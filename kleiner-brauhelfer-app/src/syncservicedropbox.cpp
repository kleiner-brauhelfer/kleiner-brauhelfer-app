#include "syncservicedropbox.h"

#include <QEventLoop>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDir>
#include <QFileInfo>

static const char* QDROPBOX2_API_URL     = "https://api.dropboxapi.com";
static const char* QDROPBOX2_CONTENT_URL = "https://content.dropboxapi.com";

SyncServiceDropbox::SyncServiceDropbox(QSettings *settings) :
    SyncService(settings, "http://api.dropboxapi.com"),
    _fileContent(new QStringListModel(this))
{
    setFilePath(cacheFilePath(filePathServer()));
    _netManager = new QNetworkAccessManager(this);
}

SyncServiceDropbox::~SyncServiceDropbox()
{
    delete _netManager;
}

bool SyncServiceDropbox::downloadFile()
{
    bool ret = false;

    QUrl url;
    url.setUrl(QDROPBOX2_CONTENT_URL);
    url.setPath(QString("/2/files/download"));

    QNetworkRequest req;
    req.setUrl(url);
    req.setRawHeader("Authorization", QString("Bearer %1").arg(accessToken()).toUtf8());
    QString json = QString("{ \"path\": \"%1\" }")
            .arg((filePathServer().compare("/") == 0) ? "" : filePathServer());
    req.setRawHeader("Dropbox-API-arg", json.toUtf8());

    QEventLoop loop;
    _netReply = _netManager->get(req);
    connect(_netReply, SIGNAL(sslErrors(const QList<QSslError>&)), this, SLOT(sslErrors(const QList<QSslError>&)));
    connect(_netReply, SIGNAL(errorOccurred(QNetworkReply::NetworkError)), this, SLOT(error(QNetworkReply::NetworkError)));
    connect(_netReply, SIGNAL(finished()), &loop, SLOT(quit()));
    loop.exec();

    if (_netReply->error() == QNetworkReply::NoError)
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

    return ret;
}

bool SyncServiceDropbox::uploadFile()
{
    bool ret = false;
    QFile srcFile(getFilePath());
    if (srcFile.open(QIODevice::ReadOnly))
    {
        QUrl url;
        url.setUrl(QDROPBOX2_CONTENT_URL);
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
        connect(_netReply, SIGNAL(sslErrors(const QList<QSslError>&)), this, SLOT(sslErrors(const QList<QSslError>&)));
        connect(_netReply, SIGNAL(errorOccurred(QNetworkReply::NetworkError)), this, SLOT(error(QNetworkReply::NetworkError)));
        connect(_netReply, SIGNAL(finished()), &loop, SLOT(quit()));
        loop.exec();

        if (_netReply->error() == QNetworkReply::NoError)
            ret = true;

        srcFile.close();
    }

    return ret;
}

QString SyncServiceDropbox::getServerRevision()
{
    QUrl url;
    url.setUrl(QDROPBOX2_API_URL);
    url.setPath(QString("/2/files/get_metadata"));

    QNetworkRequest req;
    req.setUrl(url);
    req.setRawHeader("Authorization", QString("Bearer %1").arg(accessToken()).toUtf8());
    req.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QString json = QString("{\"path\": \"%1\"}").arg((filePathServer().compare("/") == 0) ? "" : filePathServer());

    QEventLoop loop;
    _netReply = _netManager->post(req, json.toUtf8());
    connect(_netReply, SIGNAL(sslErrors(const QList<QSslError>&)), this, SLOT(sslErrors(const QList<QSslError>&)));
    connect(_netReply, SIGNAL(errorOccurred(QNetworkReply::NetworkError)), this, SLOT(error(QNetworkReply::NetworkError)));
    connect(_netReply, SIGNAL(finished()), &loop, SLOT(quit()));
    loop.exec();

    if (_netReply->error() == QNetworkReply::NoError)
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
            emit errorOccurred((int)QNetworkReply::UnknownContentError, jsonError.errorString());
        }
    }
    return "";
}

QStringListModel* SyncServiceDropbox::folderContent()
{
    QStringList list;
    QString cursor = "";
    do
    {
        QString json;

        QUrl url;
        url.setUrl(QDROPBOX2_API_URL);
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
        connect(_netReply, SIGNAL(sslErrors(const QList<QSslError>&)), this, SLOT(sslErrors(const QList<QSslError>&)));
        connect(_netReply, SIGNAL(errorOccurred(QNetworkReply::NetworkError)), this, SLOT(error(QNetworkReply::NetworkError)));
        connect(_netReply, SIGNAL(finished()), &loop, SLOT(quit()));
        loop.exec();

        if (_netReply->error() == QNetworkReply::NoError)
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
                emit errorOccurred((int)QNetworkReply::UnknownContentError, jsonError.errorString());
                break;
            }
        }
        else
        {
            break;
        }
    } while (true);
qDebug() << list.count();
    _fileContent->setStringList(list);
    return _fileContent;
}

void SyncServiceDropbox::error(QNetworkReply::NetworkError error)
{
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
    emit errorOccurred((int)error, msg);
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
