WITH pokemon AS
(
	SELECT
		*
	FROM {{ ref('int_pokemon_with_types') }}
),

final AS
(
	SELECT
		pokemon_id,
		pokemon_name,
		height,
		weight,
		base_experience,
		type_primary,
		type_secondary,
		CASE
			WHEN base_experience >= 200 THEN 'Legendary'
			WHEN base_experience >= 100 THEN 'Strong'
			ELSE 'Normal'
		END AS power_tier
	FROM pokemon
)

SELECT * FROM final
