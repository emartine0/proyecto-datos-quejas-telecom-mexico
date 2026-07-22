/*
============================================================================================
Reporte de Proveedores
============================================================================================
Proposito:
	- Este reporte consolida metricas y comportamientos clave de sobre los proveedores.

Features:
	1. Agrupa informacion esencial como la razon social, nombre comercial y detalles de la queja.
	2. Agrupa proveedores en categorias (Nivel de Conflictividad: Nv 1, Nv 2 y Nv 3)
	3. Resume metricas de los proveedores
		- Total de quejas
		- Total de motivos de reclamaciones
		- Total de reclamaciones monetarias
		- Total de reclamaciones monetarias recuperadas
	4. Calcula Indicadores de Desempeño Claves (IDC-KPI):
		- Tiempo medio de resolucion de la queja
		- Monto promedio de reclamaciones
		- Cantidad mensual promedio de quejas
		- Cantidad mensual promedio de diferentes reclamaciones
=============================================================================================
*/

-- =============================================================================
-- Create Report: gold.reporte_proveedores
-- =============================================================================
IF OBJECT_ID('gold.reporte_proveedores', 'V') IS NOT NULL
    DROP VIEW gold.reporte_proveedores;
GO

CREATE VIEW gold.reporte_proveedores AS 
  
WITH base_query AS (
/*-------------------------------------------------------------------------------------------
1) Query de Base: Tomar y crear las columna clave de la tabla
-------------------------------------------------------------------------------------------*/
	SELECT
		proveedor,
		nombre_comercial,
		expediente,
		estado_procesal,
		fecha_ingreso,
		fecha_cierre,
		tipo_reclamacion,
		motivo_reclamacion,
		monto_reclamado,
		CASE WHEN monto_reclamado != 0 THEN 1
			 ELSE 0
		END AS queja_monetaria,
		CASE WHEN monto_recuperado != 0 THEN 1
			 ELSE 0
		END AS queja_monetaria_recuperada
	FROM gold.quejas_telecom
),
resumen_metricas AS (
/*---------------------------------------------------------------------------
2) Resumenes proveedores: Resume las metricas clave a nivel de proveedor
---------------------------------------------------------------------------*/
	SELECT 
		proveedor,
		YEAR(fecha_ingreso) AS año_ingreso,
		COUNT(expediente) AS total_quejas,
		SUM(queja_monetaria) AS total_quejas_monetarias,
		SUM(queja_monetaria_recuperada) AS total_montos_recuperados,
		COUNT(DISTINCT motivo_reclamacion) AS total_motivos_reclamacion,
		ROUND(AVG(DATEDIFF(day, fecha_ingreso, fecha_cierre)),2) AS tiempo_medio_resolucion,
		AVG(monto_reclamado) AS monto_promedio_reclamacion,
		CASE WHEN COUNT(DISTINCT motivo_reclamacion) < 23 THEN 'Nv 3'
			 WHEN COUNT(DISTINCT motivo_reclamacion) BETWEEN 24 AND 46 THEN 'Nv 2'
			 ELSE 'Nv 1'
		END AS nivel_conflictividad
	FROM base_query
	GROUP BY proveedor, YEAR(fecha_ingreso)
)

SELECT 
	proveedor,
	año_ingreso,
	total_quejas,
	total_quejas_monetarias,
	total_montos_recuperados,
	tiempo_medio_resolucion,
	monto_promedio_reclamacion,
	nivel_conflictividad,
	AVG(total_quejas) AS promedio_anual_quejas,
	AVG(total_motivos_reclamacion) AS promedio_anual_motivos
FROM resumen_metricas
GROUP BY proveedor,
	año_ingreso,
	total_quejas,
	total_quejas_monetarias,
	total_montos_recuperados,
	tiempo_medio_resolucion,
	monto_promedio_reclamacion,
	nivel_conflictividad
