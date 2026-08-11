<?php require "db_connect.php"; try { $stmt = $pdo->query("SELECT * FROM kitchens WHERE user_id = 9"); print_r($stmt->fetchAll()); } catch(Exception $e) { echo $e->getMessage(); } ?>
