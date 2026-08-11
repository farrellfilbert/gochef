<?php require "db_connect.php"; try { $stmt = $pdo->query("SELECT * FROM cart_items WHERE user_id = 9"); print_r($stmt->fetchAll()); } catch(Exception $e) { echo $e->getMessage(); } ?>
