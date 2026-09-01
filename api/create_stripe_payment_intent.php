<?php
// api/create_stripe_payment_intent.php
require_once 'db_connect.php';
require_once 'config.php';

header('Content-Type: application/json');

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    $user_id = intval($input['user_id'] ?? 0);
    $address_id = intval($input['address_id'] ?? 0);
    $kitchen_id = intval($input['kitchen_id'] ?? 0);
    $notes = $input['notes'] ?? '';
    
    $order_type = $input['order_type'] ?? 'delivery';
    $dine_in_date = $input['dine_in_date'] ?? null;
    $dine_in_time = $input['dine_in_time'] ?? null;
    $promo_code = $input['promo_code'] ?? null;

    if (!$user_id || !$kitchen_id) {
        echo json_encode(['success' => false, 'error' => 'user_id and kitchen_id required']);
        exit;
    }

    try {
        // Get cart items for specific kitchen
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
        $foodSubtotal = 0;
        $itemsCount = 0;
        
        foreach ($cartItems as $item) {
            // Add addon prices
            $addonStmt = $pdo->prepare("SELECT SUM(ma.price) as addon_total FROM cart_item_addons cia JOIN menu_addons ma ON cia.addon_id = ma.id WHERE cia.cart_item_id = ?");
            $addonStmt->execute([$item['id']]);
            $addonTotal = floatval($addonStmt->fetchColumn() ?? 0);
            
            $finalPrice = floatval($item['price']) + $addonTotal;
            $subtotal = $finalPrice * intval($item['quantity']);
            $foodSubtotal += $subtotal;
            $itemsCount += intval($item['quantity']);
        }

        // Get delivery address
        $deliveryAddress = '';
        if ($address_id && $order_type !== 'dine_in') {
            $stmt = $pdo->prepare("SELECT address FROM addresses WHERE id = ? AND user_id = ?");
            $stmt->execute([$address_id, $user_id]);
            $deliveryAddress = $stmt->fetchColumn() ?: '';
        }

        $total = $foodSubtotal;

        // Handle Promo Code
        $discountAmount = 0;
        if (!empty($promo_code)) {
            $promoStmt = $pdo->prepare("SELECT discount_percent FROM promotions WHERE code = ? AND is_active = 1");
            $promoStmt->execute([$promo_code]);
            $discountPercent = $promoStmt->fetchColumn();
            
            if ($discountPercent) {
                $discountAmount = ($total * floatval($discountPercent)) / 100.0;
                $total -= $discountAmount;
            }
        }
        
        // Add Delivery Fee if applicable
        $deliveryFee = floatval($input['delivery_fee'] ?? 4.00);
        if ($order_type === 'delivery') {
            $total += $deliveryFee;
        }

        // Add Service Fee if applicable
        $serviceFee = floatval($input['service_fee'] ?? 0.00);
        if ($serviceFee > 0) {
            $total += $serviceFee;
        }

        // Round to 2 decimals
        $total = round($total, 2);

        // Create initial pending order ID
        $orderId = 'ORD-' . date('Y') . '-' . str_pad(rand(1, 9999), 4, '0', STR_PAD_LEFT);
        $kitchenName = $cartItems[0]['kitchen_name'] ?? 'Kitchen';
        $kitchenAvatar = $cartItems[0]['kitchen_avatar'] ?? $cartItems[0]['image'] ?? '';
        $status = 'pending_payment';

        // Insert pending order
        $stmt = $pdo->prepare("INSERT INTO orders (id, user_id, kitchen_id, kitchen_name, order_date, order_type, dine_in_date, dine_in_time, discount_amount, promo_code, status, total_amount, items_count, avatar, delivery_address, notes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
        $stmt->execute([
            $orderId, $user_id, $kitchen_id, $kitchenName,
            gmdate('Y-m-d\TH:i:s\Z'), $order_type, $dine_in_date, $dine_in_time, $discountAmount, $promo_code, $status, $total, $itemsCount,
            $kitchenAvatar, $deliveryAddress, $notes
        ]);

        // Insert order items
        $itemStmt = $pdo->prepare("INSERT INTO order_items (order_id, name, options, quantity, price) VALUES (?, ?, ?, ?, ?)");
        foreach ($cartItems as $item) {
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

            $addonTotal = 0;
            foreach ($addons as $a) {
                $addonTotal += floatval($a['price']);
            }
            $finalPrice = floatval($item['price']) + $addonTotal;
            
            $itemStmt->execute([$orderId, $item['name'], $optionsString, $item['quantity'], $finalPrice]);
        }

        // Amount in cents for Stripe (e.g. 26.88 -> 2688)
        $amountInCents = intval(round($total * 100));

        // Call Stripe PaymentIntents API
        $postFields = [
            'amount' => $amountInCents,
            'currency' => 'usd',
            'automatic_payment_methods[enabled]' => 'true',
            'description' => "GoChef Order $orderId from $kitchenName",
            'metadata[order_id]' => $orderId,
            'metadata[user_id]' => strval($user_id),
            'metadata[kitchen_id]' => strval($kitchen_id),
            'metadata[kitchen_name]' => $kitchenName,
        ];

        $ch = curl_init('https://api.stripe.com/v1/payment_intents');
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_IPRESOLVE, CURL_IPRESOLVE_V4);
        curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($postFields));
        curl_setopt($ch, CURLOPT_USERPWD, STRIPE_SECRET_KEY . ':');

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if ($httpCode == 200) {
            $intent = json_decode($response, true);
            $clientSecret = $intent['client_secret'];
            
            $domain_url = 'https://thegrubnextdoor.com';
            $payUrl = $domain_url . '/pay.php?' . http_build_query([
                'client_secret' => $clientSecret,
                'order_id' => $orderId,
                'total' => number_format($total, 2, '.', ''),
                'kitchen' => $kitchenName,
                'avatar' => $kitchenAvatar,
                'items' => $itemsCount
            ]);

            echo json_encode([
                'success' => true,
                'order_id' => $orderId,
                'client_secret' => $clientSecret,
                'publishable_key' => STRIPE_PUBLISHABLE_KEY,
                'total_amount' => $total,
                'kitchen_name' => $kitchenName,
                'kitchen_avatar' => $kitchenAvatar,
                'items_count' => $itemsCount,
                'checkout_url' => $payUrl,
                'pay_url' => $payUrl
            ]);
        } else {
            // Delete pending order on failure
            $pdo->prepare("DELETE FROM orders WHERE id = ?")->execute([$orderId]);
            $pdo->prepare("DELETE FROM order_items WHERE order_id = ?")->execute([$orderId]);
            
            echo json_encode([
                'success' => false,
                'error' => 'Failed to initialize payment with Stripe',
                'stripe_resp' => $response
            ]);
        }

    } catch (Exception $e) {
        echo json_encode(['success' => false, 'error' => $e->getMessage()]);
    }
}
?>
