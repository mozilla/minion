#!/bin/bash

#
# make.sh <clone|setup|run-frontend|run-backend|run-scan-worker|run-state-worker|run-plugin-worker>
#
# This script is really just for development only. It makes it easier to
# checkout the depend projects and to set them up in a virtualenv.
#
PROJECTS="backend frontend"

if [ "$(id -u)" == "0" ]; then
    echo "abort: cannot run as root."
    exit 1
fi

if [ ! `which virtualenv` ]; then
    echo "abort: no virtualenv found"
fi

if [ ! `which python2.7` ]; then
    echo "abort: no python2.7 found"
fi

if [ ! -z "$VIRTUAL_ENV" ]; then
    echo "abort: cannot run from an existing virtual environment"
    exit 1
fi

case $1 in
    clone)
        for project in $PROJECTS; do
            if [ ! -d "minion-$project" ]; then
                git clone --recursive "https://github.com/mozilla/minion-$project" || exit 1
            fi
        done
        ;;
    setup)
        # Create our virtualenv
        if [ ! -d "env" ]; then
            virtualenv -p python2.7 --no-site-packages env || exit 1
        fi
        # Activate our virtualenv
        source env/bin/activate
        for project in $PROJECTS; do
            if [ -x "minion-$project/setup.sh" ]; then
				(cd "minion-$project"; "./setup.sh" develop) || exit 1
            fi
        done
        ;;
    run-backend-api)
        source env/bin/activate
        minion-backend/scripts/minion-backend-api
        ;;
    run-frontend)
        source env/bin/activate
        minion-frontend/scripts/minion-frontend runserver
        ;;
    run-scan-worker)
        source env/bin/activate
        minion-backend/scripts/minion-scan-worker
        ;;
    run-state-worker)
        source env/bin/activate
        minion-backend/scripts/minion-state-worker
        ;;
    run-plugin-worker)
        source env/bin/activate
        minion-backend/scripts/minion-plugin-worker
        ;;
    *)
        echo "Usage : $0 <clone|setup|run-backend|run-frontend>"
        ;;
esac
