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

if (!isset($data->id)) {
    http_response_code(400);
    echo json_encode(["message" => "Menu item id is required.", "success" => false]);
    exit();
}

$id = intval($data->id);

$query = "DELETE FROM menu_items WHERE id = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("i", $id);

if ($stmt->execute()) {
    echo json_encode(["message" => "Menu item deleted successfully.", "success" => true]);
} else {
    http_response_code(500);
    echo json_encode(["message" => "Unable to delete menu item.", "error" => $stmt->error, "success" => false]);
}
?>
