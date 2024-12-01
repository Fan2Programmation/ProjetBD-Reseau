-- Table Identite (avec id_adresse auto-incrémenté)
INSERT INTO adresse (numero_et_voie, code_postal, commune)
VALUES 
    ('3 RUE LEBON', '95000', 'CERGY'),
    ('5 BD DU PORT', '95000', 'CERGY'),
    ('154 AVENUE DE LA REPUBLIQUE', '95600', 'EAUBONNE'),
    ('12 TROU DE LA FOURMILLIERE', '95999', 'FOURMILLIERE');

-- Table Identite
INSERT INTO identite (pseudo, nom, prenom, id_adresse, telephone, email, date_naissance) 
VALUES 
    ('Tibsous', 'TERRIE', 'THIBAULT', 'Addr1', '+33645789125', 'thibault.terrie@etu.cyu.fr', '2001-04-06'),
    ('Redwn', 'TRINH', 'GIATAM', 'Addr2', '+33742168934', 'giatam.trinh@etu.cyu.fr', '1958-03-24'),
    ('el_moroccan_sniper', 'SAIDANE', 'ZAKARIA', 'Addr2', '+33615733127', 'zakaria.saidane@etu.cyu.fr', '2003-01-17'),
    ('mlteacher', 'LEMAIRE', 'Marc', 'Addr3', '+33628990304', 'marc.lemaire@cyu.fr', '1963-08-12'),
    ('f0urmiBaluch0n', 'FOURMI', 'Yves', 'Addr4', '+33699120031', 'fourmi.baluchon@fourmilliere.com', '2023-12-13');

CREATE TABLE utilisateurs (
    id SERIAL PRIMARY KEY,
    pseudo VARCHAR(50) UNIQUE NOT NULL,
    mot_de_passe VARCHAR(255) NOT NULL,
    date_inscription TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (pseudo) REFERENCES identite(pseudo)
);

-- Table Personnel
INSERT INTO personnel (pseudo_personnel, date_embauche_personnel, role_personnel, salaire, status_personnel, conge_date_debut, conge_date_fin) 
VALUES
    ('Redwn', '2024-08-08', 'gestionnaire', 2500.00, 'actif', NULL, NULL),
    ('el_moroccan_sniper', '2024-11-27', 'caissier', 1800.00, 'congé', '2024-11-30', '2025-01-24');

-- Table Joueur
INSERT INTO joueur (pseudo_joueur, date_inscription_joueur, carte_fidelite_id_joueur, points_fidelite_joueur, solde_joueur, pseudo_personnel)
VALUES
    ('mlteacher', '2024-08-12', 'cfst0025', 1249, 53.47, 'Redwn'),
    ('Tibsous', '2024-11-29', 'cfhe0003', 2005, 89.79, 'el_moroccan_sniper'),
    ('f0urmiBaluch0n', '2024-12-01', 'cfop9595', 1, 1.3, 'el_moroccan_sniper');

-- Table Transaction
INSERT INTO transaction (date_transaction, montant_transaction, type_transaction, mode_paiement_transaction, pseudo_joueur)
VALUES
    ('2024-11-30', 10.50, 'achat_jeton', 'carte_bancaire', 'Tibsous'),
    ('2024-12-03', 5.00, 'achat_conso', 'carte_fidelite', 'mlteacher');

-- Table Consommable
INSERT INTO consommable (nom_consommable, prix_consommable, stock_consommable, pseudo_joueur)
VALUES
    ('Coca-Cola', 5.00, 12, 'mlteacher');

-- Table Machine
INSERT INTO machine (nom_machine, emplacement_machine, date_installation_machine, statut_machine, nom_du_sav_machine, numero_du_sav_machine, pseudo_personnel)
VALUES
    ('Borne', 'Accueil', '2024-09-17', 'disponible', 'TechnoSav', '+33612345678', 'Redwn'),
    ('Casque VR', 'Zone 3', '2024-09-19', 'maintenance', 'ServicePlus', '+33798765432', 'Redwn'),
    ('Gameboy', 'Zone 2', '2024-09-27', 'reservee', 'ServicePlus', '+33798765432', 'Redwn');

-- Table Reservation
INSERT INTO reservation (date_debut_reservation, date_fin_reservation, status_reservation, pseudo_joueur, id_machine)
VALUES
    ('2024-09-18 14:30:00', '2024-09-18 17:30:00', 'finie', 'mlteacher', 'Mach1'),
    ('2024-12-18 19:00:00', '2024-06-18 21:00:00', 'a_venir', 'Tibsous', 'Mach2'),
    ('2024-12-01 19:50:00', '2024-12-01 20:50:00', 'en_cours', 'Tibsous', 'Mach3');

-- Table Jeu
INSERT INTO jeu (nom_jeu, categorie_jeu, date_creation_jeu, id_machine)
VALUES
    ('Fifa', 'jeu vidéo', '1993-03-01', 'Mach1'),
    ('Fortnite', 'jeu vidéo', '2017-09-26', 'Mach2'),
    ('Minecraft', 'jeu vidéo', '2009-11-15', 'Mach3');

-- Table Session
INSERT INTO session (id_machine, pseudo_joueur, date_heure_debut, date_heure_fin, score)
VALUES
    ('Mach1', 'Tibsous', '2024-11-30 10:00:00', '2024-11-30 12:00:00', 512);
