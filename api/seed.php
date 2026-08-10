<?php
require_once 'db_connect.php';

try {
    // Insert kitchens
    $pdo->exec("
        INSERT IGNORE INTO kitchens (id, user_id, name, description, avatar, cover_image, cuisine_type, delivery_time, minimum_order, is_featured, rating, total_reviews) VALUES
        (1, 1, 'Chef\'s Kitchen', 'Premium quality meals cooked with passion.', 'https://images.unsplash.com/photo-1556910103-1c02745aae4d?q=80&w=600&auto=format&fit=crop', 'https://images.unsplash.com/photo-1556910103-1c02745aae4d?q=80&w=600&auto=format&fit=crop', 'Healthy', '15-25 min', 20.00, 1, 4.8, 120),
        (2, 2, 'Spice Symphony', 'Experience the magic of authentic spices.', 'https://images.unsplash.com/photo-1549488344-c5d0137a28eb?q=80&w=600&auto=format&fit=crop', 'https://images.unsplash.com/photo-1549488344-c5d0137a28eb?q=80&w=600&auto=format&fit=crop', 'Indian', '25-40 min', 15.00, 1, 4.6, 85)
    ");

    // Insert menu items
    $pdo->exec("
        INSERT IGNORE INTO menu_items (id, kitchen_id, category_id, name, description, price, image, prep_time, is_available, is_popular, rating, total_reviews) VALUES
        (1, 1, 1, 'Grilled Salmon Bowl', 'Fresh grilled salmon with quinoa and roasted vegetables.', 45000, 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=600&auto=format&fit=crop', '15-20 min', 1, 1, 4.9, 50),
        (2, 2, 2, 'Spicy Chicken Burger', 'Crispy chicken patty with spicy mayo and fresh lettuce.', 35000, 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?q=80&w=600&auto=format&fit=crop', '10-15 min', 1, 1, 4.7, 30)
    ");

    echo "Seed successful!";
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
?>
