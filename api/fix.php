<?php
require_once 'db_connect.php';
$stmt = $pdo->prepare("SELECT * FROM orders");
$stmt->execute();
echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
?>
