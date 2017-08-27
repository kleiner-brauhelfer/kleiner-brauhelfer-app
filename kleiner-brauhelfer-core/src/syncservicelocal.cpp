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
            _state = SyncState::UpToDate;
            return true;

        case SyncDirection::Upload:
            _state = SyncState::Updated;
            return true;

        default:
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
