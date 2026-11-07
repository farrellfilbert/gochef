<?php
// admin_stats.php - Comprehensive platform financials & kitchen earnings
require_once 'db_connect.php';

header('Content-Type: application/json');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

try {
    // 1. Total revenue from all non-cancelled orders
    $stmt = $pdo->query("SELECT COALESCE(SUM(total_amount), 0) as total_volume, COUNT(id) as total_orders FROM orders WHERE status NOT IN ('Cancelled', 'pending_payment')");
    $salesRow = $stmt->fetch(PDO::FETCH_ASSOC);
    $totalVolume = floatval($salesRow['total_volume'] ?? 0);
    $totalOrders = intval($salesRow['total_orders'] ?? 0);

    // 2. Completed / Delivered orders
    $stmt = $pdo->query("SELECT COALESCE(SUM(total_amount), 0) as completed_volume, COUNT(id) as completed_count FROM orders WHERE status IN ('Completed', 'delivered', 'Delivered')");
    $compRow = $stmt->fetch(PDO::FETCH_ASSOC);
    $completedVolume = floatval($compRow['completed_volume'] ?? 0);
    $completedCount = intval($compRow['completed_count'] ?? 0);

    // 3. Average order value
    $avgOrderValue = $totalOrders > 0 ? round($totalVolume / $totalOrders, 2) : 0.0;

    // 4. Kitchens breakdown with amounts earned
    $stmt = $pdo->query("
        SELECT 
            k.id, 
            k.name, 
            COALESCE(u.name, k.name) as chef_name, 
            k.avatar, 
            k.is_verified,
            k.bank_name,
            k.bank_account_number,
            COALESCE(SUM(CASE WHEN o.status NOT IN ('Cancelled', 'pending_payment') THEN o.total_amount ELSE 0 END), 0) as total_earned,
            COUNT(CASE WHEN o.id IS NOT NULL THEN 1 ELSE NULL END) as order_count,
            COUNT(CASE WHEN o.status IN ('Completed', 'delivered', 'Delivered') THEN 1 ELSE NULL END) as completed_count
        FROM kitchens k
        LEFT JOIN users u ON k.user_id = u.id
        LEFT JOIN orders o ON k.id = o.kitchen_id
        GROUP BY k.id, k.name, u.name, k.avatar, k.is_verified, k.bank_name, k.bank_account_number
        ORDER BY total_earned DESC, order_count DESC, k.id ASC
    ");
    $kitchens = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Format kitchen numbers
    foreach ($kitchens as &$k) {
        $k['total_earned'] = floatval($k['total_earned']);
        $k['order_count'] = intval($k['order_count']);
        $k['completed_count'] = intval($k['completed_count']);
    }

    // 5. Payouts summary
    $totalPayouts = 0.0;
    $payoutCount = 0;
    try {
        $pStmt = $pdo->query("SELECT COALESCE(SUM(amount), 0) as total_payouts, COUNT(id) as payout_count FROM payout_requests");
        $pRow = $pStmt->fetch(PDO::FETCH_ASSOC);
        $totalPayouts = floatval($pRow['total_payouts'] ?? 0);
        $payoutCount = intval($pRow['payout_count'] ?? 0);
    } catch (Exception $pe) {}

    echo json_encode([
        'success' => true,
        'data' => [
            'total_volume' => $totalVolume,
            'completed_volume' => $completedVolume,
            'total_orders' => $totalOrders,
            'completed_orders' => $completedCount,
            'avg_order_value' => $avgOrderValue,
            'total_payouts' => $totalPayouts,
            'payout_count' => $payoutCount,
            'kitchens' => $kitchens
        ]
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>
