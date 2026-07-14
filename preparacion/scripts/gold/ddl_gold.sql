/*
===============================================================================
Codigo DDL: Crear las Vistas 'gold'
===============================================================================
Propoósito del Codigo:
    Este codigo crea las vistas para la capa 'gold'.
    La capa 'gold' representa la tabla final.

    Cada vista realiza transformaciones desde la capa 'silver' para 
    producir un conjunto de datos limpio, enriquecido y listo para su uso 
    en análisis.

Uso:
    - Estas vistas se pueden consultar directamente para análisis e informes.
===============================================================================
*/

-- =============================================================================
-- Creación: gold.quejas_telecom
-- =============================================================================
IF OBJECT_ID('gold.quejas_telecom', 'V') IS NOT NULL
    DROP VIEW gold.quejas_telecom;
GO

CREATE VIEW gold.quejas_telecom AS
SELECT
	expediente, -- Reporte
	medio_ingreso,
	estado_procesal,
	tipo_reclamacion,
	motivo_reclamacion,
	fecha_ingreso,
	CASE expediente
		WHEN 'PFC.HGO.B.3/001586-2022' THEN CONVERT(DATE, '2023-05-04', 120)
		WHEN 'PFC.YUC.B.3/001891-2022' THEN CONVERT(DATE, '2023-05-04', 120)
		WHEN 'PFC.ZAC.B.3/000867-2022' THEN CONVERT(DATE, '2023-05-02', 120)
		ELSE fecha_cierre
	END AS fecha_cierre,
	tipo_conciliacion,
	CASE WHEN procedimiento = 'Conciliación por Medios Electrónicos' THEN 'Conciliación Medios Electrónicos'
		 ELSE procedimiento
	END AS procedimiento,
	monto_reclamado,
	monto_recuperado,
	proveedor, -- proveedor
	nombre_comercial,
	giro,
	tipo_producto, -- Producto
	clase,
	modalidad_compra,
	modalidad_pago,
	costo_bien_servicio,
	odeco AS oficina_defensa_consumidor, -- Oficinas
	estado
FROM silver.quejas_telecom;
GO
