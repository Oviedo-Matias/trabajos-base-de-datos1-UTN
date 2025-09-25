USE BaseDeDatos1_TP2_ejemplos;

CREATE TABLE Clientes (
  dni INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  direccion VARCHAR(255) NOT NULL
);

CREATE TABLE Asuntos (
  numero_expediente INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
  fecha_inicio date NOT NULL,
  fecha_fin date,
  estado VARCHAR(100) NOT NULL,
  dni_cliente INT NOT NULL,
  FOREIGN KEY (dni_cliente) REFERENCES Clientes (dni)
);

CREATE TABLE Procuradores (
  id_procurador INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  direccion VARCHAR(255) NOT NULL
);

CREATE TABLE Asuntos_Procuradores AS 
SELECT Asuntos.numero_expediente, Procuradores.id_procurador FROM Asuntos, Procuradores;

-- Poblar la tabla Clientes
INSERT INTO Clientes (dni, nombre, direccion)
VALUES
('123456789', 'Juan Pérez', 'Calle Pueyrredón 3498, Buenos Aires'),
('987654321', 'Ana García', 'Calle 5 323, La Plata'),
('456123789', 'Luis Fernández', 'Avenida de Gral. Paz 1056, Bahía Blanca');

-- Poblar la tabla Asuntos
INSERT INTO Asuntos (numero_expediente, dni_cliente, fecha_inicio, fecha_fin, estado)
VALUES
(1, '123456789', '2023-01-15', '2023-07-20', 'Cerrado'),
(2, '987654321', '2023-05-10', NULL, 'Abierto'),
(3, '456123789', '2023-06-01', '2023-09-10', 'Cerrado');

-- Poblar la tabla Procuradores
INSERT INTO Procuradores (id_procurador, nombre, direccion)
VALUES
(1, 'Laura Sánchez', 'Calle Soler 3765, Buenos Aires'),
(2, 'Carlos López', 'Calle Estrellas 8, Mar del Plata'),
(3, 'Marta Díaz', 'Calle Estación 12, Olavarria');

-- Poblar la tabla Asuntos_Procuradores
INSERT INTO Asuntos_Procuradores (numero_expediente, id_procurador)
VALUES
(1, 1),
(2, 2),
(3, 3),
(2, 1);  -- Un asunto puede tener varios procuradores