#include "syncservicedropbox.h"

#include <QOAuthHttpServerReplyHandler>
#include <QEventLoop>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDir>
#include <QFileInfo>
#include <QDesktopServices>

SyncServiceDropbox::SyncServiceDropbox(QSettings *settings) :
    SyncService(settings),
    _mightNeedToRefreshToken(false)
{
    setFilePath(cacheFilePath(filePathServer()));
    _oauth2 = new QOAuth2AuthorizationCodeFlow(this);
    _netManager = new QNetworkAccessManager(this);

    _oauth2->setAuthorizationUrl(QUrl(QStringLiteral("https://www.dropbox.com/oauth2/authorize")));
    _oauth2->setAccessTokenUrl(QUrl(QStringLiteral("https://api.dropboxapi.com/oauth2/token")));
    _oauth2->setClientIdentifier(appKey());
    _oauth2->setClientIdentifierSharedKey(appSecret());
    _oauth2->setRefreshToken(refreshToken());
    _oauth2->setToken(accessToken());
    _oauth2->setReplyHandler(new QOAuthHttpServerReplyHandler(5476, this));
    _oauth2->setModifyParametersFunction([](QAbstractOAuth::Stage stage, QMultiMap<QString, QVariant>* parameters)
    {
        switch (stage)
        {
        case QAbstractOAuth::Stage::RequestingAuthorization:
            parameters->insert(QStringLiteral("token_access_type"), "offline");
            break;
        case QAbstractOAuth::Stage::RefreshingAccessToken:
            parameters->remove(QStringLiteral("redirect_uri"));
            break;
        default:
            break;
        }
    });
    connect(_oauth2, &QAbstractOAuth2::error, this, &SyncServiceDropbox::authError);
    connect(_oauth2, &QOAuth2AuthorizationCodeFlow::authorizeWithBrowser, &QDesktopServices::openUrl);
    connect(_oauth2, &QOAuth2AuthorizationCodeFlow::granted, this, [this]()
    {
        setRefreshToken(_oauth2->refreshToken());
        setAccessToken(_oauth2->token());
        if (!_mightNeedToRefreshToken)
            emit accessGranted();
    });
}

SyncServiceDropbox::~SyncServiceDropbox()
{
    delete _netManager;
}

void SyncServiceDropbox::grantAccess()
{
    if (_oauth2->refreshToken().isEmpty())
        _oauth2->grant();
    else
        _oauth2->refreshAccessToken();
}

void SyncServiceDropbox::refreshAccess()
{
    _oauth2->refreshAccessToken();
}

bool SyncServiceDropbox::downloadFile()
{
    bool ret = false;

    QNetworkRequest req;
    QUrl url(QStringLiteral("https://content.dropboxapi.com/2/files/download"));
    req.setUrl(url);
    req.setRawHeader("Authorization", QStringLiteral("Bearer %1").arg(accessToken()).toUtf8());
    QString json = QStringLiteral("{\"path\": \"%1\"}").arg((filePathServer().compare(QStringLiteral("/")) == 0) ? QStringLiteral("") : filePathServer());
    req.setRawHeader("Dropbox-API-arg", json.toUtf8());

    QEventLoop loop;
    _netReply = _netManager->get(req);
    connect(_netReply, &QNetworkReply::sslErrors, this, &SyncServiceDropbox::sslErrors);
    connect(_netReply, &QNetworkReply::errorOccurred, this, &SyncServiceDropbox::networkError);
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

bool SyncServiceDropbox::uploadFile()
{
    bool ret = false;

    QFile srcFile(getFilePath());
    if (srcFile.open(QIODevice::ReadOnly))
    {
        QNetworkRequest req;
        QUrl url(QStringLiteral("https://content.dropboxapi.com/2/files/upload"));
        req.setUrl(url);
        req.setRawHeader("Authorization", QStringLiteral("Bearer %1").arg(accessToken()).toUtf8());
        req.setHeader(QNetworkRequest::ContentTypeHeader, "application/octet-stream");
        QString json = QStringLiteral("{\"path\": \"%1\",\"mode\": \"overwrite\",\"autorename\": true,\"mute\": true}")
                           .arg((filePathServer().compare(QStringLiteral("/")) == 0) ? QStringLiteral("") : filePathServer());
        req.setRawHeader("Dropbox-API-arg", json.toUtf8());

        QEventLoop loop;
        _netReply = _netManager->post(req, srcFile.readAll());
        connect(_netReply, &QNetworkReply::sslErrors, this, &SyncServiceDropbox::sslErrors);
        connect(_netReply, &QNetworkReply::errorOccurred, this, &SyncServiceDropbox::networkError);
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

QString SyncServiceDropbox::getServerRevision(QNetworkReply::NetworkError* replyCode)
{
    QNetworkRequest req;
    QUrl url(QStringLiteral("https://api.dropboxapi.com/2/files/get_metadata"));
    req.setUrl(url);
    req.setRawHeader("Authorization", QStringLiteral("Bearer %1").arg(accessToken()).toUtf8());
    req.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QString json = QStringLiteral("{\"path\": \"%1\"}").arg((filePathServer().compare(QStringLiteral("/")) == 0) ? QStringLiteral("") : filePathServer());

    QEventLoop loop;
    _netReply = _netManager->post(req, json.toUtf8());
    connect(_netReply, &QNetworkReply::sslErrors, this, &SyncServiceDropbox::sslErrors);
    connect(_netReply, &QNetworkReply::errorOccurred, this, &SyncServiceDropbox::networkError);
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
            return jsonData.value(QStringLiteral("rev")).toString();
        }
        else
        {
            emit message(QtMsgType::QtCriticalMsg, jsonError.errorString());
        }
    }

    return QString();
}

void SyncServiceDropbox::networkError(QNetworkReply::NetworkError error)
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

void SyncServiceDropbox::authError(const QString &error, const QString &errorDescription, const QUrl &uri)
{
    Q_UNUSED(uri)
    emit message(QtMsgType::QtCriticalMsg, error + "\n" + errorDescription);
}

void SyncServiceDropbox::sslErrors(const QList<QSslError> &errors)
{
    if (errors.count() > 0)
        emit message(QtMsgType::QtWarningMsg, errors[0].errorString());
    else
        emit message(QtMsgType::QtWarningMsg, QStringLiteral("SSL error."));
    _netReply->ignoreSslErrors();
}

QString SyncServiceDropbox::getLocalRevision() const
{
    return _settings->value("SyncService/dropbox/revisions/" + filePathServer(), "").toString();
}

void SyncServiceDropbox::setLocalRevision(const QString &revision)
{
    _settings->setValue("SyncService/dropbox/revisions/" + filePathServer(), revision);
}

bool SyncServiceDropbox::synchronize(SyncDirection direction)
{
    if (filePathServer().isEmpty())
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

QString SyncServiceDropbox::appKey() const
{
    return _settings->value("SyncService/dropbox/AppKey").toString();
}

void SyncServiceDropbox::setAppKey(const QString &key)
{
    if (appKey() != key)
    {
        _settings->setValue("SyncService/dropbox/AppKey", key);
        _oauth2->setClientIdentifier(key);
        clearCache();
        emit appKeyChanged(key);
    }
}

QString SyncServiceDropbox::appSecret() const
{
    return _settings->value("SyncService/dropbox/AppSecret").toString();
}

void SyncServiceDropbox::setAppSecret(const QString &secret)
{
    if (appSecret() != secret)
    {
        _settings->setValue("SyncService/dropbox/AppSecret", secret);
        _oauth2->setClientIdentifierSharedKey(secret);
        clearCache();
        emit appSecretChanged(secret);
    }
}

QString SyncServiceDropbox::refreshToken() const
{
    return _settings->value("SyncService/dropbox/RefreshToken").toString();
}

void SyncServiceDropbox::setRefreshToken(const QString &token)
{
    _settings->setValue("SyncService/dropbox/RefreshToken", token);
}

QString SyncServiceDropbox::accessToken() const
{
    return _settings->value("SyncService/dropbox/AccessToken").toString();
}

void SyncServiceDropbox::setAccessToken(const QString &token)
{
    _settings->setValue("SyncService/dropbox/AccessToken", token);
}

QString SyncServiceDropbox::filePathServer() const
{
    return _settings->value("SyncService/dropbox/DatabasePathOnServer").toString();
}

void SyncServiceDropbox::setFilePathServer(const QString &filePath)
{
    if (filePathServer() != filePath)
    {
        _settings->setValue("SyncService/dropbox/DatabasePathOnServer", filePath);
        setFilePath(cacheFilePath(filePath));
        emit filePathServerChanged(filePath);
    }
}

void SyncServiceDropbox::clearCachedSettings()
{
    _settings->remove("SyncService/dropbox/RefreshToken");
    _settings->remove("SyncService/dropbox/AccessToken");
    _oauth2->setRefreshToken(QString());
    _oauth2->setToken(QString());
}
