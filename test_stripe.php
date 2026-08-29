<?php
require_once 'api/config.php';

$domain_url = 'https://thegrubnextdoor.com/#';
$orderId = 'ORD-2026-1234';

$stripe_data = [
    'payment_method_types' => ['card'],
    'mode' => 'payment',
    'success_url' => $domain_url . '/payment_success?session_id={CHECKOUT_SESSION_ID}',
    'cancel_url' => $domain_url . '/checkout?canceled=true',
    'client_reference_id' => $orderId,
];

$line_items = [
    [
        'price_data' => [
            'currency' => 'usd',
            'product_data' => [
                'name' => 'Nasi Goreng',
            ],
            'unit_amount' => 1500,
        ],
        'quantity' => 2,
    ]
];

$postData = "";
$postData .= "payment_method_types[0]=card&";
$postData .= "mode=payment&";
$postData .= "success_url=" . urlencode($stripe_data['success_url']) . "&";
$postData .= "cancel_url=" . urlencode($stripe_data['cancel_url']) . "&";
$postData .= "client_reference_id=" . urlencode($orderId) . "&";

foreach ($line_items as $i => $item) {
    $postData .= "line_items[$i][price_data][currency]=" . $item['price_data']['currency'] . "&";
    $postData .= "line_items[$i][price_data][unit_amount]=" . $item['price_data']['unit_amount'] . "&";
    $postData .= "line_items[$i][price_data][product_data][name]=" . urlencode($item['price_data']['product_data']['name']) . "&";
    $postData .= "line_items[$i][quantity]=" . $item['quantity'] . "&";
}
$postData = rtrim($postData, '&');

$ch = curl_init('https://api.stripe.com/v1/checkout/sessions');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $postData);
curl_setopt($ch, CURLOPT_USERPWD, STRIPE_SECRET_KEY . ':');

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP: $httpCode\n";
echo "Response: $response\n";
?>
