QT += network xml
QT -= core gui

TEMPLATE = lib
TARGET = qtdropbox2
DEFINES += QTDROPBOX_LIBRARY
CONFIG += skip_target_version_ext unversioned_libname unversioned_soname

!android: DESTDIR = $$OUT_PWD/..

include(qtdropbox2.pri)
