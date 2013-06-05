ptl-client
==========

.. ![CI Build Status]
   (https://travis-ci.org/dupuy/ptl-client.png?branch=master)
   ![Coverage Status]
   (https://coveralls.io/repos/dupuy/ptl-client/badge.png?branch=master)
   <!---

.. image:: https://travis-ci.org/dupuy/ptl-client.png?branch=master
    :target: https://travis-ci.org/dupuy/ptl-client

.. image:: https://coveralls.io/repos/dupuy/ptl-client/badge.png?branch=master
    :target: https://coveralls.io/r/dupuy/ptl-client

.. --->

Both the ``ptl`` command line client and the ptl.py Python client library
for the Pootle web services API are provided in the ptl-client package.
You can use them to perform management operations on the Pootle
translation or localization database from a command line, or script
operations in your own applications.

The API is currently in development, and the interfaces provided in the
0.9.* releases are subject to change - the ptl-client software will track
these changes fairly closely, so the programmatic interface to the client
library and the command options will change as well.  The slumber library
is used to provide the basic client functionality; the ``ptl`` module
simply adds wrappers to manage specific aspects of the Pootle API that
would otherwise be annoying.

Until this package is published on PyPI (when the API is frozen for the
1.0 release), installation is done manually by ``python setup.py install``
or ``make install`` - which runs setup.py.

Documentation is generated with ``make -C docs html`` and is available
online at links below.

Basic usage
-----------

To get a list of all languages enabled on a Pootle server::

    ptl languages list

The Python code to implement the above using the client library would be::

```python
import ptl
import slumber

API_URL = "http://localhost/api/v1/"

API = slumber.API(API_URL)

print ("\nid\tcode=fullname")

for lang in API.languages.get()['objects']:
    dbid = lang['resource_uri'].strip('/').split('/')[-1]
    print(dbid + '\t' + lang['code'] + '=' + lang['fullname'])

```

Resources
---------

- Pootle: <http://pootle.translatehouse.org>
- Pootle API Specification:
  <http://docs.translatehouse.org/projects/pootle/en/latest/api/>
- Documentation:
  <http://docs.translatehouse.org/projects/ptl-client/en/latest/>
- Slumber documentation:
  <https://github.com/dstufft/slumber#readme>
  <https://slumber.readthedocs.org/en/latest/>
- Translations: <http://pootle.locamotion.org/projects/ptl-client/>
- Bug Tracker: <http://bugs.locamotion.org/>
- Mailing List:
  <https://lists.sourceforge.net/lists/listinfo/translate-pootle>
- IRC: #pootle on irc.freenode.net

License
-------

The ptl-client code is released under the Lesser General Public License,
version 3 or later.  See the ``LICENSE`` file for details.
