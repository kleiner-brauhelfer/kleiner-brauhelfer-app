#include "sqltablemodel.h"
#include <QSqlRecord>

SqlTableModel::SqlTableModel(QObject *parent) :
    QSqlTableModel(parent)
{
    setEditStrategy(EditStrategy::OnManualSubmit);
}

QVariant SqlTableModel::data(const QModelIndex &index, int role) const
{
    QVariant value;
    if (role == Qt::DisplayRole || role > Qt::UserRole)
    {
        int col = (role > Qt::UserRole) ? (role - Qt::UserRole - 1) : index.column();
        const QModelIndex index2 = this->index(index.row(), col);
        value = dataExt(index2);
        if (!value.isValid())
            value = QSqlTableModel::data(index2);
    }
    else
    {
        value = QSqlTableModel::data(index, role);
    }
    return value;
}

QVariant SqlTableModel::data(int row, const QString &fieldName) const
{
    return data(this->index(row, fieldIndex(fieldName)));
}

bool SqlTableModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    bool ret;
    if (role == Qt::EditRole || role > Qt::UserRole)
    {
        int col = (role > Qt::UserRole) ? (role - Qt::UserRole - 1) : index.column();
        const QModelIndex index2 = this->index(index.row(), col);
        QVariant oldValue = data(index2);
        ret = setDataExt(index2, value);
        if (!ret)
            ret = QSqlTableModel::setData(index2, value);
        if (ret && oldValue != value)
        {
            emit valueChanged(index, value);
            emit modified();
        }
    }
    else
    {
        ret = QSqlTableModel::setData(index, value, role);
    }
    return ret;
}

bool SqlTableModel::setData(int row, const QString &fieldName, const QVariant &value)
{
    return setData(this->index(row, fieldIndex(fieldName)), value);
}

bool SqlTableModel::setData(int row, const QVariantMap &values)
{
    bool ret = true;
    QVariantMap::const_iterator it = values.constBegin();
    while (it != values.constEnd())
    {
        ret &= setData(row, it.key(), it.value());
        ++it;
    }
    return ret;
}

QHash<int, QByteArray> SqlTableModel::roleNames() const
{
    return roles;
}

QVariant SqlTableModel::headerData(int section, Qt::Orientation orientation, int role) const
{
    if (section < QSqlTableModel::columnCount())
        return QSqlTableModel::headerData(section, orientation, role);
    else
        return QVariant(additionalFieldNames.at(section - QSqlTableModel::columnCount()));
}

int SqlTableModel::columnCount(const QModelIndex &index) const
{
    return QSqlTableModel::columnCount(index) + additionalFieldNames.size();
}

int SqlTableModel::fieldIndex(const QString &fieldName) const
{
    int index = QSqlTableModel::fieldIndex(fieldName);
    if (index == -1)
    {
        for(int i = 0; i < additionalFieldNames.size(); ++i)
        {
            if (additionalFieldNames.at(i) == fieldName)
            {
                index = i + QSqlTableModel::columnCount();
                break;
            }
        }
    }
    return index;
}

QString SqlTableModel::fieldName(int fieldIndex) const
{
    return headerData(fieldIndex).toString();
}

void SqlTableModel::setSortByFieldName(const QString &fieldName, Qt::SortOrder order)
{
    int idx = fieldIndex(fieldName);
    if (idx != -1)
    {
        QSqlTableModel::setSort(idx, order);
    }
}

void SqlTableModel::setTable(const QString &tableName)
{
    if (tableName != this->tableName())
    {
        QSqlTableModel::setTable(tableName);
        roles.clear();
        for(int i = 0; i < columnCount(); ++i)
            roles.insert(Qt::UserRole + i + 1, QVariant(headerData(i).toString()).toByteArray());
        emit tableChanged();
    }
}

void SqlTableModel::setFilter(const QString &filter)
{
    if (filter != this->filter())
    {
        QSqlTableModel::setFilter(filter);
        emit filterChanged();
    }
}

void SqlTableModel::remove(int row)
{
    if (removeRow(row))
    {
        emit modified();
    }
}

void SqlTableModel::append(const QVariantMap &values)
{
    QSqlRecord rec = record();
    const QVariantMap valuesDefault = defaultValues();
    QVariantMap::const_iterator it = valuesDefault.constBegin();
    while (it != valuesDefault.constEnd())
    {
        rec.setValue(it.key(), it.value());
        ++it;
    }
    if (insertRecord(-1, rec))
    {
        setData(rowCount() - 1, values);
        emit modified();
    }
}

void SqlTableModel::append()
{
    append(QVariantMap());
}

bool SqlTableModel::submitAll()
{
    if (QSqlTableModel::submitAll())
    {
        emit modified();
        return true;
    }
    return false;
}

void SqlTableModel::revertAll()
{
    QSqlTableModel::revertAll();
    emit modified();
}

int SqlTableModel::GetRowWithValue(const QString &fieldName, const QVariant &value)
{
    int col = fieldIndex(fieldName);
    if (col != -1)
    {
        for (int row = 0; row < rowCount(); ++row)
        {
            if (data(this->index(row, col)) == value)
                return row;
        }
    }
    return -1;
}

QVariant SqlTableModel::dataExt(const QModelIndex &index) const
{
    Q_UNUSED(index);
    return QVariant();
}

bool SqlTableModel::setDataExt(const QModelIndex &index, const QVariant &value)
{
    Q_UNUSED(index);
    Q_UNUSED(value);
    return false;
}

QVariantMap SqlTableModel::defaultValues() const
{
    return QVariantMap();
}
