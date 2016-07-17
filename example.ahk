#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

/*
  
  KeyboardLED(LEDvalue, Kbdevice)
  LEDvalue   - All Off = 0, ScrollLock = 1, NumLock = 2, NumLock + ScrollLock = 3, CapsLock = 4, CapsLock + ScrollLock = 5, NumLock + CapsLock = 6, All = 7
  Kbdevice   - Keyboard Device
  
*/

#Persistent ; Делаем скрипт постоянно выполняющимся
#SingleInstance, Force ; Скрипт перезапускается без вопросов
SetBatchLines, -1 ; Выполнять таймеры без задержек
Process, Priority, , High ; Назначаем высокий приоритет скрипту при запуске

#Include keyboard_led_control.ahk

SetNumLockState, AlwaysOff
SetCapsLockState, AlwaysOff
SetScrollLockState, AlwaysOff

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Gui, Add, GroupBox, x8 y8 w335 h48 vGSelectKbd, Select Keyboard
Gui, Add, DropDownList, x15 yp+19 w321 h20 R10 vDSelectKbd gDSelectKbd

Gui, Add, Button, x8 y+20 w100 h25 vBNumLockON gBNumLockON, NumLock ON
Gui, Add, Button, x+17 yp w100 h25 vBCapsLockON gBCapsLockON, CapsLock ON
Gui, Add, Button, x+17 yp w100 h25 vBScrollLockON gBScrollLockON, ScrollLock ON

Gui, Add, Button, x8 y+20 w100 h25 vBNumLockOFF gBNumLockOFF, NumLock OFF
Gui, Add, Button, x+17 yp w100 h25 vBCapsLockOFF gBCapsLockOFF, CapsLock OFF
Gui, Add, Button, x+17 yp w100 h25 vBScrollLockOFF gBScrollLockOFF, ScrollLock OFF

gosub Get_Kbd_Device_List

Gui, Show, w351 h150 Center, Keyboard LED Control | v0.1

GUIControl, Focus, GSelectKbd ; Ставим фокус вникуда

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Kbd_ID := "" ; Выбранный идентификатор клавиатуры
Kbd_Device := "" ; Полный путь к девайсу выбранной клавиатуры

; Состояние светодиодов
NumLock := false
CapsLock := false
ScrollLock := false

return

Get_Kbd_Device_List:
  Loop, HKEY_LOCAL_MACHINE, SYSTEM\CurrentControlSet\Services\Kbdclass\Enum
  {
    RegRead, device_instance_id, HKLM, SYSTEM\CurrentControlSet\Services\Kbdclass\Enum, %A_LoopRegName%
    if InStr(device_instance_id, "ACPI\") || InStr(device_instance_id, "HID\") {
      GuiControl,, DSelectKbd, %device_instance_id%
    }
  }
  return

DSelectKbd:
  GuiControl, Enable, BNumLockON
  GuiControl, Enable, BNumLockOFF
  GuiControl, Enable, BCapsLockON
  GuiControl, Enable, BCapsLockOFF
  GuiControl, Enable, BScrollLockON
  GuiControl, Enable, BScrollLockOFF
  NumLock := false
  CapsLock := false
  ScrollLock := false
  return

Find_Kbd_Device:
  GuiControlGet, select_kbd_id,, DSelectKbd
  if (Kbd_ID <> select_kbd_id) {
    Kbd_ID := select_kbd_id ; Запоминаем идентификатор клавиатуры
    
    Loop, HKEY_LOCAL_MACHINE, SYSTEM\CurrentControlSet\Control\DeviceClasses, 1, 1
    {
      if (A_LoopRegName = "DeviceInstance") {
        RegRead, value
        if InStr(value, Kbd_ID) {
          StringGetPos, ix, A_LoopRegSubKey, \##?#, R
          StringTrimLeft, device, A_LoopRegSubKey, ix + 5
          Kbd_Device = \\.\%device%
          ;MsgBox, % Kbd_Device
          Break
        }
      }
    }
  }
  return

LED_Event:
  gosub Find_Kbd_Device
  
  ; All Off = 0, ScrollLock = 1, NumLock = 2, NumLock + ScrollLock = 3, CapsLock = 4, CapsLock + ScrollLock = 5, NumLock + CapsLock = 6, All = 7
  if (!NumLock) && (!CapsLock) && (!ScrollLock) {
    KeyboardLED(0, Kbd_Device) ; Потущить все светодиоды
  } else if (!NumLock) && (!CapsLock) && (ScrollLock) {
    KeyboardLED(1, Kbd_Device) ; Включить ScrollLock
  } else if (NumLock) && (!CapsLock) && (!ScrollLock) {
    KeyboardLED(2, Kbd_Device) ; Включить NumLock
  } else if (NumLock) && (!CapsLock) && (ScrollLock) {
    KeyboardLED(3, Kbd_Device) ; Включить NumLock + ScrollLock
  } else if (!NumLock) && (CapsLock) && (!ScrollLock) {
    KeyboardLED(4, Kbd_Device) ; Включить CapsLock
  } else if (!NumLock) && (CapsLock) && (ScrollLock) {
    KeyboardLED(5, Kbd_Device) ; Включить CapsLock + ScrollLock
  } else if (NumLock) && (CapsLock) && (!ScrollLock) {
    KeyboardLED(6, Kbd_Device) ; Включить NumLock + CapsLock
  }  else if (NumLock) && (CapsLock) && (ScrollLock) {
    KeyboardLED(7, Kbd_Device) ; Включить All
  }
  return

BNumLockON:
  GuiControl, Disable, BNumLockON
  GuiControl, Enable, BNumLockOFF
  NumLock := true
  gosub LED_Event
  return

BNumLockOFF:
  GuiControl, Disable, BNumLockOFF
  GuiControl, Enable, BNumLockON
  NumLock := false
  gosub LED_Event
  return

BCapsLockON:
  GuiControl, Disable, BCapsLockON
  GuiControl, Enable, BCapsLockOFF
  CapsLock := true
  gosub LED_Event
  return

BCapsLockOFF:
  GuiControl, Disable, BCapsLockOFF
  GuiControl, Enable, BCapsLockON
  CapsLock := false
  gosub LED_Event
  return

BScrollLockON:
  GuiControl, Disable, BScrollLockON
  GuiControl, Enable, BScrollLockOFF
  ScrollLock := true
  gosub LED_Event
  return

BScrollLockOFF:
  GuiControl, Disable, BScrollLockOFF
  GuiControl, Enable, BScrollLockON
  ScrollLock := false
  gosub LED_Event
  return

GuiEscape:
GuiClose:
  ExitApp
