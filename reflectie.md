#   Data Persistencie - Project Velo
### 2024 - 2025
####
###### Student 1
* Naam: Thibeau Colman
* klasgroep: IAO
* Studentennummer: 0154170-37
###### Student 2
* Naam: Tim Hofman
* klasgroep: IAO
* Studentennummer: 0156186-16


## Status
Wij denken dat we alles hebben gedaan wat we voor 07/10 moesten doen.
De opdracht is vrij onduidelijk van wat we precies moeten doen of op welke of welke data we precies nodig hebben.
Onze samenwerking verloopt vlot en zoals het hoort. (´｡• ω •｡`)

We hebben waarschijnlijk wel minstens 80 procent van de opdracht (hopelijk) juist gedaan.


## na vergadering
### dim_date
Recentere begin datum

### dim_weather
Verschil aangenaam en neutraal via temperatuur berekenen.

### dim_klant
Slowly changing incremental run toepassen + bewijs (kijken of nieuwe rij bij een aanpassing)
op address (if name geen nieuwe rij)

slowly changing type 1 op name

### dim_slot
Iets toevoegen als er geen slot is

In ons fact ook eindslot toevoegen


## TODO
- [x] fact cleanup 
- [x] "geen slot" in `dim_slot` when `biketypedescription = "step"` 
- [x] slowly changing incremental run toepassen + bewijs (kijken of nieuwe rij bij een aanpassing)
- [ ] slowly changing type 1 op name --optioneel
- [x] Verschil aangenaam en neutraal via temperatuur berekenen.
- [x] Recentere begin datum
- [x] In ons fact ook eindslot toevoegen
- [x] In fact: `weather` join aanpassen naar `dim_weather`
- [x] In fact: when `no weather found` -> `dim_weather` -> `weather_id = 4`
- [x] Query en analyse files herwerken (niet alles op fact)



## Voor vergadering 2
### Status
We denken dat we de feedback van vorige vergadering juist hebben toegepast.
Naast dat hebben we ook de opdracht van NoSQL afgewerkt.

#### MongoDB (Thibeau)
Ik denk dat alles wat in de opdracht stond is verwerkt en alles werkt via scripts.
Ik weet wel niet zeker of het aanmaken van mijn json juist heb gedaan.

#### Neo4j (Tim)
Ik heb besloten om mijn json data op te vragen via een python server en vervolgens heb ik nodes gemaakt van user, ride, station en vehicle.
Ik heb denk ik de volledige opdracht verwerkt, het enige wat ik niet heb gedaan was de vraag waar ik een bepaald uur nodig had omdat deze nergens in mijn json zat en ik ook geen datatype had waar een geldige tijd in zat.



## Voor vergadering 3
### Status
We denken dat we de feedback van vorige vergadering juist hebben toegepast.
Daarnaast ook de laatste loodjes gelegd aan Neo4j en MongoDB.

Nu op het einde van het project hopen we dat alles juist is afgewerkt en dat we alles hebben gedaan wat we moesten doen.
