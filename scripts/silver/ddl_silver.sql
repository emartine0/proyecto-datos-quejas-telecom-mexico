/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

IF OBJECT_ID ('silver.quejas_telecom', 'U') IS NOT NULL
	DROP TABLE silver.quejas_telecom;
GO
  
CREATE TABLE silver.quejas_telecom (
	expediente NVARCHAR(85),
	fecha_ingreso NVARCHAR(85),
	fecha_cierre NVARCHAR(85),
	tipo_conciliacion NVARCHAR(85),
	estado_procesal NVARCHAR(85),
	proveedor NVARCHAR(85),
	nombre_comercial NVARCHAR(85),
	giro NVARCHAR(85),
	odeco NVARCHAR(85), 
	estado NVARCHAR(85),
	tipo_reclamacion NVARCHAR(85),
	motivo_reclamacion NVARCHAR(85),
	costo_bien_servicio NVARCHAR(85),
	monto_reclamado NVARCHAR(85),
	monto_recuperado NVARCHAR(85), 
	procedimiento NVARCHAR(85),
	medio_ingreso NVARCHAR(85),
	clase NVARCHAR(85),
	tipo_producto NVARCHAR(85),
	modalidad_compra NVARCHAR(85),
	modalidad_pago NVARCHAR(85),
	md_fecha_creacion DATETIME2 DEFAULT GETDATE()
);
GO
