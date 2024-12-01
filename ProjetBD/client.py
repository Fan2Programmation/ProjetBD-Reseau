#!/usr/bin/python3
# -*- coding: UTF-8 -*-

import socket
import logging
import argparse
import sys

# Configuration du logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

def main():
    # Gestion des arguments de ligne de commande
    parser = argparse.ArgumentParser(description="Client réseau modulable.")
    parser.add_argument("--ip", type=str, default="localhost", help="Adresse IP du serveur (par défaut : localhost)")
    parser.add_argument("--port", type=int, default=420, help="Port du serveur (par défaut : 420)")
    args = parser.parse_args()

    # Initialisation de la connexion
    try:
        client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        client.settimeout(5)  # Timeout de 5 secondes pour la connexion
        logger.info(f"Tentative de connexion au serveur {args.ip}:{args.port}")
        client.connect((args.ip, args.port))
        logger.info("Connexion établie avec le serveur.")
    except socket.error as e:
        logger.error(f"Erreur lors de la connexion au serveur : {e}")
        sys.exit(1)

    # Tenter de lire le message de bienvenue, s'il existe
    try:
        client.settimeout(1)  # Timeout court pour la lecture initiale
        welcome_message = client.recv(1024).decode("utf-8")
        if welcome_message:
            print(welcome_message.strip())
            logger.info(f"Message reçu du serveur : {welcome_message.strip()}")
    except socket.timeout:
        # Pas de message de bienvenue reçu, continuer sans erreur
        logger.info("Aucun message de bienvenue reçu du serveur.")
    except socket.error as e:
        logger.error(f"Erreur lors de la réception du message de bienvenue : {e}")
        client.close()
        sys.exit(1)
    finally:
        # Remettre le timeout par défaut pour les prochaines opérations
        client.settimeout(None)  # Aucun timeout (blocage jusqu'à réception)

    try:
        while True:
            # Lire une commande utilisateur
            message = input("> ")
            if message.strip().lower() == "exit":
                logger.info("Fin de la communication demandée par l'utilisateur.")
                break
            if message.strip() == "":
                logger.warning("Le message ne peut pas être vide.")
                continue

            # Envoyer le message au serveur
            try:
                client.sendall((message + "\n").encode("utf-8"))
            except socket.error as e:
                logger.error(f"Erreur lors de l'envoi du message : {e}")
                break

            # Attendre et lire la réponse du serveur
            try:
                response = client.recv(1024).decode("utf-8")
                if not response:
                    logger.warning("Le serveur a fermé la connexion.")
                    break
                print(response.strip())
                logger.info(f"Réponse reçue : {response.strip()}")
            except socket.error as e:
                logger.error(f"Erreur lors de la réception de la réponse : {e}")
                break
    except KeyboardInterrupt:
        logger.info("Interruption par l'utilisateur.")
    finally:
        logger.info("Fermeture de la connexion.")
        client.close()

if __name__ == "__main__":
    main()
