#!/usr/bin/python3
# -*- coding: UTF-8 -*-

import socket
import sys
import time
import logging
import argparse

# Configuration du logger
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Paramètres de timeout pour éviter que le client reste bloqué
TIMEOUT_CONNECTION = 10  # 10 secondes pour se connecter
TIMEOUT_RECEIVE = 5  # 5 secondes pour attendre une réponse du serveur

def parse_arguments():
    """Analyse les arguments de ligne de commande pour obtenir l'adresse IP et le port."""
    parser = argparse.ArgumentParser(description='Client réseau TCP modulable')
    parser.add_argument('--ip', type=str, default='localhost', help="Adresse IP du serveur (par défaut: localhost)")
    parser.add_argument('--port', type=int, default=420, help="Port du serveur (par défaut: 420)")
    args = parser.parse_args()

    # Vérification des paramètres
    if not (0 <= args.port <= 65535):
        logging.error("Le port doit être compris entre 0 et 65535.")
        sys.exit(1)
    return args.ip, args.port

def create_client_socket(adresseIP, port):
    """Crée et retourne un socket client avec gestion des erreurs."""
    try:
        client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)  # TCP
        client.settimeout(TIMEOUT_CONNECTION)  # On définit un timeout pour la connexion
        client.connect((adresseIP, port))
        logging.info(f"Connecté au serveur {adresseIP}:{port}.")
        return client
    except socket.gaierror:
        logging.error("Erreur : L'adresse IP ou le nom de domaine est invalide.")
        sys.exit(1)
    except socket.timeout:
        logging.error("Erreur : Le serveur est inaccessible ou trop lent.")
        sys.exit(1)
    except socket.error as e:
        logging.error(f"Erreur réseau : {e}")
        sys.exit(1)

def send_message(client, message):
    """Envoie un message au serveur."""
    try:
        client.send((message + "\n").encode("utf-8"))
        logging.info(f"Message envoyé : {message}")
    except socket.error as e:
        logging.error(f"Erreur lors de l'envoi du message : {e}")
        client.close()
        sys.exit(1)

def receive_response(client):
    """Réceptionne la réponse du serveur."""
    try:
        client.settimeout(TIMEOUT_RECEIVE)  # Timeout pour la réception
        response = ""
        while True:
            data = client.recv(1024)
            if not data:
                break
            response += data.decode("utf-8")
            if '\n' in response:
                break
        logging.info(f"Réponse du serveur : {response.strip()}")
        return response.strip()
    except socket.timeout:
        logging.error("Erreur : Délai d'attente dépassé pour la réponse du serveur.")
        client.close()
        sys.exit(1)
    except socket.error as e:
        logging.error(f"Erreur réseau lors de la réception : {e}")
        client.close()
        sys.exit(1)

def main():
    """Fonction principale pour la gestion de la communication avec le serveur."""
    # Analyse des arguments de ligne de commande
    adresseIP, port = parse_arguments()

    # Créer le socket client
    client = create_client_socket(adresseIP, port)

    try:
        # Boucle principale d'envoi/réception
        while True:
            message = input("Entrez votre message (ou 'exit' pour quitter) : ")
            if message.strip().lower() == "exit":
                logging.info("Déconnexion du serveur demandée par l'utilisateur.")
                send_message(client, "exit")
                break
            elif not message.strip():
                logging.warning("Le message ne peut pas être vide.")
                continue

            send_message(client, message)  # Envoi du message
            response = receive_response(client)  # Réception de la réponse

            # Traitement de la réponse (modulaire)
            print(f"Réponse du serveur : {response}")

        # Fermeture propre de la connexion
        client.close()
        logging.info("Connexion fermée.")

    except KeyboardInterrupt:
        logging.info("Connexion fermée par l'utilisateur (interruption clavier).")
        client.close()
        sys.exit(0)

if __name__ == "__main__":
    main()
