## 📋 📊 SQL (Preparación y Análisis de los Datos)
- **Fuente de los Datos**: Los datos son importados desde un archivo CVS
- **Calidad de los Datos**: Limpiar y preparar los datos antes del análisis.
- **Documentación**: Proveer documentación clara del modelo para los usuarios.
- **Análisis exploratorio (EDA)**
- **Análisis de Datos Avanzado (ADA)**

### 🏗️ Arquitectura de Datos

La arquitectura de datos para este proyecto sigue la Arquitectura Medallion con las capas **Bronze**, **Silver**, y **Gold**.

1. **Bronze Layer**: Almacena los datos sin procesar tal cual provienen de los sistemas de origen. Los datos se importan desde archivos CSV a una base de datos de SQL Server.
2. **Silver Layer**: Esta capa incluye procesos de limpieza, estandarización y normalización de datos para prepararlos para el análisis.
3. **Gold Layer**: Almacena datos listos para su uso empresarial, modelados en un esquema de estrella, necesarios para la elaboración de informes y análisis.
