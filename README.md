# Proyecto de Datos sobre Quejas en Telecomunicaciones

Este proyecto combina el análisis exploratorio, el análisis avanzado y la visualización de datos, mostrando un flujo de trabajo completo sobre un conjunto de datos reales sobre quejas en el area de telecomunicaciones.

> ⚠️ **Aviso:** 
> Este proyecto fue desarrollado con fines educativos y de aprendizaje y se encuentra actualmente en fase de revisión y optimización. Tenga en cuenta que el código SQL y la estructura en Tableau contienen oportunidades de mejora.

## 🏗️ Arquitectura de Datos

La arquitectura de datos para este proyecto sigue la Arquitectura Medallion con las capas **Bronze**, **Silver**, y **Gold**.

1. **Bronze Layer**: Almacena los datos sin procesar tal cual provienen de los sistemas de origen. Los datos se importan desde archivos CSV a una base de datos de SQL Server.
2. **Silver Layer**: Esta capa incluye procesos de limpieza, estandarización y normalización de datos para prepararlos para el análisis.
3. **Gold Layer**: Almacena datos listos para su uso empresarial, modelados en un esquema de estrella, necesarios para la elaboración de informes y análisis.

---

## 📋 SQL (Preparación de los Datos)
- **Fuente de los Datos**: Los datos son importados desde un archivo CVS
- **Calidad de los Datos**: Limpiar y preparar los datos antes del análisis.
- **Documentación**: Proveer documentación clara del modelo para los usuarios.

## 📊 SQL (Análisis de Datos)
- **Análisis exploratorio (EDA)**
- **Análisis de Datos Avanzado (ADA)**

## 📈 Tableau (Visualizacion)
- **Dashboard interactivo**
- **Análisis temporal de las quejas**
- **Ranking de proveedores**
- **Principales motivos de reclamación**

## 📂 Estructura del Repositorio
```
proyecto-datos-quejas-telecom-mexico/
|
├── SQL/
|   │
|   ├── datos/                              # Conjunto de datos sin procesar  para el proyecto
|   │
|   ├── docs/                               # Documentacion y detalles del proyecto
|   │   ├── data_catalog.md                 # Catalogo del conjunto de datos, incluyendo descripciones de los campos y metadatos
|   │   └── naming-conventions.md           # Directrices consistentes para nombrar archivos, tablas y columnas
|   │
|   ├── scripts/                            # SQL scripts para ETL y transformaciones
|   │   ├── bronze/                         # Scripts para cargar y extraer los datos sin procesar
|   │   ├── silver/                         # Scripts para limpiar y transformar los datos
|   │   └── gold/                           # Scripts para crear modelos analiticos
|   │
|   └── pruebas/                            # Scripts para pruebas and calidad de los datos
|
├── Tableau/
|   ├── tablero_quejas_telecom.jpg          # Screenshot del tablero
|   ├── tablero_quejas_telecom.twbx         # El archivo del workbook de Tableau
|   ├── quejas_telecom.csv                  # El conjunto de datos utilizado para la visualización
|   ├── historia_usuario.md                 # Requerimientos del usuario final
|   └── README.md                           # Descripción general del proyecto y enlace al tablero
|
│   
├── README.md                               # Descripción general del proyecto e instrucciones
└── LICENSE                                 # Información de la licencia del repositorio
```
---


## 🛡️ Licencia

Este proyecto esta bajo la licencia [MIT License](LICENSE). Puedes usar, modificar y compartir este proyecto con el debido reconocimiento del autor.
Hi there! I'm **Edgar Martinez**
