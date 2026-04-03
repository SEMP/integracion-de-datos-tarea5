WITH source AS
(
    SELECT *
    FROM {{ source('github', 'branches') }}
),

renamed AS
(
    SELECT
        repository                      AS repositorio_nombre_completo,
        name                            AS rama_nombre,
        commit.sha                      AS rama_commit_sha,
        commit.url                      AS rama_commit_url,
        protected                       AS rama_protegida

    FROM source
)

SELECT * FROM renamed
