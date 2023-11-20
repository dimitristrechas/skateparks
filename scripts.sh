#!/bin/bash

clear
echo -e "Please select : \n"
echo -e " (1) to start the development server with a fresh build"
echo -e " (2) to start the development server"
read OPTION

case $OPTION in

    1)
    docker compose -f ./docker-compose.yml -f ./docker-compose.development.yml up --remove-orphans --build --force-recreate
    ;;

    2)
    docker compose -f ./docker-compose.yml -f ./docker-compose.development.yml up
    ;;

    *)
    echo -n "unknown choice"
    ;;
esac
