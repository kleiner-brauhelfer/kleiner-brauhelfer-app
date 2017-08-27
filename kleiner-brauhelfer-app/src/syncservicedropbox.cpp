#include "syncservicedropbox.h"

#include <QDir>
#include <QFileInfo>
#include "qdropbox2.h"
#include "qdropbox2file.h"

SyncServiceDropbox::SyncServiceDropbox(QSettings *settings) :
    SyncService(settings, "http://api.dropboxapi.com")
{
    setFilePath(cacheFilePath(filePathServer()));
    _dbox = new QDropbox2(accessToken());
    connect(_dbox, SIGNAL(signal_errorOccurred(int,const QString&)), this, SIGNAL(errorOccurred(int,const QString&)));
}

SyncServiceDropbox::~SyncServiceDropbox()
{
    delete _dbox;
}

bool SyncServiceDropbox::downloadFile()
{
    bool ret = false;
    QDropbox2File srcFile(filePathServer(), _dbox);
    connect(&srcFile, SIGNAL(signal_downloadProgress(qint64,qint64)), this, SIGNAL(progress(qint64,qint64)));
    connect(&srcFile, SIGNAL(signal_errorOccurred(int,const QString&)), this, SIGNAL(errorOccurred(int,const QString&)));
    if (srcFile.open(QIODevice::ReadOnly))
    {
        if (_dbox->error() == QDropbox2::NoError && srcFile.error() == QDropbox2::NoError)
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
                if (dstFile.write(srcFile.readAll()) != -1)
                    ret = true;
                dstFile.close();
            }
        }
        srcFile.close();
    }
    return ret;
}

bool SyncServiceDropbox::uploadFile()
{
    bool ret = false;
    QFile srcFile(getFilePath());
    if (srcFile.open(QIODevice::ReadOnly))
    {
        QDropbox2File dstFile(filePathServer(), _dbox);
        connect(&dstFile, SIGNAL(signal_uploadProgress(qint64,qint64)), this, SIGNAL(progress(qint64,qint64)));
        connect(&dstFile, SIGNAL(signal_errorOccurred(int,const QString&)), this, SIGNAL(errorOccurred(int,const QString&)));
        if (dstFile.open(QIODevice::WriteOnly))
        {
            if (_dbox->error() == QDropbox2::NoError && dstFile.error() == QDropbox2::NoError)
            {
                if (dstFile.write(srcFile.readAll()) != -1)
                    ret = true;
            }
            dstFile.close();
        }
        srcFile.close();
    }
    return ret;
}

QString SyncServiceDropbox::getServerRevision()
{
    QDropbox2File file(filePathServer(), _dbox);
    QDropbox2EntityInfo info(file.metadata());
    if (_dbox->error() == QDropbox2::NoError && file.error() == QDropbox2::NoError)
        return info.revisionHash();
    return "";
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
        _state = SyncState::Failed;
        return false;
    }

    if (isServiceAvailable())
    {
        if (QFile::exists(getFilePath()))
        {
            QString revision = getServerRevision();
            if (revision == getLocalRevision())
            {
                if (direction == SyncDirection::Download)
                {
                    _state = SyncState::UpToDate;
                    return true;
                }
                else
                {
                    if (uploadFile())
                    {
                        setLocalRevision(getServerRevision());
                        _state = SyncState::Updated;
                        return true;
                    }
                    else
                    {
                        _state = SyncState::Failed;
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
                        _state = SyncState::Updated;
                        return true;
                    }
                    else
                    {
                        _state = SyncState::Failed;
                        return false;
                    }
                }
                else
                {
                    _state = SyncState::OutOfSync;
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
                    _state = SyncState::Updated;
                    return true;
                }
                else
                {
                    _state = SyncState::Failed;
                    return false;
                }
            }
            else
            {
                _state = SyncState::NotFound;
                return false;
            }
        }
    }
    else
    {
        if (QFile::exists(getFilePath()))
        {
            _state = SyncState::Offline;
            if (direction == SyncDirection::Download)
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        else
        {
            _state = SyncState::NotFound;
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
        _dbox->setAccessToken(token);
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
