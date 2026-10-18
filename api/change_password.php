<?php
require_once 'db_connect.php';

header('Content-Type: application/json');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$rawInput = file_get_contents('php://input');
$input = json_decode($rawInput, true) ?? [];

$userId = $_POST['user_id'] ?? $input['user_id'] ?? null;
$currentPassword = $_POST['current_password'] ?? $input['current_password'] ?? '';
$newPassword = $_POST['new_password'] ?? $input['new_password'] ?? '';

if (!$userId) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'User ID is required.']);
    exit();
}

if (empty($newPassword) || strlen($newPassword) < 6) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'New password must be at least 6 characters.']);
    exit();
}

try {
    $stmt = $pdo->prepare("SELECT id, password, email FROM users WHERE id = ? LIMIT 1");
    $stmt->execute([$userId]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user) {
        http_response_code(404);
        echo json_encode(['success' => false, 'error' => 'User not found.']);
        exit();
    }

    // If user already has a non-empty password set, verify current password
    if (!empty($user['password'])) {
        if (empty($currentPassword)) {
            http_response_code(400);
            echo json_encode(['success' => false, 'error' => 'Current password is required.']);
            exit();
        }

        if (!password_verify($currentPassword, $user['password'])) {
            http_response_code(400);
            echo json_encode(['success' => false, 'error' => 'Current password is incorrect.']);
            exit();
        }
    }

    // Hash and update
    $newHash = password_hash($newPassword, PASSWORD_DEFAULT);
    $upd = $pdo->prepare("UPDATE users SET password = ? WHERE id = ?");
    $upd->execute([$newHash, $userId]);

    echo json_encode([
        'success' => true,
        'message' => 'Password updated successfully.'
    ]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Database error: ' . $e->getMessage()]);
}
?>
