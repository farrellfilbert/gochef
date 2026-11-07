<?php
require_once 'db_connect.php';

header('Content-Type: application/json');

$results = [];

try {
    // 1. Migrate menu_items
    try {
        $pdo->exec("ALTER TABLE menu_items ADD COLUMN dietary_tags TEXT DEFAULT NULL");
        $results[] = "Added dietary_tags to menu_items";
    } catch (Exception $e) {
        $results[] = "dietary_tags already in menu_items or error: " . $e->getMessage();
    }

    try {
        $pdo->exec("ALTER TABLE menu_items ADD COLUMN daily_quota INT DEFAULT 20");
        $results[] = "Added daily_quota to menu_items";
    } catch (Exception $e) {
        $results[] = "daily_quota already in menu_items or error: " . $e->getMessage();
    }

    try {
        $pdo->exec("ALTER TABLE menu_items ADD COLUMN portions_sold_today INT DEFAULT 0");
        $results[] = "Added portions_sold_today to menu_items";
    } catch (Exception $e) {
        $results[] = "portions_sold_today already in menu_items or error: " . $e->getMessage();
    }

    // 2. Migrate kitchens
    try {
        $pdo->exec("ALTER TABLE kitchens ADD COLUMN vacation_mode TINYINT(1) DEFAULT 0");
        $results[] = "Added vacation_mode to kitchens";
    } catch (Exception $e) {
        $results[] = "vacation_mode already in kitchens or error: " . $e->getMessage();
    }

    try {
        $pdo->exec("ALTER TABLE kitchens ADD COLUMN vacation_return_date VARCHAR(50) DEFAULT NULL");
        $results[] = "Added vacation_return_date to kitchens";
    } catch (Exception $e) {
        $results[] = "vacation_return_date already in kitchens or error: " . $e->getMessage();
    }

    try {
        $pdo->exec("ALTER TABLE kitchens ADD COLUMN vacation_message TEXT DEFAULT NULL");
        $results[] = "Added vacation_message to kitchens";
    } catch (Exception $e) {
        $results[] = "vacation_message already in kitchens or error: " . $e->getMessage();
    }

    // 3. Migrate users
    try {
        $pdo->exec("ALTER TABLE users ADD COLUMN referral_code VARCHAR(20) DEFAULT NULL");
        $results[] = "Added referral_code to users";
    } catch (Exception $e) {
        $results[] = "referral_code already in users or error: " . $e->getMessage();
    }

    try {
        $pdo->exec("ALTER TABLE users ADD COLUMN referred_by VARCHAR(20) DEFAULT NULL");
        $results[] = "Added referred_by to users";
    } catch (Exception $e) {
        $results[] = "referred_by already in users or error: " . $e->getMessage();
    }

    try {
        $pdo->exec("ALTER TABLE users ADD COLUMN referral_balance DECIMAL(10,2) DEFAULT 10.00");
        $results[] = "Added referral_balance to users";
    } catch (Exception $e) {
        $results[] = "referral_balance already in users or error: " . $e->getMessage();
    }

    // 4. Create referrals table
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS referrals (
            id INT AUTO_INCREMENT PRIMARY KEY,
            referrer_id INT NOT NULL,
            referred_user_id INT NOT NULL,
            code_used VARCHAR(20) NOT NULL,
            reward_amount DECIMAL(10,2) DEFAULT 10.00,
            status VARCHAR(20) DEFAULT 'completed',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ");
    $results[] = "Referrals table verified";

    // 5. Populate referral codes for existing users if null
    $users = $pdo->query("SELECT id, name FROM users WHERE referral_code IS NULL OR referral_code = ''")->fetchAll(PDO::FETCH_ASSOC);
    $upStmt = $pdo->prepare("UPDATE users SET referral_code = ? WHERE id = ?");
    foreach ($users as $u) {
        $cleanName = strtoupper(preg_replace('/[^A-Za-z0-9]/', '', $u['name']));
        if (strlen($cleanName) < 3) $cleanName = 'USER';
        $prefix = substr($cleanName, 0, 6);
        $code = 'GO' . $prefix . $u['id'];
        $upStmt->execute([$code, $u['id']]);
    }
    $results[] = "Generated referral codes for " . count($users) . " users";

    // 6. Populate California dietary tags for existing dishes if null
    $dishes = $pdo->query("SELECT id, name, description FROM menu_items WHERE dietary_tags IS NULL OR dietary_tags = ''")->fetchAll(PDO::FETCH_ASSOC);
    $tagStmt = $pdo->prepare("UPDATE menu_items SET dietary_tags = ?, daily_quota = ? WHERE id = ?");
    $taggedCount = 0;
    foreach ($dishes as $d) {
        $name = strtolower($d['name'] . ' ' . $d['description']);
        $tags = [];

        if (preg_match('/(vegan|tofu|veggie|plant|salad|greens|avocado|mushroom)/i', $name)) {
            $tags[] = 'Vegan';
            $tags[] = 'Dairy-Free';
        } elseif (preg_match('/(cheese|pasta|paneer|curry|vegetarian|egg)/i', $name)) {
            $tags[] = 'Vegetarian';
        }

        if (preg_match('/(bbq|brisket|ribs|smoke|steak|grill|chicken|pork|beef|keto)/i', $name)) {
            $tags[] = 'Keto';
            $tags[] = 'High-Protein';
            if (!preg_match('/pork|bacon|ham/i', $name)) {
                $tags[] = 'Halal';
            }
        }

        if (preg_match('/(corn|rice|gluten-free|gf|salad|smoke|bbq)/i', $name) && !preg_match('/bread|flour|bun|wheat|pasta|noodle/i', $name)) {
            $tags[] = 'Gluten-Free';
        }

        if (!preg_match('/peanut|almond|nut|cashew|walnut/i', $name)) {
            $tags[] = 'Nut-Free';
        }

        if (empty($tags)) {
            $tags = ['Farm-to-Table', 'Nut-Free'];
        }

        // Limit to 4 tags max
        $tags = array_slice(array_unique($tags), 0, 4);
        $jsonTags = json_encode($tags);
        $quota = rand(15, 30); // California MEHKO daily batch limit

        $tagStmt->execute([$jsonTags, $quota, $d['id']]);
        $taggedCount++;
    }
    $results[] = "Auto-tagged $taggedCount dishes with California dietary & MEHKO quota data";

    echo json_encode([
        'success' => true,
        'message' => 'California features migration completed successfully',
        'details' => $results
    ], JSON_PRETTY_PRINT);

} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage(),
        'details' => $results
    ], JSON_PRETTY_PRINT);
}
