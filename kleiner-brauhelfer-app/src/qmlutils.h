#ifndef QMLUTILS_H
#define QMLUTILS_H

#include <QObject>
#include <QUrl>
#include <QColor>

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

    /**
     * @brief toColor
     * @param rgb
     * @return
     */
    Q_INVOKABLE static QColor toColor(unsigned int rgb);
};

#endif // QMLUTILS_H
