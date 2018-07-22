#include "languageselector.h"
#include <QLocale>
#include <QQmlApplicationEngine>

LanguageSelector::LanguageSelector(QCoreApplication* parent, QQmlEngine *engine, const QString& language) :
    mParent(parent),
    mEngine(engine)
{
    if (language.isEmpty())
        selectLanguage(QLocale::system().name());
    else
        selectLanguage(language);
}

void LanguageSelector::selectLanguage(const QString& language)
{
    if (mCurrentLanguage != language)
    {
        mCurrentLanguage = language;
        mParent->removeTranslator(&mTranslator);
        if (mTranslator.load(QString("kb_app_%1").arg(mCurrentLanguage), ":/languages/"))
            mParent->installTranslator(&mTranslator);
        mEngine->retranslate();
        emit languageChanged(mCurrentLanguage);
    }
}
