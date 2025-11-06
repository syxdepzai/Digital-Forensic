<#
gt_create.ps1
Tạo dữ liệu "Ground Truth" cho emulator:
 - Bật WAL cho DB (contacts, calllog, sms)
 - Tạo CallLog & SMS mẫu
 - Đẩy ảnh JPEG vào /storage/emulated/0/Pictures/
 - Quét MediaStore để ghi nhận ảnh
Usage:
   .\gt_create.ps1
   .\gt_create.ps1 -Serial emulator-5554 -Calls 5 -Sms 2 -Images 5
#>

param(
    [string]$Serial = "",
    [int]$Calls = 5,
    [int]$Sms = 2,
    [int]$Images = 5
)

function _log($msg) {
    Write-Host ("[GT] " + (Get-Date -Format "HH:mm:ss") + " " + $msg)
}

# Tim adb tu PATH
$adbCmd = Get-Command "adb" -ErrorAction SilentlyContinue
if (-not $adbCmd) {
    Write-Error "adb khong duoc tim thay trong PATH."
    exit 1
}
$ADB = "adb"
if ($Serial -ne "") { $ADB = "$ADB -s $Serial" }

# Kiem tra thiet bi
$state = & $ADB get-state 2>$null
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrEmpty($state)) {
    Write-Error "Khong co thiet bi ket noi hoac adb khong truy cap duoc."
    exit 1
}
$deviceSerial = (& $ADB get-serialno).Trim()
_log "Thiet bi: $deviceSerial ($state)"

# Root & remount
_log "Bat adb root va remount..."
& $ADB root | Out-Null
Start-Sleep -Seconds 1
try {
    & $ADB remount | Out-Null
} catch {
    _log "Remount loi, bo qua (AVD co the read-only)"
}
Start-Sleep -Seconds 1

# Bat WAL & ep sinh file WAL
$targetDBs = @(
    "/data/data/com.android.providers.contacts/databases/contacts2.db",
    "/data/data/com.android.providers.contacts/databases/calllog.db",
    "/data/data/com.android.providers.telephony/databases/mmssms.db"
)
_log "Bat WAL va ghi transaction nho de ep tao file .wal..."
foreach ($db in $targetDBs) {
    _log " -> $db"
    & $ADB shell "sqlite3 $db 'PRAGMA journal_mode=WAL;'" 2>$null | Out-Null
    & $ADB shell "sqlite3 $db 'CREATE TABLE IF NOT EXISTS _tmp_gt(x); INSERT INTO _tmp_gt VALUES(1); DELETE FROM _tmp_gt;'" 2>$null | Out-Null
    Start-Sleep -Milliseconds 200
}

# Tao Call log
$numbers = @("+84111111111","+84222222222","+84333333333","+84444444444","+84555555555")
_log "Tao $Calls ban ghi Call Log..."
for ($i = 0; $i -lt $Calls; $i++) {
    $num = $numbers[$i % $numbers.Count]
    $dur = (20 + ($i * 11) % 90)
    $dateMs = ([int64](Get-Date -UFormat %s)) * 1000
    $insert = "content insert --uri content://call_log/calls --bind number:s:`"$num`" --bind type:i:2 --bind duration:i:$dur --bind date:l:$dateMs"
    _log " -> Ghi Calllog: $num ($dur s)"
    & $ADB shell $insert 2>$null | Out-Null
    Start-Sleep -Milliseconds 150
}

# Tao SMS
_log "Tao $Sms ban ghi SMS..."
for ($i = 0; $i -lt $Sms; $i++) {
    $num = $numbers[$i % $numbers.Count]
    $body = "GT SMS sample $([int]($i+1))"
    $dateMs = ([int64](Get-Date -UFormat %s)) * 1000
    $smsCmd = "content insert --uri content://sms/inbox --bind address:s:`"$num`" --bind body:s:`"$body`" --bind date:l:$dateMs --bind read:i:0"
    _log " -> Ghi SMS tu $num"
    & $ADB shell $smsCmd 2>$null | Out-Null
    Start-Sleep -Milliseconds 150
}

# Push anh va quet MediaStore
$dest = "/storage/emulated/0/Pictures"
_log "Dam bao thu muc $dest ton tai..."
& $ADB shell "mkdir -p $dest" | Out-Null

_log "Day va quet $Images anh..."
for ($i = 1; $i -le $Images; $i++) {
    $local = "$PSScriptRoot\$i.jpg"
    $remote = "$dest/$i.jpg"

    if (-not (Test-Path $local)) {
        _log "Thieu file $local - bo qua."
        continue
    }

    _log " -> adb push $local $remote"
    & $ADB push $local $remote | Out-Null

    $scanCmd = "am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file:///$remote"
    _log " -> adb shell $scanCmd"
    & $ADB shell $scanCmd | Out-Null
    Start-Sleep -Milliseconds 300
}

_log "Ground Truth da tao thanh cong!"
Write-Host ""
Write-Host "Khi thu thap, copy DB Media tu:"
Write-Host "   /data/data/com.google.android.providers.media.module/databases/"
