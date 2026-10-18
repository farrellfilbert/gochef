<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

require_once 'db_connect.php';

$user_id = isset($_GET['user_id']) ? $_GET['user_id'] : null;
$role = isset($_GET['role']) ? $_GET['role'] : 'user'; // 'user', 'chef', 'admin'
$is_support_desk = isset($_GET['is_support_desk']) && $_GET['is_support_desk'] == '1';

if (!$user_id) {
    echo json_encode(['success' => false, 'error' => 'Missing user ID']);
    exit;
}

try {
    // Auto-cleanup expired order chats
    $pdo->exec("
        DELETE m FROM chat_messages m 
        JOIN orders o ON m.order_id = o.id 
        WHERE o.status IN ('Completed', 'Delivered') 
          AND o.updated_at < (NOW() - INTERVAL 10 MINUTE)
    ");

    // Find dedicated support user ID
    $suppStmt = $pdo->query("SELECT id FROM users WHERE email = 'support@thegrubnextdoor.com' OR role = 'support' LIMIT 1");
    $support_user_id = $suppStmt->fetchColumn();

    // Query conversation list
    if ($is_support_desk && $support_user_id) {
        // Support desk: view all conversations with support account
        $target_id = $support_user_id;
    } else {
        $target_id = $user_id;
    }
    
    $stmt = $pdo->prepare("
        SELECT 
            m1.*, 
            u.name as other_user_name, 
            u.email as other_user_email,
            u.phone as other_user_phone,
            u.role as other_user_role,
            u.avatar as other_user_avatar,
            k.id as kitchen_id,
            k.name as kitchen_name,
            k.avatar as kitchen_avatar,
            (SELECT COUNT(*) FROM chat_messages WHERE sender_id = u.id AND receiver_id = ? AND IFNULL(order_id, '') = IFNULL(m1.order_id, '') AND is_read = 0) as unread_count
        FROM chat_messages m1
        INNER JOIN (
            SELECT 
                LEAST(sender_id, receiver_id) as p1, 
                GREATEST(sender_id, receiver_id) as p2, 
                IFNULL(order_id, '') as p3,
                MAX(created_at) as max_created_at
            FROM chat_messages
            WHERE sender_id = ? OR receiver_id = ?
            GROUP BY p1, p2, p3
        ) m2 
        ON LEAST(m1.sender_id, m1.receiver_id) = m2.p1 
           AND GREATEST(m1.sender_id, m1.receiver_id) = m2.p2 
           AND IFNULL(m1.order_id, '') = m2.p3
           AND m1.created_at = m2.max_created_at
        JOIN users u ON u.id = IF(m1.sender_id = ?, m1.receiver_id, m1.sender_id)
        LEFT JOIN kitchens k ON (k.id = m1.kitchen_id OR (k.user_id = u.id AND u.role = 'chef'))
        ORDER BY m1.created_at DESC
    ");
    
    $stmt->execute([$target_id, $target_id, $target_id, $target_id]);
    $inbox_raw = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $inbox = [];
    foreach ($inbox_raw as $row) {
        $other_id = ($row['sender_id'] == $target_id) ? $row['receiver_id'] : $row['sender_id'];
        
        $name = $row['other_user_name'];
        $avatar = $row['other_user_avatar'];
        
        $is_support = ($row['other_user_role'] === 'support' 
                       || $row['other_user_email'] === 'support@thegrubnextdoor.com'
                       || ($support_user_id && $other_id == $support_user_id));

        if ($is_support) {
            $name = 'GoChef Live Support 🎧';
            $avatar = 'https://ui-avatars.com/api/?name=GoChef+Support&background=E53935&color=fff';
        } elseif (!empty($row['kitchen_name']) && $role == 'user' && $row['other_user_role'] != 'admin' && $row['other_user_role'] != 'support') {
            // Only use kitchen name/avatar if participant is an actual chef, not admin or support
            $name = $row['kitchen_name'];
            if (!empty($row['kitchen_avatar'])) {
                $avatar = $row['kitchen_avatar'];
            }
        }
        
        $inbox[] = [
            'other_user_id' => $other_id,
            'name' => $name,
            'avatar' => $avatar,
            'role' => $row['other_user_role'] ?? 'user',
            'email' => $row['other_user_email'] ?? '',
            'phone' => $row['other_user_phone'] ?? '',
            'kitchen_id' => $row['kitchen_id'] ?? null,
            'kitchen_name' => $row['kitchen_name'] ?? null,
            'last_message' => $row['message'],
            'created_at' => $row['created_at'],
            'unread_count' => intval($row['unread_count'] ?? 0),
            'order_id' => $row['order_id']
        ];
    }

    echo json_encode([
        'success' => true,
        'inbox' => $inbox
    ]);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>
