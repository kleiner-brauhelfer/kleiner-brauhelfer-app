#include "sudobject.h"
#include "database.h"
#include "brauhelfer.h"
#include "modelsud.h"
#include <QDateTime>

SudObject::SudObject(Brauhelfer *bh) :
    QObject(bh),
    bh(bh),
    id(-1)
{
    connect(modelSud(), SIGNAL(modified()), this, SIGNAL(modified()));
}

void SudObject::load(int id)
{
    if (this->id != id)
    {
        QString strId = QString::number(id);
        bool first = !loaded();
        this->id = id;

        // discard database changes
        bh->discard(true);

        // show information
        bh->message("Load brew with ID: " + strId);

        // select brew tables
        modelSud()->setFilter("ID=" + strId);
        modelRasten()->setFilter("SudID=" + strId);
        modelMalzschuettung()->setFilter("SudID=" + strId);
        modelHopfengaben()->setFilter("SudID=" + strId);
        modelWeitereZutatenGaben()->setFilter("SudID=" + strId);
        modelSchnellgaerverlauf()->setFilter("SudID=" + strId);
        modelHauptgaerverlauf()->setFilter("SudID=" + strId);
        modelNachgaerverlauf()->setFilter("SudID=" + strId);
        modelBewertungen()->setFilter("SudID=" + strId);
        modelAnhang()->setFilter("SudID=" + strId);
        if (first)
            select();
        emit modified();
    }
}

void SudObject::unload()
{
    if (id != -1)
    {
        bh->message("Unload brew: " + QString::number(id));
        bh->discard();
        id = -1;
        emit modified();
    }
}

bool SudObject::loaded() const
{
    return id != -1;
}

void SudObject::select()
{
    bh->message("Select brew tables");
    modelSud()->select();
    modelRasten()->select();
    modelMalzschuettung()->select();
    modelHopfengaben()->select();
    modelWeitereZutatenGaben()->select();
    modelSchnellgaerverlauf()->select();
    modelHauptgaerverlauf()->select();
    modelNachgaerverlauf()->select();
    modelBewertungen()->select();
    modelAnhang()->select();
}

SqlTableModel* SudObject::modelSud() const
{
    return bh->db()->modelSud;
}

SqlTableModel* SudObject::modelRasten() const
{
    return bh->db()->modelRasten;
}

SqlTableModel* SudObject::modelMalzschuettung() const
{
    return bh->db()->modelMalzschuettung;
}

SqlTableModel* SudObject::modelHopfengaben() const
{
    return bh->db()->modelHopfengaben;
}

SqlTableModel* SudObject::modelWeitereZutatenGaben() const
{
 return bh->db()->modelWeitereZutatenGaben;
}

QSortFilterProxyModel *SudObject::modelWeitereZutatenGabenMaischen() const
{
    return bh->db()->modelWeitereZutatenGabenMaischen;
}

QSortFilterProxyModel *SudObject::modelWeitereZutatenGabenKochen() const
{
    return bh->db()->modelWeitereZutatenGabenKochen;
}

QSortFilterProxyModel *SudObject::modelWeitereZutatenGabenGaerung() const
{
    return bh->db()->modelWeitereZutatenGabenGaerung;
}

SqlTableModel* SudObject::modelSchnellgaerverlauf() const
{
    return bh->db()->modelSchnellgaerverlauf;
}

SqlTableModel* SudObject::modelHauptgaerverlauf() const
{
    return bh->db()->modelHauptgaerverlauf;
}

SqlTableModel* SudObject::modelNachgaerverlauf() const
{
    return bh->db()->modelNachgaerverlauf;
}

SqlTableModel* SudObject::modelBewertungen() const
{
    return bh->db()->modelBewertungen;
}

SqlTableModel* SudObject::modelAnhang() const
{
    return bh->db()->modelAnhang;
}

int SudObject::getId() const
{
    return id;
}

QVariant SudObject::getValue(const QString &fieldName) const
{
    return modelSud()->data(0, fieldName);
}

bool SudObject::setValue(const QString &fieldName, const QVariant &value)
{
    return modelSud()->setData(0, fieldName, value);
}

void SudObject::substractBrewIngredients()
{
    int row;
    double quantity;
    SqlTableModel *mList;
    SqlTableModel *mSubstract;

    // Malz
    mList = modelMalzschuettung();
    mSubstract = bh->modelMalz();
    for (int i = 0; i < mList->rowCount(); ++i)
    {
        row = mSubstract->GetRowWithValue("Beschreibung", mList->data(i, "Name").toString());
        if (row != -1)
        {
            quantity = mSubstract->data(row, "Menge").toDouble() - mList->data(i, "erg_Menge").toDouble();
            if (quantity < 0.0)
                quantity = 0.0;
            mSubstract->setData(row, "Menge", quantity);
        }
    }

    // Hopfen
    mList = modelHopfengaben();
    mSubstract = bh->modelHopfen();
    for (int i = 0; i < mList->rowCount(); ++i)
    {
        row = mSubstract->GetRowWithValue("Beschreibung", mList->data(i, "Name").toString());
        if (row != -1)
        {
            quantity = mSubstract->data(row, "Menge").toDouble() - mList->data(i, "erg_Menge").toDouble();
            if (quantity < 0.0)
                quantity = 0.0;
            mSubstract->setData(row, "Menge", quantity);
        }
    }

    // Hefe
    mSubstract = bh->modelHefe();
    row = mSubstract->GetRowWithValue("Beschreibung", getAuswahlHefe());
    if (row != -1)
    {
        quantity = mSubstract->data(row, "Menge").toDouble() - getHefeAnzahlEinheiten();
        if (quantity < 0.0)
            quantity = 0.0;
        mSubstract->setData(row, "Menge", quantity);
    }

    // Weitere Zutaten
    mList = modelWeitereZutatenGaben();
    for (int i = 0; i < mList->rowCount(); ++i)
    {
        if (mList->data(i, "Zeitpunkt").toInt() != EWZ_Zeitpunkt_Gaerung)
        {
            if (mList->data(i, "Typ").toInt() != EWZ_Typ_Hopfen)
            {
                mSubstract = bh->modelWeitereZutaten();
                row = mSubstract->GetRowWithValue("Beschreibung", mList->data(i, "Name").toString());
                if (row != -1)
                {
                    quantity = mSubstract->data(row, "Menge").toDouble();
                    if (mList->data(i, "Einheit").toInt() == EWZ_Einheit_Kg)
                        quantity -= mList->data(i, "erg_Menge").toDouble() / 1000;
                    else
                        quantity -= mList->data(i, "erg_Menge").toDouble();
                    if (quantity < 0.0)
                        quantity = 0.0;
                    mSubstract->setData(row, "Menge", quantity);
                }
            }
            else
            {
                mSubstract = bh->modelHopfen();
                row = mSubstract->GetRowWithValue("Beschreibung", mList->data(i, "Name").toString());
                if (row != -1)
                {
                    quantity = mSubstract->data(row, "Menge").toDouble();
                    if (mList->data(i, "Einheit").toInt() == EWZ_Einheit_Kg)
                        quantity -= mList->data(i, "erg_Menge").toDouble() / 1000;
                    else
                        quantity -= mList->data(i, "erg_Menge").toDouble();
                    if (quantity < 0.0)
                        quantity = 0.0;
                    mSubstract->setData(row, "Menge", quantity);
                }
            }
        }
    }
}

void SudObject::substractIngredient(const QString& ingredient, int type, double quantity)
{
    int row;
    double totalQuantity;
    SqlTableModel *mSubstract;
    if (type == EWZ_Typ_Hopfen)
    {
        mSubstract = bh->modelHopfen();
        row = mSubstract->GetRowWithValue("Beschreibung", ingredient);
        if (row != -1)
        {
            totalQuantity = mSubstract->data(row, "Menge").toDouble() - quantity;
            if (totalQuantity < 0.0)
                totalQuantity = 0.0;
            mSubstract->setData(row, "Menge", totalQuantity);
        }
    }
    else
    {
        mSubstract = bh->modelWeitereZutaten();
        row = mSubstract->GetRowWithValue("Beschreibung", ingredient);
        if (row != -1)
        {
            totalQuantity = mSubstract->data(row, "Menge").toDouble();
            if (mSubstract->data(row, "Einheiten").toInt() == EWZ_Einheit_Kg)
                totalQuantity -= quantity / 1000;
            else
                totalQuantity -= quantity;
            if (totalQuantity < 0.0)
                totalQuantity = 0.0;
            mSubstract->setData(row, "Menge", totalQuantity);
        }
    }
}
