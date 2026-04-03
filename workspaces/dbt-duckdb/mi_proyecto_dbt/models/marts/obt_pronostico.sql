{{
    config(materialized='table')
}}

WITH forecast AS
(
    SELECT *
    FROM {{ ref('stg_weather__forecast') }}
),

final AS
(
    SELECT
        ROW_NUMBER() OVER ()    AS pronostico_id,
        dt_unix,
        dt_txt,
        fecha,
        hora,
        anio,
        mes,
        dia,
        parte_dia,
        latitud,
        longitud,
        ciudad,
        pais,
        condicion_codigo,
        condicion_principal,
        condicion_descripcion,
        condicion_icono,
        temperatura_c,
        sensacion_termica_c,
        temp_min_c,
        temp_max_c,
        humedad_pct,
        presion_hpa,
        presion_mar_hpa,
        presion_suelo_hpa,
        visibilidad_m,
        velocidad_viento_ms,
        dir_viento_deg,
        rafaga_viento_ms,
        cobertura_nubes_pct,
        prob_precipitacion,
        lluvia_3h_mm
    FROM forecast
)

SELECT * FROM final
