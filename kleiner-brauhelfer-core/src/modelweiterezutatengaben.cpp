#include "modelweiterezutatengaben.h"
#include "brauhelfer.h"
#include "modelsud.h"
#include <QDateTime>
#include <cmath>

ModelWeitereZutatenGaben::ModelWeitereZutatenGaben(Brauhelfer* bh) :
    SqlTableModel(bh),
    bh(bh)
{
    additionalFieldNames.append("Abfuellbereit");
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
    if (field == "Abfuellbereit")
    {
        if (data(index.row(), "Zeitpunkt").toInt() == EWZ_Zeitpunkt_Gaerung)
        {
            int Zugabestatus = data(index.row(), "Zugabestatus").toInt();
            int Entnahmeindex = data(index.row(), "Entnahmeindex").toInt();
            if (Zugabestatus == EWZ_Zugabestatus_nichtZugegeben)
              return false;
            if (Zugabestatus == EWZ_Zugabestatus_Zugegeben && Entnahmeindex == EWZ_Entnahmeindex_MitEntnahme)
                return false;
        }
        return true;
    }
    return QVariant();
}

bool ModelWeitereZutatenGaben::setDataExt(const QModelIndex &index, const QVariant &value)
{
    QString field = fieldName(index.column());
    if (field == "Zeitpunkt_von")
    {
        QDateTime dt = value.toDateTime();
        if (QSqlTableModel::setData(index, dt.toString(Qt::ISODate)))
        {
            QModelIndex index2 = this->index(index.row(), fieldIndex("Zeitpunkt_bis"));
            dt = dt.addDays(ceil(data(index.row(), "Zugabedauer").toInt() / 1440.0));
            QSqlTableModel::setData(index2, dt.toString(Qt::ISODate));
            return true;
        }
    }
    if (field == "Zeitpunkt_bis")
    {
        return QSqlTableModel::setData(index, value.toDateTime().toString(Qt::ISODate));
    }
    if (field == "Zugabestatus")
    {
        if (QSqlTableModel::setData(index, value))
        {
            if (value.toInt() == EWZ_Zugabestatus_Entnommen)
            {
                QModelIndex index2 = this->index(index.row(), fieldIndex("Zugabedauer"));
                int day = data(index.row(), "Zeitpunkt_von").toDateTime().daysTo(data(index.row(), "Zeitpunkt_bis").toDateTime());
                QSqlTableModel::setData(index2, day * 1440);
            }
            return true;
        }
    }
    return false;
}
