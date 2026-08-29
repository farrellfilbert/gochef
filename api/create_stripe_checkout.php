<?php
file_put_contents('checkout_error.log', date('Y-m-d H:i:s') . " - API HIT!\n", FILE_APPEND);
require_once 'db_connect.php';
require_once 'config.php';

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

    if (!$user_id || !$kitchen_id) {
        file_put_contents('checkout_error.log', date('Y-m-d H:i:s') . " - Missing IDs: user=$user_id, kitchen=$kitchen_id\n", FILE_APPEND);
        echo json_encode(['success' => false, 'error' => 'user_id and kitchen_id required']);
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
            file_put_contents('checkout_error.log', date('Y-m-d H:i:s') . " - Empty Cart for user=$user_id, kitchen=$kitchen_id\n", FILE_APPEND);
            echo json_encode(['success' => false, 'error' => 'Cart is empty for this kitchen']);
            exit;
        }

        // Calculate total
        $total = 0;
        $itemsCount = 0;
        $line_items = [];
        
        foreach ($cartItems as $item) {
            $subtotal = $item['price'] * $item['quantity'];
            
            // Add addon prices
            $addonStmt = $pdo->prepare("SELECT SUM(ma.price) as addon_total FROM cart_item_addons cia JOIN menu_addons ma ON cia.addon_id = ma.id WHERE cia.cart_item_id = ?");
            $addonStmt->execute([$item['id']]);
            $addonTotal = $addonStmt->fetchColumn() ?? 0;
            
            $finalPrice = $item['price'] + $addonTotal;
            $subtotal = $finalPrice * $item['quantity'];
            $total += $subtotal;
            $itemsCount += $item['quantity'];
            
            // Format for Stripe Line Items
            $line_items[] = [
                'price_data' => [
                    'currency' => 'usd',
                    'product_data' => [
                        'name' => $item['name'],
                    ],
                    'unit_amount' => intval($finalPrice * 100), // Stripe expects cents
                ],
                'quantity' => $item['quantity'],
            ];
        }

        // Get delivery address
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
                // Apply discount as a negative line item or reduce the prices directly.
                // For simplicity with Stripe Checkout without coupons, we will just add a discount line item
                // Stripe Checkout doesn't support negative line items easily without creating a Coupon object first.
                // We'll create an ad-hoc coupon via Stripe API if needed, or simply pass the discounted total.
                // Actually, the easiest is to reduce the unit_amount proportionally, OR since Stripe is tricky with ad-hoc discounts,
                // We will just create a single line item called "Order Total" for now if we have a discount to keep it simple.
                
                // Let's adjust all prices proportionally or create a coupon.
                // For now, let's keep it simple: no discount handling in Stripe for this iteration unless needed.
            }
        }
        
        // Add Delivery Fee if applicable
        $deliveryFee = floatval($input['delivery_fee'] ?? 4.00); // 4 dollar default or dynamic from Uber
        if ($order_type === 'delivery') {
            $total += $deliveryFee;
            $line_items[] = [
                'price_data' => [
                    'currency' => 'usd',
                    'product_data' => [
                        'name' => 'Delivery Fee',
                    ],
                    'unit_amount' => intval($deliveryFee * 100),
                ],
                'quantity' => 1,
            ];
        }

        // Add Service Fee if applicable
        $serviceFee = floatval($input['service_fee'] ?? 0.00);
        if ($serviceFee > 0) {
            $total += $serviceFee;
            $line_items[] = [
                'price_data' => [
                    'currency' => 'usd',
                    'product_data' => [
                        'name' => 'Service Fee',
                    ],
                    'unit_amount' => intval($serviceFee * 100),
                ],
                'quantity' => 1,
            ];
        }

        // Create initial pending order ID
        $orderId = 'ORD-' . date('Y') . '-' . str_pad(rand(1, 9999), 4, '0', STR_PAD_LEFT);
        $kitchenName = $cartItems[0]['kitchen_name'] ?? 'Kitchen';
        $kitchenAvatar = $cartItems[0]['kitchen_avatar'] ?? $cartItems[0]['image'] ?? '';
        $status = 'pending_payment'; // Important: NOT active yet

        // Ensure columns exist (omitted for brevity, assume db_setup is run)

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
                $addonTotal += $a['price'];
            }
            $finalPrice = $item['price'] + $addonTotal;
            
            $itemStmt->execute([$orderId, $item['name'], $optionsString, $item['quantity'], $finalPrice]);
        }
        
        // We DO NOT delete cart items yet! We only delete them after successful payment.

        // Create Stripe Checkout Session
        // Note: Replace with actual domain
        $domain_url = 'https://thegrubnextdoor.com/#';
        
        $stripe_data = [
            'payment_method_types' => ['card'],
            'mode' => 'payment',
            'success_url' => $domain_url . '/#/payment_success?session_id={CHECKOUT_SESSION_ID}',
            'cancel_url' => $domain_url . '/#/checkout?cancel=true',
            'client_reference_id' => $orderId,
        ];

        // Format line items for x-www-form-urlencoded
        $postData = "";
        $postData .= "payment_method_types[0]=card&";
        $postData .= "mode=payment&";
        $postData .= "success_url=" . urlencode($stripe_data['success_url']) . "&";
        $postData .= "cancel_url=" . urlencode($stripe_data['cancel_url']) . "&";
        $postData .= "client_reference_id=" . urlencode($orderId) . "&";

        foreach ($line_items as $i => $item) {
            $postData .= "line_items[$i][price_data][currency]=" . $item['price_data']['currency'] . "&";
            $postData .= "line_items[$i][price_data][unit_amount]=" . $item['price_data']['unit_amount'] . "&";
            $postData .= "line_items[$i][price_data][product_data][name]=" . urlencode($item['price_data']['product_data']['name']) . "&";
            $postData .= "line_items[$i][quantity]=" . $item['quantity'] . "&";
        }
        $postData = rtrim($postData, '&');

        $ch = curl_init('https://api.stripe.com/v1/checkout/sessions');
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_IPRESOLVE, CURL_IPRESOLVE_V4);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $postData);
        curl_setopt($ch, CURLOPT_USERPWD, STRIPE_SECRET_KEY . ':'); // Basic Auth uses Secret Key as username

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if ($httpCode == 200) {
            $session = json_decode($response, true);
            echo json_encode([
                'success' => true,
                'checkout_url' => $session['url'],
                'order_id' => $orderId
            ]);
        } else {
            // Delete the pending order since Stripe failed to create session
            $pdo->prepare("DELETE FROM orders WHERE id = ?")->execute([$orderId]);
            $pdo->prepare("DELETE FROM order_items WHERE order_id = ?")->execute([$orderId]);
            file_put_contents('checkout_error.log', date('Y-m-d H:i:s') . " - Stripe Error: " . $response . "\n", FILE_APPEND);
            echo json_encode(['success' => false, 'error' => 'Failed to create Stripe session', 'stripe_resp' => $response]);
        }

    } catch (Exception $e) {
        $errorMsg = $e->getMessage();
        file_put_contents('checkout_error.log', date('Y-m-d H:i:s') . " - Exception: " . $errorMsg . "\n", FILE_APPEND);
        echo json_encode(['success' => false, 'error' => $errorMsg]);
    }
}
?>
