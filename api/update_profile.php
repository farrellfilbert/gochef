<?php
require_once 'db_connect.php';

header('Content-Type: application/json');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

try {
    $user_id = $_POST['user_id'] ?? null;
    if (!$user_id) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'user_id is required']);
        exit();
    }
    
    $name = $_POST['name'] ?? null;
    $phone = $_POST['phone'] ?? null;
    $avatarUrl = null;
    
    if (isset($_FILES['avatar'])) {
        if ($_FILES['avatar']['error'] === UPLOAD_ERR_OK) {
            $uploadDir = '../avatars/';
            if (!is_dir($uploadDir)) {
                mkdir($uploadDir, 0777, true);
            }
            
            $tmpName = $_FILES['avatar']['tmp_name'];
            $fileName = time() . '_' . basename($_FILES['avatar']['name']);
            $targetPath = $uploadDir . $fileName;
            
            if (move_uploaded_file($tmpName, $targetPath)) {
                $host = $_SERVER['HTTP_HOST'] ?? 'thegrubnextdoor.com';
                $scheme = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on') ? 'https' : 'http';
                $avatarUrl = "$scheme://$host/avatars/" . $fileName;
            } else {
                http_response_code(500);
                echo json_encode(['success' => false, 'error' => 'Failed to move uploaded file.']);
                exit();
            }
        } else {
            http_response_code(400);
            echo json_encode(['success' => false, 'error' => 'Upload failed with error code: ' . $_FILES['avatar']['error']]);
            exit();
        }
    }
    
    $updates = [];
    $params = [];
    
    if ($name !== null && trim($name) !== '') {
        $updates[] = 'name = ?';
        $params[] = trim($name);
    }
    if ($phone !== null) {
        $updates[] = 'phone = ?';
        $params[] = trim($phone);
    }
    if ($avatarUrl !== null) {
        $updates[] = 'avatar = ?';
        $params[] = $avatarUrl;
    }
    
    if (empty($updates)) {
        echo json_encode(['success' => true, 'message' => 'No changes made']);
        exit();
    }
    
    $params[] = $user_id;
    $sql = "UPDATE users SET " . implode(', ', $updates) . " WHERE id = ?";
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    
    $stmt = $pdo->prepare("SELECT id, name, email, phone, avatar, role FROM users WHERE id = ? LIMIT 1");
    $stmt->execute([$user_id]);
    $updatedUser = $stmt->fetch(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'message' => 'Profile updated successfully',
        'data' => $updatedUser
    ]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Database error: ' . $e->getMessage()]);
}
?>
