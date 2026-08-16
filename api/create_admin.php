<?php
// create_admin.php - Create or update the administrator account
require_once 'db_connect.php';

$admin_email = 'dany.r.tri@gmail.com';
$admin_pass = 'TheGrubNextDoor2026!';
$admin_name = 'Dany (Admin)';
$hashed_password = password_hash($admin_pass, PASSWORD_BCRYPT);
$role = 'admin';
$avatar = 'https://ui-avatars.com/api/?name=Admin+Dany&background=E53935&color=fff';

try {
    // Ensure all existing active kitchens are marked verified
    $pdo->exec("UPDATE kitchens SET is_verified = 1 WHERE is_verified = 0 OR is_verified IS NULL");

    $stmt = $pdo->prepare("SELECT id FROM users WHERE email = ?");
    $stmt->execute([$admin_email]);
    $existing = $stmt->fetch();

    if ($existing) {
        $update = $pdo->prepare("UPDATE users SET name = ?, password = ?, role = 'admin', avatar = ? WHERE id = ?");
        $update->execute([$admin_name, $hashed_password, $avatar, $existing['id']]);
        echo json_encode([
            'success' => true,
            'message' => 'Admin account updated successfully',
            'user_id' => $existing['id'],
            'email' => $admin_email,
            'role' => 'admin'
        ]);
    } else {
        $insert = $pdo->prepare("INSERT INTO users (name, email, password, phone, role, avatar) VALUES (?, ?, ?, ?, ?, ?)");
        $insert->execute([$admin_name, $admin_email, $hashed_password, '+6281234567890', $role, $avatar]);
        $new_id = $pdo->lastInsertId();
        echo json_encode([
            'success' => true,
            'message' => 'Admin account created successfully',
            'user_id' => $new_id,
            'email' => $admin_email,
            'role' => 'admin'
        ]);
    }
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>
