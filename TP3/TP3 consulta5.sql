USE db1_tp3;

CREATE TABLE datos_juegos(
anio_olimpiada INT NOT NULL UNIQUE,
pais_olimpiada VARCHAR(56) NOT NULL,
PRIMARY KEY (anio_olimpiada)
);

CREATE TABLE deportistas(
nombre_deportista VARCHAR(50) NOT NULL,
anio_olimpiada INT NOT NULL,
PRIMARY KEY (nombre_deportista)
);

CREATE TABLE participacion_juegos(
anio_olimpiada INT NOT NULL,
nombre_deportista VARCHAR(50) NOT NULL,
nombre_disciplina VARCHAR(50) NOT NULL,
asistente VARCHAR(50) NOT NULL,
PRIMARY KEY (anio_olimpiada, nombre_deportista),
FOREIGN KEY (nombre_deportista) REFERENCES deportistas(nombre_deportista)
);

CREATE TABLE paises(
nombre_deportista VARCHAR(50) PRIMARY KEY,
nombre_pais VARCHAR(56) NOT NULL,
FOREIGN KEY (nombre_deportista) REFERENCES deportistas(nombre_deportista)
);