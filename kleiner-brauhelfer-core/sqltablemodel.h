#ifndef SQLTABLEMODEL_H
#define SQLTABLEMODEL_H

#include "kleiner-brauhelfer-core_global.h"
#include <QSqlTableModel>
#include <QLoggingCategory>

class LIB_EXPORT SqlTableModel : public QSqlTableModel
{
    Q_OBJECT

    Q_PROPERTY(QString table READ tableName WRITE setTable NOTIFY tableChanged)
    Q_PROPERTY(QString filter READ filter WRITE setFilter NOTIFY filterChanged)
    Q_PROPERTY(bool modified READ isDirty NOTIFY modified)

public:

    /**
     * @brief Creates an SQL model
     * @param parent Parent
     * @param db Database
     */
    explicit SqlTableModel(QObject *parent = nullptr, QSqlDatabase db = QSqlDatabase());

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
     * @param col Column numer
     * @return Table data
     */
    Q_INVOKABLE QVariant data(int row, int col, int role = Qt::DisplayRole) const;

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
     * @param col Column number
     * @param value Field value
     * @return True on success
     */
    Q_INVOKABLE bool setData(int row, int col, const QVariant &value, int role = Qt::EditRole);

    /**
     * @brief Sets data to the model
     * @param row Row number
     * @param values Field name-values pairs to set
     */
    Q_INVOKABLE bool setData(int row, const QMap<int, QVariant> &values, int role = Qt::EditRole);

    /**
     * @brief Gets the role names
     * @return Role names
     */
    QHash<int, QByteArray> roleNames() const Q_DECL_OVERRIDE;

    /**
     * @brief Returns the item flags for the given index
     * @param index Index
     * @return Item flags
     */
    Qt::ItemFlags virtual flags(const QModelIndex &index) const Q_DECL_OVERRIDE;

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
     * @brief Sets the table
     * @param tableName Table name
     */
    Q_INVOKABLE virtual void setTable(const QString &tableName) Q_DECL_OVERRIDE;

    /**
     * @brief Sets the selection filter
     * @param filter Filter
     */
    Q_INVOKABLE virtual void setFilter(const QString &filter) Q_DECL_OVERRIDE;

    /**
     * @brief Removes rows from the table
     * @param row Row number
     * @param count Number of rows
     */
    Q_INVOKABLE virtual bool removeRows(int row, int count = 1, const QModelIndex &parent = QModelIndex()) Q_DECL_OVERRIDE;

    /**
     * @brief Removes a row from the table
     * @param arow Row number
     */
    Q_INVOKABLE bool removeRow(int arow, const QModelIndex &parent = QModelIndex());

    /**
     * @brief Appends a new row to the table
     * @param values Field values
     * @return Index of appended row
     */
    Q_INVOKABLE int append(const QMap<int, QVariant> &values = QMap<int, QVariant>());

    /**
     * @brief Appends a new row to the table
     * @param values Field values
     * @return Index of appended row
     */
    Q_INVOKABLE int append(const QVariantMap &values);
	
    /**
     * @brief Appends a new row directly to the table without calculating dependencies
     * @param values Field values
     * @return Index of appended row
     */
    Q_INVOKABLE int appendDirect(const QMap<int, QVariant> &values = QMap<int, QVariant>());

    /**
     * @brief Appends a new row directly to the table without calculating dependencies
     * @param values Field values
     * @return Index of appended row
     */
    Q_INVOKABLE int appendDirect(const QVariantMap &values);

    /**
     * @brief swap
     * @param row1 
     * @param row2
     * @return
     */
    Q_INVOKABLE bool swap(int row1, int row2);

    /**
     * @brief Emits the modified signal
     * @note Can be usefull in combination with blockSignals() and appendDirect()
     */
    Q_INVOKABLE void emitModified();

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
     * @param col Column number to compare
     * @param value Value of field name to match
     * @return Row number, -1 if not found
     */
    int getRowWithValue(int col, const QVariant &value) const;

    /**
     * @brief Gets the field name value matching a given field name key
     * @param fieldNameKey Field name to compare
     * @param valueKey Value of field name to match
     * @param fieldName Field name to get
     * @return Value corresponding to field name
     */
    QVariant getValueFromSameRow(int colKey, const QVariant &valueKey, int col) const;

    /**
     * @brief setValueFromSameRow
     * @param colKey
     * @param valueKey
     * @param col
     * @param value
     */
    void setValueFromSameRow(int colKey, const QVariant &valueKey, int col, const QVariant &value);

    /**
     * @brief Default values of a row
     * @param values Values
     */
    virtual void defaultValues(QMap<int, QVariant> &values) const;

    /**
     * @brief Values used to copy a row
     * @param row Row
     * @return Values
     */
    virtual QMap<int, QVariant> copyValues(int row) const;

    /**
     * @brief toVariantMap
     * @param row
     * @param ignoreCols
     * @return
     */
    QVariantMap toVariantMap(int row, QList<int> ignoreCols = QList<int>()) const;

    /**
     * @brief getNextId
     * @return
     */
    int getNextId() const;

public Q_SLOTS:

    bool select() Q_DECL_OVERRIDE;

Q_SIGNALS:

    /**
     * @brief Emitted when the underlying table was changed
     */
    void tableChanged();

    /**
     * @brief Emitted when the selection filter was changed
     */
    void filterChanged();

    /**
     * @brief submited
     */
    void submitted();

    /**
     * @brief reverted
     */
    void reverted();

    /**
     * @brief Emitted when the table data was changed
     */
    void modified();

    /**
     * @brief rowChanged
     * @param index
     */
    void rowChanged(const QModelIndex &index);

protected:

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
     * @brief isUnique
     * @param index
     * @param value
     * @return
     */
    bool isUnique(const QModelIndex &index, const QVariant &value, bool ignoreIndexRow = false) const;

    /**
     * @brief getUniqueName
     * @param index
     * @param value
     * @param ignoreIndexRow
     * @return
     */
    QString getUniqueName(const QModelIndex &index, const QVariant &value, bool ignoreIndexRow = false) const;

private Q_SLOTS:

    void fetchAll();

protected:

    /**
     * @brief Logging category for all SQL models
     */
    static QLoggingCategory loggingCategory;

    /**
     * @brief Can be used to define virtual field names to add virtual fields
     * @note Use dataExt() and setDataExt() to provide read/write functionality to these fields
     */
    QStringList mVirtualField;

    /**
     * @brief Can be set to temporarily skip emit of the modified signal
     */
    bool mSignalModifiedBlocked;

private:
    QHash<int, QByteArray> mRoles;
    int mSetDataCnt;
};

#endif // SQLTABLEMODEL_H
