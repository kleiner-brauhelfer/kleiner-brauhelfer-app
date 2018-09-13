#ifndef DATABASE_H
#define DATABASE_H

#include <QString>
#include "sqltablemodel.h"
#include "modelsud.h"
#include "modelmalz.h"
#include "modelhopfen.h"
#include "modelhefe.h"
#include "modelweiterezutaten.h"
#include "modelschnellgaerverlauf.h"
#include "modelhauptgaerverlauf.h"
#include "modelnachgaerverlauf.h"
#include "modelbewertungen.h"
#include "modelwasser.h"
#include "modelweiterezutatengaben.h"
#include "modelausruestung.h"

class QSqlDatabase;
class Brauhelfer;

/**
 * @brief Database class to handle sqlite database
 */
class Database
{
public:

    /**
     * @brief Creates a database class
     * @param bh Brauhelfer class
     */
    Database(Brauhelfer* bh);

    /**
     * @brief Destroys the database class
     */
    ~Database();

    /**
     * @brief Connects to the database
     * @param dbPath Database path
     * @param readonly Read-only
     * @return True if connected
     */
    bool connect(const QString &dbPath, bool readonly);

    /**
     * @brief Disconnects from the database
     */
    void disconnect();

    /**
     * @brief Gets the connection state
     * @return True if connected
     */
    bool isConnected() const;

    /**
     * @brief Modification state of the database
     * @return True if database was modified
     */
    bool isDirty() const;

    /**
     * @brief Gets the version of the database
     * @return Database version
     */
    int getVersion() const;

    /**
     * @brief Saves the pending changes of the whole database
     */
    void save();

    /**
     * @brief Discards the pending changes of the whole database
     */
    void discard();

private:
    void onConnect();

public:
    ModelSud* modelSudAuswahl;
    ModelSud* modelSud;
    SqlTableModel* modelRasten;
    SqlTableModel* modelRastauswahl;
    SqlTableModel* modelMalzschuettung;
    SqlTableModel* modelHopfengaben;
    ModelWeitereZutatenGaben* modelWeitereZutatenGaben;
    ModelSchnellgaerverlauf* modelSchnellgaerverlauf;
    ModelHauptgaerverlauf* modelHauptgaerverlauf;
    ModelNachgaerverlauf* modelNachgaerverlauf;
    ModelBewertungen* modelBewertungen;
    ModelMalz* modelMalz;
    ModelHopfen* modelHopfen;
    ModelHefe* modelHefe;
    ModelWeitereZutaten* modelWeitereZutaten;
    SqlTableModel* modelAnhang;
    ModelAusruestung* modelAusruestung;
    SqlTableModel* modelGeraete;
    ModelWasser* modelWasser;

private:
    QSqlDatabase* db;
    int version;
};

#endif // DATABASE_H
