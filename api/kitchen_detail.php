<?php
require_once 'db_connect.php';

$id = isset($_GET['id']) ? intval($_GET['id']) : 0;
$user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : 0;
$viewer_id = isset($_GET['viewer_id']) ? intval($_GET['viewer_id']) : 0;

if (!$id && !$user_id) {
    echo json_encode(['success' => false, 'error' => 'Kitchen ID or User ID required']);
    exit;
}

try {
    try {
        $pdo->exec("ALTER TABLE kitchens ADD COLUMN certificates TEXT DEFAULT NULL");
    } catch (Exception $e) {}

    if ($id > 0) {
        $stmt = $pdo->prepare("SELECT k.*, u.name as chef_name FROM kitchens k LEFT JOIN users u ON k.user_id = u.id WHERE k.id = ?");
        $stmt->execute([$id]);
        $kitchen = $stmt->fetch();
    } else {
        $stmt = $pdo->prepare("SELECT k.*, u.name as chef_name FROM kitchens k LEFT JOIN users u ON k.user_id = u.id WHERE k.user_id = ? LIMIT 1");
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

    // Check if viewer has made an order from this kitchen or is the kitchen owner
    $has_purchased = false;
    if ($viewer_id > 0) {
        if ($viewer_id === intval($kitchen['user_id'])) {
            $has_purchased = true;
        } else {
            $orderCheck = $pdo->prepare("SELECT id FROM orders WHERE user_id = ? AND kitchen_id = ? LIMIT 1");
            $orderCheck->execute([$viewer_id, $id]);
            if ($orderCheck->fetch()) {
                $has_purchased = true;
            }
        }
    }
    $kitchen['has_purchased'] = $has_purchased;

    // Get menu items for this kitchen
    $stmt = $pdo->prepare("SELECT mi.*, COALESCE(mi.is_available, 1) as is_available, c.name as category_name FROM menu_items mi LEFT JOIN categories c ON mi.category_id = c.id WHERE mi.kitchen_id = ? ORDER BY mi.is_popular DESC, mi.name ASC");
    $stmt->execute([$id]);
    $menuItems = $stmt->fetchAll() ?: [];
    foreach ($menuItems as &$mItem) {
        $mItem['is_available'] = isset($mItem['is_available']) ? (int)$mItem['is_available'] : 1;
    }

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
    if (isset($kitchen['certificates']) && !empty($kitchen['certificates'])) {
        $kitchen['certificates'] = is_string($kitchen['certificates']) ? (json_decode($kitchen['certificates'], true) ?: []) : $kitchen['certificates'];
    } else {
        $kitchen['certificates'] = [];
    }

    echo json_encode(['success' => true, 'data' => $kitchen]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Database error: ' . $e->getMessage()]);
}
?>
