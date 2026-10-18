<?php
// get_support_admin.php - Returns the dedicated official support contact for Live Chat
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit(0);
}

require_once 'db_connect.php';

try {
    // 1. Check for dedicated support account
    $stmt = $pdo->prepare("SELECT id, name, email, phone, avatar, role FROM users WHERE email = 'support@thegrubnextdoor.com' OR role = 'support' LIMIT 1");
    $stmt->execute();
    $admin = $stmt->fetch(PDO::FETCH_ASSOC);

    // 2. If not found, automatically create the dedicated Support user account
    if (!$admin) {
        $defaultPass = password_hash('SupportDesk2026!Secure', PASSWORD_DEFAULT);
        $ins = $pdo->prepare("
            INSERT INTO users (name, email, password, phone, role, avatar, status) 
            VALUES (?, ?, ?, ?, 'support', ?, 'active')
        ");
        $ins->execute([
            'GoChef Live Support 🎧',
            'support@thegrubnextdoor.com',
            $defaultPass,
            '+1 (800) 462-4330',
            'https://ui-avatars.com/api/?name=GoChef+Support&background=E53935&color=fff'
        ]);
        $supportId = $pdo->lastInsertId();

        $stmt = $pdo->prepare("SELECT id, name, email, phone, avatar, role FROM users WHERE id = ?");
        $stmt->execute([$supportId]);
        $admin = $stmt->fetch(PDO::FETCH_ASSOC);
    }

    // 3. Migrate any previous support messages incorrectly sent to user 22 or test account to the dedicated support ID
    if ($admin && !empty($admin['id'])) {
        $suppId = intval($admin['id']);
        if ($suppId != 22) {
            $pdo->prepare("
                UPDATE chat_messages 
                SET receiver_id = ? 
                WHERE receiver_id = 22 AND (order_id IS NULL OR order_id = '') AND (kitchen_id IS NULL OR kitchen_id = 0)
                  AND (message LIKE '%support%' OR message LIKE '%menu%' OR message LIKE '%meny%' OR message LIKE '%help%' OR message LIKE '%item%')
            ")->execute([$suppId]);

            $pdo->prepare("
                UPDATE chat_messages 
                SET sender_id = ? 
                WHERE sender_id = 22 AND (order_id IS NULL OR order_id = '') AND (kitchen_id IS NULL OR kitchen_id = 0)
                  AND receiver_id IN (SELECT id FROM users WHERE role != 'admin' AND role != 'support')
            ")->execute([$suppId]);
        }
    }

    echo json_encode([
        'success' => true,
        'admin' => [
            'id' => intval($admin['id']),
            'name' => 'GoChef Live Support 🎧',
            'email' => 'support@thegrubnextdoor.com',
            'phone' => '+1 (800) 462-4330',
            'avatar' => !empty($admin['avatar']) ? $admin['avatar'] : 'https://ui-avatars.com/api/?name=GoChef+Support&background=E53935&color=fff',
            'is_official' => true,
            'status' => 'Online 24/7'
        ]
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>
