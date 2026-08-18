<?php
require_once 'db_connect.php';

// Handle image upload
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['success' => false, 'error' => 'POST method required']);
    exit;
}

$uploadDir = __DIR__ . '/../uploads/';
if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0755, true);
}

// 1. Check for JSON base64 input
$rawInput = file_get_contents('php://input');
$jsonData = json_decode($rawInput, true);

if ($jsonData && (!empty($jsonData['image']) || !empty($jsonData['image_base64']))) {
    $base64Str = $jsonData['image'] ?? $jsonData['image_base64'];
    
    // Remove data:image/...;base64, prefix if present
    if (preg_match('/^data:image\/(\w+);base64,/', $base64Str, $type)) {
        $base64Str = substr($base64Str, strpos($base64Str, ',') + 1);
        $ext = strtolower($type[1]);
        if ($ext === 'jpeg') $ext = 'jpg';
    } else {
        $ext = 'jpg';
    }

    $decodedData = base64_decode($base64Str);
    if ($decodedData === false) {
        echo json_encode(['success' => false, 'error' => 'Invalid base64 image data']);
        exit;
    }

    $filename = uniqid('img_') . '_' . time() . '.' . $ext;
    $filepath = $uploadDir . $filename;

    if (file_put_contents($filepath, $decodedData)) {
        $host = $_SERVER['HTTP_HOST'] ?? 'thegrubnextdoor.com';
        $scheme = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on') ? 'https' : 'http';
        $imageUrl = "$scheme://$host/uploads/" . $filename;

        echo json_encode(['success' => true, 'url' => $imageUrl, 'filename' => $filename]);
        exit;
    } else {
        echo json_encode(['success' => false, 'error' => 'Failed to save image file']);
        exit;
    }
}

// 2. Check for standard multipart $_FILES
if (!isset($_FILES['image'])) {
    echo json_encode(['success' => false, 'error' => 'No image file or base64 provided']);
    exit;
}

$file = $_FILES['image'];
$allowedTypes = ['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'application/octet-stream'];

if (!in_array($file['type'], $allowedTypes)) {
    echo json_encode(['success' => false, 'error' => 'Invalid file type: ' . $file['type']]);
    exit;
}

// Max 10MB
if ($file['size'] > 10 * 1024 * 1024) {
    echo json_encode(['success' => false, 'error' => 'File too large. Max 10MB']);
    exit;
}

// Generate unique filename
$ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
if (empty($ext)) {
    $ext = 'jpg';
}
$filename = uniqid('img_') . '_' . time() . '.' . $ext;
$filepath = $uploadDir . $filename;

if (move_uploaded_file($file['tmp_name'], $filepath)) {
    $host = $_SERVER['HTTP_HOST'] ?? 'thegrubnextdoor.com';
    $scheme = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on') ? 'https' : 'http';
    $baseUrl = "$scheme://$host/uploads/";
    $imageUrl = $baseUrl . $filename;

    echo json_encode(['success' => true, 'url' => $imageUrl, 'filename' => $filename]);
} else {
    echo json_encode(['success' => false, 'error' => 'Failed to save file']);
}
?>
