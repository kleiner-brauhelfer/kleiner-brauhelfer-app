#ifndef SUDOBJECT_H
#define SUDOBJECT_H

#include <QObject>
#include <QDateTime>
#include <QSortFilterProxyModel>
#include "sqltablemodel.h"

class Brauhelfer;

// Property with automatic getter/setter generation
#define Q_PROPERTY_SUD(type, name, convertion) \
    Q_PROPERTY(type name READ get##name WRITE set##name NOTIFY modified) \
    public: type get##name() const { return getValue(#name).convertion; } \
    public: void set##name(type const &value) { setValue(#name, value); }
#define Q_PROPERTY_SUD_READONLY(type, name, convertion) \
    Q_PROPERTY(type name READ get##name NOTIFY modified) \
    public: type get##name() const { return getValue(#name).convertion; }

class SudObject : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool loaded READ loaded NOTIFY modified)
    Q_PROPERTY(bool isModified READ isDirty NOTIFY modified)
    Q_PROPERTY(int id READ getId NOTIFY modified)

    // real fields in table Sud
    Q_PROPERTY_SUD(QString, Sudname, toString())
    Q_PROPERTY_SUD(double, Menge, toDouble())
    Q_PROPERTY_SUD(double, SW, toDouble())
    Q_PROPERTY_SUD(double, CO2, toDouble())
    Q_PROPERTY_SUD(double, IBU, toDouble())
    Q_PROPERTY_SUD(QString, Kommentar, toString())
    Q_PROPERTY_SUD(QDateTime, Braudatum, toDateTime())
    Q_PROPERTY_SUD(bool, BierWurdeGebraut, toBool())
    Q_PROPERTY_SUD(QDateTime, Anstelldatum, toDateTime())
    Q_PROPERTY_SUD(double, WuerzemengeAnstellen, toDouble())
    Q_PROPERTY_SUD(double, SWAnstellen, toDouble())
    Q_PROPERTY_SUD(QDateTime, Abfuelldatum, toDateTime())
    Q_PROPERTY_SUD(bool, BierWurdeAbgefuellt, toBool())
    Q_PROPERTY_SUD(double, SWSchnellgaerprobe, toDouble())
    Q_PROPERTY_SUD(double, SWJungbier, toDouble())
    Q_PROPERTY_SUD(double, TemperaturJungbier, toDouble())
    Q_PROPERTY_SUD(double, WuerzemengeKochende, toDouble())
    Q_PROPERTY_SUD(double, Speisemenge, toDouble())
    Q_PROPERTY_SUD(double, SWKochende, toDouble())
    Q_PROPERTY_SUD(QString, AuswahlHefe, toString())
    Q_PROPERTY_SUD(double, FaktorHauptguss, toDouble())
    Q_PROPERTY_SUD(double, KochdauerNachBitterhopfung, toDouble())
    Q_PROPERTY_SUD(double, EinmaischenTemp, toDouble())
    Q_PROPERTY_SUD(QDateTime, Erstellt, toDateTime())
    Q_PROPERTY_SUD(QDateTime, Gespeichert, toDateTime())
    Q_PROPERTY_SUD(int, AktivTab, toInt())
    Q_PROPERTY_SUD(double, erg_S_Gesammt, toDouble())
    Q_PROPERTY_SUD(double, erg_W_Gesammt, toDouble())
    Q_PROPERTY_SUD(double, erg_WHauptguss, toDouble())
    Q_PROPERTY_SUD(double, erg_WNachguss, toDouble())
    Q_PROPERTY_SUD(double, erg_Sudhausausbeute, toDouble())
    Q_PROPERTY_SUD(double, erg_Farbe, toDouble())
    Q_PROPERTY_SUD(double, erg_Preis, toDouble())
    Q_PROPERTY_SUD(double, erg_Alkohol, toDouble())
    Q_PROPERTY_SUD(double, KostenWasserStrom, toDouble())
    Q_PROPERTY_SUD(double, Bewertung, toDouble())
    Q_PROPERTY_SUD(QString, BewertungText, toString())
    Q_PROPERTY_SUD(int, AktivTab_Gaerverlauf, toInt())
    Q_PROPERTY_SUD(int, Reifezeit, toInt())
    Q_PROPERTY_SUD(bool, BierWurdeVerbraucht, toBool())
    Q_PROPERTY_SUD(double, Nachisomerisierungszeit, toDouble())
    Q_PROPERTY_SUD(double, WuerzemengeVorHopfenseihen, toDouble())
    Q_PROPERTY_SUD(double, SWVorHopfenseihen, toDouble())
    Q_PROPERTY_SUD(double, erg_EffektiveAusbeute, toDouble())
    Q_PROPERTY_SUD(double, RestalkalitaetSoll, toDouble())
    Q_PROPERTY_SUD(bool, SchnellgaerprobeAktiv, toBool())
    Q_PROPERTY_SUD(double, JungbiermengeAbfuellen, toDouble())
    Q_PROPERTY_SUD(double, erg_AbgefuellteBiermenge, toDouble())
    Q_PROPERTY_SUD(double, BewertungMaxSterne, toDouble())
    Q_PROPERTY_SUD(bool, NeuBerechnen, toBool())
    Q_PROPERTY_SUD(double, HefeAnzahlEinheiten, toDouble())
    Q_PROPERTY_SUD(double, berechnungsArtHopfen, toDouble())
    Q_PROPERTY_SUD(double, highGravityFaktor, toDouble())
    Q_PROPERTY_SUD(int, AuswahlBrauanlage, toInt())
    Q_PROPERTY_SUD(QString, AuswahlBrauanlageName, toString())
    Q_PROPERTY_SUD(bool, AusbeuteIgnorieren, toBool())
    Q_PROPERTY_SUD(int, MerklistenID, toInt())
    Q_PROPERTY_SUD(bool, Spunden, toBool())

    // virtual fields in table Sud
    Q_PROPERTY_SUD_READONLY(double, SWIst, toDouble())
    Q_PROPERTY_SUD_READONLY(double, SREIst, toDouble())
    Q_PROPERTY_SUD_READONLY(double, CO2Ist, toDouble())
    Q_PROPERTY_SUD_READONLY(double, Spundungsdruck, toDouble())
    Q_PROPERTY_SUD_READONLY(double, Gruenschlauchzeitpunkt, toDouble())
    Q_PROPERTY_SUD_READONLY(double, SpeiseNoetig, toDouble())
    Q_PROPERTY_SUD_READONLY(double, SpeiseAnteil, toDouble())
    Q_PROPERTY_SUD_READONLY(double, ZuckerAnteil, toDouble())
    Q_PROPERTY_SUD_READONLY(int, ReifezeitDelta, toInt())
    Q_PROPERTY_SUD_READONLY(bool, AbfuellenBereitZutaten, toBool())
    Q_PROPERTY_SUD_READONLY(double, MengeSollKochbegin, toDouble())
    Q_PROPERTY_SUD_READONLY(double, MengeSollKochende, toDouble())
    Q_PROPERTY_SUD_READONLY(double, SWSollLautern, toDouble())
    Q_PROPERTY_SUD_READONLY(double, SWSollKochbegin, toDouble())
    Q_PROPERTY_SUD_READONLY(double, SWSollKochende, toDouble())
    Q_PROPERTY_SUD_READONLY(double, SWSollAnstellen, toDouble())
    Q_PROPERTY_SUD_READONLY(double, KorrekturWasser, toDouble())
    Q_PROPERTY_SUD_READONLY(double, Verdampfungsziffer, toDouble())
    Q_PROPERTY_SUD_READONLY(double, RestalkalitaetFaktor, toDouble())
    Q_PROPERTY_SUD_READONLY(double, FaktorHauptgussEmpfehlung, toDouble())

    // tables
    Q_PROPERTY(SqlTableModel* modelRasten READ modelRasten CONSTANT)
    Q_PROPERTY(SqlTableModel* modelMalzschuettung READ modelMalzschuettung CONSTANT)
    Q_PROPERTY(SqlTableModel* modelHopfengaben READ modelHopfengaben CONSTANT)
    Q_PROPERTY(SqlTableModel* modelWeitereZutatenGaben READ modelWeitereZutatenGaben CONSTANT)
    Q_PROPERTY(SqlTableModel* modelSchnellgaerverlauf READ modelSchnellgaerverlauf CONSTANT)
    Q_PROPERTY(SqlTableModel* modelHauptgaerverlauf READ modelHauptgaerverlauf CONSTANT)
    Q_PROPERTY(SqlTableModel* modelNachgaerverlauf READ modelNachgaerverlauf CONSTANT)
    Q_PROPERTY(SqlTableModel* modelBewertungen READ modelBewertungen CONSTANT)
    Q_PROPERTY(SqlTableModel* modelAnhang READ modelAnhang CONSTANT)

public:

    /**
     * @brief Creates a brew object
     * @param bh Brauhelfer class
     */
    SudObject(Brauhelfer *bh);

    /**
     * @brief Loads a brew
     * @param id Brew ID
     */
    Q_INVOKABLE void load(int id);

    /**
     * @brief Unload any loaded brew
     */
    Q_INVOKABLE void unload();

    /**
     * @brief Loaded State
     * @return True if a brew is loaded
     */
    bool loaded() const;

    /**
     * @brief Modification state of the database
     * @return True if database was modified
     */
    bool isDirty() const;

    /**
     * @brief Selects all tables related to the brew
     */
    void select();

    /**
     * @brief Gets the brew ID
     * @return Brew ID
     */
    int getId() const;

    /**
     * @brief Gets a value
     * @param fieldName Field name
     * @return Value
     */
    QVariant getValue(const QString &fieldName) const;

    /**
     * @brief Sets a value
     * @param fieldName Field name
     * @param value Field value
     * @return True on success
     */
    bool setValue(const QString &fieldName, const QVariant &value);

    /**
     * @brief Gets the different tables
     * @return Table model
     */
    SqlTableModel* modelRasten() const;
    SqlTableModel* modelMalzschuettung() const;
    SqlTableModel* modelHopfengaben() const;
    SqlTableModel* modelWeitereZutatenGaben() const;
    SqlTableModel* modelSchnellgaerverlauf() const;
    SqlTableModel* modelHauptgaerverlauf() const;
    SqlTableModel* modelNachgaerverlauf() const;
    SqlTableModel* modelBewertungen() const;
    SqlTableModel* modelAnhang() const;

    /**
     * @brief Substracts the brew ingredients from the inventory
     */
    Q_INVOKABLE void substractBrewIngredients();

    /**
     * @brief Substracts an ingredient from the inventory
     * @param ingredient Ingredient
     * @param type Ingredient type
     * @param quantity Quantity [g]
     */
    Q_INVOKABLE void substractIngredient(const QString& ingredient, int type, double quantity);

signals:

    /**
     * @brief Emitted when something was modified
     */
    void modified();

private:
    SqlTableModel* modelSud() const;

private:
    Brauhelfer *bh;
    int id;
};

#endif // SUDOBJECT_H
