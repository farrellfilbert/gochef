<?php
// register.php - GoChef Register API
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
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

// Database Connection
$db_host = 'localhost';
$db_user = 'astroboomin_id_rsa';
$db_pass = 'Astroboomin2026!';
$db_name = 'astroboomin_gochef';

try {
    $pdo = new PDO("mysql:host=$db_host;dbname=$db_name;charset=utf8mb4", $db_user, $db_pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
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
    
    // Insert new user
    $insert = $pdo->prepare("INSERT INTO users (name, email, password, phone, role) VALUES (?, ?, ?, ?, ?)");
    $insert->execute([$name, $email, $hashed_password, $phone, $role]);
    
    $user_id = $pdo->lastInsertId();
    $kitchen_id = null;

    if ($role === 'chef') {
        $insert_kitchen = $pdo->prepare("INSERT INTO kitchens (user_id, name, description, avatar, cover_image) VALUES (?, ?, ?, ?, ?)");
        $insert_kitchen->execute([$user_id, $kitchen_name, $kitchen_description, $kitchen_avatar, $kitchen_cover]);
        $kitchen_id = $pdo->lastInsertId();
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'Registration successful',
        'user' => [
            'id' => $user_id,
            'name' => $name,
            'email' => $email,
            'role' => $role,
            'kitchen_id' => $kitchen_id
        ]
    ]);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Database connection failed']);
}
?>
