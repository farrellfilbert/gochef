<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

require_once 'db_connect.php';

$user_id = isset($_GET['user_id']) ? $_GET['user_id'] : null;
$last_open_time = isset($_GET['last_open_time']) ? $_GET['last_open_time'] : null;

if (!$user_id) {
    echo json_encode(['success' => false, 'error' => 'Missing user ID']);
    exit;
}

try {
    // Unread notifications (Promos/System)
    $q1 = "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0";
    $params1 = [$user_id];
    if ($last_open_time) {
        $q1 .= " AND created_at > ?";
        $params1[] = $last_open_time;
    }
    $stmt1 = $pdo->prepare($q1);
    $stmt1->execute($params1);
    $unread_notifications = intval($stmt1->fetchColumn());

    // Unread chats
    $q2 = "SELECT COUNT(*) FROM chat_messages WHERE receiver_id = ? AND is_read = 0";
    $params2 = [$user_id];
    if ($last_open_time) {
        $q2 .= " AND created_at > ?";
        $params2[] = $last_open_time;
    }
    $stmt2 = $pdo->prepare($q2);
    $stmt2->execute($params2);
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
