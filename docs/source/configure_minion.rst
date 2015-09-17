Configuring Minion
##################

This document explains how to configure the Minion frontend and backend.

As a convention, Minion will look in ``/etc/minion/`` and ``~minion/.minion`` for its configuration files.

.. _configure_minion_frontend_label:

Configure Minion Frontend
=========================

Here is the `default configuration <https://github.com/mozilla/minion-vm/blob/master/frontend.json>`_ for the Minion frontend server::

    {
        "backend-api": {
            "url": "http://minion-backend:8383"
        },

        "login": {
            "type": "persona",

            "ldap": {
                "uri": "ldaps://ldap.server/",
                "baseDN": "ou=test,dc=test_dc",

                "emailAttribute": "mail",
                "groupMembershipAttribute": "member",
                "usernameAttribute": "uid",

                "checkAuthorizedGroups": false,
                "authorizedGroups": [
                    "ou=groupTest1,ou=test,dc=test_dc",
                    "ou=groupTest2,ou=test,dc=test_dc"
                ]
            }
        }
    }

To configure the frontend, place your configuration in a file called ``frontend.json`` in either ``/etc/minion`` or ``/home/user/.minion``.

- ``backend-api``

  - ``uri``: URI of the Minion backend server

- ``login``

  - ``type``: the type of authentication to use; currently supported types are ``persona``, which requires no configuration, and ``ldap``

  - ``ldap``: the configuration for LDAP, if ``ldap`` is the chosen authentication method in ``login -> ``type`` 

    - ``uri``: URI to ldap server

    - ``baseDN``: baseDN for users; not needed for Active Directory

    - ``emailAttribute``: typically ``mail`` in OpenLDAP or ``userPrincipalName`` in Active Directory

    - ``groupMembershipAttribute``: typically ``member`` in OpenLDAP or ``uniqueMember`` in Active Directory

    - ``usernameAttribute``: typically ``uid`` in OpenLDAP or ``samAccountName`` in AD

    - ``checkAuthorizedGroups``: if true, require group membership in addition to valid user id

    - ``authorizedGroups``: list of groups where users are authorized to use Minion (if ``checkAuthorizedGroups`` is true)

.. _configure_minion_backend_label:

Configure Minion Backend
========================

Here is the `default configuration <https://github.com/mozilla/minion-backend/blob/master/etc/backend.json>`_ for the Minion backend server::

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
            'max_time_allowed': 604800 # 7 * 24 * 60 * 60 (7 days)
        }
    }

To configure the backend, place your configuration in a file called ``backend.json`` at either ``/etc/minion`` or
``/home/user/.minion``.

- ``api``

  - ``url``: the full authority (hostname and port) of the backend server.

- ``celery``

  - ``broker``: URI of the celery broker

  - ``backend``: protocol used to speak to backend

- ``mongodb``:

  - ``host``: hostname of MongoDB server

  - ``port``: port of the MongoDB server

- ``email``

  - ``host``: hostname of mail server

  - ``port``: port of mail server

  - ``max_time_allowed``: determines the life time of an invitation; by default it will remain valid for seven days.


.. _whitelist_blacklist_hostname_label:

Whitelisting and Blacklisting Hosts
===================================

By default, `Minion will blacklist <https://github.com/mozilla/minion-backend/blob/master/etc/scan.json>`_ the following IP addresses from being scanned:

.. code-block:: javascript

    "blacklist": [
        "10.0.0.0/8",
        "127.0.0.0/8",
        "172.16.0.0/12",
        "192.168.0.0/16",
        "169.254.0.0/16"
    ]

You can check the latest list at: .

The effect of this is that Minion will refuse to scan any target site whose hostname falls in one of the ranges.
For example, when Minion resolve the hostname ``localhost`` to ``127.0.0.1``, Minion will abort the scan because
it is blacklisted.

To configure the blacklist and whitelist, you can copy ``etc/scan.json`` into either ``/etc/minion/`` or ``~minion/.minion/``.  Note that the whitelist will override the blacklist, so in this example, IP addresses in 192.168.1.0/24 can be scanned, despite 192.168.0.0/16 being in the blacklist:

.. code-block:: javascript

    {
        "whitelist": [
            "192.168.1.0/24"
        ],
        "blacklist": [
            "10.0.0.0/8",
            "127.0.0.0/8",
            "172.16.0.0/12",
            "192.168.0.0/16",
            "169.254.0.0/16"
        ]
    }

Any host that does not fall within the blacklist can be scanned.

IP address blacklisting and whitelist also supports hostnames and hostname wildcards. For example:

.. code-block:: javascript

    "blacklist": [
        "mozilla.com",
        "*.mozilla.org"
    ]


In this configuration, we allowed scanning LAN network and localhost, but we removed the ability to scan mozilla.com and any subdomain of mozilla.org.  Note that if we wanted to block mozilla.org and subdomains, we would need entries for ``mozilla.org`` and ``*.mozilla.org``:

.. code-block:: javascript

    "blacklist": [
        "mozilla.org",
        "*.mozilla.org"
    ]