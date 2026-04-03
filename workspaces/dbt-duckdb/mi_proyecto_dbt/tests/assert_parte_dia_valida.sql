-- Verifica que parte_dia solo contenga los valores válidos de la API de OpenWeather:
-- 'd' (day) o 'n' (night).
--
-- Este test cubre obt_pronostico (mart). El tipo VARCHAR está garantizado porque
-- el modelo de staging aplica json_extract_string(sys.pod, '$') para normalizar
-- el campo antes de que llegue a capas downstream.
-- Un test de dbt pasa cuando la consulta no retorna filas.

SELECT *
FROM {{ ref('obt_pronostico') }}
WHERE parte_dia NOT IN ('d', 'n')
