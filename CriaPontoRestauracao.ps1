Get-ExecutionPolicy
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

# Ativar criação de pontos de restauração
Enable-ComputerRestore -Drive "C:\"

# Criar um ponto de restauração manualmente
Checkpoint-Computer -Description "Ponto de restauração Diario" -RestorePointType "MODIFY_SETTINGS"

# Criar um script para criar um ponto de restauração diariamente
$scriptPath = "d:\CriaPontoRestauracaoDiario.ps1"
$scriptContent = @"
Enable-ComputerRestore -Drive "C:\"
Checkpoint-Computer -Description "Ponto de restauração diário" -RestorePointType "MODIFY_SETTINGS"
"@

# Salvar o script em um arquivo
$scriptContent | Out-File -FilePath $scriptPath -Force

# Criar a tarefa no Agendador de Tarefas
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
$trigger = New-ScheduledTaskTrigger -Daily -At "3:00 AM"  # Altere o horário conforme necessário

# Configurar opções da tarefa para executar como administrador
$principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -DontStopOnIdleEnd -StartWhenAvailable
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "CriarPontoRestauracaoDiario" -Principal $principal -Settings $settings -Force

Write-Host "Tarefa agendada criada com sucesso para criar um ponto de restauração diariamente como administrador."