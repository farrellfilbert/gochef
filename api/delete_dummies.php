<?php
require_once 'db_connect.php';

try {
    $dummy_kitchen_names = [
        "Chef's Kitchen",
        "Spice Symphony",
        "Yosuke's Ramen Den",
        "Global Flavors",
        "Le Petit Bistro",
        "Spice Route Kitchen",
        "Green Bowl Co."
    ];

    $inQuery = implode(',', array_fill(0, count($dummy_kitchen_names), '?'));
    
    // First let's get the IDs to verify
    $stmt = $pdo->prepare("SELECT id, name FROM kitchens WHERE name IN ($inQuery)");
    $stmt->execute($dummy_kitchen_names);
    $kitchens = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Delete them
    $delStmt = $pdo->prepare("DELETE FROM kitchens WHERE name IN ($inQuery)");
    $delStmt->execute($dummy_kitchen_names);
    $deleted_kitchens = $delStmt->rowCount();

    echo json_encode([
        'success' => true, 
        'deleted_count' => $deleted_kitchens,
        'deleted_kitchens' => $kitchens
    ]);
} catch (Exception $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>
