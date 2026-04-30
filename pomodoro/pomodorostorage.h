#pragma once

#include <QDateTime>
#include <QSqlDatabase>
#include <QString>
#include <QUrl>
#include <QVariant>
#include <QVariantList>

class PomodoroStorage
{
public:
    struct Settings
    {
        int focusDurationSeconds = 5;
        int shortBreakDurationSeconds = 5;
        int longBreakDurationSeconds = 10;
        int notificationDurationMs = 5000;
        bool notificationSoundEnabled = true;
        bool transparencyEnabled = false;
        double windowOpacity = 1.0;
        QUrl focusGifSource = QUrl(QStringLiteral("qrc:/qt/qml/pomodoro/assets/focus.gif"));
        QUrl shortBreakGifSource = QUrl(QStringLiteral("qrc:/qt/qml/pomodoro/assets/break.gif"));
        QUrl longBreakGifSource = QUrl(QStringLiteral("qrc:/qt/qml/pomodoro/assets/break.gif"));
        QUrl startGifSource = QUrl(QStringLiteral("qrc:/qt/qml/pomodoro/assets/start.gif"));
        QUrl pauseGifSource = QUrl(QStringLiteral("qrc:/qt/qml/pomodoro/assets/pause.gif"));
    };

    struct SessionRecord
    {
        QString fromState;
        QString toState;
        QDateTime startedAt;
        QDateTime endedAt;
        int cycle = 0;
        int durationSeconds = 0;
        bool completed = true;
    };

    PomodoroStorage();
    ~PomodoroStorage();

    bool initialize(QString *errorMessage = nullptr);
    bool loadSettings(Settings *settings, QString *errorMessage = nullptr);
    bool saveSettings(const Settings &settings, QString *errorMessage = nullptr);
    bool insertSessionRecord(const SessionRecord &record, QString *errorMessage = nullptr);
    QVariantList recentSessionRecords(int limit = 20, QString *errorMessage = nullptr) const;
    bool clearSessionRecords(QString *errorMessage = nullptr);
    bool exportSessionRecordsCsv(const QString &path, QString *errorMessage = nullptr) const;

    QString databasePath() const;

private:
    bool ensureSchema(QString *errorMessage = nullptr);
    bool upsertSetting(const QString &key, const QString &value, QString *errorMessage = nullptr);
    QString settingValue(const QString &key, const QString &fallback, QString *errorMessage = nullptr) const;

    QSqlDatabase m_database;
    QString m_connectionName;
    QString m_databasePath;
};
