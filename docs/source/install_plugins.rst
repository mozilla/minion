Installing Plugins
##################

Plugins are essential to Minion scan. Every attack plan will specify one or more Minion plugin. A plugin is essentially a Python wrapper around a scan tool. The tool can be as complex as `OWASP ZAP <https://github.com/zaproxy/zaproxy>`_ or as simple as checking HTTP header using Python (such as basic.plan that is shipped with Minion).

To view a list of plugins available to Minion backend, logged in the frontend with an admin account, click on
**Administration**, and then click on **Plugins**.

.. image:: images/admin-plugins.png

The Minion instance this screenshot is taken from has custom plugin `Nmap <https://github.com/mozilla/minion-nmap-plugin/>`_. Plugins that are under
the namespace ``minion.plugins.basic.*`` come from the **basic** plugin that is shipped with Minion backend.

In this document, users can learn how to install the Nmap plugin. Each plugin should have roughly similar instructions for installation.

First, we need to install whatever external tool the plugin requires, in this case, nmap::

    # apt-get update && apt-get -y install nmap

Then, source the Minion virtualenv, download the plugin, and install it::

    # source /opt/minion/minion-env/bin/activate
    (minion-env)# cd /opt/minion
    (minion-env)# git clone https://github.com/mozilla/minion-nmap-plugin.git
    (minion-env)# cd minion-nmap-plugin
    (minion-env)# python setup.py install

Finally, restart Minion to pick up the new plugin::

    # /etc/init.d/minion stop
    # /etc/init.d/minion start

This should add the Minion plugin to the plugin administration page.  Simply configure its plan, assign it to a site, and you're ready to begin scanning!