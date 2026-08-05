<?php
require_once 'db_connect.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $kitchen_id = isset($_GET['kitchen_id']) ? intval($_GET['kitchen_id']) : 0;
    $menu_item_id = isset($_GET['menu_item_id']) ? intval($_GET['menu_item_id']) : 0;

    $sql = "SELECT r.*, u.name as user_name, u.avatar as user_avatar FROM reviews r JOIN users u ON r.user_id = u.id WHERE 1=1";
    $params = [];

    if ($kitchen_id) {
        $sql .= " AND r.kitchen_id = ?";
        $params[] = $kitchen_id;
    }
    if ($menu_item_id) {
        $sql .= " AND r.menu_item_id = ?";
        $params[] = $menu_item_id;
    }

    $sql .= " ORDER BY r.created_at DESC";

    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $reviews = $stmt->fetchAll();

    echo json_encode(['success' => true, 'data' => $reviews]);

} elseif ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    $user_id = intval($input['user_id'] ?? 0);
    $kitchen_id = isset($input['kitchen_id']) ? intval($input['kitchen_id']) : null;
    $menu_item_id = isset($input['menu_item_id']) ? intval($input['menu_item_id']) : null;
    $rating = intval($input['rating'] ?? 5);
    $comment = $input['comment'] ?? '';

    if (!$user_id || $rating < 1 || $rating > 5) {
        echo json_encode(['success' => false, 'error' => 'Valid user_id and rating (1-5) required']);
        exit;
    }

    $stmt = $pdo->prepare("INSERT INTO reviews (user_id, kitchen_id, menu_item_id, rating, comment) VALUES (?, ?, ?, ?, ?)");
    $stmt->execute([$user_id, $kitchen_id, $menu_item_id, $rating, $comment]);

    // Update kitchen/menu average rating
    if ($kitchen_id) {
        $pdo->prepare("UPDATE kitchens SET rating = (SELECT AVG(rating) FROM reviews WHERE kitchen_id = ?), total_reviews = (SELECT COUNT(*) FROM reviews WHERE kitchen_id = ?) WHERE id = ?")->execute([$kitchen_id, $kitchen_id, $kitchen_id]);
    }
    if ($menu_item_id) {
        $pdo->prepare("UPDATE menu_items SET rating = (SELECT AVG(rating) FROM reviews WHERE menu_item_id = ?), total_reviews = (SELECT COUNT(*) FROM reviews WHERE menu_item_id = ?) WHERE id = ?")->execute([$menu_item_id, $menu_item_id, $menu_item_id]);
    }

    echo json_encode(['success' => true, 'id' => $pdo->lastInsertId()]);
}
?>
