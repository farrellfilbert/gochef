<?php
// user_calories.php - Calculates daily and weekly calorie intake for a user
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once 'db_connect.php';

$user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : 0;

try {
    // 1. Fetch user orders from last 7 days
    $orderStmt = $pdo->prepare("SELECT id, order_date, created_at, status FROM orders WHERE user_id = ? AND status != 'cancelled' ORDER BY id DESC");
    $orderStmt->execute([$user_id]);
    $orders = $orderStmt->fetchAll(PDO::FETCH_ASSOC);

    $dailyCalories = 0;
    $weeklyCalories = 0;
    $todayOrdersCount = 0;
    $weeklyOrdersCount = 0;

    $todayStr = date('Y-m-d');
    $sevenDaysAgo = strtotime('-7 days');

    $itemStmt = $pdo->prepare("SELECT oi.quantity, oi.name, COALESCE(mi.calories, 650) as calories 
                               FROM order_items oi 
                               LEFT JOIN menu_items mi ON oi.name = mi.name 
                               WHERE oi.order_id = ?");

    foreach ($orders as $order) {
        $orderTimeStr = !empty($order['created_at']) ? $order['created_at'] : (!empty($order['order_date']) ? $order['order_date'] : '');
        $orderTimestamp = strtotime($orderTimeStr);
        $orderDate = date('Y-m-d', $orderTimestamp);

        $itemStmt->execute([$order['id']]);
        $items = $itemStmt->fetchAll(PDO::FETCH_ASSOC);

        $orderCals = 0;
        foreach ($items as $item) {
            $qty = max(1, intval($item['quantity']));
            $calPerItem = intval($item['calories'] ?? 650);
            if ($calPerItem <= 0) $calPerItem = 650;
            $orderCals += ($calPerItem * $qty);
        }

        // Check if today
        if ($orderDate === $todayStr) {
            $dailyCalories += $orderCals;
            $todayOrdersCount++;
        }

        // Check if within 7 days
        if ($orderTimestamp >= $sevenDaysAgo) {
            $weeklyCalories += $orderCals;
            $weeklyOrdersCount++;
        }
    }

    $dailyGoal = 2000;
    $weeklyGoal = 14000;

    echo json_encode([
        'success' => true,
        'user_id' => $user_id,
        'daily_calories' => $dailyCalories,
        'weekly_calories' => $weeklyCalories,
        'today_orders_count' => $todayOrdersCount,
        'weekly_orders_count' => $weeklyOrdersCount,
        'daily_goal' => $dailyGoal,
        'weekly_goal' => $weeklyGoal,
        'daily_percentage' => min(100, round(($dailyCalories / $dailyGoal) * 100)),
        'weekly_percentage' => min(100, round(($weeklyCalories / $weeklyGoal) * 100)),
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
