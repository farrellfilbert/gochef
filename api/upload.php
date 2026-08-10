<?php
require_once 'db_connect.php';

// Handle image upload
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['success' => false, 'error' => 'POST method required']);
    exit;
}

if (!isset($_FILES['image'])) {
    echo json_encode(['success' => false, 'error' => 'No image file provided']);
    exit;
}

$file = $_FILES['image'];
$allowedTypes = ['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'application/octet-stream'];

if (!in_array($file['type'], $allowedTypes)) {
    echo json_encode(['success' => false, 'error' => 'Invalid file type sent by client: ' . $file['type']]);
    exit;
}

if (getimagesize($file['tmp_name']) === false) {
    echo json_encode(['success' => false, 'error' => 'File is not a valid image']);
    exit;
}

// Max 5MB
if ($file['size'] > 5 * 1024 * 1024) {
    echo json_encode(['success' => false, 'error' => 'File too large. Max 5MB']);
    exit;
}

// Create uploads directory
$uploadDir = __DIR__ . '/../uploads/';
if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0755, true);
}

// Generate unique filename
$ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
if (empty($ext)) {
    $ext = 'jpg';
}
$filename = uniqid('img_') . '_' . time() . '.' . $ext;
$filepath = $uploadDir . $filename;

if (move_uploaded_file($file['tmp_name'], $filepath)) {
    // Return the public URL
    $baseUrl = 'https://astroboomin.co/uploads/';
    $imageUrl = $baseUrl . $filename;

    echo json_encode(['success' => true, 'url' => $imageUrl, 'filename' => $filename]);
} else {
    echo json_encode(['success' => false, 'error' => 'Failed to save file']);
}
?>
