# BBP API

### TODO LIST
Link to Rocket
Link to sqlx
OpenAPI spec
Add a bind for Rcommand + U to delete (function + delete?)
Create script for inserting data to containerized db on startup.

### Getting Started
You can run the database locally using the provided docker-compose file

```SHELL
docker-compose up -d
```

What packages need to be installed?
- sqlx-cli???

Install the sqlx-cli using cargo. Need to add the cargo bin folder to your path to be able to use the cli.
```SHELL
cargo install sqlx-cli
```

Rename these files so that rocket and sqlx know to point to the postgres instance running in docker
rename ```.env.local``` to ```.env```
rename ```rocket.toml.local``` to ```rocket.toml```

Open pgadmin and login with dbuser@bbp.com/password. Connect to the server, give it any name, and then the hostname, username, and password should all just be ```postgres```.