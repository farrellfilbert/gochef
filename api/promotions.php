<?php
require_once 'db_connect.php';

$stmt = $pdo->query("SELECT * FROM promotions WHERE is_active = 1 AND (end_date IS NULL OR end_date >= CURDATE()) ORDER BY created_at DESC");
$promotions = $stmt->fetchAll();

echo json_encode(['success' => true, 'data' => $promotions]);
?>
