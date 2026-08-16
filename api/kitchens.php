<?php
require_once 'db_connect.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $featured = isset($_GET['featured']) ? true : false;
    $search = isset($_GET['q']) ? trim($_GET['q']) : '';
    $cuisine = isset($_GET['cuisine']) ? trim($_GET['cuisine']) : '';

    $sql = "SELECT * FROM kitchens WHERE is_verified = 1";
    $params = [];

    if ($featured) {
        $sql .= " AND is_featured = 1";
    }
    if ($search) {
        $sql .= " AND (name LIKE ? OR cuisine_type LIKE ?)";
        $params[] = "%$search%";
        $params[] = "%$search%";
    }
    if ($cuisine) {
        $sql .= " AND cuisine_type = ?";
        $params[] = $cuisine;
    }

    $sql .= " ORDER BY is_featured DESC, rating DESC";

    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $kitchens = $stmt->fetchAll();

    echo json_encode(['success' => true, 'data' => $kitchens]);
}
?>
