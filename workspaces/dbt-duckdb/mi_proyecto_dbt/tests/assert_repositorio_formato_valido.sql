-- Verifica que repositorio_nombre_completo tenga formato válido 'owner/repo':
-- tanto el propietario como el nombre del repositorio deben ser strings no vacíos.
-- Un formato inválido (ej. '/repo', 'owner/', '/') produciría partes vacías al
-- hacer SPLIT_PART, lo que indicaría datos corruptos del conector de GitHub en Airbyte.
-- Un test de dbt pasa cuando la consulta no retorna filas.

SELECT *
FROM {{ ref('obt_github_actividad') }}
WHERE repositorio_propietario = ''
   OR repositorio_nombre = ''
