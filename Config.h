/*

  Created by Beat707 (c) 2011 - http://www.Beat707.com
  
  Pinage Configration File
  
*/

#ifndef EXTRASETTINGS_h
#define EXTRASETTINGS_h

  // ===================================================================================================================================================================== //
  #define MAXSONGPOS 99         // By changing any of those 2 settings you will need to re-do the Storage code sizes definitions for patterns, setup and song storage
  #define MAXSPATTERNS 90       // Check W_Storage to see the size of each pattern, so you know how many patterns you can store on an EEPROM chip
  #define MAXSONGSFILE 21       // Used by the Flash Storage, to determinate how many songs the Flash memory can hold (see W_Storage)
  #define MIDIECHO 1            // Copies all Midi Input to the Midi Output

  // ===================================================================================================================================================================== // 
  // List of possible Hacks and Mods - Note: ANALOG_INPUT_A0 and GATE_OUTS can be used only one at a time (as they use the same pins)
  // Most functions are set in the W_Hacks Tab and used in the W_Loop and W_Midi Tabs
  #define ANALOG_INPUT_A0 0     // Reads the analog input A0 (D14 on the Beat707 SV2 Headers) for multiple options (also uses ANALOG_PATT_MAX and ANALOG_MDLY below)
    #define ANALOG_INPUT_BT 0   // When Enabled in conjunction with ANALOG_INPUT_A0, it will only work if a button is attached and pressed on Digital Pin 2 (S2 on Beat707 SV3 Headers) Pull-Up Resistors internally used, so all you need to do is attach a regular button to the port and connect the button to ground.
    #define ANALOG_PATT_MAX 16  // If Analog Input is enabled and is in Pattern mode, this will define the max number of patterns to select. (0 to MAX)
    #define ANALOG_MDLY 100     // If Analog Input is enabled, the delay for when a new mode is selected (in ms) or, if ANALOG_INPUT_BT is enabled, the time to pause when the button is pressed 
  #define GATE_OUTS 0           // When enabled adds 3 Gate Outputs on pins A0, D2 and D3. (check the Board Details PDF file for headers information - should be SV2 and SV3) Gates are fixed for Tracks 1, 2 and 3. (MIDI is disabled on those tracks)
    #define GATE_OUTS_TIME 15   // Time of the Gate Trig (from High to Low)
    #define GATE_OUTS_VEL_D3 0  // Add Velocity (PWM) on Digital Pin 3 (D3)
  #define EXTRA_8_BUTTONS 0     // Will use the extra 8 buttons input header to read 8 inputs (no need for pull-up/down resistors, the hardware already has it) and call user-code that can be written on the W_Hacks tab.
    
  // ===================================================================================================================================================================== //
  #define CHECK_FOR_USB_MODE 0  // The Device will check if the USB Remote Program is running (takes 1 second during initialization)
  #define EXTENDED_DRUM_NAMES 1 // Add more GM Drum Note Names to the Track Drum Note Selectors
  #define STORAGE_FORCE_INIT 0  // Force an Initiation of all EEPROM memory during startup 
  #define SHOW_INITIALIZING 0   // Display "Initializing..." during startup (only when CHECK_FOR_USB_MODE is 1)
  #define SHOW_USB_MODE 0       // Display "USB Mode Ready" during startup (only when CHECK_FOR_USB_MODE is 1)
  #define SHOWFREEMEM 0         // Outputs free RAM to Serial
  #define MSerial Serial        // Used for MIDI Input/Output
  #define INIT_EMPTY_SONG 1     // Determinates if an Empty Song should be saved during Initiation of the EEPROM + Flash
  #define DISABLE_MIDI 0        // Debug Only
  #define DISABLE_STORAGE_CHK 0 // Debug Only
  #if ANALOG_INPUT_A0
    #define LAST_PATT_ZONE 14   // The code of the last Pattern Zone. If you add a new option/zone, you will need to update this value.
  #else
    #define LAST_PATT_ZONE 13
  #endif
  
  // ===================================================================================================================================================================== //  
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

  #define BTN_EXT1 B00000001
  #define BTN_EXT2 B00000010
  #define BTN_EXT3 B00000100
  #define BTN_EXT4 B00001000
  #define BTN_EXT5 B00010000
  #define BTN_EXT6 B00100000
  #define BTN_EXT7 B01000000
  #define BTN_EXT8 B10000000

  #define SONG_VERSION 2 // As used by the Storage to check the song format version //
 
#endif
