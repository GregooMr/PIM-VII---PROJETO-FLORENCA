# 📑 Documentação Técnica de Desenvolvimento - Restaurante Florença (Flutter)

**Sistema de Gestão Gastronômica & Inclusão Social — Restaurante Florença**  
**Versão:** 1.0.0 (Flutter / Dart)  
**Tecnologias:** Flutter SDK, Dart, Material Design 3, HTTP RESTful API, SharedPreferences, C# .NET Core, SQL Server.

---

## 📄 Sumário
1. [Visão Geral e Objetivos do Sistema](#1-visão-geral-e-objetivos-do-sistema)
2. [Arquitetura e Padrões do Projeto](#2-arquitetura-e-padrões-do-projeto)
3. [Design System e Identidade Visual](#3-design-system-e-identidade-visual)
4. [Estrutura de Pastas do Projeto](#4-estrutura-de-pastas-do-projeto)
5. [Modelagem de Dados (Entidades Dart)](#5-modelagem-de-dados-entidades-dart)
6. [Camada de Serviços (Integração HTTP REST)](#6-camada-de-serviços-integração-http-rest)
7. [Mapeamento Completo de Telas e Módulos](#7-mapeamento-completo-de-telas-e-módulos)
   - [Módulo Autenticação](#módulo-autenticação)
   - [Módulo Cliente](#módulo-cliente)
   - [Módulo Equipe / Staff](#módulo-equipe--staff)
8. [Diretrizes de Acessibilidade e Responsabilidade Social](#8-diretrizes-de-acessibilidade-e-responsabilidade-social)
9. [Guia de Execução, Testes e Validação no VS Code](#9-guia-de-execução-testes-e-validação-no-vs-code)

---

## 1. Visão Geral e Objetivos do Sistema

O **Restaurante Florença** é um aplicativo mobile multiplataforma concebido para modernizar a experiência de atendimento gastronômico e promover ativamente a inclusão social e acessibilidade.

### Principais Pilares:
* **Automação Gastronômica:** Cardápio digital com 37 itens divididos em 8 categorias, comanda eletrônica e envio direto de pedidos para a cozinha.
* **Inclusão Social & PCD:** Módulo exclusivo para reserva de mesas com suporte a pessoas com deficiência e necessidades especiais (Cadeirantes, Cão-Guia, LIBRAS, Sensibilidade Sensorial, etc.).
* **Gestão da Fila Virtual:** Controle dinâmico de fila de espera com notificação automática quando a mesa do cliente estiver pronta.
* **Módulo Operacional Staff:** Painel administrativo para a equipe do restaurante monitorar cozinha, chamar clientes na fila e validar cupons.

---

## 2. Arquitetura e Padrões do Projeto

A aplicação adota o padrão de **Separação de Responsabilidades (SoC)**, organizada em camadas bem delimitadas:

```
┌─────────────────────────────────────────────────────────┐
│                    CAMADA DE APRESENTAÇÃO               │
│        (Widgets / Screens / UI Material Design 3)       │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│                 GERENCIAMENTO DE ESTADO                 │
│        (StatefulWidget + SharedPreferences local)       │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│                   CAMADA DE SERVIÇOS                    │
│             (ApiService - HTTP Async Client)            │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│                  BACKEND & BANCO DE DADOS               │
│          (API REST C# .NET Core + SQL Server)           │
└─────────────────────────────────────────────────────────┘
```

* **Estado Local:** Gerenciado via `StatefulWidget` com `setState()` para reatividade imediata.
* **Persistência Temporária:** Utilização de `SharedPreferences` para token de sessão (`usuario_id`, `usuario_tipo`) e itens da comanda/carrinho local.
* **Comunicação Assíncrona:** Requisições HTTP com `Future` e manipulação em JSON.

---

## 3. Design System e Identidade Visual

O tema visual da aplicação foi estruturado no arquivo `lib/main.dart` utilizando a paleta corporativa oficial do restaurante:

| Elemento Visual | Código Hex | Aplicação no Sistema |
| :--- | :--- | :--- |
| **Vinho Bordô** | `#6B122C` | AppBars, botões primários, títulos principais, botões de ação do carrinho |
| **Dourado** | `#D4AF37` | Detalhes de destaque, sub-títulos do cabeçalho, elementos comemorativos |
| **Oliva** | `#4A5D3E` | Botões de adição ao carrinho, cartões de reservas e atalhos secundários |
| **Creme Suave** | `#FAF7F2` | Fundo principal de todas as telas (Scaffold Background) |
| **Branco Card** | `#FFFFFF` | Cartões de conteúdo, listas de pratos e formulários |

* **Imagem da Marca:** Fundo da tela de login e cadastro enriquecido com a foto oficial do restaurante (`assets/images/restaurante.png`) sobreposta por uma camada semi-transparente de opacidade 55%.

---

## 4. Estrutura de Pastas do Projeto

```text
RestauranteFlorenca_Flutter/
├── assets/
│   └── images/
│       └── restaurante.png            <-- Foto oficial do restaurante para fundo
├── pubspec.yaml                        <-- Configuração de dependências e assets
└── lib/
    ├── main.dart                       <-- Ponto de entrada, rotas e Tema M3
    ├── models/                         <-- Entidades de dados
    │   ├── usuario.dart
    │   ├── agendamento.dart
    │   ├── comanda_pedido.dart
    │   ├── cupom.dart
    │   ├── favorito.dart
    │   └── fila_virtual.dart
    ├── services/
    │   └── api_service.dart            <-- Cliente HTTP RESTful
    └── screens/                        <-- Interfaces de usuário (Screens)
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

## 5. Modelagem de Dados (Entidades Dart)

### A) `Usuario` (`lib/models/usuario.dart`)
* `id` (int): Identificador único.
* `nome` (String): Nome completo.
* `loginUsuario` (String): Credencial de acesso.
* `senha` (String): Senha de autenticação.
* `tipoUsuario` (String): Perfil de permissão (`CLIENTE` ou `FUNCIONARIO`).

### B) `Agendamento` (`lib/models/agendamento.dart`)
* `id` (int): Identificador da reserva.
* `usuarioId` (int): ID do cliente.
* `dataHora` (String): Data e hora no formato ISO-8601.
* `qtdPessoas` (int): Número de convidados.
* `isPcd` (bool): Flag de necessidade especial/PCD.
* `nomePcd` (String): Nome da pessoa com deficiência.
* `tipoPcd` (String): Categoria de acessibilidade requerida.
* `status` (String): Estado (`CONFIRMADO`, `CANCELADO`, `CONCLUIDO`).

### C) `ComandaPedido` (`lib/models/comanda_pedido.dart`)
* `id` (int): Código do pedido.
* `usuarioId` (int): ID do cliente.
* `itensJson` (String): Lista de pratos serializada em JSON.
* `valorTotal` (double): Valor total da conta em Reais (R$).
* `status` (String): Estado na cozinha (`PENDENTE`, `EM_PREPARO`, `ENTREGUE`, `CANCELADO`).

### D) `Favorito` (`lib/models/favorito.dart`)
* `id` (int): Identificador do registro.
* `usuarioId` (int): ID do usuário.
* `pratoNome` (String): Nome do prato salvo.
* `preco` (double): Valor do prato.

### E) `FilaVirtual` (`lib/models/fila_virtual.dart`)
* `id` (int): Identificador na fila.
* `usuarioId` (int): ID do cliente.
* `qtdPessoas` (int): Tamanho do grupo.
* `status` (String): Estado na fila (`AGUARDANDO`, `MESA_PRONTA`, `FINALIZADO`, `CANCELADO`).

### F) `Cupom` (`lib/models/cupom.dart`)
* `id` (int): Código do cupom.
* `usuarioId` (int): Beneficiário.
* `nomePromocao` (String): Título da promoção.
* `codigoCupom` (String): Código resgatado (Ex: `FLOR-8492`).
* `isUsado` (bool): Flag de validação no caixa.

---

## 6. Camada de Serviços (Integração HTTP REST)

A classe `ApiService` (`lib/services/api_service.dart`) encapsula todas as chamas à API C# (.NET):

* **URL Base de Produção/Emulador:** `http://10.0.2.2:5162/api`

### Principais Endpoints Mapeados:

| Domínio | Método | Endpoint | Função |
| :--- | :---: | :--- | :--- |
| **Autenticação** | `POST` | `/usuarios/login` | Efetua login e retorna o token de perfil |
| **Autenticação** | `POST` | `/usuarios/cadastrar` | Registra novo usuário no sistema |
| **Agendamentos** | `POST` | `/agendamentos` | Cria nova reserva com parâmetros PCD |
| **Agendamentos** | `GET` | `/agendamentos/usuario/{id}` | Lista reservas do cliente logado |
| **Agendamentos** | `GET` | `/agendamentos` | Lista todas as reservas para a equipe Staff |
| **Comandas** | `POST` | `/comandaspedidos` | Envia novo pedido para a cozinha |
| **Comandas** | `GET` | `/comandaspedidos/usuario/{id}` | Histórico de pedidos do cliente |
| **Comandas** | `PUT` | `/comandaspedidos/{id}/status` | Atualiza o status do pedido na cozinha |
| **Favoritos** | `GET` | `/favoritos/usuario/{id}` | Obtém os pratos favoritados pelo usuário |
| **Favoritos** | `POST` | `/favoritos` | Adiciona um prato aos favoritos |
| **Favoritos** | `DELETE` | `/favoritos/{id}` | Remove um prato dos favoritos |
| **Fila Virtual** | `POST` | `/filavirtual` | Insere o cliente na fila de espera |
| **Fila Virtual** | `GET` | `/filavirtual/usuario/{id}` | Consulta posição e status da fila do cliente |
| **Fila Virtual** | `PUT` | `/filavirtual/{id}/chamar` | Notifica o cliente que a mesa está pronta |
| **Cupons** | `POST` | `/cupons` | Resgata cupom promocional para o cliente |
| **Cupons** | `POST` | `/cupons/validar-funcionario` | Caixa valida o código impresso |

---

## 7. Mapeamento Completo de Telas e Módulos

### Módulo Autenticação
1. **`login_screen.dart`**: Formulário de autenticação com seletor de acesso para equipe staff e imagem oficial de fundo.
2. **`cadastro_screen.dart`**: Cadastro simples para novos clientes.

### Módulo Cliente
1. **`home_cliente_screen.dart`**: Dashboard principal com Menu Lateral (Drawer) e atalhos rápidos.
2. **`cardapio_screen.dart`**: Exibe o cardápio completo com 37 itens divididos em 8 seções:
   - 🥗 *Entradas* (3 itens)
   - 🍝 *Pratos Principais Italianos* (5 itens)
   - 🥘 *Risotos Especiais* (3 itens)
   - 🇧🇷 *Moda Brasileira / Culinária Plural* (5 itens)
   - 🍷 *Lembranças Italianas / Drinks* (5 itens)
   - 🥤 *Bebidas Refrescantes* (8 itens)
   - ☕ *Bebidas Quentes* (4 itens)
   - 🍨 *Sobremesas* (9 itens)
3. **`carrinho_screen.dart`**: Gerencia a comanda local, calcula totais e submete o pedido para a API.
4. **`agendamento_screen.dart`**: Formulário de reserva com seletores de data/hora e formulário acessível PCD.
5. **`fila_screen.dart`**: Acompanhamento remoto da fila de espera com atualização a cada 5 segundos.
6. **`historico_screen.dart`**: Visualização combinada de histórico de comandas e agendamentos.
7. **`promocao_screen.dart`**: Vitrine de cupons de desconto para resgate imediato.
8. **`fidelidade_screen.dart`**: Exibição do cartão de selos de fidelidade (3 de 5 selos).
9. **`perfil_screen.dart`**: Perfil do usuário e listagem de pratos favoritados.
10. **`sobre_screen.dart`**: Apresentação institucional e responsabilidade social.

### Módulo Equipe / Staff
1. **`home_funcionario_screen.dart`**: Painel administrativo operacional.
2. **`func_fila_screen.dart`**: Painel da recepção para gerenciar fila e chamar próximos clientes.
3. **`func_agendamento_screen.dart`**: Monitoramento de mesas e alertas de reservas PCD.
4. **`func_pedido_screen.dart`**: Painel da cozinha para atualização do fluxo de preparo dos pratos.
5. **`func_promocao_screen.dart`**: Interface do caixa para validação e baixa de cupons.

---

## 8. Diretrizes de Acessibilidade e Responsabilidade Social

O aplicativo da **Florença Plural** foi desenvolvido seguindo as diretrizes universais de acessibilidade **WCAG (Web Content Accessibility Guidelines)** e as melhores práticas da plataforma Flutter:

### A) Suporte a Deficiência Visual (Pessoas Cegas e Baixa Visão)
* **Árvore Semântica & Leitores de Tela (TalkBack / VoiceOver):**
  Todos os componentes e imagens possuem nós semânticos descritivos (`Semantics` e `semanticLabel`), garantindo leitura clara e sequencial por leitores de tela.
* **Escalabilidade de Fonte (Dynamic Text Scaling):**
  A interface respeita a escala de fontes ajustada no sistema operacional pelo usuário, sem quebrar layouts ou textos.
* **Alto Contraste de Cores (WCAG AA/AAA):**
  Contraste elevado entre texto escuro e fundo claro (Vinho `#6B122C` e Preto `#2C2C2C` sobre Fundo Creme `#FAF7F2` e Cartões Brancos `#FFFFFF`), assegurando fácil leitura para pessoas com baixa visão ou daltonismo.

### B) Suporte a Deficiência Auditiva (Surdos / LIBRAS)
* **Interface 100% Visual:**
  Nenhuma funcionalidade do aplicativo depende exclusivamente de sinais sonoros. Notificações e confirmações são apresentadas visualmente através de `SnackBar`, alertas e badges de status.
* **Reserva com Atendimento em LIBRAS:**
  No formulário de agendamento (`agendamento_screen.dart`), o cliente pode marcar a opção de necessidade especial com atendimento em LIBRAS para que a recepção disponibilize um atendente capacitado no momento da chegada.

### C) Suporte a Pessoas Neurodivergentes e Sensibilidade Sensorial
* **Reserva para Ambiente Silencioso:**
  Permite agendar mesas em espaços reservados com menor ruído acústico e iluminação suave, ideal para pessoas no espectro autista (TEA), TDAH ou com hipersensibilidade tátil/auditiva.

### D) Acessibilidade Física e Mobilidade Reduzida (PCD)
* **Tamanho Mínimo de Alvo de Toque (Touch Targets):**
  Botões e campos possuem altura mínima de 50dp e espaçamento generoso, facilitando o toque para pessoas com tremores musculares ou mobilidade reduzida.
* **Reserva de Mesas Acessíveis:**
  Notificação automática para a equipe de Staff providenciar mesas adaptadas para cadeirantes ou espaço adequado para cão-guia.

### E) Diretrizes Étnico-Raciais e Diversidade
* **Leis 10.639/2003 e 11.645/2008:**
  Divulgação e valorização da culinária plural e formação contínua da equipe em atendimento antirracista e linguagem inclusiva (conforme apresentado na tela `SobreScreen`).


---

## 9. Guia de Execução, Testes e Validação no VS Code

### Pré-requisitos
1. **Flutter SDK** `>=3.0.0 <4.0.0` instalado na máquina.
2. **VS Code** com as extensões **Flutter** e **Dart** ativas.
3. **API C# (.NET Core)** rodando no backend na porta `5162`.

### Passo a Passo de Execução:

1. **Abrir a pasta no VS Code:**
   Navegue até a pasta `RestauranteFlorenca_Flutter`.

2. **Restaurar Dependências:**
   No terminal do VS Code (`Ctrl + '`), rode:
   ```bash
   flutter pub get
   ```

3. **Conectar Emulador ou Dispositivo:**
   Verifique os dispositivos ativos:
   ```bash
   flutter devices
   ```

4. **Iniciar a Aplicação:**
   Execute o comando abaixo ou pressione **F5**:
   ```bash
   flutter run
   ```

5. **Principais Comandos no Terminal durante a execução:**
   - `r`: Executa **Hot Reload** (atualiza a interface instantaneamente).
   - `R`: Executa **Hot Restart** (reinicia o estado do app).
   - `q`: Encerra a aplicação.

---
*Documentação gerada e atualizada para o ecossistema Flutter do Restaurante Florença.*
