' ==========================================
' VBScript to run GitHub hosts update PowerShell script silently
' Path to PowerShell script: F:\github\host.ps1
' ==========================================

Set objShell = CreateObject("Wscript.Shell")
objShell.Run "powershell.exe -ExecutionPolicy Bypass -File ""F:\github\host.ps1""", 0, False
