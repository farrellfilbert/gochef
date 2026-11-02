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
if (isset($data->atmosphere_images)) {
    $updateFields[] = "atmosphere_images = ?";
    $params[] = $data->atmosphere_images;
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
if (isset($data->business_hours)) {
    $updateFields[] = "business_hours = ?";
    $params[] = $data->business_hours;
    $types .= "s";
}
if (isset($data->is_open)) {
    $updateFields[] = "is_open = ?";
    $params[] = intval($data->is_open);
    $types .= "i";
}
if (isset($data->latitude)) {
    $updateFields[] = "latitude = ?";
    $params[] = floatval($data->latitude);
    $types .= "d";
}
if (isset($data->longitude)) {
    $updateFields[] = "longitude = ?";
    $params[] = floatval($data->longitude);
    $types .= "d";
}
if (isset($data->certificates)) {
    try {
        $pdo->exec("ALTER TABLE kitchens ADD COLUMN certificates TEXT DEFAULT NULL");
    } catch (Exception $e) {}
    $updateFields[] = "certificates = ?";
    $params[] = is_string($data->certificates) ? $data->certificates : json_encode($data->certificates);
    $types .= "s";
}
if (isset($data->bank_name)) {
    $updateFields[] = "bank_name = ?";
    $params[] = $data->bank_name;
    $types .= "s";
}
if (isset($data->bank_account_holder)) {
    $updateFields[] = "bank_account_holder = ?";
    $params[] = $data->bank_account_holder;
    $types .= "s";
}
if (isset($data->bank_account_number)) {
    $updateFields[] = "bank_account_number = ?";
    $params[] = $data->bank_account_number;
    $types .= "s";
}
if (isset($data->bank_routing_number)) {
    $updateFields[] = "bank_routing_number = ?";
    $params[] = $data->bank_routing_number;
    $types .= "s";
}
if (isset($data->stripe_account_id)) {
    $updateFields[] = "stripe_account_id = ?";
    $params[] = $data->stripe_account_id;
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
