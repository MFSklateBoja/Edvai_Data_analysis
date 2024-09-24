Proyecto final EDVAI- análisis de ventas de licorerías en IOWA

# Ventas de Iowa - Análisis de Datos

## 1. Presentación de la Temática
La base de datos de "Ventas de Iowa" documenta transacciones comerciales en diversas categorías de productos en Iowa, Estados Unidos. El objetivo es proporcionar información sobre ventas, permitiendo análisis de patrones de consumo, rendimiento de productos y comportamiento de ventas por ubicación y temporalidad.

## 2. Orígenes de la Información
Los datos son públicos y se encuentran en BigQuery, recopilando información de:
- Registros transaccionales de puntos de venta en Iowa.
- Inventario de tiendas en Iowa.
- Información demográfica y geolocalización.

## 3. Foco de Análisis
Los principales enfoques de análisis incluyen:
- **Tendencias de consumo**: Categorías más vendidas y comportamiento de consumidores.
- **Rendimiento de ventas por región**: Identificación de zonas con mayor actividad comercial.
- **Estacionalidad y ventas**: Fluctuaciones de ventas en función de temporadas y eventos.
- **Optimización de inventario**: Identificación de productos de alta y baja rotación.

### Hipótesis
1. Las ventas aumentan durante eventos festivos.
2. Las campañas de marketing aumentan ventas en días específicos.
3. Las ventas son más bajas los fines de semana.
4. Existen proveedores clave en el mercado.
5. La demanda varía significativamente según la región.
6. Los productos de menor precio tienen mayor rotación.
7. Las botellas se venden en packs de 6 o 12.

## 4. Descripción de la Base de Datos
La base de datos registra transacciones de bebidas alcohólicas. Los campos principales son:

| Campo              | Descripción                                                    |
|--------------------|----------------------------------------------------------------|
| Invoice/Item Number | Número de factura/ítem en la transacción                      |
| Date               | Fecha de la transacción                                        |
| Store Number       | Identificación única del minorista                             |
| Store Name         | Nombre del establecimiento                                     |
| Address            | Dirección de la tienda                                         |
| City               | Ciudad de la tienda                                            |
| Zip Code           | Código postal de la tienda                                     |
| Store Location     | Coordenadas geográficas de la tienda                           |
| County Number      | Número del condado                                             |
| County             | Nombre del condado                                             |
| Category           | Clasificación del licor                                        |
| Vendor Number      | Número del proveedor                                           |
| Vendor Name        | Nombre del proveedor                                           |
| Item Number        | Código del producto vendido                                    |
| Item Description   | Descripción del producto                                       |
| Pack               | Unidades por paquete                                           |
| Bottle Volume (ml) | Volumen de la botella en ml                                    |
| State Bottle Cost  | Costo de la botella para el estado                             |
| State Bottle Retail| Precio de venta al público                                     |
| Bottles Sold       | Número de botellas vendidas                                    |
| Sale (Dollars)     | Monto total de la venta en dólares                             |
| Volume Sold (Liters)| Volumen total vendido en litros                                |

## 5. Modelo de Entidades y Relaciones - Origen Bronze/Raw
La capa raw incluye una tabla con las ventas en crudo para análisis geográfico y de inventario.

## 6. Plan de Métricas
El plan incluye:
- **Análisis de ventas**: total de ventas, variación temporal, precios promedio, costos, ganancia y rentabilidad.
- **Indicadores geográficos**: ventas por región.
- **Análisis de productos**: rotación de productos y margen de ganancia.

## 7. Proceso ETL
- **Extracción**: Datos crudos desde sistemas de transacciones.
- **Transformación**:
  - Limpieza de datos.
  - Normalización de nombres de productos y categorías.
  - Agregar columnas calculadas.
- **Carga**: Datos transformados a BigQuery.

## 8. Modelo DER para Power BI
Esquema estrella en Power BI:
- **Fact Table**: `facts_sales` - Datos de ventas.
- **Dimensión**: `dim_product`, `dim_store`, `dim_vendor`, `dim_category`, `calendario`.

## 9. Principales Medidas en DAX
Algunas de las medidas usadas en Power BI:

```DAX
#ventas = COUNT(fact_sales[invoice_and_item_number])
$Total_sales = SUM(fact_sales[sale_dollars])
#tiendas = COUNT(dim_store[store_number])
#proveedores_activos = DISTINCTCOUNT(fact_sales[vendor_number])
#litros = SUM(fact_sales[volumen_sold_liters])
$Precio_Promedio_Producto = AVERAGE(fact_sales[sale_dollars])
RankingVentas = RANKX(ALLSELECTED(fact_sales), [$Total_sales],, DESC)
$Ganancias = SUM(fact_sales[profit])
$rentabilidad = [$Ganancias] / [$Total_sales]
$Ventas_promedio = AVERAGE(fact_sales[sale_dollars])
$max = MAX(fact_sales[sale_dollars])
MaxSalesDate = VAR MaxSales = CALCULATE(MAX(fact_sales[sale_dollars]))
RETURN CALCULATE(MAX(fact_sales[date]), fact_sales[sale_dollars] = MaxSales)
```

## 10.	Conclusiones o cumplimiento de hipótesis
•	Aumento de ventas en eventos festivos y campañas de marketing: Se observa un incremento significativo en las ventas durante eventos festivos o feriados. Además, algunos productos experimentan picos en días específicos debido a campañas de marketing dirigidas, mostrando el impacto de la promoción estratégica.
•	Tendencias semanales de ventas: A lo largo de la semana, las ventas siguen un patrón claro: los días miércoles y jueves son los más fuertes, probablemente como resultado de campañas promocionales. En contraste, las ventas caen drásticamente durante los fines de semana, posiblemente debido a que muchas tiendas permanecen cerradas.
•	Variación de ventas en los últimos años: Aunque la rentabilidad se ha mantenido, las ventas han disminuido considerablemente en los últimos cuatro años. Históricamente, los meses de diciembre y junio mostraban un aumento significativo en las ventas, pero esta tendencia cambió a partir de 2018, con un mayor consumo al inicio del año. A pesar de estas variaciones, los días de mayor venta no han cambiado.
•	Variaciones regionales en la demanda: La demanda de productos varía considerablemente según la región de Iowa. El condado de Polk ha mantenido consistentemente el mayor volumen de ventas, lo cual se corresponde con la mayor concentración de tiendas en esa área.
•	Proveedores clave en el mercado: Un grupo reducido de proveedores es responsable de la mayoría de las ventas, destacándose como líderes en el rubro.
•	Rotación de productos por categoría: Los productos de menor precio tienden a tener una rotación más alta, lo que significa que las categorías más vendidas no coinciden necesariamente con los artículos más costosos.
•	Presentación de productos: En su mayoría, los productos se venden en packs de 6 o 12 botellas, con tamaños que generalmente no superan el litro.

---

### Archivo `queries.sql` (para las consultas SQL)

```sql
-- Crear tabla ventas en la capa Silver
CREATE OR REPLACE TABLE `mi_proyecto_silver.ventas` AS 
SELECT * FROM `bronzelayer-433922.mi_proyecto_bronce.ventas`
WHERE invoice_and_item_number IS NOT NULL
  AND date IS NOT NULL
  AND store_number IS NOT NULL
  AND item_number IS NOT NULL
  AND vendor_number IS NOT NULL
  AND category IS NOT NULL;

-- Crear tabla de hechos (fact_sales)
CREATE OR REPLACE TABLE `mi_proyecto_silver.fact_sales` AS 
SELECT invoice_and_item_number, date, store_number, item_number, vendor_number, bottles_sold
FROM `bronzelayer-433922.mi_proyecto_bronce.ventas`;

-- Crear tabla de proveedores (dim_vendor)
CREATE OR REPLACE TABLE `mi_proyecto_silver.dim_vendor` AS 
SELECT SAFE_CAST(vendor_number AS INT64) AS vendor_number, vendor_name
FROM (
  SELECT DISTINCT vendor_number, vendor_name
  FROM `mi_proyecto_silver.ventas`
  WHERE SAFE_CAST(vendor_number AS FLOAT64) IS NOT NULL
);

-- Crear tabla de productos (dim_product)
CREATE OR REPLACE TABLE `mi_proyecto_silver.dim_product` AS 
SELECT SAFE_CAST(item_number AS INT64) AS item_number, item_description, category, pack, bottle_volume_ml, state_bottle_cost, state_bottle_retail
FROM (
  SELECT DISTINCT item_number, item_description, category, pack, bottle_volume_ml, state_bottle_cost, state_bottle_retail
  FROM `mi_proyecto_silver.ventas`
  WHERE SAFE_CAST(item_number AS FLOAT64) IS NOT NULL
);

-- Crear tabla de tiendas (dim_store)
CREATE OR REPLACE TABLE `mi_proyecto_silver.dim_store` AS 
SELECT CAST(CAST(store_number AS FLOAT64) AS INT64) AS store_number, store_name, address, city, zip_code, county, store_location
FROM (
  SELECT DISTINCT store_number, store_name, address, city, zip_code, county, store_location
  FROM `mi_proyecto_silver.ventas`
);
