# Progreso - Tarea 6: Testing y Documentación con dbt

## Objetivo

Agregar testing y documentación completa al proyecto dbt de la Tarea 5.
Todos los tests deben pasar con `dbt build`.

---

## Checklist de entregables

### 1. dbt-expectations instalado
- [ ] `packages.yml` actualizado con `dbt-expectations`
- [ ] `dbt deps` ejecutado correctamente

### 2. Tests genéricos (mínimo 5)
- [ ] `unique` + `not_null` en PKs de staging
- [ ] `relationships` en intermediate (si aplica)
- [ ] `accepted_values` en categorías de marts

### 3. Tests de dbt-expectations (mínimo 3)
- [ ] `expect_table_row_count_to_be_between` en staging
- [ ] `expect_column_values_to_be_between` en marts
- [ ] (1 adicional a definir)

### 4. Singular tests personalizados (mínimo 2)
- [ ] Regla de negocio personalizada #1 en `tests/`
- [ ] Regla de negocio personalizada #2 en `tests/`

### 5. Documentación de modelos y columnas clave
- [ ] `_models.yml` (o equivalente) con descripción de modelos y columnas en staging
- [ ] Documentación de intermediate
- [ ] Documentación de marts

### 6. Captura del DAG con documentación generada
- [ ] `dbt docs generate` ejecutado tras agregar tests y docs
- [ ] Screenshot del DAG actualizado guardado en `assets/`

---

## Tests por capa (tabla de requerimientos mínimos)

| Capa | Test requerido | Tipo |
|---|---|---|
| staging | `unique` + `not_null` en PKs | Generic |
| staging | `expect_table_row_count_to_be_between` | dbt-expectations |
| intermediate | `relationships` (si aplica) | Generic |
| marts | `accepted_values` en categorías | Generic |
| marts | `expect_column_values_to_be_between` | dbt-expectations |
| `tests/` | Regla de negocio personalizada | Singular |

---

## Estado general

| Componente | Estado |
|---|---|
| dbt-expectations instalado | Pendiente |
| Tests genéricos (≥5) | Pendiente |
| Tests dbt-expectations (≥3) | Pendiente |
| Singular tests (≥2) | Pendiente |
| Documentación modelos/columnas | Pendiente |
| DAG con docs generado | Pendiente |
| `dbt build` todo en PASS | Pendiente |
