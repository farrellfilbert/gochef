<?php
// user_calories.php - Calculates and manages daily and weekly calorie intake and goals
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once 'db_connect.php';

// Ensure daily_calorie_goal column exists
try {
    $pdo->exec("ALTER TABLE users ADD COLUMN daily_calorie_goal INT DEFAULT 2000");
} catch (Exception $e) {
    // Column may already exist
}

// Handle POST request to update calorie target
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    $user_id = isset($input['user_id']) ? intval($input['user_id']) : 0;
    $daily_goal = isset($input['daily_goal']) ? intval($input['daily_goal']) : 2000;

    if ($daily_goal < 500) $daily_goal = 500;
    if ($daily_goal > 10000) $daily_goal = 10000;

    if ($user_id > 0) {
        $updateStmt = $pdo->prepare("UPDATE users SET daily_calorie_goal = ? WHERE id = ?");
        $updateStmt->execute([$daily_goal, $user_id]);
    }
}

$user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : (isset($input['user_id']) ? intval($input['user_id']) : 0);

try {
    // Fetch custom user calorie goal
    $dailyGoal = 2000;
    if ($user_id > 0) {
        $uStmt = $pdo->prepare("SELECT daily_calorie_goal FROM users WHERE id = ?");
        $uStmt->execute([$user_id]);
        $uRow = $uStmt->fetch(PDO::FETCH_ASSOC);
        if ($uRow && !empty($uRow['daily_calorie_goal']) && intval($uRow['daily_calorie_goal']) > 0) {
            $dailyGoal = intval($uRow['daily_calorie_goal']);
        }
    }
    $weeklyGoal = $dailyGoal * 7;

    // Fetch user orders
    $orderStmt = $pdo->prepare("SELECT id, order_date, status, total_amount, kitchen_id FROM orders WHERE user_id = ? AND status != 'cancelled' ORDER BY id DESC");
    $orderStmt->execute([$user_id]);
    $orders = $orderStmt->fetchAll(PDO::FETCH_ASSOC);

    $dailyCalories = 0;
    $weeklyCalories = 0;
    $todayOrdersCount = 0;
    $weeklyOrdersCount = 0;

    $todayStr = date('Y-m-d');
    $sevenDaysAgo = strtotime('-7 days');

    $todayMeals = [];
    $weeklyMeals = [];

    $itemStmt = $pdo->prepare("SELECT oi.quantity, oi.name, oi.price, COALESCE(mi.calories, 650) as calories, mi.image 
                               FROM order_items oi 
                               LEFT JOIN menu_items mi ON oi.name = mi.name 
                               WHERE oi.order_id = ?");

    foreach ($orders as $order) {
        $orderTimeStr = !empty($order['order_date']) ? $order['order_date'] : '';
        $orderTimestamp = !empty($orderTimeStr) ? strtotime($orderTimeStr) : time();
        $orderDate = date('Y-m-d', $orderTimestamp);

        $itemStmt->execute([$order['id']]);
        $items = $itemStmt->fetchAll(PDO::FETCH_ASSOC);

        $orderCals = 0;
        $orderItemsList = [];
        foreach ($items as $item) {
            $qty = max(1, intval($item['quantity']));
            $calPerItem = intval($item['calories'] ?? 650);
            if ($calPerItem <= 0) $calPerItem = 650;
            $totalItemCal = $calPerItem * $qty;
            $orderCals += $totalItemCal;

            $orderItemsList[] = [
                'name' => $item['name'],
                'quantity' => $qty,
                'calories_per_item' => $calPerItem,
                'total_calories' => $totalItemCal,
                'image' => $item['image'] ?? ''
            ];
        }

        $orderSummary = [
            'order_id' => $order['id'],
            'order_date' => $orderTimeStr,
            'total_calories' => $orderCals,
            'status' => $order['status'],
            'items' => $orderItemsList
        ];

        // Check if today
        if ($orderDate === $todayStr) {
            $dailyCalories += $orderCals;
            $todayOrdersCount++;
            $todayMeals[] = $orderSummary;
        }

        // Check if within 7 days
        if ($orderTimestamp >= $sevenDaysAgo) {
            $weeklyCalories += $orderCals;
            $weeklyOrdersCount++;
            $weeklyMeals[] = $orderSummary;
        }
    }

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
        'today_meals' => $todayMeals,
        'weekly_meals' => $weeklyMeals
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
