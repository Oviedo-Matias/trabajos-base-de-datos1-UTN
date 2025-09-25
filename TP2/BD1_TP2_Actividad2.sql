USE BaseDeDatos1_TP2_ejemplos;

-- ¿Cuál es el nombre y la dirección de los procuradores que han trabajado en un asunto abierto?
SELECT Procuradores.nombre, Procuradores.direccion FROM procuradores INNER JOIN Asuntos_Procuradores ON procuradores.id_procurador = Asuntos_Procuradores.id_procurador
INNER JOIN Asuntos ON Asuntos_Procuradores.numero_expediente = Asuntos.numero_expediente WHERE Asuntos.Estado = 'Abierto';

-- ¿Qué clientes han tenido asuntos en los que ha participado el procurador Carlos López?
SELECT clientes.nombre FROM clientes INNER JOIN asuntos ON clientes.dni = asuntos.dni_cliente
INNER JOIN Asuntos_Procuradores ON asuntos.numero_expediente = Asuntos_Procuradores.numero_expediente
INNER JOIN Procuradores ON Asuntos_Procuradores.id_procurador = Procuradores.id_procurador WHERE Procuradores.nombre = 'Carlos López';

-- ¿Cuántos asuntos ha gestionado cada procurador?
SELECT procuradores.nombre, COUNT(*) AS casos FROM procuradores
INNER JOIN Asuntos_Procuradores ON Procuradores.id_procurador = Asuntos_Procuradores.id_procurador
INNER JOIN Asuntos ON Asuntos_Procuradores.numero_expediente = Asuntos.numero_expediente
WHERE Procuradores.id_procurador = Asuntos_Procuradores.id_procurador GROUP BY Asuntos_Procuradores.id_procurador;

-- Lista los números de expediente y fechas de inicio de los asuntos de los clientes que viven en Buenos Aires.
SELECT asuntos.numero_expediente, asuntos.fecha_inicio FROM asuntos INNER JOIN clientes ON asuntos.dni_cliente = clientes.dni WHERE clientes.direccion LIKE '%Buenos Aires';

