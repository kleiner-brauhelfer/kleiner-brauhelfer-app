#include "proxymodel.h"
#include "sqltablemodel.h"

ProxyModel::ProxyModel(QObject *parent) :
    QSortFilterProxyModel(parent),
    mDeletedColumn(-1),
    mDateColumn(-1),
    mMinDate(QDateTime()),
    mMaxDate(QDateTime())
{
    setDynamicSortFilter(false);
    setFilterCaseSensitivity(Qt::CaseSensitivity::CaseInsensitive);
    setSortCaseSensitivity(Qt::CaseSensitivity::CaseInsensitive);
}

void ProxyModel::setSourceModel(QAbstractItemModel *model)
{
    QAbstractItemModel *prevModel = sourceModel();
    if (prevModel)
    {
        disconnect(prevModel, SIGNAL(modelReset()), this, SLOT(invalidate()));
        disconnect(prevModel, SIGNAL(modified()), this, SIGNAL(modified()));
    }

    QSortFilterProxyModel::setSourceModel(model);
    if(SqlTableModel* m = dynamic_cast<SqlTableModel*>(model))
    {
        mDeletedColumn = m->fieldIndex("deleted");
        connect(model, SIGNAL(modified()), this, SIGNAL(modified()));
    }
    else if(ProxyModel* m = dynamic_cast<ProxyModel*>(model))
    {
        mDeletedColumn = m->fieldIndex("deleted");
        connect(model, SIGNAL(modified()), this, SIGNAL(modified()));
    }
    else
    {
        mDeletedColumn = -1;
    }
    connect(model, SIGNAL(modelReset()), this, SLOT(invalidate()));
}

QVariant ProxyModel::data(int row, int col, int role) const
{
    return data(index(row, col), role);
}

bool ProxyModel::setData(int row, int col, const QVariant &value, int role)
{
    return setData(index(row, col), value, role);
}

bool ProxyModel::removeRows(int row, int count, const QModelIndex &parent)
{
    if (QSortFilterProxyModel::removeRows(row, count, parent))
    {
        invalidate();
        return true;
    }
    return false;
}

bool ProxyModel::removeRow(int arow, const QModelIndex &parent)
{
    if (QSortFilterProxyModel::removeRow(arow, parent))
    {
        invalidate();
        return true;
    }
    return false;
}

int ProxyModel::append(const QMap<int, QVariant> &values)
{
    SqlTableModel* model = dynamic_cast<SqlTableModel*>(sourceModel());
    if (model)
    {
        int idx = model->append(values);
        invalidate();
        return mapRowFromSource(idx);
    }
    ProxyModel* proxyModel = dynamic_cast<ProxyModel*>(sourceModel());
    if (proxyModel)
    {
        int idx = proxyModel->append(values);
        invalidate();
        return mapRowFromSource(idx);
    }
    return -1;
}

int ProxyModel::append(const QVariantMap &values)
{
    SqlTableModel* model = dynamic_cast<SqlTableModel*>(sourceModel());
    if (model)
    {
        int idx = model->append(values);
        invalidate();
        return mapRowFromSource(idx);
    }
    ProxyModel* proxyModel = dynamic_cast<ProxyModel*>(sourceModel());
    if (proxyModel)
    {
        int idx = proxyModel->append(values);
        invalidate();
        return mapRowFromSource(idx);
    }
    return -1;
}

bool ProxyModel::swap(int row1, int row2)
{
    SqlTableModel* model = dynamic_cast<SqlTableModel*>(sourceModel());
    if (model)
    {
        bool ret = model->swap(mapRowToSource(row1), mapRowToSource(row2));
        invalidate();
        return ret;
    }
    ProxyModel* proxyModel = dynamic_cast<ProxyModel*>(sourceModel());
    if (proxyModel)
    {
        bool ret = proxyModel->swap(mapRowToSource(row1), mapRowToSource(row2));
        invalidate();
        return ret;
    }
    return false;
}

int ProxyModel::mapRowToSource(int row) const
{
    QModelIndex idx = mapToSource(index(row, 0));
    return idx.row();
}

int ProxyModel::mapRowFromSource(int row) const
{
    QModelIndex index = mapFromSource(sourceModel()->index(row, 0));
    return index.row();
}

int ProxyModel::fieldIndex(const QString &fieldName) const
{
    SqlTableModel* model = dynamic_cast<SqlTableModel*>(sourceModel());
    if (model)
        return model->fieldIndex(fieldName);
    ProxyModel* proxyModel = dynamic_cast<ProxyModel*>(sourceModel());
    if (proxyModel)
        return proxyModel->fieldIndex(fieldName);
    return -1;
}

int ProxyModel::getRowWithValue(int col, const QVariant &value)
{
    SqlTableModel* model = dynamic_cast<SqlTableModel*>(sourceModel());
    if (model)
        return mapRowFromSource(model->getRowWithValue(col, value));
    ProxyModel* proxyModel = dynamic_cast<ProxyModel*>(sourceModel());
    if (proxyModel)
        return mapRowFromSource(proxyModel->getRowWithValue(col, value));
    return -1;
}

QVariant ProxyModel::getValueFromSameRow(int colKey, const QVariant &valueKey, int col)
{
    SqlTableModel* model = dynamic_cast<SqlTableModel*>(sourceModel());
    if (model)
        return model->getValueFromSameRow(colKey, valueKey, col);
    ProxyModel* proxyModel = dynamic_cast<ProxyModel*>(sourceModel());
    if (proxyModel)
        return proxyModel->getValueFromSameRow(colKey, valueKey, col);
    return QVariant();
}

void ProxyModel::setFilterString(const QString &pattern)
{
    QRegularExpression regExp(QRegularExpression::escape(pattern), QRegularExpression::CaseInsensitiveOption);
    setFilterRegularExpression(regExp);
}

int ProxyModel::sortColumn() const
{
    return QSortFilterProxyModel::sortColumn();
}

void ProxyModel::setSortColumn(int column)
{
    sort(column, sortOrder());
}

Qt::SortOrder ProxyModel::sortOrder() const
{
    return QSortFilterProxyModel::sortOrder();
}

void ProxyModel::setSortOrder(Qt::SortOrder order)
{
    sort(sortColumn(), order);
}

void ProxyModel::setFilterKeyColumns(const QList<int> &columns)
{
    mFilterColumns = columns;
}

int ProxyModel::filterDateColumn() const
{
    return mDateColumn;
}

void ProxyModel::setFilterDateColumn(int column)
{
    if (mDateColumn != column)
    {
        mDateColumn = column;
        invalidate();
    }
}

QDateTime ProxyModel::filterMinimumDate() const
{
    return mMinDate;
}

void ProxyModel::setFilterMinimumDate(const QDateTime &dt)
{
    if (mMinDate != dt)
    {
        mMinDate = dt;
        invalidate();
    }
}

QDateTime ProxyModel::filterMaximumDate() const
{
    return mMaxDate;
}

void ProxyModel::setFilterMaximumDate(const QDateTime &dt)
{
    if (mMaxDate != dt)
    {
        mMaxDate = dt;
        invalidate();
    }
}

bool ProxyModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    bool accept = true;
    if (mFilterColumns.empty())
    {
        accept = QSortFilterProxyModel::filterAcceptsRow(source_row, source_parent);
    }
    else
    {
        accept = false;
      #if (QT_VERSION >= QT_VERSION_CHECK(5, 12, 0))
        QRegularExpression rx = filterRegularExpression();
      #else
        QRegExp rx = filterRegExp();
      #endif
        for (int col : mFilterColumns)
        {
           QModelIndex idx = sourceModel()->index(source_row, col, source_parent);
            accept = sourceModel()->data(idx).toString().contains(rx);
            if (accept)
                break;
        }
    }
    if (accept && mDeletedColumn >= 0)
    {
        QModelIndex index = sourceModel()->index(source_row, mDeletedColumn, source_parent);
        if (index.isValid())
            accept = !sourceModel()->data(index).toBool();
    }
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
