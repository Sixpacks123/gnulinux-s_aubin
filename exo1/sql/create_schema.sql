-- ------------------------------------------------------------
-- create_schema.sql – Schéma minimal prod + archive
-- ------------------------------------------------------------

-- Base de production
DROP DATABASE IF EXISTS prod;
CREATE DATABASE prod CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE prod;

CREATE TABLE clients (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    nom           VARCHAR(50)  NOT NULL,
    prenom        VARCHAR(50)  NOT NULL,
    email         VARCHAR(100) NOT NULL UNIQUE,
    adresse       VARCHAR(255),
    mot_de_passe  CHAR(60)     NOT NULL,
    last_activity DATE         NOT NULL
);

CREATE TABLE factures (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    id_client     INT          NOT NULL,
    date          DATE         NOT NULL,
    montant_ttc   DECIMAL(10,2) NOT NULL,
    num_facture   VARCHAR(20) NOT NULL UNIQUE,
    FOREIGN KEY (id_client) REFERENCES clients(id)
);

-- Base d'archive (vierge au départ)
DROP DATABASE IF EXISTS archive;
CREATE DATABASE archive CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

