<?php
require_once 'db_connect.php';
require_once 'uber_service.php';

// Ambil order delivery terakhir yang berstatus Active, Preparing, atau Ready
$stmt = $pdo->query("SELECT o.*, u.address AS dropoff_address FROM orders o JOIN users u ON o.user_id = u.id WHERE o.order_type = 'delivery' AND o.status IN ('Active', 'Preparing', 'Ready') ORDER BY o.id DESC LIMIT 1");
$order = $stmt->fetch();

if (!$order) {
    echo "<h1>Tidak ada order delivery aktif yang bisa dipanggilkan Uber.</h1>";
    echo "<p>Silakan buat pesanan delivery baru terlebih dahulu dan selesaikan pembayarannya.</p>";
    exit;
}

$orderId = $order['id'];
echo "<h1>Mencoba memanggil Uber untuk Order #$orderId</h1>";

try {
    // Ambil alamat Kitchen
    $stmt = $pdo->prepare("SELECT location as address FROM kitchens WHERE id = ?");
    $stmt->execute([$order['kitchen_id']]);
    $kitchen = $stmt->fetch();
    
    if (!$kitchen) {
        $stmt = $pdo->prepare("SELECT location as address FROM kitchens WHERE user_id = ?");
        $stmt->execute([$order['kitchen_id']]);
        $kitchen = $stmt->fetch();
    }
    
    $pickupAddressString = $kitchen['address'] ?? 'Jakarta';
    $dropoffAddressString = $order['dropoff_address'] ?? 'Alamat Pelanggan';

    echo "<p>Pickup: $pickupAddressString</p>";
    echo "<p>Dropoff: $dropoffAddressString</p>";

    // Manifest items
    $manifestItems = [
        [
            "name" => "Makanan GoChef Order #$orderId",
            "quantity" => 1,
            "size" => "small"
        ]
    ];

    // Panggil Uber API
    echo "<p>Memanggil Uber Direct API...</p>";
    $deliveryResult = UberService::createDelivery($pickupAddressString, $dropoffAddressString, $manifestItems, $orderId);

    if ($deliveryResult['success']) {
        $uberTrackingId = $deliveryResult['data']['id'] ?? '';
        $trackingUrl = $deliveryResult['data']['tracking_url'] ?? '';

        $updateStmt = $pdo->prepare("UPDATE orders SET status = 'on_the_way', uber_delivery_id = ?, uber_tracking_url = ?, uber_delivery_status = 'processing' WHERE id = ?");
        $updateStmt->execute([$uberTrackingId, $trackingUrl, $orderId]);

        echo "<h2 style='color:green;'>BERHASIL!</h2>";
        echo "<p>Uber Tracking URL: <a href='$trackingUrl' target='_blank'>$trackingUrl</a></p>";
        echo "<p>Silakan buka aplikasi dan cek halaman Order Tracking. Anda sekarang akan melihat tombol <strong>Live Track</strong>!</p>";
    } else {
        echo "<h2 style='color:red;'>GAGAL!</h2>";
        echo "<pre>" . print_r($deliveryResult['error'], true) . "</pre>";
    }
} catch (Exception $e) {
    echo "<h2 style='color:red;'>ERROR!</h2>";
    echo "<p>" . $e->getMessage() . "</p>";
}
?>
