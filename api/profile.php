<?php
require_once 'db_connect.php';

header('Content-Type: application/json');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

try {
    $user_id = $_GET['user_id'] ?? null;
    if (!$user_id) {
        echo json_encode(['success' => false, 'error' => 'user_id is required']);
        exit();
    }
    
    // Ensure notification columns exist
    try {
        $cols = $pdo->query("SHOW COLUMNS FROM users LIKE 'push_notifications'")->fetchAll();
        if (empty($cols)) {
            $pdo->exec("ALTER TABLE users ADD COLUMN push_notifications TINYINT(1) DEFAULT 1");
        }
        $cols = $pdo->query("SHOW COLUMNS FROM users LIKE 'email_notifications'")->fetchAll();
        if (empty($cols)) {
            $pdo->exec("ALTER TABLE users ADD COLUMN email_notifications TINYINT(1) DEFAULT 1");
        }
        $cols = $pdo->query("SHOW COLUMNS FROM users LIKE 'sms_alerts'")->fetchAll();
        if (empty($cols)) {
            $pdo->exec("ALTER TABLE users ADD COLUMN sms_alerts TINYINT(1) DEFAULT 0");
        }
    } catch (Exception $e) {}
    
    $stmt = $pdo->prepare("SELECT id, name, email, phone, avatar, role, push_notifications, email_notifications, sms_alerts FROM users WHERE id = ? LIMIT 1");
    $stmt->execute([$user_id]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($user) {
        $kitchen_id = null;
        $kitchen_name = null;
        $kStmt = $pdo->prepare("SELECT id, name FROM kitchens WHERE user_id = ? LIMIT 1");
        $kStmt->execute([$user['id']]);
        $kitchen = $kStmt->fetch(PDO::FETCH_ASSOC);
        if ($kitchen) {
            $kitchen_id = $kitchen['id'];
            $kitchen_name = $kitchen['name'];
        }
        
        $avatar = $user['avatar'];
        if (empty($avatar)) {
            $avatar = 'https://ui-avatars.com/api/?name=' . urlencode($user['name']);
        }
        $phone = (!empty($user['phone']) && trim($user['phone']) !== '') ? $user['phone'] : '+1 (818) 555-0199';
        
        echo json_encode([
            'success' => true,
            'data' => [
                'id' => $user['id'],
                'name' => $user['name'],
                'email' => $user['email'],
                'phone' => $phone,
                'avatar' => $avatar,
                'role' => $user['role'],
                'kitchen_id' => $kitchen_id,
                'kitchen_name' => $kitchen_name,
                'push_notifications' => isset($user['push_notifications']) ? (int)$user['push_notifications'] : 1,
                'email_notifications' => isset($user['email_notifications']) ? (int)$user['email_notifications'] : 1,
                'sms_alerts' => isset($user['sms_alerts']) ? (int)$user['sms_alerts'] : 0
            ]
        ]);
    } else {
        http_response_code(404);
        echo json_encode(['success' => false, 'error' => 'User not found']);
    }
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Database error: ' . $e->getMessage()]);
}
?>
