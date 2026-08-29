<?php
require_once 'db_connect.php';
$pdo->exec("INSERT INTO cart_items (user_id, menu_item_id, quantity) VALUES (1, 1, 1)");
echo "Cart item inserted.";
?>
