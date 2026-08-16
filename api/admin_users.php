<?php
// admin_users.php - Admin User & Kitchen Moderation API
require_once 'db_connect.php';

header('Content-Type: application/json');

// Ensure 'status' column exists in users and kitchens
try {
    $pdo->exec("ALTER TABLE users ADD COLUMN status VARCHAR(20) NOT NULL DEFAULT 'active'");
} catch (Exception $e) {
    // Column may already exist
}

try {
    $pdo->exec("ALTER TABLE kitchens ADD COLUMN status VARCHAR(20) NOT NULL DEFAULT 'active'");
} catch (Exception $e) {
    // Column may already exist
}

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $type = $_GET['type'] ?? 'all'; // all, users, kitchens, suspended
    $search = trim($_GET['search'] ?? '');

    try {
        $sql = "
            SELECT 
                u.id,
                u.name,
                u.email,
                u.phone,
                u.role,
                COALESCE(u.status, 'active') as status,
                u.avatar,
                u.created_at,
                k.id as kitchen_id,
                k.name as kitchen_name,
                k.avatar as kitchen_avatar,
                k.is_verified as kitchen_verified,
                COALESCE(k.status, 'active') as kitchen_status
            FROM users u
            LEFT JOIN kitchens k ON k.user_id = u.id
            WHERE u.role != 'admin'
        ";

        $params = [];

        if ($type === 'users') {
            $sql .= " AND (u.role = 'user' AND k.id IS NULL)";
        } else if ($type === 'kitchens') {
            $sql .= " AND (u.role = 'chef' OR k.id IS NOT NULL)";
        } else if ($type === 'suspended') {
            $sql .= " AND (u.status = 'suspended' OR k.status = 'suspended')";
        }

        if (!empty($search)) {
            $sql .= " AND (u.name LIKE ? OR u.email LIKE ? OR u.phone LIKE ? OR k.name LIKE ?)";
            $searchTerm = "%$search%";
            $params[] = $searchTerm;
            $params[] = $searchTerm;
            $params[] = $searchTerm;
            $params[] = $searchTerm;
        }

        $sql .= " ORDER BY u.id DESC";

        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        $users = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode([
            'success' => true,
            'count' => count($users),
            'data' => $users
        ]);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['success' => false, 'error' => 'Database error: ' . $e->getMessage()]);
    }
    exit();
}

if ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
    $action = $input['action'] ?? '';
    $userId = $input['user_id'] ?? null;
    $kitchenId = $input['kitchen_id'] ?? null;
    $reason = $input['reason'] ?? 'Violation of Community Guidelines';

    if (!$userId && !$kitchenId) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'User ID or Kitchen ID required']);
        exit();
    }

    try {
        if ($action === 'suspend') {
            if ($userId) {
                // Suspend user
                $stmt = $pdo->prepare("UPDATE users SET status = 'suspended' WHERE id = ?");
                $stmt->execute([$userId]);

                // Also suspend any associated kitchen
                $kStmt = $pdo->prepare("UPDATE kitchens SET status = 'suspended' WHERE user_id = ?");
                $kStmt->execute([$userId]);

                // Send notification
                try {
                    $notif = $pdo->prepare("INSERT INTO notifications (user_id, title, message, type, is_read, created_at) VALUES (?, 'Account Suspended', ?, 'warning', 0, NOW())");
                    $notif->execute([$userId, "Your account has been suspended. Please contact admin at support@gochef.com"]);
                } catch (Exception $ne) {}
            } else if ($kitchenId) {
                // Suspend only kitchen
                $stmt = $pdo->prepare("UPDATE kitchens SET status = 'suspended' WHERE id = ?");
                $stmt->execute([$kitchenId]);
            }

            echo json_encode(['success' => true, 'message' => 'Account / Kitchen suspended successfully']);
        } else if ($action === 'unsuspend') {
            if ($userId) {
                // Unsuspend user
                $stmt = $pdo->prepare("UPDATE users SET status = 'active' WHERE id = ?");
                $stmt->execute([$userId]);

                // Also unsuspend associated kitchen
                $kStmt = $pdo->prepare("UPDATE kitchens SET status = 'active' WHERE user_id = ?");
                $kStmt->execute([$userId]);

                // Send notification
                try {
                    $notif = $pdo->prepare("INSERT INTO notifications (user_id, title, message, type, is_read, created_at) VALUES (?, 'Account Restored', 'Your account suspension has been lifted by Admin. You may continue using GoChef.', 'success', 0, NOW())");
                    $notif->execute([$userId]);
                } catch (Exception $ne) {}
            } else if ($kitchenId) {
                // Unsuspend kitchen
                $stmt = $pdo->prepare("UPDATE kitchens SET status = 'active' WHERE id = ?");
                $stmt->execute([$kitchenId]);
            }

            echo json_encode(['success' => true, 'message' => 'Account / Kitchen restored to active']);
        } else if ($action === 'delete') {
            // Disable foreign key checks for clean cascading deletion
            $pdo->exec("SET FOREIGN_KEY_CHECKS = 0;");

            try {
                if ($userId) {
                    // 1. Get all kitchens owned by this user
                    $kStmt = $pdo->prepare("SELECT id FROM kitchens WHERE user_id = ?");
                    $kStmt->execute([$userId]);
                    $kitchenIds = $kStmt->fetchAll(PDO::FETCH_COLUMN);

                    // Delete kitchen-related records if any
                    if (!empty($kitchenIds)) {
                        foreach ($kitchenIds as $kId) {
                            try { $pdo->prepare("DELETE FROM menu_addons WHERE menu_item_id IN (SELECT id FROM menu_items WHERE kitchen_id = ?)")->execute([$kId]); } catch (Exception $e) {}
                            try { $pdo->prepare("DELETE FROM menu_addon_categories WHERE menu_item_id IN (SELECT id FROM menu_items WHERE kitchen_id = ?)")->execute([$kId]); } catch (Exception $e) {}
                            try { $pdo->prepare("DELETE FROM menu_items WHERE kitchen_id = ?")->execute([$kId]); } catch (Exception $e) {}
                            try { $pdo->prepare("DELETE FROM order_items WHERE order_id IN (SELECT id FROM orders WHERE kitchen_id = ?)")->execute([$kId]); } catch (Exception $e) {}
                            try { $pdo->prepare("DELETE FROM orders WHERE kitchen_id = ?")->execute([$kId]); } catch (Exception $e) {}
                            try { $pdo->prepare("DELETE FROM reviews WHERE kitchen_id = ?")->execute([$kId]); } catch (Exception $e) {}
                            try { $pdo->prepare("DELETE FROM promotions WHERE kitchen_id = ?")->execute([$kId]); } catch (Exception $e) {}
                            try { $pdo->prepare("DELETE FROM kitchens WHERE id = ?")->execute([$kId]); } catch (Exception $e) {}
                        }
                    }

                    // 2. Delete user's personal cart items and addons
                    try { $pdo->prepare("DELETE FROM cart_item_addons WHERE cart_item_id IN (SELECT id FROM cart_items WHERE user_id = ?)")->execute([$userId]); } catch (Exception $e) {}
                    try { $pdo->prepare("DELETE FROM cart_items WHERE user_id = ?")->execute([$userId]); } catch (Exception $e) {}

                    // 3. Delete user's personal orders and items
                    try { $pdo->prepare("DELETE FROM order_items WHERE order_id IN (SELECT id FROM orders WHERE user_id = ?)")->execute([$userId]); } catch (Exception $e) {}
                    try { $pdo->prepare("DELETE FROM orders WHERE user_id = ?")->execute([$userId]); } catch (Exception $e) {}

                    // 4. Delete user's chats / messages
                    try { $pdo->prepare("DELETE FROM chat_messages WHERE sender_id = ? OR receiver_id = ?")->execute([$userId, $userId]); } catch (Exception $e) {}

                    // 5. Delete favorites, notifications, reviews, addresses
                    try { $pdo->prepare("DELETE FROM favorites WHERE user_id = ?")->execute([$userId]); } catch (Exception $e) {}
                    try { $pdo->prepare("DELETE FROM notifications WHERE user_id = ?")->execute([$userId]); } catch (Exception $e) {}
                    try { $pdo->prepare("DELETE FROM reviews WHERE user_id = ?")->execute([$userId]); } catch (Exception $e) {}
                    try { $pdo->prepare("DELETE FROM addresses WHERE user_id = ?")->execute([$userId]); } catch (Exception $e) {}

                    // 6. Delete user record
                    $stmt = $pdo->prepare("DELETE FROM users WHERE id = ?");
                    $stmt->execute([$userId]);
                } else if ($kitchenId) {
                    try { $pdo->prepare("DELETE FROM menu_addons WHERE menu_item_id IN (SELECT id FROM menu_items WHERE kitchen_id = ?)")->execute([$kitchenId]); } catch (Exception $e) {}
                    try { $pdo->prepare("DELETE FROM menu_addon_categories WHERE menu_item_id IN (SELECT id FROM menu_items WHERE kitchen_id = ?)")->execute([$kitchenId]); } catch (Exception $e) {}
                    try { $pdo->prepare("DELETE FROM menu_items WHERE kitchen_id = ?")->execute([$kitchenId]); } catch (Exception $e) {}
                    try { $pdo->prepare("DELETE FROM order_items WHERE order_id IN (SELECT id FROM orders WHERE kitchen_id = ?)")->execute([$kitchenId]); } catch (Exception $e) {}
                    try { $pdo->prepare("DELETE FROM orders WHERE kitchen_id = ?")->execute([$kitchenId]); } catch (Exception $e) {}
                    try { $pdo->prepare("DELETE FROM reviews WHERE kitchen_id = ?")->execute([$kitchenId]); } catch (Exception $e) {}
                    try { $pdo->prepare("DELETE FROM promotions WHERE kitchen_id = ?")->execute([$kitchenId]); } catch (Exception $e) {}
                    try { $pdo->prepare("DELETE FROM kitchens WHERE id = ?")->execute([$kitchenId]); } catch (Exception $e) {}
                }

                $pdo->exec("SET FOREIGN_KEY_CHECKS = 1;");
                echo json_encode(['success' => true, 'message' => 'Account / Kitchen permanently deleted']);
            } catch (Exception $de) {
                $pdo->exec("SET FOREIGN_KEY_CHECKS = 1;");
                throw $de;
            }
        } else {
            http_response_code(400);
            echo json_encode(['success' => false, 'error' => 'Invalid action']);
        }
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['success' => false, 'error' => 'Operation failed: ' . $e->getMessage()]);
    }
    exit();
}

http_response_code(405);
echo json_encode(['error' => 'Method not allowed']);
