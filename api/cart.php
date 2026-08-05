<?php
require_once 'db_connect.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    // Get cart for user
    if (!isset($_GET['user_id'])) {
        echo json_encode(['success' => false, 'error' => 'user_id required']);
        exit;
    }
    $user_id = intval($_GET['user_id']);

    $stmt = $pdo->prepare("
        SELECT ci.id as cart_item_id, ci.quantity, ci.notes, 
               mi.id as menu_item_id, mi.name, mi.price, mi.image, mi.prep_time,
               k.name as kitchen_name, k.avatar as kitchen_avatar, k.id as kitchen_id
        FROM cart_items ci
        JOIN menu_items mi ON ci.menu_item_id = mi.id
        JOIN kitchens k ON mi.kitchen_id = k.id
        WHERE ci.user_id = ?
        ORDER BY ci.created_at DESC
    ");
    $stmt->execute([$user_id]);
    $items = $stmt->fetchAll();

    // Get addons for each cart item
    foreach ($items as &$item) {
        $stmt2 = $pdo->prepare("
            SELECT ma.name, ma.price 
            FROM cart_item_addons cia 
            JOIN menu_addons ma ON cia.addon_id = ma.id 
            WHERE cia.cart_item_id = ?
        ");
        $stmt2->execute([$item['cart_item_id']]);
        $item['addons'] = $stmt2->fetchAll();
    }

    echo json_encode(['success' => true, 'data' => $items]);

} elseif ($method === 'POST') {
    // Add item to cart
    $input = json_decode(file_get_contents('php://input'), true);
    $user_id = intval($input['user_id'] ?? 0);
    $menu_item_id = intval($input['menu_item_id'] ?? 0);
    $quantity = intval($input['quantity'] ?? 1);
    $notes = $input['notes'] ?? '';
    $addon_ids = $input['addon_ids'] ?? [];

    if (!$user_id || !$menu_item_id) {
        echo json_encode(['success' => false, 'error' => 'user_id and menu_item_id required']);
        exit;
    }

    // Check if item already in cart
    $stmt = $pdo->prepare("SELECT id, quantity FROM cart_items WHERE user_id = ? AND menu_item_id = ?");
    $stmt->execute([$user_id, $menu_item_id]);
    $existing = $stmt->fetch();

    if ($existing) {
        // Update quantity
        $stmt = $pdo->prepare("UPDATE cart_items SET quantity = quantity + ? WHERE id = ?");
        $stmt->execute([$quantity, $existing['id']]);
        $cart_item_id = $existing['id'];
    } else {
        // Insert new
        $stmt = $pdo->prepare("INSERT INTO cart_items (user_id, menu_item_id, quantity, notes) VALUES (?, ?, ?, ?)");
        $stmt->execute([$user_id, $menu_item_id, $quantity, $notes]);
        $cart_item_id = $pdo->lastInsertId();
    }

    // Add addons
    if (!empty($addon_ids)) {
        $stmt = $pdo->prepare("INSERT INTO cart_item_addons (cart_item_id, addon_id) VALUES (?, ?)");
        foreach ($addon_ids as $addon_id) {
            $stmt->execute([$cart_item_id, intval($addon_id)]);
        }
    }

    echo json_encode(['success' => true, 'cart_item_id' => $cart_item_id]);

} elseif ($method === 'DELETE') {
    // Remove item from cart
    $input = json_decode(file_get_contents('php://input'), true);
    $cart_item_id = intval($input['cart_item_id'] ?? 0);

    if (!$cart_item_id) {
        echo json_encode(['success' => false, 'error' => 'cart_item_id required']);
        exit;
    }

    $stmt = $pdo->prepare("DELETE FROM cart_items WHERE id = ?");
    $stmt->execute([$cart_item_id]);

    echo json_encode(['success' => true]);

} elseif ($method === 'PUT') {
    // Update cart item quantity
    $input = json_decode(file_get_contents('php://input'), true);
    $cart_item_id = intval($input['cart_item_id'] ?? 0);
    $quantity = intval($input['quantity'] ?? 1);

    if (!$cart_item_id) {
        echo json_encode(['success' => false, 'error' => 'cart_item_id required']);
        exit;
    }

    if ($quantity <= 0) {
        $stmt = $pdo->prepare("DELETE FROM cart_items WHERE id = ?");
        $stmt->execute([$cart_item_id]);
    } else {
        $stmt = $pdo->prepare("UPDATE cart_items SET quantity = ? WHERE id = ?");
        $stmt->execute([$quantity, $cart_item_id]);
    }

    echo json_encode(['success' => true]);
}
?>
