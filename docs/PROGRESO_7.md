# Progreso - Tarea 7: Orquestación y Visualización

## Objetivo

Implementar el pipeline completo ELT para el dataset Maven Fuzzy Factory:
MySQL -> Airbyte -> MotherDuck -> dbt -> Metabase, orquestado con Prefect.

---

## Checklist de entregables

### 0. MySQL con Docker: base de datos fuente
- [x] Dataset descargado desde Maven Analytics Data Playground (CSV)
- [x] `docker-compose.yaml` con MySQL 8.0 + phpMyAdmin en `workspaces/maven-fuzzy/mysql-container/`
- [x] `example.env` con todas las variables requeridas (`MYSQL_*`, `PMA_PORT`, `CSV_DIR`)
- [x] `initdb/01_schema.sql` — crea las 6 tablas con tipos exactos del modelo de datos
- [x] `initdb/02_load_data.sql` — carga los CSVs con `LOAD DATA INFILE` desde `/csv`
- [x] `.gitignore` corregido: eliminado `*.env`, mantenido `.env` y `.env.*` (permite versionar `example.env`)
- [x] `docker compose up -d` ejecutado y contenedor corriendo
- [x] Datos verificados en phpMyAdmin (`localhost:8095`): products=4, orders=32313, order_items=40025, order_item_refunds=1731, website_sessions=472871, website_pageviews=1188124
- Nota: volumen CSV montado sin `:ro` — el entrypoint de MySQL necesita hacer `chown` en el directorio; los archivos no son modificados.

### 1. Airbyte: Connection MySQL -> MotherDuck
- [x] Source `MySQL_Maven-Fuzzy-Factory` configurado (host: IP ZeroTier notebook Linux, port: 3306, db: `maven_fuzzy_factory`, user: `airbyte`)
- [x] Destination `MotherDuck_maven_fuzzy` configurado (`md:airbyte_curso`, schema: `maven_fuzzy`)
- [x] Connection creada: Full refresh | Overwrite, schedule Manual, 6 tablas seleccionadas
- [x] `AIRBYTE_CONNECTION_ID`: `39cdf568-8a26-4c2e-95fc-b6bc0dc989a4`
- [x] Sync completado y tablas disponibles en MotherDuck (`airbyte_curso.maven_fuzzy.*`)
- Nota: schema destino es `maven_fuzzy` (no `main` como en el repo del profesor) — requiere ajustar `schema: maven_fuzzy` en `_sources.yml` de dbt

### 2. dbt: Modelos en `main_staging` y `main_marts`
- [ ] Workspace `workspaces/maven-fuzzy/` configurado (copiado/adaptado del repo del profesor)
- [ ] `profiles.yml` con conexión a `md:airbyte_curso` via `MOTHERDUCK_TOKEN`
- [ ] `.env` y `.env.example` configurados (fuera de git)
- [ ] Modelos staging ejecutándose (`main_staging`):
  - [ ] `stg_sessions.sql`
  - [ ] `stg_orders.sql`
  - [ ] `stg_order_items.sql`
  - [ ] `stg_pageviews.sql`
  - [ ] `stg_refunds.sql`
- [ ] Modelos mart ejecutándose (`main_marts`):
  - [ ] `fct_daily_sales.sql`
  - [ ] `fct_channel_performance.sql`
  - [ ] `fct_product_performance.sql`
  - [ ] `obt_orders_enriched.sql`
- [ ] `dbt run` sin errores

### 3. Prefect: Pipeline completo con `.env` configurado
- [ ] Dependencias instaladas (`prefect`, `prefect-dbt`, `httpx`, `python-dotenv`)
- [ ] `.env` con `AIRBYTE_CONNECTION_ID`, `AIRBYTE_HOST`, `AIRBYTE_PORT`, `AIRBYTE_USERNAME`, `AIRBYTE_PASSWORD`, `MOTHERDUCK_TOKEN`
- [ ] `ecommerce_pipeline.py` adaptado al workspace local
- [ ] Flow `ecommerce_pipeline` ejecutando las 3 tasks: `extract_and_load`, `transform`, `test_data`
- [ ] Ejecución exitosa visible en Prefect UI (`prefect server start` en `localhost:4200`)
- [ ] Captura de Prefect UI con ejecución exitosa

### 4. Metabase: Dashboard con >= 5 visualizaciones y >= 2 filtros
- [ ] Metabase corriendo via Docker con driver DuckDB (`localhost:3000`)
- [ ] Conexión a MotherDuck configurada en Metabase (database `md:airbyte_curso`, token separado)
- [ ] Visualización 1: KPIs principales — 4 Number cards (Total Orders, Revenue, Margin, AOV) desde `main_marts.obt_orders_enriched`
- [ ] Visualización 2: Revenue por Mes — Line/Bar chart desde `main_marts.obt_orders_enriched`
- [ ] Visualización 3: Conversion por Canal — Table con formato condicional desde `main_marts.fct_channel_performance`
- [ ] Visualización 4: Revenue por Producto — Pie/Bar chart desde `main_marts.obt_orders_enriched`
- [ ] Visualización 5: Ventas Diarias — Line chart (últimos 30 días) desde `main_marts.fct_daily_sales`
- [ ] Filtro 1: Date range (order_month / order_date)
- [ ] Filtro 2: UTM Source o Device type
- [ ] Captura del dashboard completo

### 5. Capturas requeridas
- [ ] `assets/prefect_pipeline_tarea7.png` — Prefect UI con ejecución exitosa
- [ ] `assets/metabase_dashboard_tarea7.png` — Dashboard completo con visualizaciones

---

## Estructura del workspace

```
workspaces/maven-fuzzy/
├── .env                    # Credenciales (en .gitignore)
├── .env.example            # Plantilla sin credenciales
├── dbt/
│   ├── dbt_project.yml     # Proyecto: maven_fuzzy_factory
│   ├── profiles.yml        # Conexion a md:airbyte_curso
│   ├── packages.yml
│   ├── models/
│   │   ├── staging/
│   │   │   ├── _sources.yml
│   │   │   ├── _stg__models.yml
│   │   │   ├── stg_sessions.sql
│   │   │   ├── stg_orders.sql
│   │   │   ├── stg_order_items.sql
│   │   │   ├── stg_pageviews.sql
│   │   │   └── stg_refunds.sql
│   │   └── marts/
│   │       ├── _marts__models.yml
│   │       ├── fct_daily_sales.sql
│   │       ├── fct_channel_performance.sql
│   │       ├── fct_product_performance.sql
│   │       └── obt_orders_enriched.sql
│   └── tests/
│       └── assert_positive_revenue.sql
└── prefect/
    └── ecommerce_pipeline.py
```

---

## Modelos dbt requeridos por las visualizaciones

| Modelo | Schema | Visualización que lo consume |
|---|---|---|
| `obt_orders_enriched` | `main_marts` | KPIs, Revenue por Mes, Revenue por Producto |
| `fct_channel_performance` | `main_marts` | Conversion por Canal |
| `fct_daily_sales` | `main_marts` | Ventas Diarias |

---

## Estado general

| Componente | Estado |
|---|---|
| MySQL con Docker (schema + carga CSV) | Listo -- 1,735,166 registros totales en 6 tablas |
| Airbyte MySQL -> MotherDuck | Listo -- sync completado |
| dbt modelos staging | Pendiente |
| dbt modelos mart | Pendiente |
| Prefect pipeline | Pendiente |
| Metabase dashboard | Pendiente |
| Capturas | Pendiente |
