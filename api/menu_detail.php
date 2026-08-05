<?php
require_once 'db_connect.php';

if (!isset($_GET['id'])) {
    echo json_encode(['success' => false, 'error' => 'Menu item ID required']);
    exit;
}

$id = intval($_GET['id']);

// Get menu item with kitchen info
$stmt = $pdo->prepare("SELECT mi.*, k.name as kitchen_name, k.avatar as kitchen_avatar, k.id as kitchen_id, k.rating as kitchen_rating, k.delivery_time as kitchen_delivery_time
    FROM menu_items mi 
    JOIN kitchens k ON mi.kitchen_id = k.id 
    WHERE mi.id = ?");
$stmt->execute([$id]);
$item = $stmt->fetch();

if (!$item) {
    echo json_encode(['success' => false, 'error' => 'Menu item not found']);
    exit;
}

// Get add-ons
$stmt = $pdo->prepare("SELECT * FROM menu_addons WHERE menu_item_id = ?");
$stmt->execute([$id]);
$item['addons'] = $stmt->fetchAll();

// Get reviews
$stmt = $pdo->prepare("SELECT r.*, u.name as user_name, u.avatar as user_avatar FROM reviews r JOIN users u ON r.user_id = u.id WHERE r.menu_item_id = ? ORDER BY r.created_at DESC LIMIT 10");
$stmt->execute([$id]);
$item['reviews'] = $stmt->fetchAll();

// Get related items from same kitchen
$stmt = $pdo->prepare("SELECT id, name, price, image, rating FROM menu_items WHERE kitchen_id = ? AND id != ? AND is_available = 1 LIMIT 5");
$stmt->execute([$item['kitchen_id'], $id]);
$item['related_items'] = $stmt->fetchAll();

echo json_encode(['success' => true, 'data' => $item]);
?>
