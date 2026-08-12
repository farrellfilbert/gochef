<?php
require_once 'db_connect.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['success' => false, 'error' => 'POST method required']);
    exit;
}

$input = json_decode(file_get_contents('php://input'), true);
$kitchen_id = intval($input['kitchen_id'] ?? 0);

if (!$kitchen_id) {
    echo json_encode(['success' => false, 'error' => 'kitchen_id required']);
    exit;
}

try {
    $stmt = $pdo->prepare("SELECT total_amount, order_date FROM orders WHERE kitchen_id = ? AND status IN ('Completed', 'Delivered')");
    $stmt->execute([$kitchen_id]);
    $all_completed = $stmt->fetchAll();

    $monthly = 0;
    $revenue = 0;
    $thirty_days_ago_ts = strtotime('-30 days');
    $today_start_ts = strtotime('today');
    $today_end_ts = strtotime('tomorrow') - 1;

    foreach ($all_completed as $order) {
        $dateStr = $order['order_date'];
        $ts = false;
        if (strpos($dateStr, 'T') !== false) {
            $ts = strtotime($dateStr);
        } else {
            // Old format: "Aug 11, 2026 - 04:28"
            $cleanDateStr = str_replace(' - ', ' ', $dateStr);
            $ts = strtotime($cleanDateStr);
        }
        
        if ($ts !== false) {
            $amount = (float)$order['total_amount'];
            $revenue += $amount;
            if ($ts >= $thirty_days_ago_ts) {
                $monthly += $amount;
            }
        }
    }
    
    $stmt = $pdo->prepare("SELECT order_date FROM orders WHERE kitchen_id = ?");
    $stmt->execute([$kitchen_id]);
    $all_orders = $stmt->fetchAll();
    
    $todays_orders = 0;
    $total_orders = count($all_orders);
    
    foreach ($all_orders as $order) {
        $dateStr = $order['order_date'];
        $ts = false;
        if (strpos($dateStr, 'T') !== false) {
            $ts = strtotime($dateStr);
        } else {
            // Old format
            $cleanDateStr = str_replace(' - ', ' ', $dateStr);
            $ts = strtotime($cleanDateStr);
        }
        if ($ts !== false && $ts >= $today_start_ts && $ts <= $today_end_ts) {
            $todays_orders++;
        }
    }

    echo json_encode([
        'success' => true,
        'data' => [
            'todays_orders' => $todays_orders,
            'revenue' => (float)$revenue,
            'monthly' => (float)$monthly,
            'total_orders' => $total_orders
        ]
    ]);
} catch (Exception $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>
