<?php
require_header();
require_once 'db_connect.php';

function require_header() {
    
    header("Content-Type: application/json; charset=UTF-8");
    
    
    
}

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$data = json_decode(file_get_contents("php://input"));

if (!isset($data->kitchen_id)) {
    http_response_code(400);
    echo json_encode(["message" => "kitchen_id is required."]);
    exit();
}

$kitchen_id = intval($data->kitchen_id);
$updateFields = [];
$params = [];
$types = "";

if (isset($data->name)) {
    $updateFields[] = "name = ?";
    $params[] = $data->name;
    $types .= "s";
}
if (isset($data->cuisine_type)) {
    $updateFields[] = "cuisine_type = ?";
    $params[] = $data->cuisine_type;
    $types .= "s";
}
if (isset($data->location)) {
    $updateFields[] = "location = ?";
    $params[] = $data->location;
    $types .= "s";
}
if (isset($data->avatar)) {
    $updateFields[] = "avatar = ?";
    $params[] = $data->avatar;
    $types .= "s";
}
if (isset($data->cover_image)) {
    $updateFields[] = "cover_image = ?";
    $params[] = $data->cover_image;
    $types .= "s";
}
if (isset($data->about)) {
    $updateFields[] = "about = ?";
    $params[] = $data->about;
    $types .= "s";
}
if (isset($data->delivery_time)) {
    $updateFields[] = "delivery_time = ?";
    $params[] = $data->delivery_time;
    $types .= "s";
}

if (empty($updateFields)) {
    http_response_code(400);
    echo json_encode(["message" => "No fields to update."]);
    exit();
}

$params[] = $kitchen_id;
$types .= "i";

$query = "UPDATE kitchens SET " . implode(", ", $updateFields) . " WHERE id = ?";
$stmt = $pdo->prepare($query);

// Execute with params
if ($stmt->execute($params)) {
    echo json_encode(["message" => "Kitchen updated successfully.", "success" => true]);
} else {
    http_response_code(500);
    $err = $stmt->errorInfo();
    echo json_encode(["message" => "Unable to update kitchen.", "error" => $err[2], "success" => false]);
}
?>
