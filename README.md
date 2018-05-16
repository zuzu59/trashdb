# trashdb
Trouver un moyen d'avoir une "cloud DB" qui me permet de sauvegarder pleins de données temporelles ou non !

## Buts ##
J'ai pleins de "petites" données qui arrivent de différents endroits au cours du temps, comme par exemple qu'elle est la température de mon installation solaire d'eau chaude, ou quand est-ce que mon chauffage s'est allumé, ma puissance électrique consommée au temps t. Ou plus personnel, mon poids ou ma pression artérielle, quand j'ai le temps de les mesurer ;-)

Si je me concentre que sur des données "métriques", une approche Prometheus est nettement plus adaptée pour faire cette database. Mais si j'ai envie de pouvoir sauver autre chose comme données, une approche noSQL est plus pertinente.

C'est pourquoi j'ai nommé ce projet 'trashDB', une DB fourre tout sans a priori, pour pouvoir sauver un peu n'importe quoi comme "petites" données ;-)

## Moyens ##
Comme je veux une DB dans un "cloud" c'est à dire qu'elle est accessible depuis n'importe où sur la Terre et que des "objets" relativement simplistes puissent y accéder comme des modules à base d'ESP32 ou de simple pages en HTML5 sur un smartphone (ma pression artérielle), j'aimerai un interface en HTML simple.

Après plusieurs recherches sur Internet mon choix s'est porté sur la DB CouchDB:

http://couchdb.apache.org/

Et je vais le tester dans un mode de container Docker:

https://hub.docker.com/r/library/couchdb/

## Et la suite ? ##
Après, je verrai si je testerai d'autres solutions ;-)

En voiture Simone !





