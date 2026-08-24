# test_chat_flow.ps1
$baseUrl = "https://thegrubnextdoor.com/api"

# 1. Send support message from Foodie (ID: 51) to Admin (ID: 22)
$body = @{
    sender_id = 51
    receiver_id = 22
    message = "Halo admin GoChef, saya ingin bertanya promo voucher hari ini!"
} | ConvertTo-Json

$sendResp = Invoke-RestMethod -Uri "$baseUrl/chat_send.php" -Method Post -Body $body -ContentType "application/json"
Write-Host "Send Foodie Message to Admin Result:" ($sendResp | ConvertTo-Json)

# 2. Admin replies back to Foodie (ID: 51)
$replyBody = @{
    sender_id = 22
    receiver_id = 51
    message = "Halo! Promo voucher 10% Off dan Free Delivery sudah aktif di Rewards Gallery ya!"
} | ConvertTo-Json

$replyResp = Invoke-RestMethod -Uri "$baseUrl/chat_send.php" -Method Post -Body $replyBody -ContentType "application/json"
Write-Host "Admin Reply to Foodie Result:" ($replyResp | ConvertTo-Json)

# 3. Fetch message thread
$msgResp = Invoke-RestMethod -Uri "$baseUrl/chat_messages.php?user1_id=51&user2_id=22"
Write-Host "Total Messages in Support Thread:" $msgResp.messages.Count

# 4. Fetch Admin Support Inbox
$inboxResp = Invoke-RestMethod -Uri "$baseUrl/chat_inbox.php?user_id=22&role=admin"
Write-Host "Admin Support Inbox Conversations:" $inboxResp.inbox.Count
foreach ($item in $inboxResp.inbox) {
    Write-Host "  - User: $($item.name) | Role: $($item.role) | Last Msg: $($item.last_message)"
}
