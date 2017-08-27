#include "syncservice.h"

#include <QtNetwork>

SyncService::SyncService(QSettings *settings, const QString &urlServerCheck) :
    _settings(settings),
    _state(SyncState::Failed),
    _urlServerCheck(urlServerCheck)
{
    _online = checkIfServiceAvailable();
}


bool SyncService::isServiceAvailable() const
{
    return _online;
}

bool SyncService::checkIfServiceAvailable()
{
    if (_urlServerCheck != "")
    {
        const QUrl url = QUrl(_urlServerCheck);
        QNetworkAccessManager nam;
        QNetworkRequest req(url);
        QNetworkReply *reply = nam.get(req);

        QEventLoop loop;
        connect(reply, SIGNAL(finished()), &loop, SLOT(quit()));
        loop.exec();

        return reply->bytesAvailable();
    }
    else
    {
        return true;
    }
}

QString SyncService::getFilePath() const
{
    return _filePath;
}

void SyncService::setFilePath(const QString &path)
{
    _filePath = path;
}

SyncService::SyncState SyncService::getState() const
{
    return _state;
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
}

QString SyncService::cacheFilePath(const QString filePath)
{
    return QDir::cleanPath(QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + QDir::separator() + filePath);
}
