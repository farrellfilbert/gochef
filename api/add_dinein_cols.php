<?php
require_once 'db_connect.php';

try {
    $pdo->exec("ALTER TABLE orders ADD COLUMN IF NOT EXISTS order_type VARCHAR(20) DEFAULT 'delivery'");
    $pdo->exec("ALTER TABLE orders ADD COLUMN IF NOT EXISTS dine_in_date VARCHAR(50) NULL");
    $pdo->exec("ALTER TABLE orders ADD COLUMN IF NOT EXISTS dine_in_time VARCHAR(50) NULL");
    $pdo->exec("ALTER TABLE orders ADD COLUMN IF NOT EXISTS discount_amount DECIMAL(10,2) DEFAULT 0.00");
    $pdo->exec("ALTER TABLE orders ADD COLUMN IF NOT EXISTS promo_code VARCHAR(50) NULL");
    echo "Columns added successfully!";
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage();
}
?>
