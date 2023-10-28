#include "qmlutils.h"
#ifdef Q_OS_ANDROID
  #include <QtCore/private/qandroidextras_p.h>
#else
  #include <QDir>
#endif

QString QmlUtils::toLocalFile(const QUrl &url)
{
  #ifdef Q_OS_ANDROID
    const QJniObject uri = QJniObject::callStaticObjectMethod(
        "android/net/Uri", "parse",
        "(Ljava/lang/String;)Landroid/net/Uri;",
        QJniObject::fromString(url.toString()).object<jstring>());
    return QJniObject::callStaticObjectMethod(
        "org/kleinerbrauhelfer/app/PathUtil", "getPath",
        "(Landroid/content/Context;Landroid/net/Uri;)Ljava/lang/String;",
        QtAndroidPrivate::context(), uri.object()).toString();
  #else
    return QDir::toNativeSeparators(url.toLocalFile());
  #endif
}

QColor QmlUtils::toColor(unsigned int rgb)
{
    return QColor(rgb);
}
