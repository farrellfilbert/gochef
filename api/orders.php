<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$db_host = 'localhost';
$db_user = 'astroboomin_id_rsa';
$db_pass = 'Astroboomin2026!';
$db_name = 'astroboomin_gochef';

try {
    $pdo = new PDO("mysql:host=$db_host;dbname=$db_name;charset=utf8mb4", $db_user, $db_pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    $user_id = $_GET['user_id'] ?? null;
    if (!$user_id) {
        echo json_encode(['success' => false, 'error' => 'user_id is required', 'data' => []]);
        exit();
    }
    
    // Fetch orders for this user
    $stmt = $pdo->prepare("SELECT * FROM orders WHERE user_id = ? ORDER BY id DESC");
    $stmt->execute([$user_id]);
    $orders = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $response = [];
    foreach ($orders as $order) {
        $itemStmt = $pdo->prepare("SELECT name, options, quantity, price FROM order_items WHERE order_id = ?");
        $itemStmt->execute([$order['id']]);
        $items = $itemStmt->fetchAll(PDO::FETCH_ASSOC);
        
        $response[] = [
            'id' => $order['id'],
            'kitchen_name' => $order['kitchen_name'],
            'date' => $order['order_date'],
            'status' => $order['status'],
            'total_amount' => (float)$order['total_amount'],
            'items_count' => (int)$order['items_count'],
            'avatar' => $order['avatar'],
            'items' => $items
        ];
    }
    
    echo json_encode([
        'success' => true,
        'data' => $response
    ]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Database error', 'data' => []]);
}
?>
