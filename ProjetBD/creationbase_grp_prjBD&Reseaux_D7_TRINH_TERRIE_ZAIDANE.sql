-- Créer les séquences
CREATE SEQUENCE addr_seq
    START 1
    INCREMENT 1
    MINVALUE 1
    MAXVALUE 999999
    CACHE 1;

CREATE SEQUENCE tran_seq
    START 1
    INCREMENT 1
    MINVALUE 1
    MAXVALUE 999999
    CACHE 1;

CREATE SEQUENCE cons_seq
    START 1
    INCREMENT 1
    MINVALUE 1
    MAXVALUE 999999
    CACHE 1;

CREATE SEQUENCE res_seq
    START 1
    INCREMENT 1
    MINVALUE 1
    MAXVALUE 999999
    CACHE 1;

CREATE SEQUENCE mach_seq
    START 1
    INCREMENT 1
    MINVALUE 1
    MAXVALUE 999999
    CACHE 1;

CREATE SEQUENCE jeu_seq
    START 1
    INCREMENT 1
    MINVALUE 1
    MAXVALUE 999999
    CACHE 1;

CREATE SEQUENCE sess_seq
    START 1
    INCREMENT 1
    MINVALUE 1
    MAXVALUE 999999
    CACHE 1;

-- Table Adresse
CREATE TABLE adresse (
    id_adresse VARCHAR(6) PRIMARY KEY DEFAULT 'Addr' || nextval('addr_seq'),
    numero_et_voie VARCHAR(100) NOT NULL CHECK (numero_et_voie ~ '^[0-9]+[a-zA-Z\s]+$'),
    code_postal VARCHAR(5) NOT NULL CHECK (code_postal ~ '^[0-9]{5}$'),
    commune VARCHAR(50) NOT NULL CHECK (commune ~ '^[a-zA-Z\s]+$')
);

-- Table Identite
CREATE TABLE identite (
    pseudo VARCHAR(27) PRIMARY KEY,
    nom VARCHAR(50) NOT NULL CHECK (nom ~ '^[A-Za-z]+$'),
    prenom VARCHAR(50) NOT NULL CHECK (prenom ~ '^[A-Za-z]+$'),
    id_adresse VARCHAR(6) NOT NULL,
    telephone VARCHAR(15) UNIQUE NOT NULL CHECK (telephone ~ '^\+?[0-9]+$'),  -- Téléphone avec format spécifique
    email VARCHAR(255) UNIQUE NOT NULL CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),  -- Format email valide
    date_naissance DATE NOT NULL CHECK (date_naissance < CURRENT_DATE),
    FOREIGN KEY (id_adresse) REFERENCES adresse(id_adresse)
);

-- Table Utilisateurs
CREATE TABLE utilisateurs (
    pseudo VARCHAR(27) PRIMARY KEY UNIQUE NOT NULL,
    mot_de_passe VARCHAR(255) NOT NULL,
    date_inscription TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (pseudo) REFERENCES identite(pseudo) ON DELETE CASCADE
);


-- Table Personnel
CREATE TABLE personnel (
    pseudo_personnel VARCHAR(27) PRIMARY KEY,
    date_embauche_personnel DATE NOT NULL CHECK (date_embauche_personnel <= CURRENT_DATE), -- Date d'embauche <= TODAY()
    role_personnel VARCHAR(27) NOT NULL CHECK (role_personnel IN ('gestionnaire', 'technicien', 'caissier')),
    salaire FLOAT NOT NULL CHECK (salaire >= 0),
    status_personnel VARCHAR(27) NOT NULL CHECK (status_personnel IN ('actif', 'congé', 'démission')),
    conge_date_debut DATE,
    conge_date_fin DATE,
    FOREIGN KEY (pseudo_personnel) REFERENCES identite(pseudo) ON DELETE CASCADE
);

-- Table Joueur
CREATE TABLE joueur (
    pseudo_joueur VARCHAR(27) PRIMARY KEY UNIQUE NOT NULL,
    date_inscription_joueur DATE NOT NULL DEFAULT CURRENT_DATE, -- Valeur par défaut = today()
    carte_fidelite_id_joueur VARCHAR(20) UNIQUE,
    points_fidelite_joueur INT NOT NULL DEFAULT 0 CHECK (points_fidelite_joueur >= 0),
    solde_joueur FLOAT NOT NULL DEFAULT 0.00 CHECK (solde_joueur >= 0),
    pseudo_personnel VARCHAR(27) NOT NULL,
    FOREIGN KEY (pseudo_personnel) REFERENCES personnel(pseudo_personnel) ON DELETE CASCADE,
    FOREIGN KEY (pseudo_joueur) REFERENCES identite(pseudo) ON DELETE CASCADE
);

-- Table Transaction
CREATE TABLE transaction (
    id_transaction VARCHAR(5) PRIMARY KEY DEFAULT 'Tran' || nextval('tran_seq'),
    date_transaction DATE NOT NULL DEFAULT CURRENT_DATE,
    montant_transaction FLOAT NOT NULL CHECK (montant_transaction > 0),
    type_transaction VARCHAR(25) NOT NULL CHECK (type_transaction IN ('achat_jeton', 'achat_conso')),
    mode_paiement_transaction VARCHAR(25) NOT NULL CHECK (mode_paiement_transaction IN ('carte_bancaire', 'carte_fidelite', 'espece')),
    pseudo_joueur VARCHAR(27) NOT NULL,
    FOREIGN KEY (pseudo_joueur) REFERENCES joueur(pseudo_joueur) ON DELETE CASCADE
);

-- Table Consommable
CREATE TABLE consommable (
    id_consommable VARCHAR(6) PRIMARY KEY DEFAULT 'Cons' || nextval('cons_seq'),
    nom_consommable VARCHAR(50) NOT NULL,
    prix_consommable FLOAT NOT NULL CHECK (prix_consommable >= 0),
    stock_consommable INT NOT NULL CHECK (stock_consommable >= 0),
    pseudo_joueur VARCHAR(27) NOT NULL,
    FOREIGN KEY (pseudo_joueur) REFERENCES joueur(pseudo_joueur) ON DELETE CASCADE
);

-- Table Reservation
CREATE TABLE reservation (
    id_reservation VARCHAR(7) PRIMARY KEY DEFAULT 'Res' || nextval('res_seq'),
    date_debut_reservation DATE NOT NULL,
    date_fin_reservation DATE NOT NULL,
    status_reservation VARCHAR(27) NOT NULL CHECK (status_reservation IN ('a_venir', 'en_cours', 'finie')),
    pseudo_joueur VARCHAR(27) NOT NULL,
    id_machine VARCHAR(8) NOT NULL,
    FOREIGN KEY (pseudo_joueur) REFERENCES joueur(pseudo_joueur) ON DELETE CASCADE
);

-- Table Machine
CREATE TABLE machine (
    id_machine VARCHAR(8) PRIMARY KEY DEFAULT 'Mach' || nextval('mach_seq'),
    nom_machine VARCHAR(100) NOT NULL,
    emplacement_machine VARCHAR(50) NOT NULL,
    date_installation_machine DATE NOT NULL,
    statut_machine VARCHAR(50) NOT NULL CHECK (statut_machine IN ('disponible', 'maintenance', 'hors-service', 'occupee', 'reservee')),
    nom_du_sav_machine VARCHAR(50) NOT NULL,
    numero_du_sav_machine VARCHAR(15) NOT NULL CHECK (numero_du_sav_machine ~ '^\+?[0-9]+$'),
    pseudo_personnel VARCHAR(27) NOT NULL,
    id_reservation VARCHAR(7),
    FOREIGN KEY (pseudo_personnel) REFERENCES personnel(pseudo_personnel) ON DELETE CASCADE,
    FOREIGN KEY (id_reservation) REFERENCES reservation(id_reservation) ON DELETE SET NULL
);

-- Table Jeu
CREATE TABLE jeu (
    id_jeu VARCHAR(9) PRIMARY KEY DEFAULT 'Jeu' || nextval('jeu_seq'),
    nom_jeu VARCHAR(100) NOT NULL,
    categorie_jeu VARCHAR(27) NOT NULL,
    date_creation_jeu DATE NOT NULL CHECK (date_creation_jeu <= CURRENT_DATE),
    meilleur_score INT DEFAULT 0,
    id_machine VARCHAR(8) NOT NULL,
    FOREIGN KEY (id_machine) REFERENCES machine(id_machine) ON DELETE CASCADE
);

-- Table Est_classé
CREATE TABLE est_classe (
    id_jeu VARCHAR(9) NOT NULL,
    pseudo_joueur VARCHAR(27) NOT NULL,
    position INT NOT NULL,
    PRIMARY KEY (id_jeu, pseudo_joueur),
    FOREIGN KEY (id_jeu) REFERENCES jeu(id_jeu) ON DELETE CASCADE,
    FOREIGN KEY (pseudo_joueur) REFERENCES joueur(pseudo_joueur) ON DELETE CASCADE
);

-- Table Session
CREATE TABLE session (
    id_session VARCHAR(8) PRIMARY KEY DEFAULT 'Sess' || nextval('sess_seq'),
    id_machine VARCHAR(8) NOT NULL,
    pseudo_joueur VARCHAR(27) NOT NULL,
    date_heure_debut TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_heure_fin TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    score INT NOT NULL DEFAULT 0 CHECK (score >= 0),
    FOREIGN KEY (id_machine) REFERENCES machine(id_machine) ON DELETE CASCADE,
    FOREIGN KEY (pseudo_joueur) REFERENCES joueur(pseudo_joueur) ON DELETE CASCADE
);

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
