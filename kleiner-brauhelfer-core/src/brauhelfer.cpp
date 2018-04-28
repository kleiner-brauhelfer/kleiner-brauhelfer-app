#include "brauhelfer.h"
#include "syncservicelocal.h"
#include "database.h"

const int Brauhelfer::versionMajor = VER_MAJ;
const int Brauhelfer::verionMinor = VER_MIN;
const int Brauhelfer::versionPatch = VER_PAT;

Brauhelfer::Brauhelfer(const QString &databasePath, QObject *parent) :
    Brauhelfer(new SyncServiceLocal(databasePath), parent)
{
}

Brauhelfer::Brauhelfer(SyncService *service, QObject *parent) :
    QObject(parent),
    _verbose(false)
{
    _db = new Database(this);
    _calc = new BierCalc();
    _sud = new SudObject(this);
    setSyncService(service);
}

Brauhelfer::~Brauhelfer()
{
    delete _db;
    delete _calc;
    delete _sud;
}

void Brauhelfer::setSyncService(SyncService *service)
{
    _fs = service;
    QObject::connect(_fs, SIGNAL(progress(qint64,qint64)), this, SLOT(progress(qint64,qint64)));
    QObject::connect(_fs, SIGNAL(errorOccurred(int,const QString&)), this, SLOT(errorOccurred(int,const QString&)));
}

void Brauhelfer::message(const QString &msg)
{
    if (_verbose)
        emit newMessage(msg);
}

void Brauhelfer::setVerbose(bool verbose)
{
    _verbose = verbose;
}

void Brauhelfer::errorOccurred(int code, const QString& msg)
{
    Q_UNUSED(code);
    message(msg);
}

void Brauhelfer::progress(qint64 current, qint64 total)
{
    message("Transfer: " + QString::number(current) + "/" + QString::number(total));
}

bool Brauhelfer::connect()
{
    bool doConnect = true;

    // show some information
    message("Synchronization service: " + (QString)(isServiceAvailable() ? "available" : "not available"));
    message("Database path: " + databasePath());
    message("Database readonly: " + (QString)(readonly() ? "true" : "false"));

    // disconnect if necessary
    if (connected())
    {
        disconnect();
    }

    // check if service available
    _fs->checkIfServiceAvailable();

    // synchronize database
    message("Synchronize database: download");
    _fs->synchronize(SyncService::Download);
    switch (_fs->getState())
    {
    case SyncService::UpToDate:
        message("Database up-to-date");
        break;
    case SyncService::Updated:
        message("Database updated");
        break;
    case SyncService::Offline:
        message("Offline, can't synchronize");
        break;
    case SyncService::NotFound:
        message("File not found");
        doConnect = false;
        break;
    case SyncService::OutOfSync:
        message("Out of synchronization");
        doConnect = false;
        break;
    case SyncService::Failed:
        message("Synchronization failed");
        doConnect = false;
        break;
    }

    // connect to database
    if (doConnect)
    {
        message("Connect to database");
        if (_db->connect(databasePath(), readonly()))
        {
            select();
        }
    }

    // show some more information
    message("Database connected: " + (QString)(connected() ? "true" : "false"));

    // emit signal
    emit connectionChanged(connected());

    return connected();
}

void Brauhelfer::disconnect()
{
    message("Disconnect from database");
    _sud->unload();
    _db->disconnect();
    emit connectionChanged(connected());
}

bool Brauhelfer::connected() const
{
    return _db->isConnected();
}

bool Brauhelfer::isServiceAvailable() const
{
    return _fs->isServiceAvailable();
}

SyncService::SyncState Brauhelfer::syncState() const
{
    return _fs->getState();
}

bool Brauhelfer::readonly() const
{
    return !isServiceAvailable();
}

bool Brauhelfer::isDirty() const
{
    return _db->isDirty();
}

void Brauhelfer::save()
{
    if (!readonly() && isDirty())
    {
        message("Save database changes");
        _sud->setGespeichert(QDateTime::currentDateTime());
        _db->save();
        message("Synchronize database: upload");
        _fs->synchronize(SyncService::Upload);
        switch (_fs->getState())
        {
        case SyncService::UpToDate:
            message("Database up-to-date");
            break;
        case SyncService::Updated:
            message("Database updated");
            break;
        case SyncService::Offline:
            message("Offline, can't synchronize");
            break;
        case SyncService::NotFound:
            message("File not found");
            break;
        case SyncService::OutOfSync:
            message("Out of synchronization");
            break;
        case SyncService::Failed:
            message("Synchronization failed");
            break;
        }

        // reselect main tables
        select();

        // reselect brew table
        _sud->select();
    }
}

void Brauhelfer::discard(bool skipSelect)
{
    message("Discard database changes");
    _db->discard();

    // reselect main tables
    select();

    // reselect brew table
    if (!skipSelect)
        _sud->select();
}

void Brauhelfer::select()
{
    message("Select main tables");
    modelSudAuswahl()->select();
    modelRastauswahl()->select();
    modelMalz()->select();
    modelHopfen()->select();
    modelHefe()->select();
    modelWeitereZutaten()->select();
    modelAusruestung()->select();
    modelGeraete()->select();
    modelWasser()->select();
}

void Brauhelfer::clearCache()
{
    // disconnect if necessary
    if (connected())
        disconnect();

    // clear cache
    message("Clear cache");
    _fs->clearCache();
}

QString Brauhelfer::databasePath() const
{
    return _fs->getFilePath();
}

Database* Brauhelfer::db() const
{
    return _db;
}

BierCalc* Brauhelfer::calc() const
{
    return _calc;
}

SudObject* Brauhelfer::sud() const
{
    return _sud;
}

SqlTableModel* Brauhelfer::modelSudAuswahl() const
{
    return _db->modelSudAuswahl;
}

SqlTableModel* Brauhelfer::modelRastauswahl() const
{
    return _db->modelRastauswahl;
}

SqlTableModel* Brauhelfer::modelMalz() const
{
    return _db->modelMalz;
}

SqlTableModel* Brauhelfer::modelHopfen() const
{
    return _db->modelHopfen;
}

SqlTableModel* Brauhelfer::modelHefe() const
{
    return _db->modelHefe;
}

SqlTableModel* Brauhelfer::modelWeitereZutaten() const
{
    return _db->modelWeitereZutaten;
}

SqlTableModel* Brauhelfer::modelAusruestung() const
{
    return _db->modelAusruestung;
}

SqlTableModel* Brauhelfer::modelGeraete() const
{
    return _db->modelGeraete;
}

SqlTableModel* Brauhelfer::modelWasser() const
{
    return _db->modelWasser;
}
