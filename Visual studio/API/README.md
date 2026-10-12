# API Restaurante Florença

API ASP.NET Core 8 para o aplicativo Android do Restaurante Florença.

## Banco

A API espera pelo SQL Server LocalDB:

- Banco: `restauranteflorenca`
- Servidor: `(localdb)\MSSQLLocalDB`

Execute primeiro o script SQL do banco.

## API

HTTP:
`http://localhost:5162`

Swagger:
`http://localhost:5162/swagger`

### Android Emulator

No emulador padrão do Android Studio, use:

`http://10.0.2.2:5162`

Não use `localhost` no Android Emulator, pois `localhost` aponta para o próprio emulador.

### Celular físico

Use o IPv4 do computador na rede local, por exemplo:

`http://192.168.0.10:5162`

É necessário permitir a porta 5162 no Firewall do Windows.

## Endpoints principais

POST `/api/usuarios/login`

POST `/api/usuarios/cadastrar`

GET `/api/agendamentos`

GET `/api/agendamentos/usuario/{usuarioId}`

POST `/api/agendamentos`

GET `/api/cupons/usuario/{usuarioId}`

POST `/api/cupons/validar`

PUT `/api/cupons/{id}/usar`

GET `/api/comandaspedidos/usuario/{usuarioId}`

POST `/api/comandaspedidos`

PUT `/api/comandaspedidos/{id}/status`

GET `/api/favoritos/usuario/{usuarioId}`

POST `/api/favoritos`

DELETE `/api/favoritos/{id}`

GET `/api/filavirtual/usuario/{usuarioId}`

POST `/api/filavirtual`

PUT `/api/filavirtual/{id}/cancelar`


## Endpoints adicionais usados pelo Android
- GET `/api/filavirtual`
- PUT `/api/filavirtual/{id}/chamar`
- POST `/api/cupons`
- POST `/api/cupons/validar-funcionario`

## Execução no Visual Studio

1. Abra `ProjetoFlorenca.sln` na pasta raiz do projeto.
2. No Gerenciador de Soluções, o projeto `FlorencaApi` estará dentro da solução.
3. Defina `FlorencaApi` como projeto de inicialização.
4. No seletor de execução, escolha o perfil `http`.
5. A API ficará em `http://localhost:5162` e o Swagger em `http://localhost:5162/swagger`.
6. A conexão com o SQL Server usa `localhost` e o banco `restauranteflorenca`.

Para o Android Emulator, a base URL da API deve ser `http://10.0.2.2:5162/`.
