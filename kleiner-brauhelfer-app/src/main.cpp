#include <QApplication>
#include <QQmlApplicationEngine>
#include <QSettings>
#ifdef Q_OS_ANDROID
  #include <QtAndroid>
#endif

#include "languageselector.h"
#include "brauhelfer.h"
#include "syncservicemanager.h"
#include "qmlutils.h"
#include "proxymodel.h"
#include "proxymodelrohstoff.h"
#include "proxymodelsud.h"

static LanguageSelector* langSel;
static Brauhelfer *bh;
static BierCalc *bierCalc;
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

static QObject *getInstanceBierCalc(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return bierCalc;
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

void checkPermissions()
{
  #ifdef Q_OS_ANDROID
    if(QtAndroid::checkPermission("android.permission.READ_EXTERNAL_STORAGE") == QtAndroid::PermissionResult::Denied)
        QtAndroid::requestPermissionsSync(QStringList() << "android.permission.READ_EXTERNAL_STORAGE");
    if(QtAndroid::checkPermission("android.permission.WRITE_EXTERNAL_STORAGE") == QtAndroid::PermissionResult::Denied)
        QtAndroid::requestPermissionsSync(QStringList() << "android.permission.WRITE_EXTERNAL_STORAGE");
  #endif
}

int main(int argc, char *argv[])
{
  #ifdef Q_OS_ANDROID
    qputenv("QT_ANDROID_ENABLE_WORKAROUND_TO_DISABLE_PREDICTIVE_TEXT", "1");
  #endif

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
    bierCalc = new BierCalc();
    utils = new QmlUtils();

    // register classes to QML
    qmlRegisterSingletonType<LanguageSelector>("languageSelector", 1, 0, "LanguageSelector", getInstanceLanguageSelector);
    qmlRegisterSingletonType<Brauhelfer>("brauhelfer", 1, 0, "Brauhelfer", getInstanceBrauhelfer);
    qmlRegisterSingletonType<BierCalc>("brauhelfer", 1, 0, "BierCalc", getInstanceBierCalc);
    qmlRegisterSingletonType<SyncServiceManager>("brauhelfer", 1, 0, "SyncService", getInstanceSyncServiceManager);
    qmlRegisterSingletonType<QmlUtils>("qmlutils", 1, 0, "Utils", getInstanceUtils);
    qmlRegisterType<ProxyModel>("ProxyModel", 1, 0, "ProxyModel");
    qmlRegisterType<ProxyModelRohstoff>("ProxyModelRohstoff", 1, 0, "ProxyModelRohstoff");
    qmlRegisterType<ProxyModelSud>("ProxyModelSud", 1, 0, "ProxyModelSud");
    qmlRegisterUncreatableType<ModelSud>("ModelSud", 1, 0, "ModelSud", "not creatable");
    qmlRegisterUncreatableType<ModelRasten>("ModelRasten", 1, 0, "ModelRasten", "not creatable");
    qmlRegisterUncreatableType<ModelMalzschuettung>("ModelMalzschuettung", 1, 0, "ModelMalzschuettung", "not creatable");
    qmlRegisterUncreatableType<ModelHopfengaben>("ModelHopfengaben", 1, 0, "ModelHopfengaben", "not creatable");
    qmlRegisterUncreatableType<ModelHefegaben>("ModelHefegaben", 1, 0, "ModelHefegaben", "not creatable");
    qmlRegisterUncreatableType<ModelWeitereZutatenGaben>("ModelWeitereZutatenGaben", 1, 0, "ModelWeitereZutatenGaben", "not creatable");
    qmlRegisterUncreatableType<ModelSchnellgaerverlauf>("ModelSchnellgaerverlauf", 1, 0, "ModelSchnellgaerverlauf", "not creatable");
    qmlRegisterUncreatableType<ModelHauptgaerverlauf>("ModelHauptgaerverlauf", 1, 0, "ModelHauptgaerverlauf", "not creatable");
    qmlRegisterUncreatableType<ModelNachgaerverlauf>("ModelNachgaerverlauf", 1, 0, "ModelNachgaerverlauf", "not creatable");
    qmlRegisterUncreatableType<ModelBewertungen>("ModelBewertungen", 1, 0, "ModelBewertungen", "not creatable");
    qmlRegisterUncreatableType<ModelMalz>("ModelMalz", 1, 0, "ModelMalz", "not creatable");
    qmlRegisterUncreatableType<ModelHopfen>("ModelHopfen", 1, 0, "ModelHopfen", "not creatable");
    qmlRegisterUncreatableType<ModelHefe>("ModelHefe", 1, 0, "ModelHefe", "not creatable");
    qmlRegisterUncreatableType<ModelWeitereZutaten>("ModelWeitereZutaten", 1, 0, "ModelWeitereZutaten", "not creatable");
    qmlRegisterUncreatableType<ModelAnhang>("ModelAnhang", 1, 0, "ModelAnhang", "not creatable");
    qmlRegisterUncreatableType<ModelAusruestung>("ModelAusruestung", 1, 0, "ModelAusruestung", "not creatable");
    qmlRegisterUncreatableType<ModelGeraete>("ModelGeraete", 1, 0, "ModelGeraete", "not creatable");
    qmlRegisterUncreatableType<ModelWasser>("ModelWasser", 1, 0, "ModelWasser", "not creatable");
    qmlRegisterUncreatableType<ModelEtiketten>("ModelEtiketten", 1, 0, "ModelEtiketten", "not creatable");
    qmlRegisterUncreatableType<ModelTags>("ModelTags", 1, 0, "ModelTags", "not creatable");

    // check permissions
    checkPermissions();

    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
