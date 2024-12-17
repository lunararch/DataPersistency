@echo off
setlocal EnableDelayedExpansion

REM Stel het aantal chunks in dat je wilt aanmaken
set DESIRED_CHUNKS=21

REM Verwijder de bestaande replica set servers, config servers en mongos server
echo Removing existing MongoDB servers...
call "C:\Users\Thibeau\Desktop\verwijder_data_mongo.bat"

REM Voeg MongoDB binaries toe aan de PATH-variabele
set PATH=%PATH%;C:\Program Files\MongoDB\Server\8.0\bin

REM Start de eerste replica set servers
echo Starting first replica set servers...
start "" "C:\Program Files\MongoDB\Server\8.0\bin\mongod.exe" --replSet rs0 --shardsvr --dbpath "C:\Users\Thibeau\Desktop\school\2024-2025\DB3\datastorage\db1" --port 5005
start "" "C:\Program Files\MongoDB\Server\8.0\bin\mongod.exe" --replSet rs0 --shardsvr --dbpath "C:\Users\Thibeau\Desktop\school\2024-2025\DB3\datastorage\db2" --port 5006

REM Start de tweede replica set servers
echo Starting second replica set servers...
start "" "C:\Program Files\MongoDB\Server\8.0\bin\mongod.exe" --replSet rs1 --shardsvr --dbpath "C:\Users\Thibeau\Desktop\school\2024-2025\DB3\datastorage\db3" --port 5007
start "" "C:\Program Files\MongoDB\Server\8.0\bin\mongod.exe" --replSet rs1 --shardsvr --dbpath "C:\Users\Thibeau\Desktop\school\2024-2025\DB3\datastorage\db4" --port 5008

REM Start de derde replica set servers
echo Starting third replica set servers...
start "" "C:\Program Files\MongoDB\Server\8.0\bin\mongod.exe" --replSet rs2 --shardsvr --dbpath "C:\Users\Thibeau\Desktop\school\2024-2025\DB3\datastorage\db5" --port 5013
start "" "C:\Program Files\MongoDB\Server\8.0\bin\mongod.exe" --replSet rs2 --shardsvr --dbpath "C:\Users\Thibeau\Desktop\school\2024-2025\DB3\datastorage\db6" --port 5014

REM Wacht een paar seconden om ervoor te zorgen dat de replica set servers zijn gestart
echo Waiting for replica set servers to start...
timeout /t 2

REM Initialiseer de eerste replica set
echo Initializing first replica set...
echo @echo off > init_rs0.bat
echo "C:\Users\Thibeau\Desktop\mongosh\mongosh-2.3.2-win32-x64\bin\mongosh.exe" --port 5005 --eval "rs.initiate({_id: 'rs0', members: [{_id: 0, host: 'localhost:5005'}, {_id: 1, host: 'localhost:5006'}]});" >> init_rs0.bat
echo pause >> init_rs0.bat
start "" /wait cmd /c init_rs0.bat

REM Initialiseer de tweede replica set
echo Initializing second replica set...
echo @echo off > init_rs1.bat
echo "C:\Users\Thibeau\Desktop\mongosh\mongosh-2.3.2-win32-x64\bin\mongosh.exe" --port 5007 --eval "rs.initiate({_id: 'rs1', members: [{_id: 0, host: 'localhost:5007'}, {_id: 1, host: 'localhost:5008'}]});" >> init_rs1.bat
echo pause >> init_rs1.bat
start "" /wait cmd /c init_rs1.bat

REM Initialiseer de derde replica set
echo Initializing third replica set...
echo @echo off > init_rs2.bat
echo "C:\Users\Thibeau\Desktop\mongosh\mongosh-2.3.2-win32-x64\bin\mongosh.exe" --port 5013 --eval "rs.initiate({_id: 'rs2', members: [{_id: 0, host: 'localhost:5013'}, {_id: 1, host: 'localhost:5014'}]});" >> init_rs2.bat
echo pause >> init_rs2.bat
start "" /wait cmd /c init_rs2.bat

REM Start de config servers
echo Starting config servers...
start "" "C:\Program Files\MongoDB\Server\8.0\bin\mongod.exe" --configsvr --replSet csrs --port 5009 --dbpath "C:\Users\Thibeau\Desktop\school\2024-2025\DB3\configdb\db1"
start "" "C:\Program Files\MongoDB\Server\8.0\bin\mongod.exe" --configsvr --replSet csrs --port 5010 --dbpath "C:\Users\Thibeau\Desktop\school\2024-2025\DB3\configdb\db2"

REM Wacht opnieuw een paar seconden voor de config servers
echo Waiting for config servers to start...
timeout /t 2

REM Initialiseer de config server replica set
echo Initializing config server replica set...
echo @echo off > init_csrs.bat
echo "C:\Users\Thibeau\Desktop\mongosh\mongosh-2.3.2-win32-x64\bin\mongosh.exe" --port 5009 --eval "rs.initiate({_id: 'csrs', members: [{_id: 0, host: 'localhost:5009'}, {_id: 1, host: 'localhost:5010'}]});" >> init_csrs.bat
echo pause >> init_csrs.bat
start "" /wait cmd /c init_csrs.bat

REM Wacht een paar seconden om ervoor te zorgen dat de config server replica set is geïnitialiseerd
echo Waiting for config server replica set to initialize...
timeout /t 2

REM Controleer de status van de config server replica set
echo Checking config server replica set status...
echo @echo off > check_csrs.bat
echo "C:\Users\Thibeau\Desktop\mongosh\mongosh-2.3.2-win32-x64\bin\mongosh.exe" --port 5009 --eval "rs.status();" >> check_csrs.bat
echo pause >> check_csrs.bat
start "" /wait cmd /c check_csrs.bat

REM Start de mongos server
echo Starting mongos router...
start "" "C:\Program Files\MongoDB\Server\8.0\bin\mongos.exe" --configdb csrs/localhost:5009,localhost:5010 --port 5012 --logpath "C:\Users\Thibeau\Desktop\school\2024-2025\DB3\logs\mongos.log"

REM Wacht een paar seconden om ervoor te zorgen dat mongos is gestart
echo Waiting for mongos router to start...
timeout /t 10

REM Controleer of de mongos server draait
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

REM Configureer sharding en stel de shard key in
echo Configuring sharding and setting shard key...
echo @echo off > config_sharding.bat
echo "C:\Users\Thibeau\Desktop\mongosh\mongosh-2.3.2-win32-x64\bin\mongosh.exe" --port 5012 --eval "sh.addShard('rs0/localhost:5005,localhost:5006'); sh.addShard('rs1/localhost:5007,localhost:5008'); sh.addShard('rs2/localhost:5013,localhost:5014'); sh.enableSharding('dbForMongo'); sh.shardCollection('dbForMongo.rides', { starttime: 'hashed'});" >> config_sharding.bat
echo pause >> config_sharding.bat
start "" /wait cmd /c config_sharding.bat

REM Schakel de balancer in
echo Enabling balancer...
echo @echo off > enable_balancer.bat
echo "C:\Users\Thibeau\Desktop\mongosh\mongosh-2.3.2-win32-x64\bin\mongosh.exe" --port 5012 --eval "sh.setBalancerState(true);" >> enable_balancer.bat
echo pause >> enable_balancer.bat
start "" /wait cmd /c enable_balancer.bat

REM Importeer JSON-data
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

REM Dit script is klaar
echo Script execution completed.
@echo off
