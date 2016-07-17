/*
  
  Keyboard LED Control for AutoHotkey_L 32 & 64 bit
  http://www.autohotkey.com/forum/viewtopic.php?p=468000#468000
  
  Mod and Fix by IMadering (17.07.2016)
  
  KeyboardLED(LEDvalue, Kbdevice)
  LEDvalue   - All Off = 0, ScrollLock = 1, NumLock = 2, NumLock + ScrollLock = 3, CapsLock = 4, CapsLock + ScrollLock = 5, NumLock + CapsLock = 6, All = 7
  Kbdevice   - Keyboard Device
  
*/

KeyboardLED(LEDvalue, Kbdevice) {
  
  ;MsgBox, % Kbdevice
  
  if !Kbdevice {
    MsgBox, Not Keyboard Device!
    return
  }
  
  h_device := DllCall("CreateFile"
                     , "str", Kbdevice
                     , "uint", 0
                     , "uint", 1  ; FILE_SHARE_READ
                     , "uint", 0
                     , "uint", 3  ; OPEN_EXISTING
                     , "uint", 0
                     , "uint", 0)
  
  ;MsgBox, % h_device
  
  success := DllCall("DeviceIoControl"
                    , "ptr", h_device
                    , "uint", CTL_CODE(0x0000000b  ; FILE_DEVICE_KEYBOARD
                                      , 2
                                      , 0          ; METHOD_BUFFERED
                                      , 0)         ; FILE_ANY_ACCESS
                    , "int*", LEDvalue << 16
                    , "uint", 4
                    , "ptr",  0
                    , "uint", 0
                    , "ptr*", output_actual
                    , "ptr",  0)
  
  NtCloseFile(h_device)
  return success
}

CTL_CODE( p_device_type, p_function, p_method, p_access )
{
  return, (p_device_type << 16) | (p_access << 14) | (p_function << 2) | p_method
}

NtCloseFile(handle)
{
  return DllCall("ntdll\ZwClose","ptr", handle)
}
