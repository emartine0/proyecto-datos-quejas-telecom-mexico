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

## 📂 Estructura
```
SQL/
│
├── datos/                              # Conjunto de datos sin procesar  para el proyecto
│
├── docs/                               # Documentacion y detalles del proyecto
│   ├── data_catalog.md                 # Catalogo del conjunto de datos, incluyendo descripciones de los campos y metadatos
│   └── naming-conventions.md           # Directrices consistentes para nombrar archivos, tablas y columnas
│
├── scripts/                            # SQL scripts para ETL y transformaciones
│   ├── bronze/                         # Scripts para cargar y extraer los datos sin procesar
│   ├── silver/                         # Scripts para limpiar y transformar los datos
│   └── gold/                           # Scripts para crear modelos analiticos
│
├── pruebas/                            # Scripts para pruebas and calidad de los datos
|                          
└── README.md                           # Descripción general
```
