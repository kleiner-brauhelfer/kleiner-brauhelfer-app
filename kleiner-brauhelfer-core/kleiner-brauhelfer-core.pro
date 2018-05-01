# QT modules
QT += sql network xml

# organization, application name and version
ORGANIZATION = BourgeoisLab
TARGET = kleiner-brauhelfer-core
VER_MAJ = 1
VER_MIN = 0
VER_PAT = 0
VERSION = $$sprintf("%1.%2.%3",$$VER_MAJ,$$VER_MIN,$$VER_PAT)
DEFINES += ORGANIZATION=\\\"$$ORGANIZATION\\\" TARGET=\\\"$$TARGET\\\" VERSION=\\\"$$VERSION\\\"
DEFINES += VER_MAJ=\"$$VER_MAJ\" VER_MIN=\"$$VER_MIN\" VER_PAT=\"$$VER_PAT\"

# build library
TEMPLATE = lib
DEFINES += KBCORE_LIBRARY
CONFIG += skip_target_version_ext

# warnings
DEFINES += QT_DEPRECATED_WARNINGS
CONFIG += warn_on

# temporary and destination folders
OBJECTS_DIR = tmp
MOC_DIR = tmp
UI_DIR = tmp
RCC_DIR = tmp
win32: DESTDIR = ../bin

# header files
HEADERS += src/biercalc.h \
    src/brauhelfer.h \
    src/database.h \
    src/syncservice.h \
    src/syncservicelocal.h \
    src/modelhauptgaerverlauf.h \
    src/modelnachgaerverlauf.h \
    src/modelschnellgaerverlauf.h \
    src/modelsud.h \
    src/sqltablemodel.h \
    src/sudobject.h \
    src/modelbewertungen.h \
    src/modelwasser.h

# source files
SOURCES += src/biercalc.cpp \
    src/brauhelfer.cpp \
    src/database.cpp \
    src/syncservice.cpp \
    src/syncservicelocal.cpp \
    src/modelhauptgaerverlauf.cpp \
    src/modelnachgaerverlauf.cpp \
    src/modelschnellgaerverlauf.cpp \
    src/modelsud.cpp \
    src/sqltablemodel.cpp \
    src/sudobject.cpp \
    src/modelbewertungen.cpp \
    src/modelwasser.cpp
