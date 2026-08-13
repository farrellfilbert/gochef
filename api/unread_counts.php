<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

require_once 'db_connect.php';

$user_id = isset($_GET['user_id']) ? $_GET['user_id'] : null;

if (!$user_id) {
    echo json_encode(['success' => false, 'error' => 'Missing user ID']);
    exit;
}

try {
    // Unread notifications (Promos/System)
    $stmt1 = $pdo->prepare("SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0");
    $stmt1->execute([$user_id]);
    $unread_notifications = intval($stmt1->fetchColumn());

    // Unread chats
    $stmt2 = $pdo->prepare("SELECT COUNT(*) FROM chat_messages WHERE receiver_id = ? AND is_read = 0");
    $stmt2->execute([$user_id]);
    $unread_chats = intval($stmt2->fetchColumn());

    echo json_encode([
        'success' => true,
        'data' => [
            'unread_notifications' => $unread_notifications,
            'unread_chats' => $unread_chats,
            'total_unread' => $unread_notifications + $unread_chats
        ]
    ]);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>
