# Neo4j dossier


## Wat is Neo4j?
Neo4j is een open-source, grafgeoriënteerde database die is ontworpen voor het opslaan en beheren van gegevens in de vorm van knooppunten en relaties. Het is een van de meest populaire NoSQL-databases en wordt veel gebruikt in toepassingen waarbij complexe relaties en netwerken belangrijk zijn.

## Waarom Neo4j?
Neo4j biedt verschillende voordelen ten opzichte van traditionele relationele databases, waaronder:

- **Flexibiliteit**: Neo4j is een grafgeoriënteerde database, wat betekent dat het gegevens opslaat in de vorm van knooppunten en relaties. Dit maakt het gemakkelijk om complexe relaties en netwerken te modelleren en te beheren.
- **Schaalbaarheid**: Neo4j is ontworpen om te schalen en kan eenvoudig worden opgeschaald om te voldoen aan de behoeften van groeiende toepassingen. Het ondersteunt zowel horizontale als verticale schaling, waardoor het gemakkelijk is om de prestaties van een toepassing te verbeteren naarmate het aantal gebruikers en gegevens groeit.
- **Snelheid**: Neo4j is ontworpen voor hoge prestaties en biedt snelle lees- en schrijfoperaties. Het maakt gebruik van geavanceerde indexering en query-engine om snelle toegang tot gegevens te bieden, zelfs bij grote gegevenssets.
- **Krachtige query-taal**: Neo4j maakt gebruik van de Cypher-querytaal, die is ontworpen voor het werken met grafgegevens. Cypher biedt een eenvoud
- **Geavanceerde analyse en visualisatie**: Neo4j biedt geavanceerde analysemogelijkheden en ingebouwde visualisatietools om inzicht te krijgen in de structuur en relaties van gegevens.


## Hoe werkt Neo4j
Neo4j werkt op basis van knooppunten en relaties, die samen een graf vormen. Knooppunten vertegenwoordigen entiteiten zoals personen, plaatsen of dingen, terwijl relaties de verbindingen tussen deze entiteiten weergeven. Knooppunten en relaties kunnen eigenschappen bevatten die de kenmerken van de entiteiten en verbindingen beschrijven.

Neo4j maakt gebruik van een eigenschappen grafmodel, waarbij zowel knooppunten als relaties eigenschappen kunnen bevatten. Dit maakt het mogelijk om gegevens op een flexibele en gestructureerde manier op te slaan en te beheren.


## Start Neo4j
[openNeo4jTerminal.bat](openNeo4jTerminal.bat)
```batch
@echo off
cd /d "C:\school\KDG-4\DPTools\neo4j-community-5.24.1"
bin\neo4j-admin server console
```

## Start Python server
[S2_CAUSUS_2_STARTSERVER.ipynb](..%2F..%2FS2_CAUSUS_2_STARTSERVER.ipynb)
```batch
```jupyter
import http.server
import socketserver

PORT = 8000

Handler = http.server.SimpleHTTPRequestHandler

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print(f"Serving at port {PORT}")
    httpd.serve_forever()
```

Of in terminal
```batch
python -m http.server 8000
```

## load json data in Neo4j
```cypher
CALL apoc.load.json("http://localhost:8000/spark-warehouse/jsonFilesSmallV3/part-00000-718403e5-1656-437d-9dd7-aae98f848dea-c000.json") YIELD value
WITH DISTINCT value

MERGE (start:Station {id: toInteger(value.startstationid)})
  ON CREATE SET start.name = value.startnumber, start.zipcode = value.startzipcode

MERGE (end:Station {id: toInteger(value.endstationid)})
  ON CREATE SET end.name = value.endnumber, end.zipcode = value.endzipcode

MERGE (user:Gebruiker {id: toInteger(value.userid)})
  ON CREATE SET user.address = value.address

MERGE (vehicle:Voertuig {id: toInteger(value.vehicleid)})
  ON CREATE SET vehicle.serialNumber = value.serialnumber

MERGE (startBuurt:Buurt {zipcode: value.startzipcode})

MERGE (endBuurt:Buurt {zipcode: value.endzipcode})

MERGE (rit:Rit {id: toInteger(value.rideid)})
  ON CREATE SET 
    rit.startTime = datetime(value.starttime),
    rit.endTime = datetime(value.endtime)

MERGE (user)-[:MAAKTE]->(rit)
MERGE (rit)-[:BEGON_BIJ]->(start)
MERGE (rit)-[:EINDIGDE_BIJ]->(end)
MERGE (rit)-[:GEBRUIKTE]->(vehicle)
MERGE (start)-[:IN_BUURT]->(startBuurt)
MERGE (end)-[:IN_BUURT]->(endBuurt)
```

## Leg uit welke keuzes je hebt gemaakt bij het linken van de gegevens. Hoe kwamen die links in de database?
### Nodes
- Station: Gebaseerd op 'startstationid' en 'endstationid'
- Buurt: Gebaseerd op 'startzipcode' en 'endzipcode'
- Gebruiker: Gebaseerd op 'userid'
- Voertuig: Gebaseerd op 'vehicleid'
- Rit: Gebaseerd op 'rideid'

### Relaties
- (Gebruiker)-[:MAAKTE]->(Rit): Verbindt een gebruiker met de rit die hij/zij heeft gemaakt
- (Rit)-[:BEGON_BIJ]->(Station): Verbindt een rit met het startstation
- (Rit)-[:EINDIGDE_BIJ]->(Station): Verbindt een rit met het eindstation
- (Rit)-[:GEBRUIKTE]->(Voertuig): Verbindt een rit met het gebruikte voertuig
- (Station)-[:IN_BUURT]->(Buurt): Verbindt een station met de buurt waarin het zich bevindt

### Deze links kwamen in de database door de volgende stappen:
1. De JSON-gegevens werden geladen met behulp van de apoc.load.json-procedure.
2. Voor elke unieke waarde in de JSON-gegevens werden knooppunten gemaakt voor de entiteiten (Station, Buurt, Gebruiker, Voertuig, Rit).
3. De relaties werden gemaakt met behulp van de MERGE-clausule om dubbele knooppunten en relaties te voorkomen.

#### Voor elke rit in de data:
- De start- en eindstations werden gelinkt aan de rit met de BEGON_BIJ en EINDIGDE_BIJ relaties.
- De gebruiker werd gelinkt aan de rit met de MAAKTE relatie.
- Het voertuig werd gelinkt aan de rit met de GEBRUIKTE relatie.
- De stations werden gelinkt aan hun respectievelijke buurten met de IN_BUURT relatie.

#### Deze aanpak zorgde ervoor dat:
- Elk uniek element (station, gebruiker, voertuig, buurt) slechts één keer in de database voorkomt.
- Alle relevante verbindingen tussen elementen worden vastgelegd.
- De datastructuur de werkelijke relaties in het fietsdeelsysteem weerspiegelt.


## Kan je ons een query geven waaruit je visueel het resultaat kan afleiden.
```cypher
MATCH (u:Gebruiker)-[r1:MAAKTE]->(rit:Rit)-[r2:GEBRUIKTE]->(v:Voertuig),
      (rit)-[r3:BEGON_BIJ]->(start:Station)-[r4:IN_BUURT]->(startBuurt:Buurt),
      (rit)-[r5:EINDIGDE_BIJ]->(eind:Station)-[r6:IN_BUURT]->(eindBuurt:Buurt)
WHERE startBuurt <> eindBuurt
WITH u, rit, v, start, eind, startBuurt, eindBuurt, 
     duration.between(rit.startTime, rit.endTime).minutes AS ritDuur
WHERE ritDuur > 5
RETURN u, rit, v, start, eind, startBuurt, eindBuurt, ritDuur
LIMIT 10
```
![VisueelResultaat.png](..%2F..%2FFileStore%2Fimages%2FVisueelResultaat.png)
[VisueelResultaat.csv](..%2F..%2FFileStore%2Fimages%2FVisueelResultaat.csv)

### Uitleg query
1. Het zoekt naar gebruikers die ritten hebben gemaakt met specifieke voertuigen.
2. Het koppelt deze ritten aan start- en eindstations, en de bijbehorende buurten.
3. Het filtert op ritten tussen verschillende buurten.
4. Het berekent de duur van elke rit in minuten.
5. Het filtert ritten die langer dan 5 minuten duurden om korte ritten uit te sluiten.
6. Het retourneert alle relevante nodes en hun onderlinge relaties.

### Uitleg resultaat
- Gebruikers (Gebruiker nodes)
- Ritten (Rit nodes)
- Voertuigen (Voertuig nodes)
- Stations (Station nodes)
- Buurten (Buurt nodes)
- De relaties tussen deze entiteiten:
  - MAAKTE tussen Gebruiker en Rit
  - GEBRUIKTE tussen Rit en Voertuig
  - BEGON_BIJ en EINDIGDE_BIJ tussen Rit en Station
  - IN_BUURT tussen Station en Buurt

\
Deze visualisatie zal een complex netwerk tonen dat de interacties tussen verschillende componenten van het fietsdeelsysteem weergeeft. Je kunt de volgende inzichten verkrijgen:
- Hoe gebruikers zich bewegen tussen verschillende buurten
- Welke voertuigen worden gebruikt voor specifieke ritten
- De connecties tussen stations en buurten
- Patronen in het gebruik van het fietsdeelsysteem

## Query data in Neo4j
### Welk zijn de meest gebruikte voertuigen?
```cypher
MATCH (v:Voertuig)<-[:GEBRUIKTE]-(r:Rit)
RETURN v.id AS voertuigId, COUNT(r) AS aantalRitten
ORDER BY aantalRitten DESC
LIMIT 10
```
![MostUsedVehicle](..%2F..%2FFileStore%2Fimages%2FMostUsedVehicle.png)

### Identificeer voor een bepaald station, voor een bepaald uur naar welke buurt fietsers voornamelijk rijden.
```cypher
MATCH (start:Station {id: 39})-[:IN_BUURT]->(startBuurt:Buurt),
      (r:Rit)-[:BEGON_BIJ]->(start),
      (r)-[:EINDIGDE_BIJ]->(end:Station)-[:IN_BUURT]->(endBuurt:Buurt)
WHERE datetime(r.startTime).hour = 12
RETURN endBuurt.zipcode AS doelBuurt, COUNT(*) AS aantalRitten
ORDER BY aantalRitten DESC
LIMIT 5
```
![CyclingToStation.png](..%2F..%2FFileStore%2Fimages%2FCyclingToStation.png)

### Ga na welke buurten het sterkst met elkaar verbonden zijn.
```cypher
MATCH (startBuurt:Buurt)<-[:IN_BUURT]-(start:Station)<-[:BEGON_BIJ]-(r:Rit)-[:EINDIGDE_BIJ]->(end:Station)-[:IN_BUURT]->(endBuurt:Buurt)
WHERE startBuurt <> endBuurt
RETURN startBuurt.zipcode AS vanBuurt, endBuurt.zipcode AS naarBuurt, COUNT(*) AS aantalRitten
ORDER BY aantalRitten DESC
LIMIT 10
```
![BesteBuurt.png](..%2F..%2FFileStore%2Fimages%2FBesteBuurt.png)

### Custom Query
```cypher
MATCH path = (start:Station)-[:BEGON_BIJ|EINDIGDE_BIJ*..5]-(end:Station)
WHERE start.id = 39 AND end.id = 69
RETURN path
LIMIT 1
```
![Custom.png](..%2F..%2FFileStore%2Fimages%2FCustom.png)

#### Waarom is deze query bijna ondoenbaar in een relationele database?
1. Variabele padlengte: In een relationele database zou je voor elke mogelijke padlengte (1 tot 5 in dit geval) een aparte query moeten schrijven en deze combineren met UNION.
2. Bidirectionele relaties: De query zoekt in beide richtingen (BEGON_BIJ en EINDIGDE_BIJ). In SQL zou dit complexe JOIN-constructies vereisen.
3. Padrepresentatie: Het concept van een 'pad' als een reeks verbonden entiteiten is niet natuurlijk in relationele databases. Je zou complexe zelfjoins moeten gebruiken.
4. Performantie: Voor grote datasets zou deze query in een relationele database extreem traag kunnen zijn, omdat het aantal joins exponentieel toeneemt met de padlengte.
5. Flexibiliteit: Als je de maximale padlengte wilt wijzigen, is dat in Neo4j een simpele aanpassing van het getal 5. In SQL zou je de hele querystructuur moeten herzien.


## Conclusie
Neo4j is een krachtige en flexibele database die is ontworpen voor het werken met complexe relaties en netwerken. Het biedt geavanceerde mogelijkheden voor het modelleren, opslaan en beheren van gegevens in de vorm van grafen, waardoor het ideaal is voor toepassingen waarbij de structuur en relaties van gegevens belangrijk zijn.