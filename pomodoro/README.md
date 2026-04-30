# 🍅 Pomodoro Timer - Aplicación Qt6 + QML

Una aplicación moderna de técnica Pomodoro con interfaz gráfica usando **Qt6** y **QML**, compilada con **CMake**.

## 📋 Tabla de Contenidos

1. [¿Qué es la Técnica Pomodoro?](#qué-es-la-técnica-pomodoro)
2. [Características](#características)
3. [Arquitectura del Proyecto](#arquitectura-del-proyecto)
4. [Conceptos de C++ Utilizados](#conceptos-de-c-utilizados)
5. [Estructura de Archivos](#estructura-de-archivos)
6. [Compilación y Ejecución](#compilación-y-ejecución)
7. [Cómo Funciona el Código](#cómo-funciona-el-código)
8. [Extensiones y Mejoras](#extensiones-y-mejoras)

---

## 🍅 ¿Qué es la Técnica Pomodoro?

La **técnica Pomodoro** es un método de gestión de tiempo que:

```
Ciclo Completo = 4 Pomodoros (25 min trabajo + 5 min descanso) + 15 min descanso largo
```

**En esta aplicación (versión testing):**
- ⏱️ Tiempo de trabajo: 5 segundos (cambiar a 1500 en producción = 25 minutos)
- ☕ Descanso corto: 5 segundos (cambiar a 300 = 5 minutos)
- 😴 Descanso largo: 10 segundos (cambiar a 900 = 15 minutos, después del 4º ciclo)

---

## ✨ Características

- ✅ **Temporizador automático** con anillo de progreso visual
- ✅ **Contador de ciclos** (Pomodoros completados)
- ✅ **Estados dinámicos**: "Work Session", "Short Break", "Long Break"
- ✅ **Botones de control**: Start, Reset, Skip
- ✅ **Interfaz moderna** con diseño visual atractivo
- ✅ **Animaciones suaves** en el anillo de progreso
- ✅ **GIF animado** que cambia según el estado

---

## 🏗️ Arquitectura del Proyecto

### Diagrama de Componentes

```
┌─────────────────────────────────────────────────────┐
│                  APLICACIÓN POMODORO                 │
├─────────────────────────────────────────────────────┤
│                                                       │
│  ┌──────────────────────────────────────────────┐   │
│  │           CAPA DE PRESENTACIÓN (QML)        │   │
│  │  ┌─────────────────────────────────────┐   │   │
│  │  │  Main.qml                           │   │   │
│  │  │  - Interfaz gráfica                 │   │   │
│  │  │  - Botones (Start, Reset, Skip)     │   │   │
│  │  │  - Anillo de progreso               │   │   │
│  │  │  - Contador de ciclos               │   │   │
│  │  └─────────────────────────────────────┘   │   │
│  └──────────────────────────────────────────────┘   │
│                          ▲                            │
│                          │ Propiedades vinculadas    │
│                          │ (Bindings)               │
│                          ▼                            │
│  ┌──────────────────────────────────────────────┐   │
│  │        CAPA DE LÓGICA (C++/Qt)              │   │
│  │  ┌─────────────────────────────────────┐   │   │
│  │  │  PomodoroTimer (QObject)            │   │   │
│  │  │  - Gestión del temporizador         │   │   │
│  │  │  - Lógica de estados                │   │   │
│  │  │  - Cálculo de progreso              │   │   │
│  │  └─────────────────────────────────────┘   │   │
│  └──────────────────────────────────────────────┘   │
│                          ▲                            │
│                          │ QTimer (sistema)         │
│                          │ Tick cada 1000ms         │
│                          ▼                            │
│  ┌──────────────────────────────────────────────┐   │
│  │        CAPA DE SISTEMA (Qt Core)            │   │
│  │  ┌─────────────────────────────────────┐   │   │
│  │  │  QTimer                              │   │   │
│  │  │  - Generador de eventos periódicos   │   │   │
│  │  └─────────────────────────────────────┘   │   │
│  └──────────────────────────────────────────────┘   │
│                                                       │
└─────────────────────────────────────────────────────┘
```

### Diagrama de Flujo de Estados

```
                        ┌─────────────────┐
                        │  APLICACIÓN INI │
                        │  (Ciclo 1)      │
                        └────────┬────────┘
                                 │
                    ┌────────────▼────────────┐
                    │  WORK SESSION (5 seg)   │
                    │  Modo: isFocusMode=true │
                    └────────────┬────────────┘
                                 │
                    [Usuario presiona Start]
                                 │
                    ┌────────────▼────────────┐
                    │  CONTANDO (Tick)        │
                    │  timeLeft--             │
                    │  sweepAngle decrece     │
                    └────────────┬────────────┘
                                 │
                        ¿Tiempo terminado?
                        │          │
                   NO   │          │   SÍ
                        ▼          ▼
                    Esperar    Pasar estado
                              siguiente
                              │
                ┌─────────────┴──────────────┐
                │                            │
         ¿Es ciclo 4? (currentCycle % 4 == 0)
         │                                  │
    NO   ▼                                   ▼  SÍ
    SHORT BREAK            LONG BREAK (10 seg)
    (5 seg)                │
    │                      │
    Ciclo++        ┌───────▴────────┐
    │              │ Luego          │
    └──────────────► SHORT BREAK    │
                    │ Ciclo++       │
                    ▼               │
                 Repite            │
                 de nuevo          │
                                   └────────►
```

---

## 🔧 Conceptos de C++ Utilizados

### 1. **Clases y Herencia (QObject)**

```cpp
class PomodoroTimer : public QObject  // Hereda de QObject de Qt
{
    Q_OBJECT  // Macro necesaria para usar signals/slots
    // ...
};
```

**¿Qué es QObject?**
- Clase base de Qt que proporciona:
  - Sistema de propiedades (Q_PROPERTY)
  - Señales y slots (mecanismo observer)
  - Gestión automática de memoria

### 2. **Propiedades (Q_PROPERTY)**

```cpp
Q_PROPERTY(QString timeDisplay READ timeDisplay NOTIFY timeDisplayChanged)
```

- **READ**: Función getter para leer el valor
- **NOTIFY**: Señal emitida cuando cambia
- Permite vinculación automática con QML

### 3. **Señales y Slots (Signals/Slots)**

```cpp
signals:
    void timeDisplayChanged();  // Señal

private slots:
    void tick();               // Slot (método que responde a señales)
```

**Sistema de comunicación entre objetos:**
- Las **señales** notifican cambios
- Los **slots** responden a esos cambios
- Totalmente desacoplado (loose coupling)

### 4. **Pointers e Inicialización de Miembros**

```cpp
PomodoroTimer::PomodoroTimer(QObject *parent)
    : QObject(parent),
      m_timer(new QTimer(this)),  // Constructor de inicialización
      m_isFocusMode(true),
      m_currentCycle(1)
{
}
```

- `m_timer(new QTimer(this))`: Crea objeto dinamicamente
- `this`: Qt gestiona automáticamente la memoria

### 5. **Métodos Invocables (Q_INVOKABLE)**

```cpp
Q_INVOKABLE void startTimer();
Q_INVOKABLE void resetAll();
```

- Pueden ser llamados desde QML
- Puente entre C++ y la interfaz gráfica

### 6. **QString y Formateo**

```cpp
QString newDisplay = QString("%1:%2")
    .arg(minutes, 2, 10, QLatin1Char('0'))
    .arg(seconds, 2, 10, QLatin1Char('0'));
```

- `%1, %2`: Placeholders
- `.arg()`: Reemplaza placeholders (parecido a printf)
- `2, 10, QLatin1Char('0')`: Formato (2 dígitos, base 10, rellenado con '0')

### 7. **Operadores Ternarios y Condicionales**

```cpp
if (m_currentCycle % 4 != 0)  // Si NO es múltiplo de 4
{
    m_statusText = "Short break";
}
else  // Si es múltiplo de 4
{
    m_statusText = "Long break";
}
```

### 8. **Emit (Emisión de Señales)**

```cpp
emit timeDisplayChanged();  // Notifica que la propiedad cambió
```

Todas las vistas vinculadas a esta propiedad se actualizarán automáticamente.

---

## 📁 Estructura de Archivos

```
pomodoro/
├── CMakeLists.txt          # Configuración de compilación (CMake)
├── main.cpp                # Punto de entrada (main)
├── pomodorotimer.h         # Declaración de la clase (Header)
├── pomodorotimer.cpp       # Implementación de la clase
├── Main.qml                # Interfaz gráfica (QML)
├── assets/                 # Recursos (GIFs)
│   ├── focus.gif
│   ├── focus2.gif
│   └── break.gif
└── build/                  # Directorio de compilación
    ├── apppomodoro         # Ejecutable compilado
    └── ... (archivos generados)
```

---

## 🔨 Compilación y Ejecución

### Requisitos Previos

```bash
# En Ubuntu/Debian
sudo apt install qt6-base-dev qt6-qml-dev qt6-quick-dev cmake

# En macOS (con Homebrew)
brew install qt cmake
```

### Pasos de Compilación

```bash
# 1. Navegar al directorio del proyecto
cd /home/teto/dev/Personal/AFN2/pomodoro

# 2. Crear directorio de compilación
mkdir -p build
cd build

# 3. Configurar CMake
cmake ..

# 4. Compilar
cmake --build .

# 5. Ejecutar
./apppomodoro
```

### O en Una Sola Línea

```bash
cd pomodoro && mkdir -p build && cd build && cmake .. && cmake --build . && ./apppomodoro
```

---

## 💻 Cómo Funciona el Código

### 1. **Inicialización (Constructor)**

```cpp
PomodoroTimer::PomodoroTimer(QObject *parent)
    : QObject(parent),
      m_timer(new QTimer(this)),      // Crear timer
      m_isFocusMode(true),             // Comenzar en modo trabajo
      m_currentCycle(1)                // Ciclo 1
{
    m_totalSeconds = 5;                // 5 segundos para testing
    m_timeLeft = m_totalSeconds;       // Inicializar tiempo restante
    m_statusText = "Work Session";     // Estado inicial
    m_sweepAngle = 360.0;              // Anillo completo
    updateTimeDisplay();               // Mostrar "00:05"
    
    // Conectar el timer a la función tick
    connect(m_timer, &QTimer::timeout, this, &PomodoroTimer::tick);
}
```

**¿Qué hace cada línea?**
- `m_timer(new QTimer(this))`: Crea un temporizador
- `connect()`: Cada 1000ms, llama a `tick()`

### 2. **Secuencia de Ejecución**

```
USUARIO HACE CLICK EN "START"
        ↓
    startTimer()
        ↓
    m_timer->start(1000)  // Inicia timer cada 1 segundo
        ↓
    ┌───────────────────┐
    │  Cada 1000ms:     │
    │  tick() ejecuta:  │
    │  - m_timeLeft--   │
    │  - Actualizar UI  │
    │  - Emitir señales │
    └───────────────────┘
        ↓
    ¿m_timeLeft == 0?
    NO → Repite tick()
    SÍ  → setNextState()
         - Pasar a descanso
         - Incrementar ciclo
         - Reiniciar timer
```

### 3. **Cálculo del Anillo de Progreso**

```cpp
// Proporción de tiempo restante
m_sweepAngle = (m_timeLeft / m_totalSeconds) * 360.0;

// Ejemplo:
// - m_timeLeft = 2 segundos
// - m_totalSeconds = 5 segundos
// - m_sweepAngle = (2/5) * 360 = 144 grados
```

### 4. **Cambio de Estados**

```cpp
void PomodoroTimer::setNextState()
{
    if (m_isFocusMode)  // Si estamos trabajando
    {
        if (m_currentCycle % 4 != 0)  // No es el 4º ciclo
        {
            // Descanso corto
            m_statusText = "Short break";
            m_totalSeconds = 5;
        }
        else  // Es el 4º ciclo
        {
            // Descanso largo
            m_statusText = "Long break";
            m_totalSeconds = 10;
        }
        m_isFocusMode = false;
    }
    else  // Si estamos descansando
    {
        // Volver al trabajo
        m_isFocusMode = true;
        m_statusText = "Work Session";
        m_totalSeconds = 5;
        m_currentCycle++;  // Incrementar ciclo
        emit currentCycleChanged();  // Notificar UI
    }
    
    resetTimer();     // Resetear tiempo actual
    startTimer();     // Iniciar automáticamente
}
```

### 5. **Reset Completo**

```cpp
void PomodoroTimer::resetAll()
{
    m_timer->stop();                   // Pausar timer
    m_isFocusMode = true;              // Volver a modo trabajo
    m_currentCycle = 1;                // Reset contador
    m_statusText = "Work Session";     // Estado inicial
    m_totalSeconds = 5;                // Tiempo inicial
    m_timeLeft = m_totalSeconds;
    m_sweepAngle = 360.0;              // Anillo completo
    updateTimeDisplay();
    
    // Emitir todas las señales para actualizar UI
    emit statusTextChanged();
    emit currentCycleChanged();
    emit sweepAngleChanged();
}
```

---

## 🚀 Extensiones y Mejoras

### Idea 1: Agregar Sonidos

```cpp
// En pomodorotimer.h
#include <QSoundEffect>

private:
    QSoundEffect *m_soundEffect;

// En pomodorotimer.cpp (constructor)
m_soundEffect = new QSoundEffect(this);
m_soundEffect->setSource(QUrl("qrc:///assets/notification.wav"));

// En setNextState()
void PomodoroTimer::setNextState()
{
    // ... código existente ...
    
    m_soundEffect->play();  // Reproducir sonido al cambiar estado
}
```

### Idea 2: Persistencia (Guardar Progreso)

```cpp
// En pomodorotimer.h
#include <QSettings>

// En pomodorotimer.cpp
void PomodoroTimer::saveProgress()
{
    QSettings settings("Pomodoro", "Timer");
    settings.setValue("currentCycle", m_currentCycle);
    settings.setValue("timeLeft", m_timeLeft);
    settings.setValue("isFocusMode", m_isFocusMode);
}

void PomodoroTimer::loadProgress()
{
    QSettings settings("Pomodoro", "Timer");
    m_currentCycle = settings.value("currentCycle", 1).toInt();
    m_timeLeft = settings.value("timeLeft", m_totalSeconds).toInt();
    m_isFocusMode = settings.value("isFocusMode", true).toBool();
}
```

### Idea 3: Historial de Ciclos Completados

```cpp
// En pomodorotimer.h
private:
    int m_completedCycles;  // Total de ciclos completados hoy
    QDateTime m_startTime;

Q_PROPERTY(int completedCycles READ completedCycles NOTIFY completedCyclesChanged)

// En pomodorotimer.cpp
void PomodoroTimer::setNextState()
{
    // ... código existente ...
    
    if (!m_isFocusMode && m_currentCycle > 1)
    {
        m_completedCycles++;
        emit completedCyclesChanged();
    }
}
```

### Idea 4: Notificaciones del Sistema

```cpp
// En pomodorotimer.h
#include <QDBusInterface>

// En pomodorotimer.cpp
void PomodoroTimer::showNotification(const QString &title, const QString &message)
{
    QDBusInterface notif("org.freedesktop.Notifications",
                        "/org/freedesktop/Notifications",
                        "org.freedesktop.Notifications",
                        QDBusConnection::sessionBus());
    
    QList<QVariant> args;
    args << "pomodoro" << uint(0) << "" << title << message << QStringList() << QVariantMap() << int(5000);
    notif.callWithArgumentList(QDBus::NoBlock, "Notify", args);
}
```

### Idea 5: Cambiar Duraciones (Configuración)

```cpp
// En pomodorotimer.h
Q_INVOKABLE void setWorkDuration(int seconds);
Q_INVOKABLE void setBreakDuration(int seconds);

private:
    int m_workDuration;
    int m_breakDuration;

// En pomodorotimer.cpp
void PomodoroTimer::setWorkDuration(int seconds)
{
    m_workDuration = seconds;
    if (m_isFocusMode)
    {
        m_totalSeconds = seconds;
        resetTimer();
    }
}
```

### Idea 6: Temporizador Pausa

```cpp
// En pomodorotimer.h
Q_INVOKABLE void pauseTimer();
Q_INVOKABLE void resumeTimer();

private:
    bool m_isPaused;

// En pomodorotimer.cpp
void PomodoroTimer::pauseTimer()
{
    m_timer->stop();
    m_isPaused = true;
}

void PomodoroTimer::resumeTimer()
{
    if (m_isPaused)
    {
        m_timer->start(1000);
        m_isPaused = false;
    }
}
```

---

## 📚 Recursos para Aprender Más

### Qt/C++:
- [Qt Documentation Oficial](https://doc.qt.io/)
- [Qt Signals and Slots](https://doc.qt.io/qt-6/signalsandslots.html)
- [QML and C++ Integration](https://doc.qt.io/qt-6/qtqml-cppintegration-overview.html)

### C++ Moderno:
- [C++ Reference](https://en.cppreference.com/)
- [Smart Pointers](https://en.cppreference.com/w/cpp/memory)

### CMake:
- [CMake Documentation](https://cmake.org/cmake/help/latest/)
- [Qt and CMake](https://doc.qt.io/qt-6/cmake-manual.html)

---

## 📝 Notas Importantes

- ⚠️ **Tiempos de Testing**: Los tiempos están en segundos (5s, 10s) para facilitar pruebas. En producción, cambiar a minutos (1500s = 25 min, 300s = 5 min, 900s = 15 min)
- 🔄 **Ciclo Automático**: El timer automáticamente avanza al siguiente estado
- 🎨 **Interfaz Responsiva**: Los cambios en C++ automáticamente actualizan QML
- 🔗 **Vinculación de Datos**: QML está vinculado a propiedades C++ en tiempo real

---

## 🤝 Contribuciones

¿Ideas para mejorar? Puedes:
1. Agregar más estados (ej: "Pausa manual")
2. Implementar estadísticas
3. Crear temas personalizados
4. Agregar sincronización con calendario

---

**Última actualización**: Abril 2026
**Versión**: 0.1 (Testing)
**Autor**: Tu Nombre
**Licencia**: MIT
