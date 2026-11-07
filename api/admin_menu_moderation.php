<?php
// admin_menu_moderation.php - Admin endpoint to inspect, approve, and moderate food photos & dishes
require_once 'db_connect.php';

// Safe column migrations
try { $pdo->exec("ALTER TABLE menu_items ADD COLUMN status VARCHAR(30) DEFAULT 'approved'"); } catch (Exception $e) {}
try { $pdo->exec("ALTER TABLE menu_items ADD COLUMN rejection_reason TEXT DEFAULT NULL"); } catch (Exception $e) {}
try { $pdo->exec("ALTER TABLE menu_items ADD COLUMN approved_at TIMESTAMP NULL DEFAULT NULL"); } catch (Exception $e) {}
try { $pdo->exec("ALTER TABLE kitchens ADD COLUMN trusted_chef TINYINT(1) DEFAULT 0"); } catch (Exception $e) {}
try { $pdo->exec("ALTER TABLE kitchens ADD COLUMN approved_menus_count INT DEFAULT 0"); } catch (Exception $e) {}

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $status = isset($_GET['status']) ? trim($_GET['status']) : 'pending_review';
    $search = isset($_GET['q']) ? trim($_GET['q']) : '';

    // Calculate counts
    $countsQuery = $pdo->query("
        SELECT 
            SUM(CASE WHEN COALESCE(status, 'approved') = 'pending_review' THEN 1 ELSE 0 END) as pending_count,
            SUM(CASE WHEN COALESCE(status, 'approved') = 'approved' THEN 1 ELSE 0 END) as approved_count,
            SUM(CASE WHEN COALESCE(status, 'approved') = 'rejected' THEN 1 ELSE 0 END) as rejected_count,
            COUNT(id) as all_count
        FROM menu_items
    ");
    $counts = $countsQuery->fetch(PDO::FETCH_ASSOC) ?: [
        'pending_count' => 0,
        'approved_count' => 0,
        'rejected_count' => 0,
        'all_count' => 0
    ];

    $sql = "
        SELECT mi.id, mi.name, mi.description, mi.price, mi.image, mi.calories, 
               COALESCE(mi.prep_time, '15-20 min') as prep_time,
               COALESCE(mi.status, 'approved') as status,
               mi.rejection_reason, mi.created_at, mi.approved_at,
               c.name as category_name,
               k.id as kitchen_id, k.name as kitchen_name, k.avatar as kitchen_avatar,
               COALESCE(k.trusted_chef, 0) as trusted_chef,
               COALESCE(k.approved_menus_count, 0) as approved_menus_count,
               u.id as chef_user_id, u.name as chef_name, u.email as chef_email, u.phone as chef_phone
        FROM menu_items mi
        JOIN kitchens k ON mi.kitchen_id = k.id
        LEFT JOIN users u ON k.user_id = u.id
        LEFT JOIN categories c ON mi.category_id = c.id
        WHERE 1=1
    ";

    $params = [];

    if ($status === 'pending_review') {
        $sql .= " AND COALESCE(mi.status, 'approved') = 'pending_review'";
    } elseif ($status === 'approved') {
        $sql .= " AND COALESCE(mi.status, 'approved') = 'approved'";
    } elseif ($status === 'rejected') {
        $sql .= " AND COALESCE(mi.status, 'approved') = 'rejected'";
    }

    if (!empty($search)) {
        $sql .= " AND (mi.name LIKE ? OR k.name LIKE ? OR u.name LIKE ?)";
        $params[] = "%$search%";
        $params[] = "%$search%";
        $params[] = "%$search%";
    }

    $sql .= " ORDER BY mi.id DESC";

    try {
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        $dishes = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode([
            'success' => true,
            'counts' => [
                'pending_count' => (int)($counts['pending_count'] ?? 0),
                'approved_count' => (int)($counts['approved_count'] ?? 0),
                'rejected_count' => (int)($counts['rejected_count'] ?? 0),
                'all_count' => (int)($counts['all_count'] ?? 0),
            ],
            'data' => $dishes
        ]);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['success' => false, 'error' => $e->getMessage()]);
    }
    exit;
}

if ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    if (!$input) {
        $input = $_POST;
    }

    $action = $input['action'] ?? '';
    $menu_item_id = intval($input['menu_item_id'] ?? $input['id'] ?? 0);
    $kitchen_id = intval($input['kitchen_id'] ?? 0);

    try {
        // APPROVE DISH
        if ($action === 'approve') {
            if (!$menu_item_id) {
                echo json_encode(['success' => false, 'error' => 'menu_item_id is required']);
                exit;
            }

            // Get dish details & chef info
            $infoStmt = $pdo->prepare("
                SELECT mi.name, mi.kitchen_id, k.user_id as chef_user_id, k.name as kitchen_name, COALESCE(k.approved_menus_count, 0) as approved_menus_count
                FROM menu_items mi
                JOIN kitchens k ON mi.kitchen_id = k.id
                WHERE mi.id = ?
            ");
            $infoStmt->execute([$menu_item_id]);
            $itemInfo = $infoStmt->fetch(PDO::FETCH_ASSOC);

            if (!$itemInfo) {
                echo json_encode(['success' => false, 'error' => 'Dish not found']);
                exit;
            }

            // Update dish status to approved
            $update = $pdo->prepare("UPDATE menu_items SET status = 'approved', rejection_reason = NULL, approved_at = NOW(), is_available = 1 WHERE id = ?");
            $update->execute([$menu_item_id]);

            // Increment kitchen's approved menus count
            $newCount = ((int)$itemInfo['approved_menus_count']) + 1;
            $isNowTrusted = ($newCount >= 3) ? 1 : 0;

            $kUpdate = $pdo->prepare("UPDATE kitchens SET approved_menus_count = ?, trusted_chef = GREATEST(COALESCE(trusted_chef, 0), ?) WHERE id = ?");
            $kUpdate->execute([$newCount, $isNowTrusted, $itemInfo['kitchen_id']]);

            // Notify the chef
            $chefUserId = $itemInfo['chef_user_id'];
            if ($chefUserId) {
                try {
                    $notif = $pdo->prepare("INSERT INTO notifications (user_id, title, message, type, is_read) VALUES (?, ?, ?, 'menu_approved', 0)");
                    $dishTitle = $itemInfo['name'];
                    $msg = "Congratulations! Your dish '$dishTitle' has been approved by the GoChef Admin team and is now live for foodies to order.";
                    if ($isNowTrusted) {
                        $msg .= " You have reached 3+ approved dishes and are now recognized as a Trusted Chef! Future dishes will be published automatically.";
                    }
                    $notif->execute([$chefUserId, "Dish Approved! 🍽️", $msg]);
                } catch (Exception $ne) {}
            }

            echo json_encode([
                'success' => true,
                'message' => 'Dish photo approved and published successfully!',
                'is_trusted' => (bool)$isNowTrusted
            ]);
            exit;

        // REJECT DISH
        } elseif ($action === 'reject') {
            if (!$menu_item_id) {
                echo json_encode(['success' => false, 'error' => 'menu_item_id is required']);
                exit;
            }

            $reason = trim($input['reason'] ?? 'Photo does not meet quality guidelines (blurry, poor lighting, or non-food).');

            // Get dish info
            $infoStmt = $pdo->prepare("
                SELECT mi.name, mi.kitchen_id, k.user_id as chef_user_id
                FROM menu_items mi
                JOIN kitchens k ON mi.kitchen_id = k.id
                WHERE mi.id = ?
            ");
            $infoStmt->execute([$menu_item_id]);
            $itemInfo = $infoStmt->fetch(PDO::FETCH_ASSOC);

            // Update dish status to rejected
            $update = $pdo->prepare("UPDATE menu_items SET status = 'rejected', rejection_reason = ? WHERE id = ?");
            $update->execute([$reason, $menu_item_id]);

            // Notify the chef
            if ($itemInfo && $itemInfo['chef_user_id']) {
                try {
                    $notif = $pdo->prepare("INSERT INTO notifications (user_id, title, message, type, is_read) VALUES (?, ?, ?, 'menu_rejected', 0)");
                    $dishTitle = $itemInfo['name'];
                    $msg = "Your dish '$dishTitle' requires photo updates before it can be published. Admin Note: \"$reason\". Please edit the dish in your Menu Management to update the photo.";
                    $notif->execute([$itemInfo['chef_user_id'], "Dish Photo Needs Update 📷", $msg]);
                } catch (Exception $ne) {}
            }

            echo json_encode([
                'success' => true,
                'message' => 'Dish rejected with feedback provided to chef.'
            ]);
            exit;

        // GRANT TRUSTED CHEF STATUS
        } elseif ($action === 'trust_chef') {
            if (!$kitchen_id) {
                echo json_encode(['success' => false, 'error' => 'kitchen_id is required']);
                exit;
            }

            $stmt = $pdo->prepare("UPDATE kitchens SET trusted_chef = 1 WHERE id = ?");
            $stmt->execute([$kitchen_id]);

            // Also auto-approve all currently pending dishes for this kitchen
            $autoApprove = $pdo->prepare("UPDATE menu_items SET status = 'approved', rejection_reason = NULL, approved_at = NOW() WHERE kitchen_id = ? AND status = 'pending_review'");
            $autoApprove->execute([$kitchen_id]);

            // Notify chef
            $uStmt = $pdo->prepare("SELECT user_id, name FROM kitchens WHERE id = ?");
            $uStmt->execute([$kitchen_id]);
            $kRow = $uStmt->fetch(PDO::FETCH_ASSOC);
            if ($kRow && $kRow['user_id']) {
                try {
                    $notif = $pdo->prepare("INSERT INTO notifications (user_id, title, message, type, is_read) VALUES (?, ?, ?, 'trusted_status', 0)");
                    $notif->execute([
                        $kRow['user_id'],
                        "Trusted Chef Status Granted! 🌟",
                        "Great news! Your kitchen has been granted Trusted Chef status by the GoChef Admin team. All your dishes will now be published automatically."
                    ]);
                } catch (Exception $ne) {}
            }

            echo json_encode([
                'success' => true,
                'message' => 'Kitchen marked as Trusted Chef. All pending dishes approved!'
            ]);
            exit;

        } else {
            echo json_encode(['success' => false, 'error' => 'Invalid action']);
            exit;
        }

    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['success' => false, 'error' => $e->getMessage()]);
    }
}
?>

