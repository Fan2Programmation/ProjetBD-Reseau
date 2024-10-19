#!usr/bin/python3
# -*- coding: UTF-8 -*-

#Bibliothèque pour gérer les connexions réseaux
import socket

#Adresse IP du socket serveur
adresseIP = "localhost"
#Port du socket serveur
port = 8080
#Initialise un socket
client = socket.socket(socket.AF_INET, socket.SOCK_STREAM) #TCP
#Le socket client se connecte
client.connect((adresseIP, port))
print("Connecté au serveur")
#Instruction pour sortir de la boucle
print("Tapez FIN pour terminer la conversation")
message=""
while message.upper() != "FIN":
    message = input("> ") + "\n" #\n pour discuter avec un serveur en java qui attend ça dans son readLine
    #Le socket client envoie un message
    client.send(message.encode("utf-8"))
    reponse = client.recv(255)
    #On décode la requête
    print(reponse.decode("utf-8"))
#On ferme le socket client
print("Connexion fermée")
client.close()
