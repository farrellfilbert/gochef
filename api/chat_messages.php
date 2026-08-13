<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

require_once 'db_connect.php';

$user1_id = isset($_GET['user1_id']) ? $_GET['user1_id'] : null;
$user2_id = isset($_GET['user2_id']) ? $_GET['user2_id'] : null;
$order_id = isset($_GET['order_id']) ? $_GET['order_id'] : null;

if (!$user1_id || !$user2_id) {
    echo json_encode(['success' => false, 'error' => 'Missing user IDs']);
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

    // Fetch messages between user1 and user2
    $q = "
        SELECT id, sender_id, receiver_id, message, is_read, created_at
        FROM chat_messages
        WHERE ((sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?))
    ";
    
    $params = [$user1_id, $user2_id, $user2_id, $user1_id];
    
    if ($order_id) {
        $q .= " AND order_id = ?";
        $params[] = $order_id;
    } else {
        $q .= " AND order_id IS NULL";
    }
    
    $q .= " ORDER BY created_at ASC";
    
    $stmt = $pdo->prepare($q);
    $stmt->execute($params);
    $messages = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Mark messages as read if receiver is user1
    $uq = "
        UPDATE chat_messages 
        SET is_read = 1 
        WHERE sender_id = ? AND receiver_id = ? AND is_read = 0
    ";
    $uparams = [$user2_id, $user1_id];
    
    if ($order_id) {
        $uq .= " AND order_id = ?";
        $uparams[] = $order_id;
    } else {
        $uq .= " AND order_id IS NULL";
    }
    
    $updateStmt = $pdo->prepare($uq);
    $updateStmt->execute($uparams);

    echo json_encode([
        'success' => true,
        'messages' => $messages
    ]);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>
