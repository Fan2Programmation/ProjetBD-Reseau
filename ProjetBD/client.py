#!/usr/bin/python3
# -*- coding: UTF-8 -*-

import socket
import sys
import logging
import argparse
import time

# Configuration du logger
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Paramètres de timeout pour éviter que le client reste bloqué
TIMEOUT_CONNECTION = 10  # Timeout pour la connexion
TIMEOUT_RECEIVE = 2      # Timeout pour la réception des données (ajustez si nécessaire)

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
        client_socket = socket.create_connection((adresseIP, port), timeout=TIMEOUT_CONNECTION)
        logging.info(f"Connecté au serveur {adresseIP}:{port}.")
        return client_socket
    except socket.gaierror:
        logging.error("Erreur : L'adresse IP ou le nom de domaine est invalide.")
        sys.exit(1)
    except socket.timeout:
        logging.error("Erreur : Le serveur est inaccessible ou trop lent.")
        sys.exit(1)
    except ConnectionRefusedError:
        logging.error("Erreur : Le serveur refuse la connexion. Assurez-vous que le serveur est en ligne.")
        sys.exit(1)
    except Exception as e:
        logging.error(f"Erreur de connexion : {e}")
        sys.exit(1)

def receive_responses(sock):
    """Reçoit toutes les lignes envoyées par le serveur."""
    messages = []
    sock.setblocking(0)  # Met le socket en mode non bloquant
    start_time = time.time()
    data = b""
    while True:
        # Vérifie si le timeout est dépassé
        if time.time() - start_time > TIMEOUT_RECEIVE:
            break
        try:
            chunk = sock.recv(4096)
            if chunk:
                data += chunk
                start_time = time.time()  # Reset du timer après réception de données
            else:
                # Si recv retourne une chaîne vide, la connexion est fermée
                break
        except BlockingIOError:
            # Aucun data disponible pour le moment
            time.sleep(0.1)  # Attend un court instant avant de réessayer
            continue
        except Exception as e:
            logging.error(f"Erreur lors de la réception des données : {e}")
            break

    # Décodage des données reçues et séparation par lignes
    if data:
        try:
            messages = data.decode('utf-8').split('\n')
            messages = [msg.strip() for msg in messages if msg.strip()]
        except UnicodeDecodeError as e:
            logging.error(f"Erreur de décodage des données : {e}")
    return messages

def main():
    """Fonction principale du client."""
    adresseIP, port = parse_arguments()
    client_socket = create_client_socket(adresseIP, port)

    try:
        # Lecture du message de bienvenue si disponible
        welcome_messages = receive_responses(client_socket)
        if welcome_messages:
            for message in welcome_messages:
                print(message)
        else:
            logging.info("Aucun message de bienvenue reçu.")

        while True:
            # Demande de l'entrée utilisateur
            message = input("Entrez votre message (ou 'exit' pour quitter) : ").strip()
            if message.lower() == "exit":
                logging.info("Fermeture de la connexion.")
                break

            # Envoi du message au serveur
            try:
                client_socket.sendall((message + '\n').encode('utf-8'))
                logging.info(f"Message envoyé : {message}")
            except Exception as e:
                logging.error(f"Erreur lors de l'envoi du message : {e}")
                break

            # Réception des réponses du serveur
            responses = receive_responses(client_socket)
            if responses:
                for response in responses:
                    print(response)
            else:
                logging.warning("Pas de réponse du serveur.")

    finally:
        client_socket.close()
        logging.info("Connexion fermée.")

if __name__ == "__main__":
    main()
