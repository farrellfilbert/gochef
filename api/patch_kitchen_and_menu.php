<?php
require_once 'db_connect.php';

header('Content-Type: application/json; charset=UTF-8');

$results = [];

try {
    // 1. Check and add columns to kitchens table
    $stmt = $pdo->query("SHOW COLUMNS FROM kitchens");
    $kitchenCols = $stmt->fetchAll(PDO::FETCH_COLUMN);

    if (!in_array('business_hours', $kitchenCols)) {
        $pdo->exec("ALTER TABLE kitchens ADD COLUMN business_hours VARCHAR(100) DEFAULT '09:00 AM - 10:00 PM'");
        $results[] = "Added column business_hours to kitchens";
    } else {
        $results[] = "Column business_hours already exists in kitchens";
    }

    if (!in_array('is_open', $kitchenCols)) {
        $pdo->exec("ALTER TABLE kitchens ADD COLUMN is_open TINYINT(1) DEFAULT 1");
        $results[] = "Added column is_open to kitchens";
    } else {
        $results[] = "Column is_open already exists in kitchens";
    }

    // 2. Check and add columns to menu_items table
    $stmt = $pdo->query("SHOW COLUMNS FROM menu_items");
    $menuCols = $stmt->fetchAll(PDO::FETCH_COLUMN);

    if (!in_array('is_available', $menuCols)) {
        $pdo->exec("ALTER TABLE menu_items ADD COLUMN is_available TINYINT(1) DEFAULT 1");
        $results[] = "Added column is_available to menu_items";
    } else {
        $results[] = "Column is_available already exists in menu_items";
    }

    // 3. Inspect sample kitchen row
    $sampleStmt = $pdo->query("SELECT id, name, business_hours, is_open FROM kitchens LIMIT 3");
    $sampleKitchens = $sampleStmt->fetchAll();

    echo json_encode([
        'success' => true,
        'results' => $results,
        'sampleKitchens' => $sampleKitchens
    ], JSON_PRETTY_PRINT);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
