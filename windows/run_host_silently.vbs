' ==========================================
' VBScript to run GitHub hosts update PowerShell script silently
' Path to PowerShell script is determined relative to the VBS script's location
' ==========================================

Set objShell = CreateObject("Wscript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Get the full path of the VBS script itself
ScriptPath = WScript.ScriptFullName

' Get the directory where the VBS script is located
ScriptDir = objFSO.GetParentFolderName(ScriptPath)

' Build the absolute path for host.ps1, assuming it's in the same directory
PS1Path = objFSO.BuildPath(ScriptDir, "host.ps1")

' Run the PowerShell script silently (Window Style 0)
' The path is enclosed in double quotes for paths with spaces
objShell.Run "powershell.exe -ExecutionPolicy Bypass -File """ & PS1Path & """", 0, False