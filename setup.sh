#!/bin/bash

set -x

#
# make.sh <clone|setup|run-plugin-service|run-task-engine>
#
# This script is really just for development only. It makes it easier to
# checkout the depend projects and to set them up in a virtualenv.
#

PROJECTS="core nmap-plugin zap-plugin skipfish-plugin garmr-plugin frontend"

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
                git clone --recursive "https://github.com/st3fan/minion-$project" || exit 1
            fi
        done
        ;;
    develop)
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
    run-plugin-service)
        source env/bin/activate
        minion-core/plugin-service/scripts/minion-plugin-service
        ;;
    run-task-engine)
        source env/bin/activate
        minion-core/task-engine/scripts/minion-task-engine
        ;;
    run-frontend)
        source env/bin/activate
        (cd minion-frontend && python manage.py syncdb) || exit 1
        (cd minion-frontend && python manage.py runserver 0.0.0.0:8000) || exit 1
        ;;
esac
