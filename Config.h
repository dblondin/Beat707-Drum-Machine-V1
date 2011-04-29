/*

  Created by Beat707 (c) 2011 - http://www.Beat707.com
  
  Pinage Configration File
  
*/

#ifndef EXTRASETTINGS_h
#define EXTRASETTINGS_h

  #define MAXSONGPOS 99         // By changing any of those 2 settings you will need to re-do the Storage code sizes definitions for patterns, setup and song storage
  #define MAXSPATTERNS 90       // Check W_Storage to see the size of each pattern, so you know how many patterns you can store on an EEPROM chip
  #define MAXSONGSFILE 21       // Used by the Flash Storage, to determinate how many songs the Flash memory can hold (see W_Storage)
  #define MIDIECHO 1            // Copies all Midi Input to the Midi Output
  
  // ===================================================================================================================================================================== //

  #define CHECK_FOR_USB_MODE 1  // The Device will check if the USB Remote Program is running (takes 1 second during initialization)
  #define EXTENDED_DRUM_NAMES 1 // Add more GM Drum Note Names to the Track Drum Note Selectors
  #define STORAGE_FORCE_INIT 0  // Force an Initiation of all EEPROM memory during startup 
  #define SHOW_INITIALIZING 1   // Display "Initializing..." during startup (only when CHECK_FOR_USB_MODE is 1)
  #define SHOW_USB_MODE 1       // Display "USB Mode Ready" during startup (only when CHECK_FOR_USB_MODE is 1)
  #define SHOWFREEMEM 0         // Outputs free RAM to Serial
  #define MSerial Serial        // Used for MIDI Input/Output
  #define DISABLE_MIDI 0
  #define DISABLE_STORAGE_CHECK 0
  #define INIT_EMPTY_SONG 1     // Determinates of an Empty Song should be saved during Initiation of the EEPROM + Flash
   
  // Buttons and LEDs using C165 and C595 Shifters //
  #define LATCHOUT 8
  #if defined(__AVR_ATmega1280__) || defined(__AVR_ATmega2560__)
    #define FLASH_SSn 55
    #define SWITCH_SSn 56
    #define MIDI_ENn 57
  #else
    #define FLASH_SSn 15
    #define SWITCH_SSn 16
    #define MIDI_ENn 17
  #endif

  #define BTN_LEFT  B00000001
  #define BTN_RIGHT B00000010
  #define BTN_PLAY  B00000100
  #define BTN_STOP  B00001000
  #define BTN_REC   B00010000
  #define BTN_SHIFT B00100000
  #define BTN_UP    B01000000
  #define BTN_DOWN  B10000000

  #define SONG_VERSION 2 // As used by the Storage to check the song format version //
 
#endif
