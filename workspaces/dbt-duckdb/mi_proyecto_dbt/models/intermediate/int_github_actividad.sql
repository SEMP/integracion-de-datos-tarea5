WITH stargazers AS
(
    SELECT *
    FROM {{ ref('stg_github__stargazers') }}
),

branches AS
(
    SELECT *
    FROM {{ ref('stg_github__branches') }}
),

joined AS
(
    SELECT
        -- evento estrella
        stargazers_t.starred_at,
        stargazers_t.fecha,
        stargazers_t.anio,
        stargazers_t.mes,
        stargazers_t.dia,

        -- usuario
        stargazers_t.usuario_github_id,
        stargazers_t.usuario_login,
        stargazers_t.usuario_tipo,
        stargazers_t.usuario_es_admin,
        stargazers_t.usuario_perfil_url,
        stargazers_t.usuario_avatar_url,

        -- repositorio
        stargazers_t.repositorio_nombre_completo,
        SPLIT_PART(stargazers_t.repositorio_nombre_completo, '/', 1) AS repositorio_propietario,
        SPLIT_PART(stargazers_t.repositorio_nombre_completo, '/', 2) AS repositorio_nombre,

        -- rama principal (del join con branches)
        branches_t.rama_nombre              AS rama_principal_nombre,
        branches_t.rama_commit_sha          AS rama_principal_sha,
        branches_t.rama_protegida           AS rama_principal_protegida

    FROM stargazers AS stargazers_t
    LEFT JOIN branches AS branches_t
        ON stargazers_t.repositorio_nombre_completo = branches_t.repositorio_nombre_completo
)

SELECT * FROM joined
