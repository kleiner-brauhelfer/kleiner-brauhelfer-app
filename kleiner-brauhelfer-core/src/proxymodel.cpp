#include "proxymodel.h"

ProxyModel::ProxyModel(QObject *parent) :
    QSortFilterProxyModel(parent),
    mDateColumn(-1),
    mMinDate(QDateTime()),
    mMaxDate(QDateTime())
{
    setDynamicSortFilter(false);
    setFilterCaseSensitivity(Qt::CaseSensitivity::CaseInsensitive);
}

void ProxyModel::setSourceModel(QAbstractItemModel *sourceModel)
{
    QSortFilterProxyModel::setSourceModel(sourceModel);
    connect(sourceModel, SIGNAL(modelReset()), this, SLOT(onModelReset()));
}

void ProxyModel::onModelReset()
{
    sort(sortColumn(), sortOrder());
    emit sortChanged();
}

int ProxyModel::mapRowToSource(int row) const
{
    QModelIndex index = mapToSource(this->index(row, 0));
    return index.row();
}

int ProxyModel::mapRowFromSource(int row) const
{
    QModelIndex index = mapFromSource(sourceModel()->index(row, 0));
    return index.row();
}

void ProxyModel::setFilterString(const QString &pattern)
{
    setFilterFixedString(pattern);
}

int ProxyModel::sortColumn() const
{
    return QSortFilterProxyModel::sortColumn();
}

void ProxyModel::setSortColumn(int column)
{
    sort(column, sortOrder());
    emit sortChanged();
}

Qt::SortOrder ProxyModel::sortOrder() const
{
    return QSortFilterProxyModel::sortOrder();
}

void ProxyModel::setSortOrder(Qt::SortOrder order)
{
    sort(sortColumn(), order);
    emit sortChanged();
}

int ProxyModel::filterDateColumn() const
{
    return mDateColumn;
}

void ProxyModel::setFilterDateColumn(int column)
{
    mDateColumn = column;
    invalidateFilter();
    emit filterChanged();
}

QDateTime ProxyModel::filterMinimumDate() const
{
    return mMinDate;
}

void ProxyModel::setFilterMinimumDate(const QDateTime &dt)
{
    mMinDate = dt;
    invalidateFilter();
    emit filterChanged();
}

QDateTime ProxyModel::filterMaximumDate() const
{
    return mMaxDate;
}

void ProxyModel::setFilterMaximumDate(const QDateTime &dt)
{
    mMaxDate = dt;
    invalidateFilter();
    emit filterChanged();
}

bool ProxyModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    bool accept = QSortFilterProxyModel::filterAcceptsRow(source_row, source_parent);
    if (accept && mDateColumn >= 0)
    {
        QModelIndex index2 = sourceModel()->index(source_row, mDateColumn, source_parent);
        if (index2.isValid())
            accept = dateInRange(sourceModel()->data(index2).toDateTime());
    }
    return accept;
}

bool ProxyModel::dateInRange(const QDateTime &dt) const
{
    return (!mMinDate.isValid() || dt > mMinDate) && (!mMaxDate.isValid() || dt < mMaxDate);
}
