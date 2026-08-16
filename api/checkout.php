<?php
require_once 'db_connect.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    $user_id = intval($input['user_id'] ?? 0);
    $address_id = intval($input['address_id'] ?? 0);
    $kitchen_id = intval($input['kitchen_id'] ?? 0);
    $notes = $input['notes'] ?? '';
    
    // New fields
    $order_type = $input['order_type'] ?? 'delivery';
    $dine_in_date = $input['dine_in_date'] ?? null;
    $dine_in_time = $input['dine_in_time'] ?? null;
    $promo_code = $input['promo_code'] ?? null;

    if (!$user_id) {
        echo json_encode(['success' => false, 'error' => 'user_id required']);
        exit;
    }

    if (!$kitchen_id) {
        echo json_encode(['success' => false, 'error' => 'kitchen_id required']);
        exit;
    }

    try {
        // Get cart items for specific kitchen (with notes)
        $stmt = $pdo->prepare("
            SELECT ci.*, mi.name, mi.price, mi.image, 
                   k.name as kitchen_name, k.avatar as kitchen_avatar, k.id as kitchen_id
            FROM cart_items ci
            JOIN menu_items mi ON ci.menu_item_id = mi.id
            JOIN kitchens k ON mi.kitchen_id = k.id
            WHERE ci.user_id = ? AND k.id = ?
        ");
        $stmt->execute([$user_id, $kitchen_id]);
        $cartItems = $stmt->fetchAll();

        if (empty($cartItems)) {
            echo json_encode(['success' => false, 'error' => 'Cart is empty for this kitchen']);
            exit;
        }

        // Calculate total
        $total = 0;
        $itemsCount = 0;
        foreach ($cartItems as $item) {
            $subtotal = $item['price'] * $item['quantity'];
            // Add addon prices
            $addonStmt = $pdo->prepare("SELECT SUM(ma.price) as addon_total FROM cart_item_addons cia JOIN menu_addons ma ON cia.addon_id = ma.id WHERE cia.cart_item_id = ?");
            $addonStmt->execute([$item['id']]);
            $addonTotal = $addonStmt->fetchColumn() ?? 0;
            $subtotal += $addonTotal * $item['quantity'];
            $total += $subtotal;
            $itemsCount += $item['quantity'];
        }

        // Get delivery address (only if not dine-in)
        $deliveryAddress = '';
        if ($address_id && $order_type !== 'dine_in') {
            $stmt = $pdo->prepare("SELECT address FROM addresses WHERE id = ? AND user_id = ?");
            $stmt->execute([$address_id, $user_id]);
            $deliveryAddress = $stmt->fetchColumn() ?: '';
        }

        // Handle Promo Code
        $discountAmount = 0;
        if (!empty($promo_code)) {
            $promoStmt = $pdo->prepare("SELECT discount_percent FROM promotions WHERE code = ? AND is_active = 1");
            $promoStmt->execute([$promo_code]);
            $discountPercent = $promoStmt->fetchColumn();
            
            if ($discountPercent) {
                $discountAmount = ($total * $discountPercent) / 100;
                $total -= $discountAmount;
            } else {
                $promo_code = null; // Invalid promo
            }
        }

        // Create order ID
        $orderId = 'ORD-' . date('Y') . '-' . str_pad(rand(1, 9999), 4, '0', STR_PAD_LEFT);

        // Get kitchen name (from first item)
        $kitchenName = $cartItems[0]['kitchen_name'];
        $kitchenAvatar = $cartItems[0]['kitchen_avatar'] ?? '';

        $status = ($order_type === 'dine_in' || !empty($dine_in_date)) ? 'Pending' : 'Active';

        // Insert order
        $stmt = $pdo->prepare("INSERT INTO orders (id, user_id, kitchen_id, kitchen_name, order_date, order_type, dine_in_date, dine_in_time, discount_amount, promo_code, status, total_amount, items_count, avatar, delivery_address, notes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
        $stmt->execute([
            $orderId, $user_id, $kitchen_id, $kitchenName,
            gmdate('Y-m-d\TH:i:s\Z'), $order_type, $dine_in_date, $dine_in_time, $discountAmount, $promo_code, $status, $total, $itemsCount,
            $kitchenAvatar, $deliveryAddress, $notes
        ]);

        // Insert order items
        $itemStmt = $pdo->prepare("INSERT INTO order_items (order_id, name, options, quantity, price) VALUES (?, ?, ?, ?, ?)");
        foreach ($cartItems as $item) {
            // Get addons for this cart item
            $addonStmt = $pdo->prepare("SELECT ma.name, ma.price FROM cart_item_addons cia JOIN menu_addons ma ON cia.addon_id = ma.id WHERE cia.cart_item_id = ?");
            $addonStmt->execute([$item['id']]);
            $addons = $addonStmt->fetchAll(PDO::FETCH_ASSOC);
            
            $optionsParts = [];
            if (!empty($addons)) {
                $addonNames = array_map(function($a) { return $a['name']; }, $addons);
                $optionsParts[] = "Addons: " . implode(", ", $addonNames);
            }
            
            if (!empty($item['notes'])) {
                $optionsParts[] = "Notes: " . $item['notes'];
            }
            
            $optionsString = implode(" | ", $optionsParts);

            // Calculate final price per item (base + addons)
            $addonTotal = 0;
            foreach ($addons as $a) {
                $addonTotal += $a['price'];
            }
            $finalPrice = $item['price'] + $addonTotal;
            
            $itemStmt->execute([$orderId, $item['name'], $optionsString, $item['quantity'], $finalPrice]);
        }

        // Clear cart items for this kitchen only
        $pdo->prepare("
            DELETE ci FROM cart_items ci
            JOIN menu_items mi ON ci.menu_item_id = mi.id
            WHERE ci.user_id = ? AND mi.kitchen_id = ?
        ")->execute([$user_id, $kitchen_id]);

        // Create notification
        $pdo->prepare("INSERT INTO notifications (user_id, title, message, type) VALUES (?, ?, ?, 'order')")->execute([
            $user_id,
            'Order Confirmed!',
            "Your order $orderId from $kitchenName has been confirmed."
        ]);

        echo json_encode([
            'success' => true,
            'order_id' => $orderId,
            'kitchen_id' => $kitchen_id,
            'total' => $total,
            'discount' => $discountAmount,
            'items_count' => $itemsCount,
            'kitchen_name' => $kitchenName,
            'kitchen_avatar' => $kitchenAvatar,
            'status' => $status
        ]);
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'error' => $e->getMessage()]);
    }
}
?>
