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


INSERT INTO clinica (nome, telefone, morada) VALUES 
('Clinica Lisboa Centro', '213456789', 'Rua Augusta 42, 1100-048 Lisbon'),
('Clinica Sintra Saúde', '219876543', 'Avenida Heliodoro Salgado 12, 2710-575 Sintra'),
('Clinica Cascais Mar', '214567890', 'Avenida 25 de Abril 520, 2750-512 Cascais'),
('Clinica Amadora Saúde', '217654321', 'Rua Elias Garcia 34, 2700-327 Amadora'),
('Clinica Oeiras Bem-Estar', '214098765', 'Rua da Figueirinha 2, 2780-231 Oeiras');

INSERT INTO enfermeiro (nif, nome, telefone, morada, nome_clinica) VALUES
('123456789', 'Ana Silva', '912345678', 'Rua dos Anjos 15, 1100-039 Lisbon', 'Clinica Lisboa Centro'),
('223456789', 'João Pereira', '913456789', 'Rua da Prata 23, 1100-414 Lisbon', 'Clinica Lisboa Centro'),
('323456789', 'Maria Oliveira', '914567890', 'Rua dos Fanqueiros 200, 1100-232 Lisbon', 'Clinica Lisboa Centro'),
('423456789', 'Luís Santos', '915678901', 'Rua da Conceição 18, 1100-145 Lisbon', 'Clinica Lisboa Centro'),
('523456789', 'Carla Costa', '916789012', 'Rua dos Douradores 102, 1100-207 Lisbon', 'Clinica Lisboa Centro'),
('123456788', 'Rita Martins', '917890123', 'Rua dos Amores 10, 2710-579 Sintra', 'Clinica Sintra Saúde'),
('223456788', 'Pedro Silva', '918901234', 'Avenida dos Descobrimentos 55, 2710-073 Sintra', 'Clinica Sintra Saúde'),
('323456788', 'Sofia Santos', '919012345', 'Largo da Feira 8, 2710-652 Sintra', 'Clinica Sintra Saúde'),
('423456788', 'André Ferreira', '910123456', 'Rua do Campo 18, 2710-432 Sintra', 'Clinica Sintra Saúde'),
('523456788', 'Paula Rodrigues', '911234567', 'Travessa das Flores 3, 2710-653 Sintra', 'Clinica Sintra Saúde'),
('123456787', 'Inês Almeida', '912345679', 'Rua do Mar 25, 2750-284 Cascais', 'Clinica Cascais Mar'),
('223456787', 'Bruno Lima', '913456790', 'Avenida Marginal 100, 2750-002 Cascais', 'Clinica Cascais Mar'),
('323456787', 'Sara Fernandes', '914567891', 'Rua da Praia 45, 2750-642 Cascais', 'Clinica Cascais Mar'),
('423456787', 'Carlos Teixeira', '915678902', 'Rua do Farol 12, 2750-116 Cascais', 'Clinica Cascais Mar'),
('523456787', 'Diana Neves', '916789013', 'Avenida 1º de Maio 78, 2750-076 Cascais', 'Clinica Cascais Mar'),
('123456786', 'Joana Costa', '917890124', 'Rua do Comércio 15, 2700-675 Amadora', 'Clinica Amadora Saúde'),
('223456786', 'Miguel Nogueira', '918901235', 'Avenida da Liberdade 80, 2700-299 Amadora', 'Clinica Amadora Saúde'),
('323456786', 'Vera Lopes', '919012346', 'Rua do Lidador 12, 2700-327 Amadora', 'Clinica Amadora Saúde'),
('423456786', 'Hugo Mendes', '910123457', 'Largo da Igreja 6, 2700-438 Amadora', 'Clinica Amadora Saúde'),
('523456786', 'Isabel Gomes', '911234568', 'Rua da Solidariedade 1, 2700-623 Amadora', 'Clinica Amadora Saúde'),
('123456785', 'Patrícia Sousa', '912345680', 'Rua da Esperança 33, 2780-175 Oeiras', 'Clinica Oeiras Bem-Estar'),
('223456785', 'Ricardo Matos', '913456791', 'Avenida da República 90, 2780-273 Oeiras', 'Clinica Oeiras Bem-Estar'),
('323456785', 'Marta Cruz', '914567892', 'Rua dos Pescadores 19, 2780-254 Oeiras', 'Clinica Oeiras Bem-Estar'),
('423456785', 'Tiago Pinto', '915678903', 'Largo da Terra 20, 2780-003 Oeiras', 'Clinica Oeiras Bem-Estar'),
('523456785', 'Helena Marques', '916789014', 'Rua do Sol 44, 2780-564 Oeiras', 'Clinica Oeiras Bem-Estar');

INSERT INTO medico (nif, nome, telefone, morada, especialidade) VALUES
('100000001', 'Dr. António Sousa', '931234567', 'Rua Principal 1, 1000-001 Lisbon', 'General Practice'),
('100000002', 'Dr. Beatriz Carvalho', '932345678', 'Avenida Central 2, 1000-002 Lisbon', 'General Practice'),
('100000003', 'Dr. Carlos Almeida', '933456789', 'Rua Nova 3, 1000-003 Lisbon', 'General Practice'),
('100000004', 'Dr. Daniela Martins', '934567890', 'Largo da Paz 4, 1000-004 Lisbon', 'General Practice'),
('100000005', 'Dr. Eduardo Silva', '935678901', 'Travessa do Sol 5, 1000-005 Lisbon', 'General Practice'),
('100000006', 'Dr. Fernanda Costa', '936789012', 'Rua do Campo 6, 1000-006 Lisbon', 'General Practice'),
('100000007', 'Dr. Guilherme Rodrigues', '937890123', 'Avenida da Liberdade 7, 1000-007 Lisbon', 'General Practice'),
('100000008', 'Dr. Helena Lopes', '938901234', 'Rua das Flores 8, 1000-008 Lisbon', 'General Practice'),
('100000009', 'Dr. Isabel Ferreira', '939012345', 'Largo da Feira 9, 1000-009 Lisbon', 'General Practice'),
('100000010', 'Dr. João Mendes', '930123456', 'Avenida dos Anjos 10, 1000-010 Lisbon', 'General Practice'),
('100000011', 'Dr. Karina Lima', '931234578', 'Rua da Alegria 11, 1000-011 Lisbon', 'General Practice'),
('100000012', 'Dr. Luís Nogueira', '932345689', 'Travessa da Esperança 12, 1000-012 Lisbon', 'General Practice'),
('100000013', 'Dr. Marta Silva', '933456790', 'Rua do Progresso 13, 1000-013 Lisbon', 'General Practice'),
('100000014', 'Dr. Nuno Pereira', '934567801', 'Avenida das Nações 14, 1000-014 Lisbon', 'General Practice'),
('100000015', 'Dr. Olivia Santos', '935678912', 'Rua do Horizonte 15, 1000-015 Lisbon', 'General Practice'),
('100000016', 'Dr. Paulo Almeida', '936789023', 'Travessa da Vitória 16, 1000-016 Lisbon', 'General Practice'),
('100000017', 'Dr. Rita Martins', '937890134', 'Rua do Porto 17, 1000-017 Lisbon', 'General Practice'),
('100000018', 'Dr. Sérgio Costa', '938901245', 'Avenida do Mar 18, 1000-018 Lisbon', 'General Practice'),
('100000019', 'Dr. Teresa Lopes', '939012356', 'Largo do Carmo 19, 1000-019 Lisbon', 'General Practice'),
('100000020', 'Dr. Uriel Fernandes', '930123467', 'Rua da Liberdade 20, 1000-020 Lisbon', 'General Practice'),
('100000021', 'Dr. Vitor Ribeiro', '941234567', 'Rua da Saúde 21, 1000-021 Lisbon', 'Orthopedics'),
('100000022', 'Dr. Wagner Correia', '942345678', 'Avenida do Hospital 22, 1000-022 Lisbon', 'Orthopedics'),
('100000023', 'Dr. Xavier Teixeira', '943456789', 'Travessa do Hospital 23, 1000-023 Lisbon', 'Orthopedics'),
('100000024', 'Dr. Yara Gonçalves', '944567890', 'Rua da Clínica 24, 1000-024 Lisbon', 'Orthopedics'),
('100000025', 'Dr. Zé Fernandes', '945678901', 'Avenida dos Médicos 25, 1000-025 Lisbon', 'Orthopedics'),
('100000026', 'Dr. André Marques', '946789012', 'Travessa dos Médicos 26, 1000-026 Lisbon', 'Orthopedics'),
('100000027', 'Dr. Bia Rocha', '947890123', 'Rua da Medicina 27, 1000-027 Lisbon', 'Orthopedics'),
('100000028', 'Dr. Caio Dias', '948901234', 'Avenida do Enfermeiro 28, 1000-028 Lisbon', 'Orthopedics'),
('100000029', 'Dr. Diana Nunes', '949012345', 'Travessa do Enfermeiro 29, 1000-029 Lisbon', 'Cardiology'),
('100000030', 'Dr. Eduardo Reis', '940123456', 'Rua da Cirurgia 30, 1000-030 Lisbon', 'Cardiology'),
('100000031', 'Dr. Francisco Oliveira', '951234567', 'Rua do Coração 31, 1000-031 Lisbon', 'Cardiology'),
('100000032', 'Dr. Gustavo Martins', '952345678', 'Avenida do Coração 32, 1000-032 Lisbon', 'Cardiology'),
('100000033', 'Dr. Helena Fernandes', '953456789', 'Travessa do Coração 33, 1000-033 Lisbon', 'Cardiology'),
('100000034', 'Dr. Igor Costa', '954567890', 'Rua do Hospital 34, 1000-034 Lisbon', 'Cardiology'),
('100000035', 'Dr. Juliana Lima', '955678901', 'Avenida do Hospital 35, 1000-035 Lisbon', 'Cardiology'),
('100000036', 'Dr. Kevin Nogueira', '956789012', 'Travessa da Clínica 36, 1000-036 Lisbon', 'Cardiology'),
('100000037', 'Dr. Laura Ribeiro', '957890123', 'Rua da Clínica 37, 1000-037 Lisbon', 'Pediatrics'),
('100000038', 'Dr. Márcio Rodrigues', '958901234', 'Avenida dos Médicos 38, 1000-038 Lisbon', 'Pediatrics'),
('100000039', 'Dr. Natália Sousa', '959012345', 'Travessa dos Médicos 39, 1000-039 Lisbon', 'Pediatrics'),
('100000040', 'Dr. Oscar Fernandes', '950123456', 'Rua da Saúde 40, 1000-040 Lisbon', 'Pediatrics'),
('100000041', 'Dr. Patrícia Costa', '961234567', 'Rua das Crianças 41, 1000-041 Lisbon', 'Pediatrics'),
('100000042', 'Dr. Quentin Almeida', '962345678', 'Avenida das Crianças 42, 1000-042 Lisbon', 'Pediatrics'),
('100000043', 'Dr. Renata Silva', '963456789', 'Travessa das Crianças 43, 1000-043 Lisbon', 'Pediatrics'),
('100000044', 'Dr. Sérgio Fernandes', '964567890', 'Rua da Infância 44, 1000-044 Lisbon', 'Pediatrics'),
('100000045', 'Dr. Tânia Costa', '965678901', 'Avenida da Infância 45, 1000-045 Lisbon', 'Dermatology'),
('100000046', 'Dr. Ulisses Pereira', '966789012', 'Travessa da Infância 46, 1000-046 Lisbon', 'Dermatology'),
('100000047', 'Dr. Vera Santos', '967890123', 'Rua do Brincar 47, 1000-047 Lisbon', 'Dermatology'),
('100000048', 'Dr. Wilson Fernandes', '968901234', 'Avenida do Brincar 48, 1000-048 Lisbon', 'Dermatology'),
('100000049', 'Dr. Xavier Costa', '969012345', 'Travessa do Brincar 49, 1000-049 Lisbon', 'Dermatology'),
('100000050', 'Dr. Yara Silva', '960123456', 'Rua da Alegria 50, 1000-050 Lisbon', 'Dermatology'),
('100000051', 'Dr. Zilda Almeida', '971234567', 'Rua da Pele 51, 1000-051 Lisbon', 'Dermatology'),
('100000052', 'Dr. Afonso Silva', '972345678', 'Avenida da Pele 52, 1000-052 Lisbon', 'Dermatology'),
('100000053', 'Dr. Bárbara Fernandes', '973456789', 'Travessa da Pele 53, 1000-053 Lisbon', 'Neurology'),
('100000054', 'Dr. Cláudio Costa', '974567890', 'Rua do Sol 54, 1000-054 Lisbon', 'Neurology'),
('100000055', 'Dr. Nunes Diana', '975678901', 'Avenida do Sol 55, 1000-055 Lisbon', 'Neurology'),
('100000056', 'Dr. Eduardo Rocha', '976789012', 'Travessa do Sol 56, 1000-056 Lisbon', 'Neurology'),
('100000057', 'Dr. Fátima Fernandes', '977890123', 'Rua do Mar 57, 1000-057 Lisbon', 'Neurology'),
('100000058', 'Dr. Gabriel Costa', '978901234', 'Avenida do Mar 58, 1000-058 Lisbon', 'Neurology'),
('100000059', 'Dr. Helena Santos', '979012345', 'Travessa do Mar 59, 1000-059 Lisbon', 'Neurology'),
('100000060', 'Dr. Inês Almeida', '970123456', 'Rua da Luz 60, 1000-060 Lisbon', 'Neurology');
