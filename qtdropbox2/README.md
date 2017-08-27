# QtDropbox2
A C++ Qt-based framework for accessing Dropbox using APIv2

## Summary
QtDropbox2 is a Qt-based framework for accessing the cloud storage service
[Dropbox](http://www.dropbox.com) using its new APIv2 protocols.

This project is based on the work done by Daniel Eder (lycis) in his QtDropbox
project (https://github.com/lycis/QtDropbox).  It has been heavily re-factored
into my particular style of C++ coding and design.  More importantly, it now
uses the new Dropbox APIv2 interfaces, which makes it future-proof for when the
Dropbox APIv1 interfaces are shut down in 2017.

## Qt versions
This projects was developed with, and tested under, Qt versions 5.4.2 and 5.6.2.
Versions of Qt prior to 5 will likely not compile without some code adjustments,
but I leave that as an exercise for the user who wishes to use previous Qt
versions.  There will be no support from me for versions prior to Qt5.

## Feature set
This project greatly expands on the feature set available in the original
QtDropbox project, and compartmentalizes those feature by their focus--i.e.,
account-based actions (e.g., user details) are only in QDropbox2, folder-actions
are circumscribed to the QDropbox2Folder class, etc.

Like the original project, some features have both synchronous and asynchronous
(signal/slot-base) versions.  Some do not have corresponding asynchronous
versions because only small amounts of data are involved in the exchanged, so
should not provide taxing.

The unit tests have also been greatly expanded to exercise most of the feature
set.  Most unit tests exercise synchronous calls, a few others test deferred
(signal-based) results.

### Current status
QtDropbox2 provides a robust interface to Dropbox, but it does not currently
wrap any of the APIv2 "sharing" or "paper" interfaces.  If there is interest
in having those, I will add them in the future.  For now, however, it nicely
satisfies my particular needs.

The library also implements the "upload_session" REST interface, which provides
for sending files of any size (beyond the 150MB limit of "upload").  The
selection of which interface to use--"upload" or "upload_session"--is invisible
to the API user.  The library will choose the correct interface based on the
size of the file being uploaded.

I have largely re-used the documentation system from the original project, but
may make some more adjustments in the future.

The project makes light usage of C++11, and has been compiled successfully
under Windows (Visual Studio 2013 and QtCreator), OS X (QtCreator + clang) and
Linux (QtCreator + gcc).  Unit tests have also run successfully under all three
operating systems.

## Usage
Please see the unit tests and documentation for illustrations of how to employ
this library if you need to programmatically access a Dropbox account.

## Documentation
As with the original project, you can generate a documentation of all classes
by executing:
    
    qmake
    make documentation

This will generate a directory called docs/html/ that contains a HTML
documentation. Input files to generate a LaTeX based configuration are supplied
as well.

## Further information
There are some files included in this project apart from this README that may
provide some useful information:

* LICENSE
  Same as original project, LGPL v3
* doc/
  Used for generating documentation (requires doxygen)
