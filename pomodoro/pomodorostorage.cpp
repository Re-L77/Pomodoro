#include "pomodorostorage.h"

#include <QDir>
#include <QStandardPaths>
#include <QSqlError>
#include <QSqlQuery>
#include <QVariant>
#include <QVariantMap>
#include <QVariantList>
#include <QFile>
#include <QTextStream>

namespace
{
    QString urlToSettingValue(const QUrl &url)
    {
        return url.toString(QUrl::FullyEncoded);
    }

    QUrl settingValueToUrl(const QString &value)
    {
        return QUrl(value);
    }
} // namespace

PomodoroStorage::PomodoroStorage()
    : m_connectionName(QStringLiteral("pomodoro_sqlite_connection"))
{
}

PomodoroStorage::~PomodoroStorage()
{
    if (m_database.isValid())
    {
        const QString connectionName = m_database.connectionName();
        m_database.close();
        m_database = QSqlDatabase();
        QSqlDatabase::removeDatabase(connectionName);
    }
}

bool PomodoroStorage::initialize(QString *errorMessage)
{
    if (m_database.isValid() && m_database.isOpen())
    {
        return true;
    }

    const QString basePath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    if (basePath.isEmpty())
    {
        if (errorMessage)
        {
            *errorMessage = QStringLiteral("No se pudo resolver la ruta de AppDataLocation");
        }
        return false;
    }

    QDir directory(basePath);
    if (!directory.mkpath(QStringLiteral(".")))
    {
        if (errorMessage)
        {
            *errorMessage = QStringLiteral("No se pudo crear el directorio de datos: %1").arg(basePath);
        }
        return false;
    }

    m_databasePath = directory.filePath(QStringLiteral("pomodoro.sqlite3"));
    if (QSqlDatabase::contains(m_connectionName))
    {
        m_database = QSqlDatabase::database(m_connectionName);
    }
    else
    {
        m_database = QSqlDatabase::addDatabase(QStringLiteral("QSQLITE"), m_connectionName);
        m_database.setDatabaseName(m_databasePath);
    }

    if (!m_database.open())
    {
        if (errorMessage)
        {
            *errorMessage = m_database.lastError().text();
        }
        return false;
    }

    return ensureSchema(errorMessage);
}

bool PomodoroStorage::ensureSchema(QString *errorMessage)
{
    QSqlQuery query(m_database);

    const char *settingsSql =
        "CREATE TABLE IF NOT EXISTS settings ("
        " key TEXT PRIMARY KEY NOT NULL,"
        " value TEXT NOT NULL"
        ")";

    if (!query.exec(QString::fromLatin1(settingsSql)))
    {
        if (errorMessage)
        {
            *errorMessage = query.lastError().text();
        }
        return false;
    }

    const char *recordsSql =
        "CREATE TABLE IF NOT EXISTS session_records ("
        " id INTEGER PRIMARY KEY AUTOINCREMENT,"
        " started_at TEXT NOT NULL,"
        " ended_at TEXT NOT NULL,"
        " from_state TEXT NOT NULL,"
        " to_state TEXT NOT NULL,"
        " cycle INTEGER NOT NULL,"
        " duration_seconds INTEGER NOT NULL,"
        " completed INTEGER NOT NULL DEFAULT 1"
        ")";

    if (!query.exec(QString::fromLatin1(recordsSql)))
    {
        if (errorMessage)
        {
            *errorMessage = query.lastError().text();
        }
        return false;
    }

    return true;
}

bool PomodoroStorage::upsertSetting(const QString &key, const QString &value, QString *errorMessage)
{
    QSqlQuery query(m_database);
    query.prepare(QStringLiteral("INSERT INTO settings(key, value) VALUES(:key, :value) "
                                 "ON CONFLICT(key) DO UPDATE SET value = excluded.value"));
    query.bindValue(QStringLiteral(":key"), key);
    query.bindValue(QStringLiteral(":value"), value);

    if (!query.exec())
    {
        if (errorMessage)
        {
            *errorMessage = query.lastError().text();
        }
        return false;
    }

    return true;
}

QString PomodoroStorage::settingValue(const QString &key, const QString &fallback, QString *errorMessage) const
{
    QSqlQuery query(m_database);
    query.prepare(QStringLiteral("SELECT value FROM settings WHERE key = :key"));
    query.bindValue(QStringLiteral(":key"), key);

    if (!query.exec())
    {
        if (errorMessage)
        {
            *errorMessage = query.lastError().text();
        }
        return fallback;
    }

    if (query.next())
    {
        return query.value(0).toString();
    }

    return fallback;
}

bool PomodoroStorage::loadSettings(Settings *settings, QString *errorMessage)
{
    if (!settings)
    {
        if (errorMessage)
        {
            *errorMessage = QStringLiteral("Settings pointer is null");
        }
        return false;
    }

    if (!m_database.isOpen() && !initialize(errorMessage))
    {
        return false;
    }

    settings->focusDurationSeconds = settingValue(QStringLiteral("focus_duration_seconds"), QString::number(settings->focusDurationSeconds), errorMessage).toInt();
    settings->shortBreakDurationSeconds = settingValue(QStringLiteral("short_break_duration_seconds"), QString::number(settings->shortBreakDurationSeconds), errorMessage).toInt();
    settings->longBreakDurationSeconds = settingValue(QStringLiteral("long_break_duration_seconds"), QString::number(settings->longBreakDurationSeconds), errorMessage).toInt();
    settings->notificationDurationMs = settingValue(QStringLiteral("notification_duration_ms"), QString::number(settings->notificationDurationMs), errorMessage).toInt();
    settings->notificationSoundEnabled = settingValue(QStringLiteral("notification_sound_enabled"), settings->notificationSoundEnabled ? QStringLiteral("1") : QStringLiteral("0"), errorMessage).toInt() != 0;
    settings->windowOpacity = settingValue(QStringLiteral("window_opacity"), QString::number(settings->windowOpacity), errorMessage).toDouble();
    settings->focusGifSource = settingValueToUrl(settingValue(QStringLiteral("focus_gif_source"), urlToSettingValue(settings->focusGifSource), errorMessage));
    settings->shortBreakGifSource = settingValueToUrl(settingValue(QStringLiteral("short_break_gif_source"), urlToSettingValue(settings->shortBreakGifSource), errorMessage));
    settings->longBreakGifSource = settingValueToUrl(settingValue(QStringLiteral("long_break_gif_source"), urlToSettingValue(settings->longBreakGifSource), errorMessage));
    settings->startGifSource = settingValueToUrl(settingValue(QStringLiteral("start_gif_source"), urlToSettingValue(settings->startGifSource), errorMessage));
    settings->pauseGifSource = settingValueToUrl(settingValue(QStringLiteral("pause_gif_source"), urlToSettingValue(settings->pauseGifSource), errorMessage));

    return true;
}

bool PomodoroStorage::saveSettings(const Settings &settings, QString *errorMessage)
{
    if (!m_database.isOpen() && !initialize(errorMessage))
    {
        return false;
    }

    if (!m_database.transaction())
    {
        if (errorMessage)
        {
            *errorMessage = m_database.lastError().text();
        }
        return false;
    }

    const bool success = upsertSetting(QStringLiteral("focus_duration_seconds"), QString::number(settings.focusDurationSeconds), errorMessage) && upsertSetting(QStringLiteral("short_break_duration_seconds"), QString::number(settings.shortBreakDurationSeconds), errorMessage) && upsertSetting(QStringLiteral("long_break_duration_seconds"), QString::number(settings.longBreakDurationSeconds), errorMessage) && upsertSetting(QStringLiteral("notification_duration_ms"), QString::number(settings.notificationDurationMs), errorMessage) && upsertSetting(QStringLiteral("notification_sound_enabled"), settings.notificationSoundEnabled ? QStringLiteral("1") : QStringLiteral("0"), errorMessage) && upsertSetting(QStringLiteral("window_opacity"), QString::number(settings.windowOpacity), errorMessage) && upsertSetting(QStringLiteral("focus_gif_source"), urlToSettingValue(settings.focusGifSource), errorMessage) && upsertSetting(QStringLiteral("short_break_gif_source"), urlToSettingValue(settings.shortBreakGifSource), errorMessage) && upsertSetting(QStringLiteral("long_break_gif_source"), urlToSettingValue(settings.longBreakGifSource), errorMessage) && upsertSetting(QStringLiteral("start_gif_source"), urlToSettingValue(settings.startGifSource), errorMessage) && upsertSetting(QStringLiteral("pause_gif_source"), urlToSettingValue(settings.pauseGifSource), errorMessage);

    if (success)
    {
        if (!m_database.commit())
        {
            if (errorMessage)
            {
                *errorMessage = m_database.lastError().text();
            }
            m_database.rollback();
            return false;
        }
        return true;
    }

    m_database.rollback();
    return false;
}

bool PomodoroStorage::insertSessionRecord(const SessionRecord &record, QString *errorMessage)
{
    if (!m_database.isOpen() && !initialize(errorMessage))
    {
        return false;
    }

    QSqlQuery query(m_database);
    query.prepare(QStringLiteral(
        "INSERT INTO session_records(started_at, ended_at, from_state, to_state, cycle, duration_seconds, completed) "
        "VALUES(:started_at, :ended_at, :from_state, :to_state, :cycle, :duration_seconds, :completed)"));
    query.bindValue(QStringLiteral(":started_at"), record.startedAt.toUTC().toString(Qt::ISODateWithMs));
    query.bindValue(QStringLiteral(":ended_at"), record.endedAt.toUTC().toString(Qt::ISODateWithMs));
    query.bindValue(QStringLiteral(":from_state"), record.fromState);
    query.bindValue(QStringLiteral(":to_state"), record.toState);
    query.bindValue(QStringLiteral(":cycle"), record.cycle);
    query.bindValue(QStringLiteral(":duration_seconds"), record.durationSeconds);
    query.bindValue(QStringLiteral(":completed"), record.completed ? 1 : 0);

    if (!query.exec())
    {
        if (errorMessage)
        {
            *errorMessage = query.lastError().text();
        }
        return false;
    }

    return true;
}

QVariantList PomodoroStorage::recentSessionRecords(int limit, QString *errorMessage) const
{
    QVariantList results;

    if (!m_database.isOpen())
    {
        if (!const_cast<PomodoroStorage *>(this)->initialize(errorMessage))
        {
            return results;
        }
    }

    QSqlQuery query(m_database);
    query.prepare(QStringLiteral("SELECT id, started_at, ended_at, from_state, to_state, cycle, duration_seconds, completed FROM session_records ORDER BY id DESC LIMIT :limit"));
    query.bindValue(QStringLiteral(":limit"), limit);
    if (!query.exec())
    {
        if (errorMessage)
            *errorMessage = query.lastError().text();
        return results;
    }

    while (query.next())
    {
        QVariantMap row;
        row.insert("id", query.value(0));
        row.insert("started_at", query.value(1));
        row.insert("ended_at", query.value(2));
        row.insert("from_state", query.value(3));
        row.insert("to_state", query.value(4));
        row.insert("cycle", query.value(5));
        row.insert("duration_seconds", query.value(6));
        row.insert("completed", query.value(7));
        results.append(row);
    }

    return results;
}

bool PomodoroStorage::clearSessionRecords(QString *errorMessage)
{
    if (!m_database.isOpen() && !const_cast<PomodoroStorage *>(this)->initialize(errorMessage))
    {
        return false;
    }

    QSqlQuery query(m_database);
    if (!query.exec(QStringLiteral("DELETE FROM session_records")))
    {
        if (errorMessage)
            *errorMessage = query.lastError().text();
        return false;
    }

    return true;
}

bool PomodoroStorage::exportSessionRecordsCsv(const QString &path, QString *errorMessage) const
{
    if (!m_database.isOpen() && !const_cast<PomodoroStorage *>(this)->initialize(errorMessage))
    {
        return false;
    }

    QSqlQuery query(m_database);
    if (!query.exec(QStringLiteral("SELECT id, started_at, ended_at, from_state, to_state, cycle, duration_seconds, completed FROM session_records ORDER BY id ASC")))
    {
        if (errorMessage)
            *errorMessage = query.lastError().text();
        return false;
    }

    QFile out(path);
    if (!out.open(QIODevice::WriteOnly | QIODevice::Text))
    {
        if (errorMessage)
            *errorMessage = QStringLiteral("No se pudo abrir el archivo para escritura: %1").arg(path);
        return false;
    }

    QTextStream ts(&out);
    // header
    ts << "id,started_at,ended_at,from_state,to_state,cycle,duration_seconds,completed\n";

    while (query.next())
    {
        QStringList fields;
        for (int i = 0; i < 8; ++i)
        {
            QString f = query.value(i).toString();
            f.replace(QChar('"'), QStringLiteral("\"\""));
            fields << '"' + f + '"';
        }
        ts << fields.join(",") << "\n";
    }

    out.close();
    return true;
}

QString PomodoroStorage::databasePath() const
{
    return m_databasePath;
}
