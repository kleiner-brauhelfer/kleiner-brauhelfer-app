#ifndef MODELSUD_H
#define MODELSUD_H

#include "sqltablemodel.h"

class Brauhelfer;

// integer value to string literal
#ifndef STR_IMPL_
  #define STR_IMPL_(x)                      #x
#endif
#ifndef STR
  #define STR(x)                            STR_IMPL_(x)
#endif

class ModelSud : public SqlTableModel
{
    Q_OBJECT

public:
    ModelSud(Brauhelfer* bh, bool globalList);
    ~ModelSud() Q_DECL_OVERRIDE;
    QVariant dataExt(const QModelIndex &index) const Q_DECL_OVERRIDE;
    bool setDataExt(const QModelIndex &index, const QVariant &value) Q_DECL_OVERRIDE;
private slots:
    void onModelReset();
    void onValueChanged(const QModelIndex &index, const QVariant &value);
private:
    QVariant dataAnlage(int row, const QString& fieldName) const;
    void updateIntermediateValues(int row);
    void updateFarbe(int row);
    void updatePreis(int row);
    void updateKochdauer(const QVariant &value);
    QVariant SWIst(const QModelIndex &index) const;
    QVariant SREIst(const QModelIndex &index) const;
    QVariant CO2Ist(const QModelIndex &index) const;
    QVariant Spundungsdruck(const QModelIndex &index) const;
    QVariant Gruenschlauchzeitpunkt(const QModelIndex &index) const;
    QVariant SpeiseNoetig(const QModelIndex &index) const;
    QVariant SpeiseAnteil(const QModelIndex &index) const;
    QVariant ZuckerAnteil(const QModelIndex &index) const;
    QVariant ReifezeitDelta(const QModelIndex &index) const;
    QVariant AbfuellenBereitZutaten(const QModelIndex &index) const;
    QVariant MengeSollKochbeginn(const QModelIndex &index) const;
    QVariant MengeSollKochende(const QModelIndex &index) const;
    QVariant SWSollLautern(const QModelIndex &index) const;
    QVariant SWSollKochbeginn(const QModelIndex &index) const;
    QVariant SWSollKochende(const QModelIndex &index) const;
    QVariant SWSollAnstellen(const QModelIndex &index) const;
    QVariant Verdampfungsziffer(const QModelIndex &index) const;
    QVariant RestalkalitaetFaktor(const QModelIndex &index) const;
    QVariant FaktorHauptgussEmpfehlung(const QModelIndex &index) const;
private:
    Brauhelfer* bh;
    bool updating;
    const bool globalList;
    double *swWzMaischenRecipe;
    double *swWzKochenRecipe;
    double *swWzGaerungRecipe;
    double *swWzGaerungCurrent;
};

#endif // MODELSUD_H
