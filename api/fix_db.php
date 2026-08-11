<?php require "db_connect.php"; try { $stmt = $pdo->query("SELECT * FROM kitchens WHERE id = 7"); print_r($stmt->fetchAll()); } catch(Exception $e) { echo $e->getMessage(); } ?>
