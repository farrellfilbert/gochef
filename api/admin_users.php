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
                    $notif->execute([$userId, "Your account has been temporarily suspended by Admin. Reason: $reason. Contact support for help."]);
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
            if ($userId) {
                // Delete user and associated data
                $pdo->beginTransaction();

                // 1. Delete menu items of user's kitchens
                $pdo->prepare("DELETE FROM menu_items WHERE kitchen_id IN (SELECT id FROM kitchens WHERE user_id = ?)")->execute([$userId]);
                // 2. Delete kitchens
                $pdo->prepare("DELETE FROM kitchens WHERE user_id = ?")->execute([$userId]);
                // 3. Delete cart items
                $pdo->prepare("DELETE FROM cart WHERE user_id = ?")->execute([$userId]);
                // 4. Delete favorites
                $pdo->prepare("DELETE FROM favorites WHERE user_id = ?")->execute([$userId]);
                // 5. Delete notifications
                $pdo->prepare("DELETE FROM notifications WHERE user_id = ?")->execute([$userId]);
                // 6. Delete user
                $pdo->prepare("DELETE FROM users WHERE id = ?")->execute([$userId]);

                $pdo->commit();
            } else if ($kitchenId) {
                $pdo->beginTransaction();
                $pdo->prepare("DELETE FROM menu_items WHERE kitchen_id = ?")->execute([$kitchenId]);
                $pdo->prepare("DELETE FROM kitchens WHERE id = ?")->execute([$kitchenId]);
                $pdo->commit();
            }

            echo json_encode(['success' => true, 'message' => 'Account / Kitchen permanently deleted']);
        } else {
            http_response_code(400);
            echo json_encode(['success' => false, 'error' => 'Invalid action']);
        }
    } catch (PDOException $e) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        http_response_code(500);
        echo json_encode(['success' => false, 'error' => 'Operation failed: ' . $e->getMessage()]);
    }
    exit();
}

http_response_code(405);
echo json_encode(['error' => 'Method not allowed']);
