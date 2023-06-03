#include "proxymodelsud.h"
#include "brauhelfer.h"
#include "modelsud.h"

ProxyModelSud::ProxyModelSud(QObject *parent) :
    ProxyModel(parent),
    mFilterMerkliste(false),
    mFilterStatus(Alle),
    mMinDate(QDateTime()),
    mMaxDate(QDateTime()),
    mFilterText(QString())
{
}

bool ProxyModelSud::filterMerkliste() const
{
    return mFilterMerkliste;
}

void ProxyModelSud::setFilterMerkliste(bool value)
{
    if (mFilterMerkliste != value)
    {
        mFilterMerkliste = value;
        invalidate();
    }
}

ProxyModelSud::FilterStatus ProxyModelSud::filterStatus() const
{
    return mFilterStatus;
}

void ProxyModelSud::setFilterStatus(FilterStatus status)
{
    if (mFilterStatus != status)
    {
        mFilterStatus = status;
        invalidate();
    }
}

QDateTime ProxyModelSud::filterMinimumDate() const
{
    return mMinDate;
}

void ProxyModelSud::setFilterMinimumDate(const QDateTime &dt)
{
    if (mMinDate != dt)
    {
        mMinDate = dt;
        invalidate();
    }
}

QDateTime ProxyModelSud::filterMaximumDate() const
{
    return mMaxDate;
}

void ProxyModelSud::setFilterMaximumDate(const QDateTime &dt)
{
    if (mMaxDate != dt)
    {
        mMaxDate = dt;
        invalidate();
    }
}

void ProxyModelSud::setFilterDate(const QDateTime &min, const QDateTime &max)
{
    mMinDate = min;
    mMaxDate = max;
    invalidate();
}

QString ProxyModelSud::filterText() const
{
    return mFilterText;
}

void ProxyModelSud::setFilterText(const QString& text)
{
    if (mFilterText != text)
    {
        mFilterText = text;
        invalidate();
    }
}

bool ProxyModelSud::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    QModelIndex idx;
    bool accept = ProxyModel::filterAcceptsRow(source_row, source_parent);
    if (accept && mFilterMerkliste)
    {
        idx = sourceModel()->index(source_row, ModelSud::ColMerklistenID, source_parent);
        if (idx.isValid())
            accept = sourceModel()->data(idx).toInt() > 0;
    }
    if (accept && mFilterStatus != Alle)
    {
        idx = sourceModel()->index(source_row, ModelSud::ColStatus, source_parent);
        if (idx.isValid())
        {
            Brauhelfer::SudStatus status = static_cast<Brauhelfer::SudStatus>(idx.data().toInt());
            switch (status)
            {
            case Brauhelfer::SudStatus::Rezept:
                accept = mFilterStatus & Rezept;
                break;
            case Brauhelfer::SudStatus::Gebraut:
                accept = mFilterStatus & Gebraut;
                break;
            case Brauhelfer::SudStatus::Abgefuellt:
                accept = mFilterStatus & Abgefuellt;
                break;
            case Brauhelfer::SudStatus::Verbraucht:
                accept = mFilterStatus & Verbraucht;
                break;
            }
        }
    }
    if (accept && (mMinDate.isValid() || mMaxDate.isValid()))
    {
        idx = sourceModel()->index(source_row, ModelSud::ColBraudatum, source_parent);
        if (idx.isValid())
            accept = dateInRange(sourceModel()->data(idx).toDateTime());
    }
    if (accept && !mFilterText.isEmpty())
    {
        QRegularExpression rx(QRegularExpression::escape(mFilterText), QRegularExpression::CaseInsensitiveOption);
        idx = sourceModel()->index(source_row, ModelSud::ColSudname, source_parent);
        accept = sourceModel()->data(idx).toString().contains(rx);
        if (!accept)
        {
            idx = sourceModel()->index(source_row, ModelSud::ColKategorie, source_parent);
            accept = sourceModel()->data(idx).toString().contains(rx);
        }
        if (!accept)
        {
            idx = sourceModel()->index(source_row, ModelSud::ColKommentar, source_parent);
            accept = sourceModel()->data(idx).toString().contains(rx);
        }
        if (!accept)
        {
            ModelSud* modelSud = qobject_cast<ModelSud*>(sourceModel());
            if (modelSud)
            {
                idx = sourceModel()->index(source_row, ModelSud::ColID, source_parent);
                QRegularExpression sudReg(QStringLiteral("^%1$").arg(sourceModel()->data(idx).toInt()));

                ProxyModel modelMalzschuettung;
                modelMalzschuettung.setSourceModel(modelSud->bh->modelMalzschuettung());
                modelMalzschuettung.setFilterKeyColumn(ModelMalzschuettung::ColSudID);
                modelMalzschuettung.setFilterRegularExpression(sudReg);
                for (int i = 0; i < modelMalzschuettung.rowCount(); i++)
                {
                    QString name = modelMalzschuettung.index(i, ModelMalzschuettung::ColName).data().toString();
                    accept = name.contains(rx);
                    if (accept)
                        break;
                }
                if (!accept)
                {
                    ProxyModel modelHopfengaben;
                    modelHopfengaben.setSourceModel(modelSud->bh->modelHopfengaben());
                    modelHopfengaben.setFilterKeyColumn(ModelHopfengaben::ColSudID);
                    modelHopfengaben.setFilterRegularExpression(sudReg);
                    for (int i = 0; i < modelHopfengaben.rowCount(); i++)
                    {
                        QString name = modelHopfengaben.index(i, ModelHopfengaben::ColName).data().toString();
                        accept = name.contains(rx);
                        if (accept)
                            break;
                    }
                }
                if (!accept)
                {
                    ProxyModel modelHefegaben;
                    modelHefegaben.setSourceModel(modelSud->bh->modelHefegaben());
                    modelHefegaben.setFilterKeyColumn(ModelHefegaben::ColSudID);
                    modelHefegaben.setFilterRegularExpression(sudReg);
                    for (int i = 0; i < modelHefegaben.rowCount(); i++)
                    {
                        QString name = modelHefegaben.index(i, ModelHefegaben::ColName).data().toString();
                        accept = name.contains(rx);
                        if (accept)
                            break;
                    }
                }
                if (!accept)
                {
                    ProxyModel modelWeitereZutatenGaben;
                    modelWeitereZutatenGaben.setSourceModel(modelSud->bh->modelWeitereZutatenGaben());
                    modelWeitereZutatenGaben.setFilterKeyColumn(ModelWeitereZutatenGaben::ColSudID);
                    modelWeitereZutatenGaben.setFilterRegularExpression(sudReg);
                    for (int i = 0; i < modelWeitereZutatenGaben.rowCount(); i++)
                    {
                        QString name = modelWeitereZutatenGaben.index(i, ModelWeitereZutatenGaben::ColName).data().toString();
                        accept = name.contains(rx);
                        if (accept)
                            break;

                    }
                }
                if (!accept)
                {
                    ProxyModel modelTags;
                    modelTags.setSourceModel(modelSud->bh->modelTags());
                    modelTags.setFilterKeyColumn(ModelTags::ColSudID);
                    modelTags.setFilterRegularExpression(QStringLiteral("^(%1|-.*)$").arg(sourceModel()->data(idx).toInt()));
                    for (int i = 0; i < modelTags.rowCount(); i++)
                    {
                        QString text = modelTags.index(i, ModelTags::ColKey).data().toString();
                        accept = text.contains(rx);
                        if (accept)
                            break;
                        text = modelTags.index(i, ModelTags::ColValue).data().toString();
                        accept = text.contains(rx);
                        if (accept)
                            break;
                    }
                }
            }
        }
    }
    return accept;
}

bool ProxyModelSud::dateInRange(const QDateTime &dt) const
{
    return (!mMinDate.isValid() || dt >= mMinDate) && (!mMaxDate.isValid() || dt <= mMaxDate);
}
