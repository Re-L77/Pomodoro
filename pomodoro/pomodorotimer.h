#pragma once
#include <QObject>
#include <QTimer>
#include <QString>
#include <QUrl>
#include <QDateTime>
#include <QtQml/qqmlregistration.h>
#include <QVariant>
#include <QVariantList>
class QSystemTrayIcon;

#include "pomodorostorage.h"

class PomodoroTimer : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString timeDisplay READ timeDisplay NOTIFY timeDisplayChanged)
    Q_PROPERTY(QString statusText READ statusText NOTIFY statusTextChanged)
    Q_PROPERTY(QString controlButtonText READ controlButtonText NOTIFY controlButtonTextChanged)
    Q_PROPERTY(double sweepAngle READ sweepAngle NOTIFY sweepAngleChanged)
    Q_PROPERTY(int currentCycle READ currentCycle NOTIFY currentCycleChanged)
    Q_PROPERTY(QUrl currentGifSource READ currentGifSource NOTIFY currentGifSourceChanged)
    Q_PROPERTY(QUrl focusGifSource READ focusGifSource CONSTANT)
    Q_PROPERTY(QUrl shortBreakGifSource READ shortBreakGifSource CONSTANT)
    Q_PROPERTY(QUrl longBreakGifSource READ longBreakGifSource CONSTANT)
    Q_PROPERTY(QUrl startGifSource READ startGifSource CONSTANT)
    Q_PROPERTY(QUrl pauseGifSource READ pauseGifSource CONSTANT)
    Q_PROPERTY(int focusDurationSeconds READ focusDurationSeconds CONSTANT)
    Q_PROPERTY(int shortBreakDurationSeconds READ shortBreakDurationSeconds CONSTANT)
    Q_PROPERTY(int longBreakDurationSeconds READ longBreakDurationSeconds CONSTANT)
    Q_PROPERTY(bool transparencyEnabled READ transparencyEnabled WRITE setTransparencyEnabled NOTIFY appearanceSettingsChanged)
    Q_PROPERTY(bool notificationSoundEnabled READ notificationSoundEnabled WRITE setNotificationSoundEnabled NOTIFY notificationSettingsChanged)
    Q_PROPERTY(int notificationDurationMs READ notificationDurationMs CONSTANT)
    Q_PROPERTY(double windowOpacity READ windowOpacity WRITE setWindowOpacity NOTIFY windowOpacityChanged)

public:
    explicit PomodoroTimer(QObject *parent = nullptr);

    QString timeDisplay() const;
    QString statusText() const;
    QString controlButtonText() const;
    double sweepAngle() const;
    int currentCycle() const;
    QUrl currentGifSource() const;
    QUrl focusGifSource() const;
    QUrl shortBreakGifSource() const;
    QUrl longBreakGifSource() const;
    QUrl startGifSource() const;
    QUrl pauseGifSource() const;
    int focusDurationSeconds() const;
    int shortBreakDurationSeconds() const;
    int longBreakDurationSeconds() const;
    bool transparencyEnabled() const;
    void setTransparencyEnabled(bool enabled);
    bool notificationSoundEnabled() const;
    void setNotificationSoundEnabled(bool enabled);
    int notificationDurationMs() const;
    double windowOpacity() const;
    void setWindowOpacity(double opacity);

    Q_INVOKABLE void setFocusDurationSeconds(int seconds);
    Q_INVOKABLE void setShortBreakDurationSeconds(int seconds);
    Q_INVOKABLE void setLongBreakDurationSeconds(int seconds);
    Q_INVOKABLE void setAssetSources(const QUrl &focusGif, const QUrl &shortBreakGif, const QUrl &longBreakGif, const QUrl &startGif, const QUrl &pauseGif);
    Q_INVOKABLE void saveConfiguration();
    Q_INVOKABLE void reloadConfiguration();
    Q_INVOKABLE QString databasePath() const;
    Q_INVOKABLE void clearHistory();
    Q_INVOKABLE bool exportHistoryCsv(const QString &path);
    Q_INVOKABLE QVariantList recentSessionRecords(int limit = 20) const;

    Q_INVOKABLE void startTimer();
    Q_INVOKABLE void resetTimer();
    Q_INVOKABLE void resetAll();
    Q_INVOKABLE void skipTimer();

signals:
    void timeDisplayChanged();
    void statusTextChanged();
    void controlButtonTextChanged();
    void sweepAngleChanged();
    void currentCycleChanged();
    void currentGifSourceChanged();
    void appearanceSettingsChanged();
    void notificationSettingsChanged();
    void windowOpacityChanged();

private slots:
    void tick();

private:
    void updateTimeDisplay();
    void setNextState();
    void updateCurrentGifSource();
    void applySettings(const PomodoroStorage::Settings &settings);
    PomodoroStorage::Settings currentSettings() const;

    void showNotification(const QString &title, const QString &message);
    void playNotificationSound();
    void persistSessionRecord(const QString &fromState, const QString &toState);

    QUrl m_focusGifSource;
    QUrl m_shortBreakGifSource;
    QUrl m_longBreakGifSource;
    QUrl m_startGifSource;
    QUrl m_pauseGifSource;
    QUrl m_currentGifSource;

    int m_focusDurationSeconds;
    int m_shortBreakDurationSeconds;
    int m_longBreakDurationSeconds;
    int m_notificationDurationMs;

    bool m_transparencyEnabled = false;
    bool m_notificationSoundEnabled = true;
    double m_windowOpacity = 1.0;

    QTimer *m_timer;
    int m_totalSeconds;
    int m_timeLeft;
    bool m_isFocusMode;
    int m_currentCycle;

    QSystemTrayIcon *m_trayIcon = nullptr;

    QString m_timeDisplay;
    QString m_statusText;
    QString m_controlButtonText;
    double m_sweepAngle;

    bool m_running = false;
    bool m_paused = false;

    void updateControlButtonText();

    PomodoroStorage m_storage;
    QDateTime m_stateStartedAt;
};