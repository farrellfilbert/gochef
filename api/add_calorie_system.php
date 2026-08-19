<?php
// add_calorie_system.php - Auto-migration for Calories feature
header('Content-Type: application/json');
require_once 'db_connect.php';

try {
    // 1. Add calories column to menu_items if not exists
    $pdo->exec("ALTER TABLE menu_items ADD COLUMN IF NOT EXISTS calories INT DEFAULT 650");

    // 2. Assign realistic calorie numbers to all existing menu items
    $stmt = $pdo->query("SELECT id, name, description FROM menu_items");
    $items = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $updateStmt = $pdo->prepare("UPDATE menu_items SET calories = ? WHERE id = ?");

    foreach ($items as $item) {
        $nameLower = strtolower($item['name'] . ' ' . $item['description']);
        $cal = 650;

        if (strpos($nameLower, 'salad') !== false || strpos($nameLower, 'greens') !== false) {
            $cal = rand(320, 480);
        } elseif (strpos($nameLower, 'soup') !== false || strpos($nameLower, 'broth') !== false || strpos($nameLower, 'noodle club') !== false) {
            $cal = rand(450, 850);
        } elseif (strpos($nameLower, 'burger') !== false || strpos($nameLower, 'steak') !== false || strpos($nameLower, 'ribs') !== false || strpos($nameLower, 'bbq') !== false) {
            $cal = rand(780, 980);
        } elseif (strpos($nameLower, 'pizza') !== false || strpos($nameLower, 'pasta') !== false || strpos($nameLower, 'lasagna') !== false) {
            $cal = rand(680, 920);
        } elseif (strpos($nameLower, 'sushi') !== false || strpos($nameLower, 'sashimi') !== false || strpos($nameLower, 'taco') !== false || strpos($nameLower, 'poke') !== false) {
            $cal = rand(420, 650);
        } elseif (strpos($nameLower, 'cake') !== false || strpos($nameLower, 'dessert') !== false || strpos($nameLower, 'cookie') !== false || strpos($nameLower, 'pie') !== false || strpos($nameLower, 'ice cream') !== false) {
            $cal = rand(340, 580);
        } elseif (strpos($nameLower, 'drink') !== false || strpos($nameLower, 'tea') !== false || strpos($nameLower, 'juice') !== false || strpos($nameLower, 'cocktail') !== false) {
            $cal = rand(120, 280);
        } else {
            $cal = rand(520, 780);
        }

        $updateStmt->execute([$cal, $item['id']]);
    }

    echo json_encode([
        'success' => true,
        'message' => 'Calories column added and all menu items updated with realistic calories.',
        'total_items_updated' => count($items)
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
