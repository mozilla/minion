Using setup.sh
##############

This document describes using setup.sh script.

Options
=======

``-x`` option specify the root directory of where minion repositories and the virtualenv should reside. By default,
this is the current directory of the current terminal. This option is usable for all the commands.

``-a`` option specify the address the web server (minion-backend and minion-frontend) runs on. 

``-p`` option specify the port the web server (minion-backend and minion-frontend) listens on.

Commands
========

+-----------------------+------------------------------------------------------------------------------------+
| Command               |                       Description                                                  |
+-----------------------+------------------------------------------------------------------------------------+
| clone                 | Clone minion-backend and minion-frontend to the location specify by ``-x`` option. |
+-----------------------+------------------------------------------------------------------------------------+
| develop               | Create and source into **env** virtualenv located next to the repositories at      |
|                       | the location specify by ``-x`` option. Then run ``python setup.py develop``.       |           
+-----------------------+------------------------------------------------------------------------------------+
| install               | Similar to ``develop`` except runs ``python setup.py install``.                    |
+-----------------------+------------------------------------------------------------------------------------+
| run-backend           | Run ``minion-backend-api`` script distrubted in minionp-backend to start backend   |
|                       | server. Default to ``-p 8383`` and ``-a 127.0.0.1``.                               |
+-----------------------+------------------------------------------------------------------------------------+
| run-frontend          | Run ``minion-frontend`` script distrubted in minionp-frontend to start frontend    |
|                       | server. Default to ``-p 8383`` and ``-a 127.0.0.1``.                               |
+-----------------------+------------------------------------------------------------------------------------+
| run-plugin-worker     | Run ``minion-plugin-worker`` script distributed in minion-backend to start a celery|
|                       | worker to run a plugin.                                                            |
+-----------------------+------------------------------------------------------------------------------------+
| run-scan-worker       | Run ``minion-scan-worker`` script distributed in minion-backend to start a celery  |
|                       | worker to inititaite and collect scan results.                                     |
+-----------------------+------------------------------------------------------------------------------------+
| run-state-worker      | Run ``minion-state-worker`` script distributed in minion-backend to start a celery |
|                       | worker to keep track of the state of scan.                                         |
+-----------------------+------------------------------------------------------------------------------------+

Usage Examples
==============

.. code-block:: bash

    $ pwd
    /home/user/minion
    $ ./setup.sh clone
    $ ./setup.sh develop
    $ ./setup.sh run-backend
    $ ls
    env minion-backend minion-frontend setup.sh README.md

This will use all the default options. It will clone minion-backend and minion-frontend to ``/home/user/minion`` and the backend
is started on ``127.0.0.1:8383``.

.. code-block:: bash

    $ pwd
    /home/user/minion
    $ mkdir projects
    $ ls
    setup.sh README.md projects
    $ ./setup.sh clone -x projects
    $ ls projects
    minion-backend minion-frontend
   
In this session, an empty directory called ``projects`` is created at ``/home/user/minion``. The ``-x`` option is used and ``projects`` is specify.
The ``clone`` command then clone the two repositories down into ``/home/user/minion/projects``.

We can continue setting up Minion like this:

.. code-block:: bash

    $ ./setup.sh develop -x projects
    $ ls projects
    env minion-backend minion-frontend
    $ ./setup.sh run-backend -x projects -p 1234
    $ ./setup.sh run-plugin-worker -x projects

Following the previous session, we install Minion by specifying where minion-backend and minion-frontend resides. The virtualenv **env**
is created. Afterward, we start the backend server and specify that the virtualenv **env** is under the directory projects. We also
specify the server should listen on port 1234 instead of the default 8383. We also specify the location of the env when we run the plugin worker.

Note that ``-a`` and ``-p`` are only usable for the servers. Workers can use the ``-x``.

