<?php
// api/email_helper.php

function sendOrderNotificationEmail($toEmail, $recipientName, $subject, $heading, $subheading, $orderId, $kitchenName, $itemsHtml, $totalAmount, $detailsHtml = '') {
    if (empty($toEmail) || !filter_var($toEmail, FILTER_VALIDATE_EMAIL)) {
        return false;
    }

    $headers  = "MIME-Version: 1.0\r\n";
    $headers .= "Content-type: text/html; charset=UTF-8\r\n";
    $headers .= "From: GoChef Orders <orders@thegrubnextdoor.com>\r\n";
    $headers .= "Reply-To: support@thegrubnextdoor.com\r\n";
    $headers .= "Return-Path: orders@thegrubnextdoor.com\r\n";
    $headers .= "X-Mailer: PHP/" . phpversion() . "\r\n";
    $headers .= "X-Priority: 1 (Highest)\r\n";

    $year = date('Y');
    $message = "
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset='utf-8'>
      <title>" . htmlspecialchars($subject) . "</title>
    </head>
    <body style='margin:0; padding:0; background-color:#121318; font-family: -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, Helvetica, Arial, sans-serif; color:#ffffff;'>
      <table width='100%' border='0' cellspacing='0' cellpadding='0' style='background-color:#121318; padding: 40px 16px;'>
        <tr>
          <td align='center'>
            <table width='100%' border='0' cellspacing='0' cellpadding='0' style='max-width:540px; background-color:#1E1F28; border-radius:16px; border:1px solid #2D2F3E; overflow:hidden;'>
              <tr>
                <td style='padding: 28px 24px; text-align: center; border-bottom: 1px solid #2D2F3E; background: linear-gradient(180deg, #252836 0%, #1E1F28 100%);'>
                  <h1 style='margin: 0; font-size: 26px; font-weight: 800; color: #ffffff; letter-spacing: 1.5px;'>GO<span style='color:#EB1E8C;'>CHEF</span></h1>
                  <p style='margin: 6px 0 0 0; font-size: 13px; color: #A0A5B5; letter-spacing: 0.5px;'>THE GRUB NEXT DOOR</p>
                </td>
              </tr>
              <tr>
                <td style='padding: 28px 24px;'>
                  <h2 style='margin:0 0 8px 0; font-size:20px; font-weight:700; color:#ffffff;'>" . htmlspecialchars($heading) . "</h2>
                  <p style='margin:0 0 20px 0; font-size:14px; color:#A0A5B5; line-height: 1.5;'>" . htmlspecialchars($subheading) . "</p>

                  <div style='background-color:#161720; border-radius:12px; padding:16px; margin-bottom:20px; border: 1px solid #282A3A;'>
                    <table width='100%' border='0' cellspacing='0' cellpadding='0'>
                      <tr>
                        <td style='font-size:13px; color:#8E92A4;'>Order ID:</td>
                        <td align='right' style='font-size:14px; font-weight:bold; color:#EB1E8C; font-family:monospace;'>" . htmlspecialchars($orderId) . "</td>
                      </tr>
                      <tr>
                        <td style='font-size:13px; color:#8E92A4; padding-top:6px;'>Kitchen:</td>
                        <td align='right' style='font-size:13px; font-weight:bold; color:#ffffff; padding-top:6px;'>" . htmlspecialchars($kitchenName) . "</td>
                      </tr>
                      <tr>
                        <td style='font-size:13px; color:#8E92A4; padding-top:6px;'>Total:</td>
                        <td align='right' style='font-size:16px; font-weight:bold; color:#22C55E; padding-top:6px;'>$" . number_format((float)$totalAmount, 2) . "</td>
                      </tr>
                    </table>
                  </div>

                  " . ($detailsHtml ? "<div style='margin-bottom:20px;'>$detailsHtml</div>" : "") . "

                  <div style='margin-bottom:20px;'>
                    <p style='margin:0 0 8px 0; font-size:13px; font-weight:bold; color:#E0E2EC; text-transform:uppercase; letter-spacing:0.5px;'>Items Ordered:</p>
                    <div style='background-color:#161720; border-radius:10px; padding:12px; border:1px solid #282A3A;'>
                      $itemsHtml
                    </div>
                  </div>

                  <p style='margin:20px 0 0 0; font-size:12px; color:#8E92A4; line-height: 1.4;'>
                    You can track and manage orders anytime directly in the GoChef app.
                  </p>
                </td>
              </tr>
              <tr>
                <td style='padding: 16px 24px; background-color: #161720; text-align: center; border-top: 1px solid #2D2F3E;'>
                  <p style='margin:0; font-size:11px; color:#6B7280;'>&copy; $year GoChef. All rights reserved.</p>
                </td>
              </tr>
            </table>
          </td>
        </tr>
      </table>
    </body>
    </html>
    ";

    return @mail($toEmail, $subject, $message, $headers, "-f orders@thegrubnextdoor.com");
}

