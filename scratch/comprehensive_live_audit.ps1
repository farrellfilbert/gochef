# comprehensive_live_audit.ps1
$baseUrl = "https://thegrubnextdoor.com/api"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "   GOCHEF COMPREHENSIVE LIVE AUDIT" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

function Test-Endpoint($name, $url, $method = "GET", $body = $null) {
    try {
        if ($method -eq "POST") {
            $resp = Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json" -TimeoutSec 15
        } else {
            $resp = Invoke-RestMethod -Uri $url -Method Get -TimeoutSec 15
        }
        Write-Host " [PASS] $name" -ForegroundColor Green
        return $resp
    } catch {
        Write-Host " [FAIL] $name : $_" -ForegroundColor Red
        return $null
    }
}

# 1. Test Support Admin Endpoint
$adminResp = Test-Endpoint "1. Support Admin Endpoint" "$baseUrl/get_support_admin.php"
if ($adminResp -and $adminResp.success) {
    Write-Host "    -> Support Admin Name: $($adminResp.admin.name) (ID: $($adminResp.admin.id))" -ForegroundColor Gray
}

# 2. Test User Calories Endpoint (GET)
$calResp = Test-Endpoint "2. Calories Tracker (GET)" "$baseUrl/user_calories.php?user_id=1"
if ($calResp -and $calResp.success) {
    Write-Host "    -> Daily: $($calResp.daily_calories) / $($calResp.daily_goal) kcal, Weekly: $($calResp.weekly_calories) / $($calResp.weekly_goal) kcal" -ForegroundColor Gray
}

# 3. Test User Calories Goal Update (POST)
$goalBody = @{ user_id = 1; daily_goal = 2200 } | ConvertTo-Json
$goalUpdateResp = Test-Endpoint "3. Calories Target Goal (POST Update)" "$baseUrl/user_calories.php" "POST" $goalBody
if ($goalUpdateResp -and $goalUpdateResp.success) {
    Write-Host "    -> Daily Goal updated to $($goalUpdateResp.daily_goal) kcal, Weekly: $($goalUpdateResp.weekly_goal) kcal" -ForegroundColor Gray
}

# 4. Test Chat Inbox Endpoint
$inboxResp = Test-Endpoint "4. Chat Inbox Endpoint" "$baseUrl/chat_inbox.php?user_id=1&role=admin"
if ($inboxResp -and $inboxResp.success) {
    Write-Host "    -> Total inbox conversations: $($inboxResp.inbox.Count)" -ForegroundColor Gray
}

# 5. Test Chat Messages Endpoint
$msgResp = Test-Endpoint "5. Chat Message History" "$baseUrl/chat_messages.php?user1_id=1&user2_id=2"
if ($msgResp -and $msgResp.success) {
    Write-Host "    -> Chat message count: $($msgResp.messages.Count)" -ForegroundColor Gray
}

# 6. Test Search & Kitchens
$searchResp = Test-Endpoint "6. Search & Kitchens" "$baseUrl/search.php?q=burger&sort=price_asc"
if ($searchResp -and $searchResp.success) {
    Write-Host "    -> Matching dishes found: $($searchResp.dishes.Count)" -ForegroundColor Gray
}

# 7. Test Admin Chefs Endpoint
$chefsResp = Test-Endpoint "7. Admin Chef Approvals" "$baseUrl/admin_chefs.php?filter=all"
if ($chefsResp -and $chefsResp.success) {
    Write-Host "    -> Total chefs in system: $($chefsResp.chefs.Count)" -ForegroundColor Gray
}

# 8. Test Web Bundle Loading (flutter_bootstrap.js & main.dart.js)
try {
    $bootstrap = Invoke-WebRequest -Uri "https://thegrubnextdoor.com/flutter_bootstrap.js" -UseBasicParsing -TimeoutSec 15
    if ($bootstrap.StatusCode -eq 200) {
        Write-Host " [PASS] 8. Web App Bootstrap (HTTP 200 OK)" -ForegroundColor Green
    }
} catch {
    Write-Host " [FAIL] 8. Web App Bootstrap: $_" -ForegroundColor Red
}

try {
    $mainJs = Invoke-WebRequest -Uri "https://thegrubnextdoor.com/main.dart.js" -Method Head -UseBasicParsing -TimeoutSec 15
    if ($mainJs.StatusCode -eq 200) {
        Write-Host " [PASS] 9. Main Dart JS Bundle (HTTP 200 OK)" -ForegroundColor Green
    }
} catch {
    Write-Host " [FAIL] 9. Main Dart JS Bundle: $_" -ForegroundColor Red
}

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "          AUDIT COMPLETE" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
