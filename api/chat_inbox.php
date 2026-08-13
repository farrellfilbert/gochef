<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

require_once 'db_connect.php';

$user_id = isset($_GET['user_id']) ? $_GET['user_id'] : null;
$role = isset($_GET['role']) ? $_GET['role'] : 'user'; // 'user' or 'chef'

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

    // We want the latest message for each conversation
    // A conversation is uniquely identified by the pair (LEAST(sender_id, receiver_id), GREATEST(sender_id, receiver_id)) and order_id
    
    $stmt = $pdo->prepare("
        SELECT 
            m1.*, 
            u.name as other_user_name, 
            u.avatar as other_user_avatar,
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
        LEFT JOIN kitchens k ON (k.user_id = u.id OR k.id = m1.kitchen_id)
        ORDER BY m1.created_at DESC
    ");
    
    $stmt->execute([$user_id, $user_id, $user_id, $user_id]);
    $inbox_raw = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $inbox = [];
    foreach ($inbox_raw as $row) {
        $other_id = ($row['sender_id'] == $user_id) ? $row['receiver_id'] : $row['sender_id'];
        
        $name = $row['other_user_name'];
        $avatar = $row['other_user_avatar'];
        
        // If the other person is a chef, prefer kitchen name/avatar
        if (!empty($row['kitchen_name']) && $role == 'user') {
            $name = $row['kitchen_name'];
            if (!empty($row['kitchen_avatar'])) {
                $avatar = $row['kitchen_avatar'];
            }
        }
        
        $inbox[] = [
            'other_user_id' => $other_id,
            'name' => $name,
            'avatar' => $avatar,
            'last_message' => $row['message'],
            'created_at' => $row['created_at'],
            'unread_count' => $row['unread_count'],
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
