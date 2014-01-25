Install Minion
##############

.. note:: 

    If you are new to Minion, you probably want to check out :doc:`getting_started` instead.
    This document is for users who want to know how to set up Minion components individually
    (possibly for deployment reason).

.. _install_backend_label:

Install Minion Backend
======================

.. code-block:: bash

    $ virtualenv env
    $ source env/bin/activate
    $ git clone https://github.com/mozilla/minion-backend.git
    $ cd minion-backend
    $ python setup.py develop

First, you don't have to use virtualenv, but we recommend do it. Secondly, ``python setup.py develop``
is really useful for both development and production. It is up to you to decide which one
works best for your deployment.

Next, we just need to launch the backend server and celery workers. There is a folder called **scripts**
at the root directory of the minion-backend repository. When we run ``setup.py``, the setuptool will make
all the scripts under the minion-backend/scripts/ available to the shell. 

So if you type ``minion-`` and try auto-completion, you will see ``minion-backend-api``, ``minion-plugin-workers``
and etc. Let's launcht server and the workers.

.. code-block:: bash

    $ minion-backend-api
    $ minion-plugin-worker
    $ minion-scan-worker
    $ minion-state-worker

The backend accepts options. Check ``-h``. By default the server listens on 8383 and is a localhost service. 

.. note::

    If you use virtualenv in the first place, then these "scripts" are only available if the shell is sourced
    into the virtualenv. In other words, if you open a new terminal and then try ``minion-`` with auto-completion,
    the chance is you won't see anything. If you install Minion without virtualenv, these scripts will be availiable
    to the $PATH.

.. _install_frontend_label:

Install Minion Frontend
=======================

Similar to the backend (see above):

.. code-block:: bash

    $ virtualenv env
    $ source env/bin/activate
    $ git clone https://github.com/mozilla/minion-frontend.git
    $ cd minion-frontend
    $ python setup.py develop
    $ minion-frontend -a 0.0.0.0

If you intall the backend on the same server as the frontend, and you want to use virtualenv, you don't
have to share the same virtualenv with the backend. You can create a separate virtualenv (which is
a good practice) for the frontend and one for the backend.

Also, ``minion-frontend`` accepts options. Try ``minion-frontend -h`` to see the options. We specify ``-a`` to be
``0.0.0.0`` so that we can access the frontend from the browser by going to ``http://<vm-ip>:8080``. By default,
the frontend listens on 8080 and is a localhost service. By changing to ``0.0.0.0`` we avoid having to port forward
or setting up a proxy server like Nginx. But of course, you want to keep the frontend a localhost service in real deployment...
