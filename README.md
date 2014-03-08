#Event Extender 4 (Pour VXAce)

##Mises à jours


L'objectif de ce script est d'offrir une multitude de commandes complémentaires pour la création de systèmes via l'event-making. C'est pour ça que j'ai écrit ce script, dans la même veine que l'Event-language (devenu GeeX Make) de Roys et Avygeil. 

L'event extender est une collection d'outils facile à utiliser qui permettent de s'affranchir de certaines règles et de certaines obligations dans l'event-making en règle générale. De plus, étant principalement basé sur des appels de scripts, chaque argument peut être substitué par une variable, chose impossible avec l'interface actuelle de RPG Maker VX Ace. 

L'objectif de ce document est d'offrir une base de travail. Soit une documentation. L'Event Extender est un script qui a été prévu pour être étendu, donc n'importe qui peut suggérer/implémenter sa propre commande (la notion de commande sera expliquée plus tard dans ce même document). 

Ce document peut paraître un peu abrupte à lire mais une fois que les différents concepts du script sont appréhendés, je vous assure qu'il est possible de gagner énormément de temps dans la création de vos systèmes. De plus, nous verrons, plus tard, que les « apprentis scripteurs » pourront se servir de plusieurs composantes de l'Event Extender pour la création de script, de manière transparente. 

##Remerciements

L'Event Extender est un gros projet, je n'aurai jamais pu le terminer sans l'aide inestimable de Zeus81 et de Nuki que je remercie tout particulièrement pour leurs conseils, leurs solutions. Et aussi parce qu'ils ont tous les deux été une source d'inspiration (comme beaucoup d'autres). Je remercie aussi chaleureusement Magi, Hiino, XHTMLBoy, Zangther, Lidenvice, Raho, Joke, Al Rind, Testament, Heos, S4suk3, Avygeil, Tonyryu, Siegfried, Berka, Nagato Yuki, Fabien, Roys, Raymo, Ypsoriama, Amalrich Von Monesser, Ulis, ParadoxII, Loly74, 2cri, Kmkzy pour leurs conseils techniques comme moraux ainsi que pour des suggestions de commandes, de concepts.J'espère n'avoir oublié personne et si c'est le cas, je vous présente mes plus sincères excuses !   
L'origine du script est de Nuki, auteur des variables locales.   
Zeus81 aura été d'une titanesque aide pour la réalisation de pleins de commandes (la gestion clavier/souris, les variables locales).   
La commande Buzz a été initialement créée par Fabien.   

##Features
Concrètement (et dans les grandes lignes), l'EE offre (et de manière non exhaustive): 


*    Interface d'accès rapide aux variables/switches (via V[id], S[id]) 
*    Support des variables locales 
*    Interface d'accès rapide aux variables locales et interrupteurs locaux (via SV[id...etc] et SS[id...etc]) 
*    Comme les commandes sont écrites via des appels de scripts, il est possible de passer des variables à chaque argument. 
*    Support puissant de la souris (coordonnées, cliques, pression, relachement, rectangle de selection) 
*    Support du clavier (pression, trigger, relachement, combinaison alt_gr, verrouillage maj/scroll/num, chiffre pressé, caractère généré par le clavier) 
*    Des outils de calculs automatisé (pourcents, règles de trois) 
*    La possibilité de lire la base de données (impossible nativement) 
*    Un outil d'extension sans limite (et typé) de la base de données 
*    Des outils de test sur les évènements (collisions, distances) 
*    Des outils sur la map (flasher des cases, informations sur la map) 
*    Des outils sur les évènements (Tressaillir, l'evenement, vérification du survol de la souris, du clique) 
*    Un Pathfinder d'évènement (qui gère la route et le saut) 
*    Des outils d'invocations d'évènements. 
*    Inclusion d'une autre page d'un autre évènement. 
*    Un contrôle total sur les Pictures du jeu (changement de toutes les données, y comprit l'origine) 
*    Affichage de texte sous forme de pictures. 
*    Affichage des monstres de la base de données (à leur position définie dans la BDD) 
*    Un multi-panorama (ajoute 20 panoramas manipulables) 
*    Récupères des informations sur le temps (date,heure) IRL 
*    Un module Quicksave (sauvegarde, chargement, existence de sauvegarde, suppression de sauvegarde) 
*    Importateur de variables/switch d'autres sauvegardes 
*    Gestion de zones virtuelles (rectangles, cercles, ellipses, polygonales et possibilité de vérifier si un point est dedans ou pas, si la souris le survol, si la souris le clique). 
*    Création de champs de textes modifiables au clavier 
*    Outil de connexion à un serveur distant (envoi de données/réception de données) 
*    Possibilité de récupérer le nom de la session windows.

##Installation
(rédigé par Joke)


Rien de plus simple, c'est un script à mettre dans `Materials`, de préférence au dessus de tous les autres. Le lien vers le script est en bas de cette présentation. 

Pour ceux qui ne savent pas encore comment mettre un script, ou qui trouvent le site "github" peu intuitif : 
1.    Rendez-vous sur : [La Page du Script](https://raw.github.com/Grimimi/EventExtender4/master/EE.rb)
2.    Copiez-collez le 
      ![Exemple](https://github.com/Grimimi/EventExtender4/blob/master/images/2.gif?raw=true)


##Conditions d'utilisations
Ce script est entièrement libre, aucune créditation obligatoire, peut être utilisé dans un projet commercial sans aucune limite. Le script peut être partagé partout sans limite. L'auteur ne doit pas être respécifié. Bonne utilisation. 
N'HÉSITEZ PAS A LE PARTAGER PARTOUT !!! =D