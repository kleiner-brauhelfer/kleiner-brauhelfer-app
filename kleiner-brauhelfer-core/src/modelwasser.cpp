#include "modelwasser.h"
#include "brauhelfer.h"

ModelWasser::ModelWasser(Brauhelfer* bh) :
    SqlTableModel(bh),
    bh(bh)
{
    additionalFieldNames.append("CalciumMg");
    additionalFieldNames.append("MagnesiumMg");
    additionalFieldNames.append("Calciumhaerte");
    additionalFieldNames.append("Magnesiumhaerte");
    additionalFieldNames.append("Carbonathaerte");
    additionalFieldNames.append("Restalkalitaet");
}

QVariant ModelWasser::dataExt(const QModelIndex &index) const
{
    QString field = fieldName(index.column());
    if (field == "CalciumMg")
    {
        return data(index.row(), "Calcium").toDouble() / 40.8;
    }
    if (field == "MagnesiumMg")
    {
        return data(index.row(), "Magnesium").toDouble() / 24.3;
    }
    if (field == "Calciumhaerte")
    {
        return data(index.row(), "Calcium").toDouble() / 40.8 / 0.1783;
    }
    if (field == "Magnesiumhaerte")
    {
        return data(index.row(), "Magnesium").toDouble() / 24.3 / 0.1783;
    }
    if (field == "Carbonathaerte")
    {
        return data(index.row(), "Saeurekapazitaet").toDouble() * 2.8;
    }
    if (field == "Restalkalitaet")
    {
        double carbh = data(index.row(), "Carbonathaerte").toDouble();
        double calch = data(index.row(), "Calciumhaerte").toDouble();
        double magh = data(index.row(), "Magnesiumhaerte").toDouble();
        return carbh - (calch + 0.5 * magh) / 3.5;
    }
    return QVariant();
}

 bool ModelWasser::setDataExt(const QModelIndex &index, const QVariant &value)
 {
     QString field = fieldName(index.column());
     if (field == "CalciumMg")
     {
         return setData(index.row(), "Calcium", value.toDouble() * 40.8);
     }
     if (field == "MagnesiumMg")
     {
         return setData(index.row(), "Magnesium", value.toDouble() * 24.3);
     }
     if (field == "Calciumhaerte")
     {
         return setData(index.row(), "Calcium", value.toDouble() * 40.8 * 0.1783);
     }
     if (field == "Magnesiumhaerte")
     {
         return setData(index.row(), "Magnesium", value.toDouble() * 24.3 * 0.1783);
     }
     if (field == "Carbonathaerte")
     {
         return setData(index.row(), "Saeurekapazitaet", value.toDouble() / 2.8);
     }
     return false;
 }
