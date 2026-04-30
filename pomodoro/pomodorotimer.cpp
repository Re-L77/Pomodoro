#include "pomodorotimer.h"

#include <QApplication>
#include <QDateTime>
#include <QDebug>
#include <QIcon>
#include <QStyle>
#include <QSystemTrayIcon>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QUuid>
#include <emmintrin.h>

#include <QFile>
#include <QTextStream>

PomodoroTimer::PomodoroTimer(QObject *parent)
    : QObject(parent),
      m_focusGifSource(QUrl(QStringLiteral("qrc:/qt/qml/pomodoro/assets/focus.gif"))),
      m_shortBreakGifSource(QUrl(QStringLiteral("qrc:/qt/qml/pomodoro/assets/break.gif"))),
      m_longBreakGifSource(QUrl(QStringLiteral("qrc:/qt/qml/pomodoro/assets/break.gif"))),
      m_startGifSource(QUrl(QStringLiteral("qrc:/qt/qml/pomodoro/assets/start.gif"))),
      m_pauseGifSource(QUrl(QStringLiteral("qrc:/qt/qml/pomodoro/assets/pause.gif"))),
      m_currentGifSource(QUrl(QStringLiteral("qrc:/qt/qml/pomodoro/assets/start.gif"))),
      m_focusDurationSeconds(5),
      m_shortBreakDurationSeconds(5),
      m_longBreakDurationSeconds(10),
      m_notificationDurationMs(5000),
      m_transparencyEnabled(false),
      m_windowOpacity(1.0),
      m_timer(new QTimer(this)),
      m_isFocusMode(true),
      m_currentCycle(1),
      m_stateStartedAt(QDateTime::currentDateTimeUtc())
{
    // Configuramos el tiempo inicial con los valores centralizados
    m_totalSeconds = m_focusDurationSeconds;
    m_timeLeft = m_totalSeconds;
    m_statusText = "Work Session";
    m_controlButtonText = "▶\nStart";
    m_sweepAngle = 360.0;
    updateTimeDisplay();
    updateCurrentGifSource();

    // Conectamos el "tic" del reloj a nuestra función
    connect(m_timer, &QTimer::timeout, this, &PomodoroTimer::tick);

    // Inicializamos el icono de la bandeja del sistema si está disponible
    if (QSystemTrayIcon::isSystemTrayAvailable())
    {
        m_trayIcon = new QSystemTrayIcon(this);
        m_trayIcon->setIcon(QApplication::style()->standardIcon(QStyle::SP_ComputerIcon));
        m_trayIcon->show();
    }
    else
    {
        m_trayIcon = nullptr;
    }

    reloadConfiguration();
}

// Implementación de los Getters
QString PomodoroTimer::timeDisplay() const { return m_timeDisplay; }
QString PomodoroTimer::statusText() const { return m_statusText; }
QString PomodoroTimer::controlButtonText() const { return m_controlButtonText; }
double PomodoroTimer::sweepAngle() const { return m_sweepAngle; }
int PomodoroTimer::currentCycle() const { return m_currentCycle; }
QUrl PomodoroTimer::currentGifSource() const { return m_currentGifSource; }
QUrl PomodoroTimer::focusGifSource() const { return m_focusGifSource; }
QUrl PomodoroTimer::shortBreakGifSource() const { return m_shortBreakGifSource; }
QUrl PomodoroTimer::longBreakGifSource() const { return m_longBreakGifSource; }
QUrl PomodoroTimer::startGifSource() const { return m_startGifSource; }
QUrl PomodoroTimer::pauseGifSource() const { return m_pauseGifSource; }
int PomodoroTimer::focusDurationSeconds() const { return m_focusDurationSeconds; }
int PomodoroTimer::shortBreakDurationSeconds() const { return m_shortBreakDurationSeconds; }
int PomodoroTimer::longBreakDurationSeconds() const { return m_longBreakDurationSeconds; }
bool PomodoroTimer::notificationSoundEnabled() const { return m_notificationSoundEnabled; }
bool PomodoroTimer::transparencyEnabled() const { return m_transparencyEnabled; }
void PomodoroTimer::setTransparencyEnabled(bool enabled)
{
    if (m_transparencyEnabled == enabled)
    {
        return;
    }

    m_transparencyEnabled = enabled;
    emit appearanceSettingsChanged();
    saveConfiguration();
}

void PomodoroTimer::setNotificationSoundEnabled(bool enabled)
{
    if (m_notificationSoundEnabled == enabled)
    {
        return;
    }

    m_notificationSoundEnabled = enabled;
    emit notificationSettingsChanged();
    saveConfiguration();
}

double PomodoroTimer::windowOpacity() const { return m_windowOpacity; }
void PomodoroTimer::setWindowOpacity(double opacity)
{
    if (m_windowOpacity == opacity)
    {
        return;
    }

    m_windowOpacity = opacity;
    emit windowOpacityChanged();
    saveConfiguration();
}
int PomodoroTimer::notificationDurationMs() const { return m_notificationDurationMs; }

PomodoroStorage::Settings PomodoroTimer::currentSettings() const
{
    PomodoroStorage::Settings settings;
    settings.focusDurationSeconds = m_focusDurationSeconds;
    settings.shortBreakDurationSeconds = m_shortBreakDurationSeconds;
    settings.longBreakDurationSeconds = m_longBreakDurationSeconds;
    settings.notificationDurationMs = m_notificationDurationMs;
    settings.transparencyEnabled = m_transparencyEnabled;
    settings.notificationSoundEnabled = m_notificationSoundEnabled;
    settings.windowOpacity = m_windowOpacity;
    settings.focusGifSource = m_focusGifSource;
    settings.shortBreakGifSource = m_shortBreakGifSource;
    settings.longBreakGifSource = m_longBreakGifSource;
    settings.startGifSource = m_startGifSource;
    settings.pauseGifSource = m_pauseGifSource;
    return settings;
}

void PomodoroTimer::applySettings(const PomodoroStorage::Settings &settings)
{
    m_focusDurationSeconds = settings.focusDurationSeconds;
    m_shortBreakDurationSeconds = settings.shortBreakDurationSeconds;
    m_longBreakDurationSeconds = settings.longBreakDurationSeconds;
    m_notificationDurationMs = settings.notificationDurationMs;
    m_transparencyEnabled = settings.transparencyEnabled;
    m_notificationSoundEnabled = settings.notificationSoundEnabled;
    m_windowOpacity = settings.windowOpacity;
    m_focusGifSource = settings.focusGifSource;
    m_shortBreakGifSource = settings.shortBreakGifSource;
    m_longBreakGifSource = settings.longBreakGifSource;
    m_startGifSource = settings.startGifSource;
    m_pauseGifSource = settings.pauseGifSource;
}

void PomodoroTimer::saveConfiguration()
{
    QString storageError;
    if (!m_storage.saveSettings(currentSettings(), &storageError))
    {
        qWarning() << "No se pudo guardar la configuración SQLite:" << storageError;
    }
}

void PomodoroTimer::reloadConfiguration()
{
    QString storageError;
    PomodoroStorage::Settings settings = currentSettings();
    if (m_storage.loadSettings(&settings, &storageError))
    {
        applySettings(settings);
        if (!m_timer->isActive())
        {
            m_totalSeconds = m_isFocusMode ? m_focusDurationSeconds : m_shortBreakDurationSeconds;
            m_timeLeft = m_totalSeconds;
            updateTimeDisplay();
            emit sweepAngleChanged();
            updateControlButtonText();
        }
        updateCurrentGifSource();
        emit appearanceSettingsChanged();
        emit notificationSettingsChanged();
        emit windowOpacityChanged();
        qInfo() << "SQLite database at:" << m_storage.databasePath();
    }
    else
    {
        qWarning() << "No se pudo recargar la configuración SQLite:" << storageError;
    }
}

QString PomodoroTimer::databasePath() const
{
    return m_storage.databasePath();
}

QVariantList PomodoroTimer::recentSessionRecords(int limit) const
{
    QString storageError;
    return m_storage.recentSessionRecords(limit, &storageError);
}

void PomodoroTimer::clearHistory()
{
    QString storageError;
    if (!m_storage.clearSessionRecords(&storageError))
    {
        qWarning() << "Failed clearing session records:" << storageError;
    }
}

bool PomodoroTimer::exportHistoryCsv(const QString &path)
{
    QString storageError;
    const bool ok = m_storage.exportSessionRecordsCsv(path, &storageError);
    if (!ok)
    {
        qWarning() << "Failed exporting session records CSV:" << storageError;
    }
    return ok;
}

void PomodoroTimer::setFocusDurationSeconds(int seconds)
{
    if (seconds <= 0 || m_focusDurationSeconds == seconds)
    {
        return;
    }

    m_focusDurationSeconds = seconds;
    if (m_isFocusMode && !m_timer->isActive())
    {
        m_totalSeconds = seconds;
        m_timeLeft = seconds;
        updateTimeDisplay();
        emit sweepAngleChanged();
    }
    saveConfiguration();
}

void PomodoroTimer::setShortBreakDurationSeconds(int seconds)
{
    if (seconds <= 0 || m_shortBreakDurationSeconds == seconds)
    {
        return;
    }

    m_shortBreakDurationSeconds = seconds;
    saveConfiguration();
}

void PomodoroTimer::setLongBreakDurationSeconds(int seconds)
{
    if (seconds <= 0 || m_longBreakDurationSeconds == seconds)
    {
        return;
    }

    m_longBreakDurationSeconds = seconds;
    saveConfiguration();
}

void PomodoroTimer::setAssetSources(const QUrl &focusGif, const QUrl &shortBreakGif, const QUrl &longBreakGif, const QUrl &startGif, const QUrl &pauseGif)
{
    m_focusGifSource = focusGif;
    m_shortBreakGifSource = shortBreakGif;
    m_longBreakGifSource = longBreakGif;
    m_startGifSource = startGif;
    m_pauseGifSource = pauseGif;
    updateCurrentGifSource();
    saveConfiguration();
}

void PomodoroTimer::startTimer()
{
    if (m_timer->isActive())
    {
        m_timer->stop();
        m_running = false;
        m_paused = true;
        updateControlButtonText();
        updateCurrentGifSource();
    }
    else
    {
        m_timer->start(1000); // Dispara el slot 'tick' cada 1000 milisegundos (1 segundo)
        m_running = true;
        m_paused = false;
        updateControlButtonText();
        updateCurrentGifSource();
    }
}

void PomodoroTimer::resetTimer()
{
    m_timer->stop();
    m_running = false;
    m_paused = false;
    m_timeLeft = m_totalSeconds;
    m_sweepAngle = 360.0;
    m_stateStartedAt = QDateTime::currentDateTimeUtc();
    updateTimeDisplay();
    updateControlButtonText();
    updateCurrentGifSource();
    emit sweepAngleChanged();
}

void PomodoroTimer::resetAll()
{
    m_timer->stop();
    m_isFocusMode = true;
    m_currentCycle = 1;
    m_statusText = "Work Session";
    m_totalSeconds = m_focusDurationSeconds;
    m_timeLeft = m_totalSeconds;
    m_sweepAngle = 360.0;
    m_running = false;
    m_paused = false;
    m_stateStartedAt = QDateTime::currentDateTimeUtc();
    updateTimeDisplay();
    updateCurrentGifSource();
    emit statusTextChanged();
    emit currentCycleChanged();
    emit sweepAngleChanged();
    updateControlButtonText();
}

void PomodoroTimer::skipTimer()
{
    setNextState();
}

void PomodoroTimer::tick()
{
    if (m_timeLeft > 0)
    {
        m_timeLeft--;
        updateTimeDisplay();

        // Calculamos el ángulo matemático para el anillo
        m_sweepAngle = (static_cast<double>(m_timeLeft) / m_totalSeconds) * 360.0;
        emit sweepAngleChanged();
    }
    else
    {
        setNextState();
    }
}

void PomodoroTimer::updateTimeDisplay()
{
    int minutes = m_timeLeft / 60;
    int seconds = m_timeLeft % 60;

    // Formateamos para que siempre tenga dos dígitos (ej. "09:05")
    QString newDisplay = QString("%1:%2")
                             .arg(minutes, 2, 10, QLatin1Char('0'))
                             .arg(seconds, 2, 10, QLatin1Char('0'));

    if (m_timeDisplay != newDisplay)
    {
        m_timeDisplay = newDisplay;
        emit timeDisplayChanged();
    }
}

void PomodoroTimer::setNextState()
{
    const QString previousState = m_statusText;
    const QString nextState = m_isFocusMode
                                  ? (m_currentCycle % 4 != 0 ? QStringLiteral("Short break") : QStringLiteral("Long break"))
                                  : QStringLiteral("Work Session");

    persistSessionRecord(previousState, nextState);

    m_timer->stop();
    m_running = false;
    m_paused = false;

    if (m_isFocusMode)
    {
        if (m_currentCycle % 4 != 0)
        {
            m_isFocusMode = false;
            m_statusText = "Short break";
            m_totalSeconds = m_shortBreakDurationSeconds;
        }
        else
        {
            m_isFocusMode = false;
            m_statusText = "Long break";
            m_totalSeconds = m_longBreakDurationSeconds;
        }
    }
    else
    {
        m_isFocusMode = true;
        m_statusText = "Work Session";
        m_totalSeconds = m_focusDurationSeconds;
        m_currentCycle++;
        emit currentCycleChanged();
    }

    emit statusTextChanged();

    // Enviamos notificación del sistema indicando el cambio de estado
    QString title = previousState + " finished";
    QString body = "Now: " + m_statusText;
    showNotification(title, body);
    playNotificationSound();
    m_stateStartedAt = QDateTime::currentDateTimeUtc();
    resetTimer();
    startTimer(); // Opcional: inicia automáticamente el siguiente ciclo
}

void PomodoroTimer::persistSessionRecord(const QString &fromState, const QString &toState)
{
    QString storageError;
    PomodoroStorage::SessionRecord record;
    record.fromState = fromState;
    record.toState = toState;
    record.startedAt = m_stateStartedAt;
    record.endedAt = QDateTime::currentDateTimeUtc();
    record.cycle = m_currentCycle;
    record.durationSeconds = m_totalSeconds;
    record.completed = true;

    if (!m_storage.insertSessionRecord(record, &storageError))
    {
        qWarning() << "No se pudo guardar el registro de sesión SQLite:" << storageError;
    }
}

void PomodoroTimer::updateCurrentGifSource()
{
    QUrl newSource;

    if (m_running)
    {
        newSource = m_isFocusMode ? m_focusGifSource : m_shortBreakGifSource;
        if (m_statusText == "Long break")
        {
            newSource = m_longBreakGifSource;
        }
    }
    else if (m_paused)
    {
        newSource = m_pauseGifSource;
    }
    else
    {
        newSource = m_startGifSource;
    }

    if (m_currentGifSource != newSource)
    {
        m_currentGifSource = newSource;
        emit currentGifSourceChanged();
    }
}

void PomodoroTimer::showNotification(const QString &title, const QString &message)
{
    if (m_trayIcon && QSystemTrayIcon::isSystemTrayAvailable())
    {
        m_trayIcon->showMessage(title, message, QSystemTrayIcon::Information, m_notificationDurationMs);
    }
}

void PomodoroTimer::playNotificationSound()
{
    if (m_notificationSoundEnabled)
    {
        QApplication::beep();
    }
}

void PomodoroTimer::updateControlButtonText()
{
    QString newText;

    if (m_running)
    {
        newText = "⏸\nPause";
    }
    else if (m_paused)
    {
        newText = "▶\nResume";
    }
    else
    {
        newText = "▶\nStart";
    }

    if (m_controlButtonText != newText)
    {
        m_controlButtonText = newText;
        emit controlButtonTextChanged();
    }
}