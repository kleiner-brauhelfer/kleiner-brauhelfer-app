QT += network xml
QT -= core gui

TEMPLATE = lib
TARGET = qtdropbox2
DEFINES += QTDROPBOX_LIBRARY
CONFIG += skip_target_version_ext unversioned_libname unversioned_soname

!android: DESTDIR = $$OUT_PWD/../bin
OBJECTS_DIR = tmp
MOC_DIR = tmp
UI_DIR = tmp
RCC_DIR = tmp

include(qtdropbox2.pri)
