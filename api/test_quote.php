<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require_once 'uber_service.php';

$quoteResult = UberService::getDeliveryQuote('123 Main St, New York, NY 10001', '456 Elm St, New York, NY 10001');

echo json_encode($quoteResult);
?>
