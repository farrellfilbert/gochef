<?php require "db_connect.php"; try { $pdo->exec("ALTER TABLE orders ADD COLUMN kitchen_id INT NULL"); echo "Added."; } catch(Exception $e) { echo $e->getMessage(); } ?>
