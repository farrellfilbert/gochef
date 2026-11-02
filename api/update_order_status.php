<?php



header('Content-Type: application/json');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Method not allowed']);
    exit();
}

$input = json_decode(file_get_contents('php://input'), true);
if (!$input) {
    $input = $_POST;
}

$order_id = $input['order_id'] ?? '';
$status = $input['status'] ?? '';

if (empty($order_id) || empty($status)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'order_id and status are required']);
    exit();
}

require_once 'db_connect.php';

try {

    // Check if order exists
    $stmt = $pdo->prepare("SELECT user_id, kitchen_name FROM orders WHERE id = ?");
    $stmt->execute([$order_id]);
    $order = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$order) {
        http_response_code(404);
        echo json_encode(['success' => false, 'error' => 'Order not found']);
        exit();
    }

    // Update status
    $updateStmt = $pdo->prepare("UPDATE orders SET status = ? WHERE id = ?");
    $updateStmt->execute([$status, $order_id]);

    // Create notification for the user
    $message = "Your order $order_id from {$order['kitchen_name']} is now: $status.";
    $notifStmt = $pdo->prepare("INSERT INTO notifications (user_id, title, message, type) VALUES (?, ?, ?, 'order')");
    $notifStmt->execute([$order['user_id'], 'Order Update', $message]);

    // Send customer email status notification
    try {
        $custStmt = $pdo->prepare("SELECT email, name FROM users WHERE id = ?");
        $custStmt->execute([$order['user_id']]);
        $cust = $custStmt->fetch(PDO::FETCH_ASSOC);
        if ($cust && !empty($cust['email'])) {
            require_once 'email_helper.php';
            $sub = "Order Update: $order_id is now $status";
            $heading = "Order Status: " . ucfirst($status);
            $subheading = "Good news! Your order $order_id from {$order['kitchen_name']} is now: <strong>" . htmlspecialchars($status) . "</strong>.";
            @sendOrderNotificationEmail($cust['email'], $cust['name'] ?? 'Customer', $sub, $heading, $subheading, $order_id, $order['kitchen_name'], "<p style='margin:0; font-size:13px; color:#A0A5B5;'>Current Status: <strong style='color:#22C55E;'>" . htmlspecialchars($status) . "</strong></p>", 0);
        }
    } catch (Exception $mailErr) {
    }

    echo json_encode([
        'success' => true,
        'message' => 'Order status updated successfully'
    ]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Database error']);
}
?>