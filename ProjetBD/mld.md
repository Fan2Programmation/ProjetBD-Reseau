<b>Identite</b> (<u>pseudo</u>, nom, prenom, #id_adresse, telephone, email, date_naissance)

<b>Personnel</b> (<u>#pseudo_personnel</u>, date_embauche_personnel, role_personnel, salaire, status_personnel, conge_date_debut, conge_date_fin)

<b>Joueur</b> (<u>#pseudo_joueur</u>, date_inscription_joueur, carte_fidelite_id_joueur, points_fidelite_joueur, solde_joueur, #pseudo_personnel)

<b>Adresse</b> (<u>id_adresse</u>, numero_et_voie, code_postal, commune, #pseudo)

<b>Transaction</b> (<u>id_transaction</u>, date_transaction, montant_transaction, type_transaction, mode_paiement_transaction, #pseudo_joueur)

<b>Consommable</b> (<u>id_consommable</u>, nom_consommable, prix_consommable, stock_consommable, #pseudo_joueur)

<b>Reservation</b> (<u>id_reservation</u>, date_reservation, status_reservation, #pseudo_joueur) 

<b>Machine</b> (<u>id_machine</u>, nom_machine, emplacement_machine, date_installation_machine, statut_machine, nom_du_sav_machine, numero_du_sav_machine, #pseudo_personnel, #id_reservation)

<b>Jeu</b> (<u>id_jeu</u>, nom_jeu, categorie_jeu, date_creation_jeu, meilleur_score, #id_machine) 

<b>est_classé</b> (<u>#id_jeu</u>, <u>#pseudo_joueur</u>, position)

<b>Session_Jeu</b> (<u>id_session</u>, date_session, score, #id_jeu)

<b>joue</b> (<u>#id_session</u>, <u>#pseudo_joueur</u>) 