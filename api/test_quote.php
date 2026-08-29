<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require_once 'uber_service.php';

$quoteResult = UberService::getDeliveryQuote('555 California St, San Francisco, CA 94104', '1 Market St, San Francisco, CA 94105');

echo json_encode($quoteResult);
?>
