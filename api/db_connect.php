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
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Auto-rewrite image URLs to match the requesting origin
$is_https = (isset($_SERVER['HTTPS']) && ($_SERVER['HTTPS'] === 'on' || $_SERVER['HTTPS'] == 1))
    || (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https')
    || (isset($_SERVER['SERVER_PORT']) && $_SERVER['SERVER_PORT'] == 443);
$current_scheme = $is_https ? 'https' : 'http';
$current_host = $_SERVER['HTTP_HOST'] ?? 'thegrubnextdoor.com';
$current_origin = "$current_scheme://$current_host";

if (!ob_get_level()) {
    ob_start(function($output) use ($current_origin) {
        if (empty($output)) return $output;
        $domains = [
            'https://thegrubnextdoor.com',
            'http://thegrubnextdoor.com',
            'https://www.thegrubnextdoor.com',
            'http://www.thegrubnextdoor.com',
            'https://astroboomin.co',
            'http://astroboomin.co'
        ];
        return str_replace($domains, $current_origin, $output);
    });
}
?>
