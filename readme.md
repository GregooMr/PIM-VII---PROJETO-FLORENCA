# 🇮🇹 Restaurante Florença — Ecossistema Tecnológico Integrado
> **Projeto Integrado Multidisciplinar VII (PIM VII)**  
> **Curso Superior de Tecnologia em Análise e Desenvolvimento de Sistemas — UNIP**  
> **Integrantes:** Leonardo Rodrigues Sant' Ana (RA: 2634490)| Gabriel Olímpio dos Santos (RA: 2545535)  
> **Orientador:** Prof. MSc. Tarcísio Peres  

---

## 📌 Visão Geral do Projeto

O **Restaurante Florença** combina a tradição da gastronomia italiana com a pluralidade da cultura brasileira, apoiado por uma plataforma tecnológica moderna, inclusiva e ágil. 

O objetivo do projeto é resolver problemas crônicos do setor de restauração — como a lentidão de atendimento, filas na recepção, perda de comandas na cozinha (*no-show*) e barreiras de acessibilidade — por meio de uma solução full-stack escalável.

O ecossistema é composto por:
1. **API REST backend** construída em **ASP.NET Core 8** com **Entity Framework Core** e **SQL Server**.
2. **Painel Administrativo Web (KDS e Gestão)** desenvolvido com **ASP.NET Core MVC**.
3. **Aplicativo Mobile Multiplataforma** para Clientes e Equipe Staff desenvolvido em **Flutter / Dart**.
4. **Módulo de Responsabilidade Social e Inclusão**, com suporte a acessibilidade para Pessoas com Deficiência (PCD) e conteúdos alinhados às Leis nº 10.639/2003 e nº 11.645/2008.

---

## 🛠️ Tecnologias Utilizadas

### **Backend & Web API**
* **Linguagem & Framework:** C# / .NET 8 (ASP.NET Core Web API & MVC)
* **ORM:** Entity Framework Core 8
* **Banco de Dados:** Microsoft SQL Server
* **Segurança & Autenticação:** JWT (JSON Web Token), BCrypt.Net (Hash de Senhas), Role-Based Access Control (RBAC)
* **Documentação:** Swagger / OpenAPI

### **Mobile (Front-end)**
* **Framework:** Flutter (Dart)
* **Gerenciamento de Estado:** `StatefulWidget` com reatividade local
* **Armazenamento Local:** `SharedPreferences` (Offline-first / Carrinho e Sessão)
* **Comunicação HTTP:** Biblioteca `http` assíncrona consumindo a API REST

---

## ✨ Principais Funcionalidades

### 📱 **Aplicativo Mobile (Flutter)**
* **Módulo do Cliente:**
  * Cardápio digital interativo com 37 itens categorizados (Entradas, Pratos, Drinks, Sobremesas).
  * Carrinho com persistência local (`SharedPreferences`) e envio de pedidos à cozinha.
  * Agendamento de reservas com opção de atendimento exclusivo/prioritário PCD.
  * Fila de espera virtual remota com atualização em tempo real.
  * Resgate de cupons de desconto e programa de fidelidade acumulativo.
  * Aba educativa sobre Relações Étnico-Raciais e Valorização Cultural.
* **Módulo da Equipe (Staff):**
  * Monitor de comandas/pedidos na cozinha.
  * Chamador da fila de espera e controle de mesas acessíveis.
  * Validador de cupons promocionais no caixa.

### 💻 **Painel Administrativo Web (ASP.NET Core MVC)**
* Dashboard em tempo real com estatísticas de atendimento.
* Tela Kitchen Display System (KDS) para a cozinha avançar o status dos pratos (*Pendente*, *Em Preparo*, *Entregue*).
* Painel da Recepção para controle da Fila Virtual e Agendamentos PCD.
* Validação e gestão de cupons de desconto.

---

## ♿ Acessibilidade e Compromisso Social

* **Acessibilidade Universal:** Interface mobile e web projetadas para suporte a leitores de tela (TalkBack/VoiceOver), alto contraste (WCAG AA/AAA) e opções de agendamento para atendimento em LIBRAS ou ambientes com sensibilidade sensorial reduzida.
* **Diversidade Étnico-Racial:** Cumprimento das Leis nº 10.639/2003 e nº 11.645/2008 na plataforma digital, destacando a origem dos ingredientes e a fusão de saberes afro-brasileiros e indígenas na gastronomia do restaurante.

---

## 🚀 Como Executar o Projeto

### **Pré-requisitos**
* [.NET 8.0 SDK](https://dotnet.microsoft.com/download/dotnet/8.0) instalado.
* [SQL Server](https://www.microsoft.com/sql-server/) (LocalDB ou Express) instalado.
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (versão 3.x ou superior).
* [Visual Studio 2022](https://visualstudio.microsoft.com/) ou [VS Code].
* Emulador Android/iOS ou dispositivo físico conectado para rodar o app Flutter.

---

### 1️⃣ **Configuração do Backend & Banco de Dados (.NET 8)**

1. **Clone o repositório:**
   ```bash
   git clone https://github.com/GregooMr/PIM-VII---PROJETO-FLORENCA.git
   cd PIM-VII---PROJETO-FLORENCA
   ```

2. **Configurar a Connection String:**
   Acesse o arquivo `appsettings.json` na pasta do projeto da API e certifique-se de que a string de conexão para o SQL Server está apontando para o seu servidor local:
   ```json
   "ConnectionStrings": {
     "DefaultConnection": "Server=localhost;Database=restauranteflorenca;Trusted_Connection=True;TrustServerCertificate=True;"
   }
   ```

3. **Executar as Migrations / Script de Banco:**
   Execute o comando do Entity Framework para criar o banco de dados e as tabelas automaticamente:
   ```bash
   dotnet ef database update
   ```
   *(Caso prefira, execute o arquivo script SQL `BancoRestauranteFlorenca.sql` incluído na raiz do projeto).*

4. **Inicie a API REST:**
   ```bash
   dotnet run --project FlorencaApi
   ```
   A API iniciará na porta configurada (ex: `http://localhost:5162`). Você pode testar os endpoints através da interface do **Swagger** acessando `http://localhost:5162/swagger`.

---

### 2️⃣ **Configuração do Painel Administrativo Web (MVC)**

1. Com a API rodando, abra um novo terminal na pasta do projeto `FlorencaAdmin`:
   ```bash
   dotnet run --project FlorencaAdmin
   ```
2. Acesse a aplicação no navegador em `http://localhost:5000` (ou na porta informada pelo terminal).

---

### 3️⃣ **Configuração do Aplicativo Mobile (Flutter)**

1. **Navegue até a pasta do projeto Flutter:**
   ```bash
   cd RestauranteFlorenca_Flutter
   ```

2. **Ajuste o IP da API (Se necessário):**
   No arquivo `lib/services/api_service.dart`, certifique-se de que a `baseUrl` aponta corretamente para a sua API:
   * **Emulador Android Studio:** `http://10.0.2.2:5162/api`
   * **Dispositivo Físico / Mesma rede Wi-Fi:** `http://SEU_IP_LOCAL:5162/api`

3. **Instale as dependências:**
   ```bash
   flutter pub get
   ```

4. **Execute o aplicativo:**
   ```bash
   flutter run
   ```

---

## 🔒 Credenciais de Teste / Demonstração

| Perfil | Usuário / Login | Senha | Acesso Liberado |
| :--- | :--- | :--- | :--- |
| **Cliente** | `cliente1` | `1234` | App Mobile (Cardápio, Reservas, Carrinho) |
| **Funcionário / Staff** | `admin` | `admin` | App Mobile (Área Staff) & Painel Web (KDS/Gestão) |


---

## 📄 Licença e Uso Acadêmico

Este projeto foi desenvolvido estritamente para fins acadêmicos como parte da avaliação do **PIM VII** do CST em Análise e Desenvolvimento de Sistemas da **Universidade Paulista (UNIP)**.