param(
    [string]$Stage = "pre"
)

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "TELEGRAM FORENSICS - $Stage" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

$timestamp = Get-Date -Format "yyyyMMddTHHmmss"
$device = (adb get-serialno)
$baseDir = "C:\Forensic_Evidence\${device}_telegram_${Stage}_${timestamp}"
New-Item -ItemType Directory -Path $baseDir -Force | Out-Null

Write-Host "[1] Chuan bi"
Write-Host "Thiet bi: $device"
Write-Host "Thu muc: $baseDir"

adb root | Out-Null
Start-Sleep -Seconds 1

Write-Host "[2] Xoa logcat cu"
adb logcat --clear
Start-Sleep -Milliseconds 500

Write-Host "[3] Start logcat capture..."
$logFile = "$baseDir\logcat_${Stage}.log"
$logcatProcess = Start-Process -FilePath "adb" -ArgumentList "logcat -v threadtime" -RedirectStandardOutput $logFile -NoNewWindow -PassThru
Write-Host "Logcat PID: $($logcatProcess.Id)"
Write-Host ""
Write-Host "=== ACTION: Perform Telegram actions now ==="
Write-Host "Open Telegram on device, login and send the message(s) you need. When finished, return here and press Enter to stop logcat and pull app data."
Read-Host

Write-Host "[STOP] Stopping logcat..."
$logcatProcess | Stop-Process -Force
Start-Sleep -Seconds 1

Write-Host "[4] Pull org.telegram.messenger folder"
$telegramDir = "$baseDir\org.telegram.messenger"
adb pull "/data/data/org.telegram.messenger" "$telegramDir" 2>$null
Write-Host "Telegram data: $telegramDir"
Start-Sleep -Seconds 1

Write-Host "[5] Pull system databases"
$sysDbDir = "$baseDir\system_databases"
New-Item -ItemType Directory -Path $sysDbDir -Force | Out-Null

$systemDbs = @(
    "/data/data/com.android.providers.contacts/databases/contacts2.db",
    "/data/data/com.android.providers.contacts/databases/contacts2.db-wal",
    "/data/data/com.android.providers.contacts/databases/contacts2.db-shm",
    "/data/data/com.android.providers.contacts/databases/calllog.db",
    "/data/data/com.android.providers.contacts/databases/calllog.db-wal",
    "/data/data/com.android.providers.contacts/databases/calllog.db-shm",
    "/data/data/com.android.providers.telephony/databases/mmssms.db",
    "/data/data/com.android.providers.telephony/databases/mmssms.db-wal",
    "/data/data/com.android.providers.telephony/databases/mmssms.db-shm",
    "/data/data/com.google.android.providers.media.module/databases/external.db",
    "/data/data/com.google.android.providers.media.module/databases/external.db-wal",
    "/data/data/com.google.android.providers.media.module/databases/external.db-shm",
    "/data/data/com.google.android.providers.media.module/databases/internal.db",
    "/data/data/com.google.android.providers.media.module/databases/internal.db-wal",
    "/data/data/com.google.android.providers.media.module/databases/internal.db-shm"
)

foreach ($db in $systemDbs) {
    $fname = Split-Path $db -Leaf
    Write-Host " -> Pull $fname"
    adb pull "$db" "$sysDbDir\$fname" 2>$null
    Start-Sleep -Milliseconds 50
}

Write-Host "[6] Tinh SHA256 hash"
$hashFile = "$baseDir\hash_${Stage}.sha256"
$logFileName = "logcat_${Stage}.log"
Get-ChildItem $baseDir -Recurse -File | Where-Object { $_.Name -ne $logFileName } | ForEach-Object {
    try {
        $h = Get-FileHash $_.FullName -Algorithm SHA256
        "$($h.Hash)  $($_.FullName.Replace($baseDir, ''))" | Out-File $hashFile -Append
    } catch {
        Write-Host " -> Skip $($_.Name) (in use)"
    }
}

Write-Host "[7] Lay package info"
$pkgFile = "$baseDir\packages_${Stage}.txt"
adb shell "pm list packages -3 | grep telegram" > $pkgFile
adb shell "pm dump org.telegram.messenger | grep -A 5 'mUid\|versionCode'" >> $pkgFile

Write-Host ""
Write-Host "[OK] Thu thap $Stage hoan tat!"
Write-Host "Location: $baseDir"
Write-Host "Hash: $hashFile"
Write-Host "Logcat: $logFile"
Write-Host ""
Write-Host "Logcat van chay o background. De y chay Telegram toi khi script hoan tat."
Write-Host "Bam Enter de dung logcat..."
Read-Host

Write-Host "[STOP] Stopping logcat..."
$logcatProcess | Stop-Process -Force
Start-Sleep -Seconds 1
Write-Host "[DONE] Logcat dung, forensics data ready!"
Write-Host ""
