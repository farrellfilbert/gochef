<?php
require_once 'db_connect.php';

// Home page aggregate data
$data = [];

// Featured kitchens
$stmt = $pdo->query("SELECT * FROM kitchens WHERE is_featured = 1 ORDER BY rating DESC LIMIT 5");
$data['featured_kitchens'] = $stmt->fetchAll();

// Popular meals
$stmt = $pdo->query("
    SELECT mi.*, k.name as kitchen_name, k.avatar as kitchen_avatar
    FROM menu_items mi
    JOIN kitchens k ON mi.kitchen_id = k.id
    WHERE mi.is_popular = 1 AND mi.is_available = 1
    ORDER BY mi.rating DESC LIMIT 10
");
$data['popular_meals'] = $stmt->fetchAll();

// Categories
$stmt = $pdo->query("SELECT * FROM categories ORDER BY sort_order ASC");
$data['categories'] = $stmt->fetchAll();

// Active promotions
$stmt = $pdo->query("SELECT * FROM promotions WHERE is_active = 1 AND (end_date IS NULL OR end_date >= CURDATE()) ORDER BY created_at DESC LIMIT 3");
$data['promotions'] = $stmt->fetchAll();

echo json_encode(['success' => true, 'data' => $data]);
?>
