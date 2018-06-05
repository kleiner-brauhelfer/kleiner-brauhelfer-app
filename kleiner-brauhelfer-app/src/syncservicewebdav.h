#ifndef SYNCSERVICEWEBDAV_H
#define SYNCSERVICEWEBDAV_H

#include "syncservice.h"
#include <QObject>
#include <QSettings>
#include <QNetworkReply>

class SyncServiceWebDav : public SyncService
{
    Q_OBJECT

    Q_PROPERTY(QString filePathServer READ getFilePathServer WRITE setFilePathServer NOTIFY filePathServerChanged)
    Q_PROPERTY(QString user READ getUser WRITE setUser NOTIFY userChanged)
    Q_PROPERTY(QString password READ getPassword WRITE setPassword NOTIFY passwordChanged)

public:

    /**
     * @brief Dropbox synchronization service
     * @param settings Settings
     */
    SyncServiceWebDav(QSettings *settings);
    ~SyncServiceWebDav();

    /**
     * @brief  Synchronizes the file
     * @param direction Direction to synchronize
     * @note See getState() for details about the synchronization state
     * @return True on success
     */
    bool synchronize(SyncDirection direction) Q_DECL_OVERRIDE;

    /**
     * @brief Gets the database path on the server
     * @return Database path
     */
    QString getFilePathServer() const;

    /**
     * @brief Sets the database path on the server
     * @param filePath Database path
     */
    void setFilePathServer(const QString &filePath);

    /**
     * @brief Gets the user for authentication
     * @return User
     */
    QString getUser() const;

    /**
     * @brief Sets the user for authentication
     * @param user User
     */
    void setUser(const QString& user);

    /**
     * @brief Gets the password for authentication
     * @return Password
     */
    QString getPassword() const;

    /**
     * @brief Sets the password for authentication
     * @param password Password
     */
    void setPassword(const QString& password);

signals:

    /**
     * @brief Emitted when the database path on the server changed
     * @param filePath Database path
     */
    void filePathServerChanged(const QString &filePath);

    /**
     * @brief Emitted when the user changed
     * @param user User
     */
    void userChanged(const QString& user);

    /**
     * @brief Emitted when the password changed
     * @param password Passwrod
     */
    void passwordChanged(const QString& password);

private slots:
    void authenticationRequired(QNetworkReply *reply, QAuthenticator *authenticator);
    void error(QNetworkReply::NetworkError error);
    void sslErrors(const QList<QSslError> &errors);

private:
    bool downloadFile();
    bool uploadFile();

private:
    bool _AuthenticationGiven;
    QNetworkAccessManager* _netManager;
    QNetworkReply* _netReply;
};

#endif // SYNCSERVICEWEBDAV_H
