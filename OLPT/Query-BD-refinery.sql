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

