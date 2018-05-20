#include "modelsud.h"
#include "brauhelfer.h"
#include "modelnachgaerverlauf.h"
#include <QSqlQuery>

ModelSud::ModelSud(Brauhelfer *bh, bool globalList) :
    SqlTableModel(bh),
    bh(bh),
    updating(false),
    globalList(globalList),
    swWzMaischen(Q_NULLPTR),
    swWzKochen(Q_NULLPTR),
    swWzGaerung(Q_NULLPTR)
{
    connect(this, SIGNAL(modelReset()), this, SLOT(init()));
    connect(this, SIGNAL(valueChanged(const QModelIndex&, const QVariant&)), this, SLOT(valueChanged(const QModelIndex&, const QVariant&)));
    additionalFieldNames.append("SWIst");
    additionalFieldNames.append("SREIst");
    additionalFieldNames.append("CO2Ist");
    additionalFieldNames.append("Spundungsdruck");
    additionalFieldNames.append("Gruenschlauchzeitpunkt");
    additionalFieldNames.append("SpeiseNoetig");
    additionalFieldNames.append("SpeiseAnteil");
    additionalFieldNames.append("ZuckerAnteil");
    additionalFieldNames.append("ReifezeitDelta");
    additionalFieldNames.append("AbfuellenBereitZutaten");
    additionalFieldNames.append("MengeSollKochbegin");
    additionalFieldNames.append("MengeSollKochende");
    additionalFieldNames.append("SWSollLautern");
    additionalFieldNames.append("SWSollKochbegin");
    additionalFieldNames.append("SWSollKochende");
    additionalFieldNames.append("SWSollAnstellen");
    additionalFieldNames.append("KorrekturWasser");
    additionalFieldNames.append("Verdampfungsziffer");
    additionalFieldNames.append("RestalkalitaetFaktor");
    additionalFieldNames.append("FaktorHauptgussEmpfehlung");
}

ModelSud::~ModelSud()
{
    if (swWzMaischen)
        delete[] swWzMaischen;
    if (swWzKochen)
        delete[] swWzKochen;
    if (swWzGaerung)
        delete[] swWzGaerung;
}

void ModelSud::init()
{
    int rows = rowCount();
    if (swWzMaischen)
        delete[] swWzMaischen;
    swWzMaischen = new double[rows];
    if (swWzKochen)
        delete[] swWzKochen;
    swWzKochen = new double[rows];
    if (swWzGaerung)
        delete[] swWzGaerung;
    swWzGaerung = new double[rows];
    for (int r = 0; r < rows; ++r)
        updateIntermediateValues(r);
}

void ModelSud::updateIntermediateValues(int row)
{
    swWzMaischen[row] = 0.0;
    swWzKochen[row] = 0.0;
    swWzGaerung[row] = 0.0;
    if (globalList)
    {
        QString id = data(row, "ID").toString();
        QSqlQuery query("SELECT Typ, Menge, Ausbeute, Zeitpunkt, Zugabestatus FROM WeitereZutatenGaben WHERE SudID = " + id);
        while (query.next())
        {
            if (query.value("Typ").toInt() != EWZ_Typ_Hopfen)
            {
                double menge = query.value("Menge").toDouble();
                int ausbeute = query.value("Ausbeute").toInt();
                switch (query.value("Zeitpunkt").toInt())
                {
                case EWZ_Zeitpunkt_Gaerung:
                    if (query.value("Zugabestatus").toInt() != EWZ_Zugabestatus_nichtZugegeben)
                        swWzGaerung[row] += menge * ausbeute / 1000;
                    break;
                case EWZ_Zeitpunkt_Kochbeginn:
                    swWzKochen[row] += menge * ausbeute / 1000;
                    break;
                case EWZ_Zeitpunkt_Maischen:
                    swWzMaischen[row] += menge * ausbeute / 1000;
                    break;
                }
            }
        }
    }
    else
    {
        SqlTableModel* model = bh->sud()->modelWeitereZutatenGaben();
        for (int i = 0; i < model->rowCount(); ++i)
        {
            if (model->data(i, "Typ").toInt() != EWZ_Typ_Hopfen)
            {
                double menge = model->data(i, "Menge").toDouble();
                int ausbeute = model->data(i, "Ausbeute").toInt();
                switch (model->data(i, "Zeitpunkt").toInt())
                {
                case EWZ_Zeitpunkt_Gaerung:
                    if (model->data(i, "Zugabestatus").toInt() != EWZ_Zugabestatus_nichtZugegeben)
                        swWzGaerung[row] += menge * ausbeute / 1000;
                    break;
                case EWZ_Zeitpunkt_Kochbeginn:
                    swWzKochen[row] += menge * ausbeute / 1000;
                    break;
                case EWZ_Zeitpunkt_Maischen:
                    swWzMaischen[row] += menge * ausbeute / 1000;
                    break;
                }
            }
        }
    }
}

QVariant ModelSud::dataExt(const QModelIndex &index) const
{
    QString field = fieldName(index.column());
    if (field == "Braudatum")
    {
        return QDateTime::fromString(QSqlTableModel::data(index).toString(), Qt::ISODate);
    }
    if (field == "Anstelldatum")
    {
        return QDateTime::fromString(QSqlTableModel::data(index).toString(), Qt::ISODate);
    }
    if (field == "Abfuelldatum")
    {
        return QDateTime::fromString(QSqlTableModel::data(index).toString(), Qt::ISODate);
    }
    if (field == "Erstellt")
    {
        return QDateTime::fromString(QSqlTableModel::data(index).toString(), Qt::ISODate);
    }
    if (field == "Gespeichert")
    {
        return QDateTime::fromString(QSqlTableModel::data(index).toString(), Qt::ISODate);
    }
    if (field == "SWIst")
    {
        return SWIst(index);
    }
    if (field == "SREIst")
    {
        return SREIst(index);
    }
    if (field == "CO2Ist")
    {
        return CO2Ist(index);
    }
    if (field == "Spundungsdruck")
    {
        return Spundungsdruck(index);
    }
    if (field == "Gruenschlauchzeitpunkt")
    {
        return Gruenschlauchzeitpunkt(index);
    }
    if (field == "SpeiseNoetig")
    {
        return SpeiseNoetig(index);
    }
    if (field == "SpeiseAnteil")
    {
        return SpeiseAnteil(index);
    }
    if (field == "ZuckerAnteil")
    {
        return ZuckerAnteil(index);
    }
    if (field == "ReifezeitDelta")
    {
        return ReifezeitDelta(index);
    }
    if (field == "AbfuellenBereitZutaten")
    {
        return AbfuellenBereitZutaten(index);
    }
    if (field == "MengeSollKochbegin")
    {
        return MengeSollKochbegin(index);
    }
    if (field == "MengeSollKochende")
    {
        return MengeSollKochende(index);
    }
    if (field == "SWSollLautern")
    {
        return SWSollLautern(index);
    }
    if (field == "SWSollKochbegin")
    {
        return SWSollKochbegin(index);
    }
    if (field == "SWSollKochende")
    {
        return SWSollKochende(index);
    }
    if (field == "SWSollAnstellen")
    {
        return SWSollAnstellen(index);
    }
    if (field == "KorrekturWasser")
    {
        return KorrekturWasser(index);
    }
    if (field == "Verdampfungsziffer")
    {
        return Verdampfungsziffer(index);
    }
    if (field == "RestalkalitaetFaktor")
    {
        return RestalkalitaetFaktor(index);
    }
    if (field == "FaktorHauptgussEmpfehlung")
    {
        return FaktorHauptgussEmpfehlung(index);
    }
    return QVariant();
}

bool ModelSud::setDataExt(const QModelIndex &index, const QVariant &value)
{
    QString field = fieldName(index.column());
    if (field == "Braudatum")
    {
        return QSqlTableModel::setData(index, value.toDateTime().toString(Qt::ISODate));
    }
    if (field == "Anstelldatum")
    {
        return QSqlTableModel::setData(index, value.toDateTime().toString(Qt::ISODate));
    }
    if (field == "Abfuelldatum")
    {
        return QSqlTableModel::setData(index, value.toDateTime().toString(Qt::ISODate));
    }
    if (field == "Erstellt")
    {
        return QSqlTableModel::setData(index, value.toDateTime().toString(Qt::ISODate));
    }
    if (field == "Gespeichert")
    {
        return QSqlTableModel::setData(index, value.toDateTime().toString(Qt::ISODate));
    }
    if (field == "erg_AbgefuellteBiermenge")
    {
        if (QSqlTableModel::setData(index, value))
        {
            if (!updating)
            {
                double speise = data(index.row(), "SpeiseAnteil").toDouble() / 1000;
                double jungbiermenge = data(index.row(), "JungbiermengeAbfuellen").toDouble();
                if (jungbiermenge > 0.0)
                    QSqlTableModel::setData(this->index(index.row(), fieldIndex("JungbiermengeAbfuellen")), value.toDouble() / (1 + speise / jungbiermenge));
                else
                    QSqlTableModel::setData(this->index(index.row(), fieldIndex("JungbiermengeAbfuellen")), value.toDouble() - speise);
            }
            return true;
        }
    }
    return false;
}

void ModelSud::valueChanged(const QModelIndex &index, const QVariant &value)
{
    Q_UNUSED(value);

    if (updating)
        return;
    updating = true;

    // update intermediate values
    updateIntermediateValues(index.row());

    // erg_WHauptguss
    double schuet = data(index.row(), "erg_S_Gesammt").toDouble();
    double fac = data(index.row(), "FaktorHauptguss").toDouble();
    setData(index.row(), "erg_WHauptguss", schuet * fac);

    // erg_WNachguss
    double hg = data(index.row(), "erg_WHauptguss").toDouble();
    double KorrekturWasser = data(index.row(), "KorrekturWasser").toDouble();
    double menge = data(index.row(), "MengeSollKochbegin").toDouble();
    setData(index.row(), "erg_WNachguss", menge + schuet * 0.96 - hg + KorrekturWasser);

    // erg_W_Gesammt
    double ng = data(index.row(), "erg_WNachguss").toDouble();
    setData(index.row(), "erg_W_Gesammt", hg + ng);

    // erg_Sudhausausbeute
    double sw = data(index.row(), "SWKochende").toDouble();
    menge = data(index.row(), "WuerzemengeKochende").toDouble();
    setData(index.row(), "erg_Sudhausausbeute", BierCalc::sudhausausbeute(sw - swWzMaischen[index.row()] - swWzKochen[index.row()], menge, schuet));

    // erg_EffektiveAusbeute
    double hgf = 1 + data(index.row(), "highGravityFaktor").toDouble() / 100;
    sw = data(index.row(), "SWAnstellen").toDouble();
    menge = data(index.row(), "WuerzemengeAnstellen").toDouble() + data(index.row(), "Speisemenge").toDouble();
    setData(index.row(), "erg_EffektiveAusbeute", BierCalc::sudhausausbeute(sw * hgf - swWzMaischen[index.row()] - swWzKochen[index.row()], menge/hgf, schuet));

    // erg_Alkohol
    double sre = data(index.row(), "SREIst").toDouble();
    sw = data(index.row(), "SWAnstellen").toDouble();
    sw += swWzGaerung[index.row()];
    menge = data(index.row(), "WuerzemengeAnstellen").toDouble();
    if (menge > 0.0)
        sw += (data(index.row(), "ZuckerAnteil").toDouble() / 10) / menge;
    setData(index.row(), "erg_Alkohol", BierCalc::alkohol(sw, sre));

    // erg_AbgefuellteBiermenge
    double jungbier = data(index.row(), "JungbiermengeAbfuellen").toDouble();
    double speise = data(index.row(), "SpeiseAnteil").toDouble() / 1000;
    setData(index.row(), "erg_AbgefuellteBiermenge", jungbier + speise);

    // erg_Preis (todo: support globalList)
    if (!globalList)
        setData(index.row(), "erg_Preis", erg_Preis(index).toDouble());

    updating = false;
}

QVariant ModelSud::erg_Preis(const QModelIndex &index) const
{
    SqlTableModel *model, *modelAll;
    double summe = 0.0;
    bool KostenrechnungIO = true;

    double kg;
    double preis = 0;
    QString s;
    int z;
    int gefunden;

    double kostenSchuettung = 0.0;
    model = bh->sud()->modelMalzschuettung();
    modelAll = bh->modelMalz();
    z = 0;
    gefunden = 0;
    for (int o = 0; o < model->rowCount(); ++o)
    {
        s = model->data(o, "Name").toString();
        if (s != "")
        {
            kg = model->data(o, "erg_Menge").toDouble();
            for (int i = 0; i < modelAll->rowCount(); ++i)
            {
                if (s == modelAll->data(i, "Beschreibung").toString())
                {
                    preis = modelAll->data(i, "Preis").toDouble();
                    kostenSchuettung += preis * kg;
                    gefunden++;
                }
            }
            z++;
        }
    }
    if (z != gefunden)
        KostenrechnungIO = false;
    summe += kostenSchuettung;

    double kostenHopfen = 0.0;
    model = bh->sud()->modelHopfengaben();
    modelAll = bh->modelHopfen();
    z = 0;
    gefunden = 0;
    for (int o = 0; o < model->rowCount(); ++o)
    {
        s = model->data(o, "Name").toString();
        if (s != "")
        {
            kg = model->data(o, "erg_Menge").toDouble() / 1000;
            for (int i = 0; i < modelAll->rowCount(); ++i)
            {
                if (s == modelAll->data(i, "Beschreibung").toString())
                {
                    preis = modelAll->data(i, "Preis").toDouble();
                    kostenHopfen += preis * kg;
                    gefunden++;
                }
            }
            z++;
        }
    }
    if (z != gefunden)
        KostenrechnungIO = false;
    summe += kostenHopfen;


    double kostenHefe = 0.0;
    modelAll = bh->modelHefe();
    int anzahl = 0;
    gefunden = 0;
    s = data(index.row(), "AuswahlHefe").toString();
    if (s != "")
    {
        for (int i = 0; i < modelAll->rowCount(); ++i)
        {
            if (s == modelAll->data(i, "Beschreibung").toString())
            {
                preis = modelAll->data(i, "Preis").toDouble();
                anzahl = data(index.row(), "HefeAnzahlEinheiten").toInt();
                gefunden++;
                break;
            }
        }
    }
    if (gefunden == 0)
        KostenrechnungIO = false;
    else
        kostenHefe += preis * anzahl;

    summe += kostenHefe;


    //Kosten der Weiteren Zutaten
    double kostenWeitereZutaten = 0.0;
    model = bh->sud()->modelWeitereZutatenGaben();
    for (int o = 0; o < model->rowCount(); ++o)
    {
        s = model->data(o, "Name").toString();
        if (s != "")
        {
            kg = model->data(o, "erg_Menge").toDouble() / 1000;
            if (model->data(o, "Typ").toInt() == EWZ_Typ_Hopfen)
                modelAll = bh->modelHopfen();
            else
                modelAll = bh->modelWeitereZutaten();
            for (int i = 0; i < modelAll->rowCount(); ++i)
            {
                if (s == modelAll->data(i, "Beschreibung").toString())
                {
                    preis = modelAll->data(i, "Preis").toDouble();
                    kostenWeitereZutaten += preis * kg;
                    gefunden++;
                }
            }
            z++;
        }
    }
    summe += kostenWeitereZutaten;

    double kostenSonstiges = data(index.row(), "KostenWasserStrom").toDouble();
    summe += kostenSonstiges;

    double kostenAnlage = 0.0;
    int id = data(index.row(), "AuswahlBrauanlage").toInt();
    modelAll = bh->modelAusruestung();
    for (int i = 0; i < modelAll->rowCount(); ++i)
    {
        if (id == modelAll->data(i, "AnlagenID").toInt())
        {
          kostenAnlage = modelAll->data(i, "Kosten").toDouble();
          break;
        }
    }

    summe += kostenAnlage;

    if (KostenrechnungIO)
    {
        return summe / data(index.row(), "erg_AbgefuellteBiermenge").toDouble();
    }
    else
    {
        return 0.0;
    }
    return summe;
}

QVariant ModelSud::SWIst(const QModelIndex &index) const
{
    if (data(index.row(), "BierWurdeGebraut").toBool())
        return data(index.row(), "SWAnstellen").toDouble() + swWzGaerung[index.row()];
    return 0.0;
}

QVariant ModelSud::SREIst(const QModelIndex &index) const
{
    if (data(index.row(), "SchnellgaerprobeAktiv").toBool())
        return data(index.row(), "SWSchnellgaerprobe").toDouble();
    else
        return data(index.row(), "SWJungbier").toDouble();
}

QVariant ModelSud::CO2Ist(const QModelIndex &index) const
{
    if (globalList)
        return ((ModelNachgaerverlauf*)bh->sud()->modelNachgaerverlauf())->getLastCO2(data(index.row(), "ID").toString());
    else
        return ((ModelNachgaerverlauf*)bh->sud()->modelNachgaerverlauf())->getLastCO2();
}

QVariant ModelSud::Spundungsdruck(const QModelIndex &index) const
{
    double co2 = data(index.row(), "CO2").toDouble();
    double T = data(index.row(), "TemperaturJungbier").toDouble();
    return BierCalc::spundungsdruck(co2, T);
}

QVariant ModelSud::Gruenschlauchzeitpunkt(const QModelIndex &index) const
{
    double co2Soll = data(index.row(), "CO2").toDouble();
    double sw = data(index.row(), "SWIst").toDouble();
    double T = data(index.row(), "TemperaturJungbier").toDouble();
    double sre = data(index.row(), "SREIst").toDouble();
    return BierCalc::gruenschlauchzeitpunkt(co2Soll, sw, sre, T);
}

QVariant ModelSud::SpeiseNoetig(const QModelIndex &index) const
{
    double co2Soll = data(index.row(), "CO2").toDouble();
    double sw = data(index.row(), "SWIst").toDouble();
    double sreJungbier = data(index.row(), "SWJungbier").toDouble();
    double T = data(index.row(), "TemperaturJungbier").toDouble();
    double sreSchnellgaerprobe = data(index.row(), "SREIst").toDouble();
    double jungbiermenge = data(index.row(), "JungbiermengeAbfuellen").toDouble();
    return BierCalc::speise(co2Soll, sw, sreSchnellgaerprobe, sreJungbier, T) * jungbiermenge * 1000;
}

QVariant ModelSud::SpeiseAnteil(const QModelIndex &index) const
{
    if (data(index.row(), "Spunden").toBool())
        return 0.0;
    double speiseVerfuegbar = data(index.row(), "Speisemenge").toDouble() * 1000;
    double speise = SpeiseNoetig(index).toDouble();
    if (speise > speiseVerfuegbar)
        speise = speiseVerfuegbar;
    return speise;
}

QVariant ModelSud::ZuckerAnteil(const QModelIndex &index) const
{
    if (data(index.row(), "Spunden").toBool())
        return 0.0;
    double speiseVerfuegbar = data(index.row(), "Speisemenge").toDouble() * 1000;
    double sw = data(index.row(), "SWIst").toDouble();
    double sre = data(index.row(), "SREIst").toDouble();
    double speise = SpeiseNoetig(index).toDouble() - speiseVerfuegbar;
    if (speise <= 0.0)
        return 0.0;
    return BierCalc::speiseToZucker(sw, sre, speise);
}

QVariant ModelSud::ReifezeitDelta(const QModelIndex &index) const
{
    if (data(index.row(), "BierWurdeAbgefuellt").toBool())
    {
        QDateTime dt;
        if (globalList)
            dt = ((ModelNachgaerverlauf*)bh->sud()->modelNachgaerverlauf())->getLastDateTime(data(index.row(), "ID").toString());
        else
            dt = ((ModelNachgaerverlauf*)bh->sud()->modelNachgaerverlauf())->getLastDateTime();
        int tageReifung = dt.daysTo(QDateTime::currentDateTime());
        int tageReifungSoll = data(index.row(), "Reifezeit").toInt() * 7;
        return tageReifungSoll - tageReifung;
    }
    return 0;
}

QVariant ModelSud::AbfuellenBereitZutaten(const QModelIndex &index) const
{
    if (globalList)
    {
        QString id = data(index.row(), "ID").toString();
        QSqlQuery query("SELECT Zugabestatus, Entnahmeindex FROM WeitereZutatenGaben WHERE SudID = " + id + " AND Zeitpunkt=" + QString::number(EWZ_Zeitpunkt_Gaerung));
        while (query.next())
        {
            int Zugabestatus = query.value("Zugabestatus").toInt();
            int Entnahmeindex = query.value("Entnahmeindex").toInt();
            if (Zugabestatus == EWZ_Zugabestatus_nichtZugegeben)
              return false;
            if (Zugabestatus == EWZ_Zugabestatus_Zugegeben && Entnahmeindex == EWZ_Entnahmeindex_MitEntnahme)
                return false;
        }
    }
    else
    {
        SqlTableModel* model = bh->sud()->modelWeitereZutatenGaben();
        for (int i = 0; i < model->rowCount(); ++i)
            if (!model->data(i, "Abfuellbereit").toBool())
                return false;
    }
    return true;
}

QVariant ModelSud::MengeSollKochbegin(const QModelIndex &index) const
{
    double mengeSollKochEnde = data(index.row(), "MengeSollKochende").toDouble();
    double kochdauer = data(index.row(), "KochdauerNachBitterhopfung").toDouble();
    double verdampfungsziffer = data(index.row(), "Verdampfungsziffer").toDouble();
    return mengeSollKochEnde * (1 + (verdampfungsziffer * kochdauer / (60 * 100)));
}

QVariant ModelSud::MengeSollKochende(const QModelIndex &index) const
{
    double mengeSoll = data(index.row(), "Menge").toDouble();
    double hgf = 1 + data(index.row(), "highGravityFaktor").toDouble() / 100;
    return mengeSoll / hgf;
}

QVariant ModelSud::SWSollLautern(const QModelIndex &index) const
{
    double swSoll = data(index.row(), "SW").toDouble();
    double hgf = 1 + data(index.row(), "highGravityFaktor").toDouble() / 100;
    double sw = (swSoll - swWzKochen[index.row()] - swWzGaerung[index.row()]) * hgf;
    double menge = data(index.row(), "Menge").toDouble();
    double mengeKochbegin = data(index.row(), "MengeSollKochbegin").toDouble();
    return sw * menge / mengeKochbegin;
}

QVariant ModelSud::SWSollKochbegin(const QModelIndex &index) const
{
    double sw = data(index.row(), "SWSollKochende").toDouble();
    double menge = data(index.row(), "Menge").toDouble();
    double mengeKochbegin = data(index.row(), "MengeSollKochbegin").toDouble();
    return sw * menge / mengeKochbegin;
}

QVariant ModelSud::SWSollKochende(const QModelIndex &index) const
{
    double sw = data(index.row(), "SWSollAnstellen").toDouble();
    double hgf = 1 + data(index.row(), "highGravityFaktor").toDouble() / 100;
    return sw * hgf;
}

QVariant ModelSud::SWSollAnstellen(const QModelIndex &index) const
{
    double sw = data(index.row(), "SW").toDouble();
    return sw - swWzGaerung[index.row()];
}

QVariant ModelSud::KorrekturWasser(const QModelIndex &index) const
{
    int anlage = data(index.row(), "AuswahlBrauanlage").toInt();
    SqlTableModel* model = bh->modelAusruestung();
    int col = model->fieldIndex("AnlagenID");
    for (int i = 0; i < model->rowCount(); ++i)
        if (model->data(model->index(i, col)).toInt() == anlage)
            return model->data(i, "KorrekturWasser").toDouble();
    return 0.0;
}

QVariant ModelSud::Verdampfungsziffer(const QModelIndex &index) const
{
    int anlage = data(index.row(), "AuswahlBrauanlage").toInt();
    SqlTableModel* model = bh->modelAusruestung();
    int col = model->fieldIndex("AnlagenID");
    for (int i = 0; i < model->rowCount(); ++i)
        if (model->data(model->index(i, col)).toInt() == anlage)
            return model->data(i, "Verdampfungsziffer").toDouble();
    return 0.0;
}

QVariant ModelSud::RestalkalitaetFaktor(const QModelIndex &index) const
{
    double ist = bh->modelWasser()->data(0, "Restalkalitaet").toDouble();
    double soll = data(index.row(), "RestalkalitaetSoll").toDouble();
    double fac = (ist -  soll) * 0.033333333;
    if (fac < 0.0)
        fac = 0.0;
    return fac;
}

QVariant ModelSud::FaktorHauptgussEmpfehlung(const QModelIndex &index) const
{
    double ebc = data(index.row(), "erg_Farbe").toDouble();
    if (ebc < 50)
        return 4.0 - ebc * 0.02;
    else
        return 3.0;
}
