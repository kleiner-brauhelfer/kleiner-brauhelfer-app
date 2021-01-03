TEMPLATE = subdirs
SUBDIRS += kleiner-brauhelfer-core \
           kleiner-brauhelfer-app
CONFIG += ordered

kleiner-brauhelfer-core.subdir = kleiner-brauhelfer-core
kleiner-brauhelfer-app.subdir = kleiner-brauhelfer-app
kleiner-brauhelfer-app.depends = kleiner-brauhelfer-core
