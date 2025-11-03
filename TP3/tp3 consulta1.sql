CREATE DATABASE db1_tp3;
USE db1_tp3;

CREATE TABLE estadia(
habitacion VARCHAR(50) NOT NULL,
fecha_inicio_hospedaje DATE NOT NULL,
cant_dias_hospedaje INT NOT NULL,
cod_hotel INT NOT NULL,
dni_cliente INT NOT NULL,
PRIMARY KEY (cod_hotel, dni_cliente, habitacion),
FOREIGN KEY (cod_hotel) REFERENCES hotel(cod_hotel),
FOREIGN KEY (dni_cliente) REFERENCES cliente(dni_cliente)
);

CREATE TABLE hotel(
cod_hotel INT PRIMARY KEY NOT NULL,
cantidad_habitaciones INT NOT NULL,
direccion_hotel VARCHAR(50) NOT NULL,
ciudad_hotel VARCHAR(50) NOT NULL,
dni_gerente INT UNIQUE NOT NULL,
FOREIGN KEY (dni_gerente) REFERENCES gerente(dni_gerente)
);

CREATE TABLE gerente(
dni_gerente INT PRIMARY KEY,
nombre_gerente VARCHAR(50) NOT NULL
);

CREATE TABLE cliente(
dni_cliente INT PRIMARY KEY,
nombre_cliente VARCHAR(50) NOT NULL,
ciudad_cliente VARCHAR(50) NOT NULL
);