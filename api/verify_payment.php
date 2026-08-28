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
                // Get order to find kitchen_id and user_id
                $stmt = $pdo->prepare("SELECT user_id, kitchen_id, kitchen_name, order_type, dine_in_date FROM orders WHERE id = ?");
                $stmt->execute([$order_id]);
                $order = $stmt->fetch();

                if ($order) {
                    $new_status = ($order['order_type'] === 'dine_in' || !empty($order['dine_in_date'])) ? 'Pending' : 'Active';

                    // Update order status
                    $pdo->prepare("UPDATE orders SET status = ? WHERE id = ? AND status = 'pending_payment'")->execute([$new_status, $order_id]);
                    
                    // Did we update a row?
                    if ($pdo->prepare("SELECT status FROM orders WHERE id = ?")->execute([$order_id]) && $pdo->prepare("SELECT status FROM orders WHERE id = ?")->fetchColumn() == $new_status) {
                        // Clear cart items for this kitchen
                        $pdo->prepare("
                            DELETE ci FROM cart_items ci
                            JOIN menu_items mi ON ci.menu_item_id = mi.id
                            WHERE ci.user_id = ? AND mi.kitchen_id = ?
                        ")->execute([$order['user_id'], $order['kitchen_id']]);

                        // Create notification
                        $pdo->prepare("INSERT INTO notifications (user_id, title, message, type) VALUES (?, ?, ?, 'order')")->execute([
                            $order['user_id'],
                            'Payment Successful!',
                            "Your payment for order $order_id has been received and confirmed."
                        ]);

                        // Initiate Uber Delivery here if it's delivery?
                        // For now, they can accept it via admin panel, or we can trigger request_uber_delivery.php asynchronously.
                        
                        echo json_encode(['success' => true, 'order_id' => $order_id, 'status' => 'paid']);
                    } else {
                        echo json_encode(['success' => true, 'message' => 'Order already processed']);
                    }
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
