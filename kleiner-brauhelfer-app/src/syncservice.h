#ifndef SYNCSERVICE_H
#define SYNCSERVICE_H

#include <QObject>
#include <QSettings>

/**
 * @brief Abstract class for synchronization service
 */
class SyncService : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool serviceAvailable READ isServiceAvailable NOTIFY serviceAvailableChanged)
    Q_PROPERTY(QString filePath READ getFilePath NOTIFY filePathChanged)
    Q_PROPERTY(SyncState state READ getState NOTIFY stateChanged)

public:

    /**
     * @brief State of the file synchronization
     */
    enum SyncState
    {
        UpToDate,
        Updated,
        Offline,
        NotFound,
        OutOfSync,
        Failed
    };
    Q_ENUM(SyncState)

    /**
     * @brief Direction to synchronize
     */
    enum SyncDirection
    {
        Download,
        Upload
    };
    Q_ENUM(SyncDirection)

public:

    /**
     * @brief Abstract class for synchronization service
     * @param settings Settings
     * @param urlServerCheck URL to check availability if synchronization service
     */
    SyncService(QSettings *settings, const QString &urlServerCheck = "");
    virtual ~SyncService();

    /**
     * @brief Checks if the synchronization server is available
     * @return True if available
     */
    Q_INVOKABLE bool checkIfServiceAvailable();

    /**
     * @brief State of the synchronization server availability
     * @return True if available
     */
    bool isServiceAvailable() const;

    /**
     * @brief Gets the path to the local file
     * @return Path
     */
    QString getFilePath() const;

    /**
     * @brief Gets the state of the file synchronization
     * @return State
     */
    SyncState getState() const;

    /**
     * @brief Synchronizes the file
     * @param direction Direction to synchronize
     * @note See getState() for details about the synchronization state
     * @return True on success
     */
    virtual bool synchronize(SyncDirection direction) = 0;

    /**
     * @brief Clears the whole cache
     * @note All local files will be deleted
     */
    Q_INVOKABLE static void clearCache();

signals:

    /**
     * @brief Download or upload progress
     * @param current Current number of bytes transferred
     * @param total Total number of bytes to transfer
     */
    void progress(qint64 current, qint64 total);

    /**
     * @brief Emitted when an error occurred
     * @param errorcode Error code
     * @param errormessage Error message
     */
    void errorOccurred(int errorcode, const QString& errormessage);

    /**
     * @brief Signal when the service availability changed
     * @param serviceAvailable Service availability
     */
    void serviceAvailableChanged(bool serviceAvailable);

    /**
     * @brief Signal when the file path changed
     * @param filePath File path
     */
    void filePathChanged(QString filePath);

    /**
     * @brief Signal when the state changed
     * @param state State
     */
    void stateChanged(SyncState state);

protected:

    /**
     * @brief Sets the path to the local file
     * @param filePath File path
     */
    void setFilePath(const QString &filePath);

    /**
     * @brief Sets the state
     * @param state State
     */
    void setState(SyncState state);

    /**
     * @brief Gets a path to store a file in the cache
     * @param filePath File
     * @return File path in the cache
     */
    static QString cacheFilePath(const QString filePath);

    QSettings* _settings;
    QString _urlServerCheck;

private:
    bool _online;
    QString _filePath;
    SyncState _state;
};

#endif // SYNCSERVICE_H
