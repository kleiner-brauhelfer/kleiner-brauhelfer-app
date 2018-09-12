#ifndef MODELWEITEREZUTATEN_H
#define MODELWEITEREZUTATEN_H

#include "sqltablemodel.h"

class Brauhelfer;

class ModelWeitereZutaten : public SqlTableModel
{
public:
    ModelWeitereZutaten(Brauhelfer* bh);
    QVariant dataExt(const QModelIndex &index) const Q_DECL_OVERRIDE;
    bool setDataExt(const QModelIndex &index, const QVariant &value) Q_DECL_OVERRIDE;
    QVariantMap defaultValues() const Q_DECL_OVERRIDE;
};

#endif // MODELWEITEREZUTATEN_H
