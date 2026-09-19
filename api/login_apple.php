<?php

header('Content-Type: application/json');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$input = json_decode(file_get_contents('php://input'), true);
$apple_id = trim($input['apple_id'] ?? '');
$email = trim($input['email'] ?? '');
$name = trim($input['name'] ?? '');

if (empty($apple_id)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => 'Apple ID is required'
    ]);
    exit();
}

require_once 'db_connect.php';

try {
    // 1. Ensure apple_id column exists in users table
    try {
        $checkCol = $pdo->query("SHOW COLUMNS FROM users LIKE 'apple_id'");
        if ($checkCol->rowCount() === 0) {
            $pdo->exec("ALTER TABLE users ADD COLUMN apple_id VARCHAR(191) DEFAULT NULL UNIQUE AFTER password");
        }
    } catch (Exception $colEx) {
        // Continue if already exists or permission issues
    }

    $user = null;

    // 2. Search user by apple_id first
    $stmt = $pdo->prepare("SELECT * FROM users WHERE apple_id = ? LIMIT 1");
    $stmt->execute([$apple_id]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    // 3. If not found by apple_id, but email is provided, check if user exists by email
    if (!$user && !empty($email)) {
        $stmt = $pdo->prepare("SELECT * FROM users WHERE email = ? LIMIT 1");
        $stmt->execute([$email]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($user) {
            // Link existing account with this apple_id
            $updateStmt = $pdo->prepare("UPDATE users SET apple_id = ? WHERE id = ?");
            $updateStmt->execute([$apple_id, $user['id']]);
            $user['apple_id'] = $apple_id;
        }
    }

    // 4. If still not found, register new user
    if (!$user) {
        $userName = !empty($name) ? $name : 'Apple User';
        // If email is empty (Apple hides email after first login), create a stable placeholder email
        $userEmail = !empty($email) ? $email : ('apple_' . substr(md5($apple_id), 0, 10) . '@privaterelay.apple.com');

        $insertStmt = $pdo->prepare("INSERT INTO users (name, email, apple_id, password, status, role) VALUES (?, ?, ?, '', 'active', 'user')");
        $insertStmt->execute([$userName, $userEmail, $apple_id]);
        $newUserId = $pdo->lastInsertId();

        $stmt = $pdo->prepare("SELECT * FROM users WHERE id = ?");
        $stmt->execute([$newUserId]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
    }

    // 5. Account suspension check
    if ($user) {
        if (isset($user['status']) && $user['status'] === 'suspended') {
            http_response_code(403);
            echo json_encode([
                'success' => false,
                'error' => 'Your account has been suspended. Please contact admin at support@gochef.com'
            ]);
            exit();
        }

        $kCheck = $pdo->prepare("SELECT status FROM kitchens WHERE user_id = ? LIMIT 1");
        $kCheck->execute([$user['id']]);
        $kStatus = $kCheck->fetchColumn();
        if ($kStatus === 'suspended') {
            http_response_code(403);
            echo json_encode([
                'success' => false,
                'error' => 'Your account has been suspended. Please contact admin at support@gochef.com'
            ]);
            exit();
        }
    }

    // Fetch kitchen_id if user is chef or owns kitchen
    $kStmt = $pdo->prepare("SELECT id FROM kitchens WHERE user_id = ? LIMIT 1");
    $kStmt->execute([$user['id']]);
    $kitchenId = $kStmt->fetchColumn();
    if ($kitchenId) {
        $user['kitchen_id'] = $kitchenId;
    }

    unset($user['password']);

    echo json_encode([
        'success' => true,
        'message' => 'Apple login successful',
        'user' => $user,
        'token' => 'dummy_token_' . time()
    ]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Database error: ' . $e->getMessage()
    ]);
}
?>
