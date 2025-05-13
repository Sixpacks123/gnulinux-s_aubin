-- ------------------------------------------------------------
-- sample_data.sql – Jeu de données minimal pour tests locaux
-- ------------------------------------------------------------
USE prod;

INSERT INTO clients (nom, prenom, email, adresse, mot_de_passe, last_activity) VALUES
('Dupont','Alice','alice.dupont@example.com','1 rue des Lilas, 75000 Paris','$2y$10$Zbh8OVB1kIrZ','2025-04-15'),
('Martin','Bob','bob.martin@example.com','2 avenue Victor Hugo, 69000 Lyon','$2y$10$k9s83mBb12','2021-02-10'),
('Durand','Chloé','chloe.durand@example.com','3 bd National, 13000 Marseille','$2y$10$uJw7sD12A9','2020-05-22'),
('Petit','David','david.petit@example.com','4 impasse des Fleurs, 31000 Toulouse','$2y$10$9ghGd2Kklp','2022-11-03'),
('Moreau','Eva','eva.moreau@example.com','5 quai du Port, 44000 Nantes','$2y$10$0PkdjH72Df','2019-08-30');

INSERT INTO factures (id_client, date, montant_ttc, num_facture) VALUES
(1,'2025-04-20',120.50,'F-2025-001'),
(1,'2025-04-28',80.00,'F-2025-002'),
(2,'2020-12-05',250.99,'F-2020-101'),
(2,'2021-01-15',320.75,'F-2021-003'),
(3,'2019-09-12',99.90,'F-2019-450'),
(3,'2020-02-08',150.00,'F-2020-012'),
(4,'2022-12-30',200.00,'F-2022-230'),
(5,'2019-07-01',75.20,'F-2019-300');

