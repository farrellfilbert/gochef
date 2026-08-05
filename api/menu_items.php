<?php
require_once 'db_connect.php';

$kitchen_id = isset($_GET['kitchen_id']) ? intval($_GET['kitchen_id']) : 0;
$category_id = isset($_GET['category_id']) ? intval($_GET['category_id']) : 0;
$popular = isset($_GET['popular']) ? true : false;
$search = isset($_GET['q']) ? trim($_GET['q']) : '';

$sql = "SELECT mi.*, k.name as kitchen_name, k.avatar as kitchen_avatar, c.name as category_name 
        FROM menu_items mi 
        JOIN kitchens k ON mi.kitchen_id = k.id 
        LEFT JOIN categories c ON mi.category_id = c.id 
        WHERE mi.is_available = 1";
$params = [];

if ($kitchen_id) {
    $sql .= " AND mi.kitchen_id = ?";
    $params[] = $kitchen_id;
}
if ($category_id) {
    $sql .= " AND mi.category_id = ?";
    $params[] = $category_id;
}
if ($popular) {
    $sql .= " AND mi.is_popular = 1";
}
if ($search) {
    $sql .= " AND (mi.name LIKE ? OR mi.description LIKE ?)";
    $params[] = "%$search%";
    $params[] = "%$search%";
}

$sql .= " ORDER BY mi.is_popular DESC, mi.rating DESC";

$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$items = $stmt->fetchAll();

echo json_encode(['success' => true, 'data' => $items]);
?>
