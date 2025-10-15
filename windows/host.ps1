# ================================
# GitHub520 Hosts Auto Update Script (with retry mechanism)
# Retry up to 3 times, wait 30 seconds between failures
# ================================

$ErrorActionPreference = "Stop"

#TODO: Change this to your desired directory
$baseDir   = "F:\github"

$hostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
$tempFile  = "$baseDir\github520_hosts.txt"
$backup    = "$baseDir\hosts.bak"
$logFile   = "$baseDir\github_hosts_update.log"
$maxLogLines = 7
$maxRetries = 3
$retryDelay = 30

if (-not (Test-Path "$baseDir")) { New-Item -ItemType Directory -Path "$baseDir" | Out-Null }

$attempt = 0
$success = $false

while (-not $success -and $attempt -lt $maxRetries) {
    $attempt++
    try {
        # ------------------------
        # Step 1: Download latest hosts
        # ------------------------
        Invoke-WebRequest -Uri "https://raw.hellogithub.com/hosts" -UseBasicParsing -OutFile $tempFile

        # ------------------------
        # Step 2: Extract remote GitHub520 block
        # ------------------------
        $remoteText = Get-Content $tempFile -Raw
        $pattern = "(?s)# GitHub520 Host Start.*?# GitHub520 Host End"
        if ($remoteText -match $pattern) {
            $remoteBlock = $matches[0]
        } else {
            throw "Remote hosts file does not contain '# GitHub520 Host Start ... End' block"
        }

        # ------------------------
        # Step 3: Extract local GitHub520 block (if exists)
        # ------------------------
        $localText = if (Test-Path $hostsPath) { Get-Content $hostsPath -Raw } else { "" }
        if (-not $localText) { $localText = "" }
        if ($localText -match $pattern) {
            $localBlock = $matches[0]
        } else {
            $localBlock = ""
        }

        # ------------------------
        # Step 4: Compare and update if needed
        # ------------------------
        $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        if ($remoteBlock -eq $localBlock) {
            $logMsg = "[$time] No changes, no update needed"
        } else {
            Copy-Item -Path $hostsPath -Destination $backup -Force
            if (-not $localText) { $localText = "" }
            $updated = [regex]::Replace($localText, $pattern, "")
            $updated = "$updated`r`n$remoteBlock"
            Set-Content -Path $hostsPath -Value $updated -Encoding UTF8
            $logMsg = "[$time] Update success (attempt $attempt)"
        }

        $success = $true

    } catch {
        $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logMsg = "[$time] Update failed (attempt $attempt): $($_.Exception.Message)"
        if ($attempt -lt $maxRetries) {
            Add-Content -Path $logFile -Value "$logMsg -> Retrying in $retryDelay seconds..."
            Start-Sleep -Seconds $retryDelay
        } else {
            Add-Content -Path $logFile -Value "$logMsg -> Giving up after $attempt attempts."
        }
    }
}

# ------------------------
# Step 5: Log maintenance
# ------------------------
Add-Content -Path $logFile -Value $logMsg
if ((Get-Content $logFile).Count -gt $maxLogLines) {
    (Get-Content $logFile | Select-Object -Last $maxLogLines) | Set-Content $logFile
}
