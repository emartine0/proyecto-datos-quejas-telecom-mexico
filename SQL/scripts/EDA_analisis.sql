--#####################################
--######## DATABASE EXPLORATION #######
--#####################################

-- Examinar Todos los Objetos en la Basede Datos

SELECT * FROM INFORMATION_SCHEMA.TABLES

-- Examinar todas las Columna en la Base de Datos

SELECT * FROM INFORMATION_SCHEMA.COLUMNS 

--#####################################
--####### DIMENSION EXPLORATION #######
--#####################################

SELECT DISTINCT 
	tipo_reclamacion,
	motivo_reclamacion
FROM gold.quejas_telecom
ORDER BY 1,2 ASC

SELECT DISTINCT
	nombre_comercial,
	proveedor
FROM gold.quejas_telecom
ORDER BY 1, 2 ASC

SELECT DISTINCT
	clase,
	tipo_producto
FROM gold.quejas_telecom
ORDER BY 1, 2 ASC

SELECT DISTINCT
	estado,
	oficina_defensa_consumidor
FROM gold.quejas_telecom
ORDER BY 1, 2 ASC

--#####################################
--######### DATE EXPLORATION ##########
--#####################################

SELECT
	MIN(fecha_ingreso) AS denuncia_mas_antigua,
	MAX(fecha_ingreso) AS denuncia_mas_reciente,
	DATEDIFF(year, MIN(fecha_ingreso), MAX(fecha_ingreso)) AS lapso_registros
FROM gold.quejas_telecom

SELECT
	MAX(fecha_cierre) AS conclusion_mas_reciente,
	DATEDIFF(day, MAX(fecha_cierre), GETDATE()) AS lapso_ultima_conclusion
FROM gold.quejas_telecom

--#####################################
--# MEASURES EXPLORATION: BIG NUMBERS #
--#####################################

-- LOS NUMEROS GRANDES

-- Encontrar el Numero Total de Quejas

SELECT
	COUNT(*) AS total_quejas
FROM gold.quejas_telecom

-- Encontrar el Numero Total de Motivos

SELECT
	COUNT(DISTINCT motivo_reclamacion) AS total_motivos
FROM gold.quejas_telecom

-- Encontrar el Numero Total de Proveedores

SELECT
	COUNT(DISTINCT proveedor) AS total_proveedores
FROM gold.quejas_telecom

-- Encontrar el Numero Total de ODECO

SELECT
	COUNT(DISTINCT oficina_defensa_consumidor) AS total_odeco
FROM gold.quejas_telecom

-- Encontrar el Tiempo Promedio de Resolucion

SELECT
	AVG(DATEDIFF(day, fecha_ingreso, fecha_cierre)) AS tiempo_medio_resolucion
FROM gold.quejas_telecom

-------------------------------------------------------------
-- Generar un reporte que muestre todas las metricas clave -- 
-------------------------------------------------------------

SELECT 'Total de Quejas' AS nombre_cantidad, COUNT(*) AS valor_cantidad FROM gold.quejas_telecom
UNION ALL
SELECT 'Total de Motivos', COUNT(DISTINCT motivo_reclamacion) FROM gold.quejas_telecom
UNION ALL
SELECT 'Tiempo Medio de Resolucion', AVG(DATEDIFF(day, fecha_ingreso, fecha_cierre)) FROM gold.quejas_telecom
UNION ALL
SELECT 'Total de Proveedores', COUNT(DISTINCT proveedor) FROM gold.quejas_telecom
UNION ALL
SELECT 'Total de ODECOs', COUNT(DISTINCT oficina_defensa_consumidor) FROM gold.quejas_telecom


--#####################################
--######### MAGNITUD ANALYSIS #########
--#####################################

-- Encontrar Total de Quejas por Proveedor
-- (Cual es la Distribucion de Quejas a traves de los Proveedores?)

SELECT
	proveedor,
	COUNT(expediente) AS total_quejas
FROM gold.quejas_telecom
GROUP BY proveedor
ORDER BY total_quejas DESC

-- Encontrar Total de Quejas por Nombre Comercial del Proveedor

SELECT
	nombre_comercial,
	COUNT(expediente) AS total_quejas
FROM gold.quejas_telecom
GROUP BY nombre_comercial
ORDER BY total_quejas DESC

-- Encontrar el Total de Quejas por Tipo de Reclamacion

SELECT
	tipo_reclamacion,
	COUNT(expediente) AS total_quejas
FROM gold.quejas_telecom
GROUP BY tipo_reclamacion
ORDER BY total_quejas DESC

-- Encontrar el Tiempo Promedio de Resolucion por Proveedor

SELECT
	proveedor,
	AVG(DATEDIFF(day, fecha_ingreso, fecha_cierre)) AS tiempo_medio_resolucion
FROM gold.quejas_telecom
GROUP BY proveedor
ORDER BY tiempo_medio_resolucion ASC

-- Encontrar el Tiempo Promedio de Resolucion por Nombre Comercial del Proveedor

SELECT
	nombre_comercial,
	AVG(DATEDIFF(day, fecha_ingreso, fecha_cierre)) AS tiempo_medio_resolucion
FROM gold.quejas_telecom
GROUP BY nombre_comercial
ORDER BY tiempo_medio_resolucion ASC

-- Encontrar el Tiempo Promedio de Resolucion por Tipo de Reclamacion

SELECT
	tipo_reclamacion,
	AVG(DATEDIFF(day, fecha_ingreso, fecha_cierre)) AS tiempo_medio_resolucion
FROM gold.quejas_telecom
GROUP BY tipo_reclamacion
ORDER BY tiempo_medio_resolucion

-- Encontrar el Total de Quejas por Estado

SELECT
	estado,
	COUNT(expediente) AS total_quejas
FROM gold.quejas_telecom
GROUP BY estado
ORDER BY total_quejas DESC

-- Encontrar el Numero Total de Motivos de Reclamacion por Tipo de Reclamacion

SELECT
	tipo_reclamacion,
	COUNT(DISTINCT motivo_reclamacion) AS total_motivos
FROM gold.quejas_telecom
GROUP BY tipo_reclamacion
ORDER BY total_motivos DESC


--#####################################
-- RANKING ANALYSIS: TOP N - BOTTOM N 
--#####################################

-- Cuales son los 10 proveedores que mas acumulan quejas

SELECT TOP 10
	proveedor,
	COUNT(expediente) AS total_quejas
FROM gold.quejas_telecom
GROUP BY proveedor
ORDER BY total_quejas DESC

-- Window Function Method (More Flexibility)

SELECT
	*
FROM (
	SELECT
		proveedor,
		COUNT(expediente) AS total_quejas,
		ROW_NUMBER() OVER(ORDER BY COUNT(expediente) DESC) rank_proveedor
	FROM gold.quejas_telecom
	GROUP BY proveedor
	)t
WHERE rank_proveedor <= 10

-- Cuales son los 3 tipos de reclamacion que menos quejas acumulan

SELECT TOP 3
	tipo_reclamacion,
	COUNT(expediente) AS total_quejas
FROM gold.quejas_telecom
GROUP BY tipo_reclamacion
ORDER BY total_quejas ASC

-- Window Function 

SELECT
	*
FROM (
	SELECT
		tipo_reclamacion,
		COUNT(expediente) AS total_quejas,
		ROW_NUMBER() OVER(ORDER BY COUNT(expediente) ASC) AS rank_tipo_reclamacion
	FROM gold.quejas_telecom
	GROUP BY tipo_reclamacion
	)t
WHERE rank_tipo_reclamacion <= 3

-- Cual es el Top 5 de tipos de reclamacion

SELECT TOP 5
	tipo_reclamacion,
	COUNT(expediente) AS total_quejas
FROM gold.quejas_telecom
GROUP BY tipo_reclamacion
ORDER BY total_quejas DESC

-- Window Function

SELECT
	*
FROM (
	SELECT
		tipo_reclamacion,
		COUNT(expediente) AS total_quejas,
		ROW_NUMBER() OVER(ORDER BY COUNT(expediente) DESC) AS rank_tipo_reclamacion
	FROM gold.quejas_telecom
	GROUP BY tipo_reclamacion
	)t
WHERE rank_tipo_reclamacion <= 5


-- Cual es el Top 15 proveedores, Mediante Nombre Comercial, con menor tiempo de resolucion medio

SELECT TOP 15
	nombre_comercial,
	ROUND(AVG(DATEDIFF(day, fecha_ingreso, fecha_cierre)),2) AS tiempo_medio_resolucion
FROM gold.quejas_telecom
GROUP BY nombre_comercial
HAVING ROUND(AVG(DATEDIFF(day, fecha_ingreso, fecha_cierre)),2) IS NOT NULL
ORDER BY tiempo_medio_resolucion ASC

-- Window Function

SELECT
	*
FROM (
	SELECT
		nombre_comercial,
		ROUND(AVG(DATEDIFF(day, fecha_ingreso, fecha_cierre)),2) AS tiempo_medio_resolucion,
		ROW_NUMBER() OVER(ORDER BY ROUND(AVG(DATEDIFF(day, fecha_ingreso, fecha_cierre)),2) ASC) AS rank_proveedorNC
	FROM gold.quejas_telecom
	GROUP BY nombre_comercial
	HAVING ROUND(AVG(DATEDIFF(day, fecha_ingreso, fecha_cierre)),2) IS NOT NULL
	)t
WHERE rank_proveedorNC <= 15

-- Cuales son los 5 proveedores con el mayor numero de quejas no conciliadas

SELECT TOP 5
	nombre_comercial,
	COUNT(expediente) AS total_quejas
FROM (
	SELECT
		*
	FROM gold.quejas_telecom
	WHERE estado_procesal = 'No Conciliada'
	)t
GROUP BY nombre_comercial
ORDER BY total_quejas DESC

-- Window Function

SELECT
	*
FROM (
	SELECT
		nombre_comercial,
		COUNT(expediente) AS total_quejas,
		ROW_NUMBER() OVER(ORDER BY COUNT(expediente) DESC) AS rank_no_conciliacion
	FROM (
		SELECT
			*
		FROM gold.quejas_telecom
		WHERE estado_procesal = 'No Conciliada'
		)t
	GROUP BY nombre_comercial
	)t
WHERE rank_no_conciliacion <= 5
