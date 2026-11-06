$baseUrl = "https://thegrubnextdoor.com/api"
$passCount = 0
$failCount = 0
$testResults = @()

function Run-Test {
    param (
        [string]$TestId,
        [string]$Description,
        [string]$Url,
        [string]$Method = "GET",
        [hashtable]$Body = $null,
        [scriptblock]$Validator
    )

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        if ($Method -eq "GET") {
            $response = Invoke-RestMethod -Uri $Url -Method Get -TimeoutSec 10
        } elseif ($Method -eq "POST_JSON") {
            $jsonBody = $Body | ConvertTo-Json
            $response = Invoke-RestMethod -Uri $Url -Method Post -Body $jsonBody -ContentType "application/json" -TimeoutSec 10
        } else {
            $response = Invoke-RestMethod -Uri $Url -Method Post -Body $Body -TimeoutSec 10
        }
        $sw.Stop()

        $isValid = & $Validator $response
        if ($isValid) {
            $script:passCount++
            $result = [PSCustomObject]@{
                ID = $TestId
                Status = "PASS"
                Duration = "$($sw.ElapsedMilliseconds)ms"
                Description = $Description
                Details = "OK"
            }
        } else {
            $script:failCount++
            $result = [PSCustomObject]@{
                ID = $TestId
                Status = "FAIL"
                Duration = "$($sw.ElapsedMilliseconds)ms"
                Description = $Description
                Details = "Validation failed on response payload"
            }
        }
    } catch {
        $sw.Stop()
        $script:failCount++
        $result = [PSCustomObject]@{
            ID = $TestId
            Status = "FAIL"
            Duration = "$($sw.ElapsedMilliseconds)ms"
            Description = $Description
            Details = $_.Exception.Message
        }
    }
    $script:testResults += $result
    Write-Host "[$($result.Status)] $TestId - $Description ($($result.Duration))"
}

Write-Host "======================================================"
Write-Host "STARTING COMPREHENSIVE LIVE API TEST SUITE"
Write-Host "Target Server: thegrubnextdoor.com"
Write-Host "======================================================"

# Test 1: User Profile Retrieval
Run-Test -TestId "API-01" -Description "Fetch User Profile (user_id=1)" `
    -Url "$baseUrl/profile.php?user_id=1" `
    -Validator { param($r) $r.success -eq $true -and $r.data.id -eq "1" -and $r.data.push_notifications -ne $null }

# Test 2: User Profile Update Preferences
Run-Test -TestId "API-02" -Description "Update Notification Preferences (push=1, email=1, sms=0)" `
    -Url "$baseUrl/update_profile.php" -Method "POST" `
    -Body @{ user_id = "1"; push_notifications = "1"; email_notifications = "1"; sms_alerts = "0" } `
    -Validator { param($r) $r.success -eq $true }

# Test 3: Kitchens Listing
Run-Test -TestId "API-03" -Description "Fetch All Active Kitchens" `
    -Url "$baseUrl/kitchens.php" `
    -Validator { param($r) $r.success -eq $true -and $r.data.Count -gt 0 }

# Test 4: Coronita Kitchen Detail
Run-Test -TestId "API-04" -Description "Fetch Coronita Detail (id=28)" `
    -Url "$baseUrl/kitchen_detail.php?id=28" `
    -Validator { param($r) $r.success -eq $true -and $r.data.name -eq "Coronita" -and $r.data.business_hours -ne $null }

# Test 5: Menu Items for Kitchen 28
Run-Test -TestId "API-05" -Description "Fetch Menu Items for Kitchen 28" `
    -Url "$baseUrl/menu_items.php?kitchen_id=28" `
    -Validator { param($r) $r.success -eq $true -and $r.data.Count -gt 0 }

# Test 6: Categories Listing
Run-Test -TestId "API-06" -Description "Fetch Food Categories" `
    -Url "$baseUrl/categories.php" `
    -Validator { param($r) $r.success -eq $true -and $r.data.Count -gt 0 }

# Test 7: Active Home Promo Banners
Run-Test -TestId "API-07" -Description "Fetch Active Promo Banners with Sort Order" `
    -Url "$baseUrl/promotions.php" `
    -Validator { param($r) $r.success -eq $true -and $r.data.Count -gt 0 }

# Test 8: Admin Platform Financial Statistics
Run-Test -TestId "API-08" -Description "Fetch Admin Platform Stats & Earnings" `
    -Url "$baseUrl/admin_stats.php" `
    -Validator { param($r) $r.success -eq $true -and $r.data.completed_volume -gt 0 -and $r.data.kitchens.Count -gt 0 }

# Test 9: Admin Promotions Management
Run-Test -TestId "API-09" -Description "Fetch Admin Promo Banners" `
    -Url "$baseUrl/admin_promotions.php" `
    -Validator { param($r) $r.success -eq $true }

# Test 10: Admin Chef Applications
Run-Test -TestId "API-10" -Description "Fetch Chef Applications" `
    -Url "$baseUrl/admin_chefs.php?filter=all" `
    -Validator { param($r) $r.success -eq $true }

# Test 11: Admin Users Roster
Run-Test -TestId "API-11" -Description "Fetch Admin Users Roster" `
    -Url "$baseUrl/admin_users.php?type=all" `
    -Validator { param($r) $r.success -eq $true }

# Test 12: Customer Order History
Run-Test -TestId "API-12" -Description "Fetch Customer Order History (user_id=1)" `
    -Url "$baseUrl/orders.php?user_id=1" `
    -Validator { param($r) $r.success -eq $true }

# Test 13: Chef Orders Feed
Run-Test -TestId "API-13" -Description "Fetch Chef Orders Feed (kitchen_id=28)" `
    -Url "$baseUrl/orders.php?kitchen_id=28&for_chef=true" `
    -Validator { param($r) $r.success -eq $true }

# Test 14: Saved Addresses
Run-Test -TestId "API-14" -Description "Fetch Saved Addresses (user_id=1)" `
    -Url "$baseUrl/addresses.php?user_id=1" `
    -Validator { param($r) $r.success -eq $true }

# Test 15: Customer Inbox
Run-Test -TestId "API-15" -Description "Fetch Customer Chat Inbox" `
    -Url "$baseUrl/chat_inbox.php?user_id=1" `
    -Validator { param($r) $r.success -eq $true }

# Test 16: Admin Live Support Desk Inbox
Run-Test -TestId "API-16" -Description "Fetch Admin Support Desk Inbox" `
    -Url "$baseUrl/chat_inbox.php?is_support_desk=true" `
    -Validator { param($r) $r.success -eq $true }

# Test 17: Unread Notifications & Message Badges
Run-Test -TestId "API-17" -Description "Fetch Unread Counts (user_id=1)" `
    -Url "$baseUrl/unread_counts.php?user_id=1" `
    -Validator { param($r) $r.success -eq $true }

# Test 18: Kitchen Customer Reviews
Run-Test -TestId "API-18" -Description "Fetch Reviews for Kitchen 28" `
    -Url "$baseUrl/reviews.php?kitchen_id=28" `
    -Validator { param($r) $r.success -eq $true }

# Test 19: Food Search Engine
Run-Test -TestId "API-19" -Description "Search for 'burger' Dishes & Kitchens" `
    -Url "$baseUrl/search.php?query=burger" `
    -Validator { param($r) $r.success -eq $true }

# Test 20: User Favorites
Run-Test -TestId "API-20" -Description "Fetch User Favorites" `
    -Url "$baseUrl/favorites.php?user_id=1" `
    -Validator { param($r) $r.success -eq $true }

# Test 21: Reorder Promo Banners
Run-Test -TestId "API-21" -Description "Reorder Promo Banners (admin_promotions.php)" `
    -Url "$baseUrl/admin_promotions.php" -Method "POST_JSON" `
    -Body @{ action = "reorder"; order = @(16, 7, 8) } `
    -Validator { param($r) $r.success -eq $true }

# Test 22: Add Delivery Address
Run-Test -TestId "API-22" -Description "Add Saved Delivery Address (addresses.php)" `
    -Url "$baseUrl/addresses.php" -Method "POST_JSON" `
    -Body @{ user_id = 1; label = "Test Suite Loc"; address = "Location (34.14580, -118.39650)"; is_default = 0 } `
    -Validator { param($r) $r.success -eq $true -and $r.id -gt 0 }

Write-Host "======================================================"
Write-Host "TEST SUITE COMPLETE"
Write-Host "Total Passed: $passCount / $($passCount + $failCount)"
Write-Host "Total Failed: $failCount"
Write-Host "======================================================"

