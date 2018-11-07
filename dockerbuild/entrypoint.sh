#!/bin/bash

sed -i “s/#listen_addresses = ‘localhost’/listen_addresses = ‘*’/” /etc/postgresql/11/main/postgresql.conf
service postgresql start
su - postgres -c "psql -c \"ALTER USER postgres WITH PASSWORD 'password';\""
su - postgres -c "createdb eccube_db"

init_container.sh
