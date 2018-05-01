# QT modules
QT += network xml
QT -= core gui

# organization, application name and version
TARGET = qtdropbox2

# build library
TEMPLATE = lib
DEFINES += QTDROPBOX_LIBRARY
CONFIG += skip_target_version_ext

# temporary and destination folders
OBJECTS_DIR = tmp
MOC_DIR = tmp
UI_DIR = tmp
RCC_DIR = tmp
win32: DESTDIR = ../bin

# header and source files
include(qtdropbox2.pri)
