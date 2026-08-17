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

    // Calculate real 7-day daily performance
    $daily_performance = [];
    $seven_day_sales = 0;
    $seven_day_orders = 0;

    for ($i = 6; $i >= 0; $i--) {
        $day_ts = strtotime("-$i days");
        $day_start = strtotime("midnight", $day_ts);
        $day_end = strtotime("tomorrow", $day_start) - 1;
        $day_label = strtoupper(date('D', $day_ts));
        $date_formatted = date('M d', $day_ts);
        $is_today = ($i === 0);

        $day_revenue = 0.0;
        $day_orders_count = 0;

        foreach ($all_completed as $order) {
            $dateStr = $order['order_date'];
            $ts = strpos($dateStr, 'T') !== false ? strtotime($dateStr) : strtotime(str_replace(' - ', ' ', $dateStr));
            if ($ts !== false && $ts >= $day_start && $ts <= $day_end) {
                $day_revenue += (float)$order['total_amount'];
            }
        }

        foreach ($all_orders as $order) {
            $dateStr = $order['order_date'];
            $ts = strpos($dateStr, 'T') !== false ? strtotime($dateStr) : strtotime(str_replace(' - ', ' ', $dateStr));
            if ($ts !== false && $ts >= $day_start && $ts <= $day_end) {
                $day_orders_count++;
            }
        }

        $seven_day_sales += $day_revenue;
        $seven_day_orders += $day_orders_count;

        $daily_performance[] = [
            'day' => $day_label,
            'date' => $date_formatted,
            'sales' => (float)$day_revenue,
            'orders' => $day_orders_count,
            'is_today' => $is_today
        ];
    }

    echo json_encode([
        'success' => true,
        'data' => [
            'todays_orders' => $todays_orders,
            'revenue' => (float)$revenue,
            'monthly' => (float)$monthly,
            'total_orders' => $total_orders,
            'seven_day_sales' => (float)$seven_day_sales,
            'seven_day_orders' => (int)$seven_day_orders,
            'daily_performance' => $daily_performance
        ]
    ]);
} catch (Exception $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>
