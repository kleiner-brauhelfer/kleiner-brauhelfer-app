#include "sortfilterproxymodel.h"

SortFilterProxyModel::SortFilterProxyModel(QObject *parent) :
    QSortFilterProxyModel(parent)
{
    setDynamicSortFilter(false);
}

SortFilterProxyModel::~SortFilterProxyModel()
{
}
