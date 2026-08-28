<?php
require_once 'config.php';

$url = 'https://auth.uber.com/oauth/v2/token';
$postData = http_build_query([
    'client_id' => UBER_CLIENT_ID,
    'client_secret' => UBER_CLIENT_SECRET,
    'grant_type' => 'client_credentials',
    'scope' => 'eats.deliveries'
]);

$ch = curl_init($url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $postData);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/x-www-form-urlencoded'
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Code: $httpCode\n";
echo "Response: $response\n";
?>
