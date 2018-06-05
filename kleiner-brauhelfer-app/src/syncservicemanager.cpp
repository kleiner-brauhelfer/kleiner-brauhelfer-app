#include "syncservicemanager.h"

#include "syncservicelocal.h"
#if DROPBOX_EN
  #include "syncservicedropbox.h"
#endif
#include "syncservicewebdav.h"

SyncServiceManager::SyncServiceManager(QSettings *settings, QObject *parent) :
    QObject(parent),
    _settings(settings)
{
    syncServiceLocal = new SyncServiceLocal(_settings);
    _services.append(syncServiceLocal);
  #if DROPBOX_EN
    syncServiceDropbox = new SyncServiceDropbox(_settings);
    _services.append(syncServiceDropbox);
  #endif
    syncServiceWebDav = new SyncServiceWebDav(_settings);
    _services.append(syncServiceWebDav);
    setServiceId((SyncServiceId)_settings->value("SyncService/Id").toInt());
}

SyncServiceManager::~SyncServiceManager()
{
    qDeleteAll(_services);
    _services.clear();
}

SyncService* SyncServiceManager::service() const
{
    return service(serviceId());
}

SyncService* SyncServiceManager::service(SyncServiceId id) const
{
    if (id < 0 || id >= _services.count())
        id = SyncServiceId::Local;
    return _services.at(id);
}

SyncServiceManager::SyncServiceId SyncServiceManager::serviceId() const
{
    return _serviceId;
}

void SyncServiceManager::setServiceId(SyncServiceId id)
{
    if (id < 0 || id >= _services.count())
        id = SyncServiceId::Local;
    if (_serviceId != id)
    {
        _serviceId = id;
        _settings->setValue("SyncService/Id", (int)serviceId());
        emit serviceIdChanged(serviceId());
        emit serviceChanged(service());
    }
}
