<?php
require_once 'db_connect.php';

$q = isset($_GET['q']) ? trim($_GET['q']) : '';
$dietary = isset($_GET['dietary']) ? trim($_GET['dietary']) : '';
$cuisine = isset($_GET['cuisine']) ? trim($_GET['cuisine']) : '';

// Search kitchens
$kitchenSql = "SELECT * FROM kitchens WHERE 1=1";
$kitchenParams = [];

if (!empty($q)) {
    $kitchenSql .= " AND (name LIKE ? OR cuisine_type LIKE ? OR description LIKE ?)";
    $kitchenParams[] = "%$q%";
    $kitchenParams[] = "%$q%";
    $kitchenParams[] = "%$q%";
}
if (!empty($cuisine)) {
    $kitchenSql .= " AND cuisine_type LIKE ?";
    $kitchenParams[] = "%$cuisine%";
}
$kitchenSql .= " ORDER BY rating DESC LIMIT 15";
$stmt = $pdo->prepare($kitchenSql);
$stmt->execute($kitchenParams);
$kitchens = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Search menu items
$menuSql = "
    SELECT mi.*, k.name as kitchen_name, k.avatar as kitchen_avatar, k.vacation_mode, k.vacation_return_date
    FROM menu_items mi
    JOIN kitchens k ON mi.kitchen_id = k.id
    WHERE mi.is_available = 1 AND (mi.status IS NULL OR mi.status = 'approved')
";
$menuParams = [];

if (!empty($q)) {
    $menuSql .= " AND (mi.name LIKE ? OR mi.description LIKE ?)";
    $menuParams[] = "%$q%";
    $menuParams[] = "%$q%";
}

if (!empty($dietary)) {
    $menuSql .= " AND (mi.dietary_tags LIKE ? OR mi.name LIKE ? OR mi.description LIKE ?)";
    $menuParams[] = "%$dietary%";
    $menuParams[] = "%$dietary%";
    $menuParams[] = "%$dietary%";
}

if (!empty($cuisine)) {
    $menuSql .= " AND k.cuisine_type LIKE ?";
    $menuParams[] = "%$cuisine%";
}

$menuSql .= " ORDER BY mi.rating DESC, mi.is_popular DESC LIMIT 30";
$stmt = $pdo->prepare($menuSql);
$stmt->execute($menuParams);
$menuItems = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo json_encode([
    'success' => true, 
    'kitchens' => $kitchens, 
    'menu_items' => $menuItems
]);
?>
