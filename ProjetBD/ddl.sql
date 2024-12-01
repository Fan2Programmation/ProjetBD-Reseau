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