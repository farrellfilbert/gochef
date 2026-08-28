<?php
require_once 'config.php';

$client_ids = [
    'jmjGCSlzbifIXAHT-DihFnCvQmJar4aB',
    'jmjGCSIzbifIXAHT-DihFnCvQmJar4aB',
    'jmjGCSlzbiflXAHT-DihFnCvQmJar4aB',
    'jmjGCSIzbiflXAHT-DihFnCvQmJar4aB',
    'jmjGCS1zbifIXAHT-DihFnCvQmJar4aB',
    'jmjGCSlzbif1XAHT-DihFnCvQmJar4aB'
];

$secrets = [
    'wOOGgjwxDnGto7TkYg_YApqBE3vLvUwLUqJIFpKt',
    'wOOGgjwxDnGto7TkYg_YApqBE3vLvUwLUqJlFpKt',
    'w00GgjwxDnGto7TkYg_YApqBE3vLvUwLUqJIFpKt',
    'w00GgjwxDnGto7TkYg_YApqBE3vLvUwLUqJlFpKt',
    'wO0GgjwxDnGto7TkYg_YApqBE3vLvUwLUqJIFpKt',
    'w0OGgjwxDnGto7TkYg_YApqBE3vLvUwLUqJIFpKt'
];

foreach ($client_ids as $cid) {
    foreach ($secrets as $sec) {
        $postData = http_build_query([
            'client_id' => $cid,
            'client_secret' => $sec,
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
        
        $data = json_decode($response, true);
        if ($httpCode == 200 || !isset($data['error'])) {
            echo "SUCCESS!\nCID: $cid\nSEC: $sec\nResp: $response\n";
            exit; // Found it!
        }
    }
}
echo "All failed.\n";
?>
