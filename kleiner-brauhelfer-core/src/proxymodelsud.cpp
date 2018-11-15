#include "proxymodelsud.h"
#include <QSqlQuery>
#include "sqltablemodel.h"

ProxyModelSud::ProxyModelSud(QObject *parent) :
    ProxyModel(parent),
    mColumnId(-1),
    mColumnBierWurdeGebraut(-1),
    mColumnBierWurdeAbgefuellt(-1),
    mColumnBierWurdeVerbraucht(-1),
    mColumnMerklistenID(-1),
    mFilterMerkliste(false),
    mFilterState(Alle),
    mFilterText(QString())
{
    connect(this, SIGNAL(sourceModelChanged()), this, SLOT(onSourceModelChanged()));
}

void ProxyModelSud::onSourceModelChanged()
{
    if(SqlTableModel* model = dynamic_cast<SqlTableModel*>(sourceModel()))
    {
        mColumnId = model->fieldIndex("ID");
        mColumnBierWurdeGebraut = model->fieldIndex("BierWurdeGebraut");
        mColumnBierWurdeAbgefuellt = model->fieldIndex("BierWurdeAbgefuellt");
        mColumnBierWurdeVerbraucht = model->fieldIndex("BierWurdeVerbraucht");
        mColumnMerklistenID = model->fieldIndex("MerklistenID");
        setFilterDateColumn(model->fieldIndex("Braudatum"));
    }
}

bool ProxyModelSud::filterMerkliste() const
{
    return mFilterMerkliste;
}

void ProxyModelSud::setFilterMerkliste(bool value)
{
    mFilterMerkliste = value;
    invalidateFilter();
    emit filterChanged();
}

int ProxyModelSud::filterState() const
{
    return mFilterState;
}

void ProxyModelSud::setFilterState(int state)
{
    mFilterState = state;
    invalidateFilter();
    emit filterChanged();
}

QString ProxyModelSud::filterText() const
{
    return mFilterText;
}

void ProxyModelSud::setFilterText(const QString& text)
{
    mFilterText = text;
    invalidateFilter();
    emit filterChanged();
}

bool ProxyModelSud::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    QModelIndex index2;
    bool accept = ProxyModel::filterAcceptsRow(source_row, source_parent);
    if (accept && mFilterMerkliste)
    {
        index2 = sourceModel()->index(source_row, mColumnMerklistenID, source_parent);
        if (index2.isValid())
            accept = sourceModel()->data(index2).toInt() > 0;
    }
    if (accept && mFilterState != Alle)
    {
        switch (mFilterState)
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
    if (accept && !mFilterText.isEmpty())
    {
        index2 = sourceModel()->index(source_row, mColumnId, source_parent);
        int id = sourceModel()->data(index2).toInt();
        QSqlQuery query;
        query.prepare("SELECT ID FROM Sud WHERE ID=:sudid AND (Sudname LIKE :textFilter \
            OR ID IN (SELECT SudID FROM Malzschuettung WHERE Name LIKE :textFilter) \
            OR ID IN (SELECT SudID FROM Hopfengaben WHERE Name LIKE :textFilter) \
            OR ID IN (SELECT SudID FROM WeitereZutatenGaben WHERE Name LIKE :textFilter) \
            OR AuswahlHefe LIKE :textFilter \
            OR Kommentar LIKE :textFilter)");
        query.bindValue(":sudid", id);
        query.bindValue(":textFilter", "%" + mFilterText + "%");
        if (query.exec())
            accept = query.next();
        else
            accept = false;
    }
    return accept;
}
