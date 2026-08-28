<?php
require_once 'db_connect.php';
require_once 'uber_service.php';

$stmt = $pdo->query("SELECT k.id, k.name, k.location as address, u.phone, k.latitude, k.longitude FROM kitchens k LEFT JOIN users u ON k.user_id = u.id LIMIT 1");
$kitchen = $stmt->fetch();

if (!$kitchen) {
    echo "Kitchen not found\n";
    exit;
}

$pickupAddressString = $kitchen['address']; 
$customerAddressStr = "Jakarta";

echo "Pickup: $pickupAddressString\n";
echo "Dropoff: $customerAddressStr\n";

$quoteResult = UberService::getDeliveryQuote($pickupAddressString, $customerAddressStr);
print_r($quoteResult);
?>
