<?php
require_once 'api/uber_service.php';

$quoteResult = UberService::getDeliveryQuote('123 Main St, New York, NY 10001', '456 Elm St, New York, NY 10001');

echo json_encode($quoteResult);
?>
