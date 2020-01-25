QT += core gui widgets qml quick quickcontrols2 charts sql network xml

# organization, application name and version
ORGANIZATION = kleiner-brauhelfer
TARGET = kleiner-brauhelfer-app
VER_MAJ = 2
VER_MIN = 1
VER_PAT = 0
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

!android: DESTDIR = $$OUT_PWD/../bin
OBJECTS_DIR = tmp
MOC_DIR = tmp
UI_DIR = tmp
RCC_DIR = tmp

# enable / disable dropbox support
CONFIG += dropbox_en
dropbox_en {
    !android: LIBS += -L$$OUT_PWD/../bin/ -lqtdropbox2
    android: LIBS += -L$$OUT_PWD/../qtdropbox2/ -lqtdropbox2
    INCLUDEPATH += $$PWD/../qtdropbox2/src
    DEPENDPATH += $$PWD/../qtdropbox2/src
    DEFINES += DROPBOX_EN=1
}

# default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

# android deployment
ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
contains(ANDROID_TARGET_ARCH,armeabi-v7a) {
    ANDROID_EXTRA_LIBS = \
        $$PWD/android/libs/armeabi-v7a/libcrypto.so \
        $$PWD/android/libs/armeabi-v7a/libssl.so
}
contains(ANDROID_TARGET_ARCH,x86) {
    ANDROID_EXTRA_LIBS = \
        $$PWD/android/libs/x86/libcrypto.so \
        $$PWD/android/libs/x86/libssl.so
}

# libraries
!android: LIBS += -L$$OUT_PWD/../bin/ -lkleiner-brauhelfer-core
android: LIBS += -L$$OUT_PWD/../kleiner-brauhelfer-core/ -lkleiner-brauhelfer-core
INCLUDEPATH += $$PWD/../kleiner-brauhelfer-core
DEPENDPATH += $$PWD/../kleiner-brauhelfer-core

# header files
INCLUDEPATH += src ../kleiner-brauhelfer-core/src
HEADERS += \
    src/qmlutils.h \
    src/syncservice.h \
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
    android/gradlew.bat
