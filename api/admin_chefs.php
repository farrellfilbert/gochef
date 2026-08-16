<?php
// admin_chefs.php - Admin endpoint to manage chef applications and verification
require_once 'db_connect.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $filter = isset($_GET['filter']) ? $_GET['filter'] : 'all'; // 'pending', 'approved', 'all'
    
    $sql = "SELECT k.id as kitchen_id, k.name as kitchen_name, k.description as kitchen_description, 
                   k.avatar as kitchen_avatar, k.cover_image as kitchen_cover, k.is_verified, 
                   COALESCE(k.status, 'active') as kitchen_status,
                   k.created_at, u.id as user_id, u.name as user_name, u.email as user_email, 
                   u.phone as user_phone, u.avatar as user_avatar, u.role as user_role,
                   COALESCE(u.status, 'active') as user_status
            FROM kitchens k
            JOIN users u ON k.user_id = u.id";
            
    if ($filter === 'pending') {
        $sql .= " WHERE k.is_verified = 0";
    } elseif ($filter === 'approved') {
        $sql .= " WHERE k.is_verified = 1";
    }
    
    $sql .= " ORDER BY k.created_at DESC";
    
    try {
        $stmt = $pdo->query($sql);
        $kitchens = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode(['success' => true, 'data' => $kitchens]);
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
    $kitchen_id = $input['kitchen_id'] ?? null;
    $user_id = $input['user_id'] ?? null;
    
    if (!$kitchen_id) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'kitchen_id is required']);
        exit;
    }
    
    try {
        if ($action === 'approve') {
            // Update kitchen verification status
            $stmt = $pdo->prepare("UPDATE kitchens SET is_verified = 1 WHERE id = ?");
            $stmt->execute([$kitchen_id]);
            
            // Get user_id if not provided
            if (!$user_id) {
                $uStmt = $pdo->prepare("SELECT user_id FROM kitchens WHERE id = ?");
                $uStmt->execute([$kitchen_id]);
                $user_id = $uStmt->fetchColumn();
            }
            
            if ($user_id) {
                // Update user role to chef
                $uUpdate = $pdo->prepare("UPDATE users SET role = 'chef' WHERE id = ?");
                $uUpdate->execute([$user_id]);
                
                // Send approval notification
                $notif = $pdo->prepare("INSERT INTO notifications (user_id, title, message, type, is_read) VALUES (?, ?, ?, 'chef_approval', 0)");
                $notif->execute([
                    $user_id,
                    'Chef Application Approved! 🎉',
                    'Congratulations! Your kitchen registration has been approved by the Admin. You can now access your Chef Dashboard and start publishing menus.'
                ]);
            }
            
            echo json_encode(['success' => true, 'message' => 'Chef application approved successfully']);
            
        } elseif ($action === 'reject') {
            $reason = $input['reason'] ?? 'Requirements not met';
            
            // Get user_id before deletion
            if (!$user_id) {
                $uStmt = $pdo->prepare("SELECT user_id FROM kitchens WHERE id = ?");
                $uStmt->execute([$kitchen_id]);
                $user_id = $uStmt->fetchColumn();
            }
            
            // Delete pending kitchen
            $del = $pdo->prepare("DELETE FROM kitchens WHERE id = ?");
            $del->execute([$kitchen_id]);
            
            if ($user_id) {
                // Ensure user role stays as user
                $uUpdate = $pdo->prepare("UPDATE users SET role = 'user' WHERE id = ?");
                $uUpdate->execute([$user_id]);
                
                // Send rejection notification
                $notif = $pdo->prepare("INSERT INTO notifications (user_id, title, message, type, is_read) VALUES (?, ?, ?, 'chef_rejection', 0)");
                $notif->execute([
                    $user_id,
                    'Chef Application Update',
                    "Your chef application could not be approved at this time. Reason: $reason. You may update your profile and apply again."
                ]);
            }
            
            echo json_encode(['success' => true, 'message' => 'Chef application rejected']);
            
        } else {
            http_response_code(400);
            echo json_encode(['success' => false, 'error' => 'Invalid action']);
        }
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['success' => false, 'error' => $e->getMessage()]);
    }
    exit;
}
?>
