<?php
// api/config.php
// Konfigurasi Kredensial Stripe & Uber Direct

// ==========================================
// KREDENSIAL STRIPE (TEST MODE)
// ==========================================
define('STRIPE_SECRET_KEY', 'sk_test_..._isi_disini');
define('STRIPE_PUBLISHABLE_KEY', 'pk_test_..._isi_disini');
define('STRIPE_WEBHOOK_SECRET', 'whsec_..._isi_disini'); // Diperlukan nanti saat setup webhook

// ==========================================
// KREDENSIAL UBER DIRECT (TEST MODE)
// ==========================================
define('UBER_CUSTOMER_ID', 'ddf74731-c0ad-5a6a-a899-62f9ee9ee393');
define('UBER_CLIENT_ID', 'jmjGCSlzbifIXAHT-DihFnCvQmJar4aB');
define('UBER_CLIENT_SECRET', 'wOOGgjwxDnGto7TkYg_YApqBE3vLvUwLUqJIFpKt');

// Set ke true untuk menggunakan Sandbox/Test Mode, false untuk Production
define('IS_TEST_MODE', true);

// ==========================================
// KONFIGURASI PLATFORM GO CHEF
// ==========================================
// Komisi yang diambil platform Go Chef dari total makanan (misal: 0.20 untuk 20%)
define('PLATFORM_FEE_PERCENTAGE', 0.20);
?>
