USE db1_tp3;

CREATE TABLE programa(
programa VARCHAR(50) NOT NULL,
conductor VARCHAR(50) NOT NULL,
frecuencia_radio VARCHAR(10) NOT NULL,
anio INT NOT NULL,
radio VARCHAR(50) NOT NULL,
FOREIGN KEY (frecuencia_radio, anio, radio) REFERENCES radio(frecuencia_radio, anio, radio)
);

CREATE TABLE radio(
radio VARCHAR(50) NOT NULL,
frecuencia_radio VARCHAR(10) NOT NULL,
anio INT NOT NULL,
gerente VARCHAR(50) NOT NULL,
PRIMARY KEY (frecuencia_radio, anio)
);