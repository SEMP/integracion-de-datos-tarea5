# Tareas — Introducción a la Integración de Datos

**Curso:** Introducción a la Integración de Datos  
**Autor:** Sergio Enrique Morel Peralta  
**Institución:** Facultad Politécnica — UNA

---

## Tarea 5 — Transformación de Datos con dbt

### Documento de entrega

[`docs/Tarea-Clase5-Integracion-Datos.pdf`](docs/Tarea-Clase5-Integracion-Datos.pdf)

Generado desde [`Tarea5.typ`](Tarea5.typ) (Typst). Incluye descripción del proyecto, código de todos los modelos y capturas del DAG.

### Entregables

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

### Modelos implementados

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

### Seguimiento

[`docs/PROGRESO_5.md`](docs/PROGRESO_5.md)

---

## Tarea 6 — Testing y Documentación con dbt

Extiende el proyecto de la Tarea 5 agregando tests y documentación en el mismo repositorio.
Todos los tests deben pasar con `dbt build`.

### Entregables

| Entregable | Ubicación |
|---|---|
| `packages.yml` con dbt-expectations | `workspaces/dbt-duckdb/mi_proyecto_dbt/packages.yml` |
| Tests genéricos (≥5) | archivos `_models.yml` / `_sources.yml` en cada capa |
| Tests dbt-expectations (≥3) | archivos `_models.yml` en cada capa |
| Singular tests (≥2) | `workspaces/dbt-duckdb/mi_proyecto_dbt/tests/` |
| Documentación de modelos y columnas | archivos `_models.yml` en cada capa |
| DAG con documentación generada | `assets/` (pendiente) |

### Seguimiento

[`docs/PROGRESO_6.md`](docs/PROGRESO_6.md)

---

## Datos fuente

Base de datos MotherDuck `md:airbyte_curso`, cargada con Airbyte en clases anteriores:

| Tabla | Filas | Descripción |
|---|---|---|
| `weather.weather` | 40 | Pronóstico OpenWeather — 5 días, intervalos de 3 h |
| `github.branches` | 1 | Rama principal de SEMP/lib-utilidades |
| `github.stargazers` | 1 | Estrella dada al repositorio SEMP/lib-utilidades |

## Ejecutar el proyecto

**1. Configurar el token de MotherDuck**

`set_env.sh` está en `.gitignore` y no se versiona. Crearlo a partir de la plantilla incluida:

```bash
cd workspaces/dbt-duckdb/mi_proyecto_dbt
cp set_env.example.sh set_env.sh
# Editar set_env.sh y reemplazar TU_TOKEN con el token real de MotherDuck
```

**2. Ejecutar modelos**

```bash
cd workspaces/dbt-duckdb
source .venv/bin/activate
source mi_proyecto_dbt/set_env.sh

cd mi_proyecto_dbt
dbt deps
dbt run
```

**3. Ejecutar modelos + tests (Tarea 6)**

```bash
dbt build
```
