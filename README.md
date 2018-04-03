# PostgreSql
Projet Postgresql numéro 1

Dans ce projet notre groupe est composé 3 personnes :
#Maurin Thomas
#Aubineau Alexis
#Duval Thomas

--------------------------------------------------------------------------------------------
Projet 1 Mysql

-AUBINEAU Alexis
-MAURIN Thomas
-DUVAL Thomas

SOMMAIRE :


-INTRODUCTION
-INSTALLATION DE MySQL/phpMyAdmin
-FONCTIONNEMENT DE MySQL
-SCRIPTS
-ANNEXES













INTRODUCTION

Avant de commencer d’installer MYSQL il faut installer une machine virtuel DEBIAN 8 Jessie.
Vous pouvez aller voir sur ce lien : https://www.debian.org/releases/jessie/debian-installer/  et vous prenez la amd64.
Maintenant qu’on a notre machine virtuel DEBIAN 8 nous pouvons commencer à mettre en placer le MySQL.


INSTALLATION DE MySQL / PhpMyAdmin


Dans le terminal on fait « sudo apt install mysql-server ».
Ensuite pendant l’installation il va vous poser une question mais vous faites « O » pour continuer.
Par la suite il va vous demander un mot de passe pour la connexion à MySQL.
Vous en mettez un et vous le confirmez aussi.
Ensuite pour combler MYSQL server on a pris PhpMyAdmin.
Pour l’installer on fait un « sudo apt install phpmyadmin ».
	On l’installe on entre nos mots de passe et on confirme. (voir annexe img 5/6)
En serveur Web il faut sélectionner apache2 pour choisir un serveur web à reconfigurer automatiquement. ( voir annexe 7)
PhpMyAdmin est accessible à l’adresse http://localhost/phpmyadmin (il est nécessaire d’activer le javascript de notre navigateur internet).
Pour se connecter il faut utiliser votre login / mots de passe utilisé avec MYSQL.
Si aucun utilisateur est créé vous pouvez utiliser le compte root pour les créer :
Utilisateur : root
Mot de passe : celui qu’on a définit sur l’installation de MySQL.


FONCTIONNEMENT DE MySQL

Après les installations il faut démarrer le serveur on fait « sudo service mysql start ».
Pour redémarrer le serveur MySQL on fait « sudo service mysql restart ».
Ensuite on va créer un utilisateur et une base de données.
On peut faire de deux façons soit sur le terminal de la machine Debian 8 ou depuis PhpMyAdmin.
Pour la partie terminale pour y accéder on fait « sudo mysql -u root -p »
Et on entre notre mot de passe qu’on a mis lors de l’installation.
Dans notre cas notre mot de passe est « toto ».
Ensuite on va créer un utilisateur « appli_web » qui a tous les privilèges.
Pour créer l’utilisateur appli_web on fait « create user ‘appli_web’@’localhost’ identified by ‘toto’ ; »
Ensuite il faut qu’on quitte l’utilisateur « root » pour aller dans celui de « appli_web ».
Pour quitter un utilisateur sur MySQL on entre la commande : « \q » ça permet de revenir sur le Terminal.
On entre la commande suivante pour y accéder « sudo mysql -u appli_web -p ».
On entre le mot de passe et on est connecté à notre utilisateur depuis le terminal.
Ensuite faut créer la data base de « appli_web ».
Après pour crée la BDD, on fait un « create database appli_web ; » (Voir annexe img3)
Et pour se connecter on fait un « connect appli_web ; » (Voir annexe Img2)
Dans phpMyAdmin on entre le lien au-dessus et vous mettez les identifiants. (Voir annexe Img8)
On se connecte avec les identifiants qu’on a créé « appli_web ».
Pour créer une database on fait juste « Nouvelle base de données » et on entre « appli_web ».
Pour le mettre en mode all privilège il y a plus simple.
Sur phpMyAdmin on a des onglets avec à la suite « Structure, SQL, etc.. » vous sélectionnez privilèges. (Voir annexe Img9)
Nous on va dans « plus » puis « privilèges » et dans cette option on peut définir les privilèges des utilisateurs. (Voir annexe Img10)
On a juste à cocher « Privilèges globaux » en sélectionnant le bon utilisateur que l’on veut.



SCRIPTS

Pour se connecter au SSH il faut d’abord que vous entrez en ligne de commande (Terminal sous Debian 8 Jessie) « hostname ».
Et ça va afficher le nom de machine virtuel.
Vous récupérez votre nom de machine et vous l’insérez dans le terminal en faisant exemple « ssh tom@nom_de_votre_machine ».
Quand le script demandera votre hostname alors vous le mettez pour se connecter en SSH.


#!/bin/bash
PATH=/bin:/usr/bin:/usr/local/bin
date=$(date +%d-%m-%Y-%H)
dump="/usr/bin/mysqldump"
log="/var/log/backupdb.log"
sql="/usr/bin/mysql"

echo "Entrez votre nom d'utilisateur de base de donnée"
read user
echo "Entrez votre mot de passe de base de donnée"
read pw

echo "Rentrez la valeur de votre Hostname"
read Hostname
ssh $Hostname bash < ./mysaveandrestore.sh
suppr_date(){
	find ~/Documents/  -type f -name '*.tar' -mtime +8 -exec rm {} \;
}
make_save_onedb(){
	echo "Entrez le nom de votre database"
	read input
	${dump} -u${user} --events -p${pw} --databases ${input}  > databases.sql
	mv databases.sql ~/Documents/
	cd ~/Documents
	tar -zcvf databases-${date}.tar.gz databases.sql
	chmod 777 databases-${date}.tar.gz
	rm -f databases.sql
	exit 0
}
make_save(){
	${dump} -A -u${user} --events -p${pw}  > databases.sql
	mv databases.sql ~/Documents/
	cd ~/Documents
	tar -zcvf databases-${date}.tar.gz databases.sql
	chmod 777 databases-${date}.tar.gz
	rm -f databases.sql
	exit 0
}

all_save_rest() {

	echo
	echo "Restauration de la dernière sauvegarde...en cours..."
	sleep 2

	cd ~/Documents
	tar -zxvf databases-${date}.tar.gz
	${sql} -u${user} -p${pw} < databases.sql
	rm -f databases.sql

	echo
	echo "Dernière base de donnée restaurée avec succès"
	sleep 2
	exit 0
}

save_onedate_rest(){
	cd ~/Documents
	echo "Entrée le nom de votre .tar.gz de sauvegarde "
	read input
	tar -zxvf ${input}
	${sql} -u${user} -p${pw} < databases.sql
	rm -f databases.sql
	exit 0
}

printf "Tapez 1 pour sauvegarder toutes vos bases de données mysql\nTapez 2 pour restaurer la sauvegarde effectuée aujourd'hui\nTapez 3 pour restaurer une sauvegarde spécifique\nTapez 4 pour sauvegarder une base de donée particulière\nTapez 5 pour supprimer les archives crées il y a plus de 7 jours\n> "
read input
if [ ${input} = '1' ]
then
	make_save

elif [ ${input} = '2' ]
then
	all_save_rest

elif [ ${input} = '3' ]
then
	save_onedate_rest


elif [ ${input} = '4' ]
then
	make_save_onedb

elif [ ${input} = '5' ]
then
	suppr_date
else
	echo "Erreur"
	exit 1
fi


ANNEXE (voir dans le pdf ci-dessous)
