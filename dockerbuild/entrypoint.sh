#!/bin/bash

service postgresql start
su - postgres -c "createuser -s eccube_db_user"
su - postgres -c "psql -c \"ALTER USER eccube_db_user WITH PASSWORD 'password';\""
su - postgres -c "createdb -U eccube_db_user eccube_db"

init_container.sh
