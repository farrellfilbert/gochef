<?php
require_once 'db_connect.php';

try {
    // =============================================
    // CATEGORIES
    // =============================================
    $pdo->exec("DELETE FROM categories");
    $cats = [
        ['All', 'restaurant', 0],
        ['Breakfast', 'free_breakfast', 1],
        ['Lunch', 'lunch_dining', 2],
        ['Dinner', 'dinner_dining', 3],
        ['Desserts', 'cake', 4],
        ['Drinks', 'local_cafe', 5],
        ['Healthy', 'eco', 6],
        ['Late Night', 'nightlight', 7],
    ];
    $stmt = $pdo->prepare("INSERT INTO categories (name, icon, sort_order) VALUES (?, ?, ?)");
    foreach ($cats as $c) { $stmt->execute($c); }

    // =============================================
    // KITCHENS
    // =============================================
    $pdo->exec("DELETE FROM reviews");
    $pdo->exec("DELETE FROM menu_addons");
    $pdo->exec("DELETE FROM cart_item_addons");
    $pdo->exec("DELETE FROM cart_items");
    $pdo->exec("DELETE FROM favorites");
    $pdo->exec("DELETE FROM order_items");
    $pdo->exec("DELETE FROM orders");
    $pdo->exec("DELETE FROM menu_items");
    $pdo->exec("DELETE FROM kitchens");

    $kitchens = [
        [
            'name' => "Yosuke's Ramen Den",
            'description' => "Authentic Japanese ramen crafted with passion. Our signature 18-hour Tonkotsu broth is simmered to perfection, creating rich, creamy bowls that transport you to the streets of Tokyo. Every ingredient is carefully selected for the ultimate ramen experience.",
            'avatar' => 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=200&h=200&fit=crop',
            'cover_image' => 'https://images.unsplash.com/photo-1557872943-16a5ac26437e?w=800&h=400&fit=crop',
            'rating' => 4.9, 'total_reviews' => 128,
            'cuisine_type' => 'Japanese', 'delivery_time' => '25-35 min',
            'location' => 'University District', 'is_verified' => 1, 'is_featured' => 1
        ],
        [
            'name' => 'Global Flavors',
            'description' => "A world of taste in every dish. Chef Elena Rossi brings her international culinary training to create stunning fusion dishes that blend Mediterranean, Asian, and Latin flavors into unforgettable meals.",
            'avatar' => 'https://images.unsplash.com/photo-1577219491135-ce391730fb2c?w=200&h=200&fit=crop',
            'cover_image' => 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&h=400&fit=crop',
            'rating' => 4.8, 'total_reviews' => 96,
            'cuisine_type' => 'Fusion', 'delivery_time' => '20-30 min',
            'location' => 'Arts District', 'is_verified' => 1, 'is_featured' => 1
        ],
        [
            'name' => 'Le Petit Bistro',
            'description' => "Classic French cuisine with a modern twist. From perfectly seared duck breast to delicate pastries, every dish is a celebration of traditional French cooking techniques.",
            'avatar' => 'https://images.unsplash.com/photo-1581349485608-9469926a8e5e?w=200&h=200&fit=crop',
            'cover_image' => 'https://images.unsplash.com/photo-1550966871-3ed3cdb51f3a?w=800&h=400&fit=crop',
            'rating' => 4.7, 'total_reviews' => 84,
            'cuisine_type' => 'French', 'delivery_time' => '30-40 min',
            'location' => 'Downtown', 'is_verified' => 1, 'is_featured' => 1
        ],
        [
            'name' => 'Spice Route Kitchen',
            'description' => "Embark on a culinary journey through Southeast Asia. Authentic Thai, Vietnamese, and Indonesian dishes made with traditional spice blends and fresh ingredients.",
            'avatar' => 'https://images.unsplash.com/photo-1556910103-1c02745aae4d?w=200&h=200&fit=crop',
            'cover_image' => 'https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?w=800&h=400&fit=crop',
            'rating' => 4.6, 'total_reviews' => 72,
            'cuisine_type' => 'Asian', 'delivery_time' => '20-25 min',
            'location' => 'University District', 'is_verified' => 1, 'is_featured' => 0
        ],
        [
            'name' => 'Green Bowl Co.',
            'description' => "Healthy, nourishing bowls that don't compromise on flavor. Plant-based and gluten-free options made with locally sourced organic ingredients.",
            'avatar' => 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=200&h=200&fit=crop',
            'cover_image' => 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=800&h=400&fit=crop',
            'rating' => 4.5, 'total_reviews' => 58,
            'cuisine_type' => 'Healthy', 'delivery_time' => '15-20 min',
            'location' => 'Midtown', 'is_verified' => 0, 'is_featured' => 0
        ],
    ];

    $kitchenIds = [];
    $stmt = $pdo->prepare("INSERT INTO kitchens (name, description, avatar, cover_image, rating, total_reviews, cuisine_type, delivery_time, location, is_verified, is_featured) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
    foreach ($kitchens as $k) {
        $stmt->execute([$k['name'], $k['description'], $k['avatar'], $k['cover_image'], $k['rating'], $k['total_reviews'], $k['cuisine_type'], $k['delivery_time'], $k['location'], $k['is_verified'], $k['is_featured']]);
        $kitchenIds[] = $pdo->lastInsertId();
    }

    // =============================================
    // MENU ITEMS
    // =============================================
    $menuData = [
        // Yosuke's Ramen Den
        [$kitchenIds[0], 3, 'Spicy Miso Ramen', 'Rich miso broth with chashu pork, soft-boiled egg, bamboo shoots, corn, and nori. Topped with chili oil and sesame seeds.', 18.50, 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&h=400&fit=crop', 4.9, 42, '25-35 min', 1, 1],
        [$kitchenIds[0], 3, 'Tonkotsu Ramen Classic', 'Our signature 18-hour pork bone broth with thin noodles, chashu, ajitama egg, and green onions.', 16.00, 'https://images.unsplash.com/photo-1614563637806-1d0e645e0940?w=400&h=400&fit=crop', 4.8, 38, '25-35 min', 1, 1],
        [$kitchenIds[0], 3, 'Shoyu Ramen', 'Light soy sauce-based broth with chicken, bamboo shoots, nori, and spring onions.', 15.00, 'https://images.unsplash.com/photo-1591814468924-caf88d1232e1?w=400&h=400&fit=crop', 4.7, 25, '20-30 min', 1, 0],
        [$kitchenIds[0], 5, 'Matcha Latte', 'Premium ceremonial grade matcha with steamed oat milk.', 6.50, 'https://images.unsplash.com/photo-1515823064-d6e0c04616a7?w=400&h=400&fit=crop', 4.5, 15, '5 min', 1, 0],

        // Global Flavors
        [$kitchenIds[1], 3, 'Wild Mushroom Tagliatelle', 'Fresh pasta with porcini, shiitake, and oyster mushrooms in truffle cream sauce with parmesan.', 24.00, 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=400&h=400&fit=crop', 4.8, 35, '20-25 min', 1, 1],
        [$kitchenIds[1], 3, 'Korean BBQ Tacos', 'Fusion tacos with bulgogi beef, kimchi slaw, gochujang aioli, and pickled daikon.', 16.50, 'https://images.unsplash.com/photo-1551504734-5ee1c4a1479b?w=400&h=400&fit=crop', 4.7, 28, '15-20 min', 1, 1],
        [$kitchenIds[1], 2, 'Mediterranean Bowl', 'Quinoa, grilled halloumi, roasted vegetables, hummus, falafel, and tahini dressing.', 19.00, 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&h=400&fit=crop', 4.6, 22, '15-20 min', 1, 0],

        // Le Petit Bistro
        [$kitchenIds[2], 3, 'Truffle Risotto', 'Arborio rice slow-cooked with white truffle oil, wild mushrooms, and aged parmesan. Finished with microgreens.', 32.00, 'https://images.unsplash.com/photo-1476124369491-e7addf5db371?w=400&h=400&fit=crop', 4.9, 30, '30-40 min', 1, 1],
        [$kitchenIds[2], 3, 'Wagyu Beef Wellington', 'Premium wagyu wrapped in mushroom duxelles and puff pastry, served with red wine jus.', 85.00, 'https://images.unsplash.com/photo-1544025162-d76694265947?w=400&h=400&fit=crop', 4.8, 18, '35-45 min', 1, 1],
        [$kitchenIds[2], 4, 'Crème Brûlée', 'Classic vanilla bean custard with caramelized sugar top.', 14.00, 'https://images.unsplash.com/photo-1470124182917-cc6e71b22ecc?w=400&h=400&fit=crop', 4.7, 40, '15 min', 1, 0],

        // Spice Route
        [$kitchenIds[3], 3, 'Pad Thai', 'Classic stir-fried rice noodles with shrimp, tofu, bean sprouts, peanuts, and lime.', 14.50, 'https://images.unsplash.com/photo-1559314809-0d155014e29e?w=400&h=400&fit=crop', 4.6, 32, '15-20 min', 1, 1],
        [$kitchenIds[3], 3, 'Green Curry', 'Coconut milk based Thai green curry with chicken, bamboo shoots, Thai basil, and jasmine rice.', 15.00, 'https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?w=400&h=400&fit=crop', 4.5, 28, '20-25 min', 1, 0],
        [$kitchenIds[3], 3, 'Nasi Goreng', 'Indonesian fried rice with chicken, shrimp paste, sweet soy sauce, fried egg, and prawn crackers.', 13.00, 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400&h=400&fit=crop', 4.4, 20, '15-20 min', 1, 0],

        // Green Bowl Co.
        [$kitchenIds[4], 2, 'Açaí Power Bowl', 'Organic açaí blend topped with granola, banana, strawberries, coconut flakes, and honey.', 12.00, 'https://images.unsplash.com/photo-1590301157890-4810ed352733?w=400&h=400&fit=crop', 4.6, 25, '10-15 min', 1, 1],
        [$kitchenIds[4], 2, 'Buddha Bowl', 'Brown rice, roasted sweet potato, avocado, edamame, pickled ginger, and miso dressing.', 15.00, 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400&h=400&fit=crop', 4.5, 20, '15-20 min', 1, 0],
        [$kitchenIds[4], 5, 'Green Detox Smoothie', 'Spinach, kale, banana, mango, ginger, and coconut water.', 8.50, 'https://images.unsplash.com/photo-1610970881699-44a5587cabec?w=400&h=400&fit=crop', 4.4, 15, '5 min', 1, 0],
    ];

    $menuIds = [];
    $stmt = $pdo->prepare("INSERT INTO menu_items (kitchen_id, category_id, name, description, price, image, rating, total_reviews, prep_time, is_available, is_popular) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
    foreach ($menuData as $m) {
        $stmt->execute($m);
        $menuIds[] = $pdo->lastInsertId();
    }

    // =============================================
    // MENU ADD-ONS
    // =============================================
    $addons = [
        // Spicy Miso Ramen addons
        [$menuIds[0], 'Extra Chashu', 4.50],
        [$menuIds[0], 'Extra Noodles', 2.00],
        [$menuIds[0], 'Soft-Boiled Egg', 2.50],
        [$menuIds[0], 'Extra Spicy', 0.00],
        // Tonkotsu addons
        [$menuIds[1], 'Extra Chashu', 4.50],
        [$menuIds[1], 'Corn Topping', 1.50],
        // Wild Mushroom Tagliatelle addons
        [$menuIds[4], 'Truffle Oil Drizzle', 5.00],
        [$menuIds[4], 'Extra Parmesan', 2.00],
        [$menuIds[4], 'Grilled Chicken', 6.00],
        // Truffle Risotto addons
        [$menuIds[7], 'Extra Truffle', 8.00],
        [$menuIds[7], 'Grilled Prawns', 12.00],
        // Pad Thai addons
        [$menuIds[10], 'Extra Shrimp', 5.00],
        [$menuIds[10], 'Extra Peanuts', 1.00],
    ];
    $stmt = $pdo->prepare("INSERT INTO menu_addons (menu_item_id, name, price) VALUES (?, ?, ?)");
    foreach ($addons as $a) { $stmt->execute($a); }

    // =============================================
    // PROMOTIONS
    // =============================================
    $pdo->exec("DELETE FROM promotions");
    $promos = [
        ['50% Off Your First Order', 'Exclusive to University District students', 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&h=400&fit=crop', 50, 'FIRST50', 1],
        ['Free Delivery This Week', 'On all orders above $20', 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&h=400&fit=crop', 0, 'FREEDEL', 1],
        ['Buy 2 Get 1 Free', 'On selected ramen bowls at Yosuke\'s', 'https://images.unsplash.com/photo-1557872943-16a5ac26437e?w=800&h=400&fit=crop', 33, 'RAMEN3', 1],
    ];
    $stmt = $pdo->prepare("INSERT INTO promotions (title, subtitle, image, discount_percent, code, is_active) VALUES (?, ?, ?, ?, ?, ?)");
    foreach ($promos as $p) { $stmt->execute($p); }

    // =============================================
    // SAMPLE REVIEWS
    // =============================================
    // Get first user for reviews (or create a dummy reviewer)
    $stmt = $pdo->query("SELECT id FROM users LIMIT 1");
    $userId = $stmt->fetchColumn();
    if (!$userId) {
        $pdo->exec("INSERT INTO users (name, email, password) VALUES ('Sample User', 'sample@test.com', 'dummy')");
        $userId = $pdo->lastInsertId();
    }

    // Create additional dummy reviewers
    $reviewerNames = ['Alex Chen', 'Maria Santos', 'James Wilson', 'Yuki Tanaka', 'Sophie Laurent'];
    $reviewerIds = [];
    foreach ($reviewerNames as $name) {
        $email = strtolower(str_replace(' ', '.', $name)) . '@example.com';
        $stmt = $pdo->prepare("SELECT id FROM users WHERE email = ?");
        $stmt->execute([$email]);
        $rid = $stmt->fetchColumn();
        if (!$rid) {
            $pdo->prepare("INSERT INTO users (name, email, password) VALUES (?, ?, 'dummy')")->execute([$name, $email]);
            $rid = $pdo->lastInsertId();
        }
        $reviewerIds[] = $rid;
    }

    $reviewData = [
        [$reviewerIds[0], $kitchenIds[0], $menuIds[0], 5, 'Best ramen I\'ve ever had! The broth is incredibly rich and flavorful.'],
        [$reviewerIds[1], $kitchenIds[0], $menuIds[1], 5, 'The Tonkotsu is absolutely divine. Perfect noodle texture.'],
        [$reviewerIds[2], $kitchenIds[1], $menuIds[4], 4, 'Great pasta, generous truffle flavor. Would order again!'],
        [$reviewerIds[3], $kitchenIds[1], $menuIds[5], 5, 'These fusion tacos are incredible. Such a creative combination.'],
        [$reviewerIds[4], $kitchenIds[2], $menuIds[7], 5, 'Exquisite risotto. The truffle makes it so luxurious.'],
        [$reviewerIds[0], $kitchenIds[2], $menuIds[8], 4, 'Wagyu was perfectly cooked. A bit pricey but worth every penny.'],
        [$reviewerIds[1], $kitchenIds[3], $menuIds[10], 4, 'Authentic Pad Thai! Reminds me of Bangkok street food.'],
        [$reviewerIds[2], $kitchenIds[4], $menuIds[13], 5, 'Love this açaí bowl! So fresh and filling.'],
    ];
    $stmt = $pdo->prepare("INSERT INTO reviews (user_id, kitchen_id, menu_item_id, rating, comment) VALUES (?, ?, ?, ?, ?)");
    foreach ($reviewData as $r) { $stmt->execute($r); }

    // =============================================
    // SAMPLE NOTIFICATIONS (for first user)
    // =============================================
    $pdo->exec("DELETE FROM notifications");
    $notifs = [
        [$userId, 'Welcome to GoChef!', 'Start exploring amazing food from local student chefs near you.', 'general'],
        [$userId, '50% Off Your First Order', 'Use code FIRST50 to get half off your first order!', 'promo'],
        [$userId, 'New Kitchen Added', 'Green Bowl Co. just joined GoChef! Check out their healthy bowls.', 'general'],
    ];
    $stmt = $pdo->prepare("INSERT INTO notifications (user_id, title, message, type) VALUES (?, ?, ?, ?)");
    foreach ($notifs as $n) { $stmt->execute($n); }

    echo json_encode([
        'success' => true, 
        'message' => 'Seed data inserted!',
        'counts' => [
            'categories' => count($cats),
            'kitchens' => count($kitchens),
            'menu_items' => count($menuData),
            'addons' => count($addons),
            'promotions' => count($promos),
            'reviews' => count($reviewData),
            'notifications' => count($notifs)
        ]
    ]);

} catch (PDOException $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>
