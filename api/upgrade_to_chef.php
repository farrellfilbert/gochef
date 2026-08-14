<?php



header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$input = json_decode(file_get_contents('php://input'), true);
if (!$input) {
    $input = $_POST;
}

$user_id = $input['user_id'] ?? null;
$kitchen_name = $input['kitchen_name'] ?? '';
$kitchen_description = $input['kitchen_description'] ?? 'A new kitchen on GoChef';
$kitchen_avatar = $input['kitchen_avatar'] ?? '';
$kitchen_cover = $input['kitchen_cover'] ?? '';

if (!$user_id || empty($kitchen_name)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'user_id and kitchen_name are required']);
    exit();
}

require_once 'db_connect.php';

try {
    
    // Check if user exists
    $stmt = $pdo->prepare("SELECT id FROM users WHERE id = ?");
    $stmt->execute([$user_id]);
    if (!$stmt->fetch()) {
        http_response_code(404);
        echo json_encode(['success' => false, 'error' => 'User not found']);
        exit();
    }
    
    // Check if user already has a kitchen
    $stmt = $pdo->prepare("SELECT id FROM kitchens WHERE user_id = ?");
    $stmt->execute([$user_id]);
    if ($stmt->fetch()) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'User already has a kitchen']);
        exit();
    }
    
    // Update role to chef
    $update = $pdo->prepare("UPDATE users SET role = 'chef' WHERE id = ?");
    $update->execute([$user_id]);
    
    // Create kitchen
    $insert_kitchen = $pdo->prepare("INSERT INTO kitchens (user_id, name, description, avatar, cover_image) VALUES (?, ?, ?, ?, ?)");
    $insert_kitchen->execute([$user_id, $kitchen_name, $kitchen_description, $kitchen_avatar, $kitchen_cover]);
    $kitchen_id = $pdo->lastInsertId();
    
    echo json_encode([
        'success' => true,
        'message' => 'Successfully upgraded to Chef',
        'kitchen_id' => $kitchen_id
    ]);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Database connection failed', 'details' => $e->getMessage()]);
}
?>
