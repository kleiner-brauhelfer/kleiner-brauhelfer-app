#ifndef SYNCSERVICEDROPBOX_H
#define SYNCSERVICEDROPBOX_H

#include "syncservice.h"
#include <QObject>
#include <QSettings>
#include <QOAuth2AuthorizationCodeFlow>
#include <QNetworkReply>
#include <QStringListModel>

/**
 * @brief Dropbox synchronization service
 */
class SyncServiceDropbox : public SyncService
{
    Q_OBJECT

    Q_PROPERTY(QString appKey READ appKey WRITE setAppKey NOTIFY appKeyChanged)
    Q_PROPERTY(QString appSecret READ appSecret WRITE setAppSecret NOTIFY appSecretChanged)
    Q_PROPERTY(QString refreshToken READ refreshToken WRITE setRefreshToken NOTIFY refreshTokenChanged)
    Q_PROPERTY(QString accessToken READ accessToken WRITE setAccessToken NOTIFY accessTokenChanged)
    Q_PROPERTY(QString filePathServer READ filePathServer WRITE setFilePathServer NOTIFY filePathServerChanged)
    Q_PROPERTY(QStringListModel* folderContent READ folderContent NOTIFY accessTokenChanged)

public:

    /**
     * @brief Dropbox synchronization service
     * @param settings Settings
     */
    SyncServiceDropbox(QSettings *settings);
    ~SyncServiceDropbox();

    /**
     * @brief Grant or refresh access
     * @return
     */
    Q_INVOKABLE bool grantAccess();

    /**
     * @brief Refresh the access with the refresh token
     */
    Q_INVOKABLE void refreshAccess();

    /**
     * @brief  Synchronizes the file
     * @param direction Direction to synchronize
     * @note See getState() for details about the synchronization state
     * @return True on success
     */
    bool synchronize(SyncDirection direction) Q_DECL_OVERRIDE;

    /**
     * @brief Gets the folder content
     * @return List of files
     */
    QStringListModel *folderContent();

    /**
     * @brief appKey
     * @return
     */
    QString appKey() const;

    /**
     * @brief setAppKey
     * @param key
     */
    void setAppKey(const QString &key);

    /**
     * @brief appSecret
     * @return
     */
    QString appSecret() const;

    /**
     * @brief setAppSecret
     * @param secret
     */
    void setAppSecret(const QString &secret);

    /**
     * @brief refreshToken
     * @return
     */
    QString refreshToken() const;

    /**
     * @brief setRefreshToken
     * @param token
     */
    void setRefreshToken(const QString &token);

    /**
     * @brief Gets the server access token
     * @return Access token
     */
    QString accessToken() const;

    /**
     * @brief Sets the server access token
     * @param token Access token
     */
    void setAccessToken(const QString &token);

    /**
     * @brief Gets the database path on the server
     * @return Database path
     */
    QString filePathServer() const;

    /**
     * @brief Sets the database path on the server
     * @param filePath Database path
     */
    void setFilePathServer(const QString &filePath);

signals:

    /**
     * @brief appKeyChanged
     * @param token
     */
    void appKeyChanged(const QString &key);

    /**
     * @brief appSecretChanged
     * @param token
     */
    void appSecretChanged(const QString &secret);

    /**
     * @brief refreshTokenChanged
     * @param token
     */
    void refreshTokenChanged(const QString &token);

    /**
     * @brief Emitted if access token was changed
     * @param token Access token
     */
    void accessTokenChanged(const QString &token);

    /**
     * @brief Emitted if database path on the server changed
     * @param filePath Database path
     */
    void filePathServerChanged(const QString &filePath);

private slots:
    void error(QNetworkReply::NetworkError error);
    void sslErrors(const QList<QSslError>& errors);

private:

    bool downloadFile();
    bool uploadFile();
    QString getServerRevision();
    QString getLocalRevision() const;
    void setLocalRevision(const QString &revision);
    void clearCachedSettings() Q_DECL_OVERRIDE;
    QOAuth2AuthorizationCodeFlow *_oauth2;
    QNetworkAccessManager* _netManager;
    QNetworkReply* _netReply;
    QStringListModel* _fileContent;
};

#endif // SYNCSERVICEDROPBOX_H
