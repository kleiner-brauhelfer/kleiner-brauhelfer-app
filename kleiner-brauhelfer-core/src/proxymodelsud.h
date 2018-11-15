#ifndef PROXYMODELSUD_H
#define PROXYMODELSUD_H

#include "proxymodel.h"

#if defined(KBCORE_LIBRARY)
  #define KBCORE_EXPORT Q_DECL_EXPORT
#else
  #define KBCORE_EXPORT Q_DECL_IMPORT
#endif

class KBCORE_EXPORT ProxyModelSud : public ProxyModel
{
    Q_OBJECT
    Q_PROPERTY(bool filterMerkliste READ filterMerkliste WRITE setFilterMerkliste NOTIFY filterChanged)
    Q_PROPERTY(int filterState READ filterState WRITE setFilterState NOTIFY filterChanged)
    Q_PROPERTY(QString filterText READ filterText WRITE setFilterText NOTIFY filterChanged)

public:

    enum FilterState
    {
        Alle,
        NichtGebraut,
        Gebraut,
        NichtAbgefuellt,
        Abgefuellt,
        NichtVerbraucht,
        Verbraucht
    };
    Q_ENUMS(FilterState)

    ProxyModelSud(QObject* parent = Q_NULLPTR);

    bool filterMerkliste() const;
    void setFilterMerkliste(bool value);

    int filterState() const;
    void setFilterState(int state);

    QString filterText() const;
    void setFilterText(const QString& text);

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const Q_DECL_OVERRIDE;

private slots:
    void onSourceModelChanged();

private:
    int mColumnId;
    int mColumnBierWurdeGebraut;
    int mColumnBierWurdeAbgefuellt;
    int mColumnBierWurdeVerbraucht;
    int mColumnMerklistenID;
    bool mFilterMerkliste;
    int mFilterState;
    QString mFilterText;
};

#endif // PROXYMODELSUD_H
