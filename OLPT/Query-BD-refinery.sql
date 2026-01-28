CREATE DATABASE SCADA_OLTP;
GO

USE SCADA_OLTP;
GO

CREATE TABLE Unidad_proceso (
    id_unidad INT IDENTITY(1,1) PRIMARY KEY,
    simbolo VARCHAR(10) NOT NULL,
    nombre_unidad VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255)
);

CREATE TABLE Tipos_instrumento (
    id_tipo_inst INT IDENTITY(1,1) PRIMARY KEY,
    codigo_tipo VARCHAR(10) NOT NULL,
    nombre_tipo VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255)
);

CREATE TABLE Variables_proceso (
    id_variable_p INT IDENTITY(1,1) PRIMARY KEY,
    nombre_variable VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255)
);

CREATE TABLE Estado_instrumento (
    id_estado_inst INT IDENTITY(1,1) PRIMARY KEY,
    codigo_tipo VARCHAR(20) NOT NULL,
    nombre_tipo VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255)
);

CREATE TABLE Segmentos_planta (
    id_segmento INT IDENTITY(1,1) PRIMARY KEY,
    codigo_segmento VARCHAR(20) NOT NULL,
    nombre_segmento VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255),
    id_unidad INT NOT NULL,

    CONSTRAINT FK_Segmento_Unidad
        FOREIGN KEY (id_unidad) REFERENCES Unidad_proceso(id_unidad)
);


CREATE TABLE Loops_control (
    id_loop INT IDENTITY(1,1) PRIMARY KEY,
    codigo_loop VARCHAR(20) NOT NULL,
    descripcion VARCHAR(255),
    id_unidad INT NOT NULL,
    id_segmento INT NOT NULL,

    CONSTRAINT FK_Loop_Unidad
        FOREIGN KEY (id_unidad) REFERENCES Unidad_proceso(id_unidad),

    CONSTRAINT FK_Loop_Segmento
        FOREIGN KEY (id_segmento) REFERENCES Segmentos_planta(id_segmento)
);

CREATE TABLE Instrumento_tag (
    id_tag INT IDENTITY(1,1) PRIMARY KEY,
    tag VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255),

    valor_min DECIMAL(10,2),
    valor_max DECIMAL(10,2),
    fecha_install DATETIME NOT NULL,

    id_tipo_inst INT NOT NULL,
    id_variable_p INT NOT NULL,
    id_segmento INT NOT NULL,
    id_loop INT NULL,
    id_estado_inst INT NOT NULL,

    CONSTRAINT FK_Tag_TipoInstrumento
        FOREIGN KEY (id_tipo_inst) REFERENCES Tipos_instrumento(id_tipo_inst),

    CONSTRAINT FK_Tag_VariableProceso
        FOREIGN KEY (id_variable_p) REFERENCES Variables_proceso(id_variable_p),

    CONSTRAINT FK_Tag_Segmento
        FOREIGN KEY (id_segmento) REFERENCES Segmentos_planta(id_segmento),

    CONSTRAINT FK_Tag_Loop
        FOREIGN KEY (id_loop) REFERENCES Loops_control(id_loop),

    CONSTRAINT FK_Tag_Estado
        FOREIGN KEY (id_estado_inst) REFERENCES Estado_instrumento(id_estado_inst)
);

CREATE TABLE Lecturas_scada (
    id_lectura BIGINT IDENTITY(1,1) PRIMARY KEY,
    id_tag INT NOT NULL,
    valor_lectura DECIMAL(12,4) NOT NULL,
    fecha_hora_lectura DATETIME2 NOT NULL,
    calidad_dato VARCHAR(20),

    CONSTRAINT FK_Lectura_Tag
        FOREIGN KEY (id_tag) REFERENCES Instrumento_tag(id_tag)
);

CREATE TABLE Eventos_scada (
    id_evento_scd BIGINT IDENTITY(1,1) PRIMARY KEY,
    id_tag INT NOT NULL,
    id_estado_inst INT NOT NULL,
    tipo_evento VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255),
    severidad INT NOT NULL,
    fecha_hora_evento DATETIME2 NOT NULL,

    CONSTRAINT FK_Evento_Tag
        FOREIGN KEY (id_tag) REFERENCES Instrumento_tag(id_tag),

    CONSTRAINT FK_Evento_Estado
        FOREIGN KEY (id_estado_inst) REFERENCES Estado_instrumento(id_estado_inst)
);

-- Time-series SCADA
CREATE INDEX IX_Lecturas_Tag_Fecha
ON Lecturas_scada (id_tag, fecha_hora_lectura);

-- Eventos SCADA
CREATE INDEX IX_Eventos_Tag_Fecha
ON Eventos_scada (id_tag, fecha_hora_evento);

-- Búsquedas operativas
CREATE INDEX IX_Tag_Segmento
ON Instrumento_tag (id_segmento);

CREATE INDEX IX_Tag_Loop
ON Instrumento_tag (id_loop);


CREATE TABLE conexion_segmento_unidad (
    id_conexion INT IDENTITY(1,1) PRIMARY KEY,

    id_segmento INT NOT NULL,
    id_unidad INT NOT NULL,

    tipo_conexion VARCHAR(20) NOT NULL,  -- entrada | salida | bypass | recirculacion

    descripcion VARCHAR(255) NULL,

    CONSTRAINT FK_conexion_segmento
        FOREIGN KEY (id_segmento)
        REFERENCES Segmentos_planta(id_segmento),

    CONSTRAINT FK_conexion_unidad
        FOREIGN KEY (id_unidad)
        REFERENCES Unidad_proceso(id_unidad)
);






-- Script de datos
-- Tabla Unidad_proceso: Solo 3 unidades principales como ejemplo primero.
INSERT INTO Unidad_proceso (simbolo, nombre_unidad, descripcion)
VALUES
('FCC', 'Craqueo Catalítico Fluidizado', 'Unidad principal de conversión'),
('DST', 'Destilación Atmosférica', 'Separación primaria del crudo'),
('HTR', 'Horno de Proceso', 'Calentamiento de corrientes');

select * from Unidad_proceso;

-- Tabla Variables_proceso: Unidades de medida vistas dentro de una refinería 
INSERT INTO Variables_proceso (nombre_variable, descripcion)
VALUES
('Presión', 'Presión del proceso'),
('Temperatura', 'Temperatura del proceso'),
('Flujo', 'Caudal del fluido'),
('Nivel', 'Nivel del fluido');

select * from Variables_proceso;


-- Tablas Tipos_instrumento: Tipos de instrumentos según un P&ID
INSERT INTO Tipos_instrumento (codigo_tipo, nombre_tipo, descripcion)
VALUES
('PT', 'Transmisor de Presión', 'Mide presión'),
('TT', 'Transmisor de Temperatura', 'Mide temperatura'),
('FT', 'Transmisor de Flujo', 'Mide caudal'),
('LT', 'Transmisor de Nivel', 'Mide nivel');

select * from Tipos_instrumento;

-- Tabla Estado_instrumento: Cómo se encuentran los instrumentos según el SCADA
INSERT INTO Estado_instrumento (codigo_tipo, nombre_tipo, descripcion)
VALUES
('OK', 'Operativo', 'Instrumento funcionando correctamente'),
('WARN', 'Advertencia', 'Condición anómala'),
('FAIL', 'Falla', 'Instrumento fuera de servicio');

select * from Estado_instrumento;

-- Segmentos_planta: Un ejemplo de como se conectarían los segmentos y qué describen
INSERT INTO Segmentos_planta (codigo_segmento, nombre_segmento, descripcion)
VALUES
('SEG-101', 'Línea alimentación FCC', 'Tubería principal hacia FCC'),
('SEG-102', 'Salida reactor FCC', 'Corriente caliente de salida'),
('SEG-201', 'Línea destilación', 'Entrada a torre');

-- Tabla conexion_segmento_unidad: Tabla intermedia para una correcta conexión entre Segmentos_planta y Unidad_proceso
INSERT INTO conexion_segmento_unidad (id_segmento, id_unidad, tipo_conexion, descripcion)
VALUES
(1, 1, 'ENTRADA', 'Alimenta al reactor FCC'),
(2, 1, 'SALIDA', 'Salida del reactor FCC'),
(3, 2, 'ENTRADA', 'Alimenta torre de destilación');

-- Tabla Loops_control : Los loops de control de proceso que contienen los intrumentos.
INSERT INTO Loops_control (codigo_loop, descripcion)
VALUES
('LIC-101', 'Control de nivel reactor'),
('PIC-201', 'Control de presión salida FCC'),
('TIC-301', 'Control de temperatura horno');

ALTER TABLE Segmentos_planta
DROP CONSTRAINT FK_unidad;
ALTER TABLE Loops_control
DROP CONSTRAINT FK_Loop_Segmento;
ALTER TABLE Segmentos_planta DROP COLUMN id_unidad;
ALTER TABLE Loops_control DROP COLUMN id_segmento;

select * from Loops_control;

-- Tabla Loops_control: Lazos de control dentro de la refinería
INSERT INTO Loops_control (codigo_loop, descripcion)
VALUES
('LIC-101', 'Control de nivel reactor'),
('PIC-201', 'Control de presión salida FCC'),
('TIC-301', 'Control de temperatura horno');

-- Tabla Instrumento_tag: Los intrumentos de medición de la refinería
INSERT INTO Instrumento_tag (
    tag,
    descripcion,
    valor_min,
    valor_max,
    fecha_install,
    id_tipo_inst,
    id_variable_p,
    id_segmento,
    id_loop,
    id_estado_inst
)
VALUES (
    'PT-201',
    'Transmisor de presión en línea principal',
    0,
    300,
    '2022-05-10',
    3,   -- Tipo instrumento (Transmisor)
    1,   -- Variable proceso (Presión)
    3,   -- Segmento
    1,   -- Loop
    1    -- Estado: Activo
);

--Tabla Lecturas_scada: Tabla de hechos de la refinería
;WITH Nums AS (
    SELECT TOP (100)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects
)
INSERT INTO Lecturas_scada (
    id_tag,
    valor_lectura,
    fecha_hora_lectura,
    calidad_dato
)
SELECT
    it.id_tag,
    CASE
        WHEN it.id_variable_p = 1 THEN 20  + RAND(CHECKSUM(NEWID())) * 5     -- Presión
        WHEN it.id_variable_p = 2 THEN 450 + RAND(CHECKSUM(NEWID())) * 50    -- Temperatura
        WHEN it.id_variable_p = 3 THEN 200 + RAND(CHECKSUM(NEWID())) * 30    -- Flujo
        ELSE 0
    END AS valor_lectura,
    DATEADD(
        MINUTE,
        -ABS(CHECKSUM(NEWID())) % 10080,   -- hasta 7 días atrás
        GETDATE()
    ) AS fecha_hora_lectura,
    CASE
        WHEN RAND(CHECKSUM(NEWID())) < 0.9 THEN 'GOOD'
        WHEN RAND(CHECKSUM(NEWID())) < 0.97 THEN 'UNCERTAIN'
        ELSE 'BAD'
    END AS calidad_dato
FROM Instrumento_tag it
CROSS JOIN Nums;


-- Tabla Eventos_scada: tabla que indica las fallas de la planta en los insturmentos.x
;WITH Nums AS (
    SELECT TOP (100)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects
)
INSERT INTO Eventos_scada (
    id_tag,
    id_estado_inst,
    tipo_evento,
    descripcion,
    severidad,
    fecha_hora_evento
)
SELECT
    it.id_tag,

    -- Estado del instrumento al momento del evento
    CASE
        WHEN RAND(CHECKSUM(NEWID())) < 0.7 THEN 1  -- Operativo
        WHEN RAND(CHECKSUM(NEWID())) < 0.9 THEN 2  -- Alarma
        ELSE 3                                     -- Fallo
    END AS id_estado_inst,

    -- Tipo de evento
    CASE
        WHEN RAND(CHECKSUM(NEWID())) < 0.6 THEN 'ALARM'
        WHEN RAND(CHECKSUM(NEWID())) < 0.85 THEN 'WARNING'
        ELSE 'FAILURE'
    END AS tipo_evento,

    -- Descripción acorde al evento
    CASE
        WHEN it.id_variable_p = 1 THEN 'Presión fuera de rango'
        WHEN it.id_variable_p = 2 THEN 'Temperatura elevada'
        WHEN it.id_variable_p = 3 THEN 'Flujo inestable'
        ELSE 'Evento de proceso'
    END AS descripcion,

    -- Severidad (1=baja, 3=alta)
    CASE
        WHEN RAND(CHECKSUM(NEWID())) < 0.5 THEN 1
        WHEN RAND(CHECKSUM(NEWID())) < 0.85 THEN 2
        ELSE 3
    END AS severidad,

    -- Evento en los últimos 30 días
    DATEADD(
        MINUTE,
        -ABS(CHECKSUM(NEWID())) % 43200,
        GETDATE()
    ) AS fecha_hora_evento

FROM Instrumento_tag it
CROSS JOIN Nums;



use SCADA_OLTP;
select * from Instrumento_tag;