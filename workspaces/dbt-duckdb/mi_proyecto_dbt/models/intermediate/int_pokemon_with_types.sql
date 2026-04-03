WITH pokemon AS
(
	SELECT
		*
	FROM {{ ref('stg_pokemon') }}
),
renamed AS
(
	SELECT
		pokemon_id,
		pokemon_name,
		height,
		weight,
		base_experience,
		types->0->'type'->>'name' AS type_primary,
		types->1->'type'->>'name' AS type_secondary
	FROM pokemon
)

SELECT * FROM renamed
