<?php



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
    $kitchen_id = $_GET['kitchen_id'] ?? null;
    
    if (!$user_id && !$kitchen_id) {
        echo json_encode(['success' => false, 'error' => 'user_id or kitchen_id is required', 'data' => []]);
        exit();
    }
    
    // Fetch orders for this user or kitchen
        if ($kitchen_id) {
            $stmt = $pdo->prepare("
                SELECT o.*, u.name as customer_name, u.phone as customer_phone, u.avatar as customer_avatar, k.user_id as kitchen_user_id
                FROM orders o 
                LEFT JOIN users u ON o.user_id = u.id 
                LEFT JOIN kitchens k ON o.kitchen_id = k.id
                WHERE o.kitchen_id = ? 
                ORDER BY o.id DESC
            ");
            $stmt->execute([$kitchen_id]);
        } else {
            $stmt = $pdo->prepare("
                SELECT o.*, u.name as customer_name, u.phone as customer_phone, u.avatar as customer_avatar, k.user_id as kitchen_user_id
                FROM orders o 
                LEFT JOIN users u ON o.user_id = u.id 
                LEFT JOIN kitchens k ON o.kitchen_id = k.id
                WHERE o.user_id = ? 
                ORDER BY o.id DESC
            ");
            $stmt->execute([$user_id]);
        }
    $orders = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $response = [];
    foreach ($orders as $order) {
        $itemStmt = $pdo->prepare("SELECT name, options, quantity, price FROM order_items WHERE order_id = ?");
        $itemStmt->execute([$order['id']]);
        $items = $itemStmt->fetchAll(PDO::FETCH_ASSOC);
        
        $response[] = [
            'id' => $order['id'],
            'user_id' => $order['user_id'],
            'customer_name' => $order['customer_name'] ?? 'Guest',
            'customer_phone' => $order['customer_phone'] ?? '',
            'customer_avatar' => $order['customer_avatar'] ?? '',
            'kitchen_id' => $order['kitchen_id'],
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
