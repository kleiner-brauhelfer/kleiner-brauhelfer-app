#include <QApplication>
#include <QQmlApplicationEngine>
#include <QSettings>

#include "languageselector.h"
#include "brauhelfer.h"
#include "syncservicemanager.h"
#include "qmlutils.h"
#include "proxymodel.h"
#include "proxymodelrohstoff.h"
#include "proxymodelsud.h"

static LanguageSelector* langSel;
static Brauhelfer *bh;
static SyncServiceManager *syncMan;
static QmlUtils *utils;

static QObject *getInstanceLanguageSelector(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return langSel;
}

static QObject *getInstanceBrauhelfer(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return bh;
}

static QObject *getInstanceSyncServiceManager(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return syncMan;
}

static QObject *getInstanceUtils(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return utils;
}

int main(int argc, char *argv[])
{
    QCoreApplication::setOrganizationName(QString(ORGANIZATION));
    QCoreApplication::setApplicationName(QString(TARGET));
    QCoreApplication::setApplicationVersion(QString(VERSION));
	
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);
    QQmlApplicationEngine engine;

    // create singleton instance
    QSettings *settings = new QSettings();
    langSel = new LanguageSelector(&app, &engine);
    syncMan = new SyncServiceManager(settings);
    bh = new Brauhelfer();
    utils = new QmlUtils();

    // register classes to QML
    qmlRegisterSingletonType<LanguageSelector>("languageSelector", 1, 0, "LanguageSelector", getInstanceLanguageSelector);
    qmlRegisterSingletonType<Brauhelfer>("brauhelfer", 1, 0, "Brauhelfer", getInstanceBrauhelfer);
    qmlRegisterSingletonType<SyncServiceManager>("brauhelfer", 1, 0, "SyncService", getInstanceSyncServiceManager);
    qmlRegisterSingletonType<QmlUtils>("qmlutils", 1, 0, "Utils", getInstanceUtils);
    qmlRegisterType<ProxyModel>("ProxyModel", 1, 0, "ProxyModel");
    qmlRegisterType<ProxyModelRohstoff>("ProxyModelRohstoff", 1, 0, "ProxyModelRohstoff");
    qmlRegisterType<ProxyModelSud>("ProxyModelSud", 1, 0, "ProxyModelSud");

    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
