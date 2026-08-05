<?php
try {
    $pdo = new PDO('mysql:host=localhost;dbname=astroboomin_gochef;charset=utf8mb4', 'astroboomin_id_rsa', 'Astroboomin2026!');
    $stmt = $pdo->query('SELECT id, name, email FROM users');
    echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
} catch (Exception $e) {}
