<?php
require_once 'db_connect.php';

header('Content-Type: application/json');

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $userId = isset($_GET['user_id']) ? intval($_GET['user_id']) : 0;
    if ($userId <= 0) {
        echo json_encode(['success' => false, 'error' => 'Valid user_id required']);
        exit;
    }

    try {
        $stmt = $pdo->prepare("SELECT id, name, referral_code, referral_balance, referred_by FROM users WHERE id = ?");
        $stmt->execute([$userId]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$user) {
            echo json_encode(['success' => false, 'error' => 'User not found']);
            exit;
        }

        // If user doesn't have a referral code yet, generate one
        if (empty($user['referral_code'])) {
            $cleanName = strtoupper(preg_replace('/[^A-Za-z0-9]/', '', $user['name']));
            if (strlen($cleanName) < 3) $cleanName = 'USER';
            $prefix = substr($cleanName, 0, 6);
            $code = 'GO' . $prefix . $user['id'];
            $pdo->prepare("UPDATE users SET referral_code = ? WHERE id = ?")->execute([$code, $userId]);
            $user['referral_code'] = $code;
        }

        // Get referrals history
        $refStmt = $pdo->prepare("
            SELECT r.id, r.reward_amount, r.created_at, u.name as referred_name, u.avatar as referred_avatar 
            FROM referrals r 
            JOIN users u ON r.referred_user_id = u.id 
            WHERE r.referrer_id = ? 
            ORDER BY r.created_at DESC
        ");
        $refStmt->execute([$userId]);
        $referrals = $refStmt->fetchAll(PDO::FETCH_ASSOC) ?: [];

        echo json_encode([
            'success' => true,
            'data' => [
                'user_id' => $user['id'],
                'referral_code' => $user['referral_code'],
                'share_link' => 'https://thegrubnextdoor.com/invite?code=' . $user['referral_code'],
                'reward_per_referral' => 10.00,
                'referee_discount' => 10.00,
                'wallet_balance' => floatval($user['referral_balance'] ?? 10.00),
                'total_referred' => count($referrals),
                'referred_by' => $user['referred_by'],
                'history' => $referrals
            ]
        ]);
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'error' => $e->getMessage()]);
    }
    exit;
}

if ($method === 'POST') {
    $raw = file_get_contents('php://input');
    $body = json_decode($raw, true) ?: $_POST;

    $userId = isset($body['user_id']) ? intval($body['user_id']) : 0;
    $code = isset($body['code']) ? strtoupper(trim($body['code'])) : '';

    if ($userId <= 0 || empty($code)) {
        echo json_encode(['success' => false, 'error' => 'user_id and referral code are required']);
        exit;
    }

    try {
        // Find referrer by code
        $refStmt = $pdo->prepare("SELECT id, name, referral_balance FROM users WHERE referral_code = ?");
        $refStmt->execute([$code]);
        $referrer = $refStmt->fetch(PDO::FETCH_ASSOC);

        if (!$referrer) {
            echo json_encode(['success' => false, 'error' => 'Invalid referral code. Please check and try again.']);
            exit;
        }

        if (intval($referrer['id']) === $userId) {
            echo json_encode(['success' => false, 'error' => 'You cannot use your own referral code!']);
            exit;
        }

        // Check if user has already claimed a code
        $userStmt = $pdo->prepare("SELECT id, referred_by, referral_balance FROM users WHERE id = ?");
        $userStmt->execute([$userId]);
        $user = $userStmt->fetch(PDO::FETCH_ASSOC);

        if (!empty($user['referred_by'])) {
            echo json_encode(['success' => false, 'error' => 'You have already claimed a referral bonus (' . $user['referred_by'] . ').']);
            exit;
        }

        // Apply $10 to both
        $pdo->beginTransaction();

        // Update referee
        $pdo->prepare("UPDATE users SET referred_by = ?, referral_balance = referral_balance + 10.00 WHERE id = ?")->execute([$code, $userId]);

        // Update referrer
        $pdo->prepare("UPDATE users SET referral_balance = referral_balance + 10.00 WHERE id = ?")->execute([$referrer['id']]);

        // Insert history record
        $pdo->prepare("INSERT INTO referrals (referrer_id, referred_user_id, code_used, reward_amount) VALUES (?, ?, ?, 10.00)")
            ->execute([$referrer['id'], $userId, $code]);

        // Also insert notification for referrer
        $notifMsg = "🎉 Great news! Your neighbor signed up using your code $code. You've earned \$10.00 in GoChef credits!";
        try {
            $pdo->prepare("INSERT INTO notifications (user_id, title, message, type) VALUES (?, 'Referral Reward Received! 🎁', ?, 'referral')")
                ->execute([$referrer['id'], $notifMsg]);
        } catch (Exception $e) {}

        $pdo->commit();

        echo json_encode([
            'success' => true,
            'message' => 'Congratulations! $10.00 referral credit has been added to your GoChef wallet! 🎉',
            'new_balance' => floatval($user['referral_balance'] ?? 0) + 10.00
        ]);
    } catch (Exception $e) {
        if ($pdo->inTransaction()) $pdo->rollBack();
        echo json_encode(['success' => false, 'error' => $e->getMessage()]);
    }
    exit;
}

