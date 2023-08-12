#include "qmlutils.h"
#include <QDir>
//#ifdef Q_OS_ANDROID
//  #include <QtAndroidExtras>
//#endif

QString QmlUtils::toLocalFile(const QUrl &url)
{
  #ifdef Q_OS_ANDROID
    /* TODO: make it work...
    QAndroidJniObject uri = QAndroidJniObject::callStaticObjectMethod(
                "android/net/Uri", "parse", "(Ljava/lang/String;)Landroid/net/Uri;",
                QAndroidJniObject::fromString(url.toString()).object<jstring>());
    return QAndroidJniObject::callStaticObjectMethod(
                "org/kleinerbrauhelfer/app/PathUtil", "getFileName",
                "(Landroid/net/Uri;Landroid/content/Context;)Ljava/lang/String;",
                uri.object(), QtAndroid::androidContext().object()).toString();
    */
    return QDir::toNativeSeparators(url.toString());
  #else
    return QDir::toNativeSeparators(url.toLocalFile());
  #endif
}

QColor QmlUtils::toColor(unsigned int rgb)
{
    return QColor(rgb);
}
