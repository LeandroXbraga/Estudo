# Define a página de código do console para UTF-8
chcp 65001

# Lê os dados do arquivo "dados_usuario.txt"
$dados = Get-Content -Path "D:\html\dados_usuario.txt" -Encoding UTF8
$usuario, $novaSenha, $cpf = $dados -split '\n'

try {
    # Obter informações do usuário no AD, incluindo o CEP
    $user = Get-ADUser -Filter {SamAccountName -eq $usuario} -Properties SamAccountName, PostalCode, Enabled
    
    if ($null -eq $user) {
        Write-Host "Usuario nao encontrado no Active Directory." 
        exit 10  # Encerra o script com código de erro 1
    }

    if ($user.Enabled -eq $false) {
        Write-Host "A conta de: $usuario. esta desabilitada." 
        exit 11  # Encerra o script com código de erro 2
    }

    # Verificar se o CEP do AD coincide com o fornecido e remove espaços em branco.
    $cpf = $cpf.Trim()
    $userPostalCode = $user.PostalCode.Trim()

    if ($userPostalCode -ne $cpf) {
        # Se o CPF não coincide, envie uma mensagem de erro específica para o PHP
        Write-Host "CPF Divergente"  # Mensagem específica indicando CPF divergente
        exit 12  # Encerra o script com código de erro 3 (indicando erro específico de CPF)
    }
     
    # Sua lógica para alterar a senha no Active Directory
    $MyPassword = ConvertTo-SecureString -AsPlainText -Force -String $novaSenha
    Set-ADAccountPassword -Identity $usuario -Reset -PassThru -NewPassword $MyPassword | Set-ADuser -ChangePasswordAtLogon $false
    Enable-ADAccount -Identity $usuario

    # Saída de sucesso
    Write-Host "Senha Alterada Com Sucesso" -Encoding UTF8

    if ($returnValue -ne 0) {
        Write-Host "Erro na execução do PowerShell."
    }

} catch {
    # Erro na alteração da senha
    Write-Host "Erro Na Alteracao Da Senha" -Encoding UTF8
    $errorMessage = $_.Exception.Message
    Write-Host "Erro Na Alteracao Da Senha: $errorMessage" -Encoding UTF8

    # Grava o erro, usuário e senha em um arquivo de log
    $logFile = "D:\Html\log.txt"
    $logEntry = "Erro na Alteracao Da Senha: $errorMessage | Usuario: $usuario"
    try {
        Add-Content -Path $logFile -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Host "Erro ao adicionar conteúdo ao arquivo de log: $_"
        exit 5  # Encerra o script com código de erro 5
    }
}

# SIG # Begin signature block
# MIIFjwYJKoZIhvcNAQcCoIIFgDCCBXwCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCq/sze4bpxjjyh
# Cw3q2N3ZlnGCNyN1eNz0zwwwj95W66CCAwYwggMCMIIB6qADAgECAhBh+uSO+fIU
# rUUsnuXW+ntOMA0GCSqGSIb3DQEBBQUAMBkxFzAVBgNVBAMMDk1ldUNlcnRpZmlj
# YWRvMB4XDTIzMTEwMzEyMTkwOVoXDTI0MTEwMzEyMzkwOVowGTEXMBUGA1UEAwwO
# TWV1Q2VydGlmaWNhZG8wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDe
# p74ekcJmWiKP5/DY2lX62Pl1WP2BpneEAisXmrT1SJqhLaPP8V0QhuhLxwKyx821
# pJ7K63QNX4+bpNfCdj40UeIaQtyRrVzqaaIHpPHcXotB7dI6Y0SrOO6uNpnWP9+i
# GkiaXGEg6DI9B3dOcxkEb5cj8ONcgH4k9KObI35WX5udzJKUlrHOuMndV44q1w24
# l1D+oGXEJ+qd4maQ1o09Dkv+LJgKvMFDIdwEvbKBiGKmUbFJaGQiDyYEEtjibWu+
# V3izAxaI9NghvNB5R4d+z3kBIBZpmJ0uPl2WhaT8juEBZiBdobobyCQ6XsQWVFRG
# nfLmsuNEjXbmRl2DmskJAgMBAAGjRjBEMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUE
# DDAKBggrBgEFBQcDAzAdBgNVHQ4EFgQUHcgUyaEorC5JCi0DTXzOb1gndM8wDQYJ
# KoZIhvcNAQEFBQADggEBAIhzsmWCu33xBVSm7YVILokxAWIH59KeUaPQQuksy579
# NnECrWBWzMWDRuXbEQc4BNdaNPx4YAoo8DppQ34UMTWpSHpEXzfe3y9J1k7d5svu
# KfkD66IBUZVS7CZiz79MIiSDt/2xfKYXU7ahEobcNQHzR47kpwx6yaEQAji4YZiX
# CFQ/K7cGBKx/BdWcH5qqb/lKgERjPRRhOWfs7zijqgnxwz5ziYHe951YFmtDXAcN
# fpzSQIoh0KVg4D8QiJo6PEzqTSfW1pc0U8n0Yzuv19UemVvgBy2gSo2rbmoT82Mw
# qfJWVjvZbjhrps4KZ+QFL+9EvFTD6g+mAr4KQGezmSQxggHfMIIB2wIBATAtMBkx
# FzAVBgNVBAMMDk1ldUNlcnRpZmljYWRvAhBh+uSO+fIUrUUsnuXW+ntOMA0GCWCG
# SAFlAwQCAQUAoIGEMBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcN
# AQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUw
# LwYJKoZIhvcNAQkEMSIEINChMZ94wwyN8lKKaGiCW2QWeJeSWQyWJzydPOtsMZ5F
# MA0GCSqGSIb3DQEBAQUABIIBACKXQuD6WaiCdvKUfh9eMoDoG/59cqq8ZgY7og64
# JzSXa+DF2sMmqO90nWwo+kaS2wqelQJyJuOPjGwvpU4JQUThuCHDzpqlk9GWqxsi
# 1OGs69iyulNQPlXkcBNKyKbVGhpzdG4jQYngNVsr+lXP2DkDnJdA3d4PiZw15r/3
# KJlDXwnYgx0Id2wrCyqW8jE3IuLjaW8erkzwXebOF6LJ7uTjiIPQl3ixzXzLQrGI
# 9h7dsEveU07cPb1VexZD3nUvdcmCWHt/qq5gDCdJb+aDWnH1c+hgSWeK80dYqo+j
# JlaQ/9Y9BHc2VOhKaZH7RhePhbm7dXwNNlhbVjuorUt8YqI=
# SIG # End signature block