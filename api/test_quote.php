<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require_once 'uber_service.php';

$pickup = json_encode([
    "street_address" => ["555 California St"],
    "city" => "San Francisco",
    "state" => "CA",
    "zip_code" => "94104",
    "country" => "US"
]);

$dropoff = json_encode([
    "street_address" => ["1 Market St"],
    "city" => "San Francisco",
    "state" => "CA",
    "zip_code" => "94105",
    "country" => "US"
]);

$quoteResult = UberService::getDeliveryQuote($pickup, $dropoff);

echo json_encode($quoteResult);
?>
