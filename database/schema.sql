CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


CREATE TYPE status_enum AS ENUM(
    'Pendente', 
    'Aprovado', 
    'Reprovado', 
    'Cancelado',
    'Concluido'
);

--------------------
-- Blocos e Salas

CREATE TABLE IF NOT EXISTS blocos (
  id_bloco SERIAL PRIMARY KEY,
  codigo VARCHAR(5) UNIQUE NOT NULL,  -- B, C, D
  nome VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS salas (
  id_sala SERIAL PRIMARY KEY,
  id_bloco INT REFERENCES blocos(id_bloco) ON DELETE CASCADE,
  codigo VARCHAR(50) NOT NULL,        -- Ex: 201, Auditório 1
  tipo VARCHAR(50),                   -- Ex: sala, auditório, laboratório
  UNIQUE (id_bloco, codigo)
);

--------------------
-- Equipamentos

CREATE TABLE IF NOT EXISTS equipamentos (
  id_equipamento SERIAL PRIMARY KEY,
  nome VARCHAR(120) NOT NULL,
);

--------------------
-- Eventos

CREATE TABLE IF NOT EXISTS eventos (
  id_evento UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  titulo VARCHAR(150) NOT NULL,
  descricao TEXT,
  data_evento DATE NOT NULL,
  hora_inicio TIME NOT NULL,
  hora_fim TIME NOT NULL,
  periodo VARCHAR(15),                 -- Matutino, Vespertino, Noturno
  id_sala INT REFERENCES salas(id_sala),
  status_geral status_enum DEFAULT 'Pendente',
  criado_em TIMESTAMP DEFAULT NOW(),
  atualizado_em TIMESTAMP DEFAULT NOW()
);

--------------------
-- Aprovações (uma linha por área aplicável)

CREATE TABLE IF NOT EXISTS aprovacoes (
  id_aprovacao SERIAL PRIMARY KEY,
  id_evento UUID REFERENCES eventos(id_evento) ON DELETE CASCADE,
  area VARCHAR(20) NOT NULL,           -- Cerimonial, Marketing, Audiovisual
  status_aprovacao status_enum DEFAULT 'Pendente',
  observacoes TEXT,
  atualizado_em TIMESTAMP DEFAULT NOW(),
  UNIQUE (id_evento, area)
);

--------------------
-- Reservas de Equipamentos

CREATE TABLE IF NOT EXISTS reservas_equipamentos (
  id_reserva SERIAL PRIMARY KEY,
  id_evento UUID NULL REFERENCES eventos(id_evento) ON DELETE CASCADE,
  id_equipamento INT REFERENCES equipamentos(id_equipamento),
  quantidade INT NOT NULL CHECK (quantidade > 0),
  status_reserva status_enum DEFAULT 'Pendente',
  criado_em TIMESTAMP DEFAULT NOW()
);


-- Histórico de Ações

CREATE TABLE IF NOT EXISTS historico_evento (
  id_historico SERIAL PRIMARY KEY,
  id_evento UUID REFERENCES eventos(id_evento) ON DELETE CASCADE,
  acao VARCHAR(120) NOT NULL,
  detalhes TEXT,
  data_acao TIMESTAMP DEFAULT NOW()
);


-- Notificações

CREATE TABLE IF NOT EXISTS notificacoes (
  id_notificacao SERIAL PRIMARY KEY,
  id_evento UUID NULL REFERENCES eventos(id_evento) ON DELETE CASCADE,
  mensagem TEXT NOT NULL,
  criado_em TIMESTAMP DEFAULT NOW()
);
