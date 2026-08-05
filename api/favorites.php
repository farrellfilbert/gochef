<?php
require_once 'db_connect.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    if (!isset($_GET['user_id'])) {
        echo json_encode(['success' => false, 'error' => 'user_id required']);
        exit;
    }
    $user_id = intval($_GET['user_id']);
    $type = isset($_GET['type']) ? $_GET['type'] : '';

    if ($type === 'kitchen') {
        $stmt = $pdo->prepare("
            SELECT f.id as favorite_id, f.created_at as favorited_at, k.*
            FROM favorites f
            JOIN kitchens k ON f.kitchen_id = k.id
            WHERE f.user_id = ? AND f.type = 'kitchen'
            ORDER BY f.created_at DESC
        ");
    } else {
        $stmt = $pdo->prepare("
            SELECT f.id as favorite_id, f.created_at as favorited_at,
                   mi.id, mi.name, mi.price, mi.image, mi.rating, mi.prep_time,
                   k.name as kitchen_name, k.avatar as kitchen_avatar
            FROM favorites f
            JOIN menu_items mi ON f.menu_item_id = mi.id
            JOIN kitchens k ON mi.kitchen_id = k.id
            WHERE f.user_id = ? AND f.type = 'dish'
            ORDER BY f.created_at DESC
        ");
    }
    $stmt->execute([$user_id]);
    $favorites = $stmt->fetchAll();

    echo json_encode(['success' => true, 'data' => $favorites]);

} elseif ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    $user_id = intval($input['user_id'] ?? 0);
    $type = $input['type'] ?? 'dish';
    $menu_item_id = isset($input['menu_item_id']) ? intval($input['menu_item_id']) : null;
    $kitchen_id = isset($input['kitchen_id']) ? intval($input['kitchen_id']) : null;

    if (!$user_id) {
        echo json_encode(['success' => false, 'error' => 'user_id required']);
        exit;
    }

    // Check if already favorited
    if ($type === 'kitchen') {
        $stmt = $pdo->prepare("SELECT id FROM favorites WHERE user_id = ? AND kitchen_id = ? AND type = 'kitchen'");
        $stmt->execute([$user_id, $kitchen_id]);
    } else {
        $stmt = $pdo->prepare("SELECT id FROM favorites WHERE user_id = ? AND menu_item_id = ? AND type = 'dish'");
        $stmt->execute([$user_id, $menu_item_id]);
    }

    if ($stmt->fetch()) {
        echo json_encode(['success' => false, 'error' => 'Already favorited']);
        exit;
    }

    $stmt = $pdo->prepare("INSERT INTO favorites (user_id, menu_item_id, kitchen_id, type) VALUES (?, ?, ?, ?)");
    $stmt->execute([$user_id, $menu_item_id, $kitchen_id, $type]);

    echo json_encode(['success' => true, 'id' => $pdo->lastInsertId()]);

} elseif ($method === 'DELETE') {
    $input = json_decode(file_get_contents('php://input'), true);
    $favorite_id = intval($input['favorite_id'] ?? 0);

    if (!$favorite_id) {
        echo json_encode(['success' => false, 'error' => 'favorite_id required']);
        exit;
    }

    $stmt = $pdo->prepare("DELETE FROM favorites WHERE id = ?");
    $stmt->execute([$favorite_id]);

    echo json_encode(['success' => true]);
}
?>
