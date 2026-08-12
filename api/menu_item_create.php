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

$query = "INSERT INTO menu_items (kitchen_id, category_id, name, description, price, image, is_popular) VALUES (?, ?, ?, ?, ?, ?, ?)";
$stmt = $pdo->prepare($query);

if ($stmt->execute([$kitchen_id, $category_id, $name, $description, $price, $image, $is_popular])) {
    $menu_item_id = $pdo->lastInsertId();
    
    // Process addons if provided
    if (isset($data->addons) && is_array($data->addons)) {
        $addonQuery = "INSERT INTO menu_addons (menu_item_id, name, price) VALUES (?, ?, ?)";
        $addonStmt = $pdo->prepare($addonQuery);
        foreach ($data->addons as $addon) {
            if (isset($addon->name)) {
                $addonPrice = isset($addon->price) ? floatval($addon->price) : 0.00;
                $addonStmt->execute([$menu_item_id, $addon->name, $addonPrice]);
            }
        }
    }
    
    echo json_encode(["message" => "Menu item created successfully.", "id" => $menu_item_id, "success" => true]);
} else {
    http_response_code(500);
    $err = $stmt->errorInfo();
    echo json_encode(["message" => "Unable to create menu item.", "error" => $err[2], "success" => false]);
}
?>
