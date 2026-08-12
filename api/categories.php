<?php
require_once 'db_connect.php';

$stmt = $pdo->query("SELECT * FROM categories ORDER BY sort_order ASC, name ASC");
$categories = $stmt->fetchAll();

echo json_encode(['success' => true, 'data' => $categories]);
?>
