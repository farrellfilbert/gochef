<?php require_once "api/db_connect.php"; $stmt = $pdo->query("SELECT * FROM chat_messages"); print_r($stmt->fetchAll(PDO::FETCH_ASSOC)); ?>
