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

if (!isset($data->id) || !isset($data->kitchen_id)) {
    http_response_code(400);
    echo json_encode(["message" => "id and kitchen_id are required.", "success" => false]);
    exit();
}

$id = intval($data->id);
$kitchen_id = intval($data->kitchen_id);
$category_id = isset($data->category_id) ? intval($data->category_id) : 1;
$name = isset($data->name) ? $data->name : '';
$description = isset($data->description) ? $data->description : '';
$price = isset($data->price) ? floatval($data->price) : 0;
$image = isset($data->image) ? $data->image : '';

if ($image !== '') {
    $query = "UPDATE menu_items SET name = ?, description = ?, price = ?, category_id = ?, image = ? WHERE id = ? AND kitchen_id = ?";
    $stmt = $pdo->prepare($query);
    $result = $stmt->execute([$name, $description, $price, $category_id, $image, $id, $kitchen_id]);
} else {
    $query = "UPDATE menu_items SET name = ?, description = ?, price = ?, category_id = ? WHERE id = ? AND kitchen_id = ?";
    $stmt = $pdo->prepare($query);
    $result = $stmt->execute([$name, $description, $price, $category_id, $id, $kitchen_id]);
}

if ($result) {
    echo json_encode(["message" => "Menu item updated successfully.", "success" => true]);
} else {
    http_response_code(500);
    $err = $stmt->errorInfo();
    echo json_encode(["message" => "Unable to update menu item.", "error" => $err[2], "success" => false]);
}
?>
