Created by Beat707 (c) 2011 - http://www.Beat707.com

Beat707.com is a joint collaboration between Wusik.com and RuggedCircuits.com, all rights reserved (c) 2011

--------------------------------------------------------------------------------------------------------

Latest version direct download link:

https://github.com/Beat707/Beat707-Drum-Machine-V1/archives/master

Official GitHub download area:

https://github.com/Beat707/Beat707-Drum-Machine-V1

You can download manuals at:

http://www.beat707.com/w/downloads/manual

Hacks and Mods at:

http://www.beat707.com/w/downloads/hacks-and-mods

And Tutorial Videos at:

http://www.youtube.com/user/beat707videos

--------------------------------------------------------------------------------------------------------

March 30 2011 - Version 1.0.0

 - Complete Design with 3 Modes: Pattern, Song and File
 - Midi SysEx Dump/Receive
 - Midi Sync Modes: None, Slave, Master
 - Drum Tracks and Synth Tracks
 - 32 steps per pattern (quick shift toggles)
 - 93 Patterns per Song + 99 Song-Pattern Positions on a Song
 - 42 Songs Flash Memory Storage + 14 character name per Song

---------------------------------------------------------------------------------

April 17 2011 - Version 1.2.0
  
 - This version uses Song Format 2, therefore is not compatible with previous Songs.
 - Double Pattern Size: each pattern now holds 64 steps, instead of the 32 previous mode.
 - Each pattern now has an A and B set of steps, each has 32 steps for a total of 64 steps.
 - The Copy/Paste pattern area is now saved on the EEPROM. So you can copy a pattern from one song and past into another song's pattern.
 - Improved the LCD code by reducing the LiquidCrystal library and creating the WLCD library on its place.
 - Improved MIDI Clock by using the 16-bit Timer1 (before was 8-bit Timer2)
 - BPM Range now goes from 25 to 255 BPM
 - Added special Pattern Mirror Mode Editing (slow double click Shift or use the menu navigation)
 - Added Midi Clock Shuffle (0 to 6)
 - Added option to edit patterns from the Song mode. Just hit Record and it will go directly to the Pattern that is playing, hit Left+Right to go back to Song mode.
 - When Playing in Song Mode, now you can go up and down Song Positions. (before you could only edit BPM)
 - Added Left+Right key shortcut: cycles all 3 modes: Pattern, Song and File.
 - Holding shift and Hiting Record will make the Shift key "stick". Release Shift and hit Record again to "un-stick" the Shift key.
 - Quick Shift Click still goes from 1/16 to 1/32 step editing. (or 1/32 to 1/64 in double speed) But now, you don't see a message, just a small icon change next to the pattern number, where now shows A/B. A small square above A/B tells you are in double step editing mode.
 - Better code for less Flash space even with the latest additions.
 - New USB Mode that uses an extra program to talk to the unit directly without the need of a MIDI connection.

---------------------------------------------------------------------------------

May 07 2011 - Version 1.2.4

 - Added Number of Steps (global)
 - Added Enable Pattern AB. (when disabled, only Pattern A will play)
 - Added ANALOG_INPUT_A0 to Config.h - Analog input option, by using the free Analog A0 Pin. (D14 on the Beat707 SV2 Headers) The current options are: BPM Tempo, Pattern Selector, Track Selector, Note Selector and Number of Steps. There's a 2 second delay for when you select a new input mode or press an optional button attached to Digital Pin 2. (the delay can be tweaked)
 - Added GATE_OUTS to Config.h - Gate Output option for the first 3 tracks: T>01, T>02 and T>03. When enabled it will use 3 pins to output a gate voltage trigger on pins A0, D2 and D3. Check the Board Details PDF file for headers information - should be SV2 and SV3) Gates are fixed for Tracks 1, 2 and 3. (MIDI is disabled on those tracks) We also added the option to use GATE_OUTS_VEL_D3 to activate Velocity (PWM) on Track 3 (Digital Pin 3, D3)
 - Added EXTRA_8_BUTTONS to the Config.h and also a new tab named W_Hacks - This new option will use the extra 8 buttons input header to read 8 inputs (no need for pull-up/down resistors, the hardware already has it) and call user-code that can be written on the W_I_ExtraBt tab.

---------------------------------------------------------------------------------