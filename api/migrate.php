<?php
$db_host = 'localhost';
$db_user = 'astroboomin_id_rsa';
$db_pass = 'Astroboomin2026!';
$db_name = 'astroboomin_gochef';

try {
    $pdo = new PDO("mysql:host=$db_host;dbname=$db_name;charset=utf8mb4", $db_user, $db_pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Drop old tables
    $pdo->exec("DROP TABLE IF EXISTS cart_item_addons");
    $pdo->exec("DROP TABLE IF EXISTS menu_addons");

    // Recreate new tables
    $pdo->exec("CREATE TABLE IF NOT EXISTS menu_addon_categories (
        id INT AUTO_INCREMENT PRIMARY KEY,
        menu_item_id INT NOT NULL,
        name VARCHAR(100) NOT NULL,
        is_required TINYINT(1) DEFAULT 0,
        is_multiple TINYINT(1) DEFAULT 0,
        FOREIGN KEY (menu_item_id) REFERENCES menu_items(id) ON DELETE CASCADE
    )");

    $pdo->exec("CREATE TABLE IF NOT EXISTS menu_addons (
        id INT AUTO_INCREMENT PRIMARY KEY,
        category_id INT NOT NULL,
        name VARCHAR(100) NOT NULL,
        price DECIMAL(10,2) DEFAULT 0.00,
        FOREIGN KEY (category_id) REFERENCES menu_addon_categories(id) ON DELETE CASCADE
    )");

    $pdo->exec("CREATE TABLE IF NOT EXISTS cart_item_addons (
        id INT AUTO_INCREMENT PRIMARY KEY,
        cart_item_id INT NOT NULL,
        addon_id INT NOT NULL,
        FOREIGN KEY (cart_item_id) REFERENCES cart_items(id) ON DELETE CASCADE,
        FOREIGN KEY (addon_id) REFERENCES menu_addons(id) ON DELETE CASCADE
    )");

    echo "Migration successful!";
} catch (PDOException $e) {
    echo "Connection failed: " . $e->getMessage();
}
?>
