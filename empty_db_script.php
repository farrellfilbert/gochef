<?php
try {
    $pdo = new PDO('mysql:host=localhost;dbname=astroboomin_gochef;charset=utf8mb4', 'astroboomin_id_rsa', 'Astroboomin2026!');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    $tables = [
        'reviews',
        'favorites',
        'notifications',
        'order_items',
        'orders',
        'cart',
        'addresses',
        'menu_items',
        'kitchens',
        'users'
    ];
    
    $pdo->exec('SET FOREIGN_KEY_CHECKS = 0;');
    foreach ($tables as $table) {
        $pdo->exec("TRUNCATE TABLE $table;");
        echo "Truncated $table\n";
    }
    $pdo->exec('SET FOREIGN_KEY_CHECKS = 1;');
    echo "Database emptied successfully.";
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
