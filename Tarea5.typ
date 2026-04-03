#import "@preview/basic-report:0.4.0": *

#show: it => basic-report(
  doc-category: "Integración de datos",
  doc-title: "Tarea Práctica - Clase 4",
  author: "Sergio Enrique Morel Peralta",
  affiliation: "Facultad Politécnica - UNA",
  logo: image("assets/fpuna_logo_institucional.svg", width: 2cm),
  language: "es",
  compact-mode: true,
  it
)
#v(-8em)
#align(center)[
  #image("assets/fpuna_logo_institucional.svg", width: 3cm)
]

= Tarea 4: Diseño de Modelo de Datos

Esta tarea propone dos diseños alternativos de modelo de datos —un *Star Schema* y un *One Big Table* (OBT)— aplicados sobre los datos extraídos con Airbyte en la clase anterior: pronósticos meteorológicos de *OpenWeather* (tabla `weather.weather`) y metadatos del repositorio *SEMP/lib-utilidades* en GitHub (tablas `github.branches` y `github.stargazers`), disponibles en MotherDuck bajo la base de datos `md:airbyte_curso`. Para cada modelo se presenta el diagrama de tablas y relaciones, la lista de columnas y un ejemplo de query analítico.

== 0. Datos fuente

Antes de diseñar los modelos, se relevaron los campos disponibles en cada tabla cruda sincronizada por Airbyte.

=== Dataset OpenWeather — `weather.weather` (40 filas)

Pronóstico de 5 días con intervalos de 3 horas para las coordenadas lat: −25.5309750 / lon: −54.6388360.

#table(
  columns: (auto, auto, 1fr),
  table.header([*Campo JSON*], [*Tipo*], [*Descripción*]),
  [`dt`],                    [`bigint`],   [Timestamp Unix del pronóstico],
  [`dt_txt`],                [`varchar`],  [Fecha y hora en texto ("2026-03-29 00:00:00")],
  [`sys.pod`],               [`char(1)`],  [Parte del día: `d` = día, `n` = noche],
  [`main.temp`],             [`float`],    [Temperatura (°C)],
  [`main.feels_like`],       [`float`],    [Sensación térmica (°C)],
  [`main.temp_min`],         [`float`],    [Temperatura mínima del intervalo (°C)],
  [`main.temp_max`],         [`float`],    [Temperatura máxima del intervalo (°C)],
  [`main.pressure`],         [`int`],      [Presión atmosférica (hPa)],
  [`main.sea_level`],        [`int`],      [Presión a nivel del mar (hPa)],
  [`main.grnd_level`],       [`int`],      [Presión a nivel del suelo (hPa)],
  [`main.humidity`],         [`int`],      [Humedad relativa (%)],
  [`wind.speed`],            [`float`],    [Velocidad del viento (m/s)],
  [`wind.deg`],              [`int`],      [Dirección del viento (grados, 0–360)],
  [`wind.gust`],             [`float`],    [Ráfaga de viento (m/s)],
  [`clouds.all`],            [`int`],      [Cobertura nubosa (%)],
  [`pop`],                   [`float`],    [Probabilidad de precipitación (0.0–1.0)],
  [`rain.3h`],               [`float`],    [Precipitación acumulada en 3 h (mm); `null` si no llueve],
  [`visibility`],            [`float`],    [Visibilidad (metros, máx. 10 000)],
  [`weather[0].id`],         [`int`],      [Código OWM de condición climática],
  [`weather[0].main`],       [`varchar`],  [Condición principal (Clear, Clouds, Rain…)],
  [`weather[0].description`],[`varchar`],  [Descripción en español],
  [`weather[0].icon`],       [`varchar`],  [Código de ícono OWM],
)

=== Dataset GitHub — `github.branches` (1 fila) y `github.stargazers` (1 fila)

#table(
  columns: (auto, auto, 1fr),
  table.header([*Campo JSON*], [*Tipo*], [*Descripción*]),
  table.cell(colspan: 3)[*branches*],
  [`name`],           [`varchar`],   [Nombre de la rama ("main")],
  [`commit.sha`],     [`varchar`],   [SHA del último commit de la rama],
  [`commit.url`],     [`varchar`],   [URL de la API de GitHub para ese commit],
  [`protected`],      [`boolean`],   [Si la rama está protegida],
  [`repository`],     [`varchar`],   [Nombre del repositorio ("SEMP/lib-utilidades")],
  table.cell(colspan: 3)[*stargazers*],
  [`user.login`],     [`varchar`],   [Login del usuario ("SEMP")],
  [`user.id`],        [`int`],       [ID numérico de GitHub del usuario],
  [`user.type`],      [`varchar`],   [Tipo de cuenta ("User")],
  [`user.site_admin`],[`boolean`],   [Si es administrador de GitHub],
  [`user.html_url`],  [`varchar`],   [URL web del perfil],
  [`user.avatar_url`],[`varchar`],   [URL del avatar],
  [`user_id`],        [`int`],       [ID del usuario repetido a nivel raíz],
  [`repository`],     [`varchar`],   [Nombre del repositorio ("SEMP/lib-utilidades")],
  [`starred_at`],     [`timestamp`], [Fecha y hora en que se dio la estrella],
)

== 1. Modelo Dimensional — Star Schema

El modelo dimensional organiza los datos en una tabla de hechos central rodeada de tablas de dimensiones, siguiendo la metodología de Kimball. Las métricas numéricas quedan en la tabla de hechos; el contexto descriptivo (quién, cuándo, dónde, qué condición) se desplaza a las dimensiones.

=== 1.1 Dataset OpenWeather

==== Diagrama

#figure(
  image("assets/star_schema_weather.svg", width: 14cm),
  caption: "Star Schema para el dataset OpenWeather.",
)

==== Tabla de hechos: `fct_pronostico`

#table(
  columns: (auto, auto, 1fr),
  table.header([*Columna*], [*Tipo*], [*Descripción*]),
  [`pronostico_id`],       [`integer`], [Clave subrogada (PK)],
  [`fecha_id`],            [`integer`], [FK → `dim_fecha`],
  [`ubicacion_id`],        [`integer`], [FK → `dim_ubicacion`],
  [`condicion_id`],        [`integer`], [FK → `dim_condicion`],
  [`temperatura_c`],       [`float`],   [Temperatura (°C) — `main.temp`],
  [`sensacion_termica_c`], [`float`],   [Sensación térmica (°C) — `main.feels_like`],
  [`temp_min_c`],          [`float`],   [Temperatura mínima del intervalo — `main.temp_min`],
  [`temp_max_c`],          [`float`],   [Temperatura máxima del intervalo — `main.temp_max`],
  [`humedad_pct`],         [`integer`], [Humedad relativa (%) — `main.humidity`],
  [`presion_hpa`],         [`integer`], [Presión atmosférica (hPa) — `main.pressure`],
  [`presion_mar_hpa`],     [`integer`], [Presión a nivel del mar — `main.sea_level`],
  [`presion_suelo_hpa`],   [`integer`], [Presión a nivel del suelo — `main.grnd_level`],
  [`visibilidad_m`],       [`float`],   [Visibilidad en metros — `visibility`],
  [`velocidad_viento_ms`], [`float`],   [Velocidad del viento (m/s) — `wind.speed`],
  [`dir_viento_deg`],      [`integer`], [Dirección del viento (grados) — `wind.deg`],
  [`rafaga_viento_ms`],    [`float`],   [Ráfaga de viento (m/s) — `wind.gust`],
  [`cobertura_nubes_pct`], [`integer`], [Cobertura nubosa (%) — `clouds.all`],
  [`prob_precipitacion`],  [`float`],   [Probabilidad de precipitación (0–1) — `pop`],
  [`lluvia_3h_mm`],        [`float`],   [Precipitación en 3 h (mm), nullable — `rain.3h`],
)

==== Dimensión: `dim_fecha`

#table(
  columns: (auto, auto, 1fr),
  table.header([*Columna*], [*Tipo*], [*Descripción*]),
  [`fecha_id`],  [`integer`], [Clave subrogada (PK)],
  [`dt_unix`],   [`bigint`],  [Timestamp Unix original — `dt`],
  [`dt_txt`],    [`varchar`], [Fecha/hora en texto — `dt_txt`],
  [`fecha`],     [`date`],    [Parte fecha de `dt_txt`],
  [`hora`],      [`integer`], [Hora del día (0–23)],
  [`anio`],      [`integer`], [Año],
  [`mes`],       [`integer`], [Mes (1–12)],
  [`dia`],       [`integer`], [Día del mes],
  [`parte_dia`], [`char(1)`], [Parte del día: `d` = día / `n` = noche — `sys.pod`],
)

==== Dimensión: `dim_ubicacion`

#table(
  columns: (auto, auto, 1fr),
  table.header([*Columna*], [*Tipo*], [*Descripción*]),
  [`ubicacion_id`], [`integer`], [Clave subrogada (PK)],
  [`latitud`],      [`float`],   [Latitud geográfica],
  [`longitud`],     [`float`],   [Longitud geográfica],
  [`ciudad`],       [`varchar`], [Nombre de la ciudad],
  [`pais`],         [`varchar`], [Código de país],
)

==== Dimensión: `dim_condicion`

#table(
  columns: (auto, auto, 1fr),
  table.header([*Columna*], [*Tipo*], [*Descripción*]),
  [`condicion_id`],        [`integer`], [Código OWM de condición (PK) — `weather[0].id`],
  [`condicion_principal`], [`varchar`], [Condición principal (Clear, Clouds, Rain…) — `weather[0].main`],
  [`descripcion`],         [`varchar`], [Descripción en español — `weather[0].description`],
  [`icono`],               [`varchar`], [Código de ícono OWM — `weather[0].icon`],
)

=== 1.2 Dataset GitHub

==== Diagrama

#figure(
  image("assets/star_schema_github.svg", width: 14cm),
  caption: "Star Schema para el dataset GitHub.",
)

==== Tabla de hechos: `fct_estrella`

#table(
  columns: (auto, auto, 1fr),
  table.header([*Columna*], [*Tipo*], [*Descripción*]),
  [`estrella_id`],    [`integer`], [Clave subrogada (PK)],
  [`repositorio_id`], [`integer`], [FK → `dim_repositorio`],
  [`usuario_id`],     [`integer`], [FK → `dim_usuario`],
  [`fecha_id`],       [`integer`], [FK → `dim_fecha` — fecha de la estrella],
)

==== Dimensión: `dim_repositorio`

#table(
  columns: (auto, auto, 1fr),
  table.header([*Columna*], [*Tipo*], [*Descripción*]),
  [`repositorio_id`],   [`integer`], [Clave subrogada (PK)],
  [`nombre`],           [`varchar`], [Nombre corto del repositorio],
  [`propietario`],      [`varchar`], [Propietario (parte antes de `/`)],
  [`nombre_completo`],  [`varchar`], [Nombre completo — `repository`],
  [`rama_principal`],   [`varchar`], [Nombre de la rama principal — `branches.name`],
  [`sha_commit_actual`],[`varchar`], [SHA del último commit — `branches.commit.sha`],
  [`rama_protegida`],   [`boolean`], [Si la rama está protegida — `branches.protected`],
)

==== Dimensión: `dim_usuario`

#table(
  columns: (auto, auto, 1fr),
  table.header([*Columna*], [*Tipo*], [*Descripción*]),
  [`usuario_id`],     [`integer`], [Clave subrogada (PK)],
  [`login`],          [`varchar`], [Login de GitHub — `user.login`],
  [`github_user_id`], [`integer`], [ID numérico en GitHub — `user.id`],
  [`tipo`],           [`varchar`], [Tipo de cuenta — `user.type`],
  [`es_site_admin`],  [`boolean`], [Si es admin de GitHub — `user.site_admin`],
  [`perfil_url`],     [`varchar`], [URL del perfil web — `user.html_url`],
  [`avatar_url`],     [`varchar`], [URL del avatar — `user.avatar_url`],
)

==== Dimensión: `dim_fecha`

#table(
  columns: (auto, auto, 1fr),
  table.header([*Columna*], [*Tipo*], [*Descripción*]),
  [`fecha_id`], [`integer`], [Clave subrogada (PK)],
  [`fecha`],    [`date`],    [Fecha completa — parte de `starred_at`],
  [`anio`],     [`integer`], [Año],
  [`mes`],      [`integer`], [Mes (1–12)],
  [`dia`],      [`integer`], [Día del mes],
)

=== 1.3 Queries analíticos de ejemplo

Las siguientes consultas se presentan en pares —Star Schema y OBT— sobre los mismos análisis, para ilustrar la diferencia en complejidad.

==== Query 1: Temperatura máxima, mínima y promedio por día (OpenWeather)

*Star Schema* — requiere JOIN con `dim_fecha` para acceder a la columna `fecha`:

```sql
SELECT
  d.fecha,
  MAX(f.temp_max_c)              AS temp_max_c,
  MIN(f.temp_min_c)              AS temp_min_c,
  ROUND(AVG(f.temperatura_c), 1) AS temp_promedio_c
FROM fct_pronostico f
JOIN dim_fecha d ON f.fecha_id = d.fecha_id
GROUP BY d.fecha
ORDER BY d.fecha;
```

==== Query 2: Condiciones climáticas más frecuentes (OpenWeather)

*Star Schema* — JOIN con `dim_condicion` para obtener la descripción:

```sql
SELECT
  c.condicion_principal,
  c.descripcion,
  COUNT(*)                       AS cantidad_intervalos,
  ROUND(AVG(f.temperatura_c), 1) AS temp_promedio_c,
  ROUND(AVG(f.humedad_pct), 1)   AS humedad_promedio_pct
FROM fct_pronostico f
JOIN dim_condicion c ON f.condicion_id = c.condicion_id
GROUP BY c.condicion_principal, c.descripcion
ORDER BY cantidad_intervalos DESC;
```

==== Query 3: Detalle de estrellas con usuario y fecha (GitHub)

*Star Schema* — requiere JOINs con las tres dimensiones:

```sql
SELECT
  u.login           AS usuario,
  r.nombre_completo AS repositorio,
  d.fecha           AS fecha_estrella
FROM fct_estrella f
JOIN dim_usuario     u ON f.usuario_id     = u.usuario_id
JOIN dim_repositorio r ON f.repositorio_id = r.repositorio_id
JOIN dim_fecha       d ON f.fecha_id       = d.fecha_id
ORDER BY d.fecha;
```

== 2. Modelo OBT — One Big Table

=== 2.1 Dataset OpenWeather — `obt_pronostico`

Tabla única de 32 columnas que aplana todos los atributos del pronóstico. Los campos de dimensión (fecha, ubicación, condición climática) se incorporan directamente como columnas, eliminando la necesidad de JOINs. La única columna nullable es `lluvia_3h_mm`, fiel al dato crudo donde `rain` es `null` cuando no hay precipitación.

#table(
  columns: (auto, auto, auto, 1fr),
  table.header([*Columna*], [*Tipo*], [*Nullable*], [*Descripción*]),
  [`pronostico_id`],         [`integer`], [NO], [Clave primaria autoincremental],
  [`dt_unix`],               [`bigint`],  [NO], [Timestamp Unix — `dt`],
  [`dt_txt`],                [`varchar`], [NO], [Fecha y hora en texto — `dt_txt`],
  [`fecha`],                 [`date`],    [NO], [Parte fecha de `dt_txt`],
  [`hora`],                  [`integer`], [NO], [Hora del día (0–23)],
  [`anio`],                  [`integer`], [NO], [Año],
  [`mes`],                   [`integer`], [NO], [Mes (1–12)],
  [`dia`],                   [`integer`], [NO], [Día del mes],
  [`parte_dia`],             [`char(1)`], [NO], [Parte del día: `d` = día / `n` = noche — `sys.pod`],
  [`latitud`],               [`float`],   [NO], [Latitud geográfica (fijo: −25.5309750)],
  [`longitud`],              [`float`],   [NO], [Longitud geográfica (fijo: −54.6388360)],
  [`ciudad`],                [`varchar`], [NO], [Ciudad de la consulta (fijo: Ciudad del Este)],
  [`pais`],                  [`varchar`], [NO], [Código de país (fijo: PY)],
  [`condicion_codigo`],      [`integer`], [NO], [Código OWM de condición — `weather[0].id`],
  [`condicion_principal`],   [`varchar`], [NO], [Condición principal (Clear, Clouds, Rain…) — `weather[0].main`],
  [`condicion_descripcion`], [`varchar`], [NO], [Descripción en español — `weather[0].description`],
  [`condicion_icono`],       [`varchar`], [NO], [Código de ícono OWM — `weather[0].icon`],
  [`temperatura_c`],         [`float`],   [NO], [Temperatura (°C) — `main.temp`],
  [`sensacion_termica_c`],   [`float`],   [NO], [Sensación térmica (°C) — `main.feels_like`],
  [`temp_min_c`],            [`float`],   [NO], [Temperatura mínima del intervalo — `main.temp_min`],
  [`temp_max_c`],            [`float`],   [NO], [Temperatura máxima del intervalo — `main.temp_max`],
  [`humedad_pct`],           [`integer`], [NO], [Humedad relativa (%) — `main.humidity`],
  [`presion_hpa`],           [`integer`], [NO], [Presión atmosférica (hPa) — `main.pressure`],
  [`presion_mar_hpa`],       [`integer`], [NO], [Presión a nivel del mar — `main.sea_level`],
  [`presion_suelo_hpa`],     [`integer`], [NO], [Presión a nivel del suelo — `main.grnd_level`],
  [`visibilidad_m`],         [`float`],   [NO], [Visibilidad (metros) — `visibility`],
  [`velocidad_viento_ms`],   [`float`],   [NO], [Velocidad del viento (m/s) — `wind.speed`],
  [`dir_viento_deg`],        [`integer`], [NO], [Dirección del viento (grados) — `wind.deg`],
  [`rafaga_viento_ms`],      [`float`],   [NO], [Ráfaga de viento (m/s) — `wind.gust`],
  [`cobertura_nubes_pct`],   [`integer`], [NO], [Cobertura nubosa (%) — `clouds.all`],
  [`prob_precipitacion`],    [`float`],   [NO], [Probabilidad de precipitación (0–1) — `pop`],
  [`lluvia_3h_mm`],          [`float`],   [SÍ], [Precipitación en 3 h (mm); NULL si no llueve — `rain.3h`],
)

=== 2.2 Dataset GitHub — `obt_github_actividad`

Tabla única de 18 columnas que combina `github.stargazers` y `github.branches`. El evento central es la estrella dada al repositorio; los atributos del repositorio (incluyendo los de la rama principal) y del usuario se incorporan como columnas adicionales. `repositorio_propietario` y `repositorio_nombre` se derivan partiendo el campo `repository` por `/`.

#table(
  columns: (auto, auto, auto, 1fr),
  table.header([*Columna*], [*Tipo*], [*Nullable*], [*Descripción*]),
  [`estrella_id`],                [`integer`],   [NO], [Clave primaria autoincremental],
  [`starred_at`],                 [`timestamp`], [NO], [Fecha y hora en que se dio la estrella — `starred_at`],
  [`fecha`],                      [`date`],      [NO], [Parte fecha de `starred_at`],
  [`anio`],                       [`integer`],   [NO], [Año],
  [`mes`],                        [`integer`],   [NO], [Mes (1–12)],
  [`dia`],                        [`integer`],   [NO], [Día del mes],
  [`usuario_login`],              [`varchar`],   [NO], [Login del usuario — `user.login`],
  [`usuario_github_id`],          [`integer`],   [NO], [ID numérico del usuario — `user.id`],
  [`usuario_tipo`],               [`varchar`],   [NO], [Tipo de cuenta — `user.type`],
  [`usuario_es_admin`],           [`boolean`],   [NO], [Si es administrador de GitHub — `user.site_admin`],
  [`usuario_perfil_url`],         [`varchar`],   [NO], [URL web del perfil — `user.html_url`],
  [`usuario_avatar_url`],         [`varchar`],   [NO], [URL del avatar — `user.avatar_url`],
  [`repositorio_nombre_completo`],[`varchar`],   [NO], [Nombre completo del repositorio — `repository`],
  [`repositorio_propietario`],    [`varchar`],   [NO], [Propietario (parte antes de `/`)],
  [`repositorio_nombre`],         [`varchar`],   [NO], [Nombre corto (parte después de `/`)],
  [`rama_principal_nombre`],      [`varchar`],   [NO], [Nombre de la rama principal — `branches.name`],
  [`rama_principal_sha`],         [`varchar`],   [NO], [SHA del último commit — `branches.commit.sha`],
  [`rama_principal_protegida`],   [`boolean`],   [NO], [Si la rama está protegida — `branches.protected`],
)

=== 2.3 Queries analíticos de ejemplo

Los mismos tres análisis del Star Schema, ahora sobre las tablas OBT. Sin JOINs, todos los atributos están disponibles directamente.

==== Query 1: Temperatura máxima, mínima y promedio por día (OpenWeather)

*OBT* — `fecha` disponible directamente en la tabla:

```sql
SELECT
  fecha,
  MAX(temp_max_c)              AS temp_max_c,
  MIN(temp_min_c)              AS temp_min_c,
  ROUND(AVG(temperatura_c), 1) AS temp_promedio_c
FROM obt_pronostico
GROUP BY fecha
ORDER BY fecha;
```

==== Query 2: Condiciones climáticas más frecuentes (OpenWeather)

*OBT* — descripción y condición ya están en la tabla:

```sql
SELECT
  condicion_principal,
  condicion_descripcion,
  COUNT(*)                     AS cantidad_intervalos,
  ROUND(AVG(temperatura_c), 1) AS temp_promedio_c,
  ROUND(AVG(humedad_pct), 1)   AS humedad_promedio_pct
FROM obt_pronostico
GROUP BY condicion_principal, condicion_descripcion
ORDER BY cantidad_intervalos DESC;
```

==== Query 3: Detalle de estrellas con usuario y fecha (GitHub)

*OBT* — usuario, repositorio y fecha en una sola tabla:

```sql
SELECT
  usuario_login               AS usuario,
  repositorio_nombre_completo AS repositorio,
  fecha                       AS fecha_estrella
FROM obt_github_actividad
ORDER BY starred_at;
```

== 3. Comparación de modelos

=== 3.1 Comparación general

#table(
  columns: (1.4fr, 1fr, 1fr),
  table.header([*Aspecto*], [*Star Schema*], [*OBT*]),
  [Número de tablas],
    [Varias (1 fact + N dims)],
    [Una sola tabla],
  [JOINs en queries],
    [Requeridos para obtener contexto],
    [No se necesitan],
  [Redundancia de datos],
    [Mínima — el contexto vive una sola vez en cada dimensión],
    [Alta — los atributos descriptivos se repiten en cada fila],
  [Facilidad de consulta],
    [Mayor complejidad; requiere conocer las relaciones],
    [Queries simples y directos],
  [Rendimiento analítico],
    [Óptimo con índices en FKs y columnar storage],
    [Excelente en motores columnar (DuckDB, BigQuery, Snowflake)],
  [Consistencia],
    [Alta — un cambio en una dimensión se propaga automáticamente],
    [Baja — una corrección implica actualizar todas las filas],
  [Flexibilidad],
    [Alta — se agregan dimensiones sin tocar la tabla de hechos],
    [Baja — agregar contexto requiere alterar la tabla],
  [Reutilización],
    [Las dimensiones son compartibles entre múltiples facts],
    [Cada OBT es autocontenida; no hay reutilización],
  [Costo de mantenimiento],
    [Mayor — más objetos, más ETL],
    [Menor — una sola tabla que cargar y mantener],
  [Ideal para],
    [DWH empresariales, múltiples equipos consumidores, datos que cambian],
    [Exploración rápida, un solo caso de uso, datos estables],
)

=== 3.2 Análisis por dataset

==== Dataset OpenWeather

En el dataset de pronósticos, el Star Schema ofrece una ventaja concreta en la dimensión `dim_condicion`: las 40 filas del pronóstico incluyen solo unos pocos valores distintos de condición climática (Clear, Clouds, Rain), de modo que la descripción en español se almacena una sola vez por código OWM en lugar de repetirse en cada registro. La dimensión `dim_ubicacion` también evita repetir las coordenadas y el nombre de la ciudad en las 40 filas.

Sin embargo, dado que la ubicación es fija (una sola ciudad) y el horizonte del pronóstico es corto (5 días), la OBT resulta igualmente práctica: las 32 columnas son manejables, no hay riesgo real de inconsistencia y cualquier query analítico —temperatura máxima por día, promedio de humedad por condición, etc.— se escribe sin JOINs.

==== Dataset GitHub

Con solo 1 fila en cada tabla fuente, la diferencia entre modelos es marginal en términos de volumen. Sin embargo, el contraste conceptual es claro: el Star Schema separa correctamente los atributos del repositorio y del usuario en dimensiones independientes, lo que sería valioso si en el futuro se incorporaran más repositorios o más usuarios. La OBT, al combinar ambas tablas en una sola fila de 18 columnas, es más directa para consultas puntuales pero no escala bien si el repositorio tuviera cientos de ramas o miles de stargazers.

=== 3.3 ¿Cuándo elegir cada modelo?

#table(
  columns: (1fr, 1fr),
  table.header([*Elegir Star Schema cuando…*], [*Elegir OBT cuando…*]),
  [Los datos alimentan a múltiples equipos con preguntas distintas],
    [Hay un caso de uso analítico único y bien definido],
  [Las dimensiones se reutilizan en varios procesos],
    [Se prioriza la velocidad de desarrollo sobre la escalabilidad],
  [El volumen de datos es alto y la redundancia tiene costo real],
    [El volumen es pequeño y la redundancia no impacta],
  [Los atributos descriptivos cambian con el tiempo (SCD)],
    [Los datos son estables y no requieren historial de cambios],
  [Se trabaja con herramientas de BI que aprovechan el esquema relacional],
    [Se trabaja directamente con SQL ad-hoc o notebooks],
)

=== 3.4 Modelo elegido para el proyecto final

==== Dataset: accidentes de tránsito en Brasil (`datatran2026.csv`)

El dataset del proyecto final registra ocurrencias de accidentes de tránsito en rutas federales de Brasil. Cada fila representa un accidente individual e incluye atributos temporales, geográficos, de infraestructura vial, meteorológicos y de resultado (víctimas). A continuación se listan los campos disponibles:

#table(
  columns: (auto, auto, 1fr),
  table.header([*Campo*], [*Tipo*], [*Descripción*]),
  [`id`],                      [`integer`],  [Identificador único del accidente],
  [`data_inversa`],            [`date`],     [Fecha del accidente],
  [`dia_semana`],              [`varchar`],  [Día de la semana],
  [`horario`],                 [`time`],     [Hora del accidente],
  [`uf`],                      [`char(2)`],  [Estado (Unidad Federativa)],
  [`br`],                      [`integer`],  [Número de la ruta federal],
  [`km`],                      [`float`],    [Kilómetro de la ruta],
  [`municipio`],               [`varchar`],  [Municipio],
  [`causa_acidente`],          [`varchar`],  [Causa del accidente],
  [`tipo_acidente`],           [`varchar`],  [Tipo de accidente (colisión, atropello, etc.)],
  [`classificacao_acidente`],  [`varchar`],  [Clasificación: sin víctimas / con heridos / fatal],
  [`fase_dia`],                [`varchar`],  [Fase del día (amanecer, pleno día, noche, etc.)],
  [`sentido_via`],             [`varchar`],  [Sentido de la vía (creciente / decreciente)],
  [`condicao_metereologica`],  [`varchar`],  [Condición meteorológica al momento del accidente],
  [`tipo_pista`],              [`varchar`],  [Tipo de pista (simple, doble, múltiple)],
  [`tracado_via`],             [`varchar`],  [Trazado (recta, curva, declive, etc.)],
  [`uso_solo`],                [`varchar`],  [Uso del suelo: urbano o rural],
  [`pessoas`],                 [`integer`],  [Total de personas involucradas],
  [`mortos`],                  [`integer`],  [Número de fallecidos],
  [`feridos_leves`],           [`integer`],  [Número de heridos leves],
  [`feridos_graves`],          [`integer`],  [Número de heridos graves],
  [`ilesos`],                  [`integer`],  [Número de ilesos],
  [`ignorados`],               [`integer`],  [Personas con estado desconocido],
  [`feridos`],                 [`integer`],  [Total de heridos (leves + graves)],
  [`veiculos`],                [`integer`],  [Número de vehículos involucrados],
  [`latitude`],                [`float`],    [Latitud geográfica del accidente],
  [`longitude`],               [`float`],    [Longitud geográfica del accidente],
  [`regional`],                [`varchar`],  [Superintendencia regional (SPRF-XX)],
  [`delegacia`],               [`varchar`],  [Delegacía de policía responsable],
  [`uop`],                     [`varchar`],  [Unidad operacional],
)

==== Justificación: Star Schema

Para este dataset se elige el *Star Schema* por las siguientes razones:

*Alto volumen con alta repetición de dimensiones.* El dataset contiene miles de accidentes registrados a lo largo del año. Atributos como `uf`, `municipio`, `tipo_pista`, `tracado_via` o `condicao_metereologica` toman valores de un conjunto reducido y se repiten en miles de filas. Almacenarlos una sola vez en dimensiones reduce significativamente el tamaño de la tabla de hechos y mejora el rendimiento de las consultas analíticas.

*Dimensiones naturales y bien definidas.* Los campos del dataset se agrupan de forma clara en al menos cinco dimensiones independientes:

#table(
  columns: (auto, 1fr),
  table.header([*Dimensión*], [*Campos que agrupa*]),
  [`dim_fecha`],        [`data_inversa`, `dia_semana`, `horario`, `fase_dia`],
  [`dim_localizacion`], [`uf`, `br`, `km`, `municipio`, `latitude`, `longitude`, `regional`, `delegacia`, `uop`],
  [`dim_causa`],        [`causa_acidente`, `tipo_acidente`, `classificacao_acidente`],
  [`dim_via`],          [`tipo_pista`, `tracado_via`, `sentido_via`, `uso_solo`],
  [`dim_clima`],        [`condicao_metereologica`],
)

*Múltiples ejes de análisis.* El dataset es naturalmente multidimensional: los mismos hechos (víctimas, vehículos) se analizan por fecha, por región, por causa, por tipo de vía y por condición climática. El Star Schema está diseñado exactamente para este patrón.

*Consistencia ante correcciones.* Si se corrige el nombre de un municipio o la clasificación de una causa, basta actualizar una fila en la dimensión correspondiente; en una OBT habría que actualizar miles de filas.

En contraste, una OBT para este dataset repetiría las mismas cadenas de texto (`"Velocidade Incompatível"`, `"Chuva"`, `"Curva"`) en cada uno de los miles de registros, incrementando el almacenamiento sin aportar valor analítico adicional.
