<?php
require_once 'api/config.php';
require_once 'api/uber_service.php';

$res = UberService::createDelivery(
    "1455 Market St, San Francisco, CA 94103, USA",
    "1500 Market St, San Francisco, CA 94103, USA",
    [["name" => "Test Item", "quantity" => 1, "size" => "small"]],
    "TEST-123"
);

print_r($res);
?>
