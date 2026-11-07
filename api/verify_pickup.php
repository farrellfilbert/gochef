<?php
require_once 'db_connect.php';

header('Content-Type: application/json');

$raw = file_get_contents('php://input');
$body = json_decode($raw, true) ?: $_POST;

$kitchenId = isset($body['kitchen_id']) ? intval($body['kitchen_id']) : 0;
$pickupCode = isset($body['pickup_code']) ? trim($body['pickup_code']) : '';

if (empty($pickupCode)) {
    echo json_encode(['success' => false, 'error' => 'Pickup verification code is required.']);
    exit;
}

try {
    // Clean code: match either GC-ORD-YYYY-XXXX or ORD-YYYY-XXXX or ID
    $cleanCode = strtoupper($pickupCode);
    
    // Find order
    $sql = "SELECT o.*, u.name as customer_name, u.phone as customer_phone 
            FROM orders o 
            LEFT JOIN users u ON o.user_id = u.id 
            WHERE (o.order_number = ? OR o.id = ? OR CONCAT('GC-', o.order_number) = ? OR o.order_number LIKE ?)";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$cleanCode, intval($pickupCode), $cleanCode, "%$cleanCode%"]);
    $order = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$order) {
        echo json_encode(['success' => false, 'error' => "No order found matching code '$pickupCode'."]);
        exit;
    }

    if ($kitchenId > 0 && intval($order['kitchen_id']) !== $kitchenId) {
        echo json_encode(['success' => false, 'error' => 'This order belongs to another kitchen!']);
        exit;
    }

    $alreadyDone = strtolower($order['status']) === 'completed';

    if (!$alreadyDone) {
        $upStmt = $pdo->prepare("UPDATE orders SET status = 'completed', updated_at = NOW() WHERE id = ?");
        $upStmt->execute([$order['id']]);

        // Send notification to customer
        try {
            $pdo->prepare("INSERT INTO notifications (user_id, title, message, type) VALUES (?, 'Order Picked Up! 🍲', 'Your order #" . $order['order_number'] . " has been successfully verified & handed over. Enjoy your homemade meal!', 'order')")
                ->execute([$order['user_id']]);
        } catch (Exception $e) {}
    }

    echo json_encode([
        'success' => true,
        'message' => $alreadyDone 
            ? 'Order was already verified & completed.' 
            : '✅ Order successfully verified & marked as Handed Over / Completed!',
        'order' => [
            'id' => $order['id'],
            'order_number' => $order['order_number'],
            'customer_name' => $order['customer_name'] ?? 'Customer',
            'order_type' => $order['order_type'] ?? 'pickup',
            'total_amount' => floatval($order['total_amount'] ?? 0),
            'status' => 'completed',
            'items_count' => $order['items_count'] ?? 1
        ]
    ]);
} catch (Exception $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}

