import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;
import java.sql.*;

public class Server {

    private static final int PORT = 420;
    private static ServerSocket serverSocket;
    private static Socket clientSocket;
    private static BufferedReader in;
    private static PrintWriter out;

    // Informations de connexion à la base de données
    private static final String DB_PORT = "5432";
    private static final String DB_IP = "localhost";
    private static final String DB_NAME = "arcade";
    private static final String DB_USER = "etu";
    private static final String DB_PASSWORD = "A123456*";
    private static final String DB_URL = "jdbc:postgresql://" + DB_IP + ":" + DB_PORT + "/" + DB_NAME;

    private static Connection connection;

    public static void main(String[] args) {
        try {
            // Initialisation du serveur
            serverSocket = new ServerSocket(PORT);
            System.out.println("Serveur en attente de connexion...");

            while (true) {
                clientSocket = serverSocket.accept();
                System.out.println("Client connecte.");

                // Initialisation des flux
                in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
                out = new PrintWriter(clientSocket.getOutputStream(), true);

                // Connexion à la base de données
                connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                System.out.println("Connexion a la base de donnees reussie.");

                // Gestion de l'interaction avec le client
                handleClient();

                // Fermeture des ressources
                closeEverything();
            }
        } catch (IOException | SQLException e) {
            e.printStackTrace();
            closeEverything();
        }
    }

    private static void handleClient() throws IOException, SQLException {
        // Envoi du message de bienvenue
        out.println("Bienvenue dans ARKD1.1, commencez par ecrire le pseudo du joueur, puis entrez l'identifiant de la machine, puis acceptez, ou non, le paiement. Have fun !");

        // Étape 1: Récupération du username
        String username = in.readLine();
        if (username == null || username.isEmpty()) {
            out.println("400 Invalid username");
            closeEverything();
        }

        // Vérification du username dans la base de données
        if (!isValidUsername(username)) {
            out.println("401 Invalid username");
            closeEverything();
        } else {
            out.println("200 Username valid");
        }

        // Étape 2: Récupération de l'identifiant de la machine
        String machineId = in.readLine();
        if (machineId == null || machineId.isEmpty()) {
            out.println("402 Invalid machine ID");
            closeEverything();
        }

        // Vérification du format de l'identifiant de la machine
        if (!isValidMachineFormat(machineId)) {
            out.println("403 Invalid machine ID format");
            closeEverything();
        } else {
            out.println("201 Machine ID format valid");
        }

        // Vérification de l'existence de la machine
        if (!machineExists(machineId)) {
            out.println("404 Machine ID does not exist");
            closeEverything();
        } else {
            out.println("202 Machine ID exists");
        }

        // Vérification du statut de la machine
        String machineStatus = getMachineStatus(machineId);
        switch (machineStatus) {
            case "disponible":
                out.println("203 Machine available");
                // On continue
                break;
            case "maintenance":
            case "hors-service":
                out.println("405 Machine not available");
                closeEverything();
            case "reservee":
                // Vérifier si la réservation est pour ce joueur
                if (isMachineReservedForUser(machineId, username)) {
                    out.println("204 Machine reserved for you");
                    // On continue
                    break;
                } else {
                    out.println("406 Machine reserved for another user");
                    closeEverything();
                }
            default:
                out.println("407 Unknown machine status");
                closeEverything();
        }

        // Étape 3: Demande de paiement
        out.println("Souhaitez-vous payer 5 crédits pour 1 heure de jeu ? Y/n");
        String paymentResponse = in.readLine();
        if (paymentResponse == null || paymentResponse.equalsIgnoreCase("n")) {
            out.println("408 Payment declined");
            closeEverything();
        } else if (paymentResponse.equalsIgnoreCase("Y")) {
            // Vérification du solde du joueur
            if (hasEnoughCredits(username, 5)) {
                // Décrémenter les crédits du joueur
                decrementCredits(username, 5);
                // Ajouter une session de jeu
                addGameSession(username, machineId, 1); // 1 heure de jeu
                out.println("200 Payment successful. Amusez-vous bien!");
            } else {
                out.println("409 Insufficient credits");
                return;
            }
        } else {
            out.println("410 Invalid payment response");
            closeEverything();;
        }
    }

    // Méthode pour vérifier si le username existe dans la base de données
    private static boolean isValidUsername(String username) throws SQLException {
        String query = "SELECT pseudo_joueur FROM joueur WHERE pseudo_joueur = ?";
        try (PreparedStatement ps = connection.prepareStatement(query)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    // Méthode pour vérifier le format de l'identifiant de la machine
    private static boolean isValidMachineFormat(String machineId) {
        return machineId.matches("^Mach\\d+$");
    }

    // Méthode pour vérifier si la machine existe
    private static boolean machineExists(String machineId) throws SQLException {
        String query = "SELECT id_machine FROM machine WHERE id_machine = ?";
        try (PreparedStatement ps = connection.prepareStatement(query)) {
            ps.setString(1, machineId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    // Méthode pour obtenir le statut de la machine
    private static String getMachineStatus(String machineId) throws SQLException {
        String query = "SELECT statut_machine FROM machine WHERE id_machine = ?";
        try (PreparedStatement ps = connection.prepareStatement(query)) {
            ps.setString(1, machineId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("statut_machine");
                }
            }
        }
        return "";
    }

    // Méthode pour vérifier si la machine réservée est pour le joueur
    private static boolean isMachineReservedForUser(String machineId, String username) throws SQLException {
        String query = "SELECT pseudo_joueur FROM reservation WHERE id_machine = ? AND status_reservation = 'reservee'";
        try (PreparedStatement ps = connection.prepareStatement(query)) {
            ps.setString(1, machineId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String reservedUsername = rs.getString("pseudo_joueur");
                    return reservedUsername.equals(username);
                }
            }
        }
        return false;
    }

    // Méthode pour vérifier si le joueur a assez de crédits
    private static boolean hasEnoughCredits(String username, int requiredCredits) throws SQLException {
        String query = "SELECT solde_joueur FROM joueur WHERE pseudo_joueur = ?";
        try (PreparedStatement ps = connection.prepareStatement(query)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    double solde = rs.getDouble("solde_joueur");
                    return solde >= requiredCredits;
                }
            }
        }
        return false;
    }

    // Méthode pour décrémenter les crédits du joueur
    private static void decrementCredits(String username, int amount) throws SQLException {
        String query = "UPDATE joueur SET solde_joueur = solde_joueur - ? WHERE pseudo_joueur = ?";
        try (PreparedStatement ps = connection.prepareStatement(query)) {
            ps.setInt(1, amount);
            ps.setString(2, username);
            ps.executeUpdate();
        }
    }

    // Méthode pour ajouter une session de jeu
    private static void addGameSession(String username, String machineId, int durationHours) throws SQLException {
        String query = "INSERT INTO session (id_machine, pseudo_joueur, date_heure_debut, date_heure_fin, score) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(query)) {
            Timestamp startTime = new Timestamp(System.currentTimeMillis());
            Timestamp endTime = new Timestamp(System.currentTimeMillis() + durationHours * 3600 * 1000);

            ps.setString(1, machineId);
            ps.setString(2, username);
            ps.setTimestamp(3, startTime);
            ps.setTimestamp(4, endTime);
            ps.setInt(5, 0); // Score initial

            ps.executeUpdate();
        }
    }

    // Méthode pour fermer les ressources
    private static void closeEverything() {
        try {
            if (out != null) out.close();
            if (in != null) in.close();
            if (clientSocket != null) clientSocket.close();
            if (connection != null) connection.close();
        } catch (IOException | SQLException e) {
            e.printStackTrace();
        }
    }
}
