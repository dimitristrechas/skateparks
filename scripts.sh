#!/bin/bash

clear
echo -e "--- DEVELOPMENT SERVER -- \n"
echo -e " (1) to start the development server with a fresh build (detached)"
echo -e " (2) to start the development server"
echo -e " (3) to start the tailwindcss:watch service"
echo -e " (4) to delete server pid"
echo -e " (5) rails console"
echo -e " (6) rails  cli"
echo -e "--- TEST SERVER -- \n"
echo -e " (7) to start the test server (detached)"
echo -e " (8) test rails  cli"
echo -e " (9) to delete test server pid"
read OPTION

case $OPTION in

    1)
    docker compose -f ./docker-compose.development.yml up --remove-orphans --build --force-recreate -d
    ;;

    2)
    docker compose -f ./docker-compose.development.yml up
    ;;

    3)
    rails tailwindcss:watch
    ;;

    4)
    rm tmp/pids/server.pid
    ;;

    5)
    docker compose -f ./docker-compose.development.yml exec skateparks-web bundle exec rails console
    ;;

    6)
    docker compose -f ./docker-compose.development.yml exec skateparks-web bash
    ;;

    7)
    docker compose -f ./docker-compose.test.yml --env-file ./.env.test up --remove-orphans --build --force-recreate -d
    ;;

    8)
    docker compose -f ./docker-compose.test.yml exec skateparks-web-test bash
    ;;

    9)
    rm tmp/pids/server_test.pid
    ;;

    *)
    echo -n "unknown choice"
    ;;
esac
