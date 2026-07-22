/*
=============================================================
Crear Base de Datos y Esquemas
=============================================================
Propósito del Script:
    Este codigo crea una nueva base de datos llamada 'QuejasTelecomMex' después de verificar si ya existe. 
    Si la base de datos existe se elimina y se recrea. Adicionalmente, el codigo configura tres esquemas
    dentro de la base de datos:'bronze', 'silver', y 'gold'.
	
ADVERTENCIA:
    Correr este codigo eliminara completamente la base de datos 'QuejasTelecomMex' si esta ya existe. 
    Todos los datos dentro de la misma serán permanentemente borrados. Es necesario proceder con cautela y 
    asegurarse de que se tienen los respaldos correspondientes antes de correr este codigo.
*/

USE master;
GO

-- Elimina y recrea la base de datos 'QuejasTelecomMex'
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'QuejasTelecomMex')
BEGIN
    ALTER DATABASE QuejasTelecomMex SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE QuejasTelecomMex;
END;
GO

-- Crea la base de datos 'QuejasTelecomMex'
CREATE DATABASE QuejasTelecomMex;
GO

USE QuejasTelecomMex;
GO

-- Crear los esquemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
