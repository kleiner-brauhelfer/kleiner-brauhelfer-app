#include "sortfilterproxymodel.h"

SortFilterProxyModel::SortFilterProxyModel(QObject *parent) :
    QSortFilterProxyModel(parent),
    mDateColumn(-1),
    mMinDate(QDateTime()),
    mMaxDate(QDateTime())
{
    setDynamicSortFilter(false);
}

SortFilterProxyModel::~SortFilterProxyModel()
{
}

void SortFilterProxyModel::setSourceModel(QAbstractItemModel *sourceModel)
{
    QSortFilterProxyModel::setSourceModel(sourceModel);
    connect(sourceModel, SIGNAL(modelReset()), this, SLOT(onModelReset()));
}

void SortFilterProxyModel::onModelReset()
{
    sort(sortColumn(), sortOrder());
    emit sortChanged();
}

int SortFilterProxyModel::sortColumn() const
{
    return QSortFilterProxyModel::sortColumn();
}

void SortFilterProxyModel::setSortColumn(int column)
{
    sort(column, sortOrder());
    emit sortChanged();
}

Qt::SortOrder SortFilterProxyModel::sortOrder() const
{
    return QSortFilterProxyModel::sortOrder();
}

void SortFilterProxyModel::setSortOrder(Qt::SortOrder order)
{
    sort(sortColumn(), order);
    emit sortChanged();
}

int SortFilterProxyModel::filterDateColumn() const
{
    return mDateColumn;
}

void SortFilterProxyModel::setFilterDateColumn(int column)
{
    mDateColumn = column;
    invalidateFilter();
    emit filterChanged();
}

QDateTime SortFilterProxyModel::filterMinimumDate() const
{
    return mMinDate;
}

void SortFilterProxyModel::setFilterMinimumDate(const QDateTime &dt)
{
    mMinDate = dt;
    invalidateFilter();
    emit filterChanged();
}

QDateTime SortFilterProxyModel::filterMaximumDate() const
{
    return mMaxDate;
}

void SortFilterProxyModel::setFilterMaximumDate(const QDateTime &dt)
{
    mMaxDate = dt;
    invalidateFilter();
    emit filterChanged();
}

bool SortFilterProxyModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
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

bool SortFilterProxyModel::dateInRange(const QDateTime &dt) const
{
    return (!mMinDate.isValid() || dt > mMinDate) && (!mMaxDate.isValid() || dt < mMaxDate);
}
