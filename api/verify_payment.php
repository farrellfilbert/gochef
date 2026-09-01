<?php
// api/verify_payment.php
require_once 'db_connect.php';
require_once 'config.php';

header('Content-Type: application/json');

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    $session_id = $input['session_id'] ?? '';
    $payment_intent_id = $input['payment_intent_id'] ?? $input['payment_intent'] ?? '';
    $direct_order_id = $input['order_id'] ?? '';

    if (!$session_id && !$payment_intent_id && !$direct_order_id) {
        echo json_encode(['success' => false, 'error' => 'session_id or payment_intent required']);
        exit;
    }

    try {
        $order_id = '';
        $is_paid = false;

        if (!empty($payment_intent_id)) {
            // Verify Stripe PaymentIntent
            $ch = curl_init('https://api.stripe.com/v1/payment_intents/' . urlencode($payment_intent_id));
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_USERPWD, STRIPE_SECRET_KEY . ':');
            curl_setopt($ch, CURLOPT_IPRESOLVE, CURL_IPRESOLVE_V4);

            $response = curl_exec($ch);
            $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            curl_close($ch);

            if ($httpCode == 200) {
                $intent = json_decode($response, true);
                $status = $intent['status'] ?? '';
                if ($status === 'succeeded' || $status === 'processing') {
                    $is_paid = true;
                    $order_id = $intent['metadata']['order_id'] ?? $direct_order_id;
                } else {
                    echo json_encode(['success' => false, 'error' => "Payment not succeeded (status: $status)"]);
                    exit;
                }
            } else {
                echo json_encode(['success' => false, 'error' => 'Failed to verify PaymentIntent with Stripe', 'stripe_resp' => $response]);
                exit;
            }
        } else if (!empty($session_id)) {
            // Verify Stripe Checkout Session
            $ch = curl_init('https://api.stripe.com/v1/checkout/sessions/' . urlencode($session_id));
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_USERPWD, STRIPE_SECRET_KEY . ':');
            curl_setopt($ch, CURLOPT_IPRESOLVE, CURL_IPRESOLVE_V4);

            $response = curl_exec($ch);
            $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            curl_close($ch);

            if ($httpCode == 200) {
                $session = json_decode($response, true);
                $payment_status = $session['payment_status'] ?? '';
                if ($payment_status === 'paid' || $payment_status === 'no_payment_required') {
                    $is_paid = true;
                    $order_id = $session['client_reference_id'] ?? $direct_order_id;
                } else {
                    echo json_encode(['success' => false, 'error' => "Payment not completed (status: $payment_status)"]);
                    exit;
                }
            } else {
                echo json_encode(['success' => false, 'error' => 'Failed to verify Checkout Session with Stripe', 'stripe_resp' => $response]);
                exit;
            }
        }

        if ($is_paid && !empty($order_id)) {
            // Get order details
            $stmt = $pdo->prepare("
                SELECT o.user_id, o.kitchen_id, o.kitchen_name, o.order_type, o.dine_in_date, o.total_amount,
                       (SELECT COUNT(*) FROM order_items WHERE order_id = o.id) as items_count,
                       k.avatar as kitchen_avatar
                FROM orders o
                LEFT JOIN kitchens k ON (k.id = o.kitchen_id OR k.user_id = o.kitchen_id)
                WHERE o.id = ?
            ");
            $stmt->execute([$order_id]);
            $order = $stmt->fetch();

            if ($order) {
                $new_status = ($order['order_type'] === 'dine_in' || !empty($order['dine_in_date'])) ? 'Pending' : 'Active';

                // Update order status to Active/Pending
                $pdo->prepare("UPDATE orders SET status = ? WHERE id = ? AND (status = 'pending_payment' OR status = 'Pending')")->execute([$new_status, $order_id]);
                
                // Clear cart items for this kitchen
                $pdo->prepare("
                    DELETE ci FROM cart_items ci
                    JOIN menu_items mi ON ci.menu_item_id = mi.id
                    WHERE ci.user_id = ? AND mi.kitchen_id = ?
                ")->execute([$order['user_id'], $order['kitchen_id']]);

                // Create customer notification
                $pdo->prepare("INSERT INTO notifications (user_id, title, message, type) VALUES (?, ?, ?, 'order')")->execute([
                    $order['user_id'],
                    'Payment Successful!',
                    "Your order $order_id has been confirmed and is being prepared."
                ]);

                echo json_encode([
                    'success' => true, 
                    'order_id' => $order_id, 
                    'status' => 'paid',
                    'kitchen_id' => $order['kitchen_id'],
                    'kitchen_name' => $order['kitchen_name'],
                    'total_amount' => (float)$order['total_amount'],
                    'items_count' => (int)$order['items_count'],
                    'kitchen_avatar' => $order['kitchen_avatar'] ?? ''
                ]);
            } else {
                echo json_encode(['success' => false, 'error' => "Order $order_id not found in database"]);
            }
        } else {
            echo json_encode(['success' => false, 'error' => 'Could not determine order ID from payment']);
        }

    } catch (Exception $e) {
        echo json_encode(['success' => false, 'error' => $e->getMessage()]);
    }
}
?>
