#!/bin/bash

clear
echo -e "Please select : \n"
echo -e " (1) to start the development server with a fresh build"
echo -e " (2) to start the development server"
echo -e " (3) to start the tailwindcss:watch service"
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

    *)
    echo -n "unknown choice"
    ;;
esac
