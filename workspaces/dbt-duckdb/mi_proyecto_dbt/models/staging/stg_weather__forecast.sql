WITH source AS
(
    SELECT
        *
    FROM {{ source('weather', 'weather') }}
),

renamed AS
(
    SELECT
        -- tiempo
        dt                              AS dt_unix,
        dt_txt,
        CAST(dt_txt AS DATE)            AS fecha,
        HOUR(CAST(dt_txt AS TIMESTAMP)) AS hora,
        YEAR(CAST(dt_txt AS TIMESTAMP)) AS anio,
        MONTH(CAST(dt_txt AS TIMESTAMP)) AS mes,
        DAY(CAST(dt_txt AS TIMESTAMP))  AS dia,
        sys.pod                         AS parte_dia,

        -- ubicacion (fija para esta fuente)
        -25.5309750                     AS latitud,
        -54.6388360                     AS longitud,
        'Ciudad del Este'               AS ciudad,
        'PY'                            AS pais,

        -- condicion climatica (weather es un array, se toma el primer elemento)
        weather[1].id                   AS condicion_codigo,
        weather[1].main                 AS condicion_principal,
        weather[1].description          AS condicion_descripcion,
        weather[1].icon                 AS condicion_icono,

        -- temperatura
        main.temp                       AS temperatura_c,
        main.feels_like                 AS sensacion_termica_c,
        main.temp_min                   AS temp_min_c,
        main.temp_max                   AS temp_max_c,

        -- humedad y presion
        main.humidity                   AS humedad_pct,
        main.pressure                   AS presion_hpa,
        main.sea_level                  AS presion_mar_hpa,
        main.grnd_level                 AS presion_suelo_hpa,

        -- viento
        wind.speed                      AS velocidad_viento_ms,
        wind.deg                        AS dir_viento_deg,
        wind.gust                       AS rafaga_viento_ms,

        -- nubes y precipitacion
        clouds['all']                   AS cobertura_nubes_pct,
        pop                             AS prob_precipitacion,
        rain['3h']                      AS lluvia_3h_mm,
        visibility                      AS visibilidad_m

    FROM source
)

SELECT * FROM renamed