/*
=====================================================================================
Procedimiento Almacenado: Carga la capa Silver (Bronze -> Silver)
=====================================================================================
Proposito del Codigo:
    Este procedimiento almacenado realiza el proceso ETL (Extract, Transform, Load)
    para llenar las tablas del esquema 'silver' desde el esquema 'bronze'.
  Acciones Realizadas:
      - Elimina las tablas 'silver'
      - Llena los datos limpios y transformados desde el esquema 'bronze' en 
        las tablas 'silver'.

Parametros:
    Ninguno. 
	  Este procedimiento almacenado no acepta ningun parametro ni regresa ningun valor.

Ejemplo de Uso:
    EXEC Silver.load_silver;
=====================================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME;
	BEGIN TRY
		PRINT '===================================================';
		PRINT 'Cargando la Capa "silver"';
		PRINT '===================================================';

		SET @start_time = GETDATE();
        PRINT '>> Vaciando la Tabla: silver.quejas_telecom';
        TRUNCATE TABLE silver.quejas_telecom;

        PRINT '>> Llenando la Tabla: silver.quejas_telecom';
        INSERT INTO silver.quejas_telecom (
            expediente,
            fecha_ingreso,
            fecha_cierre,
            tipo_conciliacion,
            estado_procesal,
            proveedor,
            nombre_comercial,
            giro,
            odeco,
            estado,
            tipo_reclamacion,
            motivo_reclamacion,
            costo_bien_servicio,
            monto_reclamado,
            monto_recuperado,
            procedimiento,
            medio_ingreso,
            clase,
            tipo_producto,
            modalidad_compra,
            modalidad_pago
        )
        SELECT
            TRIM('"' FROM expediente) AS expediente,
            CONVERT(DATE, fecha_ingreso, 120) AS fecha_ingreso,
            CONVERT(DATE, fecha_cierre, 120) AS fecha_cierre,
            CASE WHEN tipo_conciliacion = 'En Proceso' THEN 
                    CASE WHEN fecha_cierre IS NOT NULL THEN 'n/a'
                        WHEN estado_procesal = 'No Conciliada' THEN 'n/a'
                        WHEN estado_procesal = 'Cancelada' THEN 'Cancelada'
                    END         
                    ELSE tipo_conciliacion
            END as tipo_conciliacion,
            CASE WHEN estado_procesal = 'Turnada a Concil Person P/seg' THEN 'n/a'
                    ELSE estado_procesal
            END AS estado_procesal,
            proveedor,
            nombre_comercial,
            CASE WHEN giro = 'Empresa de Larga Distancia' OR giro = 'Empresa de Telefonía' THEN 'Empresa de Telefonía'
                    WHEN giro = 'Empresa de Tv de Paga (de Tv Restringida)' OR giro = 'Empresa de Tv de Paga' OR giro = 'Televisión por Cable' OR giro = 'Television por Cable' THEN 'Empresa Tv de Paga'
                    WHEN giro = 'Distribuidor de Servicio de Telefonía Celular' OR giro = 'Empresa de Telefonía Celular' OR giro = 'Empresa de Telefonia Celular' THEN 'Empresa de Telefonía Celular'
                    WHEN giro = 'Televisión Satelital' OR giro = 'Tv Satelital' OR giro = 'Tv Vía Satélite' OR giro = 'Tv Vía Sátelite' THEN 'Tv Satelital'
                    ELSE giro
            END AS giro,
            odeco,
            estado,
            tipo_reclamacion,
            CASE motivo_reclamacion
                WHEN 'Comprobantes Neg' THEN 'Comprobantes Negados'
                WHEN 'Estados de Cuenta Neg' THEN 'Estados de Cuenta Negados'
                WHEN 'Forma de Pago Neg' THEN 'Forma de Pago Negada'
                WHEN 'Pagos a Capital Neg' THEN 'Pagos a Capital Negados'
                WHEN 'Periodicidad de Pagos Neg' THEN 'Periodicidad de Pagos Negada'
                ELSE motivo_reclamacion
            END AS motivo_reclamacion,
            CONVERT(FLOAT, NULLIF(costo_bien_servicio, '0')) AS costo_bien_servicio,
            CASE WHEN monto_reclamado = 'Sin Dato' OR monto_reclamado = '-' OR monto_reclamado = 'Oo' THEN NULL
                    ELSE monto_reclamado
            END AS monto_reclamado,
            CONVERT(FlOAT, monto_recuperado) AS monto_recuperado,
            CASE procedimiento
                WHEN '-' THEN 'n/a'
                WHEN '0' THEN 'n/a'
                WHEN 'Proc. Infracciones a la Ley' THEN 'Procedimiento por Infracciones a la Ley'
                WHEN 'Sol. de Dictamen' THEN 'Solicitud de Dictamen'
                WHEN 'Resol al Recurso de Rev. Admin' THEN 'Resolución al Recurso de Revisión Administrativa'
                WHEN 'Cumpliment Sentencia o Resoluc' THEN 'Cumplimiento de Sentencia o Resolución'
                WHEN 'Conciliación Medios Electrónic' THEN 'Conciliación por Medios Electrónicos'
                ELSE procedimiento
            END AS procedimiento,
            CASE WHEN medio_ingreso = 'Bien' OR medio_ingreso = 'Servicio' THEN clase
                 WHEN medio_ingreso = 'Sin Dato' OR medio_ingreso = '-' THEN 'n/a'
                 ELSE medio_ingreso
            END AS medio_ingreso,
            CASE WHEN medio_ingreso = 'Bien' OR medio_ingreso = 'Servicio' THEN medio_ingreso
                 ELSE clase
            END AS clase,
            CASE WHEN tipo_producto = 'Sin dato' OR tipo_producto = '-' THEN 'n/a'
                 ELSE tipo_producto
            END AS tipo_producto,
            CASE WHEN modalidad_compra = 'Sin dato' OR modalidad_compra = '-' THEN 'n/a'
                 ELSE modalidad_compra
            END AS modalidad_compra,
            CASE WHEN modalidad_pago = 'Sin dato' OR modalidad_pago = '-' OR modalidad_pago = '0' THEN 'n/a'
                 ELSE modalidad_pago
            END AS modalidad_pago
        FROM bronze.quejas_telecom
        WHERE expediente COLLATE Modern_Spanish_CS_AS NOT IN ('"PFC.yUC.B.3/001619-2024', '"PFC.yUC.B.3/001976-2024')
        AND proveedor != '-';
    	SET @end_time = GETDATE();
		PRINT '>> Timpo de Carga: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' segundos';
	END TRY
    BEGIN CATCH
	    PRINT '===================================================';
	    PRINT 'UN ERROR HA OCURRIDO AL CARGAR LA CAPA DE "BRONZE"';
	    PRINT 'Mensaje de Error' + ERROR_MESSAGE();
	    PRINT 'Mensaje de Error' + CAST(ERROR_NUMBER() AS NVARCHAR);
	    PRINT 'Mensaje de Error' + CAST(ERROR_STATE() AS NVARCHAR);
	    PRINT '===================================================';
    END CATCH
END

