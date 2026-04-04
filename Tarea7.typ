#import "@preview/basic-report:0.4.0": *

#show: it => basic-report(
  doc-category: "Integración de datos",
  doc-title: "Tarea Práctica - Clase 7",
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

= Tarea 7: Orquestación y Visualización

Esta tarea implementa el pipeline ELT completo para el dataset *Maven Fuzzy Factory*, un ecommerce ficticio con datos de sesiones web, órdenes, productos y reembolsos. El pipeline sigue la arquitectura: *MySQL -> Airbyte -> MotherDuck -> dbt -> Metabase*, orquestado con *Prefect*. El workspace se ubica en `workspaces/maven-fuzzy/` dentro del mismo repositorio de las tareas anteriores.

== Paso 1: Base de datos MySQL con Docker

=== Dataset: Maven Fuzzy Factory

El dataset proviene de *Maven Analytics Data Playground* y contiene la base de datos transaccional de un ecommerce de juguetes ficticio. Se descarga como archivo `.zip` y se carga en una instancia local de MySQL.

#table(
  columns: (auto, auto, 1fr),
  table.header([*Tabla*], [*Registros*], [*Descripción*]),
  [`website_sessions`],    [472,871],  [Sesiones de usuarios con datos UTM, device y referer],
  [`website_pageviews`],   [1,188,124],[Páginas visitadas por sesión],
  [`orders`],              [32,313],   [Órdenes realizadas con precio y costo],
  [`order_items`],         [40,025],   [Items individuales dentro de cada orden],
  [`order_item_refunds`],  [1,731],    [Reembolsos procesados],
  [`products`],            [4],        [Catálogo de productos],
)

=== Contenedor Docker

Se levanta MySQL 8.0 junto a phpMyAdmin mediante `docker-compose.yaml` en `workspaces/maven-fuzzy/mysql-container/`. Las credenciales se leen desde un archivo `.env` (no versionado); el archivo `example.env` sirve de plantilla:

```bash
# Crear .env a partir de la plantilla
cd workspaces/maven-fuzzy/mysql-container
cp example.env .env
# Editar .env con las credenciales reales
```

```yaml
# docker-compose.yaml (resumen)
services:
  mia-mysql:
    image: mysql:8.0
    environment:
      - MYSQL_ROOT_PASSWORD
      - MYSQL_DATABASE       # maven_fuzzy_factory
      - MYSQL_USER           # airbyte
      - MYSQL_PASSWORD
    ports:
      - "${MYSQL_PORT}:3306"
    volumes:
      - mia-mysql_data:/var/lib/mysql
      - ./initdb:/docker-entrypoint-initdb.d

  mia-phpmyadmin:
    image: phpmyadmin:latest
    environment:
      - PMA_HOST=mia-mysql
      - PMA_USER=${MYSQL_USER}
      - PMA_PASSWORD=${MYSQL_PASSWORD}
    ports:
      - "${PMA_PORT}:80"
    depends_on:
      - mia-mysql
```

La opción `--default-authentication-plugin=mysql_native_password` en MySQL garantiza compatibilidad con el conector de Airbyte, que no soporta el plugin `caching_sha2_password` introducido por defecto en MySQL 8.0.

phpMyAdmin se pre-configura automáticamente con `PMA_HOST`, `PMA_USER` y `PMA_PASSWORD`, por lo que no requiere ingresar credenciales manualmente al acceder a `localhost:8095`. El puerto 8095 se eligió para evitar conflicto con `dbt docs serve`, que usa 8080 por defecto.

=== Schema de la base de datos

El schema se declara en `initdb/01_schema.sql` siguiendo los tipos de datos del modelo original. MySQL ejecuta este script automáticamente al primer arranque del contenedor.

#table(
  columns: (auto, 1fr),
  table.header([*Tabla*], [*Columnas clave y tipos*]),
  [`products`],            [`product_id INT`, `product_name VARCHAR(45)`],
  [`website_sessions`],    [`website_session_id BIGINT`, `is_repeat_session BINARY(1)`, `utm_source/campaign/content VARCHAR(45)`],
  [`website_pageviews`],   [`website_pageview_id BIGINT`, `pageview_url VARCHAR(45)`],
  [`orders`],              [`order_id BIGINT`, `price_usd DECIMAL(6,2)`, `cogs_usd DECIMAL(6,2)`],
  [`order_items`],         [`order_item_id BIGINT`, `is_primary_item BINARY(1)`, `price_usd DECIMAL(6,2)`],
  [`order_item_refunds`],  [`order_item_refund_id BIGINT`, `refund_amount_usd DECIMAL(6,2)`],
)

=== Carga de datos

Los CSVs se montan en `/csv` dentro del contenedor a través del volumen `${CSV_DIR}:/csv`. El script `initdb/02_load_data.sql` usa `LOAD DATA INFILE` para cargar cada archivo:

```sql
LOAD DATA INFILE '/csv/website_sessions.csv'
INTO TABLE website_sessions
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(website_session_id, created_at, user_id, is_repeat_session,
 utm_source, utm_campaign, utm_content, device_type, http_referer);
```

La variable `CSV_DIR` en `.env` apunta a la carpeta local donde se descomprimió el `.zip` descargado de Maven Analytics Data Playground.

=== Levantar los contenedores

```bash
cd workspaces/maven-fuzzy/mysql-container
cp example.env .env
# Editar .env: ajustar CSV_DIR y credenciales
docker compose up -d
```

Al primer arranque MySQL ejecuta los scripts de `initdb/` en orden numérico: primero crea el schema (`01_schema.sql`) y luego carga los datos (`02_load_data.sql`). La carga de las tablas más grandes (`website_sessions` con 450K filas, `website_pageviews` con 1.1M) puede tomar algunos minutos. El progreso es visible en los logs del contenedor:

```bash
docker logs -f mia_mysql
```

=== Verificación

Una vez que el contenedor está corriendo, se puede verificar la carga desde phpMyAdmin (`localhost:8095`) ejecutando:

```sql
SELECT 'products'            AS tabla, COUNT(*) AS registros FROM products
UNION ALL SELECT 'orders',                        COUNT(*) FROM orders
UNION ALL SELECT 'order_items',                   COUNT(*) FROM order_items
UNION ALL SELECT 'order_item_refunds',            COUNT(*) FROM order_item_refunds
UNION ALL SELECT 'website_sessions',              COUNT(*) FROM website_sessions
UNION ALL SELECT 'website_pageviews',             COUNT(*) FROM website_pageviews;
```

Resultado obtenido:

#table(
  columns: (1fr, auto),
  table.header([*Tabla*], [*Registros*]),
  [`products`],           [4],
  [`orders`],             [32,313],
  [`order_items`],        [40,025],
  [`order_item_refunds`], [1,731],
  [`website_sessions`],   [472,871],
  [`website_pageviews`],  [1,188,124],
)

== Paso 2: Configurar Airbyte

== Paso 3: Modelos dbt

== Paso 4: Orquestación con Prefect

== Paso 5: Visualización con Metabase
