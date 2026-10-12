# 📱 Restaurante Florença - Aplicativo Mobile Exclusivo em Flutter (Dart)

Este é o projeto **Flutter exclusivo** do aplicativo mobile para o **Restaurante Florença**, desenvolvido em conformidade com as exigências acadêmicas do trabalho de faculdade.

---

## 🛠️ Requisitos Atendidos do Edital

- [x] **Desenvolvimento de Interface Responsiva em Flutter:** Padrão Material Design 3 com a paleta corporativa do restaurante (*Vinho Bordô*, *Dourado*, *Oliva* e *Creme*).
- [x] **Integração com APIs RESTful:** Consumo assíncrono via biblioteca `http` conectando-se ao backend C# (.NET Core) na rota `http://10.0.2.2:5162/api/`.
- [x] **Implementação de Autenticação e Gerenciamento de Usuários:** Módulos separados para **Cliente** e **Equipe / Staff** com salvamento local de sessão via `shared_preferences`.
- [x] **Armazenamento Local e Sincronização de Dados:** Comanda local salva via `shared_preferences` em JSON e enviada em tempo real para a cozinha no SQL Server.

---

## 📂 Estrutura do Projeto Flutter

```text
RestauranteFlorenca_Flutter/
├── pubspec.yaml                    <-- Configuração de dependências Flutter (http, shared_preferences)
└── lib/
    ├── main.dart                   <-- Ponto de entrada e configuração do Tema
    ├── models/                     <-- Entidades de dados (Usuario, Agendamento, Comanda, etc.)
    │   ├── usuario.dart
    │   ├── agendamento.dart
    │   ├── comanda_pedido.dart
    │   ├── cupom.dart
    │   ├── favorito.dart
    │   └── fila_virtual.dart
    ├── services/
    │   └── api_service.dart        <-- Cliente HTTP assíncrono conectado à API REST
    └── screens/                    <-- Telas em Dart / Widgets Flutter
        ├── login_screen.dart
        ├── cadastro_screen.dart
        ├── home_cliente_screen.dart
        ├── cardapio_screen.dart
        ├── carrinho_screen.dart
        ├── agendamento_screen.dart
        ├── fila_screen.dart
        ├── historico_screen.dart
        ├── promocao_screen.dart
        ├── fidelidade_screen.dart
        ├── perfil_screen.dart
        ├── sobre_screen.dart
        ├── home_funcionario_screen.dart
        ├── func_pedido_screen.dart
        ├── func_agendamento_screen.dart
        ├── func_fila_screen.dart
        └── func_promocao_screen.dart
```

---

## 🚀 Como Executar o App no VS Code ou Android Studio

1. **Abra a pasta `RestauranteFlorenca_Flutter`** no seu VS Code ou Android Studio.
2. Certifique-se de que o **Flutter SDK** está instalado na sua máquina (`flutter --version`).
3. No terminal, baixe as dependências:
   ```bash
   flutter pub get
   ```
4. Inicie o emulador Android ou conecte seu dispositivo móvel.
5. Certifique-se de que a **API C# (.NET)** no Visual Studio está rodando na porta `5162`.
6. Execute o aplicativo:
   ```bash
   flutter run
   ```
