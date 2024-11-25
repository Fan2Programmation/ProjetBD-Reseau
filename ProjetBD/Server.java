import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Locale;

// Dans PowerShell sur Windows :
// javac -cp postgresql-42.7.4.jar Server.java
// java -cp ".;postgresql-42.7.4.jar" Server

public class Server {

    private static final int PORT = 420;
    private static ServerSocket serverSocket;
    private static Socket clientSocket;
    private static BufferedReader in;
    private static PrintWriter out;
    private static StringBuilder response;

    // Partie informations relatives à la base de donnée "arcade" (version intranet)
    private static final String DB_PORT = "5432";
    private static final String DB_IP = "devwebdb2.etu";
    private static final String DB_NAME = "db24l3i_tterrie";
    private static final String DB_USER = "y24l3i_tterrie";
    private static final String DB_PASSWORD = "A123456*";
    private static final String DB_URL = "jdbc:postgresql://" + DB_IP + ":" + DB_PORT + "/" + DB_NAME;

    // // Partie informations relatives à la base de donnée "arcade" (version à la maison)
    // private static final String DB_PORT = "5432";
    // private static final String DB_IP = "localhost";
    // private static final String DB_NAME = "arcade";
    // private static final String DB_USER = "etu";
    // private static final String DB_PASSWORD = "A123456*";
    // private static final String DB_URL = "jdbc:postgresql://" + DB_IP + ":" + DB_PORT + "/" + DB_NAME;

    private static Connection connection;
    private static Statement statement;
    private static ResultSet resultSet;

    public static void main(String[] args) {
        try {
            serverSocket = new ServerSocket(PORT);
            System.out.println("Serveur en attente de connexion...");
            clientSocket = serverSocket.accept();
            System.out.println("Client connecte.");

            // Initialisation de notre support de reponse
            response = new StringBuilder();

            connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            System.out.println("Connexion a la base de donnees reussie.");
            statement = connection.createStatement();

            in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
            out = new PrintWriter(clientSocket.getOutputStream(), true);
            ArrayList<String> lignesRecues = new ArrayList<>();

            // On remplit une ArrayList avec toutes les lignes envoyées par le client
            while (true) {
                String line = in.readLine();
                if (line == null || line.isEmpty()) { // Fin de l'envoi des lignes
                    break;
                }
                lignesRecues.add(line);
            }

            // Vérifier que la première ligne est bien "GET / ARKD/1.1"
            if (lignesRecues.isEmpty() || !lignesRecues.get(0).equals("GET / ARKD/1.1")) {
                // Si la ligne de requête n'est pas correcte, on envoie une erreur au client
                out.println("ARKD/1.1 400 BAD REQUEST");
                closeEverything();
                return;
            }

            // Variables pour stocker les informations extraites
            String machineId = null;
            String abonnementId = null;

            // On lit chaque ligne pour extraire les informations
            for (String ligne : lignesRecues) {
                if (ligne.startsWith("Machine: ")) {
                    machineId = ligne.substring(9).trim(); // Récupération de l'ID de la machine
                } else if (ligne.startsWith("Abonnement: ")) {
                    abonnementId = ligne.substring(12).trim(); // Récupération de l'ID d'abonnement
                }
            }

            response.append("ARKD/1.1 200 OK\n");
            response.append("Date: ").append(getServerTime()).append("\n");

            if (machineId != null && isValidMachineId(machineId)) {
                response.append("Machine: 300 MACHINE_FORMAT_OK\n");
            } else {
                response.append("Machine: 301 MACHINE_FORMAT_INVALID\n");
            }

            if (abonnementId != null && isValidSubscriberNumber(abonnementId)) {
                response.append("Abonnement: 300 ABONNEMENT_FORMAT_OK\n");

                // On construit la requête pour voir si le numero abo existe dans la DB
                resultSet = statement.executeQuery("SELECT numero_abonnement FROM Joueur;");
                boolean correspondance = false;
                while(resultSet.next()) {
                    String numeroAbonnement = resultSet.getString("numero_abonnement");
                    if(numeroAbonnement.equals(abonnementId)) {
                        correspondance = true;
                        break;
                    }
                }

                if(correspondance) {
                    response.append("Abonnement: 350 ABONNEMENT_EXISTANT");
                }
                else {
                    response.append("Abonnement: 351 ABONNEMENT_INEXISTANT");
                }

            } else {
                response.append("Abonnement: 301 ABONNEMENT_FORMAT_INVALID\n");
            }

            sendResponse();
            closeEverything();

        } catch (IOException e) {
            System.err.println("Probleme de lecture ou d'ecriture : " + e.getMessage());
            out.append("Une erreur a été rencontree, contactez l'administrateur du serveur.");
            sendResponse();
            closeEverything();
        } catch (SQLException e1) {
            System.err.println("Probleme de connexion a la base de donnee : " + e1.getMessage());
            out.append("Erreur de connexion a la base de donnee, contactez l'administrateur du serveur.");
            sendResponse();
            closeEverything();
        }
    }

    // Méthode pour valider le format du numéro d'abonné (ex: Abo12345)
    private static boolean isValidSubscriberNumber(String number) {
        return number.matches("^Abo\\d{5}$");
    }

    // Méthode pour valider le format de l'identifiant de machine (ex: Mach1234)
    private static boolean isValidMachineId(String machineId) {
        return machineId.matches("^Mach\\d{4}$");
    }

    // Méthode pour obtenir la date et l'heure actuelle du serveur au format GMT
    private static String getServerTime() {
        SimpleDateFormat dateFormat = new SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss z", Locale.ENGLISH);
        dateFormat.setTimeZone(java.util.TimeZone.getTimeZone("GMT"));
        return dateFormat.format(new Date());
    }

    // Méthode pour fermer tout ce qu'on à ouvert
    private static void closeEverything() {
        try {
            out.close();
            in.close();
            clientSocket.close();
            serverSocket.close();
        } catch (IOException e) {
            System.err.println("Probleme de fermeture : " + e.getMessage());
        }
    }

    // Méthode pour envoyer simplement la réponse au client
    private static void sendResponse() {
        // Envoi de la réponse au client
        out.println(response.toString());
    }
}
