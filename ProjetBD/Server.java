import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.ArrayList;
import java.util.Iterator;

public class Server {

    private static final int PORT = 8080;

    public static void main(String[] args) {
        try {
            ServerSocket serverSocket = new ServerSocket(PORT);
            System.out.println("Serveur en attente de connexion...");
            Socket clientSocket = serverSocket.accept();
            System.out.println("Client connecté.");
            BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
            ArrayList<String> lignesRecues = new ArrayList<String>();

            // On remplit une ArrayList avec toutes les lignes envoyées par le client
            while (true) {
                String line = in.readLine();
                if(line.isEmpty())
                    break;
                lignesRecues.add(line);
            }

            // On ouvre le canal de sortie 
            PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true);

            // On affiche toutes ces lignes au client en retour
            for(Iterator<String> it = lignesRecues.iterator() ; it.hasNext() ; ) {
                String ligne = it.next();
                out.println(ligne);
            }

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

    // Méthode pour valider l'identifiant de réservation (ex: Res1234)
    private static boolean isValidReservationId(String reservationId) {
        return reservationId.matches("^Res\\d{4}$");
    }
}