<?php require 'api/db_connect.php'; try { $pdo->exec('ALTER TABLE users ADD COLUMN avatar VARCHAR(500) DEFAULT '''); echo 'Success'; } catch (Exception $e) { echo $e->getMessage(); } ?>
