# trashdb

zf180516.1856

Trouver un moyen d'avoir une *cloud DB* qui me permet de sauvegarder pleins de données temporelles ou non !

## Buts

J'ai pleins de *petites* données qui arrivent de différents endroits au cours du temps, comme par exemple qu'elle est la température de mon stock solaire d'eau chaude, ou quand est-ce que mon chauffage s'est allumé, ma puissance électrique consommée au temps t. Ou plus personnel, mon poids ou ma pression artérielle, quand j'ai le temps de les mesurer ;-)

Si je me concentre que sur des données *métriques*, une approche Prometheus ou Influxdb est nettement plus adaptée pour faire cette database. Mais si j'ai envie de pouvoir sauver autre chose comme données, une approche noSQL est plus pertinente.

C'est pourquoi j'ai nommé ce projet *trashDB*, une DB fourre tout sans a priori, pour pouvoir sauver un peu n'importe quoi comme *petites* données ;-)

## Moyens

Comme je veux une DB dans un *cloud* c'est à dire qu'elle est accessible depuis n'importe où sur la Terre et que des *objets* relativement simplistes puissent y accéder comme des modules à base d'ESP32 ou de simples pages en HTML5/JS sur un smartphone (ma pression artérielle), j'aimerai un interface en HTML.

Après plusieurs recherches sur Internet mon choix s'est porté sur la DB *CouchDB*:

<http://couchdb.apache.org/>

CouchDB présente pas mal d'avantages:
* entrées/sorties en HTML/JSON, utilisable très facilement avec un *curl*
* interface d'administration en HTML out of the box
* synchronisation des serveurs CouchDB très simple, travail off line ou pour les backups par exemple
* possibilité de synchroniser off line sur un smartphone grâce à Pounchdb (https://pouchdb.com/)
* léger et hyper simple à installer via un Docker

### Installation
Je vais le tester dans un mode de container Docker:

<https://hub.docker.com/r/library/couchdb/>

Il faut donc juste installer Docker sur sa machine:

https://www.docker.com/community-edition

et peut-être installer sur les machines *clientes*, donc où on fait les *curls*, un petit *viewer* de JSON tout simple pour se faciliter la vue des résultats JSON:

``sudo apt-get install python-minimal``

Afin de pouvoir faire un truc du style:

``curl -X GET http://localhost:5984/toto | python -m json.tool``


### Utilisation
Simplement démarrer le script start.sh:

``./start.sh``


### Hello World

On regarde déjà si le serveur CouchDB fonctionne avec:

``curl -X GET http://localhost:5984``

Et on obtient un truc du style:

{"couchdb":"Welcome","version":"2.1.1","features":["scheduler"],"vendor":{"name":"The Apache Software Foundation"}}

Après on peut se créer la database *toto* avec:
``curl -X PUT http://localhost:5984/toto``

Et vérifier que l'on a bien la database *toto* avec:
``curl -X GET http://localhost:5984/_all_dbs``

Et enfin on peut lui ajouter un *record* (dans la terminologie CouchDB un *record* est un *document*) à *toto* avec:

``curl -H 'Content-Type: application/json' -X POST http://localhost:5984/toto -d '{"toto": "titi"}'``

Ici on a laissé CouchDB générer un *_id* automatiquement, mais on peut choisir son propre *_id*, pour autant qu'il soit unique comme par exemple:

``curl -H 'Content-Type: application/json' -X POST http://localhost:5984/toto -d '{"_id": "id001", "toto": "titi"}'``

ou avec un *_id* temporel comme:

``curl -H 'Content-Type: application/json' -X POST http://localhost:5984/toto -d '{"_id": "180516.182710.00", "toto": "titi"}'``

Je peux *lire* le résultat en lui donnant un *_id*, par exemple:

``curl -X GET http://localhost:5984/toto/id001``

Pour modifier un *record* il faut en premier lire la *révision* du record pour pouvoir le modifier, ceci permet de vérifier les conflits en écriture et de pouvoir garder l'intégrité de la data base. Donc on lit le *record* *id001* que l'on veut modifier:

``curl -X GET http://localhost:5984/toto/id001``

On obtient un truc du style:

``{"_id":"id001","_rev":"2-8198c0bf1c8d51fc138e520045906e33","toto":"titi"}``

Et on modifie alors le *record* *id001* avec:

``curl -X PUT http://localhost:5984/toto/id001 -d '{ "toto" : "tata","_rev":"2-8198c0bf1c8d51fc138e520045906e33"}'``

On peut vérifier que la modification est bien effectuée avec:

``curl -X GET http://localhost:5984/toto/id001``


**ce n'est pas encore terminé, zf180516.1853**


Quand même sympa comme database ;-)



## Et la suite ?

Après, je verrai si je testerai d'autres solutions ;-)

En voiture Simone !
