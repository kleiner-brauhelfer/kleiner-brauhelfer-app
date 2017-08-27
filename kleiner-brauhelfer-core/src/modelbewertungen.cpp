#include "modelbewertungen.h"
#include "brauhelfer.h"
#include "modelnachgaerverlauf.h"

ModelBewertungen::ModelBewertungen(Brauhelfer* bh) :
    SqlTableModel(bh),
    bh(bh)
{
}

QVariant ModelBewertungen::dataExt(const QModelIndex &index) const
{
    QString field = fieldName(index.column());
    if (field == "Datum")
    {
        return QDateTime::fromString(QSqlTableModel::data(index).toString(), Qt::ISODate);
    }
    if (field == "Woche")
    {
        QDateTime dt = ((ModelNachgaerverlauf*)bh->sud()->modelNachgaerverlauf())->getLastDateTime();
        int days = dt.daysTo(data(index.row(), "Datum").toDateTime());
        if (days > 0)
            return days / 7 + 1;
        else
            return 0;

    }
    return QVariant();
}

bool ModelBewertungen::setDataExt(const QModelIndex &index, const QVariant &value)
{
    QString field = fieldName(index.column());
    if (field == "Datum")
    {
        if (QSqlTableModel::setData(index, value.toDateTime().toString(Qt::ISODate)))
        {
            QModelIndex index2 = this->index(index.row(), fieldIndex("Woche"));
            QSqlTableModel::setData(index2, dataExt(index2));
            return true;
        }
    }
    return false;
}

QVariantMap ModelBewertungen::defaultValues() const
{
    QVariantMap values;
    values.insert("SudID", bh->sud()->getId());
    values.insert("Datum", QDateTime::currentDateTime());
    values.insert("Sterne", 0);
    return values;
}
