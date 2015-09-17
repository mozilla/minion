Inside Minion
#############

In this document, we will look at the internals of Minion. Many of the points
below have been discussed previously at:

* `Introducing Minion <https://blog.mozilla.org/security/2013/07/30/introducing-minion/>`_

* `Writing Minion Plugins <https://blog.mozilla.org/security/2013/08/22/1392/>`_

While the blog posts may be outdated, they are useful to look at.

Minion's mission
================

Minion is developed as an open source project by the Mozilla Security Assurance team.
The goal is to enable developers and security testers to bring web application security
into a continuous testing cycle. To do this, both developers and testers are given an
easy to use dashboard that lists all the sites they need to scan, detail scan summary page
and detail issue page to explain vulnerability. Instead of learning a new scan tool,
users can write Minion plugins to call their favorite scan tools, and Minion will spawn
the tool as a new process, scan the target website, and return the results back to the user.


Architecture
============

At a high level there are three major components in Minion: **Plugins**, 
**Task Engine**, and **Front End**.

In principle, the backend of Minion consists of a task engine and a set of plugins. 
The Front End exposes a user interface for both regular users and administrators
to manage configurations and to see scan results.

Technology stack
----------------

Before we divde into what each component does, let us look at the technology stack
we are using in Minion:

* We build the backend and frontend heavily in Python, using the 
  `Flask <http://flask.pocoo.org>`_ web framework for building 
  an APIs server.

* The backend's task engine uses `Twisted <http://twistedmatrix.com/trac/>`_
  for plugin execution. 

* We use `RabbitMQ <http://www.rabbitmq.com/>`_
  to queue and transfer messages between executing plugin and the backend's task engine. 

* The Front-end has a layer of wrapper APIs serving with Flask web framework.

* We create the front end interface using `angular.js <http://angularjs.org/>`_
  and `Twitter Bootstrap <http://twitter.github.io/bootstrap/>`_ by making
  http requests to our front end's APIs (which in turns make requests to the backend's
  API server).

* We use MongoDB as our data store.

* By default, our version of Minion is using Persona for authentication.


This stack corresponds to the diagram shown below.

.. image:: https://wiki.mozilla.org/images/8/86/Minion-03-diagram-draft.png
   :align: center
   :scale: 80%

Plugins
-------

Minion plugins are light-weight wrappers that perform tasks such as configuring, 
starting, stopping a plan, and accept a set of callbacks to notify the caller 
that information is available. Minion ships with several primitive plugins
known as **basic plugin**. This group of plugins checks to see whether
the target URL is accessible, examines various HTTP headers and verifies
whether robots.txt exists and correct. 

Two base classes for plugins are provided in the Minion backend to get developers started:

    * **BlockingPlugin** provides the basic functionality to support 
      a plugin that performs a task, and reports it’s completion state at 
      the end. This is suitable for creating straightforward plugins directly 
      within Python.

    * **ExternalProcessPlugin** provides the functionality required 
      to kick-off an external tool, and the class provides the basis for 
      several other extensions, especially those that wrap existing security tools.

Besides the primitive basic plugins, Mozilla developers have created several
plugins:

.. include:: include/plugin_repos.rst

Task Engine
-----------

Minion Backend and Minion Task Engine are synonym in this docuemtnation. 
The Task Engine provides the core functionality for managing users, 
groups, sites, scans, and results within the Minion platform. 
Acting as a central hub, the Task Engine maintains a register of 
available plugins, provides facilities for creating and modifying plans, 
and managing user access to Minion, including which sites they can scan.

To execute a scan on a target URL, one or more plan must be defined for the target
URL and a scan is initiated by picking a specific plan. In the nutshell, a 
plan is a JSON document that specifies some information about what the 
plan does, and a sequence of plugins to invoke (and such sequence is
called a **workflow**). An example is shown below:

.. code-block:: python

    {
     "name": "Fuzz and Scan",
     "description": "Run Skipfish to fuzz the application, and perform a ZAP scan.",
     "workflow": [
          {
               "plugin_name": "minion.plugins.skipfish.skipfish.SkipfishPlugin",
               "description": "",
               "configuration": {}
          },
          {
               "plugin_name": "minion.plugins.zap.zap_plugin.ZAPPlugin",
               "description": "Run the ZAP Spider and Scanner",
               "configuration": {
                    "scan": true
               }
          }
     ]


This plan will invoke Skipfish and ZAP. The configuration for Skipfish
plugin is left empty to use the default options. Some plugins have required
and optional configuration parameters for users to specify.

Front End
---------

As we stated in the technology stack section, the front end server is a Flask
web application, while the user interface is created using AngularJS. In simple
terms, users do not make direct API calls to the backend. In the nutshell,
the task engine has very very little access control built-in. The front end
is responsible for creating the ACL by wrapping API requests to the task
engine in the front end's API. AngularJS makes calls to the front end's
API endpoints. 

This looks confusing and unncessary for newcomer, but the main advantage 
is that we can re-engineer the front end in anyway we want with little 
to zero impact to the task engine. For example, someone swap out the entire 
front end and our Persona authentiation with their own front end implementation
and authentication model (e.g. LDAP authentication).
