#include "qmlutils.h"

QString QmlUtils::toLocalFile(const QUrl &url)
{
    return url.toLocalFile();
}

QColor QmlUtils::toColor(unsigned int rgb)
{
    return QColor(rgb);
}
