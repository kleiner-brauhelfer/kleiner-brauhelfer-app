#include "modelrasten.h"
#include "brauhelfer.h"

ModelRasten::ModelRasten(Brauhelfer* bh) :
    SqlTableModel(bh),
    bh(bh)
{
}

QVariantMap ModelRasten::defaultValues() const
{
    QVariantMap values;
    values.insert("SudID", bh->sud()->getId());
    values.insert("RastAktiv", true);
    return values;
}
