<?php
require_once 'db_connect.php';

if (!isset($_GET['id'])) {
    echo json_encode(['success' => false, 'error' => 'Kitchen ID required']);
    exit;
}

$id = intval($_GET['id']);

// Get kitchen info
$stmt = $pdo->prepare("SELECT * FROM kitchens WHERE id = ?");
$stmt->execute([$id]);
$kitchen = $stmt->fetch();

if (!$kitchen) {
    echo json_encode(['success' => false, 'error' => 'Kitchen not found']);
    exit;
}

// Get menu items for this kitchen
$stmt = $pdo->prepare("SELECT mi.*, c.name as category_name FROM menu_items mi LEFT JOIN categories c ON mi.category_id = c.id WHERE mi.kitchen_id = ? ORDER BY mi.is_popular DESC, mi.name ASC");
$stmt->execute([$id]);
$menuItems = $stmt->fetchAll();

// Get reviews for this kitchen
$stmt = $pdo->prepare("SELECT r.*, u.name as user_name, u.avatar as user_avatar FROM reviews r JOIN users u ON r.user_id = u.id WHERE r.kitchen_id = ? ORDER BY r.created_at DESC LIMIT 10");
$stmt->execute([$id]);
$reviews = $stmt->fetchAll();

$kitchen['menu_items'] = $menuItems;
$kitchen['reviews'] = $reviews;
if (isset($kitchen['atmosphere_images']) && !empty($kitchen['atmosphere_images'])) {
    $kitchen['atmosphere_images'] = json_decode($kitchen['atmosphere_images'], true) ?: [];
} else {
    $kitchen['atmosphere_images'] = [];
}

echo json_encode(['success' => true, 'data' => $kitchen]);
?>
