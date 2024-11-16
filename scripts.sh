#!/bin/bash

clear
echo -e "--- DEVELOPMENT SERVER --"
echo -e " (1) to start the development server"
echo -e " (2) to start the tailwindcss:watch service"
echo -e " (3) to delete server pid"
echo -e " (4) to start the development server with a fresh build (detached)"
echo -e " (5) to attach in docker development server"
echo -e " (6) rails console"
echo -e " (7) rails  cli"
echo -e " \n"
echo -e "--- TEST SERVER --"
echo -e " (8) to start the test server"
echo -e " (9) to start the test server with a fresh build (detached)"
echo -e " (10) test rails cli"
echo -e " (11) to delete test server pid"
read OPTION

case $OPTION in

    1)
    docker compose -f ./docker-compose.development.yml start
    ;;

    2)
    rails tailwindcss:watch
    ;;

    3)
    rm tmp/pids/server.pid
    ;;

    4)
    docker compose -f ./docker-compose.development.yml up --remove-orphans --build --force-recreate -d
    ;;

    5)
    docker attach rails-app
    ;;

    6)
    docker compose -f ./docker-compose.development.yml exec skateparks-web bundle exec rails console
    ;;

    7)
    docker compose -f ./docker-compose.development.yml exec skateparks-web bash
    ;;

    8)
    docker compose -f ./docker-compose.test.yml start
    ;;

    9)
    docker compose -f ./docker-compose.test.yml --env-file ./.env.test up --remove-orphans --build --force-recreate -d
    ;;

    10)
    docker compose -f ./docker-compose.test.yml exec skateparks-web-test bash
    ;;

    11)
    rm tmp/pids/server_test.pid
    ;;

    *)
    echo -n "unknown choice"
    ;;
esac
