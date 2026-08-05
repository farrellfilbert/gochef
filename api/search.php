<?php
require_once 'db_connect.php';

$q = isset($_GET['q']) ? trim($_GET['q']) : '';

if (empty($q)) {
    echo json_encode(['success' => true, 'kitchens' => [], 'menu_items' => []]);
    exit;
}

// Search kitchens
$stmt = $pdo->prepare("SELECT * FROM kitchens WHERE name LIKE ? OR cuisine_type LIKE ? OR description LIKE ? ORDER BY rating DESC LIMIT 10");
$stmt->execute(["%$q%", "%$q%", "%$q%"]);
$kitchens = $stmt->fetchAll();

// Search menu items
$stmt = $pdo->prepare("
    SELECT mi.*, k.name as kitchen_name, k.avatar as kitchen_avatar
    FROM menu_items mi
    JOIN kitchens k ON mi.kitchen_id = k.id
    WHERE (mi.name LIKE ? OR mi.description LIKE ?) AND mi.is_available = 1
    ORDER BY mi.rating DESC LIMIT 20
");
$stmt->execute(["%$q%", "%$q%"]);
$menuItems = $stmt->fetchAll();

echo json_encode(['success' => true, 'kitchens' => $kitchens, 'menu_items' => $menuItems]);
?>
