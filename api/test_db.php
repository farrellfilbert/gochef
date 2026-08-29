<?php
$start = microtime(true);
require_once 'db_connect.php';
$end = microtime(true);
echo "DB Connect time: " . ($end - $start) . " seconds";
?>
