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
- [ ] `dbt docs generate` ejecutado
- [ ] `dbt docs serve` corriendo y DAG visible en el navegador
- [ ] Screenshot del DAG guardado en `assets/`

---

## Estructura objetivo del proyecto

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
│       ├── fct_pronostico.sql
│       ├── dim_fecha.sql
│       └── dim_condicion.sql
└── README.md
```

---

## Documento de entrega

- [ ] `Tarea5.typ` actualizado con:
  - [ ] Título y categoría correctos (Tarea 5)
  - [ ] Descripción del proyecto dbt y configuración
  - [ ] Código de los modelos staging, intermediate y mart
  - [ ] Screenshot del DAG embebido
  - [ ] Explicación de decisiones de diseño (por qué Star Schema, qué hace cada capa)

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
| DAG screenshot        | Pendiente  |
| Tarea5.typ            | Pendiente  |
