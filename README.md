# trashdb

zf180524.1536

*Trouver un moyen d'avoir une *cloud DB* qui me permet de sauvegarder pleins de données temporelles ou non !*

## Buts

J'ai pleins de *petites* données qui arrivent de différents endroits au cours du temps, comme par exemple qu'elle est la température de mon stock solaire d'eau chaude, ou quand est-ce que mon chauffage s'est allumé, ma puissance électrique consommée au temps t. Ou plus personnel, mon poids ou ma pression artérielle, quand j'ai le temps de les mesurer ;-)

Si je me concentre que sur des données *métriques*, une approche Prometheus ou Influxdb est nettement plus adaptée pour faire cette base de données. Mais si j'ai envie de pouvoir sauver autre chose comme données, une approche noSQL est plus pertinente.

C'est pourquoi j'ai nommé ce projet *trashDB*, une DB fourre tout sans a priori, pour pouvoir sauver n'importe quoi comme données ;-)

## Moyens

Comme je veux une DB dans un *cloud* c'est à dire qu'elle est accessible depuis n'importe où sur la Terre et que des *objets* relativement simplistes puissent y accéder comme des modules à base d'ESP32 ou de simples pages en HTML5/JS sur un smartphone (ma pression artérielle), j'aimerai un interface en HTML.

Après plusieurs recherches sur Internet mon choix s'est porté sur la DB *CouchDB*:

<http://couchdb.apache.org/>

CouchDB présente pas mal d'avantages:
* entrées/sorties en HTML/JSON, utilisable très facilement avec un *curl*
* travail en JSON, superbe liberté au niveau du schéma de la DB
* interface d'administration en HTML out of the box
* synchronisation/réplication entre serveurs CouchDB très simple, travail off line ou pour les backups par exemple
* système de version des enregistrements, tout s'écrit, rien ne s'efface
* possibilité de synchroniser off line sur un smartphone grâce à Pounchdb
* léger et hyper simple à installer via un Docker

En savoir plus sur CouchDB:

https://www.tutorialspoint.com/couchdb/couchdb_introduction.htm

### Installation
Je vais le faire tourner dans un container Docker:

https://hub.docker.com/r/library/couchdb

https://www.docker.com/community-edition

Il faut donc juste installer Docker sur sa machine avec:

./install.sh

Ne pas oublier de faire un *logoff/logon* afin de tenir compte des modifications des groupes !

et peut-être installer sur les machines *clientes*, donc où on fait les *curls*, un petit *viewer* de JSON tout simple pour se faciliter la vue des résultats JSON:

``sudo apt-get install python-minimal``

Afin de pouvoir faire un truc du style:

``curl -X GET http://localhost:5984/toto | python -m json.tool``


### Utilisation
Simplement démarrer le script *start.sh* qui va démarrer un serveur CouchDB dans un Docker et sauvegarder les données sur le disque du host:

``./start.sh``


### Hello World

On regarde déjà si le serveur CouchDB fonctionne avec (attention, il faut attendre environ 2 minutes afin que CouchDB se mette en place):

``curl -X GET http://localhost:5984``

Et on obtient un truc du style:

``"couchdb":"Welcome","version":"2.1.1","features":["scheduler"],"vendor":{"name":"The Apache Software Foundation"}}``

Après on peut se créer la database *dbtoto* avec:

``curl -X PUT http://localhost:5984/dbtoto``

Et vérifier que l'on a bien la database *toto* avec:

``curl -X GET http://localhost:5984/_all_dbs``

Et enfin on peut lui ajouter un *record* (dans la terminologie CouchDB un *record* est un *document*) à *dbtoto* avec:

``curl -H 'Content-Type: application/json' -X POST http://localhost:5984/dbtoto -d '{"toto": "1234"}'``

Ici on a laissé CouchDB générer un *_id* automatiquement, mais on peut choisir son propre *_id*, pour autant qu'il soit unique comme par exemple:

``curl -H 'Content-Type: application/json' -X POST http://localhost:5984/dbtoto -d '{"_id": "id001", "toto": "1234"}'``

ou avec un *_id* temporel comme:

``curl -H 'Content-Type: application/json' -X POST http://localhost:5984/dbtoto -d '{"_id": "180516.182710.00", "toto": "1234"}'``

Je peux *lire* le résultat en lui donnant un *_id*, par exemple:

``curl -X GET http://localhost:5984/dbtoto/id001``

Pour modifier un *record* il faut en premier lire la *révision* du record pour pouvoir le modifier, ceci permet de vérifier les conflits en écriture et de pouvoir garder l'intégrité de la data base. Donc on lit le *record* *id001* que l'on veut modifier:

``curl -X GET http://localhost:5984/dbtoto/id001``

On obtient un truc du style:

``{"_id":"id001","_rev":"2-8198c0bf1c8d51fc138e520045906e33","toto":"1234"}``

Et on modifie alors le *record* *id001* avec:

``curl -X PUT http://localhost:5984/dbtoto/id001 -d '{ "toto" : "234","_rev":"xxxx"}'``

On peut vérifier que la modification est bien effectuée avec:

``curl -X GET http://localhost:5984/dbtoto/id001``

Pour effacer ce document il faut à nouveau récupérer sa *révision* et faire:

``curl -X DELETE http://localhost:5984/dbtoto/id001?rev=xxx``

Pour la suite du Hello World, nous avons besoin de quelques documents que nous allons rapidement créer avec:

```
curl -H 'Content-Type: application/json' -X POST http://localhost:5984/dbtoto -d '{"_id": "id001", "toto": "1234"}'
curl -H 'Content-Type: application/json' -X POST http://localhost:5984/dbtoto -d '{"_id": "id002", "tutu": "2345"}'
curl -H 'Content-Type: application/json' -X POST http://localhost:5984/dbtoto -d '{"_id": "id003", "titi": "6789"}'
curl -H 'Content-Type: application/json' -X POST http://localhost:5984/dbtoto -d '{"_id": "id004", "tata": "9876"}'
```

Pour voir tous les documents de la data base *dbtoto* (Attention il faut mettre des *'* autour de l'url !):

``curl -X GET 'http://localhost:5984/dbtoto/_all_docs'``

Pour voir tous les documents de la data base *dbtoto*, mais en détail:

``curl -X GET http://localhost:5984/dbtoto/_all_docs?include_docs=true``

Pour voir tous les documents de la data base *dbtoto* en détail mais en ordre inverse:

``curl -X GET 'http://localhost:5984/dbtoto/_all_docs?include_docs=true&descending=true'``

Pour voir seulement un range d'*id* des documents de la data base *dbtoto*:

``curl -X GET 'http://localhost:5984/dbtoto/_all_docs?startkey="id002"&endkey="id003"'``

Pour voir seulement depuis un *id* les *n* documents de la data base *dbtoto*:

``curl -X GET 'http://localhost:5984/dbtoto/_all_docs?startkey="id002"&limit=2'``

Maintenant que nous avons bien vu les commandes *curl* nous allons passer au GUI de CouchDB *out the box* en mettant dans un browser:

``http://localhost:5984/_utils``

Dans CouchDB tout s'écrit rien ne s'efface ! Ceci grâce au flag des révisions des documents *_rev*. Nous allons ici tester cette fonctionnalité pour cela nous allons modifier plusieurs fois le document *id001* avec le GUI de CouchDB.

Puis on peut afficher toutes les versions de ce document:

``curl -X GET 'http://localhost:5984/dbtoto/id001?revs_info=true'``

On va avoir un truc du style:

```
_id	"id001"
_rev	"6-f6213338be055b9b14d9b0dc09e68105"
toto	"1234567"
_revs_info
0
rev	"6-f6213338be055b9b14d9b0dc09e68105"
status	"available"
1
rev	"5-c4a7a75773c3cd1d354334ed31e4f9e2"
status	"available"
2
rev	"4-0ae74a0d88d70d24c335a32003ef64d0"
status	"available"
3
rev	"3-eb0222a9a1ce651329e6d0ee214539e8"
status	"available"
4
rev	"2-d57cb237ff87276a9eb0bd7ef89a8388"
status	"deleted"
5
rev	"1-5d75c28562ab223fa79c4e9e5a696f3c"
status	"available"
```

Après pour *voir* la version demandée du document on fait:

``curl -X GET 'http://localhost:5984/dbtoto/id001?rev=4-0ae74a0d88d70d24c335a32003ef64d0'``

Travailler avec les vues.

Les vues sont simplement une représentation d'une table de documents sous forme de clefs valeurs en fonction d'un critère. Après il est possible de faire une recherche dans cette vue pour obtenir le document.
Par exemple, une base de données qui stocke les scores fait par les joueurs pour un jeux, on aura une structure de document du style:

``id, user, score``

Pour pouvoir rechercher le score d'un joueur, il faudra faire une table clefs valeurs user:score. User devenant alors la clef de cette table et il sera facile d'extraire le document contenant le joueur demandé. Les vues sont toujours triées par la clef !

Pour cette exemple on va se créer une nouvelle base de données et mettre quelques données avec

``curl -X PUT http://localhost:5984/dbgame``

``curl -H 'Content-Type: application/json' -X POST http://localhost:5984/dbgame -d '{"user":"toto","score":"1234","time":"1234"}'``

``curl -H 'Content-Type: application/json' -X POST http://localhost:5984/dbgame -d '{"user":"tutu","score":"2345","time":"12345"}'``

``curl -H 'Content-Type: application/json' -X POST http://localhost:5984/dbgame -d '{"user":"titi","score":"3456","time":"123456"}'``

``curl -H 'Content-Type: application/json' -X POST http://localhost:5984/dbgame -d '{"user":"tata","score":"4567","time":"1234567"}'``

Puis après depuis le GUI on va créer un *design document* de type *view* que l'on nommera *_design/vgamme* et *byusers* avec comme données:

```
function (doc) {
    if(doc.user && doc.score && doc.time) {
    emit(doc.user, doc.score);
  }
}
```

Après il sera très facile de demander les données du joueur *toto* avec:

``curl -X GET 'http://localhost:5984/dbgame/_design/vgame/_view/byusers?key="toto"'``

Pour bien comprendre, on peut aussi faire un autre *design document* de type *view* que l'on nommera *_design/vgamme* et *byscores* avec comme données:

```
function (doc) {
    if(doc.user && doc.score && doc.time) {
    emit(doc.score,doc.user );
  }
}
```




Quand même sympa cette base de données CouchDB ;-)


## Info en vrac

Comment ajouter un fichier dans un document CouchDB ?

https://www.tutorialspoint.com/couchdb/couchdb_attaching_files.htm



## Et la suite ?

Après, je verrai si je testerai d'autres solutions ;-)

Comme par exemple Cozy.io qui est un service CouchDB gratuit jusqu'à 5GB


# Sources d'inspiration

## CouchDB
Un petit tutoriel sympa en français qui permet déjà commencer facilement:<br>
https://www.tutorialspoint.com/couchdb/index.htm

Le livre du guide en anglais:<br>
http://guide.couchdb.org/

Le même livre mais traduit partiellement en français<br>
http://guide.couchdb.org/editions/1/fr/index.html

La documentation originale de CouchDB:<br>
http://docs.couchdb.org/en/2.1.1/

## JSON
JSON pour les débutants:<br>
https://la-cascade.io/json-pour-les-debutants/

## PouchDB
PouchDB permet d'avoir une mini DB JSON sur son smartphone et de pouvoir la synchroniser avec une DB CouchDB très facilement:<br>
https://pouchdb.com/


## Mango
A MongoDB inspired query language interface for Apache CouchDB:<br>
https://github.com/cloudant/mango

## Mon petit notepad sur couchdb
CouchDB, mais c'est si simple ;-)<br>
https://drive.google.com/open?id=1ah4rdU72lT3NVCZN9cj5RU-xvHxViw67gHUaURY4eEs
