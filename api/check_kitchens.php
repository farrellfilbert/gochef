<?php
require_once 'db_connect.php';
$stmt = $pdo->query("SHOW COLUMNS FROM kitchens");
var_dump($stmt->fetchAll(PDO::FETCH_ASSOC));
?>
