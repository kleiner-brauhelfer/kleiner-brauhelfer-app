#ifndef SYNCSERVICEGOOGLE_H
#define SYNCSERVICEGOOGLE_H

#include "syncservice.h"
#include <QObject>
#include <QSettings>
#include <QOAuth2AuthorizationCodeFlow>
#include <QNetworkReply>
#include <QStringListModel>

/**
 * @brief Dropbox synchronization service
 */
class SyncServiceGoogle : public SyncService
{
    Q_OBJECT

    Q_PROPERTY(QString clientId READ clientId WRITE setClientId NOTIFY clientIdChanged)
    Q_PROPERTY(QString clientSecret READ clientSecret WRITE setClientSecret NOTIFY clientSecretChanged)
    Q_PROPERTY(QString fileId READ fileId WRITE setFileId NOTIFY fileIdChanged)
    Q_PROPERTY(QString fileName READ fileName WRITE setFileName NOTIFY fileNameChanged)

public:

    /**
     * @brief Dropbox synchronization service
     * @param settings Settings
     */
    SyncServiceGoogle(QSettings *settings);
    ~SyncServiceGoogle();

    /**
     * @brief Grant or refresh access
     * @return
     */
    Q_INVOKABLE void grantAccess();

    /**
     * @brief Refresh the access with the refresh token
     */
    Q_INVOKABLE void refreshAccess();

    /**
     * @brief Grant or refresh access
     * @return
     */
    Q_INVOKABLE bool retrieveFileId();

    /**
     * @brief  Synchronizes the file
     * @param direction Direction to synchronize
     * @note See getState() for details about the synchronization state
     * @return True on success
     */
    bool synchronize(SyncDirection direction) Q_DECL_OVERRIDE;

    QString clientId() const;
    void setClientId(const QString &id);

    QString clientSecret() const;
    void setClientSecret(const QString &secret);

    QString fileId() const;
    void setFileId(const QString &id);

    QString fileName() const;
    void setFileName(const QString &name);

signals:
    void accessGranted();
    void clientIdChanged(const QString &id);
    void clientSecretChanged(const QString &secret);
    void fileIdChanged(const QString &id);
    void fileNameChanged(const QString &name);

private slots:
    void networkError(QNetworkReply::NetworkError error);
    void authError(const QString &error, const QString &errorDescription, const QUrl &uri);
    void sslErrors(const QList<QSslError>& errors);

private:
    bool downloadFile();
    bool uploadFile();
    QString getServerRevision(QNetworkReply::NetworkError* replyCode = nullptr);
    QString getLocalRevision() const;
    void setLocalRevision(const QString &revision);
    QString refreshToken() const;
    void setRefreshToken(const QString &token);
    QString accessToken() const;
    void setAccessToken(const QString &token);
    void clearCachedSettings() Q_DECL_OVERRIDE;

private:
    bool _mightNeedToRefreshToken;
    QOAuth2AuthorizationCodeFlow *_oauth2;
    QNetworkAccessManager* _netManager;
    QNetworkReply* _netReply;
};

#endif // SYNCSERVICEGOOGLE_H
