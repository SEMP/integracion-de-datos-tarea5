#import "@preview/basic-report:0.4.0": *

#show: it => basic-report(
  doc-category: "Integración de datos",
  doc-title: "Tarea Práctica - Clase 5",
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

= Tarea 5: Transformación de Datos con dbt

Esta tarea implementa un proyecto *dbt (data build tool)* completo sobre los datos cargados con Airbyte en clases anteriores: pronósticos meteorológicos de *OpenWeather* (`weather.weather`) y metadatos del repositorio *SEMP/lib-utilidades* en GitHub (`github.branches` y `github.stargazers`), disponibles en MotherDuck bajo la base de datos `md:airbyte_curso`. El proyecto organiza las transformaciones en tres capas — *staging*, *intermediate* y *marts* — siguiendo las convenciones de dbt.

== 0. Datos fuente

Los datos crudos sincronizados por Airbyte en clases anteriores son:

#table(
  columns: (auto, auto, 1fr),
  table.header([*Tabla*], [*Filas*], [*Descripción*]),
  [`weather.weather`],    [40], [Pronóstico de 5 días con intervalos de 3 horas — OpenWeather API],
  [`github.branches`],   [1],  [Rama principal del repositorio SEMP/lib-utilidades],
  [`github.stargazers`], [1],  [Estrella dada al repositorio SEMP/lib-utilidades],
)

== 1. Configuración del proyecto dbt

=== 1.1 Instalación y entorno virtual

El proyecto utiliza *dbt-core* con el adaptador *dbt-duckdb*, que permite conectarse a MotherDuck (DuckDB en la nube). Se creó un entorno virtual Python en `workspaces/dbt-duckdb/.venv` e instalaron las dependencias declaradas en `requirements.txt`:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r mi_proyecto_dbt/requirements.txt
```

=== 1.2 Estructura del proyecto

El proyecto dbt se ubica en `workspaces/dbt-duckdb/mi_proyecto_dbt/` e incluye los archivos de configuración y los modelos organizados en tres capas:

```
mi_proyecto_dbt/
├── dbt_project.yml          # Configuración principal del proyecto
├── profiles.yml             # Conexión a MotherDuck
├── models/
│   ├── staging/
│   │   ├── _sources.yml     # Declaración de fuentes crudas
│   │   ├── stg_weather__forecast.sql
│   │   ├── stg_github__stargazers.sql
│   │   └── stg_github__branches.sql
│   ├── intermediate/
│   │   └── int_github_actividad.sql
│   └── marts/
│       ├── obt_pronostico.sql
│       └── obt_github_actividad.sql
└── requirements.txt
```

=== 1.3 Conexión a MotherDuck (`profiles.yml`)

La conexión se configura en `profiles.yml` dentro del proyecto. El token de acceso se lee desde la variable de entorno `MOTHERDUCK_TOKEN` para evitar exponer credenciales en el repositorio:

```yaml
mi_proyecto_dbt:
  outputs:
    dev:
      type: duckdb
      path: "md:airbyte_curso?motherduck_token={{env_var('MOTHERDUCK_TOKEN')}}"
  target: dev
```

=== 1.4 Verificación de la conexión (`dbt debug`)

Se verificó la conexión a MotherDuck ejecutando `dbt debug`, obteniendo el resultado:

```
Running with dbt=1.11.7
adapter type: duckdb
adapter version: 1.10.1

profiles.yml file    [OK found and valid]
dbt_project.yml file [OK found and valid]
git                  [OK found]
Connection test:     [OK connection ok]

All checks passed!
```

== 2. Modelos staging

_En construcción._

== 3. Modelo intermediate

_En construcción._

== 4. Modelos mart

_En construcción._

== 5. DAG del proyecto

_Pendiente de captura tras ejecutar `dbt docs generate`._
