#ifndef QMLUTILS_H
#define QMLUTILS_H

#include <QObject>
#include <QUrl>

/**
 * @brief Utility class for QML applications
 */
class QmlUtils : public QObject
{
    Q_OBJECT

public:

    /**
     * @brief Returns a string representing a local path from an URL
     * @param url URL
     * @return Local file path
     */
    Q_INVOKABLE static QString toLocalFile(const QUrl &url);
};

#endif // QMLUTILS_H
