<?php
require_once 'config.php';

$client_ids = [
    'jmjGCSlzbifIXAHT-DihFnCvQmJar4aB',
    'jmjGCSlzbiflXAHT-DihFnCvQmJar4aB',
    'jmjGCSIzbifIXAHT-DihFnCvQmJar4aB',
    'jmjGCSIzbiflXAHT-DihFnCvQmJar4aB'
];

foreach ($client_ids as $cid) {
    $postData = http_build_query([
        'client_id' => $cid,
        'client_secret' => UBER_CLIENT_SECRET,
        'grant_type' => 'client_credentials',
        'scope' => 'eats.deliveries'
    ]);

    $ch = curl_init('https://auth.uber.com/oauth/v2/token');
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $postData);
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    echo "ID: $cid | Code: $httpCode | Resp: $response\n";
}
?>
