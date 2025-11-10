USE banco_db1_tp4;

-- Limpiar
DROP PROCEDURE IF EXISTS VerCuentas;
DROP PROCEDURE IF EXISTS CuentasConSaldoMayorQue;
DROP PROCEDURE IF EXISTS TotalMovimientosDelMes;
DROP PROCEDURE IF EXISTS Depositar;
DROP PROCEDURE IF EXISTS Extraer;
DROP TRIGGER IF EXISTS ActualizarSaldo;
DROP PROCEDURE IF EXISTS PagarInteres;

DELIMITER $$

-- 3. Crear procedimiento VerCuentas()
CREATE PROCEDURE VerCuentas()
BEGIN
	SELECT * FROM cuentas;
END$$

-- 4. Crear procedimiento CuentasConSaldoMayorQue(IN limite DECIMAL(10,2))
CREATE PROCEDURE CuentasConSaldoMayorQue(IN limite DECIMAL(10,2))
BEGIN
	SELECT * FROM cuentas WHERE saldo > limite;
END$$

-- 5. Crear procedimiento TotalMovimientosDelMes(IN cuenta INT, OUT total DECIMAL(10,2))
CREATE PROCEDURE TotalMovimientosDelMes(IN cuenta INT, OUT total DECIMAL(10,2))
BEGIN

    DECLARE cred DECIMAL(10,2) DEFAULT 0;
    DECLARE deb DECIMAL(10,2) DEFAULT 0;
    DECLARE saldo_actual DECIMAL(10,2) DEFAULT 0;

	SELECT IFNULL(SUM(movimientos.importe), 0) INTO cred FROM movimientos WHERE UPPER(movimientos.tipo) = 'CREDITO' AND 
    movimientos.numero_cuenta = cuenta AND MONTH(fecha) = MONTH(CURDATE())
      AND YEAR(fecha) = YEAR(CURDATE());
      
	SELECT IFNULL(SUM(movimientos.importe), 0) INTO deb FROM movimientos WHERE UPPER(movimientos.tipo) = 'DEBITO' AND 
    movimientos.numero_cuenta = cuenta AND MONTH(fecha) = MONTH(CURDATE())
      AND YEAR(fecha) = YEAR(CURDATE());      
	SELECT saldo INTO saldo_actual FROM cuentas WHERE numero_cuenta = cuenta;
    SET total = saldo_actual + cred - deb;
END$$
DELIMITER ;
CALL TotalMovimientosDelMes(1001, @resultado);
SELECT @resultado;
DELIMITER $$
-- 6. Depositar
CREATE PROCEDURE Depositar(IN cuenta INT, IN monto DECIMAL(10, 2))
BEGIN
    DECLARE var_num_movimiento INT;
    DECLARE var_saldo DECIMAL(10, 2);
    
	UPDATE cuentas SET saldo = saldo + monto WHERE numero_cuenta = cuenta;
    INSERT INTO movimientos (numero_cuenta, fecha, tipo, importe) VALUES (cuenta, CURDATE(), 'CREDITO', monto);
    SELECT numero_movimiento INTO var_num_movimiento FROM movimientos WHERE numero_cuenta = cuenta;
    SELECT saldo INTO var_saldo FROM cuentas WHERE numero_cuenta = cuenta;
    INSERT INTO historial_movimientos (numero_cuenta, numero_movimiento, saldo_anterior, saldo_actual) VALUES (cuenta, var_num_movimiento, var_saldo - monto, var_saldo);
END$$

-- 7. Extraer
CREATE PROCEDURE Extraer(IN cuenta INT, IN monto DECIMAL(10, 2))
BEGIN
    DECLARE var_num_movimiento INT;
    DECLARE var_saldo DECIMAL(10, 2);

	UPDATE cuentas SET saldo = saldo - monto WHERE numero_cuenta = cuenta;
    INSERT INTO movimientos (numero_cuenta, fecha, tipo, importe) VALUES (cuenta, CURDATE(), 'DEBITO', monto);
    SELECT numero_movimiento INTO var_num_movimiento FROM movimientos WHERE numero_cuenta = cuenta;
    SELECT saldo INTO var_saldo FROM cuentas WHERE numero_cuenta = cuenta;
    INSERT INTO historial_movimientos (numero_cuenta, numero_movimiento, saldo_anterior, saldo_actual) VALUES (cuenta, var_num_movimiento, var_saldo + monto, var_saldo);
END$$

-- 8. Crear trigger que actualice el saldo
CREATE TRIGGER ActualizarSaldo
AFTER INSERT ON movimientos
FOR EACH ROW
BEGIN
	IF NEW.tipo = 'CREDITO' THEN
		UPDATE cuentas SET cuentas.saldo = cuentas.saldo + NEW.importe WHERE cuentas.numero_cuenta = NEW.numero_cuenta;
	ELSE
		UPDATE cuentas SET cuentas.saldo = cuentas.saldo - NEW.importe WHERE cuentas.numero_cuenta = NEW.numero_cuenta;
	END IF;
END $$

-- 9. Modificar trigger anterior
DROP TRIGGER IF EXISTS ActualizarSaldo;
CREATE TRIGGER ActualizarSaldo
AFTER INSERT ON movimientos
FOR EACH ROW
BEGIN
	DECLARE saldo_anterior DECIMAL(10,2);
	DECLARE saldo_actual DECIMAL(10,2);
    SELECT saldo INTO saldo_anterior FROM cuentas WHERE numero_cuenta = NEW.numero_cuenta;
	IF NEW.tipo = 'CREDITO' THEN
		UPDATE cuentas SET cuentas.saldo = cuentas.saldo + NEW.importe WHERE cuentas.numero_cuenta = NEW.numero_cuenta;
        SELECT saldo INTO saldo_actual FROM cuentas WHERE numero_cuenta = NEW.numero_cuenta;
        INSERT INTO historial_movimientos (numero_cuenta, numero_movimiento, saldo_anterior, saldo_actual) VALUES 
			(NEW.numero_cuenta, NEW.numero_movimiento, cuentas.saldo - NEW.importe, cuentas.saldo);
	ELSE
		UPDATE cuentas SET cuentas.saldo = cuentas.saldo - NEW.importe WHERE cuentas.numero_cuenta = NEW.numero_cuenta;
        SELECT saldo INTO saldo_actual FROM cuentas WHERE numero_cuenta = NEW.numero_cuenta;
        INSERT INTO historial_movimientos (numero_cuenta, numero_movimiento, saldo_anterior, saldo_actual) VALUES 
			(NEW.numero_cuenta, NEW.numero_movimiento, cuentas.saldo + NEW.importe, cuentas.saldo);
	END IF;
END $$

-- 10. Crear TotalMovimientosDelMes(IN cuenta INT, OUT total DECIMAL(10,2)) con cursores
DROP PROCEDURE IF EXISTS TotalMovimientosDelMes;
CREATE PROCEDURE TotalMovimientosDelMes(IN cuenta INT, OUT total DECIMAL(10, 2))
BEGIN
    DECLARE creditos DECIMAL(10, 2) DEFAULT 0.00;
    DECLARE debitos DECIMAL(10, 2) DEFAULT 0.00;
    DECLARE saldo_actual DECIMAL(10, 2) DEFAULT 0.00;
    DECLARE importe_temp DECIMAL(10, 2);
    DECLARE fin BOOLEAN DEFAULT FALSE;

    DECLARE cursor_creditos CURSOR FOR
        SELECT importe 
        FROM movimientos 
        WHERE numero_cuenta = cuenta 
          AND tipo = 'CREDITO' 
          AND MONTH(fecha) = MONTH(CURDATE())
          AND YEAR(fecha) = YEAR(CURDATE());

    DECLARE cursor_debitos CURSOR FOR
        SELECT importe 
        FROM movimientos 
        WHERE numero_cuenta = cuenta 
          AND tipo = 'DEBITO' 
          AND MONTH(fecha) = MONTH(CURDATE())
          AND YEAR(fecha) = YEAR(CURDATE());

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET fin = TRUE;

    SET fin = FALSE;
    SET creditos = 0.00;

    OPEN cursor_creditos;
    leer_creditos: LOOP
        FETCH cursor_creditos INTO importe_temp;
        IF fin THEN
            LEAVE leer_creditos;
        END IF;
        SET creditos = creditos + COALESCE(importe_temp, 0.00);
    END LOOP leer_creditos;
    CLOSE cursor_creditos;

    SET fin = FALSE;
    SET debitos = 0.00;

    OPEN cursor_debitos;
    leer_debitos: LOOP
        FETCH cursor_debitos INTO importe_temp;
        IF fin THEN
            LEAVE leer_debitos;
        END IF;
        SET debitos = debitos + COALESCE(importe_temp, 0.00);
    END LOOP leer_debitos;
    CLOSE cursor_debitos;

    SELECT COALESCE(saldo, 0.00) INTO saldo_actual
    FROM cuentas 
    WHERE numero_cuenta = cuenta;

    SET total = saldo_actual + creditos - debitos;
END$$
    
-- 11. Crear procedimiento para pagar interés
CREATE PROCEDURE PagarInteres(IN interes DECIMAL(5,2))
BEGIN
    DECLARE fin BOOLEAN DEFAULT FALSE;
    DECLARE saldo_actual DECIMAL(10, 2);
    DECLARE nuevo_saldo DECIMAL(10, 2);
    DECLARE cuenta_id INT;

    -- Cursor para recorrer cada cuenta
    DECLARE c CURSOR FOR
        SELECT numero_cuenta, saldo FROM cuentas;

    -- Handler para terminar el bucle al final del cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET fin = TRUE;

    SET interes = interes / 100 + 1;

    OPEN c;
    leer_lineas: LOOP
        FETCH c INTO cuenta_id, saldo_actual;
        IF fin THEN
            LEAVE leer_lineas;
        END IF;

        SET nuevo_saldo = saldo_actual * interes;

        UPDATE cuentas
        SET saldo = nuevo_saldo
        WHERE numero_cuenta = cuenta_id AND saldo > 100000;
    END LOOP leer_lineas;

    CLOSE c;
END$$

DELIMITER ;

-- Llamar procedimientos
CALL VerCuentas();
CALL CuentasConSaldoMayorQue(2000);
CALL TotalMovimientosDelMes(1001, @resultado);
SELECT @resultado;
CALL Depositar(1001, 200.00);
CALL VerCuentas();
-- CALL Extraer(1001, 200.00);
-- CALL VerCuentas();
CALL PagarInteres(2);
CALL VerCuentas();