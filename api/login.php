<?php
// login.php - GoChef Login API



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

// Get JSON input
$input = json_decode(file_get_contents('php://input'), true);
if (!$input) {
    // Fallback to form data
    $input = $_POST;
}

$email = $input['email'] ?? '';
$password = $input['password'] ?? '';

if (empty($email) || empty($password)) {
    http_response_code(400);
    echo json_encode(['error' => 'Email and password are required']);
    exit();
}

require_once 'db_connect.php';

try {
    
    $stmt = $pdo->prepare("SELECT * FROM users WHERE email = ? LIMIT 1");
    $stmt->execute([$email]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($user) {
        // 1. Check if user account is suspended
        if (isset($user['status']) && $user['status'] === 'suspended') {
            http_response_code(403);
            echo json_encode([
                'success' => false,
                'error' => 'Your account has been suspended. Please contact admin at support@gochef.com'
            ]);
            exit();
        }

        // 2. Check if user's kitchen is suspended
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

        // 3. Verify password
        if (password_verify($password, $user['password'])) {
            // Login successful
            unset($user['password']); // Don't send password hash back
            
            // Fetch kitchen_id and is_verified if they have a kitchen
            $kStmt = $pdo->prepare("SELECT id, is_verified, status FROM kitchens WHERE user_id = ? LIMIT 1");
            $kStmt->execute([$user['id']]);
            $kitchen = $kStmt->fetch(PDO::FETCH_ASSOC);
            if ($kitchen) {
                $user['kitchen_id'] = $kitchen['id'];
                $user['is_verified'] = (int)$kitchen['is_verified'];
                $user['kitchen_status'] = $kitchen['status'] ?? 'active';
            } else {
                $user['is_verified'] = 1;
                $user['kitchen_status'] = 'active';
            }
        
            echo json_encode([
                'success' => true,
                'message' => 'Login successful',
                'user' => $user,
                'token' => 'dummy_token_' . time()
            ]);
            exit();
        } else {
            // Password mismatch
            http_response_code(401);
            echo json_encode([
                'success' => false,
                'error' => 'Invalid email or password'
            ]);
            exit();
        }
    } else {
        // User not found
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'error' => 'Invalid email or password'
        ]);
        exit();
    }
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Database connection failed']);
}
?>
