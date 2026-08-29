<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require_once 'api/db_connect.php';

try {
    $orderId = 'TEST-' . date('Y') . '-' . rand(1000, 9999);
    $userId = 1; // Assuming user 1 exists
    $kitchenId = 1; // Assuming kitchen 1 exists
    $kitchenName = 'Test Kitchen';
    
    // Create query exact as in create_stripe_checkout.php
    $stmt = $pdo->prepare("INSERT INTO orders (id, user_id, kitchen_id, kitchen_name, order_date, order_type, dine_in_date, dine_in_time, discount_amount, promo_code, status, total_amount, items_count, avatar, delivery_address, notes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
    
    $stmt->execute([
        $orderId, 
        $userId, 
        $kitchenId, 
        $kitchenName, 
        date('Y-m-d H:i:s'),
        'delivery',
        null,
        null,
        0.00,
        null,
        'pending',
        10.00,
        1,
        '',
        'Test Address',
        'Test Note'
    ]);
    
    echo "INSERT SUCCESS";
    
    $pdo->prepare("DELETE FROM orders WHERE id = ?")->execute([$orderId]);
    
} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage();
}
?>
