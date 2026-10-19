<?php
require_once 'db_connect.php';

header('Content-Type: application/json');

$tables = ['reviews', 'notifications', 'messages', 'users', 'kitchens', 'menu_items', 'orders', 'order_items'];
$results = [];

foreach ($tables as $table) {
    try {
        $pdo->exec("ALTER TABLE `$table` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
        $results[$table] = 'Converted to utf8mb4 successfully';
    } catch (Exception $e) {
        $results[$table] = 'Error: ' . $e->getMessage();
    }
}

// Also fix any reviews where comment has '?' placeholders if needed
try {
    $stmt = $pdo->query("SELECT id, comment FROM reviews");
    $reviews = $stmt->fetchAll();
    foreach ($reviews as $r) {
        $newComment = str_replace(
            ['5/5 ?', 'experience! ??', 'Tasty ??', 'Delivery ?)'],
            ['5/5 ⭐', 'experience! 🌟', 'Tasty 😋', 'Delivery 🚀)'],
            $r['comment']
        );
        if ($newComment !== $r['comment']) {
            $pdo->prepare("UPDATE reviews SET comment = ? WHERE id = ?")->execute([$newComment, $r['id']]);
        }
    }
    $results['reviews_cleaned'] = true;
} catch (Exception $e) {
    $results['reviews_cleaned_error'] = $e->getMessage();
}

echo json_encode(['success' => true, 'results' => $results]);
?>
