import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;

public class Server {

    private static final int PORT = 8080;

    public static void main(String[] args) {
        try (ServerSocket serverSocket = new ServerSocket(PORT)) {
            System.out.println("Serveur en attente de connexion...");

            while (true) {
                Socket clientSocket = serverSocket.accept();
                System.out.println("Client connecté.");

                // Création du flux d'entrée et de sortie
                try (BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
                     PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true)) {

                    // Traitement du numéro d'abonné
                    String subscriberNumber = in.readLine();
                    if (isValidSubscriberNumber(subscriberNumber)) {
                        out.println("400 SUBSCRIBER_FORMAT_OK");
                    } else {
                        out.println("401 SUBSCRIBER_FORMAT_KO");
                        continue;
                    }

                    // Traitement de l'identifiant de la machine
                    String machineId = in.readLine();
                    if (isValidMachineId(machineId)) {
                        out.println("400 MACHINE_FORMAT_OK");
                        // Pour l'instant on simule une machine disponible
                        out.println("MACHINE_AVAILABLE");
                    } else {
                        out.println("401 MACHINE_FORMAT_KO");
                        continue;
                    }

                    // Si la machine est réservée, on attend l'identifiant de réservation
                    String reservationId = in.readLine();
                    if (isValidReservationId(reservationId)) {
                        out.println("400 RESERVATION_FORMAT_OK");
                        // Simulons que la réservation appartient bien au joueur
                        out.println("RESERVATION_OK");
                    } else {
                        out.println("401 RESERVATION_FORMAT_KO");
                        continue;
                    }

                    // Détection d'une action de jeu
                    String action = in.readLine();
                    if ("PLAY_3_CREDITS".equals(action)) {
                        // Pour l'instant, on simule simplement la décrémentation des crédits
                        out.println("CREDITS_DECREMENTED");
                    }

                } catch (IOException e) {
                    System.err.println("Erreur lors de la communication avec le client : " + e.getMessage());
                }
            }

        } catch (IOException e) {
            System.err.println("Erreur de démarrage du serveur : " + e.getMessage());
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

    // Méthode pour valider l'identifiant de réservation (ex: Res1234)
    private static boolean isValidReservationId(String reservationId) {
        return reservationId.matches("^Res\\d{4}$");
    }
}