<?php
require_once 'db_connect.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

try {
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
    if ($search) {
        $sql .= " AND (mi.name LIKE ? OR mi.description LIKE ?)";
        $params[] = "%$search%";
        $params[] = "%$search%";
    }

    $sql .= " ORDER BY mi.is_popular DESC, mi.rating DESC";
    
    if ($popular) {
        $sql .= " LIMIT 10"; // Only limit, so we always return something
    }

    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $items = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Fetch addons for each item
    foreach ($items as &$item) {
        $addonStmt = $pdo->prepare("SELECT id, name, price FROM menu_addons WHERE menu_item_id = ?");
        $addonStmt->execute([$item['id']]);
        $item['addons'] = $addonStmt->fetchAll(PDO::FETCH_ASSOC);
    }

    echo json_encode(['success' => true, 'data' => $items]);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage(), 'data' => []]);
}
?>
