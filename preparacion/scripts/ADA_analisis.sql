--#####################################
--######### CHANGE-OVER-TIME ##########
--#####################################

-- Encontrar el Numero de Quejas a traves del Tiempo

-- por Fecha

SELECT
	fecha_ingreso,
	COUNT(expediente) AS total_quejas
FROM gold.quejas_telecom
GROUP BY fecha_ingreso

-- Por Año

SELECT
	YEAR(fecha_ingreso) AS año_queja,
	COUNT(expediente) AS total_quejas
FROM gold.quejas_telecom
GROUP BY YEAR(fecha_ingreso)
ORDER BY año_queja

-- Por Año, quejas x proveedores 

SELECT
	YEAR(fecha_ingreso) AS año_queja,
	COUNT(expediente) AS total_quejas,
	COUNT(DISTINCT proveedor) AS total_proveedores,
	COUNT(DISTINCT oficina_defensa_consumidor) AS total_odecos
FROM gold.quejas_telecom
GROUP BY YEAR(fecha_ingreso)
ORDER BY año_queja

-- Por Mes, quejas x proveedores 

SELECT
	MONTH(fecha_ingreso) AS mes_queja,
	COUNT(expediente) AS total_quejas,
	COUNT(DISTINCT proveedor) AS total_proveedores,
	COUNT(DISTINCT oficina_defensa_consumidor) AS total_odecos
FROM gold.quejas_telecom
GROUP BY MONTH(fecha_ingreso)
ORDER BY mes_queja

-- Por Año x Mes, quejas x proveedores 

SELECT
	YEAR(fecha_ingreso) AS año_queja,
	MONTH(fecha_ingreso) AS mes_queja,
	COUNT(expediente) AS total_quejas,
	COUNT(DISTINCT proveedor) AS total_proveedores,
	COUNT(DISTINCT oficina_defensa_consumidor) AS total_odecos
FROM gold.quejas_telecom
GROUP BY YEAR(fecha_ingreso), MONTH(fecha_ingreso)
ORDER BY año_queja, mes_queja


--#####################################
--######## CUMULATIVE ANALYSIS ########
--#####################################

--Calcular el total de quejas por mes
-- y el total acumulado de quejas a 
-- traves de los 4 años

SELECT
	mes_ingreso,
	total_quejas,
	SUM(total_quejas) OVER(ORDER BY mes_ingreso) AS total_quejas_acumuladas
FROM (
	SELECT
		DATETRUNC(month, fecha_ingreso) AS mes_ingreso,
		COUNT(expediente) AS total_quejas
	FROM gold.quejas_telecom
	GROUP BY DATETRUNC(month, fecha_ingreso)
	)t

--Calcular el total de quejas por mes
-- y el total acumulado de quejas a 
-- traves de cada año

SELECT
	mes_ingreso,
	total_quejas,
	SUM(total_quejas) OVER(PARTITION BY YEAR(mes_ingreso) ORDER BY mes_ingreso) AS total_quejas_acumuladas
FROM (
	SELECT
		DATETRUNC(month, fecha_ingreso) AS mes_ingreso,
		COUNT(expediente) AS total_quejas
	FROM gold.quejas_telecom
	GROUP BY DATETRUNC(month, fecha_ingreso)
	)t 

--Calcular el total de quejas por mes
-- y el total acumulado de quejas a 
-- traves de cada año

SELECT
	mes_ingreso,
	total_quejas,
	SUM(total_quejas) OVER(PARTITION BY YEAR(mes_ingreso) ORDER BY mes_ingreso) AS total_quejas_acumuladas,
	AVG(total_quejas) OVER(PARTITION BY YEAR(mes_ingreso) ORDER BY mes_ingreso) AS media_quejas_movil
FROM (
	SELECT
		DATETRUNC(month, fecha_ingreso) AS mes_ingreso,
		COUNT(expediente) AS total_quejas
	FROM gold.quejas_telecom
	GROUP BY DATETRUNC(month, fecha_ingreso)
	)t 


--#####################################
--######## PERFORMANCE ANALYSIS #######
--#####################################

-- Analizar el desempeño -anual- del -numero de quejas- comparando
-- la cantitdad de quejas por cierto -motivo- contra
-- el promedio del numero de quejas del motivo, y también, contra el numero de quejas
-- de años pasados.

-- Desempeño anual del numero de quejas (METODO CTE)

WITH quejas_anuales AS (
SELECT 
	YEAR(fecha_ingreso) AS año_ingreso,
	motivo_reclamacion,
	COUNT(expediente) AS total_quejas
FROM gold.quejas_telecom
GROUP BY YEAR(fecha_ingreso), motivo_reclamacion
)

SELECT
	año_ingreso,
	motivo_reclamacion,
	total_quejas,
	AVG(total_quejas) OVER(PARTITION BY motivo_reclamacion) AS media_quejas,
	total_quejas - AVG(total_quejas) OVER(PARTITION BY motivo_reclamacion)  AS diferencia_media_quejas,
	CASE WHEN total_quejas - AVG(total_quejas) OVER(PARTITION BY motivo_reclamacion) > 0 THEN 'Arriba del Promedio'
		 WHEN total_quejas - AVG(total_quejas) OVER(PARTITION BY motivo_reclamacion) < 0 THEN 'Abajo del Promedio'
		 ELSE 'Promedio'
	END AS cambio_promedio_quejas,
	-- Year-Over_Year (YOY) Analysis
	LAG(total_quejas) OVER(PARTITION BY motivo_reclamacion ORDER BY año_ingreso ASC) AS quejas_año_anterior,
	total_quejas - LAG(total_quejas) OVER(PARTITION BY motivo_reclamacion ORDER BY año_ingreso ASC) AS diferencia_año_anterior,
	CASE WHEN total_quejas - LAG(total_quejas) OVER(PARTITION BY motivo_reclamacion ORDER BY año_ingreso ASC) > 0 THEN 'Incremento'
		 WHEN total_quejas - LAG(total_quejas) OVER(PARTITION BY motivo_reclamacion ORDER BY año_ingreso ASC) < 0 THEN 'Decremento'
		 ELSE 'Diferencia Nula'
	END AS cambio_año_anterior
FROM quejas_anuales
ORDER BY motivo_reclamacion, año_ingreso


--#####################################
--########## PART-TO-WHOLE ############
--#####################################

--Cuales son los motivos que mas contribuyen al  total de quejas.

WITH motivo_#quejas AS (
SELECT
	motivo_reclamacion,
	COUNT(expediente) AS total_quejas
FROM gold.quejas_telecom
GROUP BY motivo_reclamacion
)

SELECT
	motivo_reclamacion,
	total_quejas,
	SUM(total_quejas) OVER() AS grantotal_quejas,
	CONCAT(ROUND((CAST(total_quejas AS FLOAT) / SUM(total_quejas) OVER()) * 100, 2), '%') AS porcentaje_total 
FROM motivo_#quejas
ORDER BY total_quejas DESC

--#####################################
--######### DATA SEGMENTATION #########
--#####################################

-- Separar los motivos de las quejas por rango de -numero de apariciones-
-- y -contar cuantos motivos- caen en cada segmento.

WITH segmento_motivos AS (
SELECT
	motivo_reclamacion,
	COUNT(expediente) AS total_quejas,
	CASE WHEN COUNT(expediente) < 1680 THEN 'ABAJO DE 1680'
		 WHEN COUNT(expediente) BETWEEN 1680 AND 3360 THEN '1680 - 3360'
		 ELSE 'ARRIBA DE 3360'
	END AS rango_#quejas
FROM gold.quejas_telecom
GROUP BY motivo_reclamacion 
)
SELECT
	rango_#quejas,
	COUNT(motivo_reclamacion) AS total_motivos
FROM segmento_motivos
GROUP BY rango_#quejas
ORDER BY total_motivos DESC

-- Agrupar proveedores en 3 grupos basados 
-- en el numero de diferentes motivos de reclamacion (Existen 90 en total).
--	- Problematico 1: El proveedor que tenga 47 o más diferentes motivos de quejas
--	- Problematico 2: El proveedor que tenga entre 24 y 46 diferentes tipos de quejas.
--	- Problematico 3: El proveedor que tenga 23 o menos deiferentes tipos de quejas.
-- y encontrar el numero total de proveedores en cada grupo.

WITH clase_proveedor AS (
SELECT
	proveedor,
	COUNT(DISTINCT motivo_reclamacion) AS total_motivos,
	CASE WHEN COUNT(DISTINCT motivo_reclamacion) < 23 THEN 'Problematico #3'
		 WHEN COUNT(DISTINCT motivo_reclamacion) BETWEEN 24 AND 46 THEN 'Problematico #2'
		 ELSE 'Problematico #1'
	END AS proveedor_problematico
FROM gold.quejas_telecom
GROUP BY proveedor
)
SELECT
	proveedor_problematico,
	COUNT(proveedor) AS total_proveedores
FROM clase_proveedor
GROUP BY proveedor_problematico
ORDER BY total_proveedores DESC
