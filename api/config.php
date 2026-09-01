<?php
// api/config.php
// Konfigurasi Kredensial Stripe & Uber Direct

// ==========================================
// KREDENSIAL STRIPE (TEST MODE)
// ==========================================
define('STRIPE_SECRET_KEY', 'sk_test_51U9P2v8YXAY4tUXHave0VcTpWmwNN9KrjY6bqPR84j2eaAs8HemvfpLiBfMjGGEeTnLHc7PFwIj5PJL4FWYLNmxf00VC3wGGOR');
define('STRIPE_PUBLISHABLE_KEY', 'pk_test_51U9P2v8YXAY4tUXHxughm2BURbxwjvVFQOdb3LUemEumaUSgVUIXCO17NgHDkVB1GFvfFnrUQSP3jmakGGZ1BiQR00Em9eGPCt');
define('STRIPE_WEBHOOK_SECRET', 'whsec_..._isi_disini'); // Diperlukan nanti saat setup webhook

// ==========================================
// KREDENSIAL UBER DIRECT (TEST MODE)
// ==========================================
define('UBER_CUSTOMER_ID', 'ddf74731-c0ad-5a6a-a899-62f9ee9ee393');
define('UBER_CLIENT_ID', 'jmjGCSIzbifIXAHT-DihFnCvQmJar4aB');
define('UBER_CLIENT_SECRET', 'wO0GgjwxDnGto7TkYg_YApqBE3vLvUwLUqJlFpKt');

// Set ke true untuk menggunakan Sandbox/Test Mode, false untuk Production
define('IS_TEST_MODE', true);

// ==========================================
// KONFIGURASI PLATFORM GO CHEF
// ==========================================
// Komisi yang diambil platform Go Chef dari total makanan (misal: 0.20 untuk 20%)
define('PLATFORM_FEE_PERCENTAGE', 0.20);
?>
