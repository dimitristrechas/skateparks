#!/bin/bash

clear
echo -e "--- DEVELOPMENT SERVER --"
echo -e " (1) to start the development server (detached)"
echo -e " (2) to delete server pid"
echo -e " (3) to start the development server with a fresh build (detached)"
echo -e " (4) to attach in docker development server"
echo -e " (5) rails console (for querying the database)"
echo -e " (6) connect to docker console"
echo -e " \n"
echo -e "--- TEST SERVER --"
echo -e " (7) to start the test server (detached)"
echo -e " (8) to start the test server with a fresh build (detached)"
echo -e " (9) connect to test docker console"
echo -e " (10) to delete test server pid"
echo -e " \n"
echo -e "--- UTILITY --"
echo -e " (11) to format all the erb files with erb-format"
read OPTION

case $OPTION in

    1)
    docker compose -f ./docker-compose.development.yml start
    ;;

    2)
    rm tmp/pids/server.pid
    ;;

    3)
    docker compose -f ./docker-compose.development.yml up --remove-orphans --build --force-recreate -d
    ;;

    4)
    docker attach rails-app
    ;;

    5)
    docker compose -f ./docker-compose.development.yml exec skateparks-web bundle exec rails console
    ;;

    6)
    docker compose -f ./docker-compose.development.yml exec skateparks-web bash
    ;;

    7)
    docker compose -f ./docker-compose.test.yml start
    ;;

    8)
    docker compose -f ./docker-compose.test.yml --env-file ./.env.test up --remove-orphans --build --force-recreate -d
    ;;

    9)
    docker compose -f ./docker-compose.test.yml exec skateparks-web-test bash
    ;;

    10)
    rm tmp/pids/server_test.pid
    ;;

    11)
    bundle exec erb-format -w app/views/**/*.erb
    ;;

    *)
    echo -n "unknown choice"
    ;;
esac
