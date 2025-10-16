# ==============================================================================
# Script Function: Register a Scheduled Task using an XML definition file 
#                  and dynamically set the full script path.
# Requirement: GitHubHostsUpdate.xml must be in the same directory as this script.
# ==============================================================================

# Task Name
$TaskName = "GitHubHostsUpdate"
# XML File Path (Relative path to ensure the file is in the same directory)
$XmlFilePath = Join-Path $PSScriptRoot "GitHubHostsUpdate.xml"
# Get the absolute directory path of the current script (e.g., C:\Users\user\Documents)
$CurrentDir = $PSScriptRoot 

# ------------------------
# 1. Check Administrator Privileges
# ------------------------
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script requires Administrator privileges to run. Please right-click and select 'Run as Administrator'."
    exit 1
}

# ------------------------
# 2. Check if XML file exists
# ------------------------
if (-not (Test-Path $XmlFilePath)) {
    Write-Error "Error: Task definition file '$XmlFilePath' not found. Please ensure the XML file exists."
    exit 1
}

# ------------------------
# 3. Dynamically modify XML content and register the task
# ------------------------
try {
    Write-Host "Registering task '$TaskName' from XML file..."
    
    # Read the original XML file content
    $TaskXml = Get-Content $XmlFilePath -Raw

    # Define the hardcoded path from the original XML and the target VBS script name
    # Original hardcoded path to be replaced based on the XML: "F:\github\run_host_silently.vbs"
    $OldPathSegment = "F:\github\run_host_silently.vbs"
    $VBSFileName = "run_host_silently.vbs"
    
    # Build the new VBS script absolute path
    $NewVBSPath = Join-Path $CurrentDir $VBSFileName

    # Replace the hardcoded path in the XML content
    # The replacement ensures the path is correctly quoted for XML Args.
    $UpdatedXml = $TaskXml -replace [regex]::Escape($OldPathSegment), $NewVBSPath
    
    # Register the task. Use -Xml parameter and -Force to overwrite.
    Register-ScheduledTask -TaskName $TaskName -Xml $UpdatedXml -Force
        
    Write-Host "Task '$TaskName' registered successfully!" -ForegroundColor Green
    Write-Host "Task Details:"
    # Retrieve and display task information (using Get-ScheduledTask for verification)
    Get-ScheduledTask -TaskName $TaskName | Select-Object TaskName, State, @{Name='Principal'; Expression={$_.Principal.UserId}}, @{Name='RunLevel'; Expression={$_.Principal.RunLevel}}
    
} catch {
    Write-Error "An error occurred while registering the task: $($_.Exception.Message)"
}