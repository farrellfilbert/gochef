<?php
require_once 'db_connect.php';

$pdo->query("UPDATE kitchens SET avatar = REPLACE(avatar, 'astroboomin.co', 'thegrubnextdoor.com'), cover_image = REPLACE(cover_image, 'astroboomin.co', 'thegrubnextdoor.com'), atmosphere_images = REPLACE(atmosphere_images, 'astroboomin.co', 'thegrubnextdoor.com')");
$pdo->query("UPDATE menu_items SET image_url = REPLACE(image_url, 'astroboomin.co', 'thegrubnextdoor.com')");
$pdo->query("UPDATE users SET avatar = REPLACE(avatar, 'astroboomin.co', 'thegrubnextdoor.com')");
$pdo->query("UPDATE categories SET image_url = REPLACE(image_url, 'astroboomin.co', 'thegrubnextdoor.com')");

$stmt = $pdo->query("SELECT id, name, avatar, cover_image FROM kitchens LIMIT 5");
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo json_encode(['success' => true, 'sample' => $rows], JSON_PRETTY_PRINT);
?>
