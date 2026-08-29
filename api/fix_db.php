<?php
require_once 'api/db_connect.php';

try {
    $pdo->exec("ALTER TABLE orders ADD COLUMN order_type VARCHAR(50) DEFAULT 'delivery'");
    $pdo->exec("ALTER TABLE orders ADD COLUMN dine_in_date DATE NULL");
    $pdo->exec("ALTER TABLE orders ADD COLUMN dine_in_time TIME NULL");
    $pdo->exec("ALTER TABLE orders ADD COLUMN discount_amount DECIMAL(10,2) DEFAULT 0.00");
    $pdo->exec("ALTER TABLE orders ADD COLUMN promo_code VARCHAR(50) NULL");
    $pdo->exec("ALTER TABLE orders ADD COLUMN delivery_address TEXT NULL");
    $pdo->exec("ALTER TABLE orders ADD COLUMN notes TEXT NULL");
    echo "Columns added successfully";
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
?>
