#include "aiosDevicesController.h"

#include "serversUiController.h"

#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <QUrl>
#include <QUrlQuery>
#include <QBuffer>
#include <QDateTime>
#include <QSysInfo>
#include <QDebug>
#include <QTimer>

namespace {
QString devicesUrlFor(const QString &hostName, const QString &token)
{
    return QStringLiteral("https://%1/api/devices/%2").arg(hostName, token);
}

QUrl standardDevicesUrlFor(const QString &hostName, const QString &token, bool includeTokenInQuery)
{
    QUrl url(QStringLiteral("https://%1/devices").arg(hostName));
    if (includeTokenInQuery) {
        QUrlQuery query;
        query.addQueryItem(QStringLiteral("token"), token);
        url.setQuery(query);
    }
    return url;
}

QString currentPlatformName()
{
#if defined(Q_OS_WIN)
    return QStringLiteral("Windows");
#elif defined(Q_OS_MACOS)
    return QStringLiteral("macOS");
#elif defined(Q_OS_LINUX)
    return QStringLiteral("Linux");
#elif defined(Q_OS_IOS)
    return QStringLiteral("iOS");
#elif defined(Q_OS_ANDROID)
    return QStringLiteral("Android");
#else
    return QSysInfo::productType();
#endif
}

void configureRequest(QNetworkRequest &request)
{
    request.setAttribute(QNetworkRequest::RedirectPolicyAttribute,
                         QNetworkRequest::NoLessSafeRedirectPolicy);
    request.setAttribute(QNetworkRequest::CacheLoadControlAttribute,
                         QNetworkRequest::AlwaysNetwork);
    request.setAttribute(QNetworkRequest::CacheSaveControlAttribute, false);
    request.setTransferTimeout(10000);
}

bool shouldTryStandardContract(QNetworkReply *reply)
{
    const int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    return status == 404 || status == 405
           || reply->error() == QNetworkReply::ContentNotFoundError;
}

QString apiError(const QByteArray &body)
{
    const QJsonDocument doc = QJsonDocument::fromJson(body);
    if (!doc.isObject()) {
        return QString();
    }
    const QJsonObject obj = doc.object();
    const QJsonValue error = obj.value(QStringLiteral("error"));
    if (error.isString()) {
        return error.toString();
    }
    if (error.isObject()) {
        return QString::fromUtf8(QJsonDocument(error.toObject()).toJson(QJsonDocument::Compact));
    }
    if (obj.value(QStringLiteral("success")).isBool()
            && !obj.value(QStringLiteral("success")).toBool()) {
        return obj.value(QStringLiteral("message")).toString(QStringLiteral("request rejected"));
    }
    return QString();
}

// Панели могут отдавать добавленное время в разных форматах (unix sec/ms, строка).
QString normalizeAddedAt(const QJsonValue &v)
{
    if (v.isDouble()) {
        const qint64 raw = static_cast<qint64>(v.toDouble());
        const QDateTime dt = raw > 100000000000LL ? QDateTime::fromMSecsSinceEpoch(raw)
                                                  : QDateTime::fromSecsSinceEpoch(raw);
        if (dt.isValid()) {
            return dt.toString("dd.MM.yyyy");
        }
        return QString();
    }
    if (v.isString()) {
        const QString s = v.toString();
        bool ok = false;
        const qint64 raw = s.toLongLong(&ok);
        if (ok && raw > 1000000000LL) {
            const QDateTime dt = raw > 100000000000LL ? QDateTime::fromMSecsSinceEpoch(raw)
                                                      : QDateTime::fromSecsSinceEpoch(raw);
            if (dt.isValid()) {
                return dt.toString("dd.MM.yyyy");
            }
        }
        return s;
    }
    return QString();
}
} // namespace

AiosDevicesController::AiosDevicesController(QObject *parent)
    : QObject(parent)
{
}

QString AiosDevicesController::tokenFor(const QString &serverId) const
{
    return m_servers ? m_servers->aiosTokenForServer(serverId) : QString();
}

QString AiosDevicesController::hostFor(const QString &serverId) const
{
    const QString id = (serverId.isEmpty() && m_servers) ? m_servers->getDefaultServerId() : serverId;
    return m_servers ? m_servers->serverHostName(id) : QString();
}

QString AiosDevicesController::myHwid() const
{
    return QString::fromLatin1(QSysInfo::machineUniqueId());
}

void AiosDevicesController::refresh(const QString &serverId)
{
    const QString token = tokenFor(serverId);
    if (token.isEmpty()) {
        m_supported = false;
        m_hasList = false;
        m_devices.clear();
        m_error = QString();
        m_loading = false;
        emit devicesChanged();
        emit stateChanged();
        return;
    }

    m_loading = true;
    m_error = QString();
    emit stateChanged();

    fetchList(hostFor(serverId), token);
}

void AiosDevicesController::fetchList(const QString &hostName, const QString &token,
                                      bool standardContract)
{
    if (hostName.isEmpty()) {
        m_loading = false;
        m_supported = false;
        m_hasList = false;
        emit stateChanged();
        return;
    }

    QNetworkRequest request(standardContract
                                ? standardDevicesUrlFor(hostName, token, true)
                                : QUrl(devicesUrlFor(hostName, token)));
    configureRequest(request);

    QNetworkReply *reply = m_nam.get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply, hostName, token, standardContract]() {
        onListReply(reply, hostName, token, standardContract);
    });
}

void AiosDevicesController::onListReply(QNetworkReply *reply, const QString &hostName,
                                        const QString &token, bool standardContract)
{
    if (!standardContract && shouldTryStandardContract(reply)) {
        reply->deleteLater();
        fetchList(hostName, token, true);
        return;
    }

    reply->deleteLater();
    m_loading = false;

    const int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

    if (reply->error() != QNetworkReply::NoError) {
        // 404/405 -> панель не поддерживает список устройств
        m_supported = !(status == 404 || status == 405 || reply->error() == QNetworkReply::ContentNotFoundError
                        || reply->error() == QNetworkReply::OperationCanceledError);
        m_hasList = false;
        m_devices.clear();
        m_error = m_supported ? reply->errorString() : QString();
        emit devicesChanged();
        emit stateChanged();
        return;
    }

    m_supported = true;
    m_error = QString();
    parseDevices(reply->readAll());
    m_hasList = true;
    emit devicesChanged();
    emit stateChanged();
}

void AiosDevicesController::ensureCurrentDeviceRegistered(const QString &serverId)
{
    const QString token = tokenFor(serverId);
    const QString hostName = hostFor(serverId);
    if (token.isEmpty() || hostName.isEmpty() || myHwid().isEmpty()) {
        emit registrationFinished(false, QStringLiteral("no access token or device id"));
        return;
    }
    registerCurrentDevice(hostName, token);
}

void AiosDevicesController::registerCurrentDevice(const QString &hostName, const QString &token,
                                                  bool standardContract)
{
    QNetworkRequest request(standardContract
                                ? standardDevicesUrlFor(hostName, token, false)
                                : QUrl(devicesUrlFor(hostName, token)));
    configureRequest(request);
    request.setHeader(QNetworkRequest::ContentTypeHeader, QStringLiteral("application/json"));

    const QString deviceName = QSysInfo::machineHostName().isEmpty()
            ? currentPlatformName() : QSysInfo::machineHostName();
    const QJsonObject payload {
        { QStringLiteral("token"), token },
        { QStringLiteral("hwid"), myHwid() },
        { QStringLiteral("name"), deviceName },
        { QStringLiteral("deviceName"), deviceName },
        { QStringLiteral("platform"), currentPlatformName() },
        { QStringLiteral("action"), QStringLiteral("register") }
    };

    QNetworkReply *reply = m_nam.post(request, QJsonDocument(payload).toJson(QJsonDocument::Compact));
    connect(reply, &QNetworkReply::finished, this,
            [this, reply, hostName, token, standardContract]() {
        onRegisterReply(reply, hostName, token, standardContract);
    });
}

void AiosDevicesController::onRegisterReply(QNetworkReply *reply, const QString &hostName,
                                            const QString &token, bool standardContract)
{
    if (!standardContract && shouldTryStandardContract(reply)) {
        reply->deleteLater();
        registerCurrentDevice(hostName, token, true);
        return;
    }

    const QByteArray body = reply->readAll();
    const QString responseError = apiError(body);
    const bool success = reply->error() == QNetworkReply::NoError && responseError.isEmpty();
    const QString error = success ? QString()
                                  : (responseError.isEmpty() ? reply->errorString() : responseError);
    reply->deleteLater();

    if (success) {
        QTimer::singleShot(300, this, [this]() { refresh(); });
    } else {
        qWarning() << "AIOS device registration failed:" << error;
    }
    emit registrationFinished(success, error);
}

// Разбор одного элемента списка устройств; поля называются по-разному в разных панелях.
static QVariantMap parseDeviceEntry(const QJsonObject &obj)
{
    QVariantMap entry;
    const QString hwid = obj.value("hwid").toString(obj.value("id").toString());
    if (hwid.isEmpty()) {
        return {};
    }
    entry.insert("hwid", hwid);
    entry.insert("name", obj.value("name").toString(obj.value("deviceName").toString(QStringLiteral("Устройство"))));
    entry.insert("platform", obj.value("platform").toString(obj.value("os").toString(obj.value("device").toString())));
    const QJsonValue added = obj.contains("addedAt") ? obj.value("addedAt") : obj.value("added_at");
    entry.insert("addedAt", normalizeAddedAt(added));
    return entry;
}

void AiosDevicesController::parseDevices(const QByteArray &body)
{
    QVariantList result;
    const QJsonDocument doc = QJsonDocument::fromJson(body);
    QJsonArray arr;
    if (doc.isObject()) {
        const QJsonObject obj = doc.object();
        if (obj.contains("error")) {
            m_error = obj.value("error").toString();
            m_hasList = false;
            m_devices.clear();
            return;
        }
        arr = obj.value("devices").toArray();
    } else if (doc.isArray()) {
        arr = doc.array();
    }

    for (const QJsonValue &v : arr) {
        QVariantMap entry = parseDeviceEntry(v.toObject());
        if (!entry.isEmpty()) {
            // The server may retain a platform value from an older client.
            // For this machine the local platform is authoritative.
            if (entry.value(QStringLiteral("hwid")).toString() == myHwid()) {
                entry.insert(QStringLiteral("platform"), currentPlatformName());
            }
            result.append(entry);
        }
    }

    m_devices = result;
}

void AiosDevicesController::revoke(const QString &hwid)
{
    m_pendingRevokes.clear();
    m_pendingRevokes.append(hwid);
    m_okCount = 0;
    m_failCount = 0;
    m_includeThisDevice = false;
    m_lastError = QString();
    revokeNext();
}

void AiosDevicesController::revokeMany(const QVariantList &hwids)
{
    m_pendingRevokes.clear();
    for (const QVariant &v : hwids) {
        const QString hwid = v.toString();
        if (!hwid.isEmpty()) {
            m_pendingRevokes.append(hwid);
        }
    }
    m_okCount = 0;
    m_failCount = 0;
    m_includeThisDevice = false;
    m_lastError = QString();
    revokeNext();
}

void AiosDevicesController::revokeNext(bool standardContract)
{
    if (m_pendingRevokes.isEmpty()) {
        emit revokeFinished(m_okCount, m_failCount, m_includeThisDevice, m_lastError);
        if (m_okCount > 0) {
            // Give the panel a brief moment to commit the deletion before the
            // no-cache GET; otherwise an eventually-consistent backend can
            // immediately return the device that was just removed.
            QTimer::singleShot(500, this, [this]() { refresh(); });
        }
        return;
    }

    const QString hwid = m_pendingRevokes.first();
    const QString token = tokenFor(QString());
    const QString host = hostFor(QString());
    if (token.isEmpty() || host.isEmpty()) {
        m_failCount += m_pendingRevokes.size();
        m_lastError = QStringLiteral("no access token");
        m_pendingRevokes.clear();
        emit revokeFinished(m_okCount, m_failCount, m_includeThisDevice, m_lastError);
        return;
    }

    QNetworkRequest request(standardContract
                                ? standardDevicesUrlFor(host, token, false)
                                : QUrl(devicesUrlFor(host, token)));
    configureRequest(request);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QBuffer *buffer = new QBuffer();
    QJsonObject payload { { QStringLiteral("hwid"), hwid } };
    if (standardContract) {
        payload.insert(QStringLiteral("token"), token);
    }
    buffer->setData(QJsonDocument(payload).toJson(QJsonDocument::Compact));
    buffer->open(QIODevice::ReadOnly);

    QNetworkReply *reply = m_nam.sendCustomRequest(request, "DELETE", buffer);
    buffer->setParent(reply);
    connect(reply, &QNetworkReply::finished, this, [this, reply, hwid, standardContract]() {
        onRevokeReply(reply, hwid, standardContract);
    });
}

void AiosDevicesController::onRevokeReply(QNetworkReply *reply, const QString &hwid,
                                          bool standardContract)
{
    if (!standardContract && shouldTryStandardContract(reply)) {
        reply->deleteLater();
        revokeNext(true);
        return;
    }

    const QByteArray body = reply->readAll();
    const QJsonDocument doc = QJsonDocument::fromJson(body);
    const QJsonObject obj = doc.isObject() ? doc.object() : QJsonObject();
    const QString responseError = apiError(body);
    const bool explicitlyRejected = obj.value(QStringLiteral("revoked")).isBool()
                                    && !obj.value(QStringLiteral("revoked")).toBool();
    const bool success = reply->error() == QNetworkReply::NoError
                         && responseError.isEmpty() && !explicitlyRejected;
    const QString networkError = reply->errorString();
    reply->deleteLater();

    if (!m_pendingRevokes.isEmpty() && m_pendingRevokes.first() == hwid) {
        m_pendingRevokes.removeFirst();
    }

    if (success) {
        m_okCount++;
        if (hwid == myHwid()) {
            m_includeThisDevice = true;
        }
        for (qsizetype i = m_devices.size() - 1; i >= 0; --i) {
            if (m_devices.at(i).toMap().value(QStringLiteral("hwid")).toString() == hwid) {
                m_devices.removeAt(i);
            }
        }
        emit devicesChanged();
    } else {
        m_failCount++;
        m_lastError = responseError.isEmpty()
                ? (explicitlyRejected ? QStringLiteral("device was not revoked") : networkError)
                : responseError;
    }

    revokeNext();
}
