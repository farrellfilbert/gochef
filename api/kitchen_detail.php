<?php
require_once 'db_connect.php';

$id = isset($_GET['id']) ? intval($_GET['id']) : 0;
$user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : 0;

if (!$id && !$user_id) {
    echo json_encode(['success' => false, 'error' => 'Kitchen ID or User ID required']);
    exit;
}

try {
    if ($id > 0) {
        $stmt = $pdo->prepare("SELECT * FROM kitchens WHERE id = ?");
        $stmt->execute([$id]);
        $kitchen = $stmt->fetch();
    } else {
        $stmt = $pdo->prepare("SELECT * FROM kitchens WHERE user_id = ? LIMIT 1");
        $stmt->execute([$user_id]);
        $kitchen = $stmt->fetch();
        if ($kitchen) {
            $id = intval($kitchen['id']);
        }
    }

    if (!$kitchen) {
        echo json_encode(['success' => false, 'error' => 'Kitchen not found']);
        exit;
    }

    // Get menu items for this kitchen
    $stmt = $pdo->prepare("SELECT mi.*, c.name as category_name FROM menu_items mi LEFT JOIN categories c ON mi.category_id = c.id WHERE mi.kitchen_id = ? ORDER BY mi.is_popular DESC, mi.name ASC");
    $stmt->execute([$id]);
    $menuItems = $stmt->fetchAll() ?: [];

    // Get reviews for this kitchen
    $stmt = $pdo->prepare("SELECT r.*, u.name as user_name, u.avatar as user_avatar FROM reviews r JOIN users u ON r.user_id = u.id WHERE r.kitchen_id = ? ORDER BY r.created_at DESC LIMIT 10");
    $stmt->execute([$id]);
    $reviews = $stmt->fetchAll() ?: [];

    $kitchen['menu_items'] = $menuItems;
    $kitchen['reviews'] = $reviews;
    if (isset($kitchen['atmosphere_images']) && !empty($kitchen['atmosphere_images'])) {
        $kitchen['atmosphere_images'] = json_decode($kitchen['atmosphere_images'], true) ?: [];
    } else {
        $kitchen['atmosphere_images'] = [];
    }

    echo json_encode(['success' => true, 'data' => $kitchen]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Database error: ' . $e->getMessage()]);
}
?>
