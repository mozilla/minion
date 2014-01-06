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

# Default optional argument values
a="0.0.0.0"
ROOT="."

while getopts ":a:p:x:" opt; do
    case "$opt" in
        a) a=${OPTARG};;
        p) p=${OPTARG};;
        x) ROOT=${OPTARG%/};;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done

# move the last argument to first positional argument
shift $(($# - 1))
case $1 in
    clone)
        for project in $PROJECTS; do
            if [ ! -d "minion-$project" ]; then
                git clone --recursive "https://github.com/mozilla/minion-$project" "$ROOT/minion-$project" || exit 1
            fi
        done
        ;;
    develop)
        # Create our virtualenv
        if [ ! -d "env" ]; then
                virtualenv -p python2.7 --no-site-packages "$ROOT/env" || exit 1
        fi
        # Activate our virtualenv
        source "$ROOT/env/bin/activate"
        for project in $PROJECTS; do
            if [ -x "$ROOT/minion-$project/setup.sh" ]; then
				(cd "$ROOT/minion-$project"; "./setup.sh" develop) || exit 1
            fi
        done
        ;;
    install)
        for project in $PROJECTS; do
            (cd "$ROOT/minion-$project"; "sudo" "python" "setup.py" "install") || exit 1
        done
        ;;
    run-backend)
        source "$ROOT/env/bin/activate"
        if [ -z "$p" ]; then
            p="8383"
        fi
        minion-backend/scripts/minion-backend-api "-a" $a "-p" $p -r -d
        ;;
    run-frontend)
        source "$ROOT/env/bin/activate"
        if [ -z "$p" ]; then
            p="8080"
        fi
        minion-frontend/scripts/minion-frontend "-a" $a "-p" $p -r -d
        ;;
    run-scan-worker)
        source "$ROOT/env/bin/activate"
        $ROOT/minion-backend/scripts/minion-scan-worker
        ;;
    run-state-worker)
        source "$ROOT/env/bin/activate"
        $ROOT/minion-backend/scripts/minion-state-worker
        ;;
    run-plugin-worker)
        source "$ROOT/env/bin/activate"
        $ROOT/minion-backend/scripts/minion-plugin-worker
        ;;
    *)
        echo "Usage : $0 <clone|install|develop|run-backend|run-frontend|run-plugin-worker|run-scan-worker|run-state-worker>"
        ;;
esac
