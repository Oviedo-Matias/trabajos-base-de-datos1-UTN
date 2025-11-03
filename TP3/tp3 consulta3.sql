use db1_tp3;

CREATE TABLE cliente(
dni_cliente INT PRIMARY KEY,
nombre_cliente VARCHAR(50) NOT NULL,
celular_cliente INT NOT NULL
);

CREATE TABLE auto(
matricula VARCHAR(10) PRIMARY KEY,
marca_auto VARCHAR(50) NOT NULL,
modelo_auto VARCHAR(50) NOT NULL,
dni_cliente INT NOT NULL,
FOREIGN KEY (dni_cliente) REFERENCES cliente(dni_cliente)
);

CREATE TABLE sucursal(
codigo_sucursal INT PRIMARY KEY,
domicilio_sucursal VARCHAR(50) NOT NULL,
telefono_sucursal INT NOT NULL
);

CREATE TABLE fosa(
codigo_fosa INT NOT NULL,
codigo_sucursal INT NOT NULL,
largo_fosa REAL NOT NULL,
ancho_fosa REAL NOT NULL,
PRIMARY KEY (codigo_fosa, codigo_sucursal),
FOREIGN KEY (codigo_sucursal) REFERENCES sucursal(codigo_sucursal)
);

CREATE TABLE mecanico(
codigo_mecanico INT PRIMARY KEY,
nombre_mecanico VARCHAR(50) NOT NULL,
email_mecanico VARCHAR(50) NOT NULL,
codigo_sucursal INT NOT NULL,
FOREIGN KEY (codigo_sucursal) REFERENCES sucursal(codigo_sucursal)
);

CREATE TABLE reparaciones(
codigo_fosa INT NOT NULL,
codigo_sucursal INT NOT NULL,
matricula VARCHAR(10) NOT NULL,
PRIMARY KEY (codigo_fosa, codigo_sucursal, matricula),
FOREIGN KEY (codigo_fosa, codigo_sucursal) REFERENCES fosa(codigo_fosa, codigo_sucursal),
FOREIGN KEY (matricula) REFERENCES auto(matricula)
);