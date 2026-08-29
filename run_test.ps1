$Body = '{"user_id": 1, "kitchen_id": 1, "order_type": "delivery", "dine_in_date": "2026-08-30", "dine_in_time": "12:00", "promo_code": "", "delivery_fee": 4.0}'
$response = Invoke-WebRequest -Uri "https://thegrubnextdoor.com/api/create_stripe_checkout.php" -Method Post -Body $Body -ContentType "application/json"
$response.Content
