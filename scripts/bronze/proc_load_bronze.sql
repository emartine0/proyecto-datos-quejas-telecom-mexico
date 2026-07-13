/*
===============================================================================
Procedimientos Almacenados: Cargar la capa 'Bronze' (Fuente -> Bronze)
===============================================================================
Proposito del Codigo:
    Este procedimiento almacenado carga los datos en el esquema 'bronze' desde un archivo CSV externo.
    Este ejecuta las siguientes acciones: 
    - Vacía las tablas 'bronze' antes de cargar los datos.
    - Utiliza el comando BULK INSERT para cargar los datos desde archivos CSV a las tablas 'bronze'.

Parametros:
    None. 
	  Este procedimeitno almacenado no acepta ningun parametro ni regresa ningun valor.

Ejemplo de uso:
    EXEC bronze.load_bronze;
===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME;
	BEGIN TRY
		PRINT '===================================================';
		PRINT 'Cargando la Capa "bronze"';
		PRINT '===================================================';

		SET @start_time = GETDATE();
		PRINT '>> Vaciando la Tabla: bronze.quejas_telecom';
		TRUNCATE TABLE bronze.quejas_telecom

		PRINT '>> Llenando la Tabla: bronze.quejas_telecom';
		BULK INSERT bronze.quejas_telecom
		FROM 'C:\Users\emartine\Documents\DSProjects\QuejasTelecom\quejas_telecom.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = '","',
			CODEPAGE = '65001',
			TABLOCK
		);
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
