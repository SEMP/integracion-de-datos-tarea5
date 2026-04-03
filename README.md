# Tarea 5 — Transformación de Datos con dbt

**Curso:** Introducción a la Integración de Datos  
**Autor:** Sergio Enrique Morel Peralta  
**Institución:** Facultad Politécnica — UNA

## Documento de entrega

[`docs/Tarea-Clase5-Integracion-Datos.pdf`](docs/Tarea-Clase5-Integracion-Datos.pdf)

Generado desde [`Tarea5.typ`](Tarea5.typ) (Typst). Incluye descripción del proyecto, código de todos los modelos y capturas del DAG.

---

## Entregables requeridos

| Entregable | Ubicación |
|---|---|
| Proyecto dbt inicializado | `workspaces/dbt-duckdb/mi_proyecto_dbt/` |
| `profiles.yml` (conexión MotherDuck) | `workspaces/dbt-duckdb/mi_proyecto_dbt/profiles.yml` |
| `_sources.yml` (declaración de fuentes) | `workspaces/dbt-duckdb/mi_proyecto_dbt/models/staging/_sources.yml` |
| Modelos staging (×3) | `workspaces/dbt-duckdb/mi_proyecto_dbt/models/staging/` |
| Modelo intermediate (×1) | `workspaces/dbt-duckdb/mi_proyecto_dbt/models/intermediate/` |
| Modelos mart OBT (×2) | `workspaces/dbt-duckdb/mi_proyecto_dbt/models/marts/` |
| DAG — pipeline weather | `assets/dag_weather_tarea5.png` |
| DAG — pipeline GitHub | `assets/dag_github_tarea5.png` |

## Modelos implementados

```
staging/
  stg_weather__forecast.sql     # limpieza de weather.weather (40 filas)
  stg_github__stargazers.sql    # limpieza de github.stargazers (1 fila)
  stg_github__branches.sql      # limpieza de github.branches (1 fila)

intermediate/
  int_github_actividad.sql      # join stargazers + branches

marts/
  obt_pronostico.sql            # OBT pronóstico meteorológico (materializada como table)
  obt_github_actividad.sql      # OBT actividad GitHub (materializada como table)
```

## Datos fuente

Base de datos MotherDuck `md:airbyte_curso`, cargada con Airbyte en clases anteriores:

| Tabla | Filas | Descripción |
|---|---|---|
| `weather.weather` | 40 | Pronóstico OpenWeather — 5 días, intervalos de 3 h |
| `github.branches` | 1 | Rama principal de SEMP/lib-utilidades |
| `github.stargazers` | 1 | Estrella dada al repositorio SEMP/lib-utilidades |

## Ejecutar el proyecto

```bash
cd workspaces/dbt-duckdb
source .venv/bin/activate
source mi_proyecto_dbt/set_env.sh   # exporta MOTHERDUCK_TOKEN

cd mi_proyecto_dbt
dbt deps
dbt run
```

## Seguimiento de progreso

[`docs/PROGRESO.md`](docs/PROGRESO.md)
