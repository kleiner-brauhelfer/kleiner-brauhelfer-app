!versionAtLeast(QT_VERSION, 6):error("Use at least Qt 6.0")

QT += core gui widgets qml quick quickcontrols2 charts sql network networkauth xml core5compat

android: QT += core-private

# organization, application name and version
ORGANIZATION = kleiner-brauhelfer
TARGET = kleiner-brauhelfer-app
VER_MAJ = 2
VER_MIN = 6
VER_PAT = 1
VERSION = $$sprintf("%1.%2.%3",$$VER_MAJ,$$VER_MIN,$$VER_PAT)
DEFINES += ORGANIZATION=\\\"$$ORGANIZATION\\\" TARGET=\\\"$$TARGET\\\" VERSION=\\\"$$VERSION\\\"
DEFINES += VER_MAJ=\"$$VER_MAJ\" VER_MIN=\"$$VER_MIN\" VER_PAT=\"$$VER_PAT\"

# build application
TEMPLATE = app

# configuration
CONFIG += c++11

# warnings
DEFINES += QT_DEPRECATED_WARNINGS
CONFIG += warn_on

!android: DESTDIR = $$OUT_PWD/..

# default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

# android deployment
ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
ANDROID_EXTRA_LIBS = $$PWD/android/libs/$${QT_ARCH}/libcrypto_3.so $$PWD/android/libs/$${QT_ARCH}/libssl_3.so

# libraries
!android: LIBS += -L$$OUT_PWD/../ -lkleiner-brauhelfer-core
android: LIBS += -L$$OUT_PWD/../kleiner-brauhelfer-core/ -lkleiner-brauhelfer-core_$${QT_ARCH}
INCLUDEPATH += $$PWD/../kleiner-brauhelfer-core
DEPENDPATH += $$PWD/../kleiner-brauhelfer-core

# header files
INCLUDEPATH += src ../kleiner-brauhelfer-core/src
HEADERS += \
    src/qmlutils.h \
    src/syncservice.h \
    src/syncservicegoogle.h \
    src/syncservicelocal.h \
    src/syncservicemanager.h \
    src/syncservicedropbox.h \
    src/syncservicewebdav.h \
    src/languageselector.h

# source files
SOURCES += \
    src/main.cpp \
    src/qmlutils.cpp \
    src/syncservice.cpp \
    src/syncservicegoogle.cpp \
    src/syncservicelocal.cpp \
    src/syncservicemanager.cpp \
    src/syncservicedropbox.cpp \
    src/syncservicewebdav.cpp \
    src/languageselector.cpp

# resource files
RESOURCES += qml.qrc \
    images.qrc \
    languages.qrc

# translation files
TRANSLATIONS += languages/kb_app_en.ts
lupdate_only {
    SOURCES += qml/*.qml
}

# distribution files
DISTFILES += \
    android/AndroidManifest.xml \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradlew \
    android/res/values/libs.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew.bat \
    android/src/org/kleinerbrauhelfer/app/PathUtil.java
