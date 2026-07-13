/*
===============================================================================================
Control de Calidad
===============================================================================================
Proposito del Codigo:
    Este script realiza varias comprobaciones de calidad para garantizar 
    la coherencia, la precisión y la estandarización de los datos en la capa
    "silver". Incluye comprobaciones de:
    - Claves primarias nulas o duplicadas.
    - Espacios no deseados en campos de cadena.
    - Estandarización y coherencia de los datos.
    - Rangos de fechas no válidos.
    - Coherencia de los datos entre campos relacionados.

Notas de Uso:
    - Ejecuta estas comprobaciones despues de cargar los datos a la capa 'silver.
    - Investigar y resolver cualquier discrepancia que se encuentre durante las verificaciones.
===============================================================================================
*/

--======================================================================================================
--================================== COLUMNA 1 expediente ==============================================
--======================================================================================================

-- Primero verificamos la duplicidad de la clave principal
-- debido al orden de procedencia de SQL 
-- (FROM/JOIN -> WHERE -> GROUP BY -> HAVING -> SELECT -> ORDER BY)

SELECT
    expediente,
    COUNT(*)
FROM bronze.quejas_telecom
GROUP BY expediente
HAVING COUNT(*) > 1

SELECT
    *
FROM bronze.quejas_telecom
WHERE expediente IN ('"PFC.YUC.B.3/001619-2024', '"PFC.YUC.B.3/001976-2024')

/*
    Existen dos entradas repetidas. Examinando las entradas, 
    parecen ser quejas que se turnaron a la compañia del bien original.
    Por ser pequeño el numero de duplicidad, nos quedamos con las entradas
    de la cmpañia a a que se le hizo la reclamacion en primera instancia.

    Por otro lado, es posible ver que todas las entradas comienzan con el caracter '"'
    el cual de igual manera se eliminara.
*/

--======================================================================================================
--================================== COLUMNA 2 fecha_ingreso ===========================================
--======================================================================================================

-- Verificar la integridad de la fecha_ingreso

SELECT
    TRIM('"' FROM expediente) AS expediente,
    fecha_ingreso,
    fecha_cierre,
    tipo_conciliacion,
    estado_procesal,
    proveedor,
    nombre_comercial,
    giro,
    sector,
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
    modalidad_pago,
    problema_especial
FROM bronze.quejas_telecom
WHERE expediente COLLATE Modern_Spanish_CS_AS NOT IN ('"PFC.yUC.B.3/001619-2024', '"PFC.yUC.B.3/001976-2024')
    AND fecha_ingreso NOT LIKE '____/__/__'

/*
    Todas las entradas tienen el patron correcto del formato US para fechas,
    ademas es necesario cambiar al formato ISO.
*/

--======================================================================================================
--================================== COLUMNA 3 fecha_cierre ============================================
--======================================================================================================

-- Verificar la integridad de la fecha_cierre

SELECT
    TRIM('"' FROM expediente) AS expediente,
    CONVERT(DATE, fecha_ingreso, 120) AS fecha_ingreso,
    fecha_cierre,
    tipo_conciliacion,
    estado_procesal,
    proveedor,
    nombre_comercial,
    giro,
    sector,
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
    modalidad_pago,
    problema_especial
FROM bronze.quejas_telecom
WHERE expediente COLLATE Modern_Spanish_CS_AS NOT IN ('"PFC.yUC.B.3/001619-2024', '"PFC.yUC.B.3/001976-2024')
    AND fecha_cierre IS NULL
    AND proveedor = '-'


/*
    Existen 32582 entradas con el patron especifico '____/__/__' y 68 entradas nulas.
    Es necesario cambiar al formato ISO.
*/

--======================================================================================================
--================================== COLUMNA 4 tipo_conciliacion =======================================
--======================================================================================================

-- Verificar la integridad de tipo_conciliacion

SELECT DISTINCT
    tipo_conciliacion
FROM bronze.quejas_telecom

/*
    Existen 5 categorias: Conciliada, No Conciliada, Cancelada, Desistimiento, Improcedente
*/


/*
    Existen 1487 entradas en la categoria 'En Proceso': De las cuales, es posible que 1478 de ellas no esten actualizadas
    ya que ya tiene fecha de cierre, y 9 no tienen fecha de cierre: de las cuales 5 son 'Canceladas' y 4 son 'No Conciliadas'.
    El grupo de 1478 y el de 4 se asignaran al valor estandar 'n/a' y el grupo de 5 se le asignara la categoría 'Cancelada'.
*/


--======================================================================================================
--================================== COLUMNA 5 estado_procesal =========================================
--======================================================================================================

-- Verificar dimension

SELECT DISTINCT
    estado_procesal
FROM bronze.quejas_telecom

/*
    Hay una categoria que pertenece a la columna anterior 'Turnada a Concil Person P/seg
*/

SELECT
    *
FROM (
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
        estado_procesal,
        proveedor,
        nombre_comercial,
        giro,
        sector,
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
        modalidad_pago,
        problema_especial
FROM bronze.quejas_telecom
WHERE expediente COLLATE Modern_Spanish_CS_AS NOT IN ('"PFC.yUC.B.3/001619-2024', '"PFC.yUC.B.3/001976-2024')
    )t
WHERE estado_procesal = 'Turnada a Concil Person P/seg'

/*
    Solo hay una entrada 'PFC.ODF.B.3/003003-2025', la cual es una mala captura.
    Entrada a la cual le sera asigna el valor estandar 'n/a'.

*/

--======================================================================================================
--================================== COLUMNA 6 proveedor ===============================================
--======================================================================================================

-- Verificar consitencia en los nombres

SELECT DISTINCT
    proveedor
FROM bronze.quejas_telecom
WHERE proveedor != TRIM(proveedor)

/*
    Todo en orden
*/

-- Verificar dimension

SELECT DISTINCT
    proveedor
FROM bronze.quejas_telecom
ORDER BY proveedor ASC

/*
    Existen 474 categorias en esta columna. Una de ellas es '-', 
    lo cual para fines practicos es basura. Por lo tanto se eliminaran

*/

-- Verificar la consistencia de las entradas (nombres) es inviable debido a la alta dimensionalidad.


--======================================================================================================
--================================== COLUMNA 7 nombre_comercial ========================================
--======================================================================================================

-- Verificar la dimension

SELECT DISTINCT
    nombre_comercial
FROM (
    SELECT
    *
FROM (
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
        giro,
        sector,
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
        modalidad_pago,
        problema_especial
    FROM bronze.quejas_telecom
    WHERE expediente COLLATE Modern_Spanish_CS_AS NOT IN ('"PFC.yUC.B.3/001619-2024', '"PFC.yUC.B.3/001976-2024')
    )t
WHERE proveedor != '-'
    )t
ORDER BY nombre_comercial ASC

/*
    No hay una relación 1-1 entre el proveedor y el nombre_comercial. 
    474 entradas de la primera contra 191 entradas de la segunda. 
    Se asumirá que para un mismo nombre_comercial hay varios proveedores diferentes (subsidiarias).
    En todo caso, el analisis se hará en base al nombre_comercial.
*/

-- Verificar la consistencia en las entradas (nombres)

SELECT DISTINCT
    nombre_comercial
FROM bronze.quejas_telecom
WHERE nombre_comercial != TRIM(nombre_comercial)

/*
    Todo en orden
*/


--======================================================================================================
--================================== COLUMNA 8 giro ====================================================
--======================================================================================================

-- Verificar la dimension

SELECT DISTINCT
    giro
FROM (
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
    giro COLLATE Modern_Spanish_CI_AI AS giro,
    sector,
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
    modalidad_pago,
    problema_especial
FROM bronze.quejas_telecom
WHERE expediente COLLATE Modern_Spanish_CS_AS NOT IN ('"PFC.yUC.B.3/001619-2024', '"PFC.yUC.B.3/001976-2024')
    AND proveedor != '-'
    )t

/*
    Originalmente son 26 categorias.
    Case Insensitive y Accent Insensitive son 23.
    Mal escritas:
    1-Empresa de Larga Distancia
    1-Empresa de Telefonía
    2-Empresa de Tv de Paga (de Tv Restringida)
    2-Empresa de Tv de Paga
    2-Televisión por Cable
    3-Distribuidor de Servicio de Telefonía Celular
    3-Empresa de Telefonía Celular
    4-Televisión Satelital
    4-Tv Satelital
    4-Tv Vía Satélite
    
*/


--======================================================================================================
--================================== COLUMNA 9 sector ==================================================
--======================================================================================================

-- Verificar la dimension
SELECT DISTINCT
    sector
FROM (
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
    sector,
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
    modalidad_pago,
    problema_especial
FROM bronze.quejas_telecom
WHERE expediente COLLATE Modern_Spanish_CS_AS NOT IN ('"PFC.yUC.B.3/001619-2024', '"PFC.yUC.B.3/001976-2024')
    AND proveedor != '-'
    )t

/*
    Solo hay una categoría, lo cual no es relevante ni informativo.
    Procedemos a no considerarla
*/

--======================================================================================================
--================================== COLUMNA 10 odeco ==================================================
--======================================================================================================

-- Verificar la dimension

SELECT DISTINCT
    odeco
FROM (
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
    motivo_reclamacion,
    costo_bien_servicio,
    monto_reclamado,
    monto_recuperado,
    procedimiento,
    medio_ingreso,
    clase,
    tipo_producto,
    modalidad_compra,
    modalidad_pago,
    problema_especial
FROM bronze.quejas_telecom
WHERE expediente COLLATE Modern_Spanish_CS_AS NOT IN ('"PFC.yUC.B.3/001619-2024', '"PFC.yUC.B.3/001976-2024')
    AND proveedor != '-'
    )t
ORDER BY odeco ASC

/*
    Todo en orden
*/

--======================================================================================================
--================================== COLUMNA 11 estado =================================================
--======================================================================================================

-- Verificar la dimension

SELECT DISTINCT
    estado
FROM (
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
    motivo_reclamacion,
    costo_bien_servicio,
    monto_reclamado,
    monto_recuperado,
    procedimiento,
    medio_ingreso,
    clase,
    tipo_producto,
    modalidad_compra,
    modalidad_pago,
    problema_especial
FROM bronze.quejas_telecom
WHERE expediente COLLATE Modern_Spanish_CS_AS NOT IN ('"PFC.yUC.B.3/001619-2024', '"PFC.yUC.B.3/001976-2024')
    AND proveedor != '-'
    )t
ORDER BY estado ASC

/* Todo en orden */

--======================================================================================================
--================================== COLUMNA 12 tipo_reclamacion =======================================
--======================================================================================================

-- Verificar la dimension

SELECT DISTINCT
    tipo_reclamacion
FROM (
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
    motivo_reclamacion,
    costo_bien_servicio,
    monto_reclamado,
    monto_recuperado,
    procedimiento,
    medio_ingreso,
    clase,
    tipo_producto,
    modalidad_compra,
    modalidad_pago,
    problema_especial
FROM bronze.quejas_telecom
WHERE expediente COLLATE Modern_Spanish_CS_AS NOT IN ('"PFC.yUC.B.3/001619-2024', '"PFC.yUC.B.3/001976-2024')
    AND proveedor != '-'
    )t
ORDER BY tipo_reclamacion ASC

/*
    Todo en orden.
*/

--======================================================================================================
--================================== COLUMNA 13 motivo_reclamacion =====================================
--======================================================================================================

-- Verificar la dimension

SELECT DISTINCT
    motivo_reclamacion
FROM (
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
    costo_bien_servicio,
    monto_reclamado,
    monto_recuperado,
    procedimiento,
    medio_ingreso,
    clase,
    tipo_producto,
    modalidad_compra,
    modalidad_pago,
    problema_especial
FROM bronze.quejas_telecom
WHERE expediente COLLATE Modern_Spanish_CS_AS NOT IN ('"PFC.yUC.B.3/001619-2024', '"PFC.yUC.B.3/001976-2024')
    AND proveedor != '-'
    )t
ORDER BY motivo_reclamacion ASC

--======================================================================================================
--================================== COLUMNA 14 costo_bien_servicio ====================================
--======================================================================================================

-- Verificar tipos de datos

SELECT
    *
FROM (
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
    costo_bien_servicio,
    monto_reclamado,
    monto_recuperado,
    procedimiento,
    medio_ingreso,
    clase,
    tipo_producto,
    modalidad_compra,
    modalidad_pago,
    problema_especial
FROM bronze.quejas_telecom
WHERE expediente COLLATE Modern_Spanish_CS_AS NOT IN ('"PFC.yUC.B.3/001619-2024', '"PFC.yUC.B.3/001976-2024')
    AND proveedor != '-'
    )t
WHERE costo_bien_servicio IS NULL

/*
    32616 valores numericos
    24 NULLs.
    Procederemos a convertir a FLOAT
*/

-- Consistencia de la columna 

SELECT DISTINCT
    tipo_reclamacion
FROM bronze.quejas_telecom
WHERE costo_bien_servicio = '0'

/*
    Para las entradas donde costo del bien y servicio(cbs) es 0
    y el tipo de reclamacion es 'Entrega del Producto o Servicio'
    es claro que aqui es incorrecto '0' en el cbs.
    a estas entradas se les asignara el valor NULL.
    Para los otros tipos de reclamacion NO ES CLARO que deban tener
    asignado un valor de '0', pero si es claro que necesitan un valor
    estandar y como es una columna numerica se le asignara tambien NULL.
    Tambien convertiremos la columna a typo de dato FLOAT.
*/

--======================================================================================================
--================================== COLUMNA 15 monto_reclamado ========================================
--======================================================================================================

-- Verificar tipos de datos

SELECT
    monto_reclamado
FROM (
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
        monto_reclamado,
        monto_recuperado,
        procedimiento,
        medio_ingreso,
        clase,
        tipo_producto,
        modalidad_compra,
        modalidad_pago,
        problema_especial
    FROM bronze.quejas_telecom
    WHERE expediente COLLATE Modern_Spanish_CS_AS NOT IN ('"PFC.yUC.B.3/001619-2024', '"PFC.yUC.B.3/001976-2024')
        AND proveedor != '-'
    )t
WHERE TRY_CONVERT(FLOAT, monto_reclamado) IS NULL AND monto_reclamado IS NOT NULL


/*
    Existen 28 entradas que causan conflicto:
    5 entradas 'Sin Dato',
    1 entrada 'Oo',
    22 entradas '-'.
*/

--======================================================================================================
--================================== COLUMNA 16 monto_recuperado =======================================
--======================================================================================================

-- Verificar tipos de datos

SELECT
    *
FROM (
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
    monto_recuperado,
    procedimiento,
    medio_ingreso,
    clase,
    tipo_producto,
    modalidad_compra,
    modalidad_pago,
    problema_especial
FROM bronze.quejas_telecom
WHERE expediente COLLATE Modern_Spanish_CS_AS NOT IN ('"PFC.yUC.B.3/001619-2024', '"PFC.yUC.B.3/001976-2024')
AND proveedor != '-'
)t
WHERE TRY_CONVERT(FLOAT, monto_recuperado) IS NULL AND monto_recuperado IS NOT NULL

/*
    No hay problema. Convertimos a Float
*/

--======================================================================================================
--================================== COLUMNA 17 procedimiento ==========================================
--======================================================================================================

-- Verificar consistencia, dimension e integridad

SELECT DISTINCT
    procedimiento
FROM (
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
    procedimiento,
    medio_ingreso,
    clase,
    tipo_producto,
    modalidad_compra,
    modalidad_pago,
    problema_especial
FROM bronze.quejas_telecom
WHERE expediente COLLATE Modern_Spanish_CS_AS NOT IN ('"PFC.yUC.B.3/001619-2024', '"PFC.yUC.B.3/001976-2024')
AND proveedor != '-'
)t

/*
    Existen 11 categorias, entre ellas: 
    Proc. Infracciones a la Ley,
    Sol. de Dictamen,
    Resol al Recurso de Rev. Admin,
    Cumpliment Sentencia o Resoluc,
    Conciliación Medios Electrónic,
    -,
    Queja,
    Conciliación Telefónica,
    Conciliación Medios Electrónicos,
    0,
    Conciliación Personal.

    Las categorías '-' y '0' serean remplazadas por el valor estandar 'n/a'.
    Las restantes, con fines informativos,mostraran las entradas sin abreviaciones.
*/


--======================================================================================================
--================================== COLUMNA 18 medio_ingreso ==========================================
--======================================================================================================

-- Verificar consistencia, dimension e integridad

SELECT
    *
FROM (
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
    medio_ingreso,
    clase,
    tipo_producto,
    modalidad_compra,
    modalidad_pago,
    problema_especial
FROM bronze.quejas_telecom
WHERE expediente COLLATE Modern_Spanish_CS_AS NOT IN ('"PFC.yUC.B.3/001619-2024', '"PFC.yUC.B.3/001976-2024')
AND proveedor != '-'
)t
WHERE medio_ingreso = 'Servicio' OR medio_ingreso = 'Bien'

/*
    Existen 9 categorias:
    Personal,
    Sin dato,
    Teléfono,
    Bien,
    Servicio,
    -,
    Correo Electrónico,
    Internet,
    Escrito.

    1.Las categorias 'Bien' y 'Servicio' estan intercambiadas por la columna 'clase',
    por lo tanto hay que intercambiar los datos de las respectivas columnas.
    2.Por otro lado '-' y 'Sin Dato' se cambiaran por el valor estandar 'n/a'.
*/

--======================================================================================================
--================================== COLUMNA 19 tipo_producto ==========================================
--======================================================================================================

-- Verificar consistencia, dimension e integridad

SELECT DISTINCT
    tipo_producto
FROM bronze.quejas_telecom

/*
    Existen dos categorias sin informacion, '-' y 'Sin dato'
    que seran sustituidas por el valor estandar 'n/a'.
*/


--======================================================================================================
--================================== COLUMNA 20 modalidad_compra =======================================
--======================================================================================================

-- Verificar consistencia, dimension e integridad


SELECT DISTINCT
    modalidad_compra
FROM bronze.quejas_telecom

/*
    Existen dos categorias sin informacion, '-' y 'Sin dato'
    que seran sustituidas por el valor estandar 'n/a'.
*/


--======================================================================================================
--================================== COLUMNA 21 modalidad_pago =========================================
--======================================================================================================

-- Verificar consistencia, dimension e integridad

SELECT DISTINCT
    modalidad_pago
FROM bronze.quejas_telecom

/*
    Existen tres categorias sin informacion, '-', 'Sin dato' y '0'
    que seran sustituidas por el valor estandar 'n/a'.
*/

--======================================================================================================
--================================== COLUMNA 22 problema_espacial ======================================
--======================================================================================================

-- Verificar consistencia, dimension e integridad

SELECT DISTINCT
    problema_especial
FROM bronze.quejas_telecom

/*
    Esta columna sirve como anotaciones particulares de cada queja, en general.
    Lo cual para un analisis no me parece que la información pueda ser utilizada con fines
    de analisis. Se procedera a eliminar esta columna
*/



