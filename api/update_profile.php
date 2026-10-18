<?php
require_once 'db_connect.php';

header('Content-Type: application/json');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

try {
    $rawInput = file_get_contents('php://input');
    $jsonData = json_decode($rawInput, true) ?? [];

    $user_id = $_POST['user_id'] ?? $jsonData['user_id'] ?? null;
    if (!$user_id) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'user_id is required']);
        exit();
    }
    
    $name = $_POST['name'] ?? $jsonData['name'] ?? null;
    $phone = $_POST['phone'] ?? $jsonData['phone'] ?? null;
    $avatarUrl = null;

    $uploadDir = __DIR__ . '/../uploads/';
    if (!is_dir($uploadDir)) {
        @mkdir($uploadDir, 0777, true);
    }
    $host = $_SERVER['HTTP_HOST'] ?? 'thegrubnextdoor.com';
    $scheme = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on') ? 'https' : 'http';

    // 1. Multipart file upload
    if (isset($_FILES['avatar']) && $_FILES['avatar']['error'] === UPLOAD_ERR_OK) {
        $tmpName = $_FILES['avatar']['tmp_name'];
        $cleanExt = pathinfo($_FILES['avatar']['name'], PATHINFO_EXTENSION);
        if (empty($cleanExt)) $cleanExt = 'jpg';
        $fileName = 'avatar_' . $user_id . '_' . time() . '.' . $cleanExt;
        $targetPath = $uploadDir . $fileName;
        
        if (move_uploaded_file($tmpName, $targetPath)) {
            $avatarUrl = "$scheme://$host/uploads/" . $fileName;
        } else {
            // Fallback to copy if move_uploaded_file fails
            if (copy($tmpName, $targetPath)) {
                $avatarUrl = "$scheme://$host/uploads/" . $fileName;
            }
        }
    }

    // 2. Base64 avatar upload
    $base64Input = $_POST['avatar_base64'] ?? $jsonData['avatar_base64'] ?? null;
    if (!$avatarUrl && !empty($base64Input)) {
        if (preg_match('/^data:image\/(\w+);base64,/', $base64Input, $type)) {
            $base64Input = substr($base64Input, strpos($base64Input, ',') + 1);
            $ext = strtolower($type[1]);
            if ($ext === 'jpeg') $ext = 'jpg';
        } else {
            $ext = 'jpg';
        }
        $decoded = base64_decode($base64Input);
        if ($decoded !== false) {
            $fileName = 'avatar_' . $user_id . '_' . time() . '.' . $ext;
            $targetPath = $uploadDir . $fileName;
            if (file_put_contents($targetPath, $decoded)) {
                $avatarUrl = "$scheme://$host/uploads/" . $fileName;
            }
        }
    }

    // 3. Direct URL avatar provided
    $directUrl = $_POST['avatar_url'] ?? $jsonData['avatar_url'] ?? null;
    if (!$avatarUrl && !empty($directUrl) && filter_var($directUrl, FILTER_VALIDATE_URL)) {
        $avatarUrl = trim($directUrl);
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
