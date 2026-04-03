WITH source AS
(
    SELECT *
    FROM {{ source('github', 'stargazers') }}
),

renamed AS
(
    SELECT
        -- usuario (user es un struct, user_id está en el nivel raíz)
        user_id                         AS usuario_github_id,
        user.login                      AS usuario_login,
        user.type                       AS usuario_tipo,
        user.site_admin                 AS usuario_es_admin,
        user.html_url                   AS usuario_perfil_url,
        user.avatar_url                 AS usuario_avatar_url,

        -- repositorio
        repository                      AS repositorio_nombre_completo,

        -- evento
        starred_at,
        CAST(starred_at AS DATE)        AS fecha,
        YEAR(starred_at)                AS anio,
        MONTH(starred_at)               AS mes,
        DAY(starred_at)                 AS dia

    FROM source
)

SELECT * FROM renamed
