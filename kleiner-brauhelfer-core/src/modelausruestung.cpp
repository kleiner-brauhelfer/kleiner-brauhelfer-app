#include "modelausruestung.h"
#include "brauhelfer.h"
#include <cmath>
#include <math.h>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

ModelAusruestung::ModelAusruestung(Brauhelfer* bh) :
    SqlTableModel(bh),
    bh(bh)
{
    additionalFieldNames.append("Maischebottich_Volumen");
    additionalFieldNames.append("Maischebottich_MaxFuelvolumen");
    additionalFieldNames.append("Sudpfanne_Volumen");
    additionalFieldNames.append("Sudpfanne_MaxFuelvolumen");
    additionalFieldNames.append("Vermoegen");
}

QVariant ModelAusruestung::dataExt(const QModelIndex &index) const
{
    QString field = fieldName(index.column());
    if (field == "Maischebottich_Volumen")
    {
        double r = data(index.row(), "Maischebottich_Durchmesser").toDouble() / 2;
        double h = data(index.row(), "Maischebottich_Hoehe").toDouble();
        return pow(r, 2) * M_PI * h / 1000;
    }
    if (field == "Maischebottich_MaxFuelvolumen")
    {
        double r = data(index.row(), "Maischebottich_Durchmesser").toDouble() / 2;
        double h = data(index.row(), "Maischebottich_MaxFuellhoehe").toDouble();
        return pow(r, 2) * M_PI * h / 1000;
    }
    if (field == "Sudpfanne_Volumen")
    {
        double r = data(index.row(), "Sudpfanne_Durchmesser").toDouble() / 2;
        double h = data(index.row(), "Sudpfanne_Hoehe").toDouble();
        return pow(r, 2) * M_PI * h / 1000;
    }
    if (field == "Sudpfanne_MaxFuelvolumen")
    {
        double r = data(index.row(), "Sudpfanne_Durchmesser").toDouble() / 2;
        double h = data(index.row(), "Sudpfanne_MaxFuellhoehe").toDouble();
        return pow(r, 2) * M_PI * h / 1000;
    }
    if (field == "Vermoegen")
    {
        double V1 = data(index.row(), "Maischebottich_MaxFuelvolumen").toDouble();
        double V2 = data(index.row(), "Sudpfanne_MaxFuelvolumen").toDouble();
        return (V1 > V2) ? V2 : V1;
    }
    return QVariant();
}

QVariantMap ModelAusruestung::defaultValues() const
{
    QVariantMap values;
    values.insert("AnlagenID", (int)time(nullptr) + rand());
    return values;
}

QString ModelAusruestung::name(int id) const
{
    for (int i = 0; i < rowCount(); ++i)
        if (data(i, "AnlagenID").toInt() == id)
            return data(i, "Name").toString();
    return QString();
}

int ModelAusruestung::id(const QString& name) const
{
    for (int i = 0; i < rowCount(); ++i)
        if (data(i, "Name").toString() == name)
            return data(i, "AnlagenID").toInt();
    return 0;
}
