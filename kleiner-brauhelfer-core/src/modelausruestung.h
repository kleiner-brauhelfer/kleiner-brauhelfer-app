#ifndef MODELAUSRUESTUNG_H
#define MODELAUSRUESTUNG_H

#include "sqltablemodel.h"

class Brauhelfer;

class ModelAusruestung : public SqlTableModel
{
public:
    ModelAusruestung(Brauhelfer* bh);
    QVariant dataExt(const QModelIndex &index) const Q_DECL_OVERRIDE;
private:
    Brauhelfer* bh;
};

#endif // MODELAUSRUESTUNG_H
