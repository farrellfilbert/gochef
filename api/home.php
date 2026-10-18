<?php
require_once 'db_connect.php';

// Home page aggregate data
$data = [];

// Auto-assign default cover image if any kitchen has empty cover_image
try {
    $pdo->exec("UPDATE kitchens SET cover_image = 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=80' WHERE cover_image IS NULL OR cover_image = ''");
    $pdo->exec("UPDATE kitchens SET avatar = 'https://images.unsplash.com/photo-1577219491135-ce391730fb2c?auto=format&fit=crop&w=400&q=80' WHERE avatar IS NULL OR avatar = ''");
} catch(Exception $e) {}

// Featured kitchens (Latest kitchens for demo purposes)
$stmt = $pdo->query("SELECT * FROM kitchens ORDER BY id DESC LIMIT 10");
$kitchens = $stmt->fetchAll();
foreach ($kitchens as &$k) {
    if (empty($k['cover_image'])) {
        $k['cover_image'] = 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=80';
    }
    if (empty($k['avatar'])) {
        $k['avatar'] = 'https://images.unsplash.com/photo-1577219491135-ce391730fb2c?auto=format&fit=crop&w=400&q=80';
    }
}
$data['featured_kitchens'] = $kitchens;

// Popular meals (Latest available meals for demo purposes)
$stmt = $pdo->query("
    SELECT mi.*, k.name as kitchen_name, k.avatar as kitchen_avatar
    FROM menu_items mi
    JOIN kitchens k ON mi.kitchen_id = k.id
    WHERE mi.is_available = 1
    ORDER BY mi.id DESC LIMIT 15
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
