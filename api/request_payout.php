<?php
// request_payout.php - Handles Chef Payout & Withdrawal Requests
require_once 'db_connect.php';

try {
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS payout_requests (
            id INT AUTO_INCREMENT PRIMARY KEY,
            kitchen_id INT NOT NULL,
            amount DECIMAL(10,2) NOT NULL,
            bank_name VARCHAR(100) DEFAULT '',
            account_number VARCHAR(100) DEFAULT '',
            account_holder VARCHAR(100) DEFAULT '',
            status VARCHAR(30) DEFAULT 'queued',
            reference_code VARCHAR(50) DEFAULT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ");
} catch (Exception $e) {}

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $kitchen_id = isset($_GET['kitchen_id']) ? intval($_GET['kitchen_id']) : 0;
    
    if ($kitchen_id > 0) {
        $stmt = $pdo->prepare("SELECT * FROM payout_requests WHERE kitchen_id = ? ORDER BY id DESC LIMIT 20");
        $stmt->execute([$kitchen_id]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    } else {
        $stmt = $pdo->query("
            SELECT pr.*, k.name as kitchen_name, u.name as chef_name, u.email as chef_email
            FROM payout_requests pr
            JOIN kitchens k ON pr.kitchen_id = k.id
            LEFT JOIN users u ON k.user_id = u.id
            ORDER BY pr.id DESC
        ");
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    echo json_encode(['success' => true, 'data' => $rows]);
    exit;
}

if ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    if (!$input) $input = $_POST;

    $kitchen_id = intval($input['kitchen_id'] ?? 0);
    $amount = floatval($input['amount'] ?? 0.0);
    $bank_name = trim($input['bank_name'] ?? 'Direct Deposit');
    $account_number = trim($input['account_number'] ?? '');
    $account_holder = trim($input['account_holder'] ?? '');

    if (!$kitchen_id || $amount <= 0) {
        echo json_encode(['success' => false, 'error' => 'Valid kitchen_id and positive amount are required']);
        exit;
    }

    $ref = 'PAY-' . date('ymd') . '-' . strtoupper(substr(uniqid(), -5));

    try {
        $stmt = $pdo->prepare("
            INSERT INTO payout_requests (kitchen_id, amount, bank_name, account_number, account_holder, status, reference_code)
            VALUES (?, ?, ?, ?, ?, 'queued', ?)
        ");
        $stmt->execute([$kitchen_id, $amount, $bank_name, $account_number, $account_holder, $ref]);

        // Send confirmation notification to chef
        $uStmt = $pdo->prepare("SELECT user_id, name FROM kitchens WHERE id = ?");
        $uStmt->execute([$kitchen_id]);
        $kRow = $uStmt->fetch(PDO::FETCH_ASSOC);
        if ($kRow && $kRow['user_id']) {
            try {
                $notif = $pdo->prepare("INSERT INTO notifications (user_id, title, message, type, is_read) VALUES (?, ?, ?, 'payout_submitted', 0)");
                $notif->execute([
                    $kRow['user_id'],
                    "Withdrawal Request Submitted! 💸",
                    "Your withdrawal of $" . number_format($amount, 2) . " has been queued (Ref: $ref). Funds typically arrive in 1-3 business days."
                ]);
            } catch (Exception $ne) {}
        }

        echo json_encode([
            'success' => true,
            'message' => 'Withdrawal request submitted successfully',
            'reference_code' => $ref,
            'amount' => $amount
        ]);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['success' => false, 'error' => $e->getMessage()]);
    }
}
?>

