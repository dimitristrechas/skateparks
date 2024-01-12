#!/bin/bash

clear
echo -e "Please select : \n"
echo -e " (1) to start the development server with a fresh build"
echo -e " (2) to start the development server"
echo -e " (3) to start the tailwindcss:watch service"
echo -e " (4) to delete server.pid"
echo -e " (5) to open rails console in docker"
read OPTION

case $OPTION in

    1)
    docker compose -f ./docker-compose.yml -f ./docker-compose.development.yml up --remove-orphans --build --force-recreate
    ;;

    2)
    docker compose -f ./docker-compose.yml -f ./docker-compose.development.yml up
    ;;

    3)
    rails tailwindcss:watch
    ;;

    4)
    rm tmp/pids/server.pid
    ;;

    5)
    docker compose exec skateparks bundle exec rails console
    ;;

    *)
    echo -n "unknown choice"
    ;;
esac
