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
     */
    SyncService(QSettings *settings);
    virtual ~SyncService();

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
    Q_INVOKABLE void clearCache();

signals:

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
    void stateChanged(SyncService::SyncState state);

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
     * @brief clearCachedSettings
     */
    virtual void clearCachedSettings();

    /**
     * @brief Gets a path to store a file in the cache
     * @param filePath File
     * @return File path in the cache
     */
    static QString cacheFilePath(const QString filePath);

    QSettings* _settings;

private:
    QString _filePath;
    SyncState _state;
};

#endif // SYNCSERVICE_H
