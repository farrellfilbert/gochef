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
    
    $stmt = $pdo->prepare("SELECT id, name, email, phone, avatar, role FROM users WHERE id = ? LIMIT 1");
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
        
        echo json_encode([
            'success' => true,
            'data' => [
                'id' => $user['id'],
                'name' => $user['name'],
                'email' => $user['email'],
                'phone' => $user['phone'] ?? '+00 000 0000 0000',
                'avatar' => $avatar,
                'role' => $user['role'],
                'kitchen_id' => $kitchen_id,
                'kitchen_name' => $kitchen_name
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
