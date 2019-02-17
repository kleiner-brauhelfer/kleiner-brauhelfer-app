#include "syncservice.h"

#include <QtNetwork>

SyncService::SyncService(QSettings *settings, const QString &urlServerCheck) :
    _settings(settings),
    _urlServerCheck(urlServerCheck),
    _online(false),
    _filePath(""),
    _state(SyncState::Failed)
{
}

SyncService::~SyncService()
{
}

bool SyncService::isServiceAvailable() const
{
    return _online;
}

bool SyncService::checkIfServiceAvailable()
{
    if (_urlServerCheck != "")
    {
        QTimer timer;
        timer.setSingleShot(true);

        const QUrl url = QUrl(_urlServerCheck);
        QNetworkAccessManager nam;
        QNetworkRequest req(url);
        QNetworkReply *reply = nam.get(req);

        QEventLoop loop;
        connect(reply, SIGNAL(finished()), &loop, SLOT(quit()));
        connect(&timer, SIGNAL(timeout()), &loop, SLOT(quit()));
        timer.start(8000);
        loop.exec();
        if (timer.isActive())
            _online = reply->bytesAvailable();
        else
            _online = false;
    }
    else
    {
        _online = true;
    }
    emit serviceAvailableChanged(_online);
    return _online;
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
}

QString SyncService::cacheFilePath(const QString filePath)
{
    return QDir::cleanPath(QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + QDir::separator() + filePath);
}
