# PA036-2017-project



## Requirements
* PGSQL
* HAMMER_DB
* (optional) Docker


## Initialization
### Using **bash**:
* Run: ``$ ./start.sh -h`` for help
* You need to know where hammer db is installed. You have to use it's bundled tclsh.
* You can either edit ``start.sh`` or provide sufficient arguments
* Init DB will initialize database calling ``create.tcl``, which has been modified to accept command line arguments.
* You need to setup variables properly ``hostname, username, pass, ...``


## Initialization using docker (optional):

## DEFAULT PROPERTIES:
CONTAINER_NAME="pgdb"
IMAGE_NAME="postgres:latest"
PORT=5432
USER="postgres"
PASS="postgres"
DAEMON="-d"
```

* After you have container running, you should run initialization of the database.





