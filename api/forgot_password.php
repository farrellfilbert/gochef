<?php
// forgot_password.php - GoChef Password Reset API via Email OTP

header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Method not allowed']);
    exit();
}

require_once 'db_connect.php';

// Ensure password_resets table exists
try {
    $pdo->exec("CREATE TABLE IF NOT EXISTS password_resets (
        id INT AUTO_INCREMENT PRIMARY KEY,
        email VARCHAR(255) NOT NULL,
        otp_code VARCHAR(6) NOT NULL,
        expires_at DATETIME NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        INDEX (email),
        INDEX (otp_code)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");
} catch (PDOException $e) {
    // Ignore if already exists or permission issues
}

$input = json_decode(file_get_contents('php://input'), true);
if (!$input) {
    $input = $_POST;
}

$action = $input['action'] ?? 'send_otp';
$email = trim(strtolower($input['email'] ?? ''));

if (empty($email) || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Please provide a valid email address']);
    exit();
}

// ─────────────────────────────────────────────────────────────
// ACTION: SEND OTP
// ─────────────────────────────────────────────────────────────
if ($action === 'send_otp') {
    try {
        // 1. Verify user exists
        $stmt = $pdo->prepare("SELECT id, name, email FROM users WHERE LOWER(email) = ? LIMIT 1");
        $stmt->execute([$email]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$user) {
            http_response_code(404);
            echo json_encode(['success' => false, 'error' => 'Account with this email address was not found']);
            exit();
        }

        $userName = !empty($user['name']) ? $user['name'] : 'Valued Customer';

        // 2. Generate 6-digit OTP
        $otp = sprintf("%06d", mt_rand(100000, 999999));
        $expiresAt = date('Y-m-d H:i:s', strtotime('+15 minutes'));

        // 3. Clear old OTPs for this email and save new OTP
        $del = $pdo->prepare("DELETE FROM password_resets WHERE email = ?");
        $del->execute([$email]);

        $ins = $pdo->prepare("INSERT INTO password_resets (email, otp_code, expires_at) VALUES (?, ?, ?)");
        $ins->execute([$email, $otp, $expiresAt]);

        // 4. Send Email via PHP mail()
        $to = $email;
        $subject = "GoChef - Password Reset Code: $otp";

        $headers  = "MIME-Version: 1.0\r\n";
        $headers .= "Content-type: text/html; charset=UTF-8\r\n";
        $headers .= "From: GoChef Support <support@thegrubnextdoor.com>\r\n";
        $headers .= "Reply-To: support@thegrubnextdoor.com\r\n";
        $headers .= "Return-Path: support@thegrubnextdoor.com\r\n";
        $headers .= "X-Mailer: PHP/" . phpversion() . "\r\n";
        $headers .= "X-Priority: 1 (Highest)\r\n";

        $message = "
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset='utf-8'>
          <title>Reset Password</title>
        </head>
        <body style='margin:0; padding:0; background-color:#121318; font-family: -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, Helvetica, Arial, sans-serif; color:#ffffff;'>
          <table width='100%' border='0' cellspacing='0' cellpadding='0' style='background-color:#121318; padding: 40px 20px;'>
            <tr>
              <td align='center'>
                <table width='100%' max-width='500' border='0' cellspacing='0' cellpadding='0' style='max-width:500px; background-color:#1E1F28; border-radius:16px; border:1px solid #2D2F3E; overflow:hidden;'>
                  <tr>
                    <td style='padding: 30px; text-align: center; border-bottom: 1px solid #2D2F3E;'>
                      <h1 style='margin: 0; font-size: 26px; font-weight: 800; color: #ffffff; letter-spacing: 1px;'>GO<span style='color:#EB1E8C;'>CHEF</span></h1>
                      <p style='margin: 6px 0 0 0; font-size: 13px; color: #A0A5B5;'>Password Reset Verification</p>
                    </td>
                  </tr>
                  <tr>
                    <td style='padding: 30px;'>
                      <p style='margin:0 0 16px 0; font-size:15px; color:#E0E2EC; line-height: 1.5;'>
                        Hello <strong>" . htmlspecialchars($userName) . "</strong>,
                      </p>
                      <p style='margin:0 0 24px 0; font-size:14px; color:#A0A5B5; line-height: 1.5;'>
                        We received a request to reset the password for your GoChef account. Use the 6-digit verification code below to proceed:
                      </p>
                      
                      <div style='background: linear-gradient(135deg, rgba(235,30,140,0.15), rgba(235,30,140,0.05)); border: 2px dashed #EB1E8C; border-radius: 12px; padding: 20px; text-align: center; margin-bottom: 24px;'>
                        <span style='font-family: monospace; font-size: 36px; font-weight: 900; letter-spacing: 10px; color: #ffffff; text-shadow: 0 0 10px rgba(235,30,140,0.5);'>
                          $otp
                        </span>
                      </div>
                      
                      <p style='margin:0 0 8px 0; font-size:13px; color:#A0A5B5;'>
                        • This code is valid for <strong>15 minutes</strong>.<br>
                        • If you did not request this password reset, please ignore this email.
                      </p>
                    </td>
                  </tr>
                  <tr>
                    <td style='padding: 20px 30px; background-color: #161720; text-align: center; border-top: 1px solid #2D2F3E;'>
                      <p style='margin:0; font-size:12px; color:#6B7280;'>&copy; " . date('Y') . " GoChef. All rights reserved.</p>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>
          </table>
        </body>
        </html>
        ";

        // Execute mail sending with envelope sender flag -f
        $mailSent = @mail($to, $subject, $message, $headers, "-f support@thegrubnextdoor.com");

        echo json_encode([
            'success' => true,
            'message' => 'Verification OTP has been sent to your email address. Please check your Inbox or Spam folder.',
            'expires_in_minutes' => 15,
            'mail_dispatched' => (bool)$mailSent,
            'otp_code' => $otp // Included so you can verify immediately during development/testing
        ]);
        exit();

    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['success' => false, 'error' => 'Database error: ' . $e->getMessage()]);
        exit();
    }
}

// ─────────────────────────────────────────────────────────────
// ACTION: VERIFY OTP
// ─────────────────────────────────────────────────────────────
else if ($action === 'verify_otp') {
    $otp = trim($input['otp'] ?? '');

    if (empty($otp) || strlen($otp) !== 6) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'Please provide a valid 6-digit OTP code']);
        exit();
    }

    try {
        $stmt = $pdo->prepare("SELECT * FROM password_resets WHERE email = ? AND otp_code = ? AND expires_at > NOW() ORDER BY id DESC LIMIT 1");
        $stmt->execute([$email, $otp]);
        $resetRow = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($resetRow) {
            echo json_encode([
                'success' => true,
                'message' => 'OTP verified successfully'
            ]);
            exit();
        } else {
            http_response_code(400);
            echo json_encode(['success' => false, 'error' => 'Invalid or expired verification code']);
            exit();
        }
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['success' => false, 'error' => 'Database error']);
        exit();
    }
}

// ─────────────────────────────────────────────────────────────
// ACTION: RESET PASSWORD
// ─────────────────────────────────────────────────────────────
else if ($action === 'reset_password') {
    $otp = trim($input['otp'] ?? '');
    $newPassword = $input['new_password'] ?? '';

    if (empty($otp) || strlen($otp) !== 6) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'Please provide a valid 6-digit OTP code']);
        exit();
    }

    if (empty($newPassword) || strlen($newPassword) < 6) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'Password must be at least 6 characters']);
        exit();
    }

    try {
        // Verify OTP again
        $stmt = $pdo->prepare("SELECT * FROM password_resets WHERE email = ? AND otp_code = ? AND expires_at > NOW() ORDER BY id DESC LIMIT 1");
        $stmt->execute([$email, $otp]);
        $resetRow = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$resetRow) {
            http_response_code(400);
            echo json_encode(['success' => false, 'error' => 'Invalid or expired verification code. Please request a new OTP.']);
            exit();
        }

        // Hash new password
        $passwordHash = password_hash($newPassword, PASSWORD_DEFAULT);

        // Update user password
        $upd = $pdo->prepare("UPDATE users SET password = ? WHERE LOWER(email) = ?");
        $upd->execute([$passwordHash, $email]);

        // Invalidate OTPs
        $del = $pdo->prepare("DELETE FROM password_resets WHERE email = ?");
        $del->execute([$email]);

        echo json_encode([
            'success' => true,
            'message' => 'Your password has been reset successfully. Please login with your new password.'
        ]);
        exit();

    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['success' => false, 'error' => 'Failed to update password']);
        exit();
    }
}

else {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Invalid action']);
    exit();
}
