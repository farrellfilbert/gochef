<?php
require_once 'db_connect.php';
require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    $session_id = $input['session_id'] ?? '';

    if (!$session_id) {
        echo json_encode(['success' => false, 'error' => 'session_id required']);
        exit;
    }

    try {
        // Fetch session from Stripe
        $ch = curl_init('https://api.stripe.com/v1/checkout/sessions/' . urlencode($session_id));
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_USERPWD, STRIPE_SECRET_KEY . ':');

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if ($httpCode == 200) {
            $session = json_decode($response, true);
            $order_id = $session['client_reference_id'];
            $payment_status = $session['payment_status']; // 'paid', 'unpaid', or 'no_payment_required'

            if ($payment_status === 'paid') {
                // Get order to find kitchen_id and user_id, and other details for UI
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

                    // Update order status
                    $pdo->prepare("UPDATE orders SET status = ? WHERE id = ? AND status = 'pending_payment'")->execute([$new_status, $order_id]);
                    
                    $checkStmt = $pdo->prepare("SELECT status FROM orders WHERE id = ?");
                    $checkStmt->execute([$order_id]);
                    $current_status = $checkStmt->fetchColumn();

                    // Clear cart items for this kitchen
                    $pdo->prepare("
                        DELETE ci FROM cart_items ci
                        JOIN menu_items mi ON ci.menu_item_id = mi.id
                        WHERE ci.user_id = ? AND mi.kitchen_id = ?
                    ")->execute([$order['user_id'], $order['kitchen_id']]);

                    // Create notification if status was just updated (simple heuristic: if it's new_status, we send it)
                    // We can just send it, or assume it's sent. Let's just always return the order data.
                    
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
                    echo json_encode(['success' => false, 'error' => 'Order not found']);
                }
            } else {
                echo json_encode(['success' => false, 'error' => 'Payment not completed', 'status' => $payment_status]);
            }
        } else {
            echo json_encode(['success' => false, 'error' => 'Invalid session ID', 'stripe_resp' => $response]);
        }

    } catch (Exception $e) {
        echo json_encode(['success' => false, 'error' => $e->getMessage()]);
    }
}
?>
