<?php
// admin_promotions.php - Admin endpoint to manage promo banners and vouchers
require_once 'db_connect.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    try {
        $stmt = $pdo->query("SELECT * FROM promotions ORDER BY created_at DESC");
        $promos = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode(['success' => true, 'data' => $promos]);
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
    
    try {
        if ($action === 'create') {
            $title = $input['title'] ?? '';
            $subtitle = $input['subtitle'] ?? '';
            $image = $input['image'] ?? '';
            $discount_percent = intval($input['discount_percent'] ?? 0);
            $code = strtoupper(trim($input['code'] ?? ''));
            $is_active = isset($input['is_active']) ? intval($input['is_active']) : 1;
            
            if (empty($title)) {
                http_response_code(400);
                echo json_encode(['success' => false, 'error' => 'Title is required']);
                exit;
            }
            
            $stmt = $pdo->prepare("INSERT INTO promotions (title, subtitle, image, discount_percent, code, is_active) VALUES (?, ?, ?, ?, ?, ?)");
            $stmt->execute([$title, $subtitle, $image, $discount_percent, $code, $is_active]);
            $promo_id = $pdo->lastInsertId();
            
            echo json_encode([
                'success' => true, 
                'message' => 'Promotion banner created successfully',
                'id' => $promo_id
            ]);
            
        } elseif ($action === 'toggle') {
            $promo_id = $input['id'] ?? null;
            $is_active = isset($input['is_active']) ? intval($input['is_active']) : 1;
            
            if (!$promo_id) {
                http_response_code(400);
                echo json_encode(['success' => false, 'error' => 'id is required']);
                exit;
            }
            
            $stmt = $pdo->prepare("UPDATE promotions SET is_active = ? WHERE id = ?");
            $stmt->execute([$is_active, $promo_id]);
            
            echo json_encode(['success' => true, 'message' => 'Promotion status updated']);
            
        } elseif ($action === 'delete') {
            $promo_id = $input['id'] ?? null;
            
            if (!$promo_id) {
                http_response_code(400);
                echo json_encode(['success' => false, 'error' => 'id is required']);
                exit;
            }
            
            $stmt = $pdo->prepare("DELETE FROM promotions WHERE id = ?");
            $stmt->execute([$promo_id]);
            
            echo json_encode(['success' => true, 'message' => 'Promotion deleted']);
            
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
