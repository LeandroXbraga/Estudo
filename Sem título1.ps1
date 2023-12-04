# Defina a página de código do console para UTF-8
chcp 65001

# Lê os dados do arquivo "dados_usuario.txt"
$dados = Get-Content -Path "D:\html\dados_usuario.txt" -Encoding UTF8
$usuario, $novaSenha, $cpf = $dados -split '\n'

try {
    # Obter informações do usuário no AD, incluindo o CEP
    $user = Get-ADUser -Filter {SamAccountName -eq $usuario} -Properties SamAccountName, PostalCode, Enabled
    
    if ($null -eq $user) {
        Write-Host "Usuário não encontrado no Active Directory." 
        exit 1  # Encerra o script com código de erro 1
    }

    if ($user.Enabled -eq $false) {
        Write-Host "Não consegui alterar a senha de: $usuario. A conta está desabilitada." 
        exit 1  # Encerra o script com código de erro 1
    }

  # Verificar se o CEP do AD coincide com o fornecido
$userPostalCode = $user.PostalCode -as [string]
if ($userPostalCode -ne $null -and $userPostalCode.Equals($cpf, [System.StringComparison]::OrdinalIgnoreCase)) {

    # Sua lógica para alterar a senha no Active Directory
    $MyPassword = ConvertTo-SecureString -AsPlainText -Force -String $novaSenha
    Set-ADAccountPassword -Identity $usuario -Reset -PassThru -NewPassword $MyPassword | Set-ADuser -ChangePasswordAtLogon $false
    Enable-ADAccount -Identity $usuario
   
    # Saída de sucesso
    Write-Host "Senha Alterada Com Sucesso" -Encoding UTF8

} else {
    Write-Host "O CPF fornecido não coincide com o registrado no AD para o usuário: $usuario." 
    exit 1  # Encerra o script com código de erro 1
}

} catch {
    # Erro na alteração da senha
    Write-Host "Erro Na Alteracao Da Senha" -Encoding UTF8
    $errorMessage = $_.Exception.Message
    Write-Host "Erro Na Alteracao Da Senha: $errorMessage" -Encoding UTF8

    # Grava o erro, usuário e senha em um arquivo de log
    $logFile = "D:\Html\log.txt"
    $logEntry = "Erro na Alteracao Da Senha: $errorMessage | Usuário: $usuario"
    try {
        Add-Content -Path $logFile -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Host "Erro ao adicionar conteúdo ao arquivo de log: $_"
        exit 1  # Encerra o script com código de erro 1
    }
}