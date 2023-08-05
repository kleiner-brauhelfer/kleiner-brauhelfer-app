#include "syncservicegoogle.h"

#include <QOAuthHttpServerReplyHandler>
#include <QEventLoop>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDir>
#include <QFileInfo>
#include <QDesktopServices>

SyncServiceGoogle::SyncServiceGoogle(QSettings *settings) :
    SyncService(settings),
    _mightNeedToRefreshToken(false)
{
    setFilePath(cacheFilePath(fileId()));
    _oauth2 = new QOAuth2AuthorizationCodeFlow(this);
    _netManager = new QNetworkAccessManager(this);

    _oauth2->setAuthorizationUrl(QUrl(QStringLiteral("https://accounts.google.com/o/oauth2/v2/auth")));
    _oauth2->setAccessTokenUrl(QUrl(QStringLiteral("https://oauth2.googleapis.com/token")));
    _oauth2->setScope(QStringLiteral("https://www.googleapis.com/auth/drive"));
    _oauth2->setClientIdentifier(clientId());
    _oauth2->setClientIdentifierSharedKey(clientSecret());
    _oauth2->setRefreshToken(refreshToken());
    _oauth2->setToken(accessToken());
    _oauth2->setReplyHandler(new QOAuthHttpServerReplyHandler(5477, this));
    _oauth2->setModifyParametersFunction([](QAbstractOAuth::Stage stage, QMultiMap<QString, QVariant> *parameters)
    {
        QByteArray code = parameters->value(QStringLiteral("code")).toByteArray();
        parameters->replace(QStringLiteral("code"), QUrl::fromPercentEncoding(code));
        switch (stage) {
        case QAbstractOAuth::Stage::RequestingAuthorization:
            parameters->insert(QStringLiteral("access_type"), "offline");
            parameters->insert(QStringLiteral("prompt"), "consent");
            break;
        case QAbstractOAuth::Stage::RefreshingAccessToken:
            parameters->remove(QStringLiteral("redirect_uri"));
            break;
        default:
            break;
        }
    });
    connect(_oauth2, &QAbstractOAuth2::error, this, &SyncServiceGoogle::authError);
    connect(_oauth2, &QOAuth2AuthorizationCodeFlow::authorizeWithBrowser, &QDesktopServices::openUrl);
    connect(_oauth2, &QOAuth2AuthorizationCodeFlow::granted, this, [this]()
    {
        setRefreshToken(_oauth2->refreshToken());
        setAccessToken(_oauth2->token());
        if (!_mightNeedToRefreshToken)
            emit accessGranted();
    });
}

SyncServiceGoogle::~SyncServiceGoogle()
{
    delete _netManager;
}

void SyncServiceGoogle::grantAccess()
{
    if (_oauth2->refreshToken().isEmpty())
        _oauth2->grant();
    else
        _oauth2->refreshAccessToken();
}

void SyncServiceGoogle::refreshAccess()
{
    _oauth2->refreshAccessToken();
}

bool SyncServiceGoogle::retrieveFileId()
{
    bool ret = false;

    if (fileName().isEmpty())
        return false;

    QNetworkRequest req;
    QUrl url(QStringLiteral("https://www.googleapis.com/drive/v3/files?q=name='%1'&fields=files(id)").arg(fileName()));
    req.setUrl(url);
    req.setRawHeader("Authorization", QStringLiteral("Bearer %1").arg(accessToken()).toUtf8());

    QEventLoop loop;
    _netReply = _netManager->get(req);
    connect(_netReply, &QNetworkReply::sslErrors, this, &SyncServiceGoogle::sslErrors);
    connect(_netReply, &QNetworkReply::errorOccurred, this, &SyncServiceGoogle::networkError);
    connect(_netReply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    loop.exec();

    QNetworkReply::NetworkError code = _netReply->error();
    if (code == QNetworkReply::NoError)
    {
        QJsonParseError jsonError;
        QJsonDocument jsonDoc = QJsonDocument::fromJson(_netReply->readAll(), &jsonError);
        if(jsonError.error == QJsonParseError::NoError)
        {
            QJsonObject json = jsonDoc.object();
            QJsonArray files = json.value(QStringLiteral("files")).toArray();
            if (files.count() == 0)
            {
                setFileId(QStringLiteral(""));
                emit message(QtMsgType::QtWarningMsg, QStringLiteral("File not found."));
            }
            else if (files.count() == 1)
            {
                setFileId(files[0].toObject().value(QStringLiteral("id")).toString());
                ret = true;
            }
            else
            {
                setFileId(files[0].toObject().value(QStringLiteral("id")).toString());
                emit message(QtMsgType::QtWarningMsg, QStringLiteral("Multiple files not found. Verify ID manually."));
                ret = true;
            }
        }
        else
        {
            emit message(QtMsgType::QtCriticalMsg, jsonError.errorString());
        }
    }

    return ret;
}

bool SyncServiceGoogle::downloadFile()
{
    bool ret = false;

    QNetworkRequest req;
    QUrl url(QStringLiteral("https://www.googleapis.com/drive/v3/files/%1?alt=media").arg(fileId()));
    req.setUrl(url);
    req.setRawHeader("Authorization", QStringLiteral("Bearer %1").arg(accessToken()).toUtf8());

    QEventLoop loop;
    _netReply = _netManager->get(req);
    connect(_netReply, &QNetworkReply::sslErrors, this, &SyncServiceGoogle::sslErrors);
    connect(_netReply, &QNetworkReply::errorOccurred, this, &SyncServiceGoogle::networkError);
    connect(_netReply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    loop.exec();

    QNetworkReply::NetworkError code = _netReply->error();
    if (code == QNetworkReply::NoError)
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

bool SyncServiceGoogle::uploadFile()
{
    bool ret = false;

    QFile srcFile(getFilePath());
    if (srcFile.open(QIODevice::ReadOnly))
    {
        QNetworkRequest req;
        QUrl url(QStringLiteral("https://www.googleapis.com/upload/drive/v3/files/%1?uploadType=media").arg(fileId()));
        req.setUrl(url);
        req.setRawHeader("Authorization", QStringLiteral("Bearer %1").arg(accessToken()).toUtf8());
        req.setHeader(QNetworkRequest::ContentTypeHeader, "application/octet-stream");

        QEventLoop loop;
        _netReply =_netManager->sendCustomRequest(req, "PATCH", srcFile.readAll());
        connect(_netReply, &QNetworkReply::sslErrors, this, &SyncServiceGoogle::sslErrors);
        connect(_netReply, &QNetworkReply::errorOccurred, this, &SyncServiceGoogle::networkError);
        connect(_netReply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
        loop.exec();

        QNetworkReply::NetworkError code = _netReply->error();
        if (code == QNetworkReply::NoError)
        {
            ret = true;
        }

        srcFile.close();
    }

    return ret;
}

QString SyncServiceGoogle::getServerRevision(QNetworkReply::NetworkError* replyCode)
{
    QNetworkRequest req;
    QUrl url(QStringLiteral("https://www.googleapis.com/drive/v3/files/%1?fields=headRevisionId").arg(fileId()));
    req.setUrl(url);
    req.setRawHeader("Authorization", QStringLiteral("Bearer %1").arg(accessToken()).toUtf8());

    QEventLoop loop;
    _netReply = _netManager->get(req);
    connect(_netReply, &QNetworkReply::sslErrors, this, &SyncServiceGoogle::sslErrors);
    connect(_netReply, &QNetworkReply::errorOccurred, this, &SyncServiceGoogle::networkError);
    connect(_netReply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    loop.exec();

    QNetworkReply::NetworkError code = _netReply->error();
    if (replyCode)
        *replyCode = code;
    if (code == QNetworkReply::NoError)
    {
        QJsonParseError jsonError;
        QJsonDocument json = QJsonDocument::fromJson(_netReply->readAll(), &jsonError);
        if(jsonError.error == QJsonParseError::NoError)
        {
            QJsonObject jsonData = json.object();
            return jsonData.value(QStringLiteral("headRevisionId")).toString();
        }
        else
        {
            emit message(QtMsgType::QtCriticalMsg, jsonError.errorString());
        }
    }

    return QString();
}

void SyncServiceGoogle::networkError(QNetworkReply::NetworkError error)
{
    if (_mightNeedToRefreshToken && error == QNetworkReply::AuthenticationRequiredError)
        return;

    QString msg = _netReply->errorString();
    QJsonParseError jsonError;
    QJsonDocument json = QJsonDocument::fromJson(_netReply->readAll(), &jsonError);
    if(jsonError.error == QJsonParseError::NoError)
    {
        QJsonObject jsonData = json.object();
        QString error_summary = jsonData.value(QStringLiteral("error_summary")).toString();
        if (!error_summary.isEmpty())
            msg += "\n" + error_summary;
    }
    emit message(QtMsgType::QtCriticalMsg, msg);
}

void SyncServiceGoogle::authError(const QString &error, const QString &errorDescription, const QUrl &uri)
{
    Q_UNUSED(uri)
    emit message(QtMsgType::QtCriticalMsg, error + "\n" + errorDescription);
}

void SyncServiceGoogle::sslErrors(const QList<QSslError> &errors)
{
    if (errors.count() > 0)
        emit message(QtMsgType::QtWarningMsg, errors[0].errorString());
    else
        emit message(QtMsgType::QtWarningMsg, QStringLiteral("SSL error."));
    _netReply->ignoreSslErrors();
}

QString SyncServiceGoogle::getLocalRevision() const
{
    return _settings->value("SyncService/google/revisions/" + fileId(), "").toString();
}

void SyncServiceGoogle::setLocalRevision(const QString &revision)
{
    _settings->setValue("SyncService/google/revisions/" + fileId(), revision);
}

bool SyncServiceGoogle::synchronize(SyncDirection direction)
{
    if (fileId().isEmpty())
    {
        setState(SyncState::Failed);
        return false;
    }

    if (refreshToken().isEmpty() || accessToken().isEmpty()) {
        setState(SyncState::Failed);
        emit message(QtMsgType::QtCriticalMsg, QStringLiteral("Grant access first."));
        return false;
    }

    QNetworkReply::NetworkError replyCode;
    _mightNeedToRefreshToken = true;
    QString revision = getServerRevision(&replyCode);
    if (replyCode == QNetworkReply::AuthenticationRequiredError)
    {
        QEventLoop loop;
        _oauth2->refreshAccessToken();
        connect(_oauth2, &QAbstractOAuth::granted, &loop, &QEventLoop::quit);
        connect(_oauth2, &QAbstractOAuth2::error, &loop, &QEventLoop::quit);
        loop.exec();
        revision = getServerRevision();
    }
    _mightNeedToRefreshToken = false;
    if (revision.isEmpty())
    {
        setState(SyncState::Failed);
        return false;
    }

    if (QFile::exists(getFilePath()))
    {
        if (revision == getLocalRevision())
        {
            if (direction == SyncDirection::Download)
            {
                setState(SyncState::UpToDate);
                return true;
            }
            else
            {
                if (uploadFile())
                {
                    setLocalRevision(getServerRevision());
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
                    setLocalRevision(revision);
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
                setState(SyncState::OutOfSync);
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
                setLocalRevision(getServerRevision());
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

QString SyncServiceGoogle::clientId() const
{
    return _settings->value("SyncService/google/ClientId").toString();
}

void SyncServiceGoogle::setClientId(const QString &id)
{
    if (clientId() != id)
    {
        _settings->setValue("SyncService/google/ClientId", id);
        _oauth2->setClientIdentifier(id);
        clearCache();
        emit clientIdChanged(id);
    }
}

QString SyncServiceGoogle::clientSecret() const
{
    return _settings->value("SyncService/google/ClientSecret").toString();
}

void SyncServiceGoogle::setClientSecret(const QString &secret)
{
    if (clientSecret() != secret)
    {
        _settings->setValue("SyncService/google/ClientSecret", secret);
        _oauth2->setClientIdentifierSharedKey(secret);
        clearCache();
        emit clientSecretChanged(secret);
    }
}

QString SyncServiceGoogle::fileId() const
{
    return _settings->value("SyncService/google/fileId").toString();
}

void SyncServiceGoogle::setFileId(const QString &id)
{
    if (fileId() != id)
    {
        _settings->setValue("SyncService/google/fileId", id);
        setFilePath(cacheFilePath(id));
        emit fileIdChanged(id);
    }
}

QString SyncServiceGoogle::fileName() const
{
    return _settings->value("SyncService/google/fileName").toString();
}

void SyncServiceGoogle::setFileName(const QString &name)
{
    if (fileName() != name)
    {
        _settings->setValue("SyncService/google/fileName", name);
        emit fileNameChanged(name);
    }
}

QString SyncServiceGoogle::refreshToken() const
{
    return _settings->value("SyncService/google/RefreshToken").toString();
}

void SyncServiceGoogle::setRefreshToken(const QString &token)
{
    _settings->setValue("SyncService/google/RefreshToken", token);
}

QString SyncServiceGoogle::accessToken() const
{
    return _settings->value("SyncService/google/AccessToken").toString();
}

void SyncServiceGoogle::setAccessToken(const QString &token)
{
    _settings->setValue("SyncService/google/AccessToken", token);
}

void SyncServiceGoogle::clearCachedSettings()
{
    _settings->remove("SyncService/google/RefreshToken");
    _settings->remove("SyncService/google/AccessToken");
    _oauth2->setRefreshToken(QString());
    _oauth2->setToken(QString());
}
