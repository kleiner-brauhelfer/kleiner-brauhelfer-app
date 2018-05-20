#ifndef BRAUHELFER_H
#define BRAUHELFER_H

#include "biercalc.h"
#include "sudobject.h"
#include "sqltablemodel.h"
#include "syncservice.h"

#include <QtCore/qglobal.h>
#include <QObject>
#include <QSettings>
#include <QUrl>

#if defined(KBCORE_LIBRARY)
  #define KBCORE_EXPORT Q_DECL_EXPORT
#else
  #define KBCORE_EXPORT Q_DECL_IMPORT
#endif

class Database;

/**
 * @brief Brauhelfer class
 */
class KBCORE_EXPORT Brauhelfer : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool connected READ connected NOTIFY connectionChanged)
    Q_PROPERTY(bool isServiceAvailable READ isServiceAvailable NOTIFY connectionChanged)
    Q_PROPERTY(bool readonly READ readonly NOTIFY connectionChanged)
    Q_PROPERTY(QString databasePath READ databasePath NOTIFY connectionChanged)
    Q_PROPERTY(bool modified READ isDirty NOTIFY modified)
    Q_PROPERTY(SyncService::SyncState syncState READ syncState NOTIFY modified)

    Q_PROPERTY(BierCalc* calc READ calc CONSTANT)
    Q_PROPERTY(SudObject* sud READ sud CONSTANT)
    Q_PROPERTY(SqlTableModel* modelSudAuswahl READ modelSudAuswahl CONSTANT)
    Q_PROPERTY(SqlTableModel* modelRastauswahl READ modelRastauswahl CONSTANT)
    Q_PROPERTY(SqlTableModel* modelMalz READ modelMalz CONSTANT)
    Q_PROPERTY(SqlTableModel* modelHopfen READ modelHopfen CONSTANT)
    Q_PROPERTY(SqlTableModel* modelHefe READ modelHefe CONSTANT)
    Q_PROPERTY(SqlTableModel* modelWeitereZutaten READ modelWeitereZutaten CONSTANT)
    Q_PROPERTY(SqlTableModel* modelAusruestung READ modelAusruestung CONSTANT)
    Q_PROPERTY(SqlTableModel* modelGeraete READ modelGeraete CONSTANT)
    Q_PROPERTY(SqlTableModel* modelWasser READ modelWasser CONSTANT)

    Q_ENUMS(SyncService::SyncState)

public:

    /**
     * @brief Major library version
     */
    static const int versionMajor;

    /**
     * @brief Minor library version
     */
    static const int verionMinor;

    /**
     * @brief Patch library version
     */
    static const int versionPatch;

public:

    /**
     * @brief Creates a Brauhelfer class
     * @param databasePath Local database path
     * @param parent Parent
     */
    explicit Brauhelfer(const QString &databasePath, QObject *parent = Q_NULLPTR);

    /**
     * @brief Creates a Brauhelfer class
     * @param service Database synchronization service
     * @param parent Parent
     */
    Brauhelfer(SyncService *service, QObject *parent = Q_NULLPTR);

    /**
     * @brief Destroys the Brauhelfer class
     */
    ~Brauhelfer();

    /**
     * @brief Emits a debug message
     * @note Verbose mode must be enabled first
     * @see Signal newMessage()
     * @param msg Message
     */
    Q_INVOKABLE void message(const QString &msg);

    /**
     * @brief Sets the verbose mode
     * @note By default verbose mode is disabled
     * @param verbose Verbose mod
     */
    Q_INVOKABLE void setVerbose(bool verbose);

    /**
     * @brief Connects to the database
     */
    Q_INVOKABLE bool connect();

    /**
     * @brief Disconnects from the database
     */
    Q_INVOKABLE void disconnect();

    /**
     * @brief Database connection state
     * @return True if connected to the database
     */
    bool connected() const;

    /**
     * @brief Connection state to the synchronization service
     * @return True if synchronization service available
     */
    bool isServiceAvailable() const;

    /**
     * @brief Database synchronization
     * @return State of synchronization
     */
    SyncService::SyncState syncState() const;

    /**
     * @brief Read-only state of the database
     * @return Read-only state
     */
    bool readonly() const;

    /**
     * @brief Modification state of the database
     * @return True if database was modified
     */
    bool isDirty() const;

    /**
     * @brief Saves the database changes and synchronizes with the server if necessary
     */
    Q_INVOKABLE void save();

    /**
     * @brief Discards the database changes
     * @param skipSelect Skips the re-selection of the tables
     */
    Q_INVOKABLE void discard(bool skipSelect = false);

    /**
     * @brief Selects the main tables
     */
    Q_INVOKABLE void select();

    /**
     * @brief Clears the database cache
     */
    Q_INVOKABLE void clearCache();

    /**
     * @brief Gets the database path on the device
     * @return Database path
     */
    QString databasePath() const;

    /**
     * @brief Gets the database
     * @return Database
     */
    Database* db() const;

    /**
     * @brief Gets the beer calculation module
     * @return Bier calculation module
     */
    BierCalc* calc() const;

    /**
     * @brief Gets the current loaded brew
     * @return Brew
     */
    SudObject* sud() const;

    /**
     * @brief Gets the different tables
     * @return Table model
     */
    SqlTableModel* modelSudAuswahl() const;
    SqlTableModel* modelRastauswahl() const;
    SqlTableModel* modelMalz() const;
    SqlTableModel* modelHopfen() const;
    SqlTableModel* modelHefe() const;
    SqlTableModel* modelWeitereZutaten() const;
    SqlTableModel* modelAusruestung() const;
    SqlTableModel* modelGeraete() const;
    SqlTableModel* modelWasser() const;

public slots:

    /**
     * @brief Sets the database synchronization service
     * @param service Database synchronization service
     */
    void setSyncService(SyncService *service);

signals:

    /**
     * @brief Emitted on a new debug message
     * @see Function message()
     * @param msg Message
     */
    void newMessage(const QString &msg);

    /**
     * @brief Emitted if database connection changed
     * @param connected Connection state
     */
    void connectionChanged(bool connected);

    /**
     * @brief Emitted when the database was changed
     */
    void modified();

private slots:

    /**
     * @brief Called when an error occurred
     * @param code Error code
     * @param msg Error message
     */
    void errorOccurred(int code, const QString& msg);

    /**
     * @brief Called on download or upload progress update
     * @param current Current number of bytes transferred
     * @param total Total number of bytes to transfer
     */
    void progress(qint64 current, qint64 total);

private:
    bool _verbose;
    SyncService* _fs;
    Database* _db;
    BierCalc* _calc;
    SudObject* _sud;
};

#endif // BRAUHELFER_H
