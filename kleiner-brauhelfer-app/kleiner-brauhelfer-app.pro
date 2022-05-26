QT += core gui widgets qml quick quickcontrols2 charts sql network xml
android: QT += androidextras

# organization, application name and version
ORGANIZATION = kleiner-brauhelfer
TARGET = kleiner-brauhelfer-app
VER_MAJ = 2
VER_MIN = 4
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

!android: DESTDIR = $$OUT_PWD/..

# default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

# android deployment
ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
ANDROID_ABIS = armeabi-v7a arm64-v8a x86 x86_64
ANDROID_EXTRA_LIBS += \
    $$PWD/android/libs/arm/libcrypto_1_1.so \
    $$PWD/android/libs/arm/libssl_1_1.so \
    $$PWD/android/libs/arm64/libcrypto_1_1.so \
    $$PWD/android/libs/arm64/libssl_1_1.so \
    $$PWD/android/libs/x86/libcrypto_1_1.so \
    $$PWD/android/libs/x86/libssl_1_1.so \
    $$PWD/android/libs/x86_64/libcrypto_1_1.so \
    $$PWD/android/libs/x86_64/libssl_1_1.so

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
