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
    // 1. Calculate calories from today's orders
    $dailySql = "SELECT COALESCE(SUM(COALESCE(mi.calories, 650) * oi.quantity), 0) as total_daily_calories,
                        COUNT(DISTINCT o.id) as today_orders_count
                 FROM orders o
                 JOIN order_items oi ON o.id = oi.order_id
                 LEFT JOIN menu_items mi ON oi.menu_item_id = mi.id
                 WHERE o.user_id = ? 
                   AND DATE(o.created_at) = CURDATE()
                   AND o.status != 'cancelled'";
    
    $dailyStmt = $pdo->prepare($dailySql);
    $dailyStmt->execute([$user_id]);
    $dailyData = $dailyStmt->fetch(PDO::FETCH_ASSOC);

    $dailyCalories = intval($dailyData['total_daily_calories'] ?? 0);
    $todayOrdersCount = intval($dailyData['today_orders_count'] ?? 0);

    // 2. Calculate calories from this week's orders (last 7 days)
    $weeklySql = "SELECT COALESCE(SUM(COALESCE(mi.calories, 650) * oi.quantity), 0) as total_weekly_calories,
                         COUNT(DISTINCT o.id) as weekly_orders_count
                  FROM orders o
                  JOIN order_items oi ON o.id = oi.order_id
                  LEFT JOIN menu_items mi ON oi.menu_item_id = mi.id
                  WHERE o.user_id = ? 
                    AND o.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
                    AND o.status != 'cancelled'";
    
    $weeklyStmt = $pdo->prepare($weeklySql);
    $weeklyStmt->execute([$user_id]);
    $weeklyData = $weeklyStmt->fetch(PDO::FETCH_ASSOC);

    $weeklyCalories = intval($weeklyData['total_weekly_calories'] ?? 0);
    $weeklyOrdersCount = intval($weeklyData['weekly_orders_count'] ?? 0);

    // 3. Recommended daily goal benchmark (standard 2,000 kcal)
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
