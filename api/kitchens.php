<?php
require_once 'db_connect.php';

// Auto-migrate latitude and longitude columns
try {
    $pdo->exec("ALTER TABLE kitchens ADD COLUMN latitude DECIMAL(10, 8) DEFAULT NULL");
} catch (Exception $e) {}
try {
    $pdo->exec("ALTER TABLE kitchens ADD COLUMN longitude DECIMAL(11, 8) DEFAULT NULL");
} catch (Exception $e) {}

// Populate fixed coordinates if null
$fixedCoords = [
    1 => [34.1722, -118.3765], // North Hollywood (1.0 mi)
    2 => [34.1610, -118.3920], // Valley Village (2.0 mi)
    3 => [34.1480, -118.3890], // Studio City (3.0 mi)
    4 => [34.1810, -118.4280], // Valley Glen (4.0 mi)
    5 => [34.1520, -118.4480], // Sherman Oaks (5.0 mi)
    6 => [34.2050, -118.3980], // Sun Valley (3.0 mi)
    7 => [34.2270, -118.4480], // Panorama City (5.0 mi)
    8 => [34.1380, -118.3550], // Toluca Lake/Burbank (4.0 mi)
    9 => [34.1350, -118.4120], // Coldwater Canyon (5.0 mi)
    10 => [34.1660, -118.4550], // Los Angeles Valley College (5.0 mi)
    11 => [34.1560, -118.4650], // Sherman Oaks (6.0 mi)
    12 => [34.1470, -118.4720], // Sherman Oaks South (6.0 mi)
    13 => [34.1200, -118.4800], // Beverly Glen (7.0 mi)
    14 => [34.0950, -118.4120], // Greystone Mansion (7.0 mi)
    15 => [34.0880, -118.4050], // Beverly Hills (8.0 mi)
];

foreach ($fixedCoords as $kid => $coord) {
    $pdo->prepare("UPDATE kitchens SET latitude = ?, longitude = ? WHERE id = ? AND (latitude IS NULL OR latitude = 0)")->execute([$coord[0], $coord[1], $kid]);
}

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $featured = isset($_GET['featured']) ? true : false;
    $search = isset($_GET['q']) ? trim($_GET['q']) : '';
    $cuisine = isset($_GET['cuisine']) ? trim($_GET['cuisine']) : '';

    $sql = "SELECT k.*, u.name as chef_name FROM kitchens k LEFT JOIN users u ON k.user_id = u.id WHERE k.is_verified = 1 AND (k.status IS NULL OR k.status = 'active')";
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
