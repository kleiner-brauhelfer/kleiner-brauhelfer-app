#include "sortfilterproxymodelsud.h"
#include "sqltablemodel.h"

SortFilterProxyModelSud::SortFilterProxyModelSud(QObject *parent) :
    SortFilterProxyModel(parent),
    mColumnBierWurdeGebraut(-1),
    mColumnBierWurdeAbgefuellt(-1),
    mColumnBierWurdeVerbraucht(-1),
    mColumnMerklistenID(-1),
    mFilterMerkliste(false),
    mFilterValue(0)
{
    connect(this, SIGNAL(sourceModelChanged()), this, SLOT(onSourceModelChanged()));
}

SortFilterProxyModelSud::~SortFilterProxyModelSud()
{
}

void SortFilterProxyModelSud::onSourceModelChanged()
{
    if(SqlTableModel* model = dynamic_cast<SqlTableModel*>(sourceModel()))
    {
        mColumnBierWurdeGebraut = model->fieldIndex("BierWurdeGebraut");
        mColumnBierWurdeAbgefuellt = model->fieldIndex("BierWurdeAbgefuellt");
        mColumnBierWurdeVerbraucht = model->fieldIndex("BierWurdeVerbraucht");
        mColumnMerklistenID = model->fieldIndex("MerklistenID");
        setFilterDateColumn(model->fieldIndex("Braudatum"));
    }
}


bool SortFilterProxyModelSud::filterMerkliste() const
{
    return mFilterMerkliste;
}

void SortFilterProxyModelSud::setFilterMerkliste(bool value)
{
    mFilterMerkliste = value;
    invalidateFilter();
    emit filterChanged();
}

int SortFilterProxyModelSud::filterValue() const
{
    return mFilterValue;
}

void SortFilterProxyModelSud::setFilterValue(int value)
{
    mFilterValue = value;
    invalidateFilter();
    emit filterChanged();
}

bool SortFilterProxyModelSud::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    QModelIndex index2;
    bool accept = SortFilterProxyModel::filterAcceptsRow(source_row, source_parent);
    if (accept && mFilterMerkliste)
    {
        index2 = sourceModel()->index(source_row, mColumnMerklistenID, source_parent);
        if (index2.isValid())
            accept = sourceModel()->data(index2).toInt() > 0;
    }
    if (accept && mFilterValue != Alle)
    {
        switch (mFilterValue)
        {
        case NichtGebraut:
            index2 = sourceModel()->index(source_row, mColumnBierWurdeGebraut, source_parent);
            if (index2.isValid())
                accept = sourceModel()->data(index2).toInt() == 0;
        break;
        case Gebraut:
            index2 = sourceModel()->index(source_row, mColumnBierWurdeGebraut, source_parent);
            if (index2.isValid())
                accept = sourceModel()->data(index2).toInt() > 0;
        break;
        case NichtAbgefuellt:
            index2 = sourceModel()->index(source_row, mColumnBierWurdeGebraut, source_parent);
            if (index2.isValid())
            {
                accept = sourceModel()->data(index2).toInt() > 0;
                if (accept)
                {
                    index2 = sourceModel()->index(source_row, mColumnBierWurdeAbgefuellt, source_parent);
                    if (index2.isValid())
                        accept = sourceModel()->data(index2).toInt() == 0;
                }
            }
        break;
        case Abgefuellt:
            index2 = sourceModel()->index(source_row, mColumnBierWurdeGebraut, source_parent);
            if (index2.isValid())
            {
                accept = sourceModel()->data(index2).toInt() > 0;
                if (accept)
                {
                    index2 = sourceModel()->index(source_row, mColumnBierWurdeAbgefuellt, source_parent);
                    if (index2.isValid())
                        accept = sourceModel()->data(index2).toInt() > 0;
                }
            }
        break;
        case NichtVerbraucht:
            index2 = sourceModel()->index(source_row, mColumnBierWurdeGebraut, source_parent);
            if (index2.isValid())
            {
                accept = sourceModel()->data(index2).toInt() > 0;
                if (accept)
                {
                    index2 = sourceModel()->index(source_row, mColumnBierWurdeAbgefuellt, source_parent);
                    if (index2.isValid())
                    {
                        accept = sourceModel()->data(index2).toInt() > 0;
                        if (accept)
                        {
                            index2 = sourceModel()->index(source_row, mColumnBierWurdeVerbraucht, source_parent);
                            if (index2.isValid())
                                accept = sourceModel()->data(index2).toInt() == 0;
                        }
                    }
                }
            }
        break;
        case Verbraucht:
            index2 = sourceModel()->index(source_row, mColumnBierWurdeGebraut, source_parent);
            if (index2.isValid())
            {
                accept = sourceModel()->data(index2).toInt() > 0;
                if (accept)
                {
                    index2 = sourceModel()->index(source_row, mColumnBierWurdeAbgefuellt, source_parent);
                    if (index2.isValid())
                    {
                        accept = sourceModel()->data(index2).toInt() > 0;
                        if (accept)
                        {
                            index2 = sourceModel()->index(source_row, mColumnBierWurdeVerbraucht, source_parent);
                            if (index2.isValid())
                                accept = sourceModel()->data(index2).toInt() > 0;
                        }
                    }
                }
            }
        break;
        }
    }
    return accept;
}
