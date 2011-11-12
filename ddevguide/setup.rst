.. _setup:

Getting Set Up
==============

These instructions cover how to get a working copy of the source code of the
DMD compiler (DMD is Digital Mars D compiler available from
http://www.d-programming-language.org/), Phobos, and druntime. It also gives
an overview of the directory structure of the DMD and Phobos source code.

.. contents::


Version Control Setup
---------------------

DMD and Phobos are developed using `Git <http://http://git-scm.com/>`_.
It is easily available for GNU/Linux, Windows, and Mac OSX systems;


.. _checkout:

Getting the Source Code
-----------------------

To get a working copy of DMD, run::

   git clone https://github.com/D-Programming-Language/d-programming-language.org.git


To get a working copy of Phobos, run::

   git clone https://github.com/D-Programming-Language/phobos.git


To get a working copy of druntime, run::

   git clone https://github.com/D-Programming-Language/druntime.git


.. _compiling:

Compiling (for debuggin)
------------------------

.. TODO: how to set up all the needed variables for debugging mode.


Build dependencies
''''''''''''''''''

.. TODO: list all dependencies.


GNU/Linux
'''''''''

.. TODO: how to compile DMD on GNU/Linux.

Windows
'''''''

.. TODO: how to compile DMD on Windows.


Mac OSX
'''''''

.. TODO: how to compile DMD on Mac OSX.


Editors and Tools
=================

D is beginning to be used widely enough that many code editors have some form
of support for writing D code.

For editors and tools for coding in D, see :ref:`resources`.


Directory Structure
===================

There are several top-level directories in the DMD and Phobos source tree.
Knowing what each one is meant to hold will help you find where a certain piece of
functionality is implemented. Do realize, though, there are always exceptions to
every rule.

DMD
---

``docs``
     The man pages for DMD.

``samples``
     Contains sample programs written in D.


.. TODO: add any other directories as needed.


Phobos
------

``etc``
     STUFF GOES HERE

``std``
     STUFF GOES HERE

.. TODO: complete the description for each directory above and add any 
   other directories as needed.


druntime
--------

.. TODO: similar to above.
