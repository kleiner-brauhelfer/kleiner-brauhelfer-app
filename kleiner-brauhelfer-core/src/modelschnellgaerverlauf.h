#ifndef MODELSCHNELLGAERVERLAUF_H
#define MODELSCHNELLGAERVERLAUF_H

#include "sqltablemodel.h"

class Brauhelfer;

class ModelSchnellgaerverlauf : public SqlTableModel
{
public:
    ModelSchnellgaerverlauf(Brauhelfer* bh);
    QVariant dataExt(const QModelIndex &index) const Q_DECL_OVERRIDE;
    bool setDataExt(const QModelIndex &index, const QVariant &value) Q_DECL_OVERRIDE;
    QVariantMap defaultValues() const Q_DECL_OVERRIDE;
private:
    Brauhelfer* bh;
};

#endif // MODELSCHNELLGAERVERLAUF_H
