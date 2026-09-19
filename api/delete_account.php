<?php
require_once 'db_connect.php';

header('Content-Type: application/json');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

try {
    $input = json_decode(file_get_contents('php://input'), true);
    $user_id = $input['user_id'] ?? $_POST['user_id'] ?? $_GET['user_id'] ?? null;

    if (!$user_id) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'user_id is required']);
        exit();
    }

    $pdo->beginTransaction();

    // Check user existence
    $stmt = $pdo->prepare("SELECT id, email FROM users WHERE id = ? LIMIT 1");
    $stmt->execute([$user_id]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user) {
        $pdo->rollBack();
        http_response_code(404);
        echo json_encode(['success' => false, 'error' => 'User not found']);
        exit();
    }

    // Delete or clear user related records
    // 1. Remove user cart
    $delCart = $pdo->prepare("DELETE FROM cart WHERE user_id = ?");
    $delCart->execute([$user_id]);

    // 2. Remove user favorites
    $delFav = $pdo->prepare("DELETE FROM favorites WHERE user_id = ?");
    $delFav->execute([$user_id]);

    // 3. Delete user or anonymize to comply with App Store Guideline 5.1.1(v)
    $delUser = $pdo->prepare("DELETE FROM users WHERE id = ?");
    $delUser->execute([$user_id]);

    $pdo->commit();

    echo json_encode([
        'success' => true,
        'message' => 'Account has been permanently deleted successfully.'
    ]);

} catch (PDOException $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Database error: ' . $e->getMessage()]);
}
?>
