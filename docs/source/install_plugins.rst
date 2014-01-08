Installing Plugins
##################

Plugins are essential to Minion scan. Every attack plan will specify one or more Minion plugin. A plugin
is essentially a Python wrapper around a scan tool. The tool can be as complex as OWASP ZAP
(http://code.google.com/p/zaproxy/) or as simple as checking HTTP header using Python (such as basic.plan
which is shipped with Minion).

To view a list of plugins available to Minion backend, logged in the frontend with an admin account, click on
**Administration**, and then click on **Plugins**.

.. image:: images/plugins.png

The Minion instance this screenshot is take from has custom plugins such as ZAP and WPScan. Plugins that are under
the namespace ``minion.plugins.basic.*`` comes from the **basic** plugin that is shipped with Minion backend.

In this document, users can learn how to set up the zap plugin and the skipfish plugin.

.. _ZAPPlugin:

ZAPPlugin
=========

OWASP ZAP is easy to use integrated penetration testing tool for finding vulnerabilities in web applications. This is
pretty much the open source alternative to Burp scanner.

ZAP is available to download from the Internet. Major Linux distrubtion does not bundle ZAP so user must download
ZAP in a compressed file and then extract it.

Choosing a version
------------------

ZAP has a weekly build and a stable build. The current ZAPPlugin supports version 2.2.0 up to 2.2.2. Let's get the latest
stable release at the time of this writing: version 2.2.2. Since Minion is best supported on Ubuntu/Debian servers, here
we download ZAP_2.2.2_Linux.tar.gz. We can download this file in ``/home/username/`` if we want.

Once we have ZAP_2.2.2_Linux.tar.gz on disk, extract the tar file by ``tar xvf ZAP_2.2.2_Linux.tar.gz``.

Get minion-zap-plugin
---------------------

We need the Python wrapper available to Minion's backend Python environment (so remember to source
into the appropriate environment if needed).

.. code-block:: bash

    $ git clone https://github.com/mozilla/minion-zap-plugin.git
    $ cd minion-zap-plugin
    $ python setup.py install

If you are developing Minion and/or minion-zap-plugin, do ``python setup.py develop`` instead.
"install_plugins.rst" 123L, 4583C

If you are developing Minion and/or minion-zap-plugin, do ``python setup.py develop`` instead.

Configure zap-plugin.json
-------------------------

Minion plugins can take optional configurations. It searches ``/etc/minion/`` and ``/home/username/.minion/``, where
``username`` is the unix user Minion process will be running as.

It is probably better to create the configuration directory under the user Minion process runs as.

The zap plugin expects to find the location of the zap folder. The JSON file looks like this:

.. code-block:: python

    {
        "zap-path": "/home/username/ZAP_2.2.2_Linux/"
    }

This path is chosen because we extracted Minion under ``/home/username`` in the first place.

Reload backend and workers
--------------------------

Finally, reload the backend server and all the workers. Then go to the frontend and check ``Plugins`` under an admin account:
ZAP should be one of the plugins available to Minion now.

SkipfishPlugin
==============

Unlike :ref:`ZAPPlugin`, Skipfish is available as a Debian package to Ubuntu/Debian platform.

Choosing a version
------------------

Checking the README for minion-skipfish-plugin (https://github.com/mozilla/minion-skipfish-plugin),
only version ``2.1.0b`` is supported.

If you work on Ubuntu 13.04 or above:

.. code-block:: bash

    $ sudo apt-get install skipfish

If you work on Ubuntu older than 13.04:

.. code-block:: bash

    wget http://launchpadlibrarian.net/126324292/skipfish_2.10b-1_i386.deb     (for 32-bit)
    wget http://launchpadlibrarian.net/126324272/skipfish_2.10b-1_amd64.deb    (for 64-bit)
    sudo dpkg -i skipfish_2.10b-1_[i368|am64].deb
    wget http://launchpadlibrarian.net/126324272/skipfish_2.10b-1_amd64.deb    (for 64-bit)
    sudo dpkg -i skipfish_2.10b-1_[i368|am64].deb

Getting minion-skipfish-plugin
------------------------------

Let's get the plugin code and install the Python package.

.. code-block:: bash

    $ git clone https://github.com/mozilla/minion-skipfish-plugin.git
    $ cd minion-skipfish-plugin
    $ python setup.py install

If you are developing Minion, or developing minion-skipfish-plugin, you probably should
call ``python setup.py develop`` instead of ``install``.

Finally, just reload your backend and celery workers and the plugin should be discovered by
Minion.

Skipfish vs ZAP configuration
=============================

The difference is that Skipfish can be installed as a system package so there is no
manual step to make Skipfish available to ``$PATH``. Although you can make ZAP available
to the ``$PATH`` such as editing ``/etc/environments`` or placing the ZAP folder in ``/usr/local/bin``
or such, the author of the plugin feels it is easier to just configure the path manually.

So this is why ZAP plugin is configurable through ``zap-plugin.json``. It is up to the plugin
author to choose which route to take and this is not something Minion core developers
can enforce strictly at the moment. Some plugins can be further configured (beyond locating
where the executable is located) so ``.json`` configuration file is still very useful for all
plugin.

To learn more about plugins, please refer to :doc:`developing_plugins`.
