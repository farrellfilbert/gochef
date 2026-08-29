<?php
require_once 'db_connect.php';

try { $pdo->exec("ALTER TABLE orders ADD COLUMN avatar VARCHAR(500) DEFAULT ''"); } catch(Exception $e) { echo $e->getMessage() . "<br>"; }
try { $pdo->exec("ALTER TABLE orders ADD COLUMN order_type VARCHAR(50) DEFAULT 'delivery'"); } catch(Exception $e) { echo $e->getMessage() . "<br>"; }
try { $pdo->exec("ALTER TABLE orders ADD COLUMN dine_in_date VARCHAR(50) NULL"); } catch(Exception $e) { echo $e->getMessage() . "<br>"; }
try { $pdo->exec("ALTER TABLE orders ADD COLUMN dine_in_time VARCHAR(50) NULL"); } catch(Exception $e) { echo $e->getMessage() . "<br>"; }
try { $pdo->exec("ALTER TABLE orders ADD COLUMN discount_amount DECIMAL(10,2) DEFAULT 0.00"); } catch(Exception $e) { echo $e->getMessage() . "<br>"; }
try { $pdo->exec("ALTER TABLE orders ADD COLUMN promo_code VARCHAR(50) NULL"); } catch(Exception $e) { echo $e->getMessage() . "<br>"; }
try { $pdo->exec("ALTER TABLE orders ADD COLUMN delivery_address TEXT NULL"); } catch(Exception $e) { echo $e->getMessage() . "<br>"; }
try { $pdo->exec("ALTER TABLE orders ADD COLUMN notes TEXT NULL"); } catch(Exception $e) { echo $e->getMessage() . "<br>"; }
echo "Done";
?>
