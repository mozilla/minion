Developing Plugins
##################

Minion plugins are Python classes that talks to a security aessement tool. This tool can be pure
Python code inside the class doing HTTP header check (which is what the basic plugins
do), or invoke an external executable binary. It can be as simple as a few lines of perl script
or as complex as OWASP ZAP.

How Minion discovers new plugins
================================

If we look at minion-zap-plugin's source code structure closely,
we notice the layout of the package looks like this:

.. code-block:: bash

    $ tree minion-zap-plugin

    minion-zap-plugin/
    |-- minion
    |   |-- __init__.py
    |   |-- __init__.pyc
    |   `-- plugins
    |       |-- __init__.py
    |       `-- zap
    |           |-- config.xml.example
    |           |-- __init__.py
    |           |-- reference.py
    |           |-- zap_plugin.py
    |-- README.rst
    |-- setup.py

Every plugin must fall under the ``minion.plugins`` package namespace.
This is how the backend detects an existence of a plugin. The third level
in minion-zap-plugin is a directory called **zap**. This is the namespace
of the plugin itself. In addition, the plugin class must be a subclass of
``AbstractPlugin`` and the following class member attributes:

** ``PLUGIN_NAME``: the name of the plugin displayed to the frontend user

** ``PLUGIN_WEIGHT``: level of resource required to launch this plugin (light, medium, heavy)


The registry code is found in `base.py <https://github.com/mozilla/minion-backend/blob/master/minion/backend/views/base.py>`_ under the views directory.

Whenever a plugin is installed, the backend server and all the celery workers must be restarted. 


Minion Plugin Classes
=====================

Now that you know how Minion discovers a new plugin,
we can examine plugin classes.

The first thing a plugin author needs to understand is the basics of
Twisted. Minion's Task Engine uses `Twisted <http://twistedmatrix.com/trac/>`_
for running plugins. We recommend plugin authors go over
`An Introduction to Asynchronous Programming and Twisted <http://krondo.com/blog/?page_id=1327>`_ before jumping into writing plugin. We will only cover relevant information
to get you understand how a Minion plugin works.


``AbstractPlugin`` class
-------------------------

The ``AbstractPlugin`` class implements a set of methods and attributes that
a plugin should define. It also provides additional methods
that need not be override by plugin authors. The ``AbstractPlugin`` **should be**
the base class for any plugin you want to write. Minion ships with two
classes of plugins (``BlockingPlugin`` and 
``ExternalProcessPlugin``) inherit from ``AbstractPlugin`` and other plugins
Minion developers have developed so far are inheriting from one of the two
classes. We will get into them in the later section; let's focus on 
``AbstractPlugin``.

Remember how Minion discovers and registers new plugin? The registry
code expects the plugin to be found in the ``minion.plugins`` namespace,
and in addition the plugins must have three class methods defined: 
``name``, ``version``, and ``weight``.

The ``AbstractPlugin`` implements these class methods with a default value.
For example, if you don't define ``name``, it will use the plugin's class name
as the name of the plugin. But it is always a good idea to define them
yourself.

To actual do work, a plugin should implement ``do_configure``, ``do_start``
and ``do_stop`` methods since the ``AbstractPlugin`` leaves them blank. 

``BlockingPlugin`` class
------------------------

This class inherits from ``AbstractPlugin`` directly and is defined in 
`base.py <https://github.com/mozilla/minion-backend/blob/master/minion/plugins/base.py>`_
like ``AbstractPlugin``. 

The ``BlockingPlugin`` implements ``do_configure``, ``do_start``, and ``do_stop``
methods. Most of the Twsited logics are defined in the ``do_start`` method. The
class simply expects a method called ``do_run`` and passes this method to the
``deferToThread`` which will return an asynchronous result that will return
an actual result some time in the future. The nice ``deferToThread`` API
has a pair of callbacks: success and failure. We simply add these two
callbacks to the defer result object and returns.

The magic of Twsited is the event-driven model, also known as reactor model.
The idea is that an event loop will react to an event, possibly executes the
event, and then emits a callback when the event is finished. 

You are probably wondering what happen to ``do_configure``. This particular
class of plugin does not expect any pre-processing configuration needed. As
we study the source code, we will see that all basic plugins are instances of
``BlockingPlugin``. After all, they just need to connect to the target URL,
examine a header or validate the robots.txt. 


``ExternalProcessPlugin`` class
-------------------------------

This is another implementation of ``AbstractPlugin`` class and this class
is useful for executing a plugin that relies on external process such as
ZAP or Skipfish. Instead of calling ``subprocess``, we use Twsited's
``reactor.spawnProcess`` to launch the external process. 

Keen readers notice ``do_configure`` is also not defined. This is intentional.
Every plugin that inherits from the ``ExternalProcessPlugin`` will implement
its own ``do_configure`` because different process is launched differently.

Import plugin class in __init__.py
==================================

When we revisit the structure of a plugin package, it looks like this:

.. code-block:: bash

    minion-zap-plugin/
    |-- minion
    |   |-- __init__.py
    |   |-- __init__.pyc
    |   `-- plugins
    |       |-- __init__.py
    |       `-- zap
    |           |-- config.xml.example
    |           |-- __init__.py
    |           |-- reference.py
    |           |-- zap_plugin.py
    |-- README.rst
    |-- setup.py

The third ``__init__.py`` should import the main plugin class. In the case of the zap plugin, it looks like this:

.. code-block:: python

    from zap_plugin import ZAPPlugin

If the file is left blank, Minion's plugin discovery code will not be able to import ``ZAPPlugin``.

Plugin Template Generator
=========================

Because developing a plugin with the right structure can be tedious and error-prone, there is a script
to generate Minion plugin. The script lives here: https://gist.github.com/yeukhon/8309083

To use this script, download **generate-plugin.py** and **config.ini**. Then edit config.ini to fit your
need (see sample-config.ini on the same page as an example).
