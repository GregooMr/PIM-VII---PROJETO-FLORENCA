IF DB_ID('restauranteflorenca') IS NULL
BEGIN
    CREATE DATABASE restauranteflorenca;
END
GO

USE restauranteflorenca;
GO

-- Execute este bloco em um banco vazio.
-- Se as tabelas já existirem, não execute novamente sem antes recriá-las.

CREATE TABLE usuarios (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    usuario VARCHAR(50) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    tipo_usuario VARCHAR(20) NOT NULL DEFAULT 'CLIENTE'
        CHECK (tipo_usuario IN ('CLIENTE', 'FUNCIONARIO')),
    created_at DATETIME NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE agendamentos (
    id INT IDENTITY(1,1) PRIMARY KEY,
    usuario_id INT NOT NULL,
    data_hora DATETIME NOT NULL,
    qtd_pessoas INT NOT NULL CHECK (qtd_pessoas > 0),
    is_pcd BIT NOT NULL DEFAULT 0,
    nome_pcd VARCHAR(100) NULL,
    tipo_pcd VARCHAR(100) NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'CONFIRMADO'
        CHECK (status IN ('CONFIRMADO', 'CANCELADO', 'CONCLUIDO')),
    created_at DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_agendamentos_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);
GO

CREATE TABLE comandas_pedidos (
    id INT IDENTITY(1,1) PRIMARY KEY,
    usuario_id INT NOT NULL,
    itens_json NVARCHAR(MAX) NOT NULL,
    valor_total DECIMAL(10,2) NOT NULL CHECK (valor_total >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'ENVIADO'
        CHECK (status IN ('ENVIADO', 'EM_PREPARO', 'ENTREGUE', 'CANCELADO')),
    created_at DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_comandas_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);
GO

CREATE TABLE favoritos (
    id INT IDENTITY(1,1) PRIMARY KEY,
    usuario_id INT NOT NULL,
    prato_nome VARCHAR(100) NOT NULL,
    preco DECIMAL(10,2) NOT NULL CHECK (preco >= 0),
    created_at DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_favoritos_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    CONSTRAINT UQ_favorito_usuario_prato
        UNIQUE (usuario_id, prato_nome)
);
GO

CREATE TABLE cupons (
    id INT IDENTITY(1,1) PRIMARY KEY,
    usuario_id INT NOT NULL,
    nome_promocao VARCHAR(100) NOT NULL,
    codigo_cupom VARCHAR(20) NOT NULL UNIQUE,
    is_usado BIT NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_cupons_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);
GO

CREATE TABLE fila_virtual (
    id INT IDENTITY(1,1) PRIMARY KEY,
    usuario_id INT NOT NULL,
    qtd_pessoas INT NOT NULL CHECK (qtd_pessoas > 0),
    status VARCHAR(20) NOT NULL DEFAULT 'AGUARDANDO'
        CHECK (status IN ('AGUARDANDO', 'MESA_PRONTA', 'FINALIZADO', 'CANCELADO')),
    created_at DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_fila_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);
GO

-- Dados de teste
INSERT INTO usuarios (nome, usuario, senha, tipo_usuario)
VALUES
('Gabriel Silva', 'cliente1', '1234', 'CLIENTE'),
('Equipe Staff Florença', 'admin', 'admin', 'FUNCIONARIO');
GO

INSERT INTO agendamentos
(usuario_id, data_hora, qtd_pessoas, is_pcd, nome_pcd, tipo_pcd, status)
VALUES
(1, '2026-10-15 19:30:00', 4, 1, 'Ana Souza',
 'Cadeirante / Mobilidade Reduzida', 'CONFIRMADO');
GO

INSERT INTO cupons
(usuario_id, nome_promocao, codigo_cupom, is_usado)
VALUES
(1, 'Combo Massa em Dobro', 'FLOR-8X92', 0);
GO

INSERT INTO favoritos (usuario_id, prato_nome, preco)
VALUES
(1, 'Spaghetti à Bolonhesa', 39.90);
GO

INSERT INTO comandas_pedidos
(usuario_id, itens_json, valor_total, status)
VALUES
(1,
 N'[{"prato":"Spaghetti à Bolonhesa","quantidade":1,"preco":39.90},
    {"prato":"Tiramisu","quantidade":1,"preco":18.90}]',
 58.80,
 'ENVIADO');
GO

INSERT INTO fila_virtual (usuario_id, qtd_pessoas, status)
VALUES (1, 3, 'AGUARDANDO');
GO
