TEMPLATE = subdirs
SUBDIRS += \
    qtdropbox2 \
    kleiner-brauhelfer-core \
    kleiner-brauhelfer-app
CONFIG += ordered

qtdropbox2.subdir = qtdropbox2
kleiner-brauhelfer-core.subdir = kleiner-brauhelfer-core
kleiner-brauhelfer-app.subdir = kleiner-brauhelfer-app

kleiner-brauhelfer-app.depends = qtdropbox2 kleiner-brauhelfer-core
