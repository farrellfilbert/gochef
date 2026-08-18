<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once 'db_connect.php';

$data = json_decode(file_get_contents("php://input"));

if (
    !isset($data->sender_id) ||
    !isset($data->receiver_id) ||
    !isset($data->message)
) {
    echo json_encode(['success' => false, 'error' => 'Missing required fields']);
    exit;
}

$kitchen_id = isset($data->kitchen_id) ? $data->kitchen_id : null;
$order_id = isset($data->order_id) ? $data->order_id : null;
$image_url = isset($data->image_url) ? $data->image_url : null;

try {
    // Ensure image_url column exists
    try {
        $pdo->exec("ALTER TABLE chat_messages ADD COLUMN image_url VARCHAR(500) DEFAULT NULL");
    } catch (Exception $e) {}

    $stmt = $pdo->prepare("INSERT INTO chat_messages (sender_id, receiver_id, kitchen_id, order_id, message, image_url) VALUES (?, ?, ?, ?, ?, ?)");
    $stmt->execute([$data->sender_id, $data->receiver_id, $kitchen_id, $order_id, $data->message ?? '', $image_url]);
    
    echo json_encode([
        'success' => true,
        'message_id' => $pdo->lastInsertId(),
        'image_url' => $image_url
    ]);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>
