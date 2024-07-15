#
CREATE MATERIALIZED VIEW historial_paciente AS
SELECT
    c.id, c.ssn, c.nif, c.nome AS nome,
    c.data AS data,
    EXTRACT(YEAR FROM c.data) AS ano,
    EXTRACT(MONTH FROM c.data) AS mes,
    EXTRACT(DAY FROM c.data) AS dia_do_mes,
    cl.morada AS localidade,
    m.especialidade AS especialidade,
    'receita' AS tipo,
    r.medicamento AS chave,
    r.quantidade AS valor
FROM consulta c
LEFT JOIN clinica cl ON c.nome = cl.nome
LEFT JOIN medico m ON c.nif = m.nif
LEFT JOIN receita r ON c.codigo_sns = r.codigo_sns

UNION ALL

SELECT
    c.id, c.ssn, c.nif, c.nome AS nome,
    c.data AS data,
    EXTRACT(YEAR FROM c.data) AS ano,
    EXTRACT(MONTH FROM c.data) AS mes,
    EXTRACT(DAY FROM c.data) AS dia_do_mes,
    cl.morada AS localidade,
    m.especialidade AS especialidade,
    'observacao' AS tipo,
    o.parametro AS chave,
    o.valor AS valor
FROM consulta c
LEFT JOIN clinica cl ON c.nome = cl.nome
LEFT JOIN medico m ON c.nif = m.nif
LEFT JOIN observacao o ON c.id = o.id

ORDER BY id, tipo;

#
WITH orthopedic_observations AS (
    SELECT p.ssn, p.chave AS sintoma, p.data
    FROM historial_paciente p
    WHERE p.especialidade = 'Orthopedics' AND p.tipo = 'observacao' AND p.valor IS NULL),
 
symptom_intervals AS (
    SELECT ssn, sintoma, data, LEAD(data) OVER (PARTITION BY ssn, sintoma ORDER BY data) AS prox_data
    FROM orthopedic_observations),

max_intervals as (
  SELECT ssn, MAX(prox_data - data) AS intervalo_temporal_max
  FROM symptom_intervals
  WHERE prox_data IS NOT NULL
  GROUP BY ssn)
  
SELECT ssn 
FROM max_intervals 
WHERE intervalo_temporal_max = ALL (SELECT MAX(intervalo_temporal_max) FROM max_intervals)

#
WITH cardiology_medications AS (
    SELECT ssn, chave AS medicamento, EXTRACT(YEAR FROM data) AS ano, EXTRACT(MONTH FROM data) AS mes
    FROM historial_paciente
    WHERE especialidade = 'Cardiology' AND tipo = 'receita' AND data >= CURRENT_DATE - INTERVAL '1 year'
    GROUP BY ssn, chave, EXTRACT(YEAR FROM data), EXTRACT(MONTH FROM data)
)

SELECT DISTINCT medicamento
FROM cardiology_medications
GROUP BY ssn, medicamento
HAVING COUNT(DISTINCT mes) = 12;

#
SELECT chave AS medicamento, SUM(valor) AS total
FROM historial_paciente
WHERE ano = 2023 and tipo = 'receita'
GROUP BY chave;

SELECT localidade,nome AS clinica,chave AS medicamento,
    SUM(valor) AS total
FROM historial_paciente
WHERE ano = 2023 and tipo = 'receita'
GROUP BY localidade, nome, chave;

SELECT mes,dia_do_mes,chave AS medicamento,
    SUM(valor) AS total
FROM historial_paciente
WHERE ano = 2023 and tipo = 'receita'   
GROUP BY mes, dia_do_mes, chave;

SELECT m.especialidade,m.nome AS nome_medico,
    hp.chave AS medicamento,
    SUM(hp.valor) AS total
FROM historial_paciente hp
JOIN medico m ON hp.nif = m.nif
WHERE hp.ano = 2023 and hp.tipo = 'receita'
GROUP BY m.especialidade, m.nome, hp.chave;

#
WITH data_agregada AS (
    SELECT hp.localidade AS clinica,
        m.especialidade AS especialidade,
        m.nome AS nome_medico,
        hp.chave AS observacao,
        AVG(CAST(hp.valor AS NUMERIC)) AS media,
        STDDEV(CAST(hp.valor AS NUMERIC)) AS desvio_padrao
    FROM historial_paciente hp
    JOIN medico m ON hp.nif = m.nif
    WHERE hp.valor IS NOT NULL and hp.tipo = 'observaçâo'
    GROUP BY 
        GROUPING SETS (
            (hp.localidade, m.especialidade, m.nome, hp.chave),
            (hp.localidade, m.especialidade, hp.chave),
            (hp.localidade, hp.chave),
            (hp.chave)
        )
)
SELECT 
    COALESCE(clinica, 'Todas as Clínicas') AS clinica,
    COALESCE(especialidade, 'Todas as Especialidade') AS especialidade,
    COALESCE(nome_medico, 'Todos os Médicos') AS nome_medico,
    observacao,media,desvio_padrao
FROM data_agregada
ORDER BY observacao,clinica,especialidade,nome_medico;
