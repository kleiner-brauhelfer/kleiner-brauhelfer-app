#include "modelweiterezutatengaben.h"
#include "brauhelfer.h"
#include <QDateTime>

ModelWeitereZutatenGaben::ModelWeitereZutatenGaben(Brauhelfer* bh) :
    SqlTableModel(bh),
    bh(bh)
{
}

QVariant ModelWeitereZutatenGaben::dataExt(const QModelIndex &index) const
{
    QString field = fieldName(index.column());
    if (field == "Zeitpunkt_von")
    {
        return QDateTime::fromString(QSqlTableModel::data(index).toString(), Qt::ISODate);
    }
    if (field == "Zeitpunkt_bis")
    {
        return QDateTime::fromString(QSqlTableModel::data(index).toString(), Qt::ISODate);
    }
    return QVariant();
}

bool ModelWeitereZutatenGaben::setDataExt(const QModelIndex &index, const QVariant &value)
{
    QString field = fieldName(index.column());
    if (field == "Zeitpunkt_von")
    {
        return QSqlTableModel::setData(index, value.toDateTime().toString(Qt::ISODate));
    }
    if (field == "Zeitpunkt_bis")
    {
        return QSqlTableModel::setData(index, value.toDateTime().toString(Qt::ISODate));
    }
    return false;
}
