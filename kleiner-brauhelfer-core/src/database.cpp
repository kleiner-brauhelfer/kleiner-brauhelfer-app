#include "database.h"

#include <QObject>
#include <QVariant>
#include <QFile>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSortFilterProxyModel>
#include "sqltablemodel.h"
#include "modelsud.h"
#include "modelschnellgaerverlauf.h"
#include "modelhauptgaerverlauf.h"
#include "modelnachgaerverlauf.h"
#include "modelbewertungen.h"
#include "modelwasser.h"
#include "modelweiterezutatengaben.h"
#include "brauhelfer.h"

Database::Database(Brauhelfer* bh) :
    version(-1)
{
    db = new QSqlDatabase(QSqlDatabase::addDatabase("QSQLITE"));
    modelSudAuswahl = new ModelSud(bh, true);
    modelSud = new ModelSud(bh, false);
    modelRasten = new SqlTableModel(bh);
    modelRastauswahl = new SqlTableModel(bh);
    modelMalzschuettung = new SqlTableModel(bh);
    modelHopfengaben = new SqlTableModel(bh);
    modelWeitereZutatenGaben = new ModelWeitereZutatenGaben(bh);
    modelSchnellgaerverlauf = new ModelSchnellgaerverlauf(bh);
    modelHauptgaerverlauf = new ModelHauptgaerverlauf(bh);
    modelNachgaerverlauf = new ModelNachgaerverlauf(bh);
    modelBewertungen = new ModelBewertungen(bh);
    modelMalz = new SqlTableModel(bh);
    modelHopfen = new SqlTableModel(bh);
    modelHefe = new SqlTableModel(bh);
    modelWeitereZutaten = new SqlTableModel(bh);
    modelAnhang = new SqlTableModel(bh);
    modelAusruestung = new SqlTableModel(bh);
    modelGeraete = new SqlTableModel(bh);
    modelWasser = new ModelWasser(bh);
}

void Database::onConnect()
{
    modelSudAuswahl->setTable("Sud");
    modelSudAuswahl->setSortByFieldName("Braudatum", Qt::DescendingOrder);
    modelSud->setTable("Sud");
    modelSud->setSortByFieldName("Braudatum", Qt::DescendingOrder);
    modelRasten->setTable("Rasten");
    modelRastauswahl->setTable("Rastauswahl");
    modelMalzschuettung->setTable("Malzschuettung");
    modelHopfengaben->setTable("Hopfengaben");
    modelWeitereZutatenGaben->setTable("WeitereZutatenGaben");
    modelSchnellgaerverlauf->setTable("Schnellgaerverlauf");
    modelSchnellgaerverlauf->setSortByFieldName("Zeitstempel", Qt::AscendingOrder);
    modelHauptgaerverlauf->setTable("Hauptgaerverlauf");
    modelHauptgaerverlauf->setSortByFieldName("Zeitstempel", Qt::AscendingOrder);
    modelNachgaerverlauf->setTable("Nachgaerverlauf");
    modelNachgaerverlauf->setSortByFieldName("Zeitstempel", Qt::AscendingOrder);
    modelBewertungen->setTable("Bewertungen");
    modelBewertungen->setSortByFieldName("Datum", Qt::AscendingOrder);
    modelMalz->setTable("Malz");
    modelHopfen->setTable("Hopfen");
    modelHefe->setTable("Hefe");
    modelWeitereZutaten->setTable("WeitereZutaten");
    modelAnhang->setTable("Anhang");
    modelAusruestung->setTable("Ausruestung");
    modelGeraete->setTable("Geraete");
    modelWasser->setTable("Wasser");
}

Database::~Database()
{
    QString connectionName = db->connectionName();
    disconnect();
    QSqlDatabase::removeDatabase(connectionName);
    delete db;
    delete modelSudAuswahl;
    delete modelSud;
    delete modelRasten;
    delete modelRastauswahl;
    delete modelMalzschuettung;
    delete modelHopfengaben;
    delete modelWeitereZutatenGaben;
    delete modelSchnellgaerverlauf;
    delete modelHauptgaerverlauf;
    delete modelNachgaerverlauf;
    delete modelBewertungen;
    delete modelMalz;
    delete modelHopfen;
    delete modelHefe;
    delete modelWeitereZutaten;
    delete modelAnhang;
    delete modelAusruestung;
    delete modelGeraete;
    delete modelWasser;
}

bool Database::connect(const QString &dbPath, bool readonly)
{
    if (!isConnected())
    {
        if (QFile::exists(dbPath))
        {
            db->setDatabaseName(dbPath);
            if (readonly)
                db->setConnectOptions("QSQLITE_OPEN_READONLY");
            if (db->open())
            {
                QSqlQuery query;
                if (query.exec("SELECT db_Version FROM Global"))
                {
                    if (query.first())
                    {
                        version = query.value(0).toInt();
                        onConnect();
                        return true;
                    }
                }
            }
            disconnect();
        }
    }
    return false;
}

void Database::disconnect()
{
    if (isConnected())
    {
        modelSudAuswahl->clear();
        modelSud->clear();
        modelRasten->clear();
        modelRastauswahl->clear();
        modelMalzschuettung->clear();
        modelHopfengaben->clear();
        modelWeitereZutatenGaben->clear();
        modelSchnellgaerverlauf->clear();
        modelHauptgaerverlauf->clear();
        modelNachgaerverlauf->clear();
        modelBewertungen->clear();
        modelMalz->clear();
        modelHopfen->clear();
        modelHefe->clear();
        modelWeitereZutaten->clear();
        modelAnhang->clear();
        modelAusruestung->clear();
        modelGeraete->clear();
        modelWasser->clear();
        db->close();
        version = -1;
    }
}

bool Database::isConnected() const
{
    return db->isOpen();
}

bool Database::isDirty() const
{
    return modelSudAuswahl->isDirty() |
           modelSud->isDirty() |
           modelRasten->isDirty() |
           modelRastauswahl->isDirty() |
           modelMalzschuettung->isDirty() |
           modelHopfengaben->isDirty() |
           modelWeitereZutatenGaben->isDirty() |
           modelSchnellgaerverlauf->isDirty() |
           modelHauptgaerverlauf->isDirty() |
           modelNachgaerverlauf->isDirty() |
           modelBewertungen->isDirty() |
           modelMalz->isDirty() |
           modelHopfen->isDirty() |
           modelHefe->isDirty() |
           modelWeitereZutaten->isDirty() |
           modelAnhang->isDirty() |
           modelAusruestung->isDirty() |
           modelGeraete->isDirty() |
           modelWasser->isDirty();
}

int Database::getVersion() const
{
    return version;
}

void Database::save()
{
    modelSudAuswahl->submitAll();
    modelSud->submitAll();
    modelRasten->submitAll();
    modelRastauswahl->submitAll();
    modelMalzschuettung->submitAll();
    modelHopfengaben->submitAll();
    modelWeitereZutatenGaben->submitAll();
    modelSchnellgaerverlauf->submitAll();
    modelHauptgaerverlauf->submitAll();
    modelNachgaerverlauf->submitAll();
    modelBewertungen->submitAll();
    modelMalz->submitAll();
    modelHopfen->submitAll();
    modelHefe->submitAll();
    modelWeitereZutaten->submitAll();
    modelAnhang->submitAll();
    modelAusruestung->submitAll();
    modelGeraete->submitAll();
    modelWasser->submitAll();
}

void Database::discard()
{
    modelSudAuswahl->revertAll();
    modelSud->revertAll();
    modelRasten->revertAll();
    modelRastauswahl->revertAll();
    modelMalzschuettung->revertAll();
    modelHopfengaben->revertAll();
    modelWeitereZutatenGaben->revertAll();
    modelSchnellgaerverlauf->revertAll();
    modelHauptgaerverlauf->revertAll();
    modelNachgaerverlauf->revertAll();
    modelBewertungen->revertAll();
    modelMalz->revertAll();
    modelHopfen->revertAll();
    modelHefe->revertAll();
    modelWeitereZutaten->revertAll();
    modelAnhang->revertAll();
    modelAusruestung->revertAll();
    modelGeraete->revertAll();
    modelWasser->revertAll();
}
