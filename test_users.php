<?php
try {
    $pdo = new PDO('mysql:host=localhost;dbname=astroboomin_gochef;charset=utf8mb4', 'astroboomin_id_rsa', 'Astroboomin2026!');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $stmt = $pdo->query('SELECT id, name, email FROM users');
    print_r($stmt->fetchAll(PDO::FETCH_ASSOC));
} catch (Exception $e) {
    echo $e->getMessage();
}
