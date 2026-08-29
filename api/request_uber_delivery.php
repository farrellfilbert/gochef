<?php
// api/request_uber_delivery.php
require_once 'db_connect.php';
require_once 'uber_service.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Method not allowed']);
    exit;
}

$input = json_decode(file_get_contents('php://input'), true);
$orderId = $input['order_id'] ?? null;

if (!$orderId) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Order ID dibutuhkan']);
    exit;
}

try {
    // 1. Ambil data order dari database (asumsi tabel orders)
    $stmt = $pdo->prepare("SELECT o.*, o.delivery_address AS dropoff_address FROM orders o WHERE o.id = ?");
    $stmt->execute([$orderId]);
    $order = $stmt->fetch();
    
    if (!$order) {
        http_response_code(200);
        echo json_encode(['success' => false, 'error' => 'Order tidak ditemukan']);
        exit;
    }

    if ($order['status'] !== 'preparing' && $order['status'] !== 'ready') {
        echo json_encode(['success' => false, 'error' => 'Status order belum siap untuk dikirim.']);
        exit;
    }

    // 2. Ambil alamat Kitchen
    $stmt = $pdo->prepare("SELECT location as address FROM kitchens WHERE id = ?");
    $stmt->execute([$order['kitchen_id']]);
    $kitchen = $stmt->fetch();
    
    if (!$kitchen) {
        $stmt = $pdo->prepare("SELECT location as address FROM kitchens WHERE user_id = ?");
        $stmt->execute([$order['kitchen_id']]);
        $kitchen = $stmt->fetch();
    }
    
    $pickupAddressString = $kitchen['address'] ?? '';
    $dropoffAddressString = $order['dropoff_address'] ?? 'Alamat Pelanggan';

    // 3. Manifest items (List Makanan) - Opsional dari tabel order_items
    $manifestItems = [
        [
            "name" => "Makanan GoChef Order #$orderId",
            "quantity" => 1,
            "size" => "small"
        ]
    ];

    // 4. Panggil Uber API
    $deliveryResult = UberService::createDelivery($pickupAddressString, $dropoffAddressString, $manifestItems, $orderId);

    if ($deliveryResult['success']) {
        // 5. Update tabel orders dengan ID tracking Uber
        $uberTrackingId = $deliveryResult['data']['id'] ?? ''; // ID delivery dari Uber
        $trackingUrl = $deliveryResult['data']['tracking_url'] ?? '';

        $updateStmt = $pdo->prepare("UPDATE orders SET status = 'on_the_way', uber_delivery_id = ?, uber_tracking_url = ?, uber_delivery_status = 'processing' WHERE id = ?");
        $updateStmt->execute([$uberTrackingId, $trackingUrl, $orderId]);

        echo json_encode([
            'success' => true, 
            'message' => 'Kurir Uber berhasil dipanggil',
            'tracking_url' => $trackingUrl
        ]);
    } else {
        http_response_code(200);
        echo json_encode(['success' => false, 'error' => 'Uber API Error: ' . ($deliveryResult['error'] ?? 'Unknown error')]);
    }

} catch (Exception $e) {
    http_response_code(200);
    echo json_encode(['success' => false, 'error' => 'Server Error: ' . $e->getMessage()]);
}
?>
