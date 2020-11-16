#!/bin/sh

# exit when any command fails
set -e

echo "generating config/secrets.yml"
cat << END > config/secrets.yml
development:
    secret_key_base: "$(rake secret)"
END
# HERE DOCKER ERROR: for simplelibarysystem_db_1  Cannot start service db: network simplelibarysystem_default is ambiguous (2 matches found on name)

#ERROR: for db  Cannot start service db: network simplelibarysystem_default is ambiguous (2 matches found on name)
#ERROR: Encountered errors while bringing up the project
#echo "setup container"
#docker-compose build
echo "start server"
docker-compose up
#echo "rake db:migrate"
#docker-compose run app db:migrate
#echo "rake db:seed"
#docker-compose run app db:seed
