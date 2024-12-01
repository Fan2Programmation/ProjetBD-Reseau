#!/usr/bin/python3
# -*- coding: UTF-8 -*- 

import socket
import sys
import time

# Adresse IP et port du serveur
adresseIP = "localhost"
port = 420

# Paramètres de timeout pour éviter que le client reste bloqué
TIMEOUT_CONNECTION = 10  # 10 secondes pour se connecter
TIMEOUT_RECEIVE = 5  # 5 secondes pour attendre une réponse du serveur

def create_client_socket():
    """Crée et retourne un socket client avec gestion des erreurs."""
    try:
        client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)  # TCP
        client.settimeout(TIMEOUT_CONNECTION)  # On définit un timeout pour la connexion
        client.connect((adresseIP, port))
        print("Connecté au serveur.")
        return client
    except socket.timeout:
        print("Erreur : Le serveur est inaccessible ou trop lent.")
        sys.exit(1)
    except socket.error as e:
        print(f"Erreur réseau : {e}")
        sys.exit(1)

def send_message(client, message):
    """Envoie un message au serveur et attend la confirmation."""
    try:
        client.send((message + "\n").encode("utf-8"))
        print(f"Message envoyé : {message}")
    except socket.error as e:
        print(f"Erreur lors de l'envoi du message : {e}")
        client.close()
        sys.exit(1)

def receive_response(client):
    """Réceptionne la réponse du serveur."""
    try:
        response = ""
        while True:
            data = client.recv(255)
            if not data:
                break
            response += data.decode("utf-8")
        return response
    except socket.timeout:
        print("Erreur : Délai d'attente dépassé pour la réponse du serveur.")
        client.close()
        sys.exit(1)
    except socket.error as e:
        print(f"Erreur réseau lors de la réception : {e}")
        client.close()
        sys.exit(1)

def main():
    """Fonction principale pour la gestion de la communication avec le serveur."""
    # Créer le socket client
    client = create_client_socket()

    try:
        # Première interaction avec le serveur (message d'accueil)
        message = input("Entrez votre message (Appuyez sur Entrée pour envoyer) : ")
        while message.strip().lower() != "exit":
            send_message(client, message)  # Envoi du message
            response = receive_response(client)  # Réception de la réponse
            print("Réponse du serveur : ", response)
            
            message = input("Entrez votre message (Appuyez sur Entrée pour envoyer) : ")

        print("Déconnexion du serveur.")
        client.send("exit\n".encode("utf-8"))  # Envoie de 'exit' pour signifier la déconnexion
        response = receive_response(client)  # Réponse du serveur à la déconnexion
        print(response)
    
    except KeyboardInterrupt:
        print("\nConnexion fermée par l'utilisateur.")
    
    finally:
        # Fermeture du socket client
        client.close()
        print("Connexion fermée.")

if __name__ == "__main__":
    main()