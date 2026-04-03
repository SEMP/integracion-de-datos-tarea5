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
      - name: parte_dia
        tests:
          - accepted_values:
              arguments:
                values: ['d', 'n']
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

Los 11 tests genéricos pasaron exitosamente con `dbt test`:

```
Finished running 11 data tests in 7.97s.
PASS=11  WARN=0  ERROR=0  SKIP=0  TOTAL=11
```

== Tests de dbt-expectations

_Pendiente._

== Singular tests

_Pendiente._

== Documentación de modelos y columnas

_Pendiente._

== DAG con documentación generada

_Pendiente de captura tras completar documentación y ejecutar `dbt docs generate`._
