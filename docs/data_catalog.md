# Catálogo de Datos para la Capa 'gold'

## Descripción General
La capa 'gold' es la representacíon de los datos para el analisis nivel superior, organizada para admitir casos de uso analíticos y de generación de informes. 
Consta de de una sola tabla para metricas específicas.

---

### **gold.quejas_telecom**
- **Propósito:** Almacena información detallada de los reportes, enriquecida con datos de proveedores, productos y oficina de atención.
- **Columnas:**

| Nombre de la Columna  | Tipo de Dato  | Descripción                                                                                                             |
|-----------------------|---------------|-------------------------------------------------------------------------------------------------------------------------|
| expediente            | NVARCHAR(85)  | Identificador único asignado al caso registrado.                                                                        |
|	medio_ingreso         | NVARCHAR(85)  | Medio de ingreso de la queja (Correo Electrónico, Escrito, Personal, Teléfono, Internet).                               |
|	estado_procesal       | NVARCHAR(85)  | Situación procesal del expediente (Conciliada, No conciliada, Desistimiento, Improcedente, Cancelada).                  |
|	tipo_reclamacion      | NVARCHAR(85)  | Tipo general de afectación reportada por la persona consumidora (Portabilidad, Contratos, Garantías, etc).              |
|	motivo_reclamacion    | NVARCHAR(85)  | Descripción principal y específica del motivo de la reclamación.                                                        |
|	fecha_ingreso         | NVARCHAR(85)  | Fecha en que el expediente fue registrado. Con formato YYYY-MM-DD (2022-05-04)                                          |
|	fecha_cierre          | NVARCHAR(85)  | Fecha de conclusión administrativa del expediente. Puede ser nula si sigue abierto. Con formato YYYY-MM-DD (2022-05-04) |
|	tipo_conciliacion     | NVARCHAR(85)  | Mecanismo de atención aplicado (Telefónica, Personal P/seg, Medios Electronícos).                                       |
|	procedimiento         | NVARCHAR(85)  | Indica el canal o mecanismo a través del cual se llevó a cabo la conciliación de la queja. (medios electrónicos, atención personal en oficina, vía telefónica o queja tradicional). |
|	monto_reclamado       | NVARCHAR(85)  | Indica el valor monetario total que la persona consumidora reclama o solicita recuperar en el expediente, expresado en moneda nacional (pesos mexicanos, MXN). |
|	monto_recuperado      | NVARCHAR(85)  | Indica el importe total que la persona consumidora recuperó a su favor como resultado del proceso conciliatorio o de la gestión de PROFECO, expresado en moneda nacional (pesos mexicanos, MXN). |
|	proveedor             | NVARCHAR(85)  | Denominación o razón social del proveedor.                                                                              |
|	nombre_comercial      | NVARCHAR(85)  | Nombre comercial con el que el proveedor se identifica ante el público.                                                 |
|	giro                  | NVARCHAR(85)  | Describe la actividad económica específica o principal del proveedor involucrado en la queja o expediente.              |
|	tipo_producto         | NVARCHAR(85)  | Identifica la naturaleza o condición del bien o servicio objeto de la queja: producto físico (nuevo, usado o reconstruido); o de un servicio (normal o adicional/conexo al bien adquirido). |
|	clase                 | NVARCHAR(85)  | Indica si el expediente corresponde a la adquisición o contratación de un bien tangible o de un servicio.               |
|	modalidad_compra      | NVARCHAR(85)  | Indica el medio o canal a través del cual la persona consumidora realizó la adquisición del bien o contratación del servicio (Por internet, Por teléfono, Por correo, etc). |
|	modalidad_pago        | NVARCHAR(85)  | Indica la forma o esquema financiero mediante el cual la persona consumidora efectuó el pago o adquirió el compromiso de pago del bien o servicio (Plazos, Apartado, Contado, etc). |
|	costo_bien_servicio   | NVARCHAR(85)  | Indica el importe total del bien o servicio adquirido que dio origen a la queja o expediente, expresado en moneda nacional (pesos mexicanos, MXN).  |
|	odeco                 | NVARCHAR(85)  | Oficina de Defensa del Consumidor que atendió la queja.                                                                 |
|	estado                | NVARCHAR(85)  | Entidad federativa en la que se atendió la queja o se realizó el procedimiento conciliatorio. En los casos en que la atención se lleve a cabo mediante oficinas centrales o a través de medios remotos (por internet, telefónicos o electrónicos), se deberá registrar la Dirección General responsable de la atención. |
|	md_fecha_creacion     | DATETIME2     | Fecha y tiempo en que el registro del expediente fue creado en el sistema.                                              |
---
