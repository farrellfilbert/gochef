<?php
date_default_timezone_set('Asia/Jakarta');

$db_host = 'localhost';

$host = $_SERVER['HTTP_HOST'] ?? '';
$script_path = $_SERVER['SCRIPT_FILENAME'] ?? __DIR__;

if (strpos($host, 'thegrubnextdoor') !== false || strpos($script_path, 'ghst2026') !== false) {
    $db_user = 'ghst2026_gochefAppsNew';
    $db_pass = 'GochefAppsNew2026!';
    $db_name = 'ghst2026_gochefAppsNew';
} else {
    $db_user = 'astroboomin_id_rsa';
    $db_pass = 'Astroboomin2026!';
    $db_name = 'astroboomin_gochef';
}

try {
    $pdo = new PDO("mysql:host=$db_host;dbname=$db_name;charset=utf8mb4", $db_user, $db_pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
} catch (PDOException $e) {
    if (isset($db_user) && $db_user === 'ghst2026_gochefAppsNew') {
        try {
            $pdo = new PDO("mysql:host=$db_host;dbname=$db_name;charset=utf8mb4", 'ghst2026_GochefAppsNew', $db_pass);
            $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
        } catch (PDOException $e2) {
            http_response_code(500);
            echo json_encode(['success' => false, 'error' => 'Database connection failed']);
            exit;
        }
    } else {
        http_response_code(500);
        echo json_encode(['success' => false, 'error' => 'Database connection failed']);
        exit;
    }
}

// CORS headers
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}
?>
