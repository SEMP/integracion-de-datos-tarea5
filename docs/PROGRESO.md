# Progreso - Tarea 5: Transformación de Datos con dbt

## Datos fuente (MotherDuck — `md:airbyte_curso`)

- `weather.weather` — pronósticos OpenWeather (40 filas)
- `github.branches` — ramas del repo SEMP/lib-utilidades (1 fila)
- `github.stargazers` — estrellas del repo (1 fila)

---

## Checklist de entregables

### 1. Proyecto dbt inicializado y configurado
- [ ] `dbt init` ejecutado con adapter `duckdb` apuntando a `md:airbyte_curso`
- [ ] `~/.dbt/profiles.yml` configurado con token MotherDuck (`MOTHERDUCK_TOKEN`)
- [ ] `dbt_project.yml` con nombre de proyecto y rutas de modelos
- [ ] `dbt debug` exitoso (conexión verificada)

### 2. Modelos staging (mínimo 2, uno por source)
- [ ] `staging/stg_weather__forecast.sql` — limpieza de `weather.weather`
- [ ] `staging/stg_github__stargazers.sql` — limpieza de `github.stargazers`
- [ ] `staging/stg_github__branches.sql` — limpieza de `github.branches` _(opcional, ya que se puede incorporar en intermediate)_

### 3. Archivo `_sources.yml`
- [ ] Source `weather` apuntando al schema `weather`, tabla `weather`
- [ ] Source `github` apuntando al schema `github`, tablas `branches` y `stargazers`

### 4. Modelo intermediate (mínimo 1)
- [ ] `intermediate/int_github_actividad.sql` — join de stargazers + branches enriquecido

### 5. Modelo mart (mínimo 1, dimensional u OBT)
- [ ] Opción elegida según Tarea 4: **Star Schema** (para el dataset principal)
  - [ ] `marts/fct_pronostico.sql`
  - [ ] `marts/dim_fecha.sql`
  - [ ] `marts/dim_condicion.sql`
  - _O alternativamente un modelo OBT único por simplicidad_

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

| Componente          | Estado     |
|---------------------|------------|
| Proyecto dbt init   | Pendiente  |
| profiles.yml        | Pendiente  |
| _sources.yml        | Pendiente  |
| Modelos staging     | Pendiente  |
| Modelo intermediate | Pendiente  |
| Modelo mart         | Pendiente  |
| DAG screenshot      | Pendiente  |
| Tarea5.typ          | Pendiente  |
