#include "syncservicemanager.h"

#include "syncservicelocal.h"
#if DROPBOX_EN
  #include "syncservicedropbox.h"
#endif
#include "syncservicewebdav.h"

bool SyncServiceManager::supportsSsl()
{
    return QSslSocket::supportsSsl();
}

QString SyncServiceManager::sslLibraryBuildVersionString()
{
    return QSslSocket::sslLibraryBuildVersionString();
}

QString SyncServiceManager::sslLibraryVersionString()
{
    return QSslSocket::sslLibraryVersionString();
}

SyncServiceManager::SyncServiceManager(QSettings *settings, QObject *parent) :
    QObject(parent),
    mSettings(settings)
{
    mSyncServiceLocal = new SyncServiceLocal(mSettings);
    connect(mSyncServiceLocal, SIGNAL(progress(qint64,qint64)), this, SIGNAL(progress(qint64,qint64)));
    connect(mSyncServiceLocal, SIGNAL(errorOccurred(int,const QString&)), this, SIGNAL(errorOccurred(int,const QString&)));
    mServices.append(mSyncServiceLocal);
  #if DROPBOX_EN
    mSyncServiceDropbox = new SyncServiceDropbox(mSettings);
    connect(mSyncServiceDropbox, SIGNAL(progress(qint64,qint64)), this, SIGNAL(progress(qint64,qint64)));
    connect(mSyncServiceDropbox, SIGNAL(errorOccurred(int,const QString&)), this, SIGNAL(errorOccurred(int,const QString&)));
    mServices.append(mSyncServiceDropbox);
  #endif
    mSyncServiceWebDav = new SyncServiceWebDav(mSettings);
    connect(mSyncServiceWebDav, SIGNAL(progress(qint64,qint64)), this, SIGNAL(progress(qint64,qint64)));
    connect(mSyncServiceWebDav, SIGNAL(errorOccurred(int,const QString&)), this, SIGNAL(errorOccurred(int,const QString&)));
    mServices.append(mSyncServiceWebDav);
    setServiceId((SyncServiceId)mSettings->value("SyncService/Id", 0).toInt());
}

SyncServiceManager::~SyncServiceManager()
{
    qDeleteAll(mServices);
    mServices.clear();
}

SyncService* SyncServiceManager::service() const
{
    return service(serviceId());
}

SyncService* SyncServiceManager::service(SyncServiceId id) const
{
    if (id < 0 || id >= mServices.count())
        id = SyncServiceId::Local;
    return mServices.at(id);
}

SyncServiceManager::SyncServiceId SyncServiceManager::serviceId() const
{
    return mServiceId;
}

void SyncServiceManager::setServiceId(SyncServiceId id)
{
    if (id < 0 || id >= mServices.count())
        id = SyncServiceId::Local;
    if (mServiceId != id)
    {
        mServiceId = id;
        mSettings->setValue("SyncService/Id", (int)serviceId());
        emit serviceIdChanged(serviceId());
        emit serviceChanged(service());
    }
}

bool SyncServiceManager::serviceAvailable() const
{
    return service()->isServiceAvailable();
}

QString SyncServiceManager::filePath() const
{
    return service()->getFilePath();
}

SyncService::SyncState SyncServiceManager::syncState() const
{
    return service()->getState();
}

bool SyncServiceManager::download()
{
    return service()->synchronize(SyncService::Download);
}

bool SyncServiceManager::upload()
{
    return service()->synchronize(SyncService::Upload);
}

void SyncServiceManager::clearCache()
{
    service()->clearCache();
}
