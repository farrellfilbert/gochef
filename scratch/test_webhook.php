<?php
$url = "https://thegrubnextdoor.com/api/uber_webhook.php";
$data = [
    "event_type" => "dapi.status_changed",
    "meta" => [
        "resource_id" => "test_delivery_123",
        "status" => "pickup"
    ]
];
$options = [
    'http' => [
        'header'  => "Content-type: application/json\r\n",
        'method'  => 'POST',
        'content' => json_encode($data)
    ]
];
$context  = stream_context_create($options);
$result = file_get_contents($url, false, $context);
if ($result === FALSE) {
    echo "Error calling webhook";
} else {
    echo "Success: " . $result;
}
?>
