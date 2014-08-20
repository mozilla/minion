About Minion
============

Minion is a security testing framework built by Mozilla to bridge the gap between developers and security testers. To do so, it enables developers to scan their projects using a friendly interface.

For complete user and developer documentation see http://minion.readthedocs.org/en/latest/

About this project
------------------

This repository is an 'umbrella' project that simply ties together the separate projects that Minion needs.

The following two projects are the bare minimum needed to get Minion up and running:

* https://github.com/mozilla/minion-backend
* https://github.com/mozilla/minion-frontend

The following projects are optional plugins for minion that add more functionality or wrap existing tools:

* https://github.com/mozilla/minion-zap-plugin
* https://github.com/mozilla/minion-ssl-plugin
* https://github.com/mozilla/minion-skipfish-plugin
* https://github.com/mozilla/minion-nmap-plugin

This project contains a script that will check out the above projects. See below in the setup instructions.

Setting up a development environment
------------------------------------

Whatever platform you use, you will need the following tools:

* Python 2.7
* virtualenv
* git

For task distribution and data storage, Minion uses the following services:

* rabbitmq
* mongodb

If you work on Ubuntu, install the following packages:

    $ sudo apt-get install git build-essential python-virtualenv python-dev rabbitmq-server mongodb-server curl libcurl4-openssl-dev
    $ sudo apt-get install nmap skipfish

If you work on Fedora 19, install the following packages:

    $ sudo yum groupinstall 'Development Tools'
    $ sudo yum install  python-devel python-virtualenv mongodb-server mongodb-devel rabbitmq-server libcurl-devel openssl-devel
    $ sudo yum install nmap skipfish
    
You can make Minion ready for development by following these steps:

    $ git clone https://github.com/mozilla/minion
    $ cd minion
    $ ./setup.sh clone
    $ ./setup.sh develop

You can also run ``./setup.sh install`` if you choose to make Minion available to the global Python interpreter.
This option will run ``python setup.py install`` instead of ``python setup.py develop``.

Running Minion in Development Mode
----------------------------------

To run Minion you need to have five things up and running:

* The Frontend
* The Backend REST API
* The Backend Scan Worker
* The Backend State Worker
* The Backend Plugin Worker

The order is not important, just start them all up in separate terminal windows. The easiest way to start them in development mode is to use the provided `setup.sh` script.

Start the frontend in a new shell window:

    $ cd minion
    $ ./setup.sh run-frontend

Start the backend in a new shell window:

    $ cd minion
    $ ./setup.sh run-backend

Start the backend scan worker in a new shell window:

    $ cd minion
    $ ./setup.sh run-scan-worker

Start the backend state worker in a new shell window:

    $ cd minion
    $ ./setup.sh run-state-worker

Start the backend plugin worker in a new shell window:

    $ cd minion
    $ ./setup.sh run-plugin-worker

License
-------
This software is licensed under the MPL License. For more
information, read the file ``LICENSE``.

