<?php
require_once 'db_connect.php';

try {
    $stmt = $pdo->prepare("UPDATE users SET avatar = REPLACE(avatar, 'https://gochef.my.id/', 'https://astroboomin.co/') WHERE avatar LIKE '%https://gochef.my.id/%'");
    $stmt->execute();
    echo json_encode(['success' => true, 'updated' => $stmt->rowCount()]);
} catch (Exception $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>
