<?php
// api/get_delivery_quote.php
require_once 'db_connect.php';
require_once 'uber_service.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Method not allowed']);
    exit;
}

$input = json_decode(file_get_contents('php://input'), true);
$kitchenId = $input['kitchen_id'] ?? null;
$customerAddressStr = $input['dropoff_address'] ?? null;
$customerLat = $input['dropoff_lat'] ?? null;
$customerLng = $input['dropoff_lng'] ?? null;

if (!$kitchenId || empty($customerAddressStr)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Parameter tidak lengkap (kitchen_id, dropoff_address)']);
    exit;
}

try {
    // 1. Ambil data dapur dari database
    // Sesuaikan query dengan struktur tabel Anda, misalnya tabel kitchens atau users
    $stmt = $pdo->prepare("SELECT k.name, k.location as address, u.phone, k.latitude, k.longitude FROM kitchens k LEFT JOIN users u ON k.user_id = u.id WHERE k.id = ?");
    $stmt->execute([$kitchenId]);
    $kitchen = $stmt->fetch();
    
    if (!$kitchen) {
        // Fallback jika id ternyata user_id dari chef
        $stmt = $pdo->prepare("SELECT name, location as address, latitude, longitude FROM kitchens WHERE user_id = ?");
        $stmt->execute([$kitchenId]);
        $kitchen = $stmt->fetch();
    }

    if (!$kitchen) {
        http_response_code(404);
        echo json_encode(['success' => false, 'error' => 'Data dapur tidak ditemukan']);
        exit;
    }

    // 2. Format Alamat Pickup (Dapur)
    // Walau ada string address, Uber merekomendasikan mengirim titik latitude longitude juga agar lebih akurat
    $pickup = [
        "store_id" => "gochef_kitchen_" . $kitchenId,
        "street_address" => json_encode([$kitchen['address']]),
        "city" => "",
        "state" => "",
        "zip_code" => "",
        "country" => "ID"
        // Catatan: Payload spesifik Uber Direct untuk Indonesia seringkali butuh lat/lng di struktur terpisah,
        // namun untuk Get Quote simpel kita bisa mengirimkan string address utuh. Nanti disesuaikan format JSON aslinya.
    ];
    
    // Perbaikan Payload yang benar untuk Uber (string alamat utuh)
    $pickupAddressString = $kitchen['address']; 

    // 3. Panggil API Uber
    $quoteResult = UberService::getDeliveryQuote($pickupAddressString, $customerAddressStr);

    if ($quoteResult['success']) {
        echo json_encode(['success' => true, 'quote' => $quoteResult['data']]);
    } else {
        http_response_code(500);
        echo json_encode(['success' => false, 'error' => $quoteResult['error']]);
    }

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>
