<?php
require_once 'db_connect.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'OPTIONS') {
    http_response_code(200);
    exit;
}

if ($method === 'GET') {
    if (!isset($_GET['user_id'])) {
        echo json_encode(['success' => false, 'error' => 'user_id required']);
        exit;
    }
    $user_id = intval($_GET['user_id']);
    $stmt = $pdo->prepare("SELECT * FROM addresses WHERE user_id = ? ORDER BY is_default DESC, created_at DESC");
    $stmt->execute([$user_id]);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // If user has no address yet, create default Los Angeles, California address
    if (empty($results) && $user_id > 0) {
        $defAddress = "11012 Ventura Blvd, Studio City, Los Angeles, CA 91604";
        $ins = $pdo->prepare("INSERT INTO addresses (user_id, label, address, is_default) VALUES (?, 'Home', ?, 1)");
        $ins->execute([$user_id, $defAddress]);
        $stmt->execute([$user_id]);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    echo json_encode(['success' => true, 'data' => $results]);

} elseif ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    if (!$input) $input = $_POST;
    
    $user_id = intval($input['user_id'] ?? 0);
    $label = trim($input['label'] ?? 'Home');
    $address = trim($input['address'] ?? '');
    $is_default = intval($input['is_default'] ?? 0);

    if (!$user_id || !$address) {
        http_response_code(400);
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
    $id = intval($input['id'] ?? $_GET['id'] ?? 0);
    
    if (!$id) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'id required']);
        exit;
    }
    
    $stmt = $pdo->prepare("DELETE FROM addresses WHERE id = ?");
    $stmt->execute([$id]);
    echo json_encode(['success' => true, 'message' => 'Address deleted']);

} elseif ($method === 'PUT') {
    $input = json_decode(file_get_contents('php://input'), true);
    $id = intval($input['id'] ?? 0);
    $label = trim($input['label'] ?? 'Home');
    $address = trim($input['address'] ?? '');

    if (!$id || !$address) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'id and address required']);
        exit;
    }

    $stmt = $pdo->prepare("UPDATE addresses SET label = ?, address = ? WHERE id = ?");
    $stmt->execute([$label, $address, $id]);

    echo json_encode(['success' => true, 'message' => 'Address updated']);
}
?>