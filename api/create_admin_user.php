<?php
// create_admin_user.php
header('Content-Type: application/json');
require_once 'db_connect.php';

try {
    $email = 'JonathonPrince@gmail.com';
    $password = 'TheGrubNextDoor2026!';
    $name = 'Jonathon Prince';
    $hashedPassword = password_hash($password, PASSWORD_DEFAULT);

    // Check if user exists
    $stmt = $pdo->prepare("SELECT id FROM users WHERE email = ?");
    $stmt->execute([$email]);
    $existing = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($existing) {
        // Update user to admin with new password
        $update = $pdo->prepare("UPDATE users SET name = ?, password = ?, role = 'admin', status = 'active' WHERE id = ?");
        $update->execute([$name, $hashedPassword, $existing['id']]);
        $userId = $existing['id'];
        $action = 'updated';
    } else {
        // Insert new admin user
        $insert = $pdo->prepare("INSERT INTO users (name, email, password, role, status) VALUES (?, ?, ?, 'admin', 'active')");
        $insert->execute([$name, $email, $hashedPassword]);
        $userId = $pdo->lastInsertId();
        $action = 'created';
    }

    echo json_encode([
        'success' => true,
        'action' => $action,
        'user_id' => $userId,
        'email' => $email,
        'role' => 'admin',
        'message' => "Admin user $email successfully $action."
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
