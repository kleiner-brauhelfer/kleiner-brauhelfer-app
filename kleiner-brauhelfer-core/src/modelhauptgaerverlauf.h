#ifndef MODELHAUPTGAERVERLAUF_H
#define MODELHAUPTGAERVERLAUF_H

#include "sqltablemodel.h"

class Brauhelfer;

class ModelHauptgaerverlauf : public SqlTableModel
{
public:
    ModelHauptgaerverlauf(Brauhelfer* bh);
    QVariant dataExt(const QModelIndex &index) const Q_DECL_OVERRIDE;
    bool setDataExt(const QModelIndex &index, const QVariant &value) Q_DECL_OVERRIDE;
    QVariantMap defaultValues() const Q_DECL_OVERRIDE;
private:
    Brauhelfer* bh;
};

#endif // MODELHAUPTGAERVERLAUF_H
