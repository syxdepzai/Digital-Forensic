<#
collect_evidence.ps1
Mục tiêu:
 - Xóa DBs cũ trên /sdcard
 - Copy DBs (contacts, calllog, sms, media) kèm WAL/SHM
 - Pull về host, tạo SHA256 hash
Usage:
   .\collect_evidence.ps1 pre
   .\collect_evidence.ps1 post
#>

param(
    [string]$Stage = "pre"
)

$timestamp = Get-Date -Format "yyyyMMddTHHmmss"
$device = (adb get-serialno)
$baseDir = "C:\Forensic_Evidence\${device}_${Stage}_${timestamp}"
New-Item -ItemType Directory -Path $baseDir -Force | Out-Null

Write-Host "[PRE] Chuan bi"
Write-Host "Thiet bi: $device"
Write-Host "Thu muc bang chung: $baseDir"

adb root | Out-Null
Start-Sleep -Seconds 1

Write-Host "[PRE] Don sach /sdcard"
adb shell "rm -f /sdcard/*.db /sdcard/*.db-wal /sdcard/*.db-shm" | Out-Null
Start-Sleep -Seconds 1

Write-Host "[POST] Copy cac DB (core & media) ra /sdcard"
$dbs = @(
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

foreach ($db in $dbs) {
    $fname = Split-Path $db -Leaf
    Write-Host ("[" + (Get-Date -Format "HH:mm:ss") + "] Copy " + $db)
    adb shell "su 0 cp $db /sdcard/$fname" 2>$null
}

Write-Host "[PRE] Pull DBs ve host"
foreach ($db in $dbs) {
    $fname = Split-Path $db -Leaf
    Write-Host " -> Pull $fname"
    adb pull "/sdcard/$fname" "$baseDir\$fname" 2>$null
}

Write-Host "[POST] Tinh SHA256 hash"
$hashFile = "$baseDir\POST_hash.sha256"
Get-ChildItem $baseDir -Filter "*.db*" | ForEach-Object {
    $h = Get-FileHash $_.FullName -Algorithm SHA256
    "$($h.Hash)  $($_.Name)" | Out-File $hashFile -Append
}

Write-Host ""
Write-Host "[OK] Thu thap bang chung hoan tat ($Stage)"
Write-Host "[LOCATION] Luu tai: $baseDir"
Write-Host "[HASH] File: $hashFile"


