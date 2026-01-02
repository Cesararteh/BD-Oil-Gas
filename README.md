# 🛢️📊 Sistema OLTP para Datos SCADA en Oil & Gas

## 🧠 Descripción del Proyecto
Este proyecto consiste en el **diseño e implementación de una base de datos transaccional (OLTP)** para almacenar, gestionar y consultar datos generados por un sistema **SCADA** en una planta industrial del sector **Oil & Gas**.

El objetivo principal es **estructurar la data cruda de sensores industriales** (presión, temperatura, caudal, etc.) de forma robusta y escalable, sentando las bases para futuros análisis de **Business Intelligence (BI)**, **mantenimiento predictivo** y **modelos de Data Science**.

---

## 🎯 Objetivos
- Diseñar un **modelo de base de datos OLTP** alineado a un entorno industrial real
- Modelar correctamente la estructura física y funcional de la planta
- Almacenar lecturas históricas de variables de proceso
- Facilitar análisis posteriores mediante SQL, Python y Power BI
- Integrar conceptos de **Ingeniería Química, Instrumentación y Data Analytics**

---

## 🏭 Contexto Industrial
En una planta Oil & Gas:
- El sistema **SCADA** captura datos en tiempo real
- Las **bases de datos OLTP** almacenan esa información de forma estructurada
- Los datos luego pueden ser explotados para:
  - Análisis histórico
  - Monitoreo operativo
  - Mantenimiento predictivo
  - Visualización en dashboards

Este proyecto cubre **la primera capa crítica: la base de datos OLTP**.

---

## 🗂️ Modelo de Datos

### 🔹 Entidades principales
- **Unidades**: Grandes áreas de proceso (ej. Craqueo Catalítico)
- **Segmentos**: Tramos del proceso o piping dentro de una unidad
- **Loops**: Conjuntos funcionales de control (sensores + controladores)
- **Instrumentos (Tags)**: Sensores y actuadores industriales
- **Lecturas SCADA**: Datos históricos de variables de proceso
- **Eventos**: Alarmas, cambios de estado, fallas
- **Variables de Proceso**: Presión, temperatura, flujo, nivel, etc.

📌 El diseño permite filtrar información por:
- Unidad (Ingeniería de procesos)
- Segmento (Mantenimiento)
- Loop (Instrumentación y control)

---

## 🧱 Modelos Entregables
✔ **Modelo Conceptual**  
✔ **Modelo Lógico** (atributos, PK, FK, tipos de datos)  
✔ **Modelo Físico** implementado en SQL Server  

---

## 🛠️ Tecnologías Utilizadas
- 🐍 **Python**
  - Simulación de datos SCADA
  - Generación de datasets sintéticos
- 🗄️ **SQL Server**
  - Implementación del modelo físico
  - Creación de tablas, claves e índices
- 📊 **Power BI** *(etapa futura)*
  - Visualización y análisis
- 📐 **Modelado de datos**
  - Normalización
  - Claves primarias y foráneas
  - Índices para optimización

---

## 📈 Flujo de Datos del Proyecto
```text
SCADA (simulado con Python)
        ↓
Base de Datos OLTP (SQL Server)
        ↓
Consultas SQL optimizadas
        ↓
BI / Analytics / Data Science

