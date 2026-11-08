
Programmer la sauvegarde automatique sous Windows
Nous allons utiliser le Planificateur de tâches Windows pour créer une sauvegarde toutes les 6 heures.

Ouvre PowerShell et exécute :


```powershell
$Action = New-ScheduledTaskAction `
  -Execute "C:\Program Files\Git\bin\bash.exe" `
  -Argument '-lc "cd /d/openclaw-2026.9.3-docker && bash scripts/backup.sh"'

$Trigger = New-ScheduledTaskTrigger -Daily -At 12:00AM

$Trigger.RepetitionInterval = New-TimeSpan -Hours 6
$Trigger.RepetitionDuration = New-TimeSpan -Days 1

$Settings = New-ScheduledTaskSettingsSet `
  -StartWhenAvailable `
  -ExecutionTimeLimit (New-TimeSpan -Hours 1)

Register-ScheduledTask `
  -TaskName "OpenClaw-Automatic-Backup" `
  -Action $Action `
  -Trigger $Trigger `
  -Settings $Settings `
  -Description "Automatic OpenClaw Docker state backup every 6 hours" `
  -Force
```