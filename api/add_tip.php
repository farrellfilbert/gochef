<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once 'db_connect.php';

try {
    $pdo->exec("ALTER TABLE orders ADD COLUMN tip_amount DECIMAL(10,2) DEFAULT 0.00");
} catch (Exception $e) {}

$input = json_decode(file_get_contents('php://input'), true);
$order_id = $input['order_id'] ?? null;
$tip_amount = floatval($input['tip_amount'] ?? 0.00);

if (!$order_id || $tip_amount <= 0) {
    echo json_encode(['success' => false, 'error' => 'Valid order_id and tip_amount (> 0) required']);
    exit;
}

try {
    $tipNote = " | Tip: $" . number_format($tip_amount, 2);
    $stmt = $pdo->prepare("UPDATE orders SET tip_amount = COALESCE(tip_amount, 0) + ?, total_amount = total_amount + ?, notes = CONCAT(COALESCE(notes, ''), ?) WHERE id = ?");
    $stmt->execute([$tip_amount, $tip_amount, $tipNote, $order_id]);

    echo json_encode([
        'success' => true,
        'message' => 'Tip of $' . number_format($tip_amount, 2) . ' successfully added to order ' . $order_id,
        'tip_amount' => $tip_amount,
        'order_id' => $order_id
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>

