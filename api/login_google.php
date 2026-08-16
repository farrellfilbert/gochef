<?php



header('Content-Type: application/json');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$input = json_decode(file_get_contents('php://input'), true);
$email = $input['email'] ?? '';
$name = $input['name'] ?? '';
$google_id = $input['google_id'] ?? '';

if (empty($email) || empty($google_id)) {
    http_response_code(400);
    echo json_encode(['error' => 'Email and Google ID are required']);
    exit();
}

require_once 'db_connect.php';

try {
    
    $stmt = $pdo->prepare("SELECT * FROM users WHERE email = ? LIMIT 1");
    $stmt->execute([$email]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
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
    } else {
        $stmt = $pdo->prepare("INSERT INTO users (name, email, password, status) VALUES (?, ?, ?, 'active')");
        $stmt->execute([$name, $email, '']);
        $user_id = $pdo->lastInsertId();
        
        $stmt = $pdo->prepare("SELECT * FROM users WHERE id = ?");
        $stmt->execute([$user_id]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
    }
    
    unset($user['password']);
    echo json_encode([
        'success' => true,
        'message' => 'Google login successful',
        'user' => $user,
        'token' => 'dummy_token_' . time()
    ]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Database error']);
}
?>
