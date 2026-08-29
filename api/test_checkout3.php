<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

$_SERVER['REQUEST_METHOD'] = 'POST';
$input = '{"user_id": 1, "kitchen_id": 1, "order_type": "delivery", "dine_in_date": "2026-08-30", "dine_in_time": "12:00", "promo_code": "", "delivery_fee": 4.0}';

function custom_file_get_contents($filename) {
    global $input;
    if ($filename === 'php://input') return $input;
    return file_get_contents($filename);
}

// Mock $_SERVER and file_get_contents
$content = file_get_contents('create_stripe_checkout.php');
$content = str_replace("file_get_contents('php://input')", "custom_file_get_contents('php://input')", $content);
eval('?>' . $content);
?>
