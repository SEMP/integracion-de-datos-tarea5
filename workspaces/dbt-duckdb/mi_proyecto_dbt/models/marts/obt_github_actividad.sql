{{
    config(materialized='table')
}}

WITH actividad AS
(
    SELECT *
    FROM {{ ref('int_github_actividad') }}
),

final AS
(
    SELECT
        ROW_NUMBER() OVER ()        AS estrella_id,
        starred_at,
        fecha,
        anio,
        mes,
        dia,
        usuario_login,
        usuario_github_id,
        usuario_tipo,
        usuario_es_admin,
        usuario_perfil_url,
        usuario_avatar_url,
        repositorio_nombre_completo,
        repositorio_propietario,
        repositorio_nombre,
        rama_principal_nombre,
        rama_principal_sha,
        rama_principal_protegida
    FROM actividad
)

SELECT * FROM final
