import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Locale;

public class Server {

    private static final int PORT = 8080;

    public static void main(String[] args) {
        try {
            ServerSocket serverSocket = new ServerSocket(PORT);
            System.out.println("Serveur en attente de connexion...");
            Socket clientSocket = serverSocket.accept();
            System.out.println("Client connecte.");
            BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
            PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true);
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
                out.close();
                in.close();
                clientSocket.close();
                serverSocket.close();
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

            // Préparer la réponse en fonction des validations
            StringBuilder response = new StringBuilder();
            response.append("ARKD/1.1 200 OK\n");
            response.append("Date: ").append(getServerTime()).append("\n");

            // Vérifier et ajouter le statut de la machine
            if (machineId != null && isValidMachineId(machineId)) {
                response.append("Machine: 300 MACHINE_FORMAT_OK\n");
            } else {
                response.append("Machine: 301 MACHINE_FORMAT_INVALID\n");
            }

            // Vérifier et ajouter le statut de l'abonnement
            if (abonnementId != null && isValidSubscriberNumber(abonnementId)) {
                response.append("Abonnement: 300 ABONNEMENT_FORMAT_OK\n");
                // Supposons ici que l'abonnement est toujours valide
                response.append("Abonnement: 600 ABONNEMENT_VALIDE\n");
            } else {
                response.append("Abonnement: 301 ABONNEMENT_FORMAT_INVALID\n");
                response.append("Abonnement: 601 ABONNEMENT_INVALIDE\n");
            }

            // Ajouter un statut de réservation générique (à adapter selon votre logique)
            response.append("Reservation: 400 NO_RESERVATION\n");

            // Ajouter un statut d'accès générique (à adapter selon votre logique)
            response.append("Access: 500 ACCESS_GRANTED\n");

            // Envoi de la réponse au client
            out.println(response.toString());

            // On referme tout
            out.close();
            in.close();
            clientSocket.close();
            serverSocket.close();

        } catch (IOException e) {
            System.err.println(e.getMessage());
        }
    }

    // Méthode pour valider le numéro d'abonné (ex: Abo12345)
    private static boolean isValidSubscriberNumber(String number) {
        return number.matches("^Abo\\d{5}$");
    }

    // Méthode pour valider l'identifiant de machine (ex: Mach1234)
    private static boolean isValidMachineId(String machineId) {
        return machineId.matches("^Mach\\d{4}$");
    }

    // Méthode utilitaire pour obtenir la date et l'heure actuelle du serveur au format GMT
    private static String getServerTime() {
        SimpleDateFormat dateFormat = new SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss z", Locale.ENGLISH);
        dateFormat.setTimeZone(java.util.TimeZone.getTimeZone("GMT"));
        return dateFormat.format(new Date());
    }
}
