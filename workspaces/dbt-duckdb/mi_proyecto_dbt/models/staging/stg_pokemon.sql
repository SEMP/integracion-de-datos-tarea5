WITH source AS
(
	SELECT
		*
	FROM {{ source('raw', 'pokemon') }}
),

renamed AS
(
	SELECT
		id AS pokemon_id,
		name AS pokemon_name,
		height,
		weight,
		base_experience,
		types,
		_airbyte_extracted_at AS loaded_at
	FROM source
)

SELECT * FROM renamed
