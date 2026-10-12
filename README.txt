Guia de Execução, Testes e Validação no VS Code
Pré-requisitos
1. Flutter SDK >=3.0.0 <4.0.0 instalado na máquina.

2. VS Code com as extensões Flutter e Dart ativas.

3.API C# (.NET Core) rodando no backend na porta 5162.
Passo a Passo de Execução:

1. Abrir a pasta no VS Code: Navegue até a pasta RestauranteFlorenca_Flutter.

2. Restaurar Dependências: No terminal do VS Code (Ctrl + '), rode:
flutter pub get

3. Conectar Emulador ou Dispositivo: Verifique os dispositivos ativos:
flutter devices

4.Iniciar a Aplicação: Execute o comando abaixo ou (pressione F5):
flutter run

5.Principais Comandos no Terminal durante a execução:

r: Executa Hot Reload (atualiza a interface instantaneamente).

R: Executa Hot Restart (reinicia o estado do app).

q: Encerra a aplicação.