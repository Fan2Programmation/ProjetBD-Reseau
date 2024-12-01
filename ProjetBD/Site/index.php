<!DOCTYPE html>
<html lang="fr">
    <?php
        #Table des utilisateurs
        $dict = array(
            #Les mots de passe ont été préalablement cryptés avec password_hash et c'est le même mot de passe pour chacun en fait
            "Tibsous" => '$2y$10$O19hEXipC/SexhTerfpoCOhw6Tq8lTg28zeON1ZsGxp2AuFk2EHEy',
            "Redwn" => '$2y$10$O19hEXipC/SexhTerfpoCOhw6Tq8lTg28zeON1ZsGxp2AuFk2EHEy',
            "el_moroccan_sniper" => '$2y$10$O19hEXipC/SexhTerfpoCOhw6Tq8lTg28zeON1ZsGxp2AuFk2EHEy',
            "mlteacher" => '$2y$10$O19hEXipC/SexhTerfpoCOhw6Tq8lTg28zeON1ZsGxp2AuFk2EHEy'
        );

        #Vérification du pseudo et du mot de passe
        $verification = false;
        if(isset($_POST["pseudo"]) && !empty($_POST["pseudo"]) && isset($_POST["mdp"]) && !empty($_POST["mdp"])){
            $pseudo = $_POST["pseudo"];
            foreach ($dict as $key => $value){
                if($pseudo == $key){
                    $mdp = $_POST["mdp"];
                    $mdp_crypte = $dict[$pseudo];
                    $verification = password_verify($mdp, $mdp_crypte);
                    break;
                }
            }
        }
    ?>

    <head>
        <title>Page de connexion</title>
        <meta charset="utf-8">
        <meta name="titre" content="Arcade à GOGO"/>
        <meta name="description" content="Arcade à GOGO"/>
        <meta name="auteur" content="22302932, zacky, et tibsous"/>
        <meta name="date" content="01/12/2024"/>
        <meta name="lieu" content="CY CERGY PARIS UNIVERSITÉ, 2 Avenue Adolphe Chauvin, 95300 Pontoise"/>
        <link rel="stylesheet" type="text/css" href="styles.css"/>
        <link rel="icon" href="images/favicon.ico"/>
    </head>

    <body>
        <main>
            <h1>Arcade à GOGO</h1>
            <?php
                //Le formulaire par défaut
                if(!isset($_POST["pseudo"]) && !isset($_POST["mdp"])){
                    echo "\t<form action=\"index.php\" method=\"POST\">\n";
                        echo "\t\t\t\t\t<fieldset style=\"display:inline-block;\">\n";
                            echo "\t\t\t\t\t\t<legend>Le meilleur joueur</legend>\n";
                            echo "\t\t\t\t\t\t<div>\n";
                                echo "\t\t\t\t\t\t\t<label for=\"pseudo\">Pseudo</label>\n";
                                echo "\t\t\t\t\t\t\t<input type=\"text\" name=\"pseudo\" id=\"pseudo\"/>\n";
                            echo "\t\t\t\t\t\t</div>\n";
                            echo "\t\t\t\t\t\t<div>\n";
                                echo "\t\t\t\t\t\t\t<label for=\"mdp\">Mot de passe</label>\n";
                                echo "\t\t\t\t\t\t\t<input type=\"password\" name=\"mdp\" id=\"mdp\"/>\n";
                            echo "\t\t\t\t\t\t</div>\n";
                            echo "\t\t\t\t\t\t<div>\n";
                                echo "\t\t\t\t\t\t\t<input type=\"submit\" value=\"Connexion\"/>\n";
                            echo "\t\t\t\t\t\t</div>\n";
                        echo "\t\t\t\t\t</fieldset>\n";
                    echo "\t\t\t\t</form>\n";
                }
                //Après avoir cliqué sur le bouton
                else{
                    //Si l'utilisateur existe et son mot de passe est correcte
                    if($verification){
                        // Connexion à la base de données
                        $dbconn = pg_connect("host=postgresql-arcadeagogo.alwaysdata.net port=5432 user=arcadeagogo password=suprafox77 dbname=arcadeagogo_bd") or die('Could not connect: ' . pg_last_error());
                        
                        //1ère requête SQL : Afficher les informations personnelles du joueur
                        $query = 'SELECT * FROM identite JOIN adresse ON identite.id_adresse=adresse.id_adresse WHERE pseudo LIKE \''.$pseudo.'\'';
                        $result = pg_query($dbconn, $query) or die('Query failed: ' . pg_last_error());
                        //Afficher le résultat
                        echo "\t\t<section>\n";
                            echo "\t\t\t\t\t<h2>Vos informations personnelles</h2>\n";   
                                echo "\t\t\t\t\t\t<ul>\n";
                                while ($line = pg_fetch_object($result)) {
                                    echo "\t\t\t\t\t\t\t<li>Nom : ".$line->nom."</li>\n";
                                    echo "\t\t\t\t\t\t\t<li>Prénom : ".$line->prenom."</li>\n";
                                    echo "\t\t\t\t\t\t\t<li>Adresse : ".$line->numero_et_voie.", ".$line->code_postal." ".$line->commune."</li>\n";
                                    echo "\t\t\t\t\t\t\t<li>Téléphone : ".$line->telephone."</li>\n";
                                    echo "\t\t\t\t\t\t\t<li>Email : ".$line->email."</li>\n";
                                    echo "\t\t\t\t\t\t\t<li>Date de naissance : ".$line->date_naissance."</li>\n";
                                }
                                echo "\t\t\t\t\t\t</ul>\n";
                        echo "\t\t\t\t</section>\n";
                        //Se séparer du résultat
                        pg_free_result($result);

                        //2nde requête SQL : Afficher les informations générales du joueur
                        $query = 'SELECT * FROM joueur WHERE pseudo_joueur LIKE \''.$pseudo.'\'';
                        $result = pg_query($dbconn, $query) or die('Query failed: ' . pg_last_error());
                        //Afficher le résultat
                        echo "\t\t<section>\n";
                            echo "\t\t\t\t\t<h2>Vos informations en tant que joueur</h2>\n";   
                                echo "\t\t\t\t\t\t<ul>\n";
                                while ($line = pg_fetch_object($result)) {
                                    echo "\t\t\t\t\t\t\t<li>Pseudo : ".$line->pseudo_joueur."</li>\n";
                                    echo "\t\t\t\t\t\t\t<li>Date d'inscription : ".$line->date_inscription_joueur."</li>\n";
                                    echo "\t\t\t\t\t\t\t<li>Carte de fidélité numéro : ".$line->carte_fidelite_id_joueur."</li>\n";
                                    echo "\t\t\t\t\t\t\t<li>Points de fidélité : ".$line->points_fidelite_joueur."</li>\n";
                                    echo "\t\t\t\t\t\t\t<li>Solde : ".$line->solde_joueur."</li>\n";
                                }
                                echo "\t\t\t\t\t\t</ul>\n";
                        echo "\t\t\t\t</section>\n";
                        //Se séparer du résultat
                        pg_free_result($result);

                        //3ème requête SQL : Afficher les réservations actives du joueur
                        $query = 'SELECT id_reservation, date_debut_reservation, date_fin_reservation, status_reservation
                            FROM reservation
                            WHERE pseudo_joueur = \''.$pseudo.'\'
                            AND status_reservation IN (\'en_attente\', \'confirmee\');';
                        $result = pg_query($dbconn, $query) or die('Query failed: ' . pg_last_error());
                        //Afficher le résultat
                        echo "\t\t\t\t<section>\n";
                            echo "\t\t\t\t\t<h2>Vos réservations pour s'entrainer</h2>\n";   
                                $i = 1;
                                while ($line = pg_fetch_object($result)) {
                                    echo "\t\t\t\t\t\t<article>\n";
                                        echo "\t\t\t\t\t\t\t<h3>Réservation ".$i."</h3>\n";
                                            echo "\t\t\t\t\t\t\t\t<ul>\n";
                                                echo "\t\t\t\t\t\t\t\t<li>Réservation : ".$line->id_reservation."</li>\n";
                                                echo "\t\t\t\t\t\t\t\t<li>Début de la réservation : ".$line->date_debut_reservation."</li>\n";
                                                echo "\t\t\t\t\t\t\t\t<li>Fin de la réservation : ".$line->date_fin_reservation."</li>\n";
                                                echo "\t\t\t\t\t\t\t\t<li>Statut : ".$line->status_reservation."</li>\n";
                                            echo "\t\t\t\t\t\t\t\t</ul>\n";
                                    echo "\t\t\t\t\t\t</article>\n";
                                    $i = $i +1;
                                }        
                        echo "\t\t\t\t</section>\n";
                        //Se séparer du résultat
                        pg_free_result($result);

                        //4ème requête SQL : Afficher les machines disponibles
                        $query = 'SELECT id_machine, nom_machine
                            FROM machine
                            WHERE statut_machine = \'disponible\'';
                        $result = pg_query($dbconn, $query) or die('Query failed: ' . pg_last_error());
                        //Afficher le résultat
                        echo "\t\t\t\t<section>\n";
                            echo "\t\t\t\t\t<h2>Les bornes d'arcades disponibles à essayer</h2>\n";   
                                echo "\t\t\t\t\t\t<ul>\n";
                                while ($line = pg_fetch_object($result)) {
                                    echo "\t\t\t\t\t\t\t<li>".$line->nom_machine." ".$line->id_machine."</li>\n";
                                }
                                echo "\t\t\t\t\t\t</ul>\n";       
                        echo "\t\t\t\t</section>\n";
                        //Se séparer du résultat
                        pg_free_result($result);

                        //5ème requête SQL : Afficher le meilleur score de chaque joueur
                        $query = 'SELECT pseudo_joueur, MAX(score) AS meilleur_score FROM session GROUP BY pseudo_joueur ORDER BY meilleur_score DESC LIMIT 10';
                        $result = pg_query($dbconn, $query) or die('Query failed: ' . pg_last_error());
                        //Afficher le résultat
                        echo "\t\t\t\t<section>\n";
                            echo "\t\t\t\t\t<h2>Le meilleur score de chaque joueur à battre</h2>\n";   
                                echo "\t\t\t\t\t\t<ul>\n";
                                while ($line = pg_fetch_object($result)) {
                                    echo "\t\t\t\t\t\t\t<li>".$line->pseudo_joueur." : ".$line->meilleur_score."</li>\n";
                                }
                                echo "\t\t\t\t\t\t</ul>\n";
                        echo "\t\t\t\t</section>\n";
                        //Se séparer du résultat
                        pg_free_result($result);

                        //Déconnexion
                        pg_close($dbconn);
                    }
                    //Sinon retour au formulaire avec un message d'erreur
                    else{
                        echo "\t<form action=\"index.php\" method=\"POST\">\n";
                        echo "\t\t\t\t\t<fieldset style=\"display:inline-block;\">\n";
                            echo "\t\t\t\t\t\t<legend>Le meilleur joueur</legend>\n";
                            echo "\t\t\t\t\t\t<div>\n";
                                echo "\t\t\t\t\t\t\t<label for=\"erreur\">Pseudo/mot de passe érroné</label>\n";
                            echo "\t\t\t\t\t\t</div>\n";
                            echo "\t\t\t\t\t\t<div>\n";
                                echo "\t\t\t\t\t\t\t<label for=\"pseudo\">Pseudo</label>\n";
                                echo "\t\t\t\t\t\t\t<input type=\"text\" name=\"pseudo\" id=\"pseudo\"/>\n";
                            echo "\t\t\t\t\t\t</div>\n";
                            echo "\t\t\t\t\t\t<div>\n";
                                echo "\t\t\t\t\t\t\t<label for=\"mdp\">Mot de passe</label>\n";
                                echo "\t\t\t\t\t\t\t<input type=\"password\" name=\"mdp\" id=\"mdp\"/>\n";
                            echo "\t\t\t\t\t\t</div>\n";
                            echo "\t\t\t\t\t\t<div>\n";
                                echo "\t\t\t\t\t\t\t<input type=\"submit\" value=\"Connexion\"/>\n";
                            echo "\t\t\t\t\t\t</div>\n";
                        echo "\t\t\t\t\t</fieldset>\n";
                    echo "\t\t\t\t</form>\n";
                    }

                }
            ?>
        </main>
    </body>

</html>