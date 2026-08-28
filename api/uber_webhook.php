<?php
// api/uber_webhook.php
// File ini akan dipanggil otomatis oleh Uber Direct saat ada perubahan status kurir
require_once 'db_connect.php';
require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    exit;
}

$payload = file_get_contents('php://input');
$data = json_decode($payload, true);

if (!$data) {
    http_response_code(400);
    exit;
}

// Untuk keamanan tambahan, di masa depan Anda bisa memverifikasi signature Uber di Header.
// $signature = $_SERVER['HTTP_X_UBER_SIGNATURE'] ?? '';

// Format data yang dikirim Uber:
// {
//   "event_id": "...",
//   "event_time": 15000000,
//   "event_type": "dapi.status_changed",
//   "meta": {
//     "resource_id": "uber_delivery_id_123",
//     "status": "pickup"
//   }
// }

$eventType = $data['event_type'] ?? '';
$deliveryId = $data['meta']['resource_id'] ?? '';
$status = $data['meta']['status'] ?? ''; // pickup, pickup_complete, dropoff, delivered, canceled

if ($eventType === 'dapi.status_changed' && !empty($deliveryId) && !empty($status)) {
    try {
        // Map status Uber ke status aplikasi GoChef
        $appStatus = 'on_the_way';
        if ($status === 'delivered') {
            $appStatus = 'delivered';
        } elseif ($status === 'canceled') {
            $appStatus = 'cancelled';
        }

        // Update database
        $stmt = $pdo->prepare("UPDATE orders SET uber_delivery_status = ?, status = IF(status != 'delivered', ?, status) WHERE uber_delivery_id = ?");
        $stmt->execute([$status, $appStatus, $deliveryId]);
        
        http_response_code(200);
        echo json_encode(['success' => true]);

    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['success' => false, 'error' => $e->getMessage()]);
    }
} else {
    // Abaikan event lain agar tidak error
    http_response_code(200);
}
?>
