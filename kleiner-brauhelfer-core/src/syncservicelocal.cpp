#include "syncservicelocal.h"
#include <QFile>

SyncServiceLocal::SyncServiceLocal(QSettings *settings) :
    SyncService(settings)
{
    setFilePath(_settings->value("SyncService/local/DatabasePath").toString());
}

SyncServiceLocal::SyncServiceLocal(const QString &filePath) :
    SyncService(NULL)
{
    setFilePath(filePath);
}

bool SyncServiceLocal::synchronize(SyncDirection direction)
{
    if (QFile::exists(getFilePath()))
    {
        switch (direction)
        {
        case SyncDirection::Download:
            setState(SyncState::UpToDate);
            return true;

        case SyncDirection::Upload:
            setState(SyncState::Updated);
            return true;

        default:
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

QString SyncServiceLocal::filePathLocal() const
{
    return getFilePath();
}

void SyncServiceLocal::setFilePathLocal(const QString &filePath)
{
    if (filePathLocal() != filePath)
    {
        setFilePath(filePath);
        if (_settings)
            _settings->setValue("SyncService/local/DatabasePath", filePath);
        emit filePathLocalChanged(filePath);
    }
}
