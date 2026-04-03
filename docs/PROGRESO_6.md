# Progreso - Tarea 6: Testing y Documentación con dbt

## Objetivo

Agregar testing y documentación completa al proyecto dbt de la Tarea 5.
Todos los tests deben pasar con `dbt build`.

---

## Checklist de entregables

### 1. dbt-expectations instalado
- [x] `packages.yml` ya incluía `dbt-expectations` (heredado de clase)
- [x] `dbt deps` ejecutado correctamente

### 2. Tests genéricos (mínimo 5) — 28 tests, PASS=28
- [x] `unique` + `not_null` en `dt_unix` (`stg_weather__forecast`)
- [x] `unique` + `not_null` en `usuario_github_id` (`stg_github__stargazers`)
- [x] `not_null` en columnas clave de `stg_github__branches`
- [x] `relationships` en `int_github_actividad.repositorio_nombre_completo` → `stg_github__branches`
- [x] `unique` + `not_null` en PKs surrogate de marts (`pronostico_id`, `estrella_id`)
- [x] `accepted_values` en `obt_pronostico.pais` → `['PY']`
- [x] `not_null` en columnas clave de `obt_pronostico` y `obt_github_actividad`
- Nota: `accepted_values` sobre `parte_dia` falló por tipo `UNION` en MotherDuck; se aplicó sobre `pais` (VARCHAR literal)

### 3. Tests de dbt-expectations (mínimo 3)
- [x] `expect_table_row_count_to_be_between` en `stg_weather__forecast` (1–40 filas)
- [x] `expect_table_row_count_to_be_between` en `stg_github__stargazers` (1–100 filas)
- [x] `expect_column_values_to_be_between` en `obt_pronostico.prob_precipitacion` (0–1)

### 4. Singular tests personalizados (mínimo 2) — PASS=3
- [x] `tests/assert_parte_dia_valida.sql` — valida que `parte_dia` sea `'d'` o `'n'` (weather)
- [x] `tests/assert_temperatura_rango_valido.sql` — valida que `temp_min_c <= temp_max_c` (weather)
- [x] `tests/assert_repositorio_formato_valido.sql` — valida formato `owner/repo` en `repositorio_nombre_completo` (GitHub)

### 5. Documentación de modelos y columnas clave
- [x] Descripciones de modelos y columnas en `staging/_models.yml`
- [x] Descripciones de modelos y columnas en `intermediate/_models.yml`
- [x] Descripciones de modelos y columnas en `marts/_models.yml`

### 6. Captura del DAG con documentación generada
- [ ] `dbt docs generate` ejecutado tras completar tests y docs
- [ ] Screenshot del DAG actualizado guardado en `assets/`

---

## Tests por capa (tabla de requerimientos mínimos)

| Capa | Test requerido | Tipo | Estado |
|---|---|---|---|
| staging | `unique` + `not_null` en PKs | Generic | ✅ |
| staging | `expect_table_row_count_to_be_between` | dbt-expectations | ✅ |
| intermediate | `relationships` | Generic | ✅ |
| marts | `accepted_values` en categorías | Generic | ✅ |
| marts | `expect_column_values_to_be_between` | dbt-expectations | ✅ |
| `tests/` | Regla de negocio personalizada | Singular | ✅ |

---

## Estado general

| Componente | Estado |
|---|---|
| dbt-expectations instalado | Listo |
| Tests genéricos (≥5) | Listo — 28 tests, PASS=28 |
| Tests dbt-expectations (≥3) | Listo — 3 tests agregados |
| Singular tests (≥2) | Listo — 3 tests, PASS=34 total |
| Documentación modelos/columnas | Listo — descripciones en los 3 `_models.yml` |
| DAG con docs generado | Pendiente |
| `dbt build` todo en PASS | Pendiente (confirmar tras singular tests) |
