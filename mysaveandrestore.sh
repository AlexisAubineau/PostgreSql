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
