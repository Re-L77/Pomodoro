/****************************************************************************
** Meta object code from reading C++ file 'pomodorotimer.h'
**
** Created by: The Qt Meta Object Compiler version 69 (Qt 6.11.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../../pomodorotimer.h"
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'pomodorotimer.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 69
#error "This file was generated using the moc from 6.11.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

#ifndef Q_CONSTINIT
#define Q_CONSTINIT
#endif

QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
QT_WARNING_DISABLE_GCC("-Wuseless-cast")
namespace {
struct qt_meta_tag_ZN13PomodoroTimerE_t {};
} // unnamed namespace

template <> constexpr inline auto PomodoroTimer::qt_create_metaobjectdata<qt_meta_tag_ZN13PomodoroTimerE_t>()
{
    namespace QMC = QtMocConstants;
    QtMocHelpers::StringRefStorage qt_stringData {
        "PomodoroTimer",
        "QML.Element",
        "auto",
        "timeDisplayChanged",
        "",
        "statusTextChanged",
        "controlButtonTextChanged",
        "sweepAngleChanged",
        "currentCycleChanged",
        "currentGifSourceChanged",
        "notificationSettingsChanged",
        "tick",
        "setFocusDurationSeconds",
        "seconds",
        "setShortBreakDurationSeconds",
        "setLongBreakDurationSeconds",
        "setAssetSources",
        "QUrl",
        "focusGif",
        "shortBreakGif",
        "longBreakGif",
        "startGif",
        "pauseGif",
        "saveConfiguration",
        "reloadConfiguration",
        "databasePath",
        "startTimer",
        "resetTimer",
        "resetAll",
        "skipTimer",
        "timeDisplay",
        "statusText",
        "controlButtonText",
        "sweepAngle",
        "currentCycle",
        "currentGifSource",
        "focusGifSource",
        "shortBreakGifSource",
        "longBreakGifSource",
        "startGifSource",
        "pauseGifSource",
        "focusDurationSeconds",
        "shortBreakDurationSeconds",
        "longBreakDurationSeconds",
        "notificationSoundEnabled",
        "notificationDurationMs"
    };

    QtMocHelpers::UintData qt_methods {
        // Signal 'timeDisplayChanged'
        QtMocHelpers::SignalData<void()>(3, 4, QMC::AccessPublic, QMetaType::Void),
        // Signal 'statusTextChanged'
        QtMocHelpers::SignalData<void()>(5, 4, QMC::AccessPublic, QMetaType::Void),
        // Signal 'controlButtonTextChanged'
        QtMocHelpers::SignalData<void()>(6, 4, QMC::AccessPublic, QMetaType::Void),
        // Signal 'sweepAngleChanged'
        QtMocHelpers::SignalData<void()>(7, 4, QMC::AccessPublic, QMetaType::Void),
        // Signal 'currentCycleChanged'
        QtMocHelpers::SignalData<void()>(8, 4, QMC::AccessPublic, QMetaType::Void),
        // Signal 'currentGifSourceChanged'
        QtMocHelpers::SignalData<void()>(9, 4, QMC::AccessPublic, QMetaType::Void),
        // Signal 'notificationSettingsChanged'
        QtMocHelpers::SignalData<void()>(10, 4, QMC::AccessPublic, QMetaType::Void),
        // Slot 'tick'
        QtMocHelpers::SlotData<void()>(11, 4, QMC::AccessPrivate, QMetaType::Void),
        // Method 'setFocusDurationSeconds'
        QtMocHelpers::MethodData<void(int)>(12, 4, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Int, 13 },
        }}),
        // Method 'setShortBreakDurationSeconds'
        QtMocHelpers::MethodData<void(int)>(14, 4, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Int, 13 },
        }}),
        // Method 'setLongBreakDurationSeconds'
        QtMocHelpers::MethodData<void(int)>(15, 4, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Int, 13 },
        }}),
        // Method 'setAssetSources'
        QtMocHelpers::MethodData<void(const QUrl &, const QUrl &, const QUrl &, const QUrl &, const QUrl &)>(16, 4, QMC::AccessPublic, QMetaType::Void, {{
            { 0x80000000 | 17, 18 }, { 0x80000000 | 17, 19 }, { 0x80000000 | 17, 20 }, { 0x80000000 | 17, 21 },
            { 0x80000000 | 17, 22 },
        }}),
        // Method 'saveConfiguration'
        QtMocHelpers::MethodData<void()>(23, 4, QMC::AccessPublic, QMetaType::Void),
        // Method 'reloadConfiguration'
        QtMocHelpers::MethodData<void()>(24, 4, QMC::AccessPublic, QMetaType::Void),
        // Method 'databasePath'
        QtMocHelpers::MethodData<QString() const>(25, 4, QMC::AccessPublic, QMetaType::QString),
        // Method 'startTimer'
        QtMocHelpers::MethodData<void()>(26, 4, QMC::AccessPublic, QMetaType::Void),
        // Method 'resetTimer'
        QtMocHelpers::MethodData<void()>(27, 4, QMC::AccessPublic, QMetaType::Void),
        // Method 'resetAll'
        QtMocHelpers::MethodData<void()>(28, 4, QMC::AccessPublic, QMetaType::Void),
        // Method 'skipTimer'
        QtMocHelpers::MethodData<void()>(29, 4, QMC::AccessPublic, QMetaType::Void),
    };
    QtMocHelpers::UintData qt_properties {
        // property 'timeDisplay'
        QtMocHelpers::PropertyData<QString>(30, QMetaType::QString, QMC::DefaultPropertyFlags, 0),
        // property 'statusText'
        QtMocHelpers::PropertyData<QString>(31, QMetaType::QString, QMC::DefaultPropertyFlags, 1),
        // property 'controlButtonText'
        QtMocHelpers::PropertyData<QString>(32, QMetaType::QString, QMC::DefaultPropertyFlags, 2),
        // property 'sweepAngle'
        QtMocHelpers::PropertyData<double>(33, QMetaType::Double, QMC::DefaultPropertyFlags, 3),
        // property 'currentCycle'
        QtMocHelpers::PropertyData<int>(34, QMetaType::Int, QMC::DefaultPropertyFlags, 4),
        // property 'currentGifSource'
        QtMocHelpers::PropertyData<QUrl>(35, 0x80000000 | 17, QMC::DefaultPropertyFlags | QMC::EnumOrFlag, 5),
        // property 'focusGifSource'
        QtMocHelpers::PropertyData<QUrl>(36, 0x80000000 | 17, QMC::DefaultPropertyFlags | QMC::EnumOrFlag | QMC::Constant),
        // property 'shortBreakGifSource'
        QtMocHelpers::PropertyData<QUrl>(37, 0x80000000 | 17, QMC::DefaultPropertyFlags | QMC::EnumOrFlag | QMC::Constant),
        // property 'longBreakGifSource'
        QtMocHelpers::PropertyData<QUrl>(38, 0x80000000 | 17, QMC::DefaultPropertyFlags | QMC::EnumOrFlag | QMC::Constant),
        // property 'startGifSource'
        QtMocHelpers::PropertyData<QUrl>(39, 0x80000000 | 17, QMC::DefaultPropertyFlags | QMC::EnumOrFlag | QMC::Constant),
        // property 'pauseGifSource'
        QtMocHelpers::PropertyData<QUrl>(40, 0x80000000 | 17, QMC::DefaultPropertyFlags | QMC::EnumOrFlag | QMC::Constant),
        // property 'focusDurationSeconds'
        QtMocHelpers::PropertyData<int>(41, QMetaType::Int, QMC::DefaultPropertyFlags | QMC::Constant),
        // property 'shortBreakDurationSeconds'
        QtMocHelpers::PropertyData<int>(42, QMetaType::Int, QMC::DefaultPropertyFlags | QMC::Constant),
        // property 'longBreakDurationSeconds'
        QtMocHelpers::PropertyData<int>(43, QMetaType::Int, QMC::DefaultPropertyFlags | QMC::Constant),
        // property 'notificationSoundEnabled'
        QtMocHelpers::PropertyData<bool>(44, QMetaType::Bool, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 6),
        // property 'notificationDurationMs'
        QtMocHelpers::PropertyData<int>(45, QMetaType::Int, QMC::DefaultPropertyFlags | QMC::Constant),
    };
    QtMocHelpers::UintData qt_enums {
    };
    QtMocHelpers::UintData qt_constructors {};
    QtMocHelpers::ClassInfos qt_classinfo({
            {    1,    2 },
    });
    return QtMocHelpers::metaObjectData<PomodoroTimer, void>(QMC::MetaObjectFlag{}, qt_stringData,
            qt_methods, qt_properties, qt_enums, qt_constructors, qt_classinfo);
}
Q_CONSTINIT const QMetaObject PomodoroTimer::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN13PomodoroTimerE_t>.stringdata,
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN13PomodoroTimerE_t>.data,
    qt_static_metacall,
    nullptr,
    qt_staticMetaObjectRelocatingContent<qt_meta_tag_ZN13PomodoroTimerE_t>.metaTypes,
    nullptr
} };

void PomodoroTimer::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<PomodoroTimer *>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: _t->timeDisplayChanged(); break;
        case 1: _t->statusTextChanged(); break;
        case 2: _t->controlButtonTextChanged(); break;
        case 3: _t->sweepAngleChanged(); break;
        case 4: _t->currentCycleChanged(); break;
        case 5: _t->currentGifSourceChanged(); break;
        case 6: _t->notificationSettingsChanged(); break;
        case 7: _t->tick(); break;
        case 8: _t->setFocusDurationSeconds((*reinterpret_cast<std::add_pointer_t<int>>(_a[1]))); break;
        case 9: _t->setShortBreakDurationSeconds((*reinterpret_cast<std::add_pointer_t<int>>(_a[1]))); break;
        case 10: _t->setLongBreakDurationSeconds((*reinterpret_cast<std::add_pointer_t<int>>(_a[1]))); break;
        case 11: _t->setAssetSources((*reinterpret_cast<std::add_pointer_t<QUrl>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QUrl>>(_a[2])),(*reinterpret_cast<std::add_pointer_t<QUrl>>(_a[3])),(*reinterpret_cast<std::add_pointer_t<QUrl>>(_a[4])),(*reinterpret_cast<std::add_pointer_t<QUrl>>(_a[5]))); break;
        case 12: _t->saveConfiguration(); break;
        case 13: _t->reloadConfiguration(); break;
        case 14: { QString _r = _t->databasePath();
            if (_a[0]) *reinterpret_cast<QString*>(_a[0]) = std::move(_r); }  break;
        case 15: _t->startTimer(); break;
        case 16: _t->resetTimer(); break;
        case 17: _t->resetAll(); break;
        case 18: _t->skipTimer(); break;
        default: ;
        }
    }
    if (_c == QMetaObject::IndexOfMethod) {
        if (QtMocHelpers::indexOfMethod<void (PomodoroTimer::*)()>(_a, &PomodoroTimer::timeDisplayChanged, 0))
            return;
        if (QtMocHelpers::indexOfMethod<void (PomodoroTimer::*)()>(_a, &PomodoroTimer::statusTextChanged, 1))
            return;
        if (QtMocHelpers::indexOfMethod<void (PomodoroTimer::*)()>(_a, &PomodoroTimer::controlButtonTextChanged, 2))
            return;
        if (QtMocHelpers::indexOfMethod<void (PomodoroTimer::*)()>(_a, &PomodoroTimer::sweepAngleChanged, 3))
            return;
        if (QtMocHelpers::indexOfMethod<void (PomodoroTimer::*)()>(_a, &PomodoroTimer::currentCycleChanged, 4))
            return;
        if (QtMocHelpers::indexOfMethod<void (PomodoroTimer::*)()>(_a, &PomodoroTimer::currentGifSourceChanged, 5))
            return;
        if (QtMocHelpers::indexOfMethod<void (PomodoroTimer::*)()>(_a, &PomodoroTimer::notificationSettingsChanged, 6))
            return;
    }
    if (_c == QMetaObject::ReadProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast<QString*>(_v) = _t->timeDisplay(); break;
        case 1: *reinterpret_cast<QString*>(_v) = _t->statusText(); break;
        case 2: *reinterpret_cast<QString*>(_v) = _t->controlButtonText(); break;
        case 3: *reinterpret_cast<double*>(_v) = _t->sweepAngle(); break;
        case 4: *reinterpret_cast<int*>(_v) = _t->currentCycle(); break;
        case 5: *reinterpret_cast<QUrl*>(_v) = _t->currentGifSource(); break;
        case 6: *reinterpret_cast<QUrl*>(_v) = _t->focusGifSource(); break;
        case 7: *reinterpret_cast<QUrl*>(_v) = _t->shortBreakGifSource(); break;
        case 8: *reinterpret_cast<QUrl*>(_v) = _t->longBreakGifSource(); break;
        case 9: *reinterpret_cast<QUrl*>(_v) = _t->startGifSource(); break;
        case 10: *reinterpret_cast<QUrl*>(_v) = _t->pauseGifSource(); break;
        case 11: *reinterpret_cast<int*>(_v) = _t->focusDurationSeconds(); break;
        case 12: *reinterpret_cast<int*>(_v) = _t->shortBreakDurationSeconds(); break;
        case 13: *reinterpret_cast<int*>(_v) = _t->longBreakDurationSeconds(); break;
        case 14: *reinterpret_cast<bool*>(_v) = _t->notificationSoundEnabled(); break;
        case 15: *reinterpret_cast<int*>(_v) = _t->notificationDurationMs(); break;
        default: break;
        }
    }
    if (_c == QMetaObject::WriteProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 14: _t->setNotificationSoundEnabled(*reinterpret_cast<bool*>(_v)); break;
        default: break;
        }
    }
}

const QMetaObject *PomodoroTimer::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *PomodoroTimer::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_staticMetaObjectStaticContent<qt_meta_tag_ZN13PomodoroTimerE_t>.strings))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int PomodoroTimer::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 19)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 19;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 19)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 19;
    }
    if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::BindableProperty
            || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 16;
    }
    return _id;
}

// SIGNAL 0
void PomodoroTimer::timeDisplayChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}

// SIGNAL 1
void PomodoroTimer::statusTextChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 1, nullptr);
}

// SIGNAL 2
void PomodoroTimer::controlButtonTextChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 2, nullptr);
}

// SIGNAL 3
void PomodoroTimer::sweepAngleChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 3, nullptr);
}

// SIGNAL 4
void PomodoroTimer::currentCycleChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 4, nullptr);
}

// SIGNAL 5
void PomodoroTimer::currentGifSourceChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 5, nullptr);
}

// SIGNAL 6
void PomodoroTimer::notificationSettingsChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 6, nullptr);
}
QT_WARNING_POP
