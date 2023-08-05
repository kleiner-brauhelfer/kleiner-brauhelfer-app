#include "syncservicewebdav.h"

#include <QDir>
#include <QFileInfo>
#include <QNetworkRequest>
#include <QNetworkAccessManager>
#include <QAuthenticator>
#include <QEventLoop>

SyncServiceWebDav::SyncServiceWebDav(QSettings *settings) :
    SyncService(settings)
{
    _netManager = new QNetworkAccessManager(this);
    connect(_netManager, &QNetworkAccessManager::authenticationRequired, this, &SyncServiceWebDav::authenticationRequired);
    setFilePath(cacheFilePath(QStringLiteral("kb_daten.sqlite")));
}

SyncServiceWebDav::~SyncServiceWebDav()
{
    delete _netManager;
}

void SyncServiceWebDav::authenticationRequired(QNetworkReply* reply, QAuthenticator* authenticator)
{
    Q_UNUSED(reply)
    if (!_AuthenticationGiven)
    {
        _AuthenticationGiven = true;
        authenticator->setUser(getUser());
        authenticator->setPassword(getPassword());
    }
}

bool SyncServiceWebDav::downloadFile()
{
    bool ret = false;

    QNetworkRequest req;
    QUrl reqUrl(getFilePathServer());
    req.setUrl(reqUrl);
    _AuthenticationGiven = false;

    QEventLoop loop;
    _netReply = _netManager->get(req);
    connect(_netReply, &QNetworkReply::sslErrors, this, &SyncServiceWebDav::sslErrors);
    connect(_netReply, &QNetworkReply::errorOccurred, this, &SyncServiceWebDav::error);
    connect(_netReply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    loop.exec();

    if (_netReply->error() == QNetworkReply::NoError)
    {
        QFile dstFile(getFilePath());
        QFileInfo finfo(dstFile);
        QDir dir(finfo.absolutePath());
        if (!dir.exists())
        {
            dir.mkpath(QStringLiteral("."));
        }
        if (dstFile.open(QIODevice::WriteOnly))
        {
            if (dstFile.write(_netReply->readAll()) != -1)
                ret = true;
            dstFile.close();
        }
    }

    return ret;
}

bool SyncServiceWebDav::uploadFile()
{
    bool ret = false;
    QFile srcFile(getFilePath());
    if (srcFile.open(QIODevice::ReadOnly))
    {
        QNetworkRequest req;
        QUrl reqUrl(getFilePathServer());
        req.setUrl(reqUrl);
        _AuthenticationGiven = false;

        QEventLoop loop;
        _netReply = _netManager->put(req, srcFile.readAll());
        connect(_netReply, &QNetworkReply::sslErrors, this, &SyncServiceWebDav::sslErrors);
        connect(_netReply, &QNetworkReply::errorOccurred, this, &SyncServiceWebDav::error);
        connect(_netReply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
        loop.exec();

        if (_netReply->error() == QNetworkReply::NoError)
            ret = true;

        srcFile.close();
    }
    return ret;
}

void SyncServiceWebDav::error(QNetworkReply::NetworkError error)
{
    Q_UNUSED(error)
    emit message(QtMsgType::QtCriticalMsg, _netReply->errorString());
}

void SyncServiceWebDav::sslErrors(const QList<QSslError> &errors)
{
    Q_UNUSED(errors)
    _netReply->ignoreSslErrors();
}

bool SyncServiceWebDav::synchronize(SyncDirection direction)
{
    if (getFilePathServer().isEmpty())
    {
        setState(SyncState::Failed);
        return false;
    }

    if (QFile::exists(getFilePath()))
    {
        if (direction == SyncDirection::Download)
        {
            if (downloadFile())
            {
                setState(SyncState::Updated);
                return true;
            }
            else
            {
                setState(SyncState::Failed);
                return false;
            }
        }
        else
        {
            if (uploadFile())
            {
                setState( SyncState::Updated);
                return true;
            }
            else
            {
                setState(SyncState::Failed);
                return false;
            }
        }
    }
    else
    {
        if (direction == SyncDirection::Download)
        {
            if (downloadFile())
            {
                setState(SyncState::Updated);
                return true;
            }
            else
            {
                setState(SyncState::Failed);
                return false;
            }
        }
        else
        {
            setState(SyncState::NotFound);
            return false;
        }
    }
}

QString SyncServiceWebDav::getFilePathServer() const
{
    return _settings->value("SyncService/webdav/DatabasePath").toString();
}

void SyncServiceWebDav::setFilePathServer(const QString &filePath)
{
    if (getFilePathServer() != filePath)
    {
        _settings->setValue("SyncService/webdav/DatabasePath", filePath);
        setFilePath(cacheFilePath(QStringLiteral("kb_daten.sqlite")));
        emit filePathServerChanged(filePath);
    }
}

QString SyncServiceWebDav::getUser() const
{
    return _settings->value("SyncService/webdav/user").toString();
}

void SyncServiceWebDav::setUser(const QString& user)
{
    if (getUser() != user)
    {
        _settings->setValue("SyncService/webdav/user", user);
        emit userChanged(user);
    }
}

QString SyncServiceWebDav::getPassword() const
{
    return _settings->value("SyncService/webdav/password").toString();
}

void SyncServiceWebDav::setPassword(const QString& password)
{
    if (getPassword() != password)
    {
        _settings->setValue("SyncService/webdav/password", password);
        emit passwordChanged(password);
    }
}
