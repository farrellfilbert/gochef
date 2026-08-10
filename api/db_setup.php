<?php
$db_host = 'localhost';
$db_user = 'astroboomin_id_rsa';
$db_pass = 'Astroboomin2026!';
$db_name = 'astroboomin_gochef';

try {
    $pdo = new PDO("mysql:host=$db_host;dbname=$db_name;charset=utf8mb4", $db_user, $db_pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // =============================================
    // USERS (already exists, ensure columns)
    // =============================================
    $pdo->exec("CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        email VARCHAR(100) NOT NULL UNIQUE,
        password VARCHAR(255) NOT NULL,
        phone VARCHAR(50) DEFAULT '',
        avatar VARCHAR(500) DEFAULT '',
        role VARCHAR(20) DEFAULT 'user',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )");
    $pdo->exec("ALTER TABLE users ADD COLUMN IF NOT EXISTS phone VARCHAR(50) DEFAULT ''");
    $pdo->exec("ALTER TABLE users ADD COLUMN IF NOT EXISTS avatar VARCHAR(500) DEFAULT ''");
    $pdo->exec("ALTER TABLE users ADD COLUMN IF NOT EXISTS role VARCHAR(20) DEFAULT 'user'");

    // =============================================
    // CATEGORIES
    // =============================================
    $pdo->exec("CREATE TABLE IF NOT EXISTS categories (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(50) NOT NULL,
        icon VARCHAR(50) DEFAULT 'restaurant',
        sort_order INT DEFAULT 0
    )");

    // =============================================
    // KITCHENS
    // =============================================
    $pdo->exec("CREATE TABLE IF NOT EXISTS kitchens (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NULL,
        name VARCHAR(100) NOT NULL,
        description TEXT,
        avatar VARCHAR(500) DEFAULT '',
        cover_image VARCHAR(500) DEFAULT '',
        rating DECIMAL(2,1) DEFAULT 0.0,
        total_reviews INT DEFAULT 0,
        cuisine_type VARCHAR(100) DEFAULT '',
        delivery_time VARCHAR(50) DEFAULT '20-30 min',
        location VARCHAR(200) DEFAULT '',
        is_verified TINYINT(1) DEFAULT 0,
        is_featured TINYINT(1) DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
    )");

    // =============================================
    // MENU ITEMS
    // =============================================
    $pdo->exec("CREATE TABLE IF NOT EXISTS menu_items (
        id INT AUTO_INCREMENT PRIMARY KEY,
        kitchen_id INT NOT NULL,
        category_id INT NULL,
        name VARCHAR(100) NOT NULL,
        description TEXT,
        price DECIMAL(10,2) NOT NULL,
        image VARCHAR(500) DEFAULT '',
        rating DECIMAL(2,1) DEFAULT 0.0,
        total_reviews INT DEFAULT 0,
        prep_time VARCHAR(50) DEFAULT '15-20 min',
        is_available TINYINT(1) DEFAULT 1,
        is_popular TINYINT(1) DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (kitchen_id) REFERENCES kitchens(id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
    )");

    // =============================================
    // MENU ADD-ONS
    // =============================================
    $pdo->exec("CREATE TABLE IF NOT EXISTS menu_addons (
        id INT AUTO_INCREMENT PRIMARY KEY,
        menu_item_id INT NOT NULL,
        name VARCHAR(100) NOT NULL,
        price DECIMAL(10,2) DEFAULT 0.00,
        FOREIGN KEY (menu_item_id) REFERENCES menu_items(id) ON DELETE CASCADE
    )");

    // =============================================
    // CART ITEMS
    // =============================================
    $pdo->exec("CREATE TABLE IF NOT EXISTS cart_items (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        menu_item_id INT NOT NULL,
        quantity INT DEFAULT 1,
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (menu_item_id) REFERENCES menu_items(id) ON DELETE CASCADE
    )");

    // =============================================
    // CART ITEM ADD-ONS
    // =============================================
    $pdo->exec("CREATE TABLE IF NOT EXISTS cart_item_addons (
        id INT AUTO_INCREMENT PRIMARY KEY,
        cart_item_id INT NOT NULL,
        addon_id INT NOT NULL,
        FOREIGN KEY (cart_item_id) REFERENCES cart_items(id) ON DELETE CASCADE,
        FOREIGN KEY (addon_id) REFERENCES menu_addons(id) ON DELETE CASCADE
    )");

    // =============================================
    // FAVORITES
    // =============================================
    $pdo->exec("CREATE TABLE IF NOT EXISTS favorites (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        menu_item_id INT NULL,
        kitchen_id INT NULL,
        type ENUM('dish','kitchen') NOT NULL DEFAULT 'dish',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (menu_item_id) REFERENCES menu_items(id) ON DELETE CASCADE,
        FOREIGN KEY (kitchen_id) REFERENCES kitchens(id) ON DELETE CASCADE
    )");

    // =============================================
    // REVIEWS
    // =============================================
    $pdo->exec("CREATE TABLE IF NOT EXISTS reviews (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        kitchen_id INT NULL,
        menu_item_id INT NULL,
        rating INT NOT NULL DEFAULT 5,
        comment TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (kitchen_id) REFERENCES kitchens(id) ON DELETE CASCADE,
        FOREIGN KEY (menu_item_id) REFERENCES menu_items(id) ON DELETE CASCADE
    )");

    // =============================================
    // NOTIFICATIONS
    // =============================================
    $pdo->exec("CREATE TABLE IF NOT EXISTS notifications (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        title VARCHAR(200) NOT NULL,
        message TEXT,
        type VARCHAR(50) DEFAULT 'general',
        is_read TINYINT(1) DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    )");

    // =============================================
    // PROMOTIONS
    // =============================================
    $pdo->exec("CREATE TABLE IF NOT EXISTS promotions (
        id INT AUTO_INCREMENT PRIMARY KEY,
        title VARCHAR(200) NOT NULL,
        subtitle VARCHAR(200) DEFAULT '',
        image VARCHAR(500) DEFAULT '',
        discount_percent INT DEFAULT 0,
        code VARCHAR(50) DEFAULT '',
        is_active TINYINT(1) DEFAULT 1,
        start_date DATE NULL,
        end_date DATE NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )");

    // =============================================
    // ADDRESSES
    // =============================================
    $pdo->exec("CREATE TABLE IF NOT EXISTS addresses (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        label VARCHAR(50) DEFAULT 'Home',
        address VARCHAR(300) NOT NULL,
        is_default TINYINT(1) DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    )");

    // =============================================
    // ORDERS (update existing)
    // =============================================
    $pdo->exec("CREATE TABLE IF NOT EXISTS orders (
        id VARCHAR(50) PRIMARY KEY,
        user_id INT NOT NULL,
        kitchen_id INT NULL,
        kitchen_name VARCHAR(100) NOT NULL,
        order_date VARCHAR(50) NOT NULL,
        status VARCHAR(20) NOT NULL DEFAULT 'Active',
        total_amount DECIMAL(10,2) NOT NULL,
        items_count INT NOT NULL,
        avatar VARCHAR(500) DEFAULT '',
        delivery_address VARCHAR(300) DEFAULT '',
        notes TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (kitchen_id) REFERENCES kitchens(id) ON DELETE SET NULL
    )");
    $pdo->exec("ALTER TABLE orders ADD COLUMN IF NOT EXISTS kitchen_id INT NULL");
    // Only try to add foreign key if we know how, simpler to just add column on existing data.
    // If we want to strictly add foreign key to existing table in mysql: 
    // ALTER TABLE orders ADD CONSTRAINT fk_kitchen FOREIGN KEY (kitchen_id) REFERENCES kitchens(id) ON DELETE SET NULL;
    // but ignoring it for safety if the table exists.

    // =============================================
    // ORDER ITEMS (ensure exists)
    // =============================================
    $pdo->exec("CREATE TABLE IF NOT EXISTS order_items (
        id INT AUTO_INCREMENT PRIMARY KEY,
        order_id VARCHAR(50) NOT NULL,
        name VARCHAR(100) NOT NULL,
        options VARCHAR(100) DEFAULT '',
        quantity INT DEFAULT 1,
        price DECIMAL(10,2) NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
    )");

    echo json_encode(['success' => true, 'message' => 'All tables created/updated successfully!']);

} catch (PDOException $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>
