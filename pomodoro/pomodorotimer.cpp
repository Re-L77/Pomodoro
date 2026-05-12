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
#include <QMediaPlayer>
#include <QAudioOutput>

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
        m_trayIcon->setToolTip(QStringLiteral("Pomodoro Timer"));
        setupTrayMenu();
        m_trayIcon->show();

        connect(m_trayIcon, &QSystemTrayIcon::activated, this, [this](QSystemTrayIcon::ActivationReason reason) {
            if (reason == QSystemTrayIcon::Trigger || reason == QSystemTrayIcon::DoubleClick)
            {
                emit requestShowWindow();
            }
        });
    }
    else
    {
        m_trayIcon = nullptr;
    }

    // Inicializamos el reproductor de audio con el tuturu
    m_audioOutput = new QAudioOutput(this);
    m_audioOutput->setVolume(1.0f);
    m_notificationPlayer = new QMediaPlayer(this);
    m_notificationPlayer->setAudioOutput(m_audioOutput);
    m_notificationPlayer->setSource(QUrl(QStringLiteral("qrc:/qt/qml/pomodoro/assets/tuturu_1.mp3")));

    reloadConfiguration();
    restoreTimerState();
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
}

void PomodoroTimer::setNotificationSoundEnabled(bool enabled)
{
    if (m_notificationSoundEnabled == enabled)
    {
        return;
    }

    m_notificationSoundEnabled = enabled;
    emit notificationSettingsChanged();
}

double PomodoroTimer::windowOpacity() const { return m_windowOpacity; }
void PomodoroTimer::setWindowOpacity(double opacity)
{
    if (qFuzzyCompare(m_windowOpacity, opacity))
    {
        return;
    }

    m_windowOpacity = opacity;
    emit windowOpacityChanged();
}
int PomodoroTimer::notificationDurationMs() const { return m_notificationDurationMs; }

int PomodoroTimer::fontSize() const { return m_fontSize; }
void PomodoroTimer::setFontSize(int size)
{
    if (size < 8) size = 8;
    if (size > 32) size = 32;
    if (m_fontSize == size) return;
    m_fontSize = size;
    emit fontSizeChanged();
}

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
    settings.fontSize = m_fontSize;
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
    m_fontSize = settings.fontSize;
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
    else
    {
        logEvent(QStringLiteral("config_save"), QStringLiteral("Settings saved"));
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
        emit fontSizeChanged();
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
        logEvent(QStringLiteral("pause"), m_statusText);
        updateControlButtonText();
        updateCurrentGifSource();
    }
    else
    {
        if (m_paused)
        {
            logEvent(QStringLiteral("resume"), m_statusText);
        }
        else
        {
            logEvent(QStringLiteral("start"), m_statusText);
        }
        m_timer->start(1000);
        m_running = true;
        m_paused = false;
        updateControlButtonText();
        updateCurrentGifSource();
    }
    saveTimerState();
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
    logEvent(QStringLiteral("reset"), QStringLiteral("Full reset"));
    saveTimerState();
}

void PomodoroTimer::skipTimer()
{
    logEvent(QStringLiteral("skip"), m_statusText + QStringLiteral(" skipped"));
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

        // Persist state every 30 seconds to survive crashes
        if (m_timeLeft % 30 == 0)
        {
            saveTimerState();
        }
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
    logEvent(QStringLiteral("transition"), previousState + QStringLiteral(" → ") + nextState);

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
        m_notificationPlayer->setPosition(0);
        m_notificationPlayer->play();
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

void PomodoroTimer::logEvent(const QString &action, const QString &detail)
{
    QString storageError;
    if (!m_storage.insertEventLog(action, detail, m_currentCycle, &storageError))
    {
        qWarning() << "Failed to insert event log:" << storageError;
    }
}

void PomodoroTimer::saveTimerState()
{
    PomodoroStorage::TimerState state;
    state.isFocusMode = m_isFocusMode;
    state.currentCycle = m_currentCycle;
    state.timeLeft = m_timeLeft;
    state.totalSeconds = m_totalSeconds;
    state.statusText = m_statusText;
    state.running = m_running;
    state.paused = m_paused;

    QString storageError;
    if (!m_storage.saveTimerState(state, &storageError))
    {
        qWarning() << "Failed to save timer state:" << storageError;
    }
}

void PomodoroTimer::restoreTimerState()
{
    PomodoroStorage::TimerState state;
    QString storageError;
    if (!m_storage.loadTimerState(&state, &storageError))
    {
        qWarning() << "Failed to load timer state:" << storageError;
        return;
    }

    // Only restore if there's a saved state with valid totalSeconds
    if (state.totalSeconds <= 0)
    {
        return;
    }

    m_isFocusMode = state.isFocusMode;
    m_currentCycle = state.currentCycle;
    m_timeLeft = state.timeLeft;
    m_totalSeconds = state.totalSeconds;
    m_statusText = state.statusText;
    // Always restore as paused (never auto-start on relaunch)
    m_running = false;
    m_paused = state.running || state.paused;

    updateTimeDisplay();
    updateControlButtonText();
    updateCurrentGifSource();

    m_sweepAngle = (static_cast<double>(m_timeLeft) / m_totalSeconds) * 360.0;
    emit sweepAngleChanged();
    emit statusTextChanged();
    emit currentCycleChanged();

    logEvent(QStringLiteral("app_start"), QStringLiteral("State restored from previous session"));
}

QVariantList PomodoroTimer::recentEventLogs(int limit) const
{
    QString storageError;
    return m_storage.recentEventLogs(limit, &storageError);
}

void PomodoroTimer::clearEventLogs()
{
    QString storageError;
    if (!m_storage.clearEventLogs(&storageError))
    {
        qWarning() << "Failed clearing event logs:" << storageError;
    }
}

void PomodoroTimer::setupTrayMenu()
{
    m_trayMenu = new QMenu();
    m_trayMenu->setTitle(QStringLiteral("Pomodoro"));

    QAction *showAction = m_trayMenu->addAction(QStringLiteral("Show Pomodoro"));
    connect(showAction, &QAction::triggered, this, [this]() {
        emit requestShowWindow();
    });

    m_trayMenu->addSeparator();

    QAction *exitAction = m_trayMenu->addAction(QStringLiteral("Exit"));
    connect(exitAction, &QAction::triggered, this, [this]() {
        emit requestQuit();
    });

    m_trayIcon->setContextMenu(m_trayMenu);
}