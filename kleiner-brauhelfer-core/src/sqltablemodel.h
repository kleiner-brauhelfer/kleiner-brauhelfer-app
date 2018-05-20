#ifndef SQLTABLEMODEL_H
#define SQLTABLEMODEL_H

#include <QSqlTableModel>

#if defined(KBCORE_LIBRARY)
  #define KBCORE_EXPORT Q_DECL_EXPORT
#else
  #define KBCORE_EXPORT Q_DECL_IMPORT
#endif

/**
 * @brief Wrapper for QSqlTableModel adding support for addressing columns by the header name
 */
class KBCORE_EXPORT SqlTableModel : public QSqlTableModel
{
    Q_OBJECT

    Q_PROPERTY(QString table READ tableName WRITE setTable NOTIFY tableChanged)
    Q_PROPERTY(QString filter READ filter WRITE setFilter NOTIFY filterChanged)
    Q_PROPERTY(bool modified READ isDirty NOTIFY modified)

public:

    /**
     * @brief Creates an SQL model
     * @note If will set the edit strategy to EditStrategy::OnManualSubmit
     * @param parent Parent
     */
    explicit SqlTableModel(QObject *parent = Q_NULLPTR);

    /**
     * @brief Gets data from the model
     * @note Tries first to get the data from dataExt()
     * @param index Index of the data to get
     * @param role Role
     * @return Data
     */
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const Q_DECL_OVERRIDE;

    /**
     * @brief Gets data from the model
     * @param row Row number
     * @param fieldName Field name
     * @return Table data
     */
    Q_INVOKABLE QVariant data(int row, const QString &fieldName) const;

    /**
     * @brief Sets data to the model
     * @note Tries first to set data with setDataExt()
     * @param index Index of the data to set
     * @param value Value to set
     * @param role Role
     * @return True on success
     */
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) Q_DECL_OVERRIDE;

    /**
     * @brief Sets data to the model
     * @param row Row number
     * @param fieldName Field name
     * @param value Field value
     * @return True on success
     */
    Q_INVOKABLE bool setData(int row, const QString &fieldName, const QVariant &value);

    /**
     * @brief Sets data to the model
     * @param row Row number
     * @param values Field name-values pairs to set
     */
    Q_INVOKABLE bool setData(int row, const QVariantMap &values);

    /**
     * @brief Gets the role names
     * @return Role names
     */
    QHash<int, QByteArray> roleNames() const Q_DECL_OVERRIDE;

    /**
     * @brief Gets the header data
     * @param section Header index
     * @param orientation Orientation
     * @param role Role
     * @return Header data
     */
    QVariant headerData(int section, Qt::Orientation orientation = Qt::Horizontal, int role = Qt::DisplayRole) const Q_DECL_OVERRIDE;

    /**
     * @brief Returns the number of columns
     * @param index Parent
     * @return Number of columns
     */
    int columnCount(const QModelIndex &index = QModelIndex()) const Q_DECL_OVERRIDE;
	
    /**
     * @brief Gets the field index corresponding to a field name
     * @param fieldName Field Name
     * @return Field inder
     */
    Q_INVOKABLE int fieldIndex(const QString &fieldName) const;

    /**
     * @brief Gets the field name corresponding to the field index
     * @param fieldIndex Field index
     * @return Field name
     */
    Q_INVOKABLE QString fieldName(int fieldIndex) const;

    /**
     * @brief Sets the sorting order
     * @param fieldName Ordered by this field name
     * @param order Ascending or descending order
     */
    Q_INVOKABLE void setSortByFieldName(const QString &fieldName, Qt::SortOrder order = Qt::AscendingOrder);

    /**
     * @brief Sets the table
     * @param tableName Table name
     */
    Q_INVOKABLE void setTable(const QString &tableName) Q_DECL_OVERRIDE;

    /**
     * @brief Sets the selection filter
     * @param filter Filter
     */
    Q_INVOKABLE void setFilter(const QString &filter) Q_DECL_OVERRIDE;   

    /**
     * @brief Removes a row from the table
     * @param row Row number
     */
    Q_INVOKABLE void remove(int row);

    /**
     * @brief Appends a new row to the table
     * @param values Field values
     */
    Q_INVOKABLE void append(const QVariantMap &values);

    /**
     * @brief Appends a new row to the table with the default values
     */
    Q_INVOKABLE void append();

    /**
     * @brief Saves the pending changes of the table
     * @return True on success
     */
    Q_INVOKABLE bool submitAll();

    /**
     * @brief Discards the pending changes of the table
     */
    Q_INVOKABLE void revertAll();

    /**
     * @brief Gets the row number matching a given value
     * @param fieldName Field name to compare
     * @param value Value of field name to match
     * @return Row number, -1 if not found
     */
    int GetRowWithValue(const QString &fieldName, const QVariant &value);

signals:

    /**
     * @brief Emitted when the underlying table was changed
     */
    void tableChanged();

    /**
     * @brief Emitted when the selection filter was changed
     */
    void filterChanged();

    /**
     * @brief Emitted when the table data was changed
     */
    void modified();

    /**
     * @brief Emitted when a value was changed
     */
    void valueChanged(const QModelIndex &index, const QVariant &value);

protected:

    /**
     * @brief Can be used to define additional field names to add virtual fields
     * @note Use dataExt() and setDataExt() to provide read/write functionality to these fields
     */
    QStringList additionalFieldNames;

    /**
     * @brief Can be used to overwrite data() to add specific behavior
     * @param index Index of the data to get
     * @return Data
     */
    virtual QVariant dataExt(const QModelIndex &index) const;

    /**
     * @brief setDataExt
     * @param index Index of the data to set
     * @param value Value to set
     * @return True on success
     */
    virtual bool setDataExt(const QModelIndex &index, const QVariant &value);

    /**
     * @brief Default values of a row
     * @return Default values
     */
    virtual QVariantMap defaultValues() const;

private:

    QHash<int, QByteArray> roles;

};

#endif // SQLTABLEMODEL_H
