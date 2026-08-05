<?php
require_once 'db_connect.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    if (!isset($_GET['user_id'])) {
        echo json_encode(['success' => false, 'error' => 'user_id required']);
        exit;
    }
    $user_id = intval($_GET['user_id']);
    $stmt = $pdo->prepare("SELECT * FROM addresses WHERE user_id = ? ORDER BY is_default DESC, created_at DESC");
    $stmt->execute([$user_id]);
    echo json_encode(['success' => true, 'data' => $stmt->fetchAll()]);

} elseif ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    $user_id = intval($input['user_id'] ?? 0);
    $label = $input['label'] ?? 'Home';
    $address = $input['address'] ?? '';
    $is_default = intval($input['is_default'] ?? 0);

    if (!$user_id || !$address) {
        echo json_encode(['success' => false, 'error' => 'user_id and address required']);
        exit;
    }

    if ($is_default) {
        $pdo->prepare("UPDATE addresses SET is_default = 0 WHERE user_id = ?")->execute([$user_id]);
    }

    $stmt = $pdo->prepare("INSERT INTO addresses (user_id, label, address, is_default) VALUES (?, ?, ?, ?)");
    $stmt->execute([$user_id, $label, $address, $is_default]);

    echo json_encode(['success' => true, 'id' => $pdo->lastInsertId()]);

} elseif ($method === 'DELETE') {
    $input = json_decode(file_get_contents('php://input'), true);
    $id = intval($input['id'] ?? 0);
    $stmt = $pdo->prepare("DELETE FROM addresses WHERE id = ?");
    $stmt->execute([$id]);
    echo json_encode(['success' => true]);
}
?>
