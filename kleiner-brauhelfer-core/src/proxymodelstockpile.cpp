#include "proxymodelstockpile.h"
#include "sqltablemodel.h"

ProxyModelStockpile::ProxyModelStockpile(QObject *parent) :
    ProxyModel(parent),
    mAmountColumn(-1),
    mShowAll(true)
{
    connect(this, SIGNAL(sourceModelChanged()), this, SLOT(onSourceModelChanged()));
}

void ProxyModelStockpile::onSourceModelChanged()
{
    if(SqlTableModel* model = dynamic_cast<SqlTableModel*>(sourceModel()))
    {
        setFilterKeyColumn(model->fieldIndex("Beschreibung"));
        setAmountColumn(model->fieldIndex("Menge"));
        setFilterDateColumn(model->fieldIndex("Braudatum"));
    }
}

int ProxyModelStockpile::amountColumn() const
{
    return mAmountColumn;
}

void ProxyModelStockpile::setAmountColumn(int column)
{
    mAmountColumn = column;
    invalidateFilter();
    emit filterChanged();
}

bool ProxyModelStockpile::showAll() const
{
    return mShowAll;
}

void ProxyModelStockpile::setShowAll(bool value)
{
    mShowAll = value;
    invalidateFilter();
    emit filterChanged();
}

bool ProxyModelStockpile::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    bool accept = QSortFilterProxyModel::filterAcceptsRow(source_row, source_parent);
    if (accept && !mShowAll)
    {
        QModelIndex index = sourceModel()->index(source_row, mAmountColumn, source_parent);
        if (index.isValid())
            accept = sourceModel()->data(index).toDouble() > 0.0;
    }
    return accept;
}
