#include "syncservicedropbox.h"

#include <QOAuthHttpServerReplyHandler>
#include <QEventLoop>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDir>
#include <QFileInfo>
#include <QDesktopServices>

static const char* DROPBOX_AUTH_URL    = "https://www.dropbox.com/oauth2/authorize";
static const char* DROPBOX_TOKEN_URL   = "https://api.dropboxapi.com/oauth2/token";
static const char* DROPBOX_API_URL     = "https://api.dropboxapi.com";
static const char* DROPBOX_CONTENT_URL = "https://content.dropboxapi.com";

SyncServiceDropbox::SyncServiceDropbox(QSettings *settings) :
    SyncService(settings, DROPBOX_API_URL),
    _fileContent(new QStringListModel(this))
{
    setFilePath(cacheFilePath(filePathServer()));
    _oauth2 = new QOAuth2AuthorizationCodeFlow(this);
    _netManager = new QNetworkAccessManager(this);

    _oauth2->setAuthorizationUrl(QUrl(DROPBOX_AUTH_URL));
    _oauth2->setAccessTokenUrl(QUrl(DROPBOX_TOKEN_URL));
    _oauth2->setClientIdentifier(appKey());
    _oauth2->setClientIdentifierSharedKey(appSecret());
    _oauth2->setRefreshToken(refreshToken());
    _oauth2->setToken(accessToken());
    _oauth2->setReplyHandler(new QOAuthHttpServerReplyHandler(5476, this));
    _oauth2->setModifyParametersFunction([](QAbstractOAuth::Stage stage, QVariantMap* parameters)
    {
        switch (stage)
        {
        case QAbstractOAuth::Stage::RequestingAuthorization:
            parameters->insert("token_access_type", "offline");
            break;
        case QAbstractOAuth::Stage::RefreshingAccessToken:
            parameters->remove("redirect_uri");
            break;
        default:
            break;
        }
    });
    connect(_oauth2, &QOAuth2AuthorizationCodeFlow::authorizeWithBrowser, &QDesktopServices::openUrl);
    connect(_oauth2, &QOAuth2AuthorizationCodeFlow::granted, this, [this]() {
        setRefreshToken(_oauth2->refreshToken());
        setAccessToken(_oauth2->token());
        emit message(QtMsgType::QtInfoMsg, "Access granted.");
    });
}

SyncServiceDropbox::~SyncServiceDropbox()
{
    delete _netManager;
}

bool SyncServiceDropbox::grantAccess()
{
    if (_oauth2->refreshToken().isEmpty())
    {
        _oauth2->grant();
        return false;
    }
    else
    {
        _oauth2->refreshAccessToken();
    }
    return true;
}

void SyncServiceDropbox::refreshAccess()
{
    _oauth2->refreshAccessToken();
}

bool SyncServiceDropbox::downloadFile()
{
    bool ret = false;
    bool retry = true;
    while (true)
    {
        QUrl url;
        url.setUrl(DROPBOX_CONTENT_URL);
        url.setPath(QString("/2/files/download"));

        QNetworkRequest req;
        req.setUrl(url);
        req.setRawHeader("Authorization", QString("Bearer %1").arg(accessToken()).toUtf8());
        QString json = QString("{ \"path\": \"%1\" }")
                .arg((filePathServer().compare("/") == 0) ? "" : filePathServer());
        req.setRawHeader("Dropbox-API-arg", json.toUtf8());

        QEventLoop loop;
        _netReply = _netManager->get(req);
        connect(_netReply, SIGNAL(sslErrors(QList<QSslError>)), this, SLOT(sslErrors(QList<QSslError>)));
        connect(_netReply, SIGNAL(errorOccurred(QNetworkReply::NetworkError)), this, SLOT(error(QNetworkReply::NetworkError)));
        connect(_netReply, SIGNAL(finished()), &loop, SLOT(quit()));
        loop.exec();

        QNetworkReply::NetworkError code = _netReply->error();
        if (code == QNetworkReply::NoError)
        {
            QFile dstFile(getFilePath());
            QFileInfo finfo(dstFile);
            QDir dir(finfo.absolutePath());
            if (!dir.exists())
            {
                dir.mkpath(".");
            }
            if (dstFile.open(QIODevice::WriteOnly))
            {
                if (dstFile.write(_netReply->readAll()) != -1)
                    ret = true;
                dstFile.close();
            }
        }
        else if (code == QNetworkReply::AuthenticationRequiredError)
        {
            if (retry)
            {
                retry = false;
                _oauth2->refreshAccessToken();
                continue;
            }
        }
        break;
    }
    return ret;
}

bool SyncServiceDropbox::uploadFile()
{
    bool ret = false;
    bool retry = true;
    while (true)
    {
        QFile srcFile(getFilePath());
        if (srcFile.open(QIODevice::ReadOnly))
        {
            QUrl url;
            url.setUrl(DROPBOX_CONTENT_URL);
            url.setPath(QString("/2/files/upload"));

            QNetworkRequest req;
            req.setUrl(url);
            req.setRawHeader("Authorization", QString("Bearer %1").arg(accessToken()).toUtf8());
            req.setHeader(QNetworkRequest::ContentTypeHeader, "application/octet-stream");
            QString json = QString("{ \"path\": \"%1\", \"mode\": \"overwrite\", \"autorename\": true, \"mute\": true }")
                    .arg((filePathServer().compare("/") == 0) ? "" : filePathServer());
            req.setRawHeader("Dropbox-API-arg", json.toUtf8());

            QEventLoop loop;
            _netReply = _netManager->post(req, srcFile.readAll());
            connect(_netReply, SIGNAL(sslErrors(QList<QSslError>)), this, SLOT(sslErrors(QList<QSslError>)));
            connect(_netReply, SIGNAL(errorOccurred(QNetworkReply::NetworkError)), this, SLOT(error(QNetworkReply::NetworkError)));
            connect(_netReply, SIGNAL(finished()), &loop, SLOT(quit()));
            loop.exec();

            QNetworkReply::NetworkError code = _netReply->error();
            if (code == QNetworkReply::NoError)
            {
                ret = true;
            }
            else if (code == QNetworkReply::AuthenticationRequiredError)
            {
                if (retry)
                {
                    retry = false;
                    _oauth2->refreshAccessToken();
                    continue;
                }
            }

            srcFile.close();
        }
        break;
    }
    return ret;
}

QString SyncServiceDropbox::getServerRevision()
{
    bool retry = true;
    while (true)
    {
        QUrl url;
        url.setUrl(DROPBOX_API_URL);
        url.setPath(QString("/2/files/get_metadata"));

        QNetworkRequest req;
        req.setUrl(url);
        req.setRawHeader("Authorization", QString("Bearer %1").arg(accessToken()).toUtf8());
        req.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

        QString json = QString("{\"path\": \"%1\"}").arg((filePathServer().compare("/") == 0) ? "" : filePathServer());

        QEventLoop loop;
        _netReply = _netManager->post(req, json.toUtf8());
        connect(_netReply, SIGNAL(sslErrors(QList<QSslError>)), this, SLOT(sslErrors(QList<QSslError>)));
        connect(_netReply, SIGNAL(errorOccurred(QNetworkReply::NetworkError)), this, SLOT(error(QNetworkReply::NetworkError)));
        connect(_netReply, SIGNAL(finished()), &loop, SLOT(quit()));
        loop.exec();

        QNetworkReply::NetworkError code = _netReply->error();
        if (code == QNetworkReply::NoError)
        {
            QJsonParseError jsonError;
            QJsonDocument json = QJsonDocument::fromJson(_netReply->readAll(), &jsonError);
            if(jsonError.error == QJsonParseError::NoError)
            {
                QJsonObject jsonData = json.object();
                return jsonData.value("rev").toString();
            }
            else
            {
                emit message(QtMsgType::QtCriticalMsg, jsonError.errorString());
            }
        }
        else if (code == QNetworkReply::AuthenticationRequiredError)
        {
            if (retry)
            {
                retry = false;
                _oauth2->refreshAccessToken();
                continue;
            }
        }
        break;
    }
    return "";
}

QStringListModel* SyncServiceDropbox::folderContent()
{
    QStringList list;
    bool retry = true;
    bool retry2 = true;
    while (true)
    {
        QString cursor = "";
        do
        {
            QUrl url;
            url.setUrl(DROPBOX_API_URL);

            QString json;
            if (cursor.isEmpty())
            {
                url.setPath(QString("/2/files/list_folder"));
                json = QString("{\"path\": \"\", \"recursive\": true}");
            }
            else
            {
                url.setPath(QString("/2/files/list_folder/continue"));
                json = QString("{\"cursor\": \"%1\"}").arg(cursor);
            }

            QNetworkRequest req;
            req.setUrl(url);
            req.setRawHeader("Authorization", QString("Bearer %1").arg(accessToken()).toUtf8());
            req.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

            QEventLoop loop;
            _netReply = _netManager->post(req, json.toUtf8());
            connect(_netReply, SIGNAL(sslErrors(QList<QSslError>)), this, SLOT(sslErrors(QList<QSslError>)));
            connect(_netReply, SIGNAL(errorOccurred(QNetworkReply::NetworkError)), this, SLOT(error(QNetworkReply::NetworkError)));
            connect(_netReply, SIGNAL(finished()), &loop, SLOT(quit()));
            loop.exec();

            QNetworkReply::NetworkError code = _netReply->error();
            if (code == QNetworkReply::NoError)
            {
                QJsonParseError jsonError;
                QJsonDocument json = QJsonDocument::fromJson(_netReply->readAll(), &jsonError);
                if(jsonError.error == QJsonParseError::NoError)
                {
                    QJsonObject obj = json.object();
                    const QJsonArray entries = obj.value("entries").toArray();
                    for (const QJsonValue& entry : entries)
                    {
                        QJsonObject jsonData = entry.toObject();
                        if (jsonData.value(".tag").toString() ==  "file")
                        {
                            QString path = jsonData.value("path_display").toString();
                            QString ext = QFileInfo(path).suffix();
                            if (ext.contains("sqlite") || ext.contains("db") || ext.contains("sl"))
                                list.append(path);
                        }
                    }
                    if (list.count() > 100)
                        break;
                    if (!obj.value("has_more").toBool())
                        break;
                    cursor = obj.value("cursor").toString();
                }
                else
                {
                    emit message(QtMsgType::QtCriticalMsg, jsonError.errorString());
                    break;
                }
            }
            else if (code == QNetworkReply::AuthenticationRequiredError)
            {
                if (retry)
                {
                    retry = false;
                    _oauth2->refreshAccessToken();
                    break;
                }
                else
                {
                    retry2 = false;
                    break;
                }
            }
            else
            {
                break;
            }
        } while (true);
        if (!retry && retry2)
            continue;
        break;
    }
    _fileContent->setStringList(list);
    return _fileContent;
}

void SyncServiceDropbox::error(QNetworkReply::NetworkError error)
{
    Q_UNUSED(error)
    QString msg = _netReply->errorString();
    QJsonParseError jsonError;
    QJsonDocument json = QJsonDocument::fromJson(_netReply->readAll(), &jsonError);
    if(jsonError.error == QJsonParseError::NoError)
    {
        QJsonObject jsonData = json.object();
        QString error_summary = jsonData.value("error_summary").toString();
        if (!error_summary.isEmpty())
            msg += "\n" + error_summary;
    }
    emit message(QtMsgType::QtCriticalMsg, msg);
}

void SyncServiceDropbox::sslErrors(const QList<QSslError> &errors)
{
    Q_UNUSED(errors)
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
    if (filePathServer() == "")
    {
        setState(SyncState::Failed);
        return false;
    }

    if (QFile::exists(getFilePath()))
    {
        QString revision = getServerRevision();
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
        emit appSecretChanged(secret);
    }
}

QString SyncServiceDropbox::refreshToken() const
{
    return _settings->value("SyncService/dropbox/RefreshToken").toString();
}

void SyncServiceDropbox::setRefreshToken(const QString &token)
{
    if (refreshToken() != token)
    {
        _settings->setValue("SyncService/dropbox/RefreshToken", token);
        emit refreshTokenChanged(token);
    }
}

QString SyncServiceDropbox::accessToken() const
{
    return _settings->value("SyncService/dropbox/AccessToken").toString();
}

void SyncServiceDropbox::setAccessToken(const QString &token)
{
    if (accessToken() != token)
    {
        _settings->setValue("SyncService/dropbox/AccessToken", token);
        emit accessTokenChanged(token);
    }
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
    _oauth2->setRefreshToken("");
    _oauth2->setToken("");
    emit refreshTokenChanged("");
    emit accessTokenChanged("");
}
