#ifndef SYNCSERVICEMANAGER_H
#define SYNCSERVICEMANAGER_H

#include <QObject>
#include <QSettings>

#include "syncservice.h"

/**
 * Manager for file synchronization services
 */
class SyncServiceManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(SyncServiceId serviceId READ serviceId WRITE setServiceId NOTIFY serviceIdChanged)
    Q_PROPERTY(SyncService* syncServiceLocal MEMBER syncServiceLocal CONSTANT)
  #if DROPBOX_EN
    Q_PROPERTY(SyncService* syncServiceDropbox MEMBER syncServiceDropbox CONSTANT)
  #endif
    Q_PROPERTY(SyncService* syncServiceWebDav MEMBER syncServiceWebDav CONSTANT)

public:

    /**
     * @brief Formel für Umrechnung von brix [°brix] nach spezifische Dichte [g/ml]
     */
    enum SyncServiceId
    {
        Local,
        Dropbox,
        WebDav
    };
    Q_ENUM(SyncServiceId)

    /**
     * @brief Manager for file synchronization servivces
     * @param settings Settings
     * @param parent Parent
     */
    SyncServiceManager(QSettings *settings = new QSettings(), QObject *parent = Q_NULLPTR);
    ~SyncServiceManager();

    /**
     * @brief Gets the current service
     * @return Current service
     */
    SyncService* service() const;

    /**
     * @brief Gets a service by its ID
     * @param id Service ID
     * @return Service
     */
    SyncService* service(SyncServiceId id) const;

    /**
     * @brief Gets the current service
     * @return Service ID
     */
    SyncServiceId serviceId() const;

    /**
     * @brief Sets the current service
     * @param id Service ID
     */
    void setServiceId(SyncServiceId id);

signals:

    /**
     * @brief Signal when the service ID changed
     * @param serviceId Service ID
     */
    void serviceIdChanged(SyncServiceId serviceId);

    /**
     * @brief Signal when the service changed
     * @param service Service
     */
    void serviceChanged(SyncService *service);

private:

    QSettings* _settings;
    SyncServiceId _serviceId;
    QList<SyncService*> _services;
    SyncService* syncServiceLocal;
  #if DROPBOX_EN
    SyncService* syncServiceDropbox;
  #endif
    SyncService* syncServiceWebDav;
};

#endif // SYNCSERVICEMANAGER_H
