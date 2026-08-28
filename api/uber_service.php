<?php
// api/uber_service.php
require_once 'config.php';

class UberService {
    
    // Fungsi untuk mendapatkan token akses Uber
    public static function getAccessToken() {
        // Cek apakah token masih ada di file sementara atau cache (untuk efisiensi, abaikan untuk versi sederhana)
        // Disarankan memakai mekanisme cache token, namun untuk awal kita panggil langsung.
        
        $url = 'https://auth.uber.com/oauth/v2/token';
        $postData = http_build_query([
            'client_id' => UBER_CLIENT_ID,
            'client_secret' => UBER_CLIENT_SECRET,
            'grant_type' => 'client_credentials',
            'scope' => 'eats.deliveries'
        ]);

        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $postData);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Content-Type: application/x-www-form-urlencoded'
        ]);

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if ($httpCode == 200) {
            $data = json_decode($response, true);
            return $data['access_token'] ?? null;
        }
        
        return null;
    }

    // Fungsi untuk meminta estimasi harga kurir (Delivery Quote)
    public static function getDeliveryQuote($pickupAddress, $dropoffAddress) {
        $token = self::getAccessToken();
        if (!$token) {
            return ['success' => false, 'error' => 'Gagal mendapatkan token Uber. Cek kredensial Anda.'];
        }

        $url = "https://api.uber.com/v1/customers/" . UBER_CUSTOMER_ID . "/delivery_quotes";
        
        // Payload Sesuai Standar Uber Direct
        $payload = [
            'pickup_address' => $pickupAddress,
            'dropoff_address' => $dropoffAddress
        ];

        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Authorization: Bearer ' . $token,
            'Content-Type: application/json'
        ]);

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        $data = json_decode($response, true);

        if ($httpCode >= 200 && $httpCode < 300) {
            return ['success' => true, 'data' => $data];
        } else {
            return ['success' => false, 'error' => $data['message'] ?? 'Gagal mendapatkan quote dari Uber.'];
        }
    }

    // Fungsi untuk meminta kurir Uber (Create Delivery)
    public static function createDelivery($pickupAddress, $dropoffAddress, $manifestItems, $orderId) {
        $token = self::getAccessToken();
        if (!$token) {
            return ['success' => false, 'error' => 'Gagal mendapatkan token Uber.'];
        }

        $url = "https://api.uber.com/v1/customers/" . UBER_CUSTOMER_ID . "/deliveries";
        
        $payload = [
            'pickup_address' => $pickupAddress,
            'dropoff_address' => $dropoffAddress,
            'manifest_items' => $manifestItems,
            'external_store_id' => 'gochef_kitchen', // Opsional, bisa disesuaikan
            'deliverable_action' => 'deliverable_action_meet_at_door',
        ];

        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Authorization: Bearer ' . $token,
            'Content-Type: application/json'
        ]);

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        $data = json_decode($response, true);

        if ($httpCode >= 200 && $httpCode < 300) {
            return ['success' => true, 'data' => $data];
        } else {
            return ['success' => false, 'error' => $data['message'] ?? 'Gagal memanggil kurir Uber.'];
        }
    }
}
?>
