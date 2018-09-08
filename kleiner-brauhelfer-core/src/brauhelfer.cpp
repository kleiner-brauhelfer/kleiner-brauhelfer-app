#include "brauhelfer.h"
#include "syncservicelocal.h"
#include "database.h"
#include <QSqlQuery>

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

    QObject::connect(_db->modelSudAuswahl, SIGNAL(modified()), this, SIGNAL(modified()));
    QObject::connect(_db->modelRastauswahl, SIGNAL(modified()), this, SIGNAL(modified()));
    QObject::connect(_db->modelMalz, SIGNAL(modified()), this, SIGNAL(modified()));
    QObject::connect(_db->modelHopfen, SIGNAL(modified()), this, SIGNAL(modified()));
    QObject::connect(_db->modelHefe, SIGNAL(modified()), this, SIGNAL(modified()));
    QObject::connect(_db->modelWeitereZutaten, SIGNAL(modified()), this, SIGNAL(modified()));
    QObject::connect(_db->modelAusruestung, SIGNAL(modified()), this, SIGNAL(modified()));
    QObject::connect(_db->modelGeraete, SIGNAL(modified()), this, SIGNAL(modified()));
    QObject::connect(_db->modelWasser, SIGNAL(modified()), this, SIGNAL(modified()));

    QObject::connect(_sud, SIGNAL(modified()), this, SIGNAL(modified()));
    QObject::connect(_db->modelSud, SIGNAL(modified()), _sud, SIGNAL(modified()));
    QObject::connect(_db->modelRasten, SIGNAL(modified()), _sud, SIGNAL(modified()));
    QObject::connect(_db->modelMalzschuettung, SIGNAL(modified()), _sud, SIGNAL(modified()));
    QObject::connect(_db->modelHopfengaben, SIGNAL(modified()), _sud, SIGNAL(modified()));
    QObject::connect(_db->modelWeitereZutatenGaben, SIGNAL(modified()), _sud, SIGNAL(modified()));
    QObject::connect(_db->modelSchnellgaerverlauf, SIGNAL(modified()), _sud, SIGNAL(modified()));
    QObject::connect(_db->modelHauptgaerverlauf, SIGNAL(modified()), _sud, SIGNAL(modified()));
    QObject::connect(_db->modelNachgaerverlauf, SIGNAL(modified()), _sud, SIGNAL(modified()));
    QObject::connect(_db->modelBewertungen, SIGNAL(modified()), _sud, SIGNAL(modified()));
    QObject::connect(_db->modelAnhang, SIGNAL(modified()), _sud, SIGNAL(modified()));

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
    message("Error " + QString::number(code) + ": " + msg);
}

void Brauhelfer::progress(qint64 current, qint64 total)
{
    message("Transfer: " + QString::number(current) + "/" + QString::number(total));
}

bool Brauhelfer::connect()
{
    bool doConnect = true;

    // disconnect if necessary
    if (connected())
    {
        disconnect();
    }

    // check if service available
    _fs->checkIfServiceAvailable();

    // show some information
    message("Synchronization service: " + (QString)(isServiceAvailable() ? "available" : "not available"));
    message("Database path: " + databasePath());
    message("Database readonly: " + (QString)(readonly() ? "true" : "false"));

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

bool Brauhelfer::allowedToDeleteIngredient(IngredientType type, const QString& ingredient)
{
    if (ingredient.isEmpty())
        return  false;

    QSqlQuery querySud("SELECT * FROM Sud WHERE BierWurdeGebraut == 0");
    if (querySud.exec())
    {
        QSqlQuery query;
        QString ing = ingredient;
        ing.replace("'", "''");
        while (querySud.next())
        {
            QString sudid = querySud.value("Id").toString();
            if (type == IngredientType::IngredientTypeMalt)
            {
                if (query.exec("SELECT * FROM Malzschuettung WHERE Name='" + ing + "' AND SudID=" + sudid))
                {
                    if (query.size() > 0)
                        return false;
                }
            }
            else if (type == IngredientType::IngredientTypeHops)
            {
                QString sql = "SELECT * FROM Hopfengaben WHERE Name='" + ing + "' AND SudID=" + sudid;
                if (query.exec(sql))
                {
                    if (query.next())
                        return false;
                }
                if (query.exec("SELECT * FROM WeitereZutatenGaben WHERE Name='" + ing + "' AND SudID=" + sudid))
                {
                    if (query.next())
                        return false;
                }
            }
            else if (type == IngredientType::IngredientTypeYeast)
            {
                if (ingredient == querySud.value("AuswahlHefe").toString())
                    return false;
            }
            else if (type == IngredientType::IngredientTypeAdditive)
            {
                if (query.exec("SELECT * FROM WeitereZutatenGaben WHERE Name='" + ing + "' AND SudID=" + sudid))
                {
                    if (query.next())
                        return false;
                }
            }
        }
    }
    return true;
}
