<?php
require_once 'db_connect.php';
$stmt = $pdo->query("SHOW TABLES LIKE '%review%'");
var_dump($stmt->fetchAll());
?>
