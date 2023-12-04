import requests
from bs4 import BeautifulSoup
import subprocess

# Realize uma solicitação HTTP para a página da web
url = 'http://10.10.24.151/'  # Altere para o URL correto
response = requests.get(url)

# Verifique se a solicitação foi bem-sucedida
if response.status_code == 200:
    # Analise o HTML da página
    soup = BeautifulSoup(response.text, 'html.parser')
    
    # Extraia informações da página (substitua com seus próprios seletores)
    user = soup.find('input', {'name': 'user'}).get('value')
    new_password = soup.find('input', {'name': 'NewPass'}).get('value')

    # Execute o script PowerShell com as informações coletadas
    script_path = 'D:\\Html\\SeuScript.ps1'
    powershell_command = f'powershell -ExecutionPolicy RemoteSigned -File "{script_path}" -User "{user}" -Password "{new_password}"'
    result = subprocess.run(powershell_command, capture_output=True, text=True, shell=True)

    # Exiba a saída do PowerShell
    print('Saída do PowerShell:')
    print(result.stdout)
else:
    print('Falha ao acessar a página da web.')
