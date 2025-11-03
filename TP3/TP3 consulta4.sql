USE db1_tp3;

CREATE TABLE torneos(
cod_torneo INT PRIMARY KEY,
nombre_torneo VARCHAR(50) NOT NULL
);

CREATE TABLE participacion_torneos(
cod_torneo INT NOT NULL,
cod_corredor INT NOT NULL,
PRIMARY KEY (cod_torneo, cod_corredor),
FOREIGN KEY (cod_corredor, cod_torneo) REFERENCES corredores(cod_corredor, cod_torneo)
);

CREATE TABLE corredores(
cod_corredor INT,
cod_torneo INT,
nyap_corredor VARCHAR(50) NOT NULL,
PRIMARY KEY (cod_corredor, cod_torneo),
FOREIGN KEY (cod_torneo) REFERENCES torneos(cod_torneo)
);

CREATE TABLE datos_sponsors(
sponsor VARCHAR(50) PRIMARY KEY,
dni_presidente_sponsor INT NOT NULL,
dni_medico INT NOT NULL
);

CREATE TABLE contratos_sponsors(
cod_torneo INT,
cod_corredor INT,
sponsor VARCHAR(50),
PRIMARY KEY (cod_torneo, cod_corredor, sponsor),
FOREIGN KEY (cod_torneo, cod_corredor) REFERENCES corredores(cod_torneo, cod_corredor),
FOREIGN KEY (sponsor) REFERENCES datos_sponsors(sponsor)
);

CREATE TABLE bicicletas(
cod_bicicleta INT NOT NULL,
cod_torneo INT,
cod_corredor INT,
marca_bicicleta VARCHAR(50) NOT NULL,
PRIMARY KEY (cod_bicicleta, cod_torneo),
FOREIGN KEY (cod_torneo, cod_corredor) REFERENCES corredores(cod_torneo, cod_corredor)
);