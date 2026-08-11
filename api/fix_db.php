<?php require "db_connect.php"; try { $stmt = $pdo->query("DESCRIBE orders"); print_r($stmt->fetchAll()); } catch(Exception $e) { echo $e->getMessage(); } ?>
