#ifndef DATABASE_H
#define DATABASE_H

#include <QString>

class QSqlDatabase;
class SqlTableModel;
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
    SqlTableModel* modelSudAuswahl;
    SqlTableModel* modelSud;
    SqlTableModel* modelRasten;
    SqlTableModel* modelRastauswahl;
    SqlTableModel* modelMalzschuettung;
    SqlTableModel* modelHopfengaben;
    SqlTableModel* modelWeitereZutatenGaben;
    SqlTableModel* modelSchnellgaerverlauf;
    SqlTableModel* modelHauptgaerverlauf;
    SqlTableModel* modelNachgaerverlauf;
    SqlTableModel* modelBewertungen;
    SqlTableModel* modelMalz;
    SqlTableModel* modelHopfen;
    SqlTableModel* modelHefe;
    SqlTableModel* modelWeitereZutaten;
    SqlTableModel* modelAnhang;
    SqlTableModel* modelAusruestung;
    SqlTableModel* modelGeraete;
    SqlTableModel* modelWasser;

private:
    QSqlDatabase* db;
    bool connected;
    int version;
};

#endif // DATABASE_H
