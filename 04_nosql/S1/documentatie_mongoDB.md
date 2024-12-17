# MongoDB dossier

## Inhoud
1. [Wat is MongoDB?](#wat-is-mongodb)
2. [Waarom MongoDB?](#waarom-mongodb)
3. [Hoe werkt MongoDB?](#hoe-werkt-mongodb)
4. [Script inhoud](#script-inhoud)
   - [Eventueel eerst alle database bestanden verwijderen](#eventueel-eerst-alle-database-bestanden-verwijderen)
   - [MongoDB Binaries toevoegen aan PATH](#mongodb-binaries-toevoegen-aan-path)
   - [Replica Set Servers starten](#replica-set-servers-starten)
   - [Replica Sets initialiseren](#replica-sets-initialiseren)
   - [Config Servers starten](#config-servers-starten)
   - [Config Servers Replica Sets initialiseren](#config-servers-replica-sets-initialiseren)
   - [Mongos Router starten](#mongos-router-starten)
   - [Mongos Router status checken](#mongos-router-status-checken)
   - [Sharding toevoegen](#sharding-toevoegen)
   - [Balancer opstarten](#balancer-opstarten)
   - [Data importeren](#data-importeren)
5. [Shard status checken](#shard-status-checken)
6. [Replicatie nakijken](#replicatie-nakijken)
7. [Controleren van de Shard Distribution](#controleren-van-de-shard-distribution)
8. [Queries](#queries)
   - [Specifieke periode](#specifieke-periode)
   - [Ritten tellen per voertuig](#ritten-tellen-per-voertuig)
   - [Langste ritten op tijdsduur](#langste-ritten-op-tijdsduur)
   - [Gemiddelde ritduur per voertuig](#gemiddelde-ritduur-per-voertuig)
9. [Conclusie](#conclusie)


## Wat is MongoDB?
MongoDB is een open-source, documentgeoriënteerde database die is ontworpen voor het opslaan en beheren van grote hoeveelheden gegevens. Het is een van de meest populaire NoSQL-databases en wordt veel gebruikt in webtoepassingen en andere toepassingen waarbij flexibiliteit en schaalbaarheid belangrijk zijn.

## Waarom MongoDB?
MongoDB biedt verschillende voordelen ten opzichte van traditionele relationele databases, waaronder: 

- **Flexibiliteit**: MongoDB is een documentgeoriënteerde database, wat betekent dat het geen vaste schema's vereist en dat documenten kunnen worden opgeslagen in een flexibel formaat. Dit maakt het gemakkelijk om gegevens te wijzigen en aan te passen naarmate de behoeften van een toepassing veranderen.
- **Schaalbaarheid**: MongoDB is ontworpen om te schalen en kan eenvoudig worden opgeschaald om te voldoen aan de behoeften van groeiende toepassingen. Het ondersteunt zowel horizontale als verticale schaling, waardoor het gemakkelijk is om de prestaties van een toepassing te verbeteren naarmate het aantal gebruikers en gegevens groeit.
- **Snelheid**: MongoDB is ontworpen voor hoge prestaties en biedt snelle lees- en schrijfoperaties. Het maakt gebruik van geavanceerde indexering en query-engine om snelle toegang tot gegevens te bieden, zelfs bij grote gegevenssets.

## Hoe werkt MongoDB
MongoDB werkt op basis van documenten, die worden opgeslagen in collecties. Een document is een JSON-achtige structuur die gegevens bevat in de vorm van velden en waarden. Documenten kunnen worden genest en kunnen verschillende gegevenstypen bevatten, waaronder tekst, getallen, arrays en andere documenten.


## Script inhoud
[mongodb.bat](mongodb.bat)

### Eventueel eerst alle database bestanden verwijderen
[verwijder_data_mongo.bat](verwijder_data_mongo.bat)

### MongoDB Binaries toevoegen aan PATH
```batch
set PATH=%PATH%;C:\Program Files\MongoDB\Server\8.0\bin
```

### Replica Set Servers starten
Een replica set is een groep MongoDB-servers die samenwerken en dezelfde gegevens bevatten.
```batch   
echo Starting first replica set servers...
start "" "C:\Program Files\MongoDB\Server\8.0\bin\mongod.exe" --replSet rs0 --shardsvr --dbpath "C:\Users\Thibeau\Desktop\school\2024-2025\DB3\datastorage\db1" --port 5005
start "" "C:\Program Files\MongoDB\Server\8.0\bin\mongod.exe" --replSet rs0 --shardsvr --dbpath "C:\Users\Thibeau\Desktop\school\2024-2025\DB3\datastorage\db2" --port 5006

echo Starting second replica set servers...
start "" "C:\Program Files\MongoDB\Server\8.0\bin\mongod.exe" --replSet rs1 --shardsvr --dbpath "C:\Users\Thibeau\Desktop\school\2024-2025\DB3\datastorage\db3" --port 5007
start "" "C:\Program Files\MongoDB\Server\8.0\bin\mongod.exe" --replSet rs1 --shardsvr --dbpath "C:\Users\Thibeau\Desktop\school\2024-2025\DB3\datastorage\db4" --port 5008

echo Starting third replica set servers...
start "" "C:\Program Files\MongoDB\Server\8.0\bin\mongod.exe" --replSet rs2 --shardsvr --dbpath "C:\Users\Thibeau\Desktop\school\2024-2025\DB3\datastorage\db5" --port 5013
start "" "C:\Program Files\MongoDB\Server\8.0\bin\mongod.exe" --replSet rs2 --shardsvr --dbpath "C:\Users\Thibeau\Desktop\school\2024-2025\DB3\datastorage\db6" --port 5014```
```

### Replica Sets initialiseren
```batch
echo Initializing first replica set...
echo @echo off > init_rs0.bat
echo "C:\Users\Thibeau\Desktop\mongosh\mongosh-2.3.2-win32-x64\bin\mongosh.exe" --port 5005 --eval "rs.initiate({_id: 'rs0', members: [{_id: 0, host: 'localhost:5005'}, {_id: 1, host: 'localhost:5006'}]});" >> init_rs0.bat
echo pause >> init_rs0.bat
start "" /wait cmd /c init_rs0.bat

echo Initializing second replica set...
echo @echo off > init_rs1.bat
echo "C:\Users\Thibeau\Desktop\mongosh\mongosh-2.3.2-win32-x64\bin\mongosh.exe" --port 5007 --eval "rs.initiate({_id: 'rs1', members: [{_id: 0, host: 'localhost:5007'}, {_id: 1, host: 'localhost:5008'}]});" >> init_rs1.bat
echo pause >> init_rs1.bat
start "" /wait cmd /c init_rs1.bat

echo Initializing third replica set...
echo @echo off > init_rs2.bat
echo "C:\Users\Thibeau\Desktop\mongosh\mongosh-2.3.2-win32-x64\bin\mongosh.exe" --port 5013 --eval "rs.initiate({_id: 'rs2', members: [{_id: 0, host: 'localhost:5013'}, {_id: 1, host: 'localhost:5014'}]});" >> init_rs2.bat
echo pause >> init_rs2.bat
start "" /wait cmd /c init_rs2.bat
```

### Config Servers starten
De config servers zijn essentieel voor het beheren en coördineren van de sharded cluster in MongoDB.
```batch
echo Starting config servers...
start "" "C:\Program Files\MongoDB\Server\8.0\bin\mongod.exe" --configsvr --replSet csrs --port 5009 --dbpath "C:\Users\Thibeau\Desktop\school\2024-2025\DB3\configdb\db1"
start "" "C:\Program Files\MongoDB\Server\8.0\bin\mongod.exe" --configsvr --replSet csrs --port 5010 --dbpath "C:\Users\Thibeau\Desktop\school\2024-2025\DB3\configdb\db2"
```

### Config Servers Replica Sets initialiseren
```batch
echo Initializing config server replica set...
echo @echo off > init_csrs.bat
echo "C:\Users\Thibeau\Desktop\mongosh\mongosh-2.3.2-win32-x64\bin\mongosh.exe" --port 5009 --eval "rs.initiate({_id: 'csrs', members: [{_id: 0, host: 'localhost:5009'}, {_id: 1, host: 'localhost:5010'}]});" >> init_csrs.bat
echo pause >> init_csrs.bat
start "" /wait cmd /c init_csrs.bat
```

### Mongos Router starten
De mongos router zorgt ervoor dat applicaties transparant kunnen communiceren met een sharded MongoDB cluster, zonder dat ze zich zorgen hoeven te maken over de onderliggende data verdeling.
```batch
start "" "C:\Program Files\MongoDB\Server\8.0\bin\mongos.exe" --configdb csrs/localhost:5009,localhost:5010 --port 5012 --logpath "C:\Users\Thibeau\Desktop\school\2024-2025\DB3\logs\mongos.log"
```

### Mongos Router status checken
```batch
echo Checking if mongos router is running...
curl -s http://localhost:5012/ >nul
if errorlevel 1 (
    echo Mongos server is not running. Exiting...
    echo Check the log file at C:\Users\Thibeau\Desktop\school\2024-2025\DB3\logs\mongos.log for more details.
    pause
    exit /b 1
) else (
    echo Mongos router is running on port 5012.
)
```

### Sharding toevoegen
Sharding wordt gebruikt om grote datasets efficiënt te beheren, prestaties te verbeteren, opslag te beheren en hoge beschikbaarheid te garanderen.
Ook is er gekozen om de collectie `rides` te sharden op basis van het veld `starttime`. 
Dit was de beste keuze omdat we aan time-based sharding doen. Deze is ook hash-based, wat betekent dat de data gelijkmatig verdeeld wordt over de shards.
```batch
echo Configuring sharding and setting shard key...
echo @echo off > config_sharding.bat
echo "C:\Users\Thibeau\Desktop\mongosh\mongosh-2.3.2-win32-x64\bin\mongosh.exe" --port 5012 --eval "sh.addShard('rs0/localhost:5005,localhost:5006'); sh.addShard('rs1/localhost:5007,localhost:5008'); sh.addShard('rs2/localhost:5013,localhost:5014'); sh.enableSharding('dbForMongo'); sh.shardCollection('dbForMongo.rides', { starttime: 'hashed'});" >> config_sharding.bat
echo pause >> config_sharding.bat
start "" /wait cmd /c config_sharding.bat
```

### Balancer opstarten
Balanceren is het proces waarbij MongoDB gegevens tussen shards verplaatst om de belasting te verdelen en de prestaties te optimaliseren.
```batch
echo Enabling balancer...
echo @echo off > enable_balancer.bat
echo "C:\Users\Thibeau\Desktop\mongosh\mongosh-2.3.2-win32-x64\bin\mongosh.exe" --port 5012 --eval "sh.setBalancerState(true);" >> enable_balancer.bat
echo pause >> enable_balancer.bat
start "" /wait cmd /c enable_balancer.bat
```

### Data importeren
De optie `--batchSize` wordt gebruikt om de hoeveelheid data die in één keer wordt geïmporteerd te beperken. Dit kan handig zijn bij het importeren van grote datasets.
```batch
echo Importing JSON data...
for %%f in ("C:\School\2024-2025\DB3\TDR_17_thibeau-tim\spark-warehouse\rides_vehicles\*.json") do (
    echo Importing file %%f
    mongoimport --host localhost --port 5012 --db dbForMongo --collection rides --file "%%f" --batchSize 10000
    if errorlevel 1 (
        echo Data import failed for file %%f. Please check the file path and format.
        pause
        exit /b 1
    )
)
```

## Shard status checken
Open de router (5012) met behulp van volgende scriptje:
[5012_router_mongosh_opstarten.bat](5012_router_mongosh_opstarten.bat)

Eens je in terminal zit, kan je volgende commando's uitvoeren:
```bash
sh.status(true)
```
![sh_status.png](..%2F..%2FFileStore%2Fimages%2Fsh_status.png)

## Replicatie nakijken
Open één van de replica set servers (5005, 5006, 5007, 5008, 5013, 5014) met behulp van volgende scriptjes:\
[5005_rs0_mongosh_opstarten.bat](5005_rs0_mongosh_opstarten.bat) \
[5007_rs1_mongosh_opstarten.bat](5007_rs1_mongosh_opstarten.bat) \
[5013_rs2_mongosh_opstarten.bat](5013_rs2_mongosh_opstarten.bat)

Eens je in terminal zit, kan je volgende commando's uitvoeren:
```bash
rs.status(true)
```
![rs_status.png](..%2F..%2FFileStore%2Fimages%2Frs_status.png)

## Controleren van de Shard Distribution
```bash
db.rides.getShardDistribution()
```
![shard_distribution.png](..%2F..%2FFileStore%2Fimages%2Fshard_distribution.png)

# Queries

## Specifieke periode
```bash
db.rides.find({ starttime: { 
  $gte: '2023-01-15T23:59:32.000+02:00', 
  $lte: '2023-12-15T23:59:32.000+02:00' 
  }}).limit(3)
```
![query_specific_period.png](..%2F..%2FFileStore%2Fimages%2Fquery_specific_period.png)

## Ritten tellen per voertuig
```bash
db.rides.aggregate([
    { $group: { _id: "$vehicleid", count: { $sum: 1 } } },
    { $sort: { count: -1 } }
])
```
![query_specific_period.png](..%2F..%2FFileStore%2Fimages%2Fquery_specific_period.png)

## Langste ritten op tijdsduur
```bash
db.rides.aggregate([
    {
        $addFields: {
            starttime: { $dateFromString: { dateString: "$starttime" } },
            endtime: { $dateFromString: { dateString: "$endtime" } }
        }
    },
    {
        $project: {
            rideid: 1,
            vehicleid: 1,
            duration: { $subtract: ["$endtime", "$starttime"] }
        }
    },
    { $sort: { duration: -1 } },
    { $limit: 3 }
])
```
![langste_ritten_op_tijdsduur.png](..%2F..%2FFileStore%2Fimages%2Flangste_ritten_op_tijdsduur.png)

## Gemiddelde ritduur per voertuig
```bash
db.rides.aggregate([
    {
        $addFields: {
            starttime: { $dateFromString: { dateString: "$starttime" } },
            endtime: { $dateFromString: { dateString: "$endtime" } }
        }
    },
    {
        $project: {
            vehicleid: 1,
            duration: { $subtract: ["$endtime", "$starttime"] }
        }
    },
    {
        $group: {
            _id: "$vehicleid",
            avgDuration: { $avg: "$duration" }
        }
    },
    { $sort: { avgDuration: -1 } },
    { $limit: 5 }
])

```
![avg_ritduur_voertuig.png](..%2F..%2FFileStore%2Fimages%2Favg_ritduur_voertuig.png)



# Conclusie
MongoDB is een krachtige NoSQL-database die flexibiliteit, schaalbaarheid en prestaties biedt voor het opslaan en beheren van grote hoeveelheden gegevens. Door gebruik te maken van replica sets en sharding, kunnen we de beschikbaarheid en prestaties van onze database verbeteren en grote datasets efficiënt beheren. MongoDB is een uitstekende keuze voor toepassingen waarbij flexibiliteit en schaalbaarheid belangrijk zijn, zoals webtoepassingen, IoT-toepassingen en big data-analyse.



# No hacking needed when you have MongoDB, leave the tricks for Neo4j!
![cyberpunk2077-edgerunners.gif](..%2F..%2FFileStore%2Fimages%2Fcyberpunk2077-edgerunners.gif) \
