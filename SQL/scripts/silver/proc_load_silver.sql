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
        -- Presentando el CTE
        WITH base_clean AS (
	        SELECT
                expediente,
                fecha_ingreso,
                fecha_cierre,
                tipo_conciliacion,
                estado_procesal,                
		        LOWER(proveedor) COLLATE Modern_Spanish_CI_AI AS proveedor,
		        CASE WHEN nombre_comercial = 'P. Física' OR nombre_comercial = 'P. Moral' OR nombre_comercial = 'Otro' THEN 'otros'
			         WHEN nombre_comercial = '-' THEN 'n/a'
			         ELSE LOWER(nombre_comercial)
		        END COLLATE Modern_Spanish_CI_AI AS nombre_comercial,
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
	        FROM bronze.quejas_telecom
        )
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
            -- limpieza profunda proveedor
	        CASE WHEN proveedor = 'ads mobile s. de r.l. de c.v.' THEN 'ads mobile services s. de r.l. de c.v.'
		         WHEN proveedor = 'ahorra cell' OR proveedor = 'ahorro cel' THEN 'freedompop mexico s.a. de c.v.'
		         WHEN proveedor = 'appel operations méxico s.a. de c.v.' OR 
			          proveedor = 'apple computer méxico s.a. de c.v.' OR 
			          proveedor = 'apple mexicali' OR 
			          proveedor = 'apple méxico s.a. de c.v.' THEN 'apple operations mexico s.a. de c.v.'
		         WHEN proveedor = 'axtel, s.a.b. de c.v.' THEN 'axtel s.a.b. de c.v.'
		         WHEN proveedor = 'izzi telecom empresas cablevisión s.a.b. de c.v.' OR
			          proveedor = 'cablevision s.a. de c.v.' THEN 'empresas cablevisión s.a.b. de c.v.'
		         WHEN proveedor = 'cable vision regional s.a. de c.v.' THEN 'cablevisión regional s.a. de c.v.'
		         WHEN proveedor = 'cacsi de occidente, s. de r.l. de c.v.' THEN 'cacsi de occidente s. de r.l. de c.v.'
		         WHEN proveedor = 'celular´s bull´s' OR
			          proveedor = 'telefonía móvil y accesorios celular s bull s' THEN  'celulars bulls'
		         WHEN proveedor = 'celulares y accesorios del sureste s.a.' THEN 'celulares y accesorios del sureste s.a. de c.v.'
		         WHEN proveedor = 'city*cell' OR
			          proveedor = 'citycell s.a. de c.v. torreón aurora' THEN 'citycell s.a. de c.v.'
		         WHEN proveedor = 'ck comunicaciones' OR
			          proveedor = 'ck comunicaciones s.a. de c.v.' THEN 'ck ingeniería en telecomunicaciones s.a. de c.v.'
		         WHEN proveedor = 'comercializadora innovaciones y productos en comunicaciones s.a. de c.v.' THEN 'comercializadora innovaciones y productos en comunicación s.a. de c.v.' 
		         WHEN proveedor = 'comunicaciones digitales. de r.l. de c.v.' THEN 'comunicaciones digitales s. de r.l. de c.v.'
		         WHEN proveedor = 'distribuidor celular zona centro s.a. de c.v.' OR
			          proveedor = 'distribuidora celular de la zona centro s.a. de c.v.' THEN 'distribuidor celular de la zona centro s.a. de c.v.'
		         WHEN proveedor = 'empresas cablevisión s.a. de c.v.' THEN 'empresas cablevisión s.a.b. de c.v.'
		         WHEN proveedor = 'eni networks s.a. de c.v.' OR
			          proveedor = 'eninetworks s.a.p.i. de c.v.' THEN 'eni networks s.a.p.i. de c.v.'
		         WHEN proveedor = 'habicom desarollos s.a. de c.v.' OR
			          proveedor = 'habicom desarrollos s.a. de c.v. (riveras de bravo)' THEN 'habicom desarrollos s.a. de c.v.'
		         WHEN proveedor = 'hns de méxico, s.a. de c.v.' THEN 'hns de méxico s.a. de c.v.'
		         WHEN proveedor = 'honor techologies de méxico s.a. de c.v.' THEN 'honor technologies de méxico s.a. de c.v.'
		         WHEN proveedor = 'huawei technologies de méxico s.a. de c.v..' THEN 'huawei technologies de méxico s.a. de c.v.'
		         WHEN proveedor = 'ingram micro s.a. de c.v.' THEN 'ingram micro méxico s.a. de c.v.'
		         WHEN proveedor = 'megacable s.a. de c.v.' THEN 'mega cable s.a. de c.v.'
		         WHEN proveedor = 'red de telecomunicaciones s. de r.l. de c.v.' THEN 'méxico red de telecomunicaciones s. de r.l. de c.v.'
		         WHEN proveedor = 'motorola de méxico s.a.' THEN 'motorola comercial s.a. de c.v.'
		         WHEN proveedor = 'mvs net, s.a. de c.v.' THEN 'mvs net s.a. de c.v.'
		         WHEN proveedor = 'promotora musical s.a. de c.v. .' THEN 'promotora musical s.a. de c.v.'
		         WHEN proveedor = 'samsung electronic méxico s.a. de c.v.' THEN 'samsung electronics méxico s.a. de c.v.'
		         WHEN proveedor = 'servicios intermediarios reuse méxico' THEN 'servicios intermediarios reuse méxico s.a. de c.v.'
		         WHEN proveedor = 'starlink satelite systems méxico s. de r.l. de c.v.' THEN 'starlink satellite systems méxico s. de r.l. de c.v.'
		         WHEN proveedor = 'teléfonos de méxico s.a. de c.v.' OR
		              proveedor = 'telmex s.a. de c.v.' OR
			          proveedor = 'telmex s.a.b. de c.v.' THEN 'teléfonos de méxico s.a.b. de c.v.'
		         WHEN proveedor = 'teléfonos de noroeste s.a. de c.v.' THEN 'teléfonos del noroeste s.a. de c.v.'
		         WHEN proveedor = 'televisión internaciona s.a. de c.v.' OR
			          proveedor = 'televisión internacionals.a. de c.v.' THEN 'televisión internacional s.a. de c.v.'
		         WHEN proveedor = 'telmov, s.a. de c.v.' THEN 'telmov s.a. de c.v.'
		         WHEN proveedor = 'telecomunicaciones s.a. de c.v.' OR
			          proveedor = 'total play telecomunicaciones s.a. de c.v.' OR
			          proveedor = 'total play telecomunicaciones s.a.b. de c.v.' THEN 'total play telecomunicaciones s.a.p.i. de c.v.'
		         WHEN proveedor = 'up inn méxico s.a. de c.v.' OR
			          proveedor = 'xiaomi store up inn de méxico s.a. de c.v.' THEN 'up inn de méxico s.a. de c.v.'
		         WHEN proveedor = 'vmc project managment s.a. de c.v.' THEN 'vmc project management s.a. de c.v.'
		         WHEN proveedor = 'wal mart innovación s. de r.l. de c.v.' OR
			          proveedor = 'walmart innovación s. de r.l. de c.v.' THEN 'wal-mart innovación s. de r.l. de c.v.'
		         WHEN proveedor = 'wimob retail s. de r.l. de c.v.' THEN 'wimob s. de r.l. de c.v.'
		         WHEN proveedor = 'worplay s.a. de c.v.' THEN 'workplay s.a. de c.v.'
		         WHEN proveedor = 'xiaomi software méxico s. de r.l. de c.v.' OR 
			          proveedor = 'xiaomi comunications' OR 
			          proveedor = 'xiaomi electronics' OR
			          proveedor = 'xiaomi mi store' THEN 'xiaomi software de méxico s. de r.l. de c.v.'
		         WHEN proveedor = 'pripietario de simitech' THEN 'propietario de simitech'
		         WHEN proveedor = 'p. física' OR proveedor = 'pesona física' THEN 'persona física'
		         ELSE proveedor
	        END COLLATE Modern_Spanish_CI_AI  AS proveedor,
            -- limpieza profunda nombre_comercial
			CASE WHEN proveedor = 'ahorra cell' OR proveedor ='ahorro cel' THEN 'ahorrocel'
				 WHEN proveedor = 'alestra innovación digital s. de r.l. de c.v.' THEN 'alestra'
				 WHEN proveedor = 'bazaya méxico s. de r.l. de c.v.' THEN 'linio'
				 WHEN proveedor = 'cablevision s.a. de c.v.' THEN 'cablevision, s.a.b. de c.v.'
				 WHEN proveedor = 'cable vision regional s.a. de c.v.' OR
					  proveedor = 'cablevisión regional s.a. de c.v.' THEN 'izzi'
				 WHEN proveedor = 'celular express s.a. de c.v.' THEN 'otros'
				 WHEN proveedor = 'celular´s bull´s' OR
					  proveedor = 'telefonía móvil y accesorios celular s bull s' THEN  'otros'
				 WHEN proveedor = 'celulares económicos s.a. de c.v.' THEN 'otros'
				 WHEN proveedor = 'celulares y accesorios del sureste s.a.' OR
					  proveedor = 'celulares y accesorios del sureste s.a. de c.v.' THEN 'macropay'
				 WHEN proveedor = 'cfe telecomunicaciones e internet para todos' THEN 'cfe internet'
				 WHEN proveedor = 'ck comunicaciones' OR
		 			  proveedor = 'ck comunicaciones s.a. de c.v.' THEN 'ck comunicaciones'
				 WHEN proveedor = 'coeficiente comunicaciones s.a. de c.v.' THEN 'coeficiente'
				 WHEN proveedor = 'comercializadora sanz s.a. de c.v.' THEN 'otros'
				 WHEN proveedor = 'compercel' THEN 'otros'
				 WHEN proveedor = 'comunicaciones digitales. de r.l. de c.v.' THEN 'at&t'
				 WHEN proveedor = 'corporativo empresarial sistel s.a. de c.v.' THEN 'telcel'
				 WHEN proveedor = 'ctdi méxico s.a. de c.v.' THEN 'ctdi'
				 WHEN proveedor = 'dgl latam s.a. de c.v.' THEN 'dgl latam'
				 WHEN proveedor = 'digital guru s.a.' THEN 'otros'
				 WHEN proveedor = 'digital shop s.a. de c.v.' THEN 'digital shop'
				 WHEN proveedor = 'eii telecom s.a. de c.v.' THEN 'weii'
				 WHEN proveedor = '' THEN ''
				 WHEN proveedor = 'gh celulares slp' THEN 'gh celulares'
				 WHEN proveedor = 'grupo w com s.a. de c.v.' AND nombre_comercial = 'star tv' THEN 'startv'
				 WHEN proveedor = 'hns de méxico s.a. de c.v.' THEN 'hughesnet'
				 WHEN proveedor = 'islim telco s.a.p.i. de c.v.' THEN 'netwey'
				 WHEN proveedor = 'jumbo prosper limited s.a. de c.v.' THEN 'otros'
				 WHEN proveedor = 'méxico red de telecomunicaciones s. de r.l. de c.v.' OR
					  proveedor = 'red de telecomunicaciones s. de r.l. de c.v.' THEN 'metrored'		 
				 WHEN proveedor = 'mvs net, s.a. de c.v.' AND nombre_comercial = 'mvs' THEN 'mvs televisión'
				 WHEN proveedor = 'promotora musical s.a. de c.v.' THEN 'ishop mixup'
				 WHEN proveedor = 'servicios empresariales de alta calidad s.a. de c.v.' THEN 'otros'
				 WHEN proveedor = 'sistemas empresariales dabo s.a. de c.v.' THEN 'macstore'
				 WHEN proveedor = 'tatric s. de r.l. de c.v.' THEN 'otros'
				 WHEN proveedor = 'techcomm wireless mx s.a. de c.v.' THEN 'techcomm wireless'
				 WHEN proveedor = 'tecnología sanje s.a.p.i. de c.v.' THEN 'tecnología sanje'
				 WHEN proveedor = 'telecable del mineral s.a. de c.v.' AND nombre_comercial = 'telecable del mineral' THEN 'telecable'
				 WHEN proveedor = 'telecomunicación global s.a. de c.v.' THEN 'tglobal'
				 WHEN proveedor = 'teléfonos del noroeste s.a. de c.v.' AND nombre_comercial = 'telmex' THEN 'telnor'
				 WHEN proveedor = 'teléfonos y computadoras s.a. de c.v.' THEN 'otros'
				 WHEN proveedor = 'televera red s.a.p.i. de c.v.' THEN 'stargo'
				 WHEN proveedor = 'telmov, s.a. de c.v.' OR
					  proveedor = 'telmov móvil s.a. de c.v.' OR
					  proveedor = 'telmov s.a. de c.v.' THEN 'telmovil'
				 WHEN proveedor = 'total play telecomunicaciones s.a. de c.v.' OR
					  proveedor = 'total play telecomunicaciones s.a.b. de c.v.' OR
					  proveedor = 'total play telecomunicaciones s.a.p.i. de c.v.' THEN 'totalplay'
				 WHEN proveedor = 'triara.com s.a. de c.v.' THEN 'otros'
				 WHEN proveedor = 'up inn méxico s.a. de c.v.' OR
					  proveedor = 'xiaomi store up inn de méxico s.a. de c.v.' OR
					  proveedor = 'up inn de méxico s.a. de c.v.' THEN 'xiaomi store'
				 WHEN proveedor = 'virgin mobile méxico s. de r.l. de c.v.' THEN 'virgin mobile'
				 WHEN proveedor = 'wdc méxico s. de r.l. de c.v.' THEN 'disney+'
				 WHEN proveedor = 'wewow s.a. de c.v.' THEN 'wewow'
				 WHEN proveedor = 'wimob retail s. de r.l. de c.v.' OR
					  proveedor = 'wimob s. de r.l. de c.v.' THEN 'wimob'
				 WHEN proveedor = 'worplay s.a. de c.v.' OR
					  proveedor = 'workplay s.a. de c.v.' THEN 'workplay'
				 WHEN proveedor = 'xiaomi software méxico s. de r.l. de c.v.' OR 
					  proveedor = 'xiaomi comunications' OR 
					  proveedor = 'xiaomi electronics' OR
					  proveedor = 'xiaomi mi store' OR
					  proveedor = 'xiaomi software de méxico s. de r.l. de c.v.' THEN 'xiaomi store'
				 WHEN proveedor = 'p. física' OR
					  proveedor = 'pesona física' OR
					  proveedor = 'persona física' THEN 'otros'
				 ELSE nombre_comercial
			END COLLATE Modern_Spanish_CI_AI AS nombre_comercial,
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
				 WHEN clase = 'Sin dato' OR clase = '-' THEN 'n/a'
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
        FROM base_clean
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
