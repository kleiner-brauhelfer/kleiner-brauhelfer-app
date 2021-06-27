#ifndef MODELSUD_H
#define MODELSUD_H

#include "kleiner-brauhelfer-core_global.h"
#include "sqltablemodel.h"

class Brauhelfer;

class LIB_EXPORT ModelSud : public SqlTableModel
{
    Q_OBJECT

    friend class ProxyModelSud;

public:

    enum Column
    {
        ColID,
        ColSudname,
        ColSudnummer,
        ColKategorie,
        ColAnlage,
        ColMenge,
        ColSW,
        ColhighGravityFaktor,
        ColFaktorHauptguss,
        ColWasserprofil,
        ColRestalkalitaetSoll,
        ColCO2,
        ColIBU,
        ColberechnungsArtHopfen,
        ColKochdauer,
        ColNachisomerisierungszeit,
        ColReifezeit,
        ColKostenWasserStrom,
        ColKommentar,
        ColStatus,
        ColBraudatum,
        ColAbfuelldatum,
        ColErstellt,
        ColGespeichert,
        Colerg_S_Gesamt,
        Colerg_W_Gesamt,
        Colerg_WHauptguss,
        Colerg_WNachguss,
        Colerg_Farbe,
        ColSWKochende,
        ColSWAnstellen,
        ColSchnellgaerprobeAktiv,
        ColSWSchnellgaerprobe,
        ColSWJungbier,
        ColTemperaturJungbier,
        ColWuerzemengeVorHopfenseihen,
        ColWuerzemengeKochende,
        ColWuerzemengeAnstellen,
        ColSpunden,
        ColSpeisemenge, // TODO: Speisemenge REAL DEFAULT 0
        ColJungbiermengeAbfuellen,
        Colerg_AbgefuellteBiermenge,
        Colerg_Sudhausausbeute,
        Colerg_EffektiveAusbeute,
        Colerg_Preis,
        Colerg_Alkohol,
        ColAusbeuteIgnorieren,
        ColMerklistenID,
        ColSudhausausbeute,
        ColVerdampfungsrate,
        ColVergaerungsgrad,
        ColWuerzemengeKochbeginn,
        ColSWKochbeginn,
        ColVerschneidungAbfuellen,
        ColTemperaturKarbonisierung,
        ColBemerkungBrauen,
        ColBemerkungAbfuellen,
        ColBemerkungGaerung,
        ColReifungStart,
        // virtual
        ColDeleted,
        ColMengeSoll,
        ColSWIst,
        ColSRE,
        ColSREIst,
        ColMengeIst,
        ColIbuIst,
        ColFarbeIst,
        ColCO2Ist,
        ColSpundungsdruck,
        ColGruenschlauchzeitpunkt,
        ColSpeiseNoetig,
        ColSpeiseAnteil,
        ColZuckerAnteil,
        ColWoche,
        ColReifezeitDelta,
        ColAbfuellenBereitZutaten,
        ColMengeSollKochbeginn,
        ColMengeSollKochende,
        ColWuerzemengeAnstellenTotal,
        ColSW_Malz,
        ColSW_WZ_Maischen,
        ColSW_WZ_Kochen,
        ColSW_WZ_Gaerung,
        ColSWSollKochbeginn,
        ColSWSollKochbeginnMitWz,
        ColSWSollKochende,
        ColSWSollAnstellen,
        ColWasserHgf,
        ColVerdampfungsrateIst,
        ColsEVG,
        ColtEVG,
        ColAlkohol,
        ColRestalkalitaetWasser,
        ColRestalkalitaetIst,
        ColPhMalz,
        ColPhMaische,
        ColPhMaischeSoll,
        ColFaktorHauptgussEmpfehlung,
        ColWHauptgussEmpfehlung,
        ColBewertungMittel,
        // number of columns
        NumCols
    };
    Q_ENUM(Column)

public:

    ModelSud(Brauhelfer* bh, QSqlDatabase db = QSqlDatabase());
    void createConnections();
    QVariant dataExt(const QModelIndex &index) const Q_DECL_OVERRIDE;
    bool setDataExt(const QModelIndex &index, const QVariant &value) Q_DECL_OVERRIDE;
    Qt::ItemFlags flags(const QModelIndex &index) const Q_DECL_OVERRIDE;
    bool removeRows(int row, int count = 1, const QModelIndex &parent = QModelIndex()) Q_DECL_OVERRIDE;
    void defaultValues(QMap<int, QVariant> &values) const Q_DECL_OVERRIDE;
    QMap<int, QVariant> copyValues(int row) const Q_DECL_OVERRIDE;
    QVariant dataSud(QVariant sudId, int col);
    QVariant dataAnlage(int row, int col) const;
    QVariant dataWasser(int row, int col) const;
    void update(int row, int colChanged = -1);

private slots:

    void onModelReset();
    void onRowChanged(const QModelIndex &index);
    void onOtherModelRowChanged(const QModelIndex &index);
    void onAnlageRowChanged(const QModelIndex &index);
    void onWasserRowChanged(const QModelIndex &index);

private:

    bool setDataExt_impl(const QModelIndex &index, const QVariant &value);
    void updateSwWeitereZutaten(int row);
    void updateWasser(int row);
    void updateFarbe(int row);
    void updatePreis(int row);
    void removeRowsFrom(SqlTableModel* model, int colId, const QList<int>& sudIds);

private:

    Brauhelfer* bh;
    bool mUpdating;
    bool mSkipUpdateOnOtherModelChanged;
    QVector<double> swWzMaischenRecipe;
    QVector<double> swWzKochenRecipe;
    QVector<double> swWzGaerungRecipe;
    QVector<double> swWzGaerungCurrent;
};

#endif // MODELSUD_H
