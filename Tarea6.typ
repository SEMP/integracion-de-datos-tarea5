#import "@preview/basic-report:0.4.0": *

#show: it => basic-report(
  doc-category: "Integración de datos",
  doc-title: "Tarea Práctica - Clase 6",
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

= Tarea 6: Testing y Documentación con dbt

Esta tarea extiende el proyecto dbt de la Tarea 5 agregando una capa completa de *testing* y *documentación*. Se trabaja sobre el mismo repositorio y el mismo proyecto `mi_proyecto_dbt`, que transforma datos de OpenWeather y GitHub disponibles en MotherDuck (`md:airbyte_curso`). El objetivo es garantizar la calidad de los datos mediante tests genéricos, tests de `dbt-expectations` y tests singulares personalizados, y documentar todos los modelos y columnas clave. Todos los tests deben pasar con `dbt build`.

== Tests genéricos

Los tests genéricos se declaran en archivos `_models.yml` dentro de cada capa. Se definieron 11 tests en total, distribuidos en staging, intermediate y marts.

=== Staging

Los modelos de staging tienen tests de unicidad y nulidad sobre sus claves primarias naturales, además de `not_null` en columnas críticas.

```yaml
models:
  - name: stg_weather__forecast
    columns:
      - name: dt_unix          # PK natural
        tests: [unique, not_null]
      - name: fecha
        tests: [not_null]

  - name: stg_github__stargazers
    columns:
      - name: usuario_github_id   # PK natural
        tests: [unique, not_null]
      - name: usuario_login
        tests: [not_null]
      - name: repositorio_nombre_completo
        tests: [not_null]

  - name: stg_github__branches
    columns:
      - name: rama_nombre          # PK natural
        tests: [not_null]
      - name: repositorio_nombre_completo
        tests: [not_null]
      - name: rama_commit_sha
        tests: [not_null]
```

=== Intermediate

El modelo `int_github_actividad` incluye un test de `relationships` que verifica que todo `repositorio_nombre_completo` presente en los stargazers exista en la tabla de branches.

```yaml
models:
  - name: int_github_actividad
    columns:
      - name: repositorio_nombre_completo
        tests:
          - not_null
          - relationships:
              to: ref('stg_github__branches')
              field: repositorio_nombre_completo
```

=== Marts

Los modelos mart tienen tests de unicidad y nulidad sobre sus claves primarias surrogate y un test de `accepted_values` sobre `parte_dia`.

```yaml
models:
  - name: obt_pronostico
    columns:
      - name: pronostico_id
        tests: [unique, not_null]
      - name: pais
        tests:
          - accepted_values:
              values: ['PY']
      - name: fecha
        tests: [not_null]
      - name: temperatura_c
        tests: [not_null]
      - name: humedad_pct
        tests: [not_null]

  - name: obt_github_actividad
    columns:
      - name: estrella_id
        tests: [unique, not_null]
      - name: usuario_login
        tests: [not_null]
      - name: repositorio_nombre_completo
        tests: [not_null]
      - name: starred_at
        tests: [not_null]
```

=== Resultado

Los tests genéricos pasaron exitosamente. El resultado consolidado con todos los tests del proyecto (genéricos + dbt-expectations + singular) ejecutando `dbt test`:

```
Finished running 32 data tests in 13.75s.
PASS=32  WARN=0  ERROR=0  SKIP=0  TOTAL=32
```

Nota: la columna `parte_dia` proviene del campo JSON `sys.pod` almacenado por Airbyte (visible como `{"pod":"n"}` en MotherDuck). El test `accepted_values` genérico no puede aplicarse directamente sobre columnas de tipo JSON porque DuckDB intenta parsear los valores literales `'d'`/`'n'` como JSON, fallando con un error de conversión. Se aplicó `accepted_values` sobre `pais` (tipo `VARCHAR` garantizado por ser un literal en el staging), y la validación de `parte_dia` se resuelve mediante un singular test con `json_extract_string`.

== Tests de dbt-expectations

La librería `dbt-expectations` (ya declarada en `packages.yml` desde la Tarea 5) provee tests estadísticos y de calidad de datos más expresivos que los genéricos. Se definieron 3 tests distribuidos en staging y marts.

=== Recuento de filas en staging

Se verificó que ambas tablas de staging de GitHub tengan al menos una fila, y que el pronóstico weather no supere las 40 filas esperadas de la API (5 días × 8 intervalos de 3 h).

```yaml
# staging/_models.yml

- name: stg_weather__forecast
  tests:
    - dbt_expectations.expect_table_row_count_to_be_between:
        min_value: 1
        max_value: 40

- name: stg_github__stargazers
  tests:
    - dbt_expectations.expect_table_row_count_to_be_between:
        min_value: 1
        max_value: 100
```

=== Rango de valores en marts

Se verificó que `prob_precipitacion` en `obt_pronostico` siempre esté en el rango válido de la API de OpenWeather (0.0 a 1.0). Esta columna proviene de `pop` (campo directo, no anidado en struct), por lo que su tipo es numérico nativo en MotherDuck.

```yaml
# marts/_models.yml

- name: obt_pronostico
  columns:
    - name: prob_precipitacion
      tests:
        - dbt_expectations.expect_column_values_to_be_between:
            min_value: 0
            max_value: 1
```

== Singular tests

Los singular tests son archivos `.sql` en `tests/` que implementan reglas de negocio personalizadas. dbt los ejecuta como consultas: el test pasa si la consulta retorna 0 filas (no hay violaciones).

=== `assert_parte_dia_valida`

Valida que `parte_dia` en `obt_pronostico` solo contenga los valores `'d'` (día) o `'n'` (noche) definidos por la API de OpenWeather.

Este test no pudo implementarse como `accepted_values` genérico en el `_models.yml` porque Airbyte almacena el campo `sys` de OpenWeather como columna de tipo `JSON` en MotherDuck (visible como `{"pod":"n"}`). Al acceder `sys.pod` en el modelo de staging, DuckDB retorna un valor de tipo `JSON`, y compararlo directamente con strings planos falla con un error de conversión JSON.

El singular test resuelve esto usando `json_extract_string` para extraer el valor real sin las comillas que agrega la serialización JSON de DuckDB:

```sql
SELECT *
FROM {{ ref('obt_pronostico') }}
WHERE json_extract_string(parte_dia, '$') NOT IN ('d', 'n')
```

=== `assert_temperatura_rango_valido`

Valida que la temperatura mínima nunca supere a la máxima en ningún intervalo del pronóstico. Es una regla de negocio meteorológica fundamental.

```sql
SELECT *
FROM {{ ref('obt_pronostico') }}
WHERE temp_min_c > temp_max_c
```

=== Resultado

```
Finished running 2 data tests in 28.48s.
PASS=2  WARN=0  ERROR=0  SKIP=0  TOTAL=2
```

== Documentación de modelos y columnas

_Pendiente._

== DAG con documentación generada

_Pendiente de captura tras completar documentación y ejecutar `dbt docs generate`._
