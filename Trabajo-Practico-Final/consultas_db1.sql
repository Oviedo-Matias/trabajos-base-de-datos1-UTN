DROP DATABASE IF EXISTS tp_final_db1;
CREATE DATABASE tp_final_db1;
USE tp_final_db1;

-- Crear tablas
CREATE TABLE clientes(
dni INT PRIMARY KEY, -- Se puede modificar desde la base de datos, pero se espera que no sea modificado por lo que no se puede modificar desde la aplicación en python
nombre VARCHAR(50) NOT NULL,
apellido VARCHAR(50) NOT NULL,
numero_telefono VARCHAR(50) DEFAULT 'No tiene',
INDEX index_dni (dni) -- Uso de index para optimizar búsqueda
);

CREATE TABLE productos(
id INT AUTO_INCREMENT PRIMARY KEY, -- Se puede modificar desde la base de datos, pero se espera que no sea modificado por lo que no se puede modificar desde la aplicación en python
nombre VARCHAR(50) NOT NULL,
stock_existente INT DEFAULT 0, -- El stock que se tiene
stock_disponible INT DEFAULT 0, -- El stock existente que no ha sido reservado en una orden
CONSTRAINT chk_stock CHECK (stock_disponible <= stock_existente AND stock_disponible >= 0 AND stock_existente >= 0), -- Validaciones para el stock
INDEX index_id (id) -- Uso de index para optimizar búsqueda
);

CREATE TABLE ordenes(
id INT AUTO_INCREMENT PRIMARY KEY,
dni_cliente INT,
id_producto INT,
fecha_compra DATE NOT NULL,
estado ENUM('Iniciado', 'Terminado', 'Cancelado') DEFAULT 'Iniciado',
cantidad_producto INT,
FOREIGN KEY (dni_cliente) REFERENCES clientes(dni) ON UPDATE CASCADE, -- Uso de UPDATE ON CASCADE para actualizar en caso de que las PK sean modificadas
FOREIGN KEY (id_producto) REFERENCES productos(id) ON UPDATE CASCADE,
CONSTRAINT chk_cant CHECK (cantidad_producto > 0),
INDEX index_id (id) -- Uso de index para optimizar búsqueda
);

-- Procedimientos
DELIMITER //

-- Recupera todos los productos en orden de más a menos vendidos
CREATE PROCEDURE productos_mas_vendidos()
BEGIN
	SELECT productos.id,
        productos.nombre,
        productos.stock_existente,
        productos.stock_disponible,
        SUM(ordenes.cantidad_producto) AS pedidos 
        FROM ordenes JOIN productos ON ordenes.id_producto = productos.id GROUP BY id_producto ORDER BY pedidos DESC;
END //

-- Recupera todos los productos en orden de menos a más vendidos
CREATE PROCEDURE productos_menos_vendidos()
BEGIN
	SELECT productos.id,
        productos.nombre,
        productos.stock_existente,
        productos.stock_disponible,
        SUM(ordenes.cantidad_producto) AS pedidos 
        FROM ordenes JOIN productos ON ordenes.id_producto = productos.id GROUP BY id_producto ORDER BY pedidos;
END //

-- Recupera los datos del producto más vendido
CREATE PROCEDURE reporte_producto_mas_vendido()
BEGIN
	SELECT productos.id,
        productos.nombre,
        productos.stock_existente,
        productos.stock_disponible,
        SUM(ordenes.cantidad_producto) AS pedidos
        FROM productos JOIN ordenes ON ordenes.id_producto = productos.id GROUP BY id ORDER BY pedidos DESC LIMIT 1;
END //

-- Recupera todos los clientes ordenados por mayor cantidad de productos pedidos
CREATE PROCEDURE clientes_con_mas_compras()
BEGIN
	SELECT clientes.dni,
			clientes.nombre,
            clientes.apellido,
            clientes.numero_telefono,
            SUM(ordenes.cantidad_producto) as pedidos
            FROM clientes JOIN ordenes ON clientes.dni = ordenes.dni_cliente GROUP BY dni ORDER BY pedidos DESC;
END //

-- Recupera todos los clientes ordenados por menor cantidad de productos pedidos
CREATE PROCEDURE clientes_con_menos_compras()
BEGIN
	SELECT clientes.dni,
			clientes.nombre,
            clientes.apellido,
            clientes.numero_telefono,
            SUM(ordenes.cantidad_producto) as pedidos
            FROM clientes JOIN ordenes ON clientes.dni = ordenes.dni_cliente GROUP BY dni ORDER BY pedidos;
END //

-- Modificar las órdenes de un producto dado para ajustarse una cierta cantidad máxima
CREATE PROCEDURE ajustar_cantidad_maxima(IN pid INT, IN cant_max INT)
BEGIN
	UPDATE ordenes SET cantidad_producto = cant_max WHERE cantidad_producto > cant_max AND id_producto = pid AND estado = 'Iniciado';
END //

DELIMITER ;

-- Inserts iniciales generados por IA para evitar la carga de 120 filas mínimas requeridas manualmente
-- Contienen cálculos comentados pedidos por el prompt para evitar errores con los stocks
INSERT INTO clientes (dni, nombre, apellido, numero_telefono) VALUES
(40123456, 'Juan', 'Pérez', '11-4567-8901'),
(38987654, 'María', 'Gómez', '11-4789-1234'),
(41222333, 'Lucía', 'Martínez', '11-5098-3344'),
(39555999, 'Santiago', 'López', '11-6001-4545'),
(37888999, 'Carla', 'Fernández', 'No tiene'),
(42333444, 'Tomás', 'Ruiz', '11-4201-2233'),
(40777666, 'Valentina', 'Sosa', 'No tiene'),
(39999888, 'Nicolás', 'Ramírez', '11-7150-9988'),
(38555666, 'Julieta', 'Moreno', '11-3344-5566'),
(43011222, 'Martín', 'Duarte', 'No tiene');

INSERT INTO productos (nombre, stock_existente, stock_disponible) VALUES
('Auriculares Bluetooth', 250, 40),
('Teclado Mecánico', 180, 25),
('Mouse Gamer', 320, 70),
('Monitor 24 Pulgadas', 150, 10),
('Memoria RAM 16GB', 210, 35),
('Disco SSD 1TB', 400, 55),
('Placa de Video GTX', 130, 15),
('Fuente 750W', 260, 30),
('Gabinete ATX', 190, 20),
('Cargador USB-C', 500, 80);

INSERT INTO ordenes (dni_cliente, id_producto, fecha_compra, estado, cantidad_producto) VALUES
-- PRODUCTO 1 (Auriculares, total iniciado = 210)
(40123456, 1, '2025-01-05', 'Iniciado', 50),
(38987654, 1, '2025-01-06', 'Iniciado', 40),
(41222333, 1, '2025-01-07', 'Iniciado', 30),
(39555999, 1, '2025-01-08', 'Iniciado', 60),
(37888999, 1, '2025-01-09', 'Iniciado', 30),

-- PRODUCTO 2 (Teclado, total iniciado = 155)
(42333444, 2, '2025-02-02', 'Iniciado', 30),
(40777666, 2, '2025-02-03', 'Iniciado', 25),
(39999888, 2, '2025-02-04', 'Iniciado', 40),
(38555666, 2, '2025-02-05', 'Iniciado', 35),
(43011222, 2, '2025-02-06', 'Iniciado', 25),

-- PRODUCTO 3 (Mouse Gamer, total iniciado = 250)
(40123456, 3, '2025-03-01', 'Iniciado', 50),
(38987654, 3, '2025-03-02', 'Iniciado', 50),
(41222333, 3, '2025-03-03', 'Iniciado', 60),
(39555999, 3, '2025-03-04', 'Iniciado', 40),
(37888999, 3, '2025-03-05', 'Iniciado', 50),

-- PRODUCTO 4 (Monitor, total iniciado = 140)
(42333444, 4, '2025-04-01', 'Iniciado', 30),
(40777666, 4, '2025-04-02', 'Iniciado', 20),
(39999888, 4, '2025-04-03', 'Iniciado', 40),
(38555666, 4, '2025-04-04', 'Iniciado', 25),
(43011222, 4, '2025-04-05', 'Iniciado', 25),

-- PRODUCTO 5 (RAM 16GB, total iniciado = 175)
(40123456, 5, '2025-05-01', 'Iniciado', 35),
(38987654, 5, '2025-05-02', 'Iniciado', 40),
(41222333, 5, '2025-05-03', 'Iniciado', 30),
(39555999, 5, '2025-05-04', 'Iniciado', 35),
(37888999, 5, '2025-05-05', 'Iniciado', 35),

-- PRODUCTO 6 (SSD 1TB, total iniciado = 345)
(42333444, 6, '2025-06-01', 'Iniciado', 70),
(40777666, 6, '2025-06-02', 'Iniciado', 80),
(39999888, 6, '2025-06-03', 'Iniciado', 60),
(38555666, 6, '2025-06-04', 'Iniciado', 70),
(43011222, 6, '2025-06-05', 'Iniciado', 65),

-- PRODUCTO 7 (Placa de video, total iniciado = 115)
(40123456, 7, '2025-07-01', 'Iniciado', 20),
(38987654, 7, '2025-07-02', 'Iniciado', 25),
(41222333, 7, '2025-07-03', 'Iniciado', 30),
(39555999, 7, '2025-07-04', 'Iniciado', 20),
(37888999, 7, '2025-07-05', 'Iniciado', 20),

-- PRODUCTO 8 (Fuente 750W, total iniciado = 230)
(42333444, 8, '2025-08-01', 'Iniciado', 50),
(40777666, 8, '2025-08-02', 'Iniciado', 40),
(39999888, 8, '2025-08-03', 'Iniciado', 50),
(38555666, 8, '2025-08-04', 'Iniciado', 45),
(43011222, 8, '2025-08-05', 'Iniciado', 45),

-- PRODUCTO 9 (Gabinete ATX, total iniciado = 170)
(40123456, 9, '2025-09-01', 'Iniciado', 30),
(38987654, 9, '2025-09-02', 'Iniciado', 40),
(41222333, 9, '2025-09-03', 'Iniciado', 35),
(39555999, 9, '2025-09-04', 'Iniciado', 35),
(37888999, 9, '2025-09-05', 'Iniciado', 30),

-- PRODUCTO 10 (Cargador USB-C, total iniciado = 420)
(42333444, 10, '2025-10-01', 'Iniciado', 80),
(40777666, 10, '2025-10-02', 'Iniciado', 90),
(39999888, 10, '2025-10-03', 'Iniciado', 70),
(38555666, 10, '2025-10-04', 'Iniciado', 90),
(43011222, 10, '2025-10-05', 'Iniciado', 90),

-- 50 ÓRDENES ADICIONALES (Terminado o Cancelado)
(40123456, 1, '2025-11-01', 'Terminado', 3),
(38987654, 2, '2025-11-02', 'Cancelado', 2),
(41222333, 3, '2025-11-03', 'Terminado', 4),
(39555999, 4, '2025-11-04', 'Cancelado', 1),
(37888999, 5, '2025-11-05', 'Terminado', 2),
(42333444, 6, '2025-11-06', 'Cancelado', 3),
(40777666, 7, '2025-11-07', 'Terminado', 5),
(39999888, 8, '2025-11-08', 'Cancelado', 2),
(38555666, 9, '2025-11-09', 'Terminado', 1),
(43011222, 10, '2025-11-10', 'Cancelado', 2),

(40123456, 2, '2025-11-11', 'Terminado', 6),
(38987654, 3, '2025-11-12', 'Cancelado', 7),
(41222333, 4, '2025-11-13', 'Terminado', 3),
(39555999, 5, '2025-11-14', 'Cancelado', 4),
(37888999, 6, '2025-11-15', 'Terminado', 8),
(42333444, 7, '2025-11-16', 'Cancelado', 6),
(40777666, 8, '2025-11-17', 'Terminado', 5),
(39999888, 9, '2025-11-18', 'Cancelado', 3),
(38555666, 10, '2025-11-19', 'Terminado', 4),
(43011222, 1, '2025-11-20', 'Cancelado', 3),

(40123456, 3, '2025-11-21', 'Terminado', 6),
(38987654, 4, '2025-11-22', 'Cancelado', 4),
(41222333, 5, '2025-11-23', 'Terminado', 7),
(39555999, 6, '2025-11-24', 'Cancelado', 6),
(37888999, 7, '2025-11-25', 'Terminado', 3),
(42333444, 8, '2025-11-26', 'Cancelado', 8),
(40777666, 9, '2025-11-27', 'Terminado', 5),
(39999888, 10, '2025-11-28', 'Cancelado', 7),
(38555666, 1, '2025-11-29', 'Terminado', 4),
(43011222, 2, '2025-11-30', 'Cancelado', 6),

(40123456, 4, '2025-12-01', 'Terminado', 5),
(38987654, 5, '2025-12-02', 'Cancelado', 3),
(41222333, 6, '2025-12-03', 'Terminado', 2),
(39555999, 7, '2025-12-04', 'Cancelado', 1),
(37888999, 8, '2025-12-05', 'Terminado', 3),
(42333444, 9, '2025-12-06', 'Cancelado', 4),
(40777666, 10, '2025-12-07', 'Terminado', 5),
(39999888, 1, '2025-12-08', 'Cancelado', 3),
(38555666, 2, '2025-12-09', 'Terminado', 4),
(43011222, 3, '2025-12-10', 'Cancelado', 7),

(40123456, 4, '2025-12-01', 'Terminado', 5),
(38987654, 5, '2025-12-02', 'Cancelado', 3),
(41222333, 6, '2025-12-03', 'Terminado', 2),
(39555999, 7, '2025-12-04', 'Cancelado', 1),
(37888999, 8, '2025-12-05', 'Terminado', 3),
(42333444, 7, '2025-11-16', 'Cancelado', 6),
(40777666, 8, '2025-11-17', 'Terminado', 5),
(39999888, 9, '2025-11-18', 'Cancelado', 3),
(38555666, 10, '2025-11-19', 'Terminado', 4),
(43011222, 1, '2025-11-20', 'Cancelado', 3);

-- Creación de triggers
DELIMITER //

-- Si un producto es eliminado, todas las ordenes de este se cancelan
CREATE TRIGGER cancelar_por_eliminacion_productos
BEFORE DELETE ON productos
FOR EACH ROW
BEGIN
	UPDATE ordenes SET estado = 'Cancelado' WHERE id_producto = old.id;
END //

-- Si un cliente es eliminado, todas las ordenes de este se cancelan
CREATE TRIGGER cancelar_por_eliminacion_clientes
BEFORE DELETE ON clientes
FOR EACH ROW
BEGIN
	UPDATE ordenes SET estado = 'Cancelado' WHERE dni_cliente = old.dni;
END //

-- Se valida que el stock para la orden sea suficiente y luego se resta
CREATE TRIGGER controlar_inicio_orden
BEFORE INSERT ON ordenes
FOR EACH ROW
BEGIN
	DECLARE disponible INT;
    SELECT stock_disponible INTO disponible FROM productos WHERE id = new.id_producto LIMIT 1;
	IF new.cantidad_producto > disponible AND new.estado = 'Iniciado' THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El stock no disponible no es suficiente';
	END IF;
    IF new.estado = 'Iniciado' THEN
		UPDATE productos SET stock_disponible = stock_disponible - new.cantidad_producto WHERE id = new.id_producto;
	END IF;
END //

-- Se resta al stock_existente la cantidad de producto pedida si se termina la orden
-- Se suma al stock_disponible la cantidad de producto pedida si se cancela la orden
CREATE TRIGGER terminar_cancelar_orden
AFTER UPDATE ON ordenes
FOR EACH ROW
BEGIN
	IF old.estado = 'Iniciado' AND new.estado = 'Terminado' THEN
		UPDATE productos SET stock_existente = stock_existente - new.cantidad_producto WHERE id = new.id_producto;
	ELSEIF old.estado = 'Iniciado' AND new.estado = 'Cancelado' THEN
		UPDATE productos SET stock_disponible = stock_disponible + new.cantidad_producto WHERE id = new.id_producto;
	END IF;
END //

-- Se evita que el stock_existente sea menor al que ya fue reservado y al que queda disponible
CREATE TRIGGER controlar_updates_stocks
BEFORE UPDATE ON productos
FOR EACH ROW
BEGIN
	DECLARE reservado INT;
    SELECT COALESCE(SUM(cantidad_producto), 0) INTO reservado FROM ordenes WHERE id_producto = new.id AND estado = 'Iniciado';
	IF new.stock_existente < reservado + new.stock_disponible THEN
		SIGNAL SQLSTATE '45001'
        SET MESSAGE_TEXT = 'El stock existente no puede ser menor al reservado + el stock disponible';
	END IF;
END //

-- Se evitan updates indebidas en ordenes y se devuelve el stock_disponible en caso de ejecutar el procedimiento ajustar_cantidad_maxima
CREATE TRIGGER controlar_update_ordenes
BEFORE UPDATE ON ordenes
FOR EACH ROW
BEGIN
	IF old.cantidad_producto > new.cantidad_producto AND old.estado = 'Iniciado' THEN
		UPDATE productos SET stock_disponible = stock_disponible + old.cantidad_producto - new.cantidad_producto,
			stock_existente = stock_existente + old.cantidad_producto - new.cantidad_producto WHERE id = new.id_producto;
	ELSEIF old.cantidad_producto < new.cantidad_producto OR (old.estado <> new.estado AND new.estado = 'Iniciado') OR old.id <> new.id THEN
		SIGNAL SQLSTATE '45002'
		SET MESSAGE_TEXT = 'Modificación indebida';
	END IF;
END //

DELIMITER ;