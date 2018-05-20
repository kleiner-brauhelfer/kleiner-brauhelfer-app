#ifndef SORTFILTERPROXYMODELSUD_H
#define SORTFILTERPROXYMODELSUD_H

#include "sortfilterproxymodel.h"

class SortFilterProxyModelSud : public SortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(bool filterMerkliste READ filterMerkliste WRITE setFilterMerkliste NOTIFY filterChanged)
    Q_PROPERTY(int filterValue READ filterValue WRITE setFilterValue NOTIFY filterChanged)

public:

    enum FilterValue
    {
        Alle,
        NichtGebraut,
        Gebraut,
        NichtAbgefuellt,
        Abgefuellt,
        NichtVerbraucht,
        Verbraucht
    };
    Q_ENUMS(FilterValue)

    SortFilterProxyModelSud(QObject* parent = 0);
    ~SortFilterProxyModelSud();

    bool filterMerkliste() const;
    void setFilterMerkliste(bool value);

    int filterValue() const;
    void setFilterValue(int value);

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const Q_DECL_OVERRIDE;

private slots:
    void onSourceModelChanged();

private:
    int mColumnBierWurdeGebraut;
    int mColumnBierWurdeAbgefuellt;
    int mColumnBierWurdeVerbraucht;
    int mColumnMerklistenID;
    bool mFilterMerkliste;
    int mFilterValue;
};

#endif // SORTFILTERPROXYMODELSUD_H
