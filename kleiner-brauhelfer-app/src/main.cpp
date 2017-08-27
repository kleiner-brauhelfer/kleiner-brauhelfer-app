#include <QApplication>
#include <QQmlApplicationEngine>
#include <QSettings>

#include "brauhelfer.h"
#include "syncservicemanager.h"
#include "qmlutils.h"

static Brauhelfer *bh;
static SyncServiceManager *syncMan;
static QmlUtils *utils;

static QObject *getInstance(QQmlEngine *engine, QJSEngine *scriptEngine)
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

    // create singleton instance
    QSettings *settings = new QSettings();
    syncMan = new SyncServiceManager(settings);
    bh = new Brauhelfer(syncMan->service());
    QObject::connect(syncMan, SIGNAL(serviceChanged(SyncService*)), bh, SLOT(setSyncService(SyncService*)));
  #ifdef QT_DEBUG
    bh->setVerbose(true);
  #endif
    utils = new QmlUtils();

    // register classes to QML
    qmlRegisterSingletonType<Brauhelfer>("brauhelfer", 1, 0, "Brauhelfer", getInstance);
    qmlRegisterSingletonType<SyncServiceManager>("brauhelfer", 1, 0, "SyncService", getInstanceSyncServiceManager);
    qmlRegisterSingletonType<QmlUtils>("qmlutils", 1, 0, "Utils", getInstanceUtils);

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
