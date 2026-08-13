<?php
require_once __DIR__ . '/../api/db_connect.php';

$emails = ['frlflbrt@gmail.com', 'farrellfilbert05@gmail.com'];
$placeholders = implode(',', array_fill(0, count($emails), '?'));

$stmt = $pdo->prepare("SELECT id, email, role FROM users WHERE email IN ($placeholders)");
$stmt->execute($emails);
$users = $stmt->fetchAll(PDO::FETCH_ASSOC);

foreach ($users as $u) {
    echo "User: " . $u['email'] . " (ID: " . $u['id'] . ", Role: " . $u['role'] . ")\n";
    
    $kStmt = $pdo->prepare("SELECT id, name FROM kitchens WHERE user_id = ?");
    $kStmt->execute([$u['id']]);
    $kitchens = $kStmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($kitchens as $k) {
        echo "  -> Deleting Kitchen: " . $k['name'] . " (ID: " . $k['id'] . ")\n";
        
        $pdo->prepare("DELETE FROM menu_items WHERE kitchen_id = ?")->execute([$k['id']]);
        echo "     - Menu items deleted\n";
        
        $pdo->prepare("DELETE FROM reviews WHERE kitchen_id = ?")->execute([$k['id']]);
        echo "     - Reviews deleted\n";
        
        $pdo->prepare("DELETE FROM orders WHERE kitchen_id = ?")->execute([$k['id']]);
        echo "     - Orders deleted\n";
        
        $pdo->prepare("DELETE FROM kitchens WHERE id = ?")->execute([$k['id']]);
        echo "     - Kitchen deleted!\n";
    }
    
    if (empty($kitchens)) {
        echo "  -> No kitchen found for this user.\n";
    }
}

echo "\nDone!\n";
?>
