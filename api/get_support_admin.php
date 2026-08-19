<?php
// get_support_admin.php - Returns the official support admin contact for Live Chat
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
    // 1. Try to find a user with role 'admin'
    $stmt = $pdo->prepare("SELECT id, name, email, phone, avatar, role FROM users WHERE role = 'admin' ORDER BY id ASC LIMIT 1");
    $stmt->execute();
    $admin = $stmt->fetch(PDO::FETCH_ASSOC);

    // 2. If no admin role found, find dany or jonathon
    if (!$admin) {
        $stmt2 = $pdo->prepare("SELECT id, name, email, phone, avatar, role FROM users WHERE email IN ('dany.r.tri@gmail.com', 'JonathonPrince@gmail.com') LIMIT 1");
        $stmt2->execute();
        $admin = $stmt2->fetch(PDO::FETCH_ASSOC);
    }

    // 3. If still no admin, fallback to first user
    if (!$admin) {
        $stmt3 = $pdo->query("SELECT id, name, email, phone, avatar, role FROM users ORDER BY id ASC LIMIT 1");
        $admin = $stmt3->fetch(PDO::FETCH_ASSOC);
    }

    if ($admin) {
        echo json_encode([
            'success' => true,
            'admin' => [
                'id' => intval($admin['id']),
                'name' => 'GoChef Live Support 🎧',
                'email' => $admin['email'],
                'phone' => $admin['phone'] ?? '+1 (800) GO-CHEF',
                'avatar' => !empty($admin['avatar']) ? $admin['avatar'] : 'https://ui-avatars.com/api/?name=GoChef+Support&background=E53935&color=fff',
                'is_official' => true,
                'status' => 'Online 24/7'
            ]
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'error' => 'No support agent available'
        ]);
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
