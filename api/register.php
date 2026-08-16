<?php
// register.php - GoChef Register API



header('Content-Type: application/json');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit();
}

$input = json_decode(file_get_contents('php://input'), true);
if (!$input) {
    $input = $_POST;
}

$name = $input['name'] ?? '';
$email = $input['email'] ?? '';
$password = $input['password'] ?? '';
$phone = $input['phone'] ?? '';
$role = $input['role'] ?? 'user';
$kitchen_name = $input['kitchen_name'] ?? '';
$kitchen_description = $input['kitchen_description'] ?? 'A new kitchen on GoChef';
$kitchen_avatar = $input['kitchen_avatar'] ?? '';
$kitchen_cover = $input['kitchen_cover'] ?? '';
$avatar = $input['avatar'] ?? '';

if (empty($name) || empty($email) || empty($password)) {
    http_response_code(400);
    echo json_encode(['error' => 'Name, email, and password are required']);
    exit();
}

if (strlen($password) < 6) {
    http_response_code(400);
    echo json_encode(['error' => 'Password must be at least 6 characters']);
    exit();
}

if ($role === 'chef' && empty($kitchen_name)) {
    http_response_code(400);
    echo json_encode(['error' => 'Kitchen name is required for chefs']);
    exit();
}

require_once 'db_connect.php';

try {
    
    // Check if email already exists
    $stmt = $pdo->prepare("SELECT id FROM users WHERE email = ? LIMIT 1");
    $stmt->execute([$email]);
    if ($stmt->fetch()) {
        http_response_code(409); // Conflict
        echo json_encode(['success' => false, 'error' => 'Email is already registered']);
        exit();
    }
    
    // Hash password
    $hashed_password = password_hash($password, PASSWORD_DEFAULT);
    
    // If chef registration, initial role is 'user' until approved by admin
    $initial_role = ($role === 'chef') ? 'user' : $role;

    // Insert new user
    $insert = $pdo->prepare("INSERT INTO users (name, email, password, phone, role, avatar) VALUES (?, ?, ?, ?, ?, ?)");
    $insert->execute([$name, $email, $hashed_password, $phone, $initial_role, $avatar]);
    
    $user_id = $pdo->lastInsertId();
    $kitchen_id = null;

    if ($role === 'chef') {
        // Kitchen is created with is_verified = 0 (Pending Admin Approval)
        $insert_kitchen = $pdo->prepare("INSERT INTO kitchens (user_id, name, description, avatar, cover_image, is_verified) VALUES (?, ?, ?, ?, ?, 0)");
        $insert_kitchen->execute([$user_id, $kitchen_name, $kitchen_description, $kitchen_avatar, $kitchen_cover]);
        $kitchen_id = $pdo->lastInsertId();

        // Notify admins about new chef application
        try {
            $adminStmt = $pdo->prepare("INSERT INTO notifications (user_id, title, message, type, is_read, created_at) SELECT id, 'New Chef Application', ?, 'chef_application', 0, NOW() FROM users WHERE role = 'admin'");
            $adminStmt->execute(["Applicant: $name ($kitchen_name) has registered and is waiting for your verification."]);
        } catch (Exception $ne) {
            // Ignore notification failure
        }
    }
    
    echo json_encode([
        'success' => true,
        'pending_approval' => ($role === 'chef'),
        'message' => ($role === 'chef') 
            ? 'Chef application submitted! Your kitchen is under review by admin.' 
            : 'Registration successful',
        'user' => [
            'id' => $user_id,
            'name' => $name,
            'email' => $email,
            'role' => $initial_role,
            'kitchen_id' => $kitchen_id,
            'is_verified' => 0
        ]
    ]);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Database connection failed', 'details' => $e->getMessage()]);
}
?>
