Getting Started
###############

This document shows how to get started with Minion by getting your own Minion installation for the first time.

Pre-requisites
===============

* Minion has been developed primarily on Ubuntu 12.04 and 13.04 so running Minion on other systems is not a guarantee

* Python 2.7+ (not Python 3 compatible)

Finally, we need these dependencies fulfill:

.. code-block:: bash

    sudo apt-get update
    sudo apt-get install git build-essential python-virtualenv python-dev rabbitmq-server mongodb-server curl libcurl4-openssl-dev


.. note::

    It is helpful to assume the followings for the purpose of this guide:

    1. Minion's Python dependencies will reside in a virtualenv

    2. Minion and plugin repositories will reside under ``/home/user/`` directory.

    3. Point 1 and 2 are not required for production, but for the purpose of this tutorial.

Installing Minion
=================

Minion has two components: minion-backend and minion-frontend. To get both installed, the quick way is
to use ``setup.sh``. This script resides in a different repository: https://github.com/mozilla/minion.

.. note::

    If you want to set up the backend and the frontend individually (suitable for production),
    please refer to :ref:`install_backend_label` and :ref:`install_frontend_label`.

.. code-block:: bash

    $ git clone https://github.com/mozilla/minion.git
    $ cd minion
    $ ./setup.sh clone
    $ ./setup.sh develop
    
By cloning we clone both the backend and frontend to the current directory (which in this case we assume it to be
``/home/user/minion`` directory.

The last command will create a virtualenv called ``env`` under ``/home/user/minion``. This virtualenv is shared by
the backend and frontend (this is not the best practice, but for the purpose of getting started this is enough). The
``develop`` command will then source into this virtualenv and run ``python setup.py develop`` on the backend
and the frontend to get all the dependencies fulfill. 

There is also ``./setup.sh install`` which performs ``python setup.py install``. This is better for production. To learn
more about the usage of the script, please refer to :doc:`using_setup_sh`.

Running Minion
==============

As aforementioned, Minion is broken down into backend and frontend which are both using Flask web framework. Minion backend
also runs three celery workers which are used to communicate between plugin scanning processes.

Let's have five terminals opened. Each terminal will ``cd minion`` so that the current working directory is ``/home/user/minion``.
Then for each terminal, run one of the following commands:

.. code-block:: bash

    $ ./setup.sh run-backend
    $ ./setup.sh run-frontend
    $ ./setup.sh run-plugin-worker
    $ ./setup.sh run-state-worker
    $ ./setup.sh run-scan-worker

By default, the backend runs on ``127.0.0.1:8383`` while the frontend runs on ``0.0.0.0:8080``; you can
visit the frontend by going to ``http://<vm-ip-address>:8080/`` in your browser assuming that
your VM IP is accessible to your host computer.

If you wonder how these commands actually work, please refer to :doc:`using_setup_sh`.

To configure Minion, please refer to :doc:`configure_minion`.

Create Minion Admin
===================

Almost there! The very last bit is to create a Minion super user. To do this, the backend comes with a handy script
called ``minion-db-init``.

.. code-block:: bash

    $ cd minion
    $ cd minion-backend/scripts
    $ ./minion-db-init

    Enter the administrator's Persona email: 
    Enter the administrator's name: 
    Do you want to import some test sites into minion? [y/n]

Enter an email that has been registered as Persona email account. If you don't have one or you are new to Persona,
please check out :doc:`persona` before proceeding.

You don't have to provide a real name, but this is the name we use in formal information such as sending invitation
to a friend to join Minion. Mozilla does not collect data from self-hosted Minion if you care about your privacy.

You also don't need to import test sites. By test sites we mean security testing sites. These sites are developed
and free to security testers for testing security tools. We encourage new users to import them when learning about
Minion. You can always delete them later (or start from scratch when you deploy a production version).

Explore the frontend
=====================

I have a separate page to guide you how to use the frontend. Please check :doc:`using_frontend`.

Install New Plugins
===================

Plugins are essentials. As a new Minion owner, you should try installing new plugins. We have
a separate guide on this topic, so please check :doc:`install_plugins`.

Moving from beginngers
======================

* :doc:`configure_minion`

* :doc:`inside_minion`

* :doc:`developing_plugins`

* :doc:`using_setup_sh`

* :doc:`contribute_to_minion`
