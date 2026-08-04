<?php
$db_host = 'localhost';
$db_user = 'astroboomin_id_rsa';
$db_pass = 'Astroboomin2026!';
$db_name = 'astroboomin_gochef';

try {
    $pdo = new PDO("mysql:host=$db_host;dbname=$db_name;charset=utf8mb4", $db_user, $db_pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Create users table first
    $pdo->exec("CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        email VARCHAR(100) NOT NULL UNIQUE,
        password VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )");

    // Alter users table to add phone and avatar
    $pdo->exec("ALTER TABLE users ADD COLUMN IF NOT EXISTS phone VARCHAR(50) DEFAULT ''");
    $pdo->exec("ALTER TABLE users ADD COLUMN IF NOT EXISTS avatar VARCHAR(500) DEFAULT ''");

    // Create orders table
    $pdo->exec("CREATE TABLE IF NOT EXISTS orders (
        id VARCHAR(50) PRIMARY KEY,
        user_id INT(11) NOT NULL,
        kitchen_name VARCHAR(100) NOT NULL,
        order_date VARCHAR(50) NOT NULL,
        status VARCHAR(20) NOT NULL,
        total_amount DECIMAL(10, 2) NOT NULL,
        items_count INT(11) NOT NULL,
        avatar VARCHAR(500) NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    )");

    // Create order_items table
    $pdo->exec("CREATE TABLE IF NOT EXISTS order_items (
        id INT(11) AUTO_INCREMENT PRIMARY KEY,
        order_id VARCHAR(50) NOT NULL,
        name VARCHAR(100) NOT NULL,
        options VARCHAR(100) NOT NULL,
        quantity INT(11) NOT NULL,
        price DECIMAL(10, 2) NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
    )");

    // Insert dummy user if doesn't exist
    $stmt = $pdo->query("SELECT id FROM users WHERE email = 'eleanor.pena@example.com'");
    if ($stmt->rowCount() == 0) {
        $pdo->exec("INSERT INTO users (name, email, password, phone, avatar) VALUES (
            'Eleanor Pena', 'eleanor.pena@example.com', 'dummy_hash', '+62 812 3456 7890', 'https://lh3.googleusercontent.com/aida-public/AB6AXuCABkMoDXf8yH7pXJ1S1GTjNU0hp579UQyB3xr2XusadzrBACMgH_WDbJQAAdV5bL-W7s0clXMSKM22PW7pbg2lVV7_xbXD_2CviE1ZSPIrhKYunEIV1p2VdbWpuIsGSgcjdeexj-lwypxoyRMeM_KDILk3Hky-IOtxBKJ8LBp_5h9RekwfcgmJGwP9qzPEtnfuOprGRUdOor7D-kprabLtBIRSf76GmR_1kOuHtf4cGmxbc6CFse6xnA'
        )");
    } else {
        $pdo->exec("UPDATE users SET name='Eleanor Pena', phone='+62 812 3456 7890', avatar='https://lh3.googleusercontent.com/aida-public/AB6AXuCABkMoDXf8yH7pXJ1S1GTjNU0hp579UQyB3xr2XusadzrBACMgH_WDbJQAAdV5bL-W7s0clXMSKM22PW7pbg2lVV7_xbXD_2CviE1ZSPIrhKYunEIV1p2VdbWpuIsGSgcjdeexj-lwypxoyRMeM_KDILk3Hky-IOtxBKJ8LBp_5h9RekwfcgmJGwP9qzPEtnfuOprGRUdOor7D-kprabLtBIRSf76GmR_1kOuHtf4cGmxbc6CFse6xnA' WHERE email='eleanor.pena@example.com'");
    }

    $stmt = $pdo->query("SELECT id FROM users WHERE email = 'eleanor.pena@example.com'");
    $user_id = $stmt->fetchColumn();

    // Clear old dummy orders
    $pdo->exec("DELETE FROM orders WHERE user_id = $user_id");

    // Insert dummy orders
    $orders = [
        [
            'id' => 'ORD-2023-0891', 'user_id' => $user_id, 'kitchen_name' => 'Le Petit Bistro', 
            'date' => 'Oct 24, 2023 • 19:30', 'status' => 'Active', 'total' => 142.50, 'count' => 3, 
            'avatar' => 'https://lh3.googleusercontent.com/aida-public/AB6AXuAZMoYO7wf8gvDE28myrFAGo5stcscD096feok4IbDsGydgEkamUrKgJh0x2HoW2YQ6o905fcAAOr-UTZU54MXcTMi3vHvnfpfV1fbotdC2EExFxhUlUK3bXX7gDvfb14LG4A0986jNBo2QxfHkrkv03qSESjCZ2GIDfgnTBJCpOTyPtWIum_BfAgzOirM6cNl1beMcwb3AuxtZcsycxq6Vkfph5EBnbtDvdpz4X551OaKyZj43dEkbBQ'
        ],
        [
            'id' => 'ORD-2023-0842', 'user_id' => $user_id, 'kitchen_name' => 'Sakura Sushi Bar', 
            'date' => 'Oct 22, 2023 • 20:15', 'status' => 'Completed', 'total' => 86.00, 'count' => 2, 
            'avatar' => 'https://lh3.googleusercontent.com/aida-public/AB6AXuCG_BhZVHdA8hyglfPxSG6KVPug0ui3JQdoHBaahM4rE0BOYZNDeVTj7DzWvjNxCzvyW8xE4Gr2KUY6gOtZmpohQeanyDWx2TxNnTiCDTcCYdp8pGdsQniNDahf57r1G6xU4oxiAPlKwgyIAWYVRGPXkxG8SL_H7iOntvHeKTzHyPkKBVC9zEM_7D7Jg74DEYxQdPREiZfieTirmrrTdO2CCWMt7xy_lmiHAsz637QxydfOElbMh3VwrA'
        ],
        [
            'id' => 'ORD-2023-0798', 'user_id' => $user_id, 'kitchen_name' => 'Trattoria Roma', 
            'date' => 'Oct 18, 2023 • 18:45', 'status' => 'Cancelled', 'total' => 64.50, 'count' => 2, 
            'avatar' => 'https://lh3.googleusercontent.com/aida-public/AB6AXuAVHfs9-zdJOlD9gIakLDDih1LuvMloL7b3yrLfSkqAINTKJ2Km3q_Vn12txGIaFj2kydQ1c43ZeYTbge-quvtnNDMctMmgh-8FXIkc86CuY7bvi6qLl0cN-YTiA8WrAQK8iRgIgir6qNySDI7lVH4v6uyE8bDDMMwHhLmaPjfINg3-EzyqAAPwaB-BQuqWsp8vAYW10K6--ln6VsNJ6SNwml1bkCTf1o5ejDTg1DuDcBHqkgeUg71rSw'
        ],
        [
            'id' => 'ORD-2023-0755', 'user_id' => $user_id, 'kitchen_name' => 'Spice Route', 
            'date' => 'Oct 15, 2023 • 19:00', 'status' => 'Completed', 'total' => 52.00, 'count' => 3, 
            'avatar' => 'https://lh3.googleusercontent.com/aida-public/AB6AXuAc2H_ek12cJF5ZnPJZ76YeCR3nSRDNVLVE9JGldUYq8fmKWMYxcB8rrzua7ALPBHaiSgJ6zO-eE5IvST3JywjWNkPARYrhHGgAwRy7w9UXBXNOU93MBGWLBJmmk0oEzab_evBCjp-nGWbzrFJ0b9fXjiVrw_XlsPIlBy1SrQePBaMIkZudTopPz-kXMCWUrYBKRj7ikymuxZFxm10kdte_J_h5QYU5QGTJSEIAiqGk75D1SNpDWj8ISw'
        ]
    ];

    $stmt = $pdo->prepare("INSERT INTO orders (id, user_id, kitchen_name, order_date, status, total_amount, items_count, avatar) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
    foreach ($orders as $o) {
        $stmt->execute([$o['id'], $o['user_id'], $o['kitchen_name'], $o['date'], $o['status'], $o['total'], $o['count'], $o['avatar']]);
    }

    // Insert dummy items for ORD-2023-0891
    $items = [
        ['ORD-2023-0891', 'Truffle Risotto', 'Extra parmesan', 1, 45.0],
        ['ORD-2023-0891', 'Wagyu Beef Wellington', 'Medium rare', 1, 85.0],
        ['ORD-2023-0891', 'Sparkling Water', 'Chilled', 1, 12.5],
    ];
    $itemStmt = $pdo->prepare("INSERT INTO order_items (order_id, name, options, quantity, price) VALUES (?, ?, ?, ?, ?)");
    foreach ($items as $i) {
        $itemStmt->execute($i);
    }

    echo "Database structure updated and dummy data inserted!\n";

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
?>
