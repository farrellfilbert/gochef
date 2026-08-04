<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$db_host = 'localhost';
$db_user = 'astroboomin_id_rsa';
$db_pass = 'Astroboomin2026!';
$db_name = 'astroboomin_gochef';

try {
    $pdo = new PDO("mysql:host=$db_host;dbname=$db_name;charset=utf8mb4", $db_user, $db_pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    $user_id = $_POST['user_id'] ?? null;
    if (!$user_id) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'user_id is required']);
        exit();
    }
    
    $name = $_POST['name'] ?? null;
    $phone = $_POST['phone'] ?? null;
    $avatarUrl = null;
    
    if (isset($_FILES['avatar']) && $_FILES['avatar']['error'] === UPLOAD_ERR_OK) {
        $uploadDir = '../avatars/';
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0755, true);
        }
        
        $tmpName = $_FILES['avatar']['tmp_name'];
        $fileName = time() . '_' . basename($_FILES['avatar']['name']);
        $targetPath = $uploadDir . $fileName;
        
        if (move_uploaded_file($tmpName, $targetPath)) {
            $avatarUrl = 'https://gochef.my.id/avatars/' . $fileName;
        }
    }
    
    $updates = [];
    $params = [];
    
    if ($name !== null) {
        $updates[] = "name = ?";
        $params[] = $name;
    }
    if ($phone !== null) {
        $updates[] = "phone = ?";
        $params[] = $phone;
    }
    if ($avatarUrl !== null) {
        $updates[] = "avatar = ?";
        $params[] = $avatarUrl;
    }
    
    if (count($updates) > 0) {
        $sql = "UPDATE users SET " . implode(", ", $updates) . " WHERE id = ?";
        $params[] = $user_id;
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        
        echo json_encode(['success' => true, 'message' => 'Profile updated']);
    } else {
        echo json_encode(['success' => true, 'message' => 'No changes made']);
    }
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Database error: ' . $e->getMessage()]);
}
?>
