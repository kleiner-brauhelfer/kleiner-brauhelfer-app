#include "modelnachgaerverlauf.h"
#include "brauhelfer.h"
#include <QSqlQuery>

ModelNachgaerverlauf::ModelNachgaerverlauf(Brauhelfer* bh) :
    SqlTableModel(bh),
    bh(bh)
{
}

QVariant ModelNachgaerverlauf::dataExt(const QModelIndex &index) const
{
    QString field = fieldName(index.column());
    if (field == "Zeitstempel")
    {
        return QDateTime::fromString(QSqlTableModel::data(index).toString(), Qt::ISODate);
    }
    if (field == "CO2")
    {
        double p = data(index.row(), "Druck").toDouble();
        double T = data(index.row(), "Temp").toDouble();
        return BierCalc::co2(p, T);
    }
    return QVariant();
}

bool ModelNachgaerverlauf::setDataExt(const QModelIndex &index, const QVariant &value)
{
    QString field = fieldName(index.column());
    if (field == "Zeitstempel")
    {
        return QSqlTableModel::setData(index, value.toDateTime().toString(Qt::ISODate));
    }
    else if (field == "Druck" || field == "Temp")
    {
        if (QSqlTableModel::setData(index, value))
        {
            QModelIndex index2 = this->index(index.row(), fieldIndex("CO2"));
            QSqlTableModel::setData(index2, dataExt(index2));
            return true;
        }
    }
    return false;
}

QVariantMap ModelNachgaerverlauf::defaultValues() const
{
    int lastRow = rowCount() - 1;
    QVariantMap values;
    values.insert("SudID", bh->sud()->getId());
    values.insert("Zeitstempel", QDateTime::currentDateTime());
    if (lastRow >= 0)
    {
        values.insert("Druck", data(lastRow, "Druck"));
        values.insert("Temp", data(lastRow, "Temp"));
    }
    else
    {
        values.insert("Druck", 0.0);
        values.insert("Temp", 20.0);
    }
    return values;
}

QDateTime ModelNachgaerverlauf::getLastDateTime(int id) const
{
    if (id == -1)
    {
        if (rowCount() > 0)
        {
            int col = fieldIndex("Zeitstempel");
            QDateTime lastDt = data(index(0, col)).toDateTime();
            for (int i = 1; i < rowCount(); ++i)
            {
                QDateTime dt = data(index(i, col)).toDateTime();
                if (dt > lastDt)
                    lastDt = dt;
            }
            return lastDt;
        }
    }
    else
    {
        QSqlQuery query("SELECT Zeitstempel FROM " + tableName() + " WHERE SudID = " + QString::number(id) + " ORDER BY Zeitstempel DESC");
        if (query.first())
            return QDateTime::fromString(query.value(0).toString(), Qt::ISODate);
    }
    return QDateTime();
}

double ModelNachgaerverlauf::getLastCO2(int id) const
{
    if (id == -1)
    {
        if (rowCount() > 0)
        {
            int col = fieldIndex("Zeitstempel");
            int col2 = fieldIndex("CO2");
            QDateTime lastDt = data(index(0, col)).toDateTime();
            double co2 = data(index(0, col2)).toDouble();
            for (int i = 1; i < rowCount(); ++i)
            {
                QDateTime dt = data(index(i, col)).toDateTime();
                if (dt > lastDt)
                {
                    lastDt = dt;
                    co2 = data(index(i, col2)).toDouble();
                }
            }
            return co2;
        }
    }
    else
    {
        QSqlQuery query("SELECT CO2 FROM " + tableName() + " WHERE SudID = " + QString::number(id) + " ORDER BY Zeitstempel DESC");
        if (query.first())
            return query.value(0).toDouble();
    }
    return 0.0;
}
