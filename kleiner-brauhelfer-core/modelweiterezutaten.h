#ifndef MODELWEITEREZUTATEN_H
#define MODELWEITEREZUTATEN_H

#include "kleiner-brauhelfer-core_global.h"
#include "sqltablemodel.h"

class Brauhelfer;

class LIB_EXPORT ModelWeitereZutaten : public SqlTableModel
{
    Q_OBJECT

public:

    enum Column
    {
        ColID,
        ColName,
        ColMenge,
        ColEinheit,
        ColTyp,
        ColAusbeute,
        ColFarbe,
        ColBemerkung,
        ColEigenschaften,
        ColAlternativen,
        ColPreis,
        ColEingelagert,
        ColMindesthaltbar,
        ColLink,
        ColUnvergaerbar,
        // virtual
        ColDeleted,
        ColMengeNormiert,
        ColInGebrauch,
        ColInGebrauchListe,
        // number of columns
        NumCols
    };
    Q_ENUM(Column)

public:

    ModelWeitereZutaten(Brauhelfer* bh, QSqlDatabase db = QSqlDatabase());
    QVariant dataExt(const QModelIndex &index) const Q_DECL_OVERRIDE;
    bool setDataExt(const QModelIndex &index, const QVariant &value) Q_DECL_OVERRIDE;
    void defaultValues(QMap<int, QVariant> &values) const Q_DECL_OVERRIDE;

private:

    Brauhelfer* bh;
};

#endif // MODELWEITEREZUTATEN_H
