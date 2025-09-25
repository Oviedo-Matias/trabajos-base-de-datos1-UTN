USE BaseDeDatos1_TP2_ejemplos;

-- Sin usar join:
-- ¿Qué socios tienen barcos amarrados en un número de amarre mayor que 10?
SELECT nombre FROM socios WHERE id_socio in (
  SELECT id_socio FROM barcos WHERE numero_amarre > 10
);
-- ¿Cuáles son los nombres de los barcos y sus cuotas de aquellos barcos cuyo socio se llama 'Juan Pérez'?
SELECT nombre, cuota FROM Barcos WHERE id_socio in (
  SELECT id_socio FROM socios WHERE nombre = 'Juan Pérez'
);

-- ¿Cuántas salidas ha realizado el barco con matrícula 'ABC123'?
SELECT count(*) FROM salidas where matricula = 'ABC123';

-- Lista los barcos que tienen una cuota mayor a 500 y sus respectivos socios.
SELECT socios.nombre as nombre_socio, barcos.nombre as nombre_barco FROM socios, barcos WHERE socios.id_socio = barcos.id_socio AND socios.id_socio in (
  SELECT id_socio FROM barcos WHERE cuota > 500
);

-- ¿Qué barcos han salido con destino a 'Mallorca'?
SELECT nombre FROM barcos WHERE matricula in (
  SELECT matricula FROM salidas WHERE destino = "Mallorca"
);

-- ¿Qué patrones (nombre y dirección) han llevado un barco cuyo socio vive en 'Barcelona'?
SELECT Salidas.patron_nombre, Salidas.patron_direccion FROM salidas, barcos, socios WHERE barcos.id_socio in (
  SELECT id_socio FROM socios WHERE direccion LIKE '%Barcelona'
) AND direccion LIKE '%Barcelona' AND salidas.matricula = barcos.matricula;

-- Usando join:
-- ¿Qué socios tienen barcos amarrados en un número de amarre mayor que 10?
SELECT socios.nombre FROM socios INNER JOIN barcos ON socios.id_socio = barcos.id_socio WHERE barcos.numero_amarre > 10;

-- ¿Cuáles son los nombres de los barcos y sus cuotas de aquellos barcos cuyo socio se llama 'Juan Pérez'?
SELECT barcos.nombre, barcos.cuota FROM barcos INNER JOIN socios ON barcos.id_socio = socios.id_socio WHERE socios.nombre = 'Juan Pérez';

-- ¿Cuántas salidas ha realizado el barco con matrícula 'ABC123'?
SELECT COUNT(*) FROM salidas inner join barcos ON salidas.matricula = barcos.matricula where barcos.matricula = 'ABC123';

-- Lista los barcos que tienen una cuota mayor a 500 y sus respectivos socios.
SELECT Barcos.nombre as nombre_barco, socios.nombre as nombre_socio FROM Barcos inner join Socios ON barcos.id_socio = Socios.id_socio WHERE barcos.cuota > 500;

-- ¿Qué barcos han salido con destino a 'Mallorca'?
SELECT barcos.nombre FROM barcos INNER JOIN salidas ON barcos.matricula = salidas.matricula WHERE salidas.destino = 'Mallorca';

-- ¿Qué patrones (nombre y dirección) han llevado un barco cuyo socio vive en 'Barcelona'?
SELECT salidas.patron_nombre, salidas.patron_direccion FROM salidas INNER JOIN barcos ON salidas.matricula = barcos.matricula
INNER JOIN socios ON barcos.id_socio = socios.id_socio WHERE direccion LIKE '%Barcelona'

