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
    $stmt1 = $pdo->prepare("SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0");
    $stmt1->execute([$user_id]);
    $unread_notifications = intval($stmt1->fetchColumn());

    // Check if user is a chef / kitchen owner
    $kStmt = $pdo->prepare("SELECT id, name FROM kitchens WHERE user_id = ? LIMIT 1");
    $kStmt->execute([$user_id]);
    $kitchen = $kStmt->fetch(PDO::FETCH_ASSOC);

    $pending_orders = 0;
    $latest_order_id = null;
    $latest_order_total = 0;
    $latest_customer_name = '';
    $latest_order_status = '';

    if ($kitchen) {
        // Chat messages for kitchen
        $stmt2 = $pdo->prepare("SELECT COUNT(*) FROM chat_messages WHERE (receiver_id = ? OR kitchen_id = ?) AND is_read = 0");
        $stmt2->execute([$user_id, $kitchen['id']]);

        // Chef pending / active incoming orders
        $ordStmt = $pdo->prepare("SELECT COUNT(*) as pending_count, MAX(id) as max_id FROM orders WHERE kitchen_id = ? AND status IN ('Pending', 'Active')");
        $ordStmt->execute([$kitchen['id']]);
        $ordData = $ordStmt->fetch(PDO::FETCH_ASSOC);
        $pending_orders = intval($ordData['pending_count'] ?? 0);
        $latest_order_id = $ordData['max_id'];

        if ($latest_order_id) {
            $latestStmt = $pdo->prepare("SELECT o.id, o.total_amount, o.status, u.name as customer_name FROM orders o LEFT JOIN users u ON o.user_id = u.id WHERE o.id = ?");
            $latestStmt->execute([$latest_order_id]);
            $latestOrd = $latestStmt->fetch(PDO::FETCH_ASSOC);
            if ($latestOrd) {
                $latest_order_total = floatval($latestOrd['total_amount']);
                $latest_customer_name = $latestOrd['customer_name'] ?? 'Customer';
                $latest_order_status = $latestOrd['status'] ?? 'Pending';
            }
        }
    } else {
        $stmt2 = $pdo->prepare("SELECT COUNT(*) FROM chat_messages WHERE receiver_id = ? AND is_read = 0");
        $stmt2->execute([$user_id]);
    }
    $unread_chats = intval($stmt2->fetchColumn());

    echo json_encode([
        'success' => true,
        'data' => [
            'unread_notifications' => $unread_notifications,
            'unread_chats' => $unread_chats,
            'pending_orders' => $pending_orders,
            'latest_order_id' => $latest_order_id,
            'latest_order_total' => $latest_order_total,
            'latest_customer_name' => $latest_customer_name,
            'latest_order_status' => $latest_order_status,
            'total_unread' => $unread_notifications + $unread_chats + $pending_orders
        ]
    ]);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>
