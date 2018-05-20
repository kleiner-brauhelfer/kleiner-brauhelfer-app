#ifndef SORTFILTERPROXYMODEL_H
#define SORTFILTERPROXYMODEL_H

#include <QSortFilterProxyModel>
#include <QDateTime>

class SortFilterProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int dateColumn READ filterDateColumn WRITE setFilterDateColumn NOTIFY filterChanged)
    Q_PROPERTY(QDateTime minDate READ filterMinimumDate WRITE setFilterMinimumDate NOTIFY filterChanged)
    Q_PROPERTY(QDateTime maxDate READ filterMaximumDate WRITE setFilterMaximumDate NOTIFY filterChanged)

public:
    SortFilterProxyModel(QObject* parent = 0);
    ~SortFilterProxyModel();

    int filterDateColumn() const;
    void setFilterDateColumn(int column);

    QDateTime filterMinimumDate() const;
    void setFilterMinimumDate(const QDateTime &dt);

    QDateTime filterMaximumDate() const;
    void setFilterMaximumDate(const QDateTime &dt);

signals:
    void filterChanged();

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const Q_DECL_OVERRIDE;

private:
    bool dateInRange(const QDateTime &dt) const;

private:
    int mDateColumn;
    QDateTime mMinDate;
    QDateTime mMaxDate;
};

#endif // SORTFILTERPROXYMODEL_H
