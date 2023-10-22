#include <QApplication>
#include <QQmlApplicationEngine>
#include <QSettings>
#ifdef Q_OS_ANDROID
  #include <QtCore/private/qandroidextras_p.h>
#endif

#include "languageselector.h"
#include "brauhelfer.h"
#include "biercalc.h"
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

int main(int argc, char *argv[])
{
  #ifdef Q_OS_ANDROID
    qputenv("QT_ANDROID_ENABLE_WORKAROUND_TO_DISABLE_PREDICTIVE_TEXT", "1");
  #endif

    QApplication app(argc, argv);
    QQmlApplicationEngine engine;

    app.setOrganizationName(QStringLiteral(ORGANIZATION));
    app.setApplicationName(QStringLiteral(TARGET));
    app.setApplicationVersion(QStringLiteral(VERSION));

    // create singleton instance
    QSettings *settings = new QSettings();
    langSel = new LanguageSelector(&app, &engine);
    syncMan = new SyncServiceManager(settings);
    bh = new Brauhelfer();
    bierCalc = new BierCalc();
    utils = new QmlUtils();

    // register classes to QML
    qmlRegisterSingletonType<LanguageSelector>("languageSelector", 1, 0, "LanguageSelector", [](...){return langSel;});
    qmlRegisterSingletonType<Brauhelfer>("brauhelfer", 1, 0, "Brauhelfer", [](...){return bh;});
    qmlRegisterSingletonType<BierCalc>("brauhelfer", 1, 0, "BierCalc", [](...){return bierCalc;});
    qmlRegisterSingletonType<SyncServiceManager>("brauhelfer", 1, 0, "SyncService", [](...){return syncMan;});
    qmlRegisterSingletonType<QmlUtils>("qmlutils", 1, 0, "Utils", [](...){return utils;});
    qmlRegisterType<ProxyModel>("ProxyModel", 1, 0, "ProxyModel");
    qmlRegisterType<ProxyModelRohstoff>("ProxyModelRohstoff", 1, 0, "ProxyModelRohstoff");
    qmlRegisterType<ProxyModelSud>("ProxyModelSud", 1, 0, "ProxyModelSud");
    qmlRegisterUncreatableType<ModelSud>("ModelSud", 1, 0, "ModelSud", QStringLiteral("not creatable"));
    qmlRegisterUncreatableType<ModelMaischplan>("ModelMaischplan", 1, 0, "ModelMaischplan", QStringLiteral("not creatable"));
    qmlRegisterUncreatableType<ModelMalzschuettung>("ModelMalzschuettung", 1, 0, "ModelMalzschuettung", QStringLiteral("not creatable"));
    qmlRegisterUncreatableType<ModelHopfengaben>("ModelHopfengaben", 1, 0, "ModelHopfengaben", QStringLiteral("not creatable"));
    qmlRegisterUncreatableType<ModelHefegaben>("ModelHefegaben", 1, 0, "ModelHefegaben", QStringLiteral("not creatable"));
    qmlRegisterUncreatableType<ModelWeitereZutatenGaben>("ModelWeitereZutatenGaben", 1, 0, "ModelWeitereZutatenGaben", QStringLiteral("not creatable"));
    qmlRegisterUncreatableType<ModelSchnellgaerverlauf>("ModelSchnellgaerverlauf", 1, 0, "ModelSchnellgaerverlauf", QStringLiteral("not creatable"));
    qmlRegisterUncreatableType<ModelHauptgaerverlauf>("ModelHauptgaerverlauf", 1, 0, "ModelHauptgaerverlauf", QStringLiteral("not creatable"));
    qmlRegisterUncreatableType<ModelNachgaerverlauf>("ModelNachgaerverlauf", 1, 0, "ModelNachgaerverlauf", QStringLiteral("not creatable"));
    qmlRegisterUncreatableType<ModelBewertungen>("ModelBewertungen", 1, 0, "ModelBewertungen", QStringLiteral("not creatable"));
    qmlRegisterUncreatableType<ModelMalz>("ModelMalz", 1, 0, "ModelMalz", QStringLiteral("not creatable"));
    qmlRegisterUncreatableType<ModelHopfen>("ModelHopfen", 1, 0, "ModelHopfen", QStringLiteral("not creatable"));
    qmlRegisterUncreatableType<ModelHefe>("ModelHefe", 1, 0, "ModelHefe", QStringLiteral("not creatable"));
    qmlRegisterUncreatableType<ModelWeitereZutaten>("ModelWeitereZutaten", 1, 0, "ModelWeitereZutaten", QStringLiteral("not creatable"));
    qmlRegisterUncreatableType<ModelAnhang>("ModelAnhang", 1, 0, "ModelAnhang", QStringLiteral("not creatable"));
    qmlRegisterUncreatableType<ModelAusruestung>("ModelAusruestung", 1, 0, "ModelAusruestung", QStringLiteral("not creatable"));
    qmlRegisterUncreatableType<ModelGeraete>("ModelGeraete", 1, 0, "ModelGeraete", QStringLiteral("not creatable"));
    qmlRegisterUncreatableType<ModelWasser>("ModelWasser", 1, 0, "ModelWasser", QStringLiteral("not creatable"));
    qmlRegisterUncreatableType<ModelEtiketten>("ModelEtiketten", 1, 0, "ModelEtiketten", QStringLiteral("not creatable"));
    qmlRegisterUncreatableType<ModelTags>("ModelTags", 1, 0, "ModelTags", QStringLiteral("not creatable"));

  #ifdef Q_OS_ANDROID
    // check permissions
    if (QtAndroidPrivate::checkPermission(QStringLiteral("android.permission.READ_EXTERNAL_STORAGE")).result() != QtAndroidPrivate::Authorized)
        QtAndroidPrivate::requestPermission(QStringLiteral("android.permission.READ_EXTERNAL_STORAGE")).result();
    if (QtAndroidPrivate::checkPermission(QStringLiteral("android.permission.WRITE_EXTERNAL_STORAGE")).result() != QtAndroidPrivate::Authorized)
        QtAndroidPrivate::requestPermission(QStringLiteral("android.permission.WRITE_EXTERNAL_STORAGE")).result();
    if (QtAndroidPrivate::checkPermission(QStringLiteral("android.permission.MANAGE_EXTERNAL_STORAGE")).result() != QtAndroidPrivate::Authorized)
        QtAndroidPrivate::requestPermission(QStringLiteral("android.permission.MANAGE_EXTERNAL_STORAGE")).result();
    if(!QJniObject::callStaticMethod<jboolean>("android/os/Environment", "isExternalStorageManager"))
    {
        QJniObject filepermit = QJniObject::getStaticObjectField("android/provider/Settings", "ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION", "Ljava/lang/String;");
        QJniObject pkgName = QJniObject::fromString(QStringLiteral("package:org.kleinerbrauhelfer.app"));
        QJniObject parsedUri = QJniObject::callStaticObjectMethod("android/net/Uri", "parse", "(Ljava/lang/String;)Landroid/net/Uri;", pkgName.object<jstring>());
        QJniObject intent("android/content/Intent", "(Ljava/lang/String;Landroid/net/Uri;)V", filepermit.object<jstring>(), parsedUri.object());
        QtAndroidPrivate::startActivity(intent, 0);
    }
  #endif

    // load QML and start
    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;
    return app.exec();
}
