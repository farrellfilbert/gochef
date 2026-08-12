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

if (!isset($data->id)) {
    http_response_code(400);
    echo json_encode(["message" => "Menu item id is required.", "success" => false]);
    exit();
}

$id = intval($data->id);

$query = "DELETE FROM menu_items WHERE id = ?";
$stmt = $pdo->prepare($query);

if ($stmt->execute([$id])) {
    echo json_encode(["message" => "Menu item deleted successfully.", "success" => true]);
} else {
    http_response_code(500);
    $err = $stmt->errorInfo();
    echo json_encode(["message" => "Unable to delete menu item.", "error" => $err[2], "success" => false]);
}
?>
