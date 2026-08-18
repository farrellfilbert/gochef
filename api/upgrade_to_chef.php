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
$location = $input['location'] ?? 'North Hollywood, CA';
$latitude = isset($input['latitude']) ? floatval($input['latitude']) : 34.1722;
$longitude = isset($input['longitude']) ? floatval($input['longitude']) : -118.3765;

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
    
    // Create kitchen with is_verified = 0 (Pending admin approval)
    $insert_kitchen = $pdo->prepare("INSERT INTO kitchens (user_id, name, description, avatar, cover_image, location, latitude, longitude, is_verified) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0)");
    $insert_kitchen->execute([$user_id, $kitchen_name, $kitchen_description, $kitchen_avatar, $kitchen_cover, $location, $latitude, $longitude]);
    $kitchen_id = $pdo->lastInsertId();
    
    // Notify admin
    $notifAdmin = $pdo->prepare("INSERT INTO notifications (user_id, title, message, type, is_read) SELECT id, 'New Chef Application', ?, 'admin_alert', 0 FROM users WHERE role = 'admin'");
    $notifAdmin->execute(["New chef application from $kitchen_name (User ID: $user_id). Please review and approve."]);

    echo json_encode([
        'success' => true,
        'message' => 'Your Chef application has been submitted and is currently pending Admin approval.',
        'kitchen_id' => $kitchen_id,
        'is_pending' => true
    ]);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Database connection failed', 'details' => $e->getMessage()]);
}
?>
