<?php

header('Content-Type: application/json');

$db_host = 'localhost';
$db_user = 'astroboomin_id_rsa';
$db_pass = 'Astroboomin2026!';
$db_name = 'astroboomin_gochef';

try {
    $pdo = new PDO("mysql:host=$db_host;dbname=$db_name;charset=utf8mb4", $db_user, $db_pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $queries = [
        "ALTER TABLE users ADD COLUMN role VARCHAR(20) DEFAULT 'user'",
        "ALTER TABLE users ADD COLUMN phone VARCHAR(50) DEFAULT ''",
        "ALTER TABLE users ADD COLUMN avatar VARCHAR(500) DEFAULT ''",
        "ALTER TABLE kitchens ADD COLUMN avatar VARCHAR(500) DEFAULT ''",
        "ALTER TABLE kitchens ADD COLUMN cover_image VARCHAR(500) DEFAULT ''",
        "ALTER TABLE kitchens ADD COLUMN business_hours VARCHAR(255) DEFAULT '09:00 AM - 10:00 PM'",
        "ALTER TABLE kitchens ADD COLUMN is_open TINYINT(1) DEFAULT 1",
        "ALTER TABLE orders ADD COLUMN order_type VARCHAR(50) DEFAULT 'delivery'",
        "ALTER TABLE orders ADD COLUMN dine_in_date VARCHAR(50) DEFAULT NULL",
        "ALTER TABLE orders ADD COLUMN dine_in_time VARCHAR(50) DEFAULT NULL",
        "ALTER TABLE orders ADD COLUMN discount_amount DECIMAL(10,2) DEFAULT 0.00",
        "ALTER TABLE orders ADD COLUMN promo_code VARCHAR(50) DEFAULT NULL",
        "ALTER TABLE orders ADD COLUMN delivery_address TEXT DEFAULT NULL",
    ];

    $results = [];
    foreach ($queries as $query) {
        try {
            $pdo->exec($query);
            $results[] = "Success: $query";
        } catch (PDOException $e) {
            $results[] = "Skipped/Failed: $query - " . $e->getMessage();
        }
    }

    echo json_encode(['success' => true, 'results' => $results]);
} catch (Exception $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>
