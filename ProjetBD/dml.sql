-- Insertion dans la table Identite
INSERT INTO Identite (pseudo, nom, prenom, id_adresse, telephone, email, date_naissance) VALUES
('2212003', 'TERRIE', 'THIBAULT', 'Addr001', '+33645789125', 'terrie.thibaul@etu.cyu.fr', '2001-04-06'),
('2222003', 'TRINH', 'GIA TAM', 'Addr002', '+33742168934', 'giatam.trinh@etu.cyu.fr', '1958-03-24');

-- Insertion dans la table Personnel
INSERT INTO Personnel (pseudo_personnel, date_embauche_personnel, role_personnel, salaire, status_personnel, conge_date_debut, conge_date_fin) VALUES
('Pers11', '2000-08-08', 'gestionnaire', 2500.00, 'actif', NULL, NULL),
('Pers21', '2000-04-06', 'caissier', 1800.00, 'congé', '2024-06-18', '2024-07-24');

-- Insertion dans la table Joueur
INSERT INTO Joueur (pseudo_joueur, date_inscription_joueur, carte_fidelite_id_joueur, points_fidelite_joueur, solde_joueur, pseudo_personnel) VALUES
('Derdoublox', '2020-01-01', 'cfhe0003', 2005, 89.79, 'Pers11'),
('SupraFox77', '2021-01-01', 'cfst0025', 1249, 53.47, 'Pers21');

-- Insertion dans la table Adresse
INSERT INTO Adresse (id_adresse, numero_et_voie, code_postal, commune, pseudo) VALUES
('Addr001', '3 RUE LEBON,', '95000', 'CERGY', '2212003'),
('Addr002', '5 BD DU PORT,', '95000', 'CERGY', '2222003');

-- Insertion dans la table Transaction
INSERT INTO Transaction (id_transaction, date_transaction, montant_transaction, type_transaction, mode_paiement_transaction, pseudo_joueur) VALUES
('Tran1', '2023-01-02', 10.50, 'achat_jeton', 'carte_bancaire', 'Derdoublox'),
('Tran2', '2024-01-03', 5.00, 'achat_conso', 'carte_fidelite', 'SupraFox77');

-- Insertion dans la table Consommable
INSERT INTO Consommable (id_consommable, nom_consommable, prix_consommable, stock_consommable, pseudo_joueur) VALUES
('Cons21', 'Soda 33cl', 2.50, 100, 'Derdoublox'),
('Cons56', 'Barre chocolatée', 1.20, 50, 'SupraFox77');

-- Insertion dans la table Reservation
INSERT INTO Reservation (id_reservation, date_reservation, status_reservation, pseudo_joueur) VALUES
('Res3457', '2024-06-18', 'en_attente', 'Derdoublox'),
('Res8134', '2024-06-18', 'confirmee', 'SupraFox77');

-- Insertion dans la table Machine
INSERT INTO Machine (id_machine, nom_machine, emplacement_machine, date_installation_machine, statut_machine, nom_du_sav_machine, numero_du_sav_machine, pseudo_personnel, id_reservation) VALUES
('Mach1234', 'Borne d’arcade', 'Accueil', '2000-01-01', 'disponible', 'TechnoSav', '+33612345678', 'Pers11', 'Res3457'),
('Mach1235', 'CasqueVR', 'Zone 3', '2000-01-01', 'maintenance', 'ServicePlus', '+33798765432', 'Pers21', 'Res8134');

-- Insertion dans la table Jeu
INSERT INTO Jeu (id_jeu, nom_jeu, categorie_jeu, date_creation_jeu, meilleur_score, id_machine) VALUES
('Jeu15026', 'Fifa', 'jeu vidéo', '2000-01-01', 1500, 'Mach1234'),
('Jeu56800', 'Fortnite', 'jeu vidéo', '2000-01-01', 2000, 'Mach1235');

-- Insertion dans la table est_classé
INSERT INTO est_classé (id_jeu, pseudo_joueur, position) VALUES
('Jeu15026', 'Derdoublox', 1),
('Jeu56800', 'SupraFox77', 2);

-- Insertion dans la table Session_Jeu
INSERT INTO Session_Jeu (id_session, date_session, score, id_jeu) VALUES
('Sess2454', '2023-09-12', 150, 'Jeu15026'),
('Sess2455', '2023-09-13', 200, 'Jeu56800');

-- Insertion dans la table joue
INSERT INTO joue (id_session, pseudo_joueur) VALUES
('Sess2454', 'Derdoublox'),
('Sess2455', 'SupraFox77');
