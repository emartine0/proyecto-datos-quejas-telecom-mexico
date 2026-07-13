/*
===============================================================================================
Control de Calidad
===============================================================================================
Proposito del Codigo:
    Este script realiza varias comprobaciones de calidad para garantizar 
    la integridad, la consistencia y la exactitud de los datos en la capa
    "gold". Incluye comprobaciones de:
    - Validación de las relaciones en el modelo de datos para propositos análisticos.

Notas de Uso:
    - Investigar y resolver cualquier discrepancia que se encuentre durante las verificaciones.
===============================================================================================
*/

-- Verificar la dimensión de cada columna.

SELECT DISTINCT
	procedimientos
FROM gold.quejas_telecom

/*
	En la columna 'procedimientos' 
	existen dos entradas similares 'Conciliación por Medios Electrónicos'
	y Conciliación Medios Electrónicos'
*/

-- Verificar la consistencia entre las fechas.

SELECT
	expediente,
	fecha_ingreso,
	fecha_cierre,
	DATEDIFF(day, fecha_ingreso, fecha_cierre) AS diferencia_fechas_dias
FROM gold.quejas_telecom
WHERE DATEDIFF(day, fecha_ingreso, fecha_cierre) < 0

/*	
	3 entradas con defecto:
	'PFC.HGO.B.3/001586-2022' -> '2022-05-04'
	'PFC.YUC.B.3/001891-2022' -> '2022-05-04'
	'PFC.ZAC.B.3/000867-2022' -> '2022-05-02
*/

-- Verificar la consistencia en las columnas con tipo de datos INT
-- Solo hay dos tipos de datos INT y NULL

SELECT
	*
FROM gold.quejas_telecom
WHERE costo_bien_servicio IS NULL -- (IS NOT NULL)

/*
    2800 NULL
    29840 NOT NULL
*/
    
SELECT
	*
FROM gold.quejas_telecom
WHERE monto_reclamado IS NULL -- (IS NOT NULL)

/*
    28 NULL
    32612 NOT NULL
*/
    
SELECT
	*
FROM gold.quejas_telecom
WHERE monto_recuperado IS NULL -- (IS NOT NULL)

/*
    1477 NULL
    31163 NOT NULL
*/

