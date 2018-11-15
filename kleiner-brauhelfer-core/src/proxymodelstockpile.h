#ifndef PROXYMODELSTOCKPILE_H
#define PROXYMODELSTOCKPILE_H

#include "proxymodel.h"

#if defined(KBCORE_LIBRARY)
  #define KBCORE_EXPORT Q_DECL_EXPORT
#else
  #define KBCORE_EXPORT Q_DECL_IMPORT
#endif

class KBCORE_EXPORT ProxyModelStockpile : public ProxyModel
{
    Q_OBJECT

    Q_PROPERTY(int amountColumn READ amountColumn WRITE setAmountColumn NOTIFY filterChanged)
    Q_PROPERTY(bool showAll READ showAll WRITE setShowAll NOTIFY filterChanged)

public:
    ProxyModelStockpile(QObject* parent = Q_NULLPTR);

    int amountColumn() const;
    void setAmountColumn(int column);

    bool showAll() const;
    void setShowAll(bool value);

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const Q_DECL_OVERRIDE;

private slots:
    void onSourceModelChanged();

private:
    int mAmountColumn;
    bool mShowAll;
};

#endif // PROXYMODELSTOCKPILE_H
