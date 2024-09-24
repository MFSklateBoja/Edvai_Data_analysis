---

### Archivo `queries.sql` (para las consultas SQL)

---Crear tabla ventas en la capa Silver
CREATE
OR
REPLACE
TABLE `mi_proyecto_silver.ventas` AS
SELECT *
FROM
    `bronzelayer-433922.mi_proyecto_bronce.ventas`
WHERE
    invoice_and_item_number IS NOT NULL
    AND date IS NOT NULL
    AND store_number IS NOT NULL
    AND item_number IS NOT NULL
    AND vendor_number IS NOT NULL
    AND category IS NOT NULL;

-- Crear tabla de hechos (fact_sales)
CREATE
OR
REPLACE
TABLE `mi_proyecto_silver.fact_sales` AS
SELECT
    invoice_and_item_number,
    date,
    store_number,
    item_number,
    vendor_number,
    bottles_sold
FROM
    `bronzelayer-433922.mi_proyecto_bronce.ventas`;

-- Crear tabla de proveedores (dim_vendor)
CREATE
OR
REPLACE
TABLE `mi_proyecto_silver.dim_vendor` AS
SELECT
    SAFE_CAST (vendor_number AS INT64) AS vendor_number,
    vendor_name
FROM (
        SELECT DISTINCT
            vendor_number, vendor_name
        FROM `mi_proyecto_silver.ventas`
        WHERE
            SAFE_CAST (vendor_number AS FLOAT64) IS NOT NULL
    );

-- Crear tabla de productos (dim_product)
CREATE
OR
REPLACE
TABLE `mi_proyecto_silver.dim_product` AS
SELECT
    SAFE_CAST (item_number AS INT64) AS item_number,
    item_description,
    category,
    pack,
    bottle_volume_ml,
    state_bottle_cost,
    state_bottle_retail
FROM (
        SELECT DISTINCT
            item_number, item_description, category, pack, bottle_volume_ml, state_bottle_cost, state_bottle_retail
        FROM `mi_proyecto_silver.ventas`
        WHERE
            SAFE_CAST (item_number AS FLOAT64) IS NOT NULL
    );

-- Crear tabla de tiendas (dim_store)
CREATE
OR
REPLACE
TABLE `mi_proyecto_silver.dim_store` AS
SELECT
    CAST(
        CAST(store_number AS FLOAT64) AS INT64
    ) AS store_number,
    store_name,
    address,
    city,
    zip_code,
    county,
    store_location
FROM (
        SELECT DISTINCT
            store_number, store_name, address, city, zip_code, county, store_location
        FROM `mi_proyecto_silver.ventas`
    );