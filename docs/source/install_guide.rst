Installing Minion
#################

Prerequisites
=============

Minion is developed on Ubuntu 14.04.  While it should work on other operating systems, your mileage may vary. The installation guide assumes that you will install Minion in ``/opt/minion``, and a virtualenv of ``/opt/minion/minion-env``, with Minion Frontend and Minion Backend installed on different systems.

.. _install_backend_label:

Install using Minion VM
=======================

For developers or testers, we strongly suggest using Minion VM, which will install Minion automatically using either Vagrant or Docker. Of the two, Vagrant is the preferred method, as it helps facilitate rapid development.

Downloading minion-vm
---------------------

Make sure you have ``git`` installed, and then clone the minion-vm repository::

    $ git clone https://github.com/mozilla/minion-vm.git

Then, regardless of whether we're using Vagrant or Docker, it is necessary to edit ``backend.sh`` to change the initial administrator's email address and name::

    MINION_ADMINISTRATOR_EMAIL="youremail@yourorganization.org"
    MINION_ADMINISTRATOR_NAME="Your Name"

Installation via Vagrant
------------------------

First, we'll grab minion-backend, and minion-frontend from GitHub::

    $ git clone https://github.com/mozilla/minion-backend
    $ git clone https://github.com/mozilla/minion-frontend

Then, edit the ``BACKEND_SRC`` and ``FRONTEND_SRC`` variables in ``Vagrantfile`` to point to the location where you cloned them on your local system.  We'll also create a directory to store the packages that Vagrant VMs will pull down; this will greatly speed up installation. This directory is the ``APT_CACHE_SRC`` variable::

    BACKEND_SRC = "/home/myuser/minion/minion-backend/"
    FRONTEND_SRC = "/home/myuser/minion/minion-frontend/"
    APT_CACHE_SRC = "/home/myuser/minion/apt-cache/com.hashicorp.vagrant/apt-cache/"

If you don't want Minion to use the private network IP addresses 192.168.50.49 and 192.168.50.50 for the backend and frontend respectively, edit them inside both ``Vagrantfile`` and ``vagrant-hosts.sh``::

    BACKEND_IP = "192.168.50.49"
    FRONTEND_IP = "192.168.50.50"

    192.168.50.49 minion-backend
    192.168.50.50 minion-frontend

Now all we need to do is start it up::

    $ vagrant up


That's it! The Minion frontend should now be accessible at http://192.168.50.50:8080, or whatever you set the IP address to.

You can also ssh into your new Minion instances with ``vagrant ssh minion-frontend`` and ``vagrant ssh minion-backend``.

Installation via Docker
-----------------------

The Docker installation will automatically pull down minion-backend and minion-frontend from GitHub. ::

    $ docker build -t 'mozilla/minion-backend'  -f Dockerfile-backend  .
    $ docker build -t 'mozilla/minion-frontend' -f Dockerfile-frontend .
    $ docker run -d --name 'minion-backend' 'mozilla/minion-backend'
    $ docker run -d -p 8080:8080 --name 'minion-frontend' \
        --link minion-backend:minion-backend 'mozilla/minion-frontend'

The Minion frontend should now be accessible over HTTP at the IP address of the system running Docker, on port 8080.

You can also get a shell on your new Minion instances with `docker exec -i -t minion-frontend /bin/bash` and
`docker exec -i -t minion-backend /bin/bash`.

Manual Installation
===================

.. _install_backend_label:

Install Minion Backend
----------------------

We will be installing the Minion Backend into ``/opt/minion/minion-backend`` with a virtualenv location of ``/opt/minion/minion-env``.

First install the essentials::

    # apt-get update
    # apt-get install -y build-essential curl git libcurl4-openssl-dev libffi-dev \
        libssl-dev mongodb-server postfix python python-dev python-virtualenv \
        rabbitmq-server stunnel supervisor

Then, create and source your virtual environment.  This will help keep Minion isolated from the rest of your system. We
also need to upgrade setuptools from the version included with Ubuntu by default::

    # mkdir -p /etc/minion /opt/minion
    # cd /opt/minion
    # virtualenv minion-env
    # source minion-env/bin/activate

    (minion-env)# easy_install --upgrade setuptools    # required for Mock

Next, setup your system with the following directories and the `minion` user account. We'll also create some convenience shell commands, to make working with Minion easier when running as the `minion` user::

    # useradd -m minion
    # install -m 700 -o minion -g minion -d /run/minion -d /var/lib/minion -d /var/log/minion -d ~minion/.python-eggs

    # echo -e "\n# Automatically source minion-backend virtualenv" >> ~minion/.profile
    # echo -e "source /opt/minion/minion-env/bin/activate" >> ~minion/.profile

    # echo -e "\n# Minion convenience commands" >> ~minion/.bashrc
    # echo -e "alias miniond=\"supervisord -c /opt/minion/minion-backend/etc/supervisord.conf\"" >> ~minion/.bashrc
    # echo -e "alias minionctl=\"supervisorctl -c /opt/minion/minion-backend/etc/supervisord.conf\"" >> ~minion/.bashrc

Now we can checkout Minion and install it::

    # cd /opt/minion
    # git clone https://github.com/mozilla/minion-backend.git
    # source minion-env/bin/activate
    (minion-env)# cd minion-backend
    (minion-env)# python setup.py develop

To make sure that Minion starts when the system reboots, we need to install the Minion init script. We can also disable
the global `supervisord` installed with `apt-get install` above, if it wasn't being used before::

    # cp /opt/minion/minion-backend/scripts/minion-init /etc/init.d/minion
    # chown root:root /etc/init.d/minion
    # chmod 755 /etc/init.d/minion
    # update-rc.d minion defaults 40
    # update-rc.d -f supervisor remove

Next, we enable debug logging and automatic reloading of Minion or plugins upon code changes, by adding the ``--debug`` and ``--reload`` options::

    # sed -i 's/runserver/--debug --reload runserver/' /opt/minion/minion-backend/etc/minion-backend.supervisor.conf

.. note::

    Auto-debugging and auto-reloading shouldn't be enabled on production systems, for security purposes.

And that's it! Provided that everything installed successfully, we can start everything up::

    # service mongodb start
    # service rabbitmq-server start
    # service minion start

From this point on, you should be able to control the Minion processes either as root or as the newly-created minion user. Let's become the ``minion`` user, and see if everything is running properly::

    # su - minion
    (minion-env)$ service minion status
    minion-backend                   RUNNING    pid 18010, uptime 0:00:04
    minion-plugin-worker             RUNNING    pid 18004, uptime 0:00:04
    minion-scan-worker               RUNNING    pid 18009, uptime 0:00:04
    minion-scanschedule-worker       RUNNING    pid 18008, uptime 0:00:04
    minion-scanscheduler             RUNNING    pid 18007, uptime 0:00:04
    minion-state-worker              RUNNING    pid 18005, uptime 0:00:04

Success! You can also use ``minionctl`` (an alias to ``supervisorctl``, using the Minion ``supervisord.conf`` configuration) to stop and start individual services, or check on status::

    (minion-env)$ minionctl stop minion-backend
    minion-backend: stopped

    (minion-env)$ minionctl status minion-backend
    minion-backend                   STOPPED    Sep 03 09:18 PM

    (minion-env)$ minionctl start minion-backend
    minion-backend: started

    (minion-env)$ minionctl status minion-backend
    minion-backend                   RUNNING    pid 18795, uptime 0:00:07

All that's left to do now is initialize the Minion database and create an administrator::

    (minion-env)$ minion-db-init 'Your Name' 'youremail@mozilla.com' y
    success: added 'Your Name' (youremail@yourcompany.com) as administrator

And we're done! All logs for Minion, including stdout, stderr, and debug logs, should appear in ``/var/log/minion``.

.. note::

    If you use virtualenv (recommended), then the Minion convenience scripts (such as `minion-db-init`) are only available if the shell is sourced into the virtualenv. This is done automatically for the Minion user. In other words, if you open a new terminal and then try ``minion-`` with auto-completion, the chance is you won't see anything. If you install Minion without virtualenv, these scripts will be available to the $PATH.

.. _install_frontend_label:

Install Minion Frontend
-----------------------

First, install the essentials::

    # apt-get update
    # apt-get install -y build-essential git libldap2-dev libsasl2-dev \
        libssl-dev python python-dev python-virtualenv supervisor

Then, create and source your virtual environment.  This will help keep Minion isolated from the rest of your system. We
also need to upgrade setuptools from the version included with Ubuntu by default::

    # mkdir -p /etc/minion /opt/minion
    # cd /opt/minion
    # virtualenv minion-env
    # source minion-env/bin/activate

(minion-env)# easy_install --upgrade setuptools    # required for Mock

Next, setup your system with the following directories and the `minion` user account. We'll also create some convenience shell commands, to make working with Minion easier when running as the `minion` user::

    # useradd -m minion
    # install -m 700 -o minion -g minion -d /run/minion -d /var/lib/minion -d /var/log/minion -d ~minion/.python-eggs

    # echo -e "\n# Automatically source minion-frontend virtualenv" >> ~minion/.profile
    # echo -e "source /opt/minion/minion-env/bin/activate" >> ~minion/.profile

    # echo -e "\n# Minion convenience commands" >> ~minion/.bashrc
    # echo -e "alias miniond=\"supervisord -c /opt/minion/minion-frontend/etc/supervisord.conf\"" >> ~minion/.bashrc
    # echo -e "alias minionctl=\"supervisorctl -c /opt/minion/minion-frontend/etc/supervisord.conf\"" >> ~minion/.bashrc

Now we can checkout Minion and install it::

    # cd /opt/minion
    # git clone https://github.com/mozilla/minion-frontend.git
    # source minion-env/bin/activate
    (minion-env)# python setup.py develop

To make sure that Minion starts when the system reboots, we need to install the Minion init script. We can also disable
the global `supervisord` installed with `apt-get install` above, if it wasn't being used before::

    # cp /opt/minion/minion-frontend/scripts/minion-init /etc/init.d/minion
    # chown root:root /etc/init.d/minion
    # chmod 755 /etc/init.d/minion
    # update-rc.d minion defaults 40
    # update-rc.d -f supervisor remove

And that's it! Provided that everything installed successfully, we can start everything up::

    # service minion start

From this point on, you should be able to control the Minion processes either as root or as the newly-created minion user.  Let's `su - minion`, and see if everything is running properly::

    # su - minion
    (minion-env)minion@minion-frontend:~$ service minion status
    minion-frontend                  RUNNING    pid 1506, uptime 1 day, 1:25:41

Success! You can also use `minionctl` (an alias to `supervisorctl`, using the Minion `supervisord.conf` configuration)
to stop and start individual services, or check on status::

    (minion-env)minion@minion-frontend:~$ minionctl stop minion-frontend
    minion-frontend: stopped
    (minion-env)minion@minion-frontend:~$ minionctl status minion-frontend
    minion-frontend                  STOPPED    Sep 09 07:15 PM
    (minion-env)minion@minion-frontend:~$ minionctl start minion-frontend
    minion-frontend: started
    (minion-env)minion@minion-frontend:~$ minionctl status minion-frontend
    minion-frontend                  RUNNING    pid 8713, uptime 0:00:05
