DROP DATABASE IF EXISTS banco_db1_tp4;
CREATE DATABASE banco_db1_tp4;
USE banco_db1_tp4;

-- 1. Crear tablas
CREATE TABLE clientes(
numero_cliente INT PRIMARY KEY,
dni INT NOT NULL,
apellido VARCHAR(60) NOT NULL,
nombre VARCHAR(60) NOT NULL
);

CREATE TABLE cuentas(
numero_cuenta INT PRIMARY KEY,
numero_cliente INT NOT NULL,
saldo DECIMAL(10, 2),
FOREIGN KEY (numero_cliente) REFERENCES clientes(numero_cliente)
);

CREATE TABLE movimientos(
numero_movimiento INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
numero_cuenta INT NOT NULL,
fecha DATE NOT NULL,
tipo VARCHAR(10) NOT NULL CHECK (UPPER(tipo) IN ('CREDITO','DEBITO')), -- Se usa un check para no ser key sensitive y validar las palabras y no el case de la letra
importe DECIMAL(10, 2) NOT NULL,
FOREIGN KEY (numero_cuenta) REFERENCES cuentas(numero_cuenta)
);

CREATE TABLE historial_movimientos(
id INT AUTO_INCREMENT PRIMARY KEY,
numero_cuenta INT NOT NULL,
numero_movimiento INT NOT NULL,
saldo_anterior DECIMAL(10, 2),
saldo_actual DECIMAL(10, 2),
FOREIGN KEY (numero_cuenta) REFERENCES cuentas(numero_cuenta),
FOREIGN KEY (numero_movimiento) REFERENCES movimientos(numero_movimiento)
);