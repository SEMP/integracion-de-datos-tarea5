-- Verifica que parte_dia solo contenga los valores válidos de la API de OpenWeather:
-- 'd' (day) o 'n' (night).
--
-- Airbyte almacena el campo sys de OpenWeather como columna JSON en MotherDuck
-- (visible como {"pod":"n"}). Al acceder sys.pod en el modelo de staging, DuckDB
-- retorna un valor de tipo JSON. Comparar ese valor directamente con 'd' o 'n'
-- falla porque accepted_values en el _models.yml intenta parsearlo como JSON.
--
-- Se usa json_extract_string para extraer el valor real de la cadena JSON sin
-- las comillas dobles que agrega la serialización JSON de DuckDB.
-- Un test de dbt pasa cuando la consulta no retorna filas.

SELECT *
FROM {{ ref('obt_pronostico') }}
WHERE json_extract_string(parte_dia, '$') NOT IN ('d', 'n')
