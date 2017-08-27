#ifndef MODELBEWERTUNGEN_H
#define MODELBEWERTUNGEN_H

#include "sqltablemodel.h"

class Brauhelfer;

class ModelBewertungen : public SqlTableModel
{
public:
    ModelBewertungen(Brauhelfer* bh);
    QVariant dataExt(const QModelIndex &index) const Q_DECL_OVERRIDE;
    bool setDataExt(const QModelIndex &index, const QVariant &value) Q_DECL_OVERRIDE;
    QVariantMap defaultValues() const Q_DECL_OVERRIDE;
private:
    Brauhelfer* bh;
};

#endif // MODELBEWERTUNGEN_H
