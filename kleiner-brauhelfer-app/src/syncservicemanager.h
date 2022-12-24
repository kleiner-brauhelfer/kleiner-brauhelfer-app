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
    Q_PROPERTY(QString filePath READ filePath NOTIFY filePathChanged)
    Q_PROPERTY(SyncService::SyncState syncState READ syncState NOTIFY syncStateChanged)
    Q_PROPERTY(SyncService* syncServiceLocal MEMBER mSyncServiceLocal CONSTANT)
    Q_PROPERTY(SyncService* syncServiceDropbox MEMBER mSyncServiceDropbox CONSTANT)
    Q_PROPERTY(SyncService* syncServiceWebDav MEMBER mSyncServiceWebDav CONSTANT)

public:

    /**
     * @brief Returns true if this platform supports SSL
     */
    Q_INVOKABLE static bool supportsSsl();

    /**
     * @brief Returns the version string of the SSL library in use at compile time
     */
    Q_INVOKABLE static QString sslLibraryBuildVersionString();

    /**
     * @brief Returns the version string of the SSL library in use at run time
     * @return
     */
    Q_INVOKABLE static QString sslLibraryVersionString();

public:

    /**
     * @brief Service IDs
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
    SyncServiceManager(QSettings *settings = new QSettings(), QObject *parent = nullptr);
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

    /**
     * @brief Gets the path to the local file
     * @return Path
     */
    QString filePath() const;

    /**
     * @brief Gets the state of the file synchronization
     * @return State
     */
    SyncService::SyncState syncState() const;

    /**
     * @brief Downloads the file
     * @return True on success
     */
    Q_INVOKABLE bool download();

    /**
     * @brief Uploads the file
     * @return True on success
     */
    Q_INVOKABLE bool upload();

    /**
     * @brief Clears the cache
     */
    Q_INVOKABLE void clearCache();

signals:

    /**
     * @brief Signal when the service ID changed
     * @param serviceId Service ID
     */
    void serviceIdChanged(SyncServiceManager::SyncServiceId serviceId);

    /**
     * @brief Signal when the service changed
     * @param service Service
     */
    void serviceChanged(SyncService *service);

    /**
     * @brief Signal to emit a messsage
     * @param type Type
     * @param txt Message
     */
    void message(int type, const QString& txt);

    /**
     * @brief Signal when the file path changed
     * @param filePath File path
     */
    void filePathChanged(QString filePath);

    /**
     * @brief Signal when the state changed
     * @param state State
     */
    void syncStateChanged(SyncService::SyncState state);

private:
    QSettings* mSettings;
    SyncServiceId mServiceId;
    QList<SyncService*> mServices;
    SyncService* mSyncServiceLocal;
    SyncService* mSyncServiceDropbox;
    SyncService* mSyncServiceWebDav;
};

#endif // SYNCSERVICEMANAGER_H
