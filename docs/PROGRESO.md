# Progreso - Tarea 5: Transformación de Datos con dbt

## Datos fuente (MotherDuck — `md:airbyte_curso`)

- `weather.weather` — pronósticos OpenWeather (40 filas)
- `github.branches` — ramas del repo SEMP/lib-utilidades (1 fila)
- `github.stargazers` — estrellas del repo (1 fila)

---

## Checklist de entregables

### 1. Proyecto dbt inicializado y configurado
- [x] Proyecto copiado a `workspaces/dbt-duckdb/mi_proyecto_dbt/` (`.git` interno eliminado)
- [x] `dbt_project.yml` configurado con nombre `mi_proyecto_dbt` y rutas de modelos
- [x] `profiles.yml` dentro del proyecto, conectado a `md:airbyte_curso` vía `MOTHERDUCK_TOKEN`
- [x] `dbt debug` exitoso (conexión verificada — dbt 1.11.7, adapter duckdb 1.10.1)

### 2. Modelos staging (mínimo 2, uno por source)
- [x] `staging/stg_weather__forecast.sql` — limpieza de `weather.weather` (PASS)
- [x] `staging/stg_github__stargazers.sql` — limpieza de `github.stargazers` (PASS)
- [x] `staging/stg_github__branches.sql` — limpieza de `github.branches` (PASS)

### 3. Archivo `_sources.yml`
- [x] Source `weather` apuntando al schema `weather`, tabla `weather`
- [x] Source `github` apuntando al schema `github`, tablas `branches` y `stargazers`

### 4. Modelo intermediate (mínimo 1)
- [x] `intermediate/int_github_actividad.sql` — join de stargazers + branches enriquecido (PASS)

### 5. Modelo mart (mínimo 1, dimensional u OBT)
- [x] Opción elegida: **OBT** por simplicidad dado el bajo volumen de datos
  - [x] `marts/obt_pronostico.sql` — tabla única para análisis del pronóstico weather (PASS)
  - [x] `marts/obt_github_actividad.sql` — tabla única para actividad GitHub (PASS)

### 6. Captura del DAG
- [x] `dbt docs generate` ejecutado
- [x] `dbt docs serve` corriendo y DAG visible en el navegador
- [x] Screenshot del DAG guardado en `assets/dag_tarea5.png` (pipeline GitHub, filtro `+int_github_actividad+`)

---

## Estructura objetivo del proyecto

> Planificación inicial (star schema). La implementación final difiere — ver estructura final abajo.

```
mi_proyecto_dbt/
├── dbt_project.yml
├── models/
│   ├── staging/
│   │   ├── _sources.yml
│   │   ├── stg_weather__forecast.sql
│   │   ├── stg_github__stargazers.sql
│   │   └── stg_github__branches.sql
│   ├── intermediate/
│   │   └── int_github_actividad.sql
│   └── marts/
│       ├── fct_pronostico.sql   ← reemplazado por OBT
│       ├── dim_fecha.sql        ← no implementado
│       └── dim_condicion.sql    ← no implementado
└── README.md
```

---

## Estructura final del proyecto

Archivos fuente relevantes (excluye artefactos `target/`, `dbt_packages/`, `logs/`):

```
mi_proyecto_dbt/
├── dbt_project.yml          # Configuración principal
├── profiles.yml             # Conexión a MotherDuck (token vía env var)
├── packages.yml             # Dependencias dbt (dbt_expectations — heredado de clase)
├── requirements.txt         # Dependencias Python (dbt-core, dbt-duckdb)
├── Makefile                 # Comandos de utilidad
├── set_env.sh               # Script para exportar MOTHERDUCK_TOKEN
├── models/
│   ├── staging/
│   │   ├── _sources.yml
│   │   ├── stg_weather__forecast.sql
│   │   ├── stg_github__stargazers.sql
│   │   └── stg_github__branches.sql
│   ├── intermediate/
│   │   └── int_github_actividad.sql
│   └── marts/
│       ├── obt_pronostico.sql
│       └── obt_github_actividad.sql
└── README.md
```

**Decisión de diseño:** Se eligió OBT (One Big Table) en lugar de star schema dado el bajo volumen de datos (40 filas weather, 1 fila GitHub). No hay redundancia real que justifique dimensiones separadas.

---

## Documento de entrega

- [x] `Tarea5.typ` actualizado con:
  - [x] Título y categoría correctos (Tarea 5)
  - [x] Descripción del proyecto dbt y configuración
  - [x] Código de los modelos staging, intermediate y mart
  - [x] Screenshot del DAG embebido (`assets/dag_tarea5.png`)
  - [x] Explicación de decisiones de diseño (OBT, capas staging/intermediate/marts)

---

## Estado general

| Componente            | Estado     |
|-----------------------|------------|
| Proyecto dbt init     | Listo      |
| profiles.yml          | Listo      |
| dbt debug             | Listo      |
| _sources.yml          | Listo      |
| Modelos staging       | Listo      |
| Modelo intermediate   | Listo      |
| Modelos mart          | Listo      |
| DAG screenshot        | Listo      |
| Tarea5.typ            | Listo      |
