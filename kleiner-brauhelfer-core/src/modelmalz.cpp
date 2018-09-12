#include "modelmalz.h"
#include "brauhelfer.h"
#include <QDate>

ModelMalz::ModelMalz(Brauhelfer* bh) :
    SqlTableModel(bh)
{
}

QVariant ModelMalz::dataExt(const QModelIndex &index) const
{
    QString field = fieldName(index.column());
    if (field == "Eingelagert")
    {
        return QDateTime::fromString(QSqlTableModel::data(index).toString(), Qt::ISODate);
    }
    if (field == "Mindesthaltbar")
    {
        return QDateTime::fromString(QSqlTableModel::data(index).toString(), Qt::ISODate);
    }
    return QVariant();
}

bool ModelMalz::setDataExt(const QModelIndex &index, const QVariant &value)
{
    QString field = fieldName(index.column());
    if (field == "Eingelagert")
    {
        return QSqlTableModel::setData(index, value.toDateTime().toString(Qt::ISODate));
    }
    if (field == "Mindesthaltbar")
    {
        return QSqlTableModel::setData(index, value.toDateTime().toString(Qt::ISODate));
    }
    if (field == "Menge")
    {
        double prevValue = data(index.row(), "Menge").toDouble();
        if (QSqlTableModel::setData(index, value))
        {
            if (value.toDouble() > 0.0)
            {
                if (prevValue == 0.0)
                {
                    setData(this->index(index.row(), fieldIndex("Eingelagert")), QDate::currentDate());
                    setData(this->index(index.row(), fieldIndex("Mindesthaltbar")), QDate::currentDate().addMonths(1));
                }
            }
        }
    }
    return false;
}

QVariantMap ModelMalz::defaultValues() const
{
    QVariantMap values;
    values.insert("MaxProzent", 100);
    values.insert("Eingelagert", QDate::currentDate());
    values.insert("Mindesthaltbar", QDate::currentDate().addMonths(1));
    return values;
}
