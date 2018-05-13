#ifndef MODELWEITEREZUTATENGABEN_H
#define MODELWEITEREZUTATENGABEN_H

#include "sqltablemodel.h"

class Brauhelfer;

class ModelWeitereZutatenGaben : public SqlTableModel
{
public:
    ModelWeitereZutatenGaben(Brauhelfer* bh);
    QVariant dataExt(const QModelIndex &index) const Q_DECL_OVERRIDE;
    bool setDataExt(const QModelIndex &index, const QVariant &value) Q_DECL_OVERRIDE;
private:
    Brauhelfer* bh;
};

#endif // MODELWEITEREZUTATENGABEN_H