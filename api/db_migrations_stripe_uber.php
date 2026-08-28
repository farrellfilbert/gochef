<?php
// api/db_migrations_stripe_uber.php
require_once 'db_connect.php';

header('Content-Type: application/json');

try {
    $pdo->beginTransaction();

    // 1. Tambah kolom ke tabel kitchens (untuk Stripe Connect ID)
    // Cek apakah tabel kitchens ada, atau pakai users (jika chef disimpan di users)
    $stmt = $pdo->query("SHOW TABLES LIKE 'kitchens'");
    $tableExists = $stmt->rowCount() > 0;
    
    if ($tableExists) {
        // Cek kolom stripe_account_id
        $stmt = $pdo->query("SHOW COLUMNS FROM kitchens LIKE 'stripe_account_id'");
        if ($stmt->rowCount() == 0) {
            $pdo->exec("ALTER TABLE kitchens ADD COLUMN stripe_account_id VARCHAR(255) NULL COMMENT 'Stripe Connect Account ID'");
        }
    } else {
        // Asumsi data chef ada di tabel users
        $stmt = $pdo->query("SHOW COLUMNS FROM users LIKE 'stripe_account_id'");
        if ($stmt->rowCount() == 0) {
            $pdo->exec("ALTER TABLE users ADD COLUMN stripe_account_id VARCHAR(255) NULL COMMENT 'Stripe Connect Account ID'");
        }
    }

    // 2. Tambah kolom ke tabel orders
    $columns = [
        'payment_intent_id' => "VARCHAR(255) NULL COMMENT 'Stripe Payment Intent ID'",
        'uber_delivery_id' => "VARCHAR(255) NULL COMMENT 'Uber Delivery/Tracking ID'",
        'uber_tracking_url' => "VARCHAR(255) NULL COMMENT 'Uber Live Tracking URL'",
        'uber_delivery_status' => "VARCHAR(50) NULL COMMENT 'Status dari Uber Webhook'",
        'delivery_fee' => "DECIMAL(10,2) NULL COMMENT 'Ongkos kirim aktual dari Uber'"
    ];

    foreach ($columns as $colName => $colDef) {
        $stmt = $pdo->query("SHOW COLUMNS FROM orders LIKE '$colName'");
        if ($stmt->rowCount() == 0) {
            $pdo->exec("ALTER TABLE orders ADD COLUMN $colName $colDef");
        }
    }

    $pdo->commit();
    echo json_encode(['success' => true, 'message' => 'Database successfully migrated for Stripe & Uber integration!']);

} catch (Exception $e) {
    $pdo->rollBack();
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>
