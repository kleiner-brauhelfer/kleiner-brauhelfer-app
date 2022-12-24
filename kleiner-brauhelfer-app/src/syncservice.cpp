#include "syncservice.h"

#include <QtNetwork>

SyncService::SyncService(QSettings *settings, const QString &urlServerCheck) :
    _settings(settings),
    _urlServerCheck(urlServerCheck),
    _filePath(""),
    _state(SyncState::Failed)
{
}

SyncService::~SyncService()
{
}

QString SyncService::getFilePath() const
{
    return _filePath;
}

void SyncService::setFilePath(const QString &filePath)
{
    _filePath = filePath;
    emit filePathChanged(_filePath);
}

SyncService::SyncState SyncService::getState() const
{
    return _state;
}

void SyncService::setState(SyncService::SyncState state)
{
    _state = state;
    emit stateChanged(_state);
}

void SyncService::clearCache()
{
    QDir cache(QStandardPaths::writableLocation(QStandardPaths::CacheLocation));

    cache.setFilter(QDir::NoDotAndDotDot | QDir::Files);
    foreach(QString dirItem, cache.entryList())
        cache.remove(dirItem);

    cache.setFilter(QDir::NoDotAndDotDot | QDir::Dirs);
    foreach( QString dirItem, cache.entryList())
    {
        QDir subDir(cache.absoluteFilePath(dirItem));
        subDir.removeRecursively();
    }

    clearCachedSettings();
}

void SyncService::clearCachedSettings()
{
}

QString SyncService::cacheFilePath(const QString filePath)
{
    return QDir::cleanPath(QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + QDir::separator() + filePath);
}
