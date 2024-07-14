DROP TABLE IF EXISTS clinica CASCADE;
DROP TABLE IF EXISTS enfermeiro CASCADE;
DROP TABLE IF EXISTS medico CASCADE;
DROP TABLE IF EXISTS trabalha CASCADE;
DROP TABLE IF EXISTS paciente CASCADE;
DROP TABLE IF EXISTS receita CASCADE;
DROP TABLE IF EXISTS consulta CASCADE;
DROP TABLE IF EXISTS observacao CASCADE;

CREATE TABLE clinica(
	nome VARCHAR(80) PRIMARY KEY,
	telefone VARCHAR(15) UNIQUE NOT NULL CHECK (telefone ~ '^[0-9]+$'),
	morada VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE enfermeiro(
	nif CHAR(9) PRIMARY KEY CHECK (nif ~ '^[0-9]+$'),
	nome VARCHAR(80) UNIQUE NOT NULL,
	telefone VARCHAR(15) NOT NULL CHECK (telefone ~ '^[0-9]+$'),
	morada VARCHAR(255) NOT NULL,
	nome_clinica VARCHAR(80) NOT NULL REFERENCES clinica (nome)
);

CREATE TABLE medico(
	nif CHAR(9) PRIMARY KEY CHECK (nif ~ '^[0-9]+$'),
	nome VARCHAR(80) UNIQUE NOT NULL,
	telefone VARCHAR(15) NOT NULL CHECK (telefone ~ '^[0-9]+$'),
	morada VARCHAR(255) NOT NULL,
	especialidade VARCHAR(80) NOT NULL
);

CREATE TABLE trabalha(
	nif CHAR(9) NOT NULL REFERENCES medico,
	nome VARCHAR(80) NOT NULL REFERENCES clinica,
	dia_da_semana SMALLINT,
	PRIMARY KEY (nif, dia_da_semana)
);

CREATE TABLE paciente(
	ssn CHAR(11) PRIMARY KEY CHECK (ssn ~ '^[0-9]+$'),
	nif CHAR(9) UNIQUE NOT NULL CHECK (nif ~ '^[0-9]+$'),
	nome VARCHAR(80) NOT NULL,
	telefone VARCHAR(15) NOT NULL CHECK (telefone ~ '^[0-9]+$'),
	morada VARCHAR(255) NOT NULL,
	data_nasc DATE NOT NULL
);

CREATE TABLE consulta(
	id SERIAL PRIMARY KEY,
	ssn CHAR(11) NOT NULL REFERENCES paciente,
	nif CHAR(9) NOT NULL REFERENCES medico,
	nome VARCHAR(80) NOT NULL REFERENCES clinica,
	data DATE NOT NULL,
	hora TIME NOT NULL,
	codigo_sns CHAR(12) UNIQUE CHECK (codigo_sns ~ '^[0-9]+$'),
	UNIQUE(ssn, data, hora),
	UNIQUE(nif, data, hora)
);

CREATE TABLE receita(
	codigo_sns VARCHAR(12) NOT NULL REFERENCES consulta (codigo_sns),
	medicamento VARCHAR(155) NOT NULL,
	quantidade SMALLINT NOT NULL CHECK (quantidade > 0),
	PRIMARY KEY (codigo_sns, medicamento)
);

CREATE TABLE observacao(
	id INTEGER NOT NULL REFERENCES consulta,
	parametro VARCHAR(155) NOT NULL,
	valor FLOAT,
	PRIMARY KEY (id, parametro)
);

ALTER TABLE consulta
ADD CONSTRAINT consulta_horarios_validos
CHECK (EXTRACT(HOUR FROM hora) BETWEEN 8 AND 18 AND EXTRACT(MINUTE FROM hora) IN (0, 30)
       AND NOT EXTRACT(HOUR FROM hora) = 13);

CREATE OR REPLACE FUNCTION verifica_autoconsulta()
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.nif = (SELECT nif FROM paciente WHERE ssn = NEW.ssn)) THEN
        RAISE EXCEPTION 'Um médico não se pode consultar a si próprio.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_verifica_autoconsulta
BEFORE INSERT OR UPDATE ON consulta
FOR EACH ROW
EXECUTE FUNCTION verifica_autoconsulta();

CREATE OR REPLACE FUNCTION verifica_medico_clinica_dia()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT *
        FROM trabalha
        WHERE trabalha.nif = NEW.nif AND
              trabalha.nome = NEW.nome AND
              trabalha.dia_da_semana = EXTRACT(DOW FROM NEW.data)
    ) THEN
        RAISE EXCEPTION 'Um médico só pode dar consultas na clínica em que trabalha no dia da semana correspondente à data da consulta.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_verifica_medico_clinica_dia
BEFORE INSERT OR UPDATE ON consulta
FOR EACH ROW
EXECUTE FUNCTION verifica_medico_clinica_dia();

CREATE INDEX idx_consulta_ssn ON consulta USING HASH (ssn);
CREATE INDEX idx_observacao_id ON observacao USING HASH (id);
CREATE INDEX idx_observacao_parametro_valor ON observacao (parametro, valor);

CREATE INDEX idx_consulta_nif ON consulta USING HASH (nif);
CREATE INDEX idx_receita_codigo_sns ON receita USING HASH (codigo_sns);
CREATE INDEX idx_consulta_codigo_sns ON consulta USING HASH (codigo_sns);
CREATE INDEX idx_consulta_data_brin ON consulta USING BRIN (data);
CREATE INDEX idx_medico_especialidade ON medico (especialidade);
