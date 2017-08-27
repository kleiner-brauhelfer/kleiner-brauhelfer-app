#include "qmlutils.h"

QString QmlUtils::toLocalFile(const QUrl &url)
{
    return url.toLocalFile();
}
