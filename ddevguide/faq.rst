:tocdepth: 2

.. _faq:

D Developer FAQ
~~~~~~~~~~~~~~~~~~~~

.. contents::
   :local:


Communications
==============


Where should I ask general D questions?
--------------------------------------------

General D questions should go to our mailing list `Digitalmars-d`_ or
other sites such as StackOverflow_.

.. _Digitalmars-d: http://lists.puremagic.com/mailman/listinfo
.. _StackOverflow: http://stackoverflow.com/


Where should I suggest new features and language changes?
---------------------------------------------------------

The `Digitalmars-d`_ mailing list can be used for discussion of
new features and language changes.

If the idea is reasonable, someone will suggest posting it as a feature
request on the `issue tracker`_.

.. _issue tracker: http://d.puremagic.com/issues/


Where should I report specific problems?
----------------------------------------

Specific problems should be posted to the `issue tracker`_.


What if I'm not sure it is a bug?
---------------------------------

The general D help locations listed above are the best place to start
with that kind of question. If they agree it looks like a bug, then the
next step is to either post it to the `issue tracker`_.


Version Control
===============

Where can I learn about the version control system used, Git?
-------------------------------------------------------------

Git's official web site is at http://git-scm.com/.  The
`official Git tutorial`_ is a good place to get started.

.. _official Git tutorial: http://schacon.github.com/git/gittutorial.html/

With Git installed, you can run the help tool that comes with Git to get help::

  git help


SSH
===

How do I generate an SSH 2 public key?
--------------------------------------

GNU/Linux
'''''''''

Run::

  ssh-keygen -t rsa

This will generate two files; your public key and your private key.  Your
public key is the file ending in ``.pub``.

Windows
'''''''

Use PuTTYgen_ to generate your public key.  Choose the "SSH2 DSA" radio button,
have it create an OpenSSH formatted key, choose a password, and save the private
key to a file.  Copy the section with the public key (using Alt-P) to a file;
that file now has your public key.

.. _PuTTYgen: http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html


.. TODO: add more Q/A as needed.
