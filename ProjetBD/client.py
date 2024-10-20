#!usr/bin/python3
# -*- coding: UTF-8 -*-

# Bibliothèque pour gérer les connexions réseaux
import socket

# Adresse IP du socket serveur
adresseIP = "localhost"
# Port du socket serveur
port = 8080
# Initialise un socket
client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)  # TCP
# Le socket client se connecte
client.connect((adresseIP, port))
print("Connecté au serveur")

message = ""
while True:
    message = input("> ")  # Demande à l'utilisateur d'entrer une ligne
    
    # Si le message est vide (juste un retour à la ligne), on arrête l'envoi des messages
    if message.strip() == "":
        client.send("\n".encode("utf-8"))  # Envoyer un retour à la ligne vide pour indiquer la fin
        break

    client.send((message + "\n").encode("utf-8"))  # Envoi du message avec un saut de ligne

# Maintenant qu'on a terminé d'envoyer toutes les lignes, on attend la réponse du serveur
response = ""
while True:
    reponse = client.recv(255)
    if not reponse:
        break
    response += reponse.decode("utf-8")

# On affiche la réponse complète du serveur
print(response)

# On ferme le socket client
print("Connexion fermée")
client.close()