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

if (!isset($data->id) || !isset($data->kitchen_id)) {
    http_response_code(400);
    echo json_encode(["message" => "id and kitchen_id are required.", "success" => false]);
    exit();
}

$id = intval($data->id);
$kitchen_id = intval($data->kitchen_id);

// Quick toggle: if only is_available is provided without name
if (isset($data->is_available) && !isset($data->name)) {
    $is_available = (intval($data->is_available) === 1 || $data->is_available === true) ? 1 : 0;
    $stmt = $pdo->prepare("UPDATE menu_items SET is_available = ? WHERE id = ? AND kitchen_id = ?");
    $result = $stmt->execute([$is_available, $id, $kitchen_id]);
    echo json_encode(["message" => "Menu item availability updated.", "is_available" => $is_available, "success" => (bool)$result]);
    exit();
}

$category_id = isset($data->category_id) ? intval($data->category_id) : 1;
$name = isset($data->name) ? $data->name : '';
$description = isset($data->description) ? $data->description : '';
$price = isset($data->price) ? floatval($data->price) : 0;
$image = isset($data->image) ? $data->image : '';
$calories = isset($data->calories) ? intval($data->calories) : 650;
$is_available = isset($data->is_available) ? ((intval($data->is_available) === 1 || $data->is_available === true) ? 1 : 0) : 1;

if ($image !== '') {
    $query = "UPDATE menu_items SET name = ?, description = ?, price = ?, category_id = ?, image = ?, calories = ?, is_available = ? WHERE id = ? AND kitchen_id = ?";
    $stmt = $pdo->prepare($query);
    $result = $stmt->execute([$name, $description, $price, $category_id, $image, $calories, $is_available, $id, $kitchen_id]);
} else {
    $query = "UPDATE menu_items SET name = ?, description = ?, price = ?, category_id = ?, calories = ?, is_available = ? WHERE id = ? AND kitchen_id = ?";
    $stmt = $pdo->prepare($query);
    $result = $stmt->execute([$name, $description, $price, $category_id, $calories, $is_available, $id, $kitchen_id]);
}

if ($result) {
    // Process addon categories if provided
    if (isset($data->addon_categories) && is_array($data->addon_categories)) {
        // Delete old categories (this cascades to addons)
        $deleteQuery = "DELETE FROM menu_addon_categories WHERE menu_item_id = ?";
        $deleteStmt = $pdo->prepare($deleteQuery);
        $deleteStmt->execute([$id]);

        // Insert new categories and addons
        $categoryQuery = "INSERT INTO menu_addon_categories (menu_item_id, name, is_required, is_multiple) VALUES (?, ?, ?, ?)";
        $categoryStmt = $pdo->prepare($categoryQuery);
        
        $addonQuery = "INSERT INTO menu_addons (category_id, name, price) VALUES (?, ?, ?)";
        $addonStmt = $pdo->prepare($addonQuery);
        
        foreach ($data->addon_categories as $category) {
            if (isset($category->name)) {
                $isRequired = isset($category->is_required) && $category->is_required ? 1 : 0;
                $isMultiple = isset($category->is_multiple) && $category->is_multiple ? 1 : 0;
                
                $categoryStmt->execute([$id, $category->name, $isRequired, $isMultiple]);
                $categoryId = $pdo->lastInsertId();
                
                if (isset($category->options) && is_array($category->options)) {
                    foreach ($category->options as $addon) {
                        if (isset($addon->name)) {
                            $addonPrice = isset($addon->price) ? floatval($addon->price) : 0.00;
                            $addonStmt->execute([$categoryId, $addon->name, $addonPrice]);
                        }
                    }
                }
            }
        }
    }

    echo json_encode(["message" => "Menu item updated successfully.", "success" => true]);
} else {
    http_response_code(500);
    $err = $stmt->errorInfo();
    echo json_encode(["message" => "Unable to update menu item.", "error" => $err[2], "success" => false]);
}
?>
