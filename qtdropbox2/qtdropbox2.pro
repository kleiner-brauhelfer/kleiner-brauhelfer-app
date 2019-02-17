QT += network xml
QT -= core gui

TEMPLATE = lib
TARGET = qtdropbox2
DEFINES += QTDROPBOX_LIBRARY
CONFIG += skip_target_version_ext

include(qtdropbox2.pri)
