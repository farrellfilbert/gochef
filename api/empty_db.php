<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

$db_host = 'localhost';
$db_user = 'astroboomin_id_rsa';
$db_pass = 'Astroboomin2026!';
$db_name = 'astroboomin_gochef';

try {
    $pdo = new PDO("mysql:host=$db_host;dbname=$db_name;charset=utf8mb4", $db_user, $db_pass);
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
        $pdo->exec("TRUNCATE TABLE `$table`;");
    }
    $pdo->exec('SET FOREIGN_KEY_CHECKS = 1;');
    
    echo json_encode(['success' => true, 'message' => 'Database emptied successfully']);
} catch (Exception $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>
