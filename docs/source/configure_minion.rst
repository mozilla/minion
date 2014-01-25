Configure Minion
################

Minion backend and frontend can be configured after installation. This document will
explain how to configure them.

As a convention, Minion will look at ``/etc/minion/`` and ``/home/user/.minion``. In the second
case, the user home directory is the user that runs Minion backend server.

.. _whitelist_blacklist_hostname_label:

Hostname Whitelist and Blacklist
================================

As of Minion 0.3 release, Minion will blacklist the following IP addresses from scanning.

.. code-block:: python

    '10.0.0.0/8',
    '127.0.0.0/8',
    '172.16.0.0/12',
    '192.168.0.0/16',
    '169.254.0.0/16'

You can check the latest list from https://github.com/mozilla/minion-backend/blob/master/minion/backend/utils.py.

The effect of this is that Minion will refuse to scan any target site whose hostname falls in one of the ranges.
For example, when Minion resolve the hostname ``localhost`` to ``127.0.0.1``, Minion will abort the scan because
it is blacklisted.

To configure the blacklist and whitelist, you can supply a file called **scan.json** in either ``/etc/minion/``
or ``/home/user/.minion/``.

.. code-block:: python

    {
        "whitelist": [
            "192.168.0.0/16",
            "127.0.0.1"
        ]
    }

In this configuration, we allowed scanning LAN network and localhost. This is useful when you are testing your
own web application from home. However, ``172.16.0.0/12`` range is still restricted from scanning. 

You can supply your own blaclist as well.

.. code-block:: python

    {
        "whitelist": [
            "192.168.0.0/16",
            "127.0.0.1"
        ],
        "blacklist": [
            "foobar.com"
        ]
    }

In this example, foobar.com is not scannable. When we specify our own blacklist, we replace the default one
entirely with our own. So we can omit the whitelist in our example.


Configure Backend
=================

Here is the default configuration for the backend server (see https://github.com/mozilla/minion-backend/blob/master/minion/backend/utils.py)

.. code-block:: python

    {
        'api': {
            'url': 'http://127.0.0.1:8383',
        },
        'celery': {
            'broker': 'amqp://guest@127.0.0.1:5672//',
            'backend': 'amqp'
        },
        'mongodb': {
            'host': '127.0.0.1',
            'port': 27017
        },
        'email': {
            'host': '127.0.0.1',
            'port': 25,
            'max_time_allowed': 3600 * 24 * 7 # seconds in 7 days
        }
    }

To configure the backend, supply all the options in a file called ``backend.json`` at either ``/etc/minion`` or
``/home/user/.minion``.

The ``api/url`` is the full authority (hostname and port) of the backend server.

The ``max_time_allowed`` determines the life time of an invitation; by default it will remain valid for seven days.

Configure Frontend
==================

The frontend is much simpler.

.. code-block:: python

    {
        'backend-api': {
            'url': 'http://127.0.0.1:8383'
        }
    }

If the backend server is on a different server, then put this configuration in a file called ``frontend.json``
at either ``/etc/minion`` or ``/home/user/.minion``.
