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

### Documento de entrega

[`docs/Tarea-Clase6-Integracion-Datos.pdf`](docs/Tarea-Clase6-Integracion-Datos.pdf)

Generado desde [`Tarea6.typ`](Tarea6.typ) (Typst). Incluye tests genéricos, dbt-expectations, singular tests, documentación de modelos y capturas del DAG. `dbt build` PASS=40.

### Entregables

| Entregable | Ubicación |
|---|---|
| `packages.yml` con dbt-expectations | `workspaces/dbt-duckdb/mi_proyecto_dbt/packages.yml` |
| Tests genéricos (28) | `_models.yml` en staging, intermediate y marts |
| Tests dbt-expectations (3) | `_models.yml` en staging y marts |
| Singular tests (3) | `workspaces/dbt-duckdb/mi_proyecto_dbt/tests/` |
| Documentación de modelos y columnas | `_models.yml` en cada capa |
| DAG — singular test weather (parte_dia) | `assets/dag_weather_test_day_tarea6.png` |
| DAG — singular test weather (temperatura) | `assets/dag_weather_test_temperature_tarea6.png` |
| DAG — singular test GitHub (repositorio) | `assets/dag_github_test_repository_tarea6.png` |
| Resultado `dbt build` | `assets/dbt_build_tarea6.png` |

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

---

## Tarea 7 — Orquestación y Visualización

### Documento de entrega

[`docs/Tarea-Clase7-Integracion-Datos.pdf`](docs/Tarea-Clase7-Integracion-Datos.pdf)

Generado desde [`Tarea7.typ`](Tarea7.typ) (Typst). Pipeline ELT completo: MySQL → Airbyte → MotherDuck → dbt → Metabase, orquestado con Prefect.

### Seguimiento

[`docs/PROGRESO_7.md`](docs/PROGRESO_7.md)

### Entregables

| Entregable | Ubicación |
|---|---|
| Docker: MySQL + phpMyAdmin + Metabase | `workspaces/maven-fuzzy/containers/` |
| Schema e initdb | `workspaces/maven-fuzzy/containers/initdb/` |
| Proyecto dbt | `workspaces/maven-fuzzy/dbt_maven_fuzzy/` |
| Pipeline Prefect | `workspaces/maven-fuzzy/prefect/ecommerce_pipeline.py` |
| Captura Prefect UI | `assets/prefect_pipeline_tarea7.png` |
| Dashboard Metabase (sin filtros) | `assets/dashboard_maven_fuzzy.png` |
| Dashboard Metabase (filtrado) | `assets/dashboard_maven_fuzzy_filtrado.png` |
| Configuración conexión DuckDB | `assets/configuracion_metabase_db.png` |

### Dataset: Maven Fuzzy Factory

Los archivos CSV del dataset se obtienen desde:

**[Maven Analytics Data Playground — Toy Store E-Commerce Database](https://mavenanalytics.io/data-playground/toy-store-e-commerce-database)**

Descargar el `.zip`, descomprimir y colocar los CSVs en una carpeta local. Configurar la ruta en `workspaces/maven-fuzzy/containers/.env` (ver `example.env`).

| Tabla | Registros |
|---|---|
| `website_sessions` | 472,871 |
| `website_pageviews` | 1,188,124 |
| `orders` | 32,313 |
| `order_items` | 40,025 |
| `order_item_refunds` | 1,731 |
| `products` | 4 |

### Modelos dbt

```
staging/                         # views en maven_fuzzy_staging
  stg_sessions.sql
  stg_orders.sql
  stg_order_items.sql
  stg_pageviews.sql
  stg_refunds.sql

marts/                           # tables en maven_fuzzy_marts
  obt_orders_enriched.sql        # One Big Table — base del dashboard
  fct_daily_sales.sql
  fct_channel_performance.sql
  fct_product_performance.sql
```

`dbt run`: PASS=9 | `dbt test`: PASS=20

---

## Ejecutar el proyecto

### Tareas 5 y 6 (dbt con MotherDuck)

**1. Configurar el token de MotherDuck**

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

### Tarea 7 (Pipeline completo ELT)

**1. Levantar infraestructura Docker**

```bash
cd workspaces/maven-fuzzy/containers
cp example.env .env
# Editar .env: ajustar CSV_DIR (ruta a los CSVs de Maven Fuzzy) y credenciales
docker compose up -d
```

**2. Ejecutar dbt**

```bash
cd workspaces/maven-fuzzy/dbt_maven_fuzzy
cp set_env.example.sh set_env.sh
# Editar set_env.sh con MOTHERDUCK_TOKEN real
source set_env.sh
dbt deps
dbt run
dbt test
```

**3. Ejecutar pipeline Prefect**

```bash
# Terminal 1
prefect server start

# Terminal 2
prefect config set PREFECT_API_URL=http://127.0.0.1:4200/api
cd workspaces/maven-fuzzy/prefect
cp .env.example .env
# Editar .env con credenciales reales
python ecommerce_pipeline.py
```
