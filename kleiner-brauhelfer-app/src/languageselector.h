#ifndef LANGUAGESELECTOR_H
#define LANGUAGESELECTOR_H

#include <QObject>
#include <QCoreApplication>
#include <QQmlEngine>
#include <QString>
#include <QTranslator>

class LanguageSelector : public QObject
{
    Q_OBJECT

public:
    LanguageSelector(QCoreApplication* parent, QQmlEngine* engine, const QString& language = QString());
    Q_INVOKABLE void selectLanguage(const QString& language);

signals:
    void languageChanged(const QString& language);

private:
    QCoreApplication* mParent;
    QQmlEngine* mEngine;
    QString mCurrentLanguage;
    QTranslator mTranslator;
};

#endif // LANGUAGESELECTOR_H
