/*

  Created by Beat707 (c) 2011 - http://www.Beat707.com

  Main File for Variable Declaration and Setup - May 07 2011 - Version 1.2.4

*/

#include "Config.h"  // Where all PIN settings are stored
#include <WLCD.h>    // Modified LCD Lib - The LCD Display Library
#include <WWire.h>   // Modified Wire Lib - For the Patterns external Storage (EEPROM) - See W_Storage
#include <SPI.h>     // Reads the external FLASH NAND memory and also all buttons and leds

// Multi Button //
uint8_t prevbutton, multiButton, tempButton = 99;
uint8_t lastMillisCounter = 0;
unsigned long lastMillis, lastMillisRecButtons, lastMillisStepPosBlinker, lastMillisLateLCDupdate, lastMillisShiftClick = 0;

// Midi Clock  //
#define PPQ 96 // Min BPM = 50 //
uint8_t midiClockBPM; // 25 to 255 BPM //
uint8_t midiClockType; // 0=Internal Only (no Sync), 1=SyncToExternal (Slave), 2=SendSync (Master)
uint8_t midiClockCounterDivider, midiClockCounter, currentTrack, currentPattern, 
        nextPattern, shiftMode, noteStepPositionBlinker, sync24PPQ = 0;
uint8_t note = 0; // Used by the MIDI Input code, the last note been Input
uint8_t state = 0; // Used by the MIDI Input code (to check 3 bytes of Note information)
uint8_t incomingByte = 0; // Used by the MIDI Input Code
uint8_t timeScale;
uint8_t autoSteps; // Used to rotate from 16 to 32 extra steps automaticaly
uint8_t midiClockShuffleData[2][3], midiClockShuffle, midiClockShuffleCounter;
uint8_t numberOfSteps = 16;
#if ANALOG_INPUT_A0
  uint8_t prevAnalogA0value = 0;
  uint8_t analogInputMode = 0; // 0=BPM, 1=Pattern#, 2=NumberOfSteps, 3=TrackSelector, 4=Note Selector
  unsigned long analogInputModeNewDelay = 0;
  #if ANALOG_INPUT_BT
    uint8_t prevAnalogButtonCheckState = HIGH;
  #endif
#endif
#if GATE_OUTS
  unsigned long gateOutDelay[3] = {0,0,0};
#endif

// Boolean Variables //
uint8_t doLCDupdate, nextPatternReady, patternBufferN, midiClockRunning, editStepsPos,
        shiftClick, holdingShift, holdingShiftUsed, patternChanged, stickyShift, mirrorPatternEdit,
        midiClockProcess, noteOn, setupChanged, recordEnabled, recordShowCurPos, 
        editDoubleSteps, midiClockProcessDoubleSteps, soloCheckerTemp, stepsPos, enableABpattern,
        showOnlyOnce, lateAutoSave, songChanged, songNextPosition, doPatternLCDupdate = 0;

// Patterns //
#define DRUMTRACKS 14
uint8_t dmNotes[DRUMTRACKS] = {36,37,38,39,40,42,44,46,51,49,45,47,48,50}; // GM Format //
uint8_t dmChannel[DRUMTRACKS+2];
unsigned int dmSteps[2][(DRUMTRACKS+2)*4]; // [currentPattern/nextPattern][tracks*steps] - 32x2 Steps - last 2 tracks are Accents - each bit is a step on/off
unsigned int dmMutes;
uint8_t dmSynthTrack[2][2][64]; // [track#][pattern_loaded/loading][steps]
uint8_t dmSynthTrackStepPos[2] = {0,0}; // Pattern A|B / Position - as in [0] = 0~1 - [1] = 0~15
uint8_t dmSynthTrackPrevNote[2] = {0,0};
uint8_t dmSynthTrackLastNoteEdit[2] = {61,61};

// Song //
int curSongPosition = 0;
uint8_t songLoopPos, patternSong, patternSongNext, patternSongRepeat, 
        patternSongRepeatNext, patternSongRepeatCounter, songPattEdit = 0;

// File Mode //
uint8_t fileMode = 0; // 0=Load, 1=Save, 2=Dump MIDI SysE, 3=Erase //
uint8_t fileSelected = 0;
uint8_t sysMIDI_ID = 0; // System Exclusive Data MIDI ID //
char fileSongName[15];
uint8_t fileSongNameEdit = 0;

// Interface //
extern uint8_t LcdCursors[64]; // Cursor Icons as set in the W_Betc file
WLCD lcd;
uint8_t curZone = 0;
uint8_t curMode = 0;  // 0=Pattern - 1=Song - 2=File
uint8_t nextMode = 0; // Used by the interface when selecting a new mode

// Other Variables //
uint8_t wireBufferCounter = 0; // Used with the Wire Library to send 64 bytes of data at once to the EEPROM
extern volatile unsigned long timer0_millis;

// ======================================================================================= //
void sysInit()
{
  memset(dmSteps,0,sizeof(dmSteps));
  memset(dmChannel,9,sizeof(dmChannel));  
  dmChannel[DRUMTRACKS] = 0;
  dmChannel[DRUMTRACKS+1] = 1;
  memset(dmSynthTrack,0,sizeof(dmSynthTrack));
  memset(fileSongName,0,sizeof(fileSongName));
  memset(midiClockShuffleData,0,sizeof(midiClockShuffleData));
  
  midiClockBPM = 120;
  midiClockType = dmMutes = mirrorPatternEdit = midiClockShuffle = midiClockShuffleCounter = 0;
  timeScale = 2;
  autoSteps = enableABpattern = 1;
  
  midiClockShuffleData[0][0] = 12;
  midiClockShuffleData[1][0] = 6;
}

// ======================================================================================= //
void setup() 
{
  pinMode(MIDI_ENn,OUTPUT);
  #if CHECK_FOR_USB_MODE
    MSerial.begin(57600); // Startup in USB Mode //  
    digitalWrite(MIDI_ENn,HIGH);  
    MSerial.write(240); MSerial.write('B'); MSerial.write('7'); 
    MSerial.write('0'); MSerial.write('7'); MSerial.write(247);
  #endif
  
  #if SHOWFREEMEM
    #if !CHECK_FOR_USB_MODE
      MSerial.begin(57600);
    #endif    
    Serial.println(""); Serial.println(""); Serial.print("Free Mem: ");
    Serial.println(freeMemory()); Serial.println("");
  #endif
  
  #if !CHECK_FOR_USB_MODE
    MSerial.begin(31250);
    digitalWrite(MIDI_ENn,LOW);
  #endif
  
  #if ANALOG_INPUT_A0
    pinMode(A0, INPUT);
    #if ANALOG_INPUT_BT
      pinMode(2, INPUT);
      digitalWrite(2, HIGH);
    #endif
  #endif
  
  #if GATE_OUTS
    pinMode(A0, OUTPUT);
    pinMode(2, OUTPUT);
    pinMode(3, OUTPUT);
    digitalWrite(A0, LOW);
    digitalWrite(2, LOW);
    digitalWrite(3, LOW);
  #endif
  
  pinMode(LATCHOUT, OUTPUT);  digitalWrite(LATCHOUT, LOW);
  pinMode(FLASH_SSn, OUTPUT);
  pinMode(SWITCH_SSn, OUTPUT); digitalWrite(SWITCH_SSn, HIGH);
  #if defined(__AVR_ATmega1280__) || defined(__AVR_ATmega2560__)
    pinMode(11, INPUT); // Conflicts with SPI MOSI...do not use
    pinMode(13, INPUT); // Conflicts with SPI CLOCK...do not use
  #endif
   
  SPI.begin();
  SPI.setDataMode(SPI_MODE0);
  Wire.begin();
    
  lcd.begin();
  #if SHOW_INITIALIZING
    lcdPrintString("Initializing...");
  #endif
  lcd.createChar(LcdCursors);

  flashInit();  
  sysInit();
  storageInit(0);
  loadSetup();
  if (curMode == 0) loadPattern(0); else if (curMode == 1) loadSongPosition();
  patternBufferN = 1;
  recordShowCurPos = 1;
  timerStop();

  #if CHECK_FOR_USB_MODE
    unsigned long endtime = timer0_millis + 1000;
    while (((long)endtime - (long)timer0_millis) > 0) { ; } // Don't use delayNI here as it clears up MIDI Data

    uint8_t keepInUSBmode = false;
    if (MSerial.available() > 0)
    {
      keepInUSBmode = true;
      
      if (MSerial.read() != 240) keepInUSBmode = false;
        else if (MSerial.read() != 'U') keepInUSBmode = false;
        else if (MSerial.read() != 'S') keepInUSBmode = false;
        else if (MSerial.read() != 'B') keepInUSBmode = false;
        else if (MSerial.read() != 247) keepInUSBmode = false;
    }
    
    if (!keepInUSBmode)
    {  
      MSerial.begin(31250); // Regular MIDI Interface
      digitalWrite(MIDI_ENn,LOW);  // Write to MIDI OUT, MIDI IN enabled      
    }    
    else
    {
      MSerial.write(240); MSerial.write('I'); MSerial.write('D'); MSerial.write(sysMIDI_ID); MSerial.write(247);
      #if SHOW_USB_MODE
        lcd.clear();
        lcdPrintString("USB Mode Ready");
        delayNI(1000);        
      #endif
    }
  #endif
  
  if (curMode == 0) updateLCDPattern(); 
    else if (curMode == 1) updateLCDSong();
    else updateLCDFile();  
  
  sendMidiAllNotesOff();
}

// ======================================================================================= //
// The Following is to implement millis() and delay() without messing up with the midi clock interrupt calls //
unsigned long millisNI(void) { return timer0_millis; }
void delayNI(unsigned long ms) 
{
  unsigned long endtime;
  endtime = timer0_millis + ms;
  while (((long)endtime - (long)timer0_millis) > 0)
  {
    #if MIDIECHO
      midiInputCheck();
    #else
    ;
    #endif
  }
}
