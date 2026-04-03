-- Verifica que la temperatura mínima nunca supere a la temperatura máxima
-- en ningún intervalo del pronóstico. Es una regla de negocio meteorológica
-- fundamental: temp_min_c <= temp_max_c debe cumplirse siempre.
-- Un test de dbt pasa cuando la consulta no retorna filas.

SELECT *
FROM {{ ref('obt_pronostico') }}
WHERE temp_min_c > temp_max_c
