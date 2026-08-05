<?php
require_header();
require_once 'db_connect.php';

function require_header() {
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    header("Access-Control-Allow-Methods: POST");
    header("Access-Control-Max-Age: 3600");
    header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
}

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$data = json_decode(file_get_contents("php://input"));

if (!isset($data->kitchen_id) || !isset($data->name) || !isset($data->price) || !isset($data->category_id)) {
    http_response_code(400);
    echo json_encode(["message" => "kitchen_id, name, price, and category_id are required.", "success" => false]);
    exit();
}

$kitchen_id = intval($data->kitchen_id);
$category_id = intval($data->category_id);
$name = $data->name;
$description = isset($data->description) ? $data->description : '';
$price = floatval($data->price);
$image = isset($data->image) ? $data->image : '';
$is_popular = isset($data->is_popular) ? intval($data->is_popular) : 0;
$tags = isset($data->tags) ? $data->tags : '';

$query = "INSERT INTO menu_items (kitchen_id, category_id, name, description, price, image, is_popular, tags) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
$stmt = $conn->prepare($query);
$stmt->bind_param("iissdsis", $kitchen_id, $category_id, $name, $description, $price, $image, $is_popular, $tags);

if ($stmt->execute()) {
    echo json_encode(["message" => "Menu item created successfully.", "id" => $conn->insert_id, "success" => true]);
} else {
    http_response_code(500);
    echo json_encode(["message" => "Unable to create menu item.", "error" => $stmt->error, "success" => false]);
}
?>
