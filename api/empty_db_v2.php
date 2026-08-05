<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');

$db_host = 'localhost';
$db_user = 'astroboomin_id_rsa';
$db_pass = 'Astroboomin2026!';
$db_name = 'astroboomin_gochef';

try {
    $pdo = new PDO("mysql:host=$db_host;dbname=$db_name;charset=utf8mb4", $db_user, $db_pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    $tables = [
        'cart_item_addons',
        'cart_items',
        'order_items',
        'orders',
        'addresses',
        'notifications',
        'favorites',
        'reviews',
        'menu_addons',
        'menu_items',
        'categories',
        'kitchens',
        'users'
    ];
    
    $pdo->exec('SET FOREIGN_KEY_CHECKS = 0;');
    foreach ($tables as $table) {
        $pdo->exec("TRUNCATE TABLE `$table`;");
    }
    $pdo->exec('SET FOREIGN_KEY_CHECKS = 1;');
    
    echo json_encode(['success' => true, 'message' => 'Database emptied successfully']);
} catch (Exception $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>
