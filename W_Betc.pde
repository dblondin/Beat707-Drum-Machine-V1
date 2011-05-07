/*

  Created by Beat707 (c) 2011 - http://www.Beat707.com
  
  Extra Functions and Classes used by this project
  
*/
uint16_t stepLEDs, stepButtons, stepButtonsTemp, stepButtonsPrev, extraExternal, interfaceButtons = 0;
uint16_t stepButtonsPrevHigh = 0xFF;

// ======================================================================================= //
void buttonsInputAndLEDsOutput()
{
  // Input Buttons and Output LEDs //
  digitalWrite(SWITCH_SSn, LOW);  // Enable 74HC165's to drive MISO
  digitalWrite(LATCHOUT, LOW);    // Take button snapshot
  digitalWrite(LATCHOUT, HIGH);   // 74HC165 set to shift mode

  extraExternal     = ~SPI.transfer(0);                        // Read extra external digital inputs
  interfaceButtons  = ~SPI.transfer(0);                        // Read Multi Interface Button
  stepButtonsTemp   = (unsigned int)SPI.transfer((stepLEDs >> 8) & 0xFFU) << 8;  // Reads 8 x Step Buttons and Writes 8 x Step LEDs
  stepButtonsTemp  |= (unsigned int)SPI.transfer(stepLEDs & 0xFFU);              // Reads 8 x Step Buttons and Writes 8 x Step LEDs

  digitalWrite(SWITCH_SSn, HIGH);  // Disable 74HC165's to drive MISO
  digitalWrite(LATCHOUT, LOW);     // Pulse LED latches
  digitalWrite(LATCHOUT, HIGH);    // 74HC165 set to shift mode
  
  delayNI(15); // Better Debouncing
  
  if (~stepButtonsTemp) holdingStepButton = 1; else holdingStepButton = 0;
  stepButtons = (~stepButtonsTemp) & stepButtonsPrevHigh;
  stepButtonsPrevHigh = stepButtonsTemp;
  if ((stepButtons == 0 && stepButtonsPrev > 0) || (stepButtons > 0 && stepButtonsPrev != stepButtons)) delayNI(10); // Debouncing //
  stepButtonsPrev = stepButtons;
     
  // ------ Process Interface Buttons ------ //
  multiButton = tempButton = 99;
  holdingButton = 0;
  
  if ((interfaceButtons & BTN_LEFT) && (interfaceButtons & BTN_RIGHT)) tempButton = 9;   // Left+Right = Cycle Modes
    else if (interfaceButtons & BTN_STOP)  tempButton = 0;   // Stop
    else if (interfaceButtons & BTN_PLAY)  tempButton = 1;   // Play
    else if (interfaceButtons & BTN_REC)   tempButton = 6;   // Rec
    else if (interfaceButtons & BTN_LEFT)  tempButton = 2;   // Left
    else if (interfaceButtons & BTN_DOWN)  tempButton = 3;   // Down
    else if (interfaceButtons & BTN_UP)    tempButton = 4;   // Up
    else if (interfaceButtons & BTN_RIGHT) tempButton = 5;   // Right
    #if EXTRA_8_BUTTONS
      else if (extraExternal & BTN_EXT1) tempButton = 21;
      else if (extraExternal & BTN_EXT2) tempButton = 22;
      else if (extraExternal & BTN_EXT3) tempButton = 23;
      else if (extraExternal & BTN_EXT4) tempButton = 24;
      else if (extraExternal & BTN_EXT5) tempButton = 25;
      else if (extraExternal & BTN_EXT6) tempButton = 26;
      else if (extraExternal & BTN_EXT7) tempButton = 27;
      else if (extraExternal & BTN_EXT8) tempButton = 28;
    #endif
    else 
    {
      if (prevbutton != 99) 
      {
        delayNI(10);
        lastMillis = millisNI()+500;
        lastMillisCounter = 255;
      }
      prevbutton = 99;
    }
  
  if (interfaceButtons & BTN_SHIFT) shiftClick = !stickyShift; else shiftClick = stickyShift; // Check the Shift button
    
  if (tempButton != 99)
  {
    if (tempButton != prevbutton) // A New Button was pressed
    {
      holdingButton = 0;
      prevbutton = tempButton;
      multiButton = tempButton;
      lastMillis = millisNI()+500;
      lastMillisCounter = 255;
      delayNI(10);
    }
    else
    {
      if (tempButton >= 2 && lastMillis < millisNI()) // The previous button is still down, repeat action
      {
        holdingButton = 1;
        multiButton = tempButton;
        if (lastMillisCounter == 255) lastMillisCounter = 100;
        lastMillisCounter -= 2;
        if (lastMillisCounter < 5) lastMillisCounter = 5;
        lastMillis = millisNI()+lastMillisCounter;
      }    
    }
  }
}

// ======================================================================================= //

void timerStart()
{
  TCCR1A = TCCR1B = 0;
  bitWrite(TCCR1B, CS11, 1);
  bitWrite(TCCR1B, WGM12, 1);
  timerSetFrequency();
  bitWrite(TIMSK1, OCIE1A, 1);
}

void timerSetFrequency()
{
  // Calculates the Frequency for the Timer, used by the PPQ clock (Pulses Per Quarter Note) //
  // This uses the 16-bit Timer1, unused by the Arduino, unless you use the analogWrite or Tone functions //
  #define frequency (((midiClockBPM)*(PPQ))/60)
  OCR1A = (F_CPU/ 8) / frequency - 1;
}

void timerStop(void)
{
  bitWrite(TIMSK1, OCIE1A, 0);
  TCCR1A = TCCR1B = OCR1A = 0;
}

// ======================================================================================= //

void InterfaceButtons()
{
  if (curMode == 0) InterfaceTickPattern(); 
    else if (curMode == 1) InterfaceTickSong();
    else if (curMode == 2) InterfaceTickFile();
}

// ======================================================================================= //
#define EEPROM_WRITE(a,b) writeEEPROM(0x50,a,b)
#define EEPROM_READ(a) readEEPROM(0x50,a)

// All the following uses the 2-Wire (TWI) protocol to load/save data from the external EEPROM chips

void EEPROMWriteInt(int p_address, int p_value)
{
  byte lowByte = ((p_value >> 0) & 0xFF);
  byte highByte = ((p_value >> 8) & 0xFF);

  EEPROM_WRITE(p_address, lowByte);
  EEPROM_WRITE(p_address + 1, highByte);
}

unsigned int EEPROMReadInt(int p_address)
{
  byte lowByte = EEPROM_READ(p_address);
  byte highByte = EEPROM_READ(p_address + 1);

  return ((lowByte << 0) & 0xFF) + ((highByte << 8) & 0xFF00);
}

void writeEEPROM(int deviceaddress, unsigned int eeaddress, byte data ) 
{
  Wire.beginTransmission(deviceaddress);
  Wire.send((int)(eeaddress >> 8));   // MSB
  Wire.send((int)(eeaddress & 0xFF)); // LSB
  Wire.send(data);
  wireEndTransmission();
}
byte readEEPROM(int deviceaddress, unsigned int eeaddress ) 
{
  byte rdata = 0xFF;
  Wire.beginTransmission(deviceaddress);
  Wire.send((int)(eeaddress >> 8));   // MSB
  Wire.send((int)(eeaddress & 0xFF)); // LSB
  Wire.endTransmission();
  Wire.requestFrom(deviceaddress,1);
  if (Wire.available()) rdata = Wire.receive();
  return rdata;
}

// ======================================================================================= //

// This is used to delay just a bit
void volatile nop(void) { asm __volatile__ ("nop"); }

// ======================================================================================= //
// Checks the RAM left - the ATmega328 has only 2K of RAM //
#if SHOWFREEMEM
  extern unsigned int __data_start;
  extern unsigned int __data_end;
  extern unsigned int __bss_start;
  extern unsigned int __bss_end;
  extern unsigned int __heap_start;
  extern void *__brkval;
  
  int freeMemory()
  {
    int free_memory;
  
    if((int)__brkval == 0)
       free_memory = ((int)&free_memory) - ((int)&__bss_end);
    else
      free_memory = ((int)&free_memory) - ((int)__brkval);
  
    return free_memory;
  }
#endif

// ======================================================================================= //

uint8_t LcdCursors[64] = { 
      B00000,    B01000,    B01100,    B01110,    B01100,    B01000,    B00000,    B00000,      
      B00000,    B01010,    B01110,    B01110,    B01110,    B01010,    B00000,    B00000,
      B11111,    B10111,    B10011,    B10001,    B10011,    B10111,    B11111,    B00000,      
      B00000,    B00000,    B11110,    B10010,    B11110,    B10010,    B10010,    B00000,      
      B00000,    B00000,    B11100,    B10010,    B11100,    B10010,    B11100,    B00000,      
      B00011,    B00011,    B11110,    B10010,    B11110,    B10010,    B10010,    B00000,      
      B00011,    B00011,    B11100,    B10010,    B11100,    B10010,    B11100,    B00000,      
      B11111,    B10101,    B10001,    B10001,    B10001,    B10101,    B11111,    B00000  };

// ======================================================================================= //

boolean hitShiftToConfirm()
{
    uint8_t tmC = 0;
    uint8_t tmC2 = 0;
    while (1)
    {
      if (tmC2 == 0)
      {
        delayNI(250);
        lcd.setCursor(0,1);
        lcdPrintEmptyChars(16);
        delayNI(250);
      }
      tmC2++;
      if (tmC2 > 20) tmC2 = 0;
      
      lcd.setCursor(0,1);
      lcdPrint(SHIFT_TO_CONFIRM);
      
      buttonsInputAndLEDsOutput();
      if (shiftClick)
      {
        while (1)
        {
          buttonsInputAndLEDsOutput();
          if (!shiftClick) break;
        }
        return true;
        break;
      }
      tmC++;
      if (tmC == 255) break;
      delayNI(10);
    }
    
    doLCDupdate = 1;
    return false;
}

// ======================================================================================= //

void lcdOK()
{
    lcd.clear();
    lcd.setCursor(6,0);
    lcd.write('O'); lcd.write('K');
    delayNI(500);
}

// ======================================================================================= //

void lcdPrint(uint8_t pos)
{
  uint8_t c;
  char* p = (char*)pgm_read_word(&(stringlist[pos]));
  while (c = pgm_read_byte(p)) { lcd.write(c); p++; }
}

void lcdPrintString(char* string)
{
  uint8_t p = 0;
  while (string[p] != 0) { lcd.write(string[p]); p++; }
}

void lcdPrintNumber(uint8_t number)
{
  lcd.write('0'+(number/10));
  lcd.write('0'+(number-((number/10)*10)));
}

void lcdPrintNumber3Dgts(uint8_t number)
{
  if (number >= 200) { lcd.write('2'); number -= 200; }
    else if (number >= 100) { lcd.write('1'); number -= 100; }
    else lcd.write('0');
  lcdPrintNumber(number);
}

// ======================================================================================= //

void printCursor() 
{ 
  if (mirrorPatternEdit) lcd.write(1+(recordEnabled*6)); else lcd.write(recordEnabled*2); 
}

// ======================================================================================= //

void lcdPrintEmptyChars(uint8_t chars)
{
  for (char q=0; q<chars; q++) lcd.write(' ');
}

// ======================================================================================= //

uint8_t dbSteps, dbStepsS, dbStepsSpos =0;
void dbStepsCalc()
{
  dbSteps = (((DRUMTRACKS+2)*editDoubleSteps)+(((DRUMTRACKS+2)*2)*editStepsPos) );
  dbStepsS = (16*editDoubleSteps)+(32*editStepsPos);
  dbStepsSpos = (dmSynthTrackStepPos[0]*32)+dmSynthTrackStepPos[1]+(16*editDoubleSteps);
}

// ======================================================================================= //

void loadNextMode()
{
  if (nextMode != curMode)
  {
    if (songPattEdit && midiClockRunning)
    {
      songPattEdit = 0;
      curMode = nextMode;
      if (setupChanged) saveSetup();
      if (patternChanged) savePattern(0);
      loadSongPosition();
      currentPattern = nextPattern = patternSong-2;
      loadPattern(0);
      patternBufferN = !patternBufferN;
      loadSongNextPosition();
      if (patternSongNext > 1) nextPattern = patternSongNext-2;
      patternSongRepeatCounter = 0;
      curZone = 0;
      updateLCDSong();
    }
    else
    {
      if (midiClockRunning) MidiClockStop();
      if (setupChanged) saveSetup();
      if (curMode == 1 && songChanged) saveSongPosition();
      if (curMode == 0 && patternChanged) savePattern(0);
      checkPatternLoader();
      recordEnabled = editDoubleSteps = shiftClick = stepLEDs = dmMutes = curZone = 0;
      curMode = nextMode;
      if (curMode == 0) 
      {
        currentPattern = nextPattern = 0;
        loadPattern(0);
        patternBufferN = !patternBufferN;
      }
      else if (curMode == 1) 
      {
        loadSongPosition();
      }
      else loadSongName();
      doLCDupdate = 1;
    }
  }
}

void lcdNextMode()
{
      lcdPrint(GOTO);
      lcd.write(0);
      if (nextMode == 0) lcdPrint(PATTRN_MODE);
        else if (nextMode == 1) lcdPrint(SONG_MODE);
        else lcdPrint(FILE_MODE);
      lcdPrintEmptyChars(2);  
}

// ======================================================================================= //

extern void MidiClockStart(uint8_t restart = true);

// ======================================================================================= //
// ======================================================================================= //
// ======================================================================================= //

void wireBeginTransmission(uint16_t address)
{
  Wire.beginTransmission(0x50);
  Wire.send((uint8_t)(address >> 8));
  Wire.send((uint8_t)(address & 0xFFU));
}

void wireEndTransmission()
{
  Wire.endTransmission();
  wireBufferCounter = 0;
  delayNI(6);
}

void wireWrite64check(uint8_t inMiddle)
{
  if ((!inMiddle && wireBufferCounter > 0) || (wireBufferCounter == 64)) wireEndTransmission();
}

// ======================================================================================= //
// ======================================================================================= //
// ======================================================================================= //

void flashEnable()    { SPI.setBitOrder(MSBFIRST); nop(); }
void flashDisable()   { SPI.setBitOrder(LSBFIRST); nop(); }

// ======================================================================================= //

void flashWaitUntilDone()
{
  uint8_t data = 0;
  while (1)
  {
    nop();
    digitalWrite(FLASH_SSn,LOW);
    (void) SPI.transfer(0x05);
    data = SPI.transfer(0);
    digitalWrite(FLASH_SSn,HIGH);
    nop();
    if (!bitRead(data,0)) break;
  }
}

// ======================================================================================= //

void flashInit()
{
  flashEnable();
  digitalWrite(FLASH_SSn,LOW);
  SPI.transfer(0x50); //enable write status register instruction
  digitalWrite(FLASH_SSn,HIGH);
  delayNI(50);
  digitalWrite(FLASH_SSn,LOW);
  SPI.transfer(0x01); //write the status register instruction
  SPI.transfer(0x00); //value to write to register - xx0000xx will remove all block protection
  digitalWrite(FLASH_SSn,HIGH);
  delayNI(50);
  digitalWrite(FLASH_SSn,LOW);
  SPI.transfer(0x06); //write enable instruction
  digitalWrite(FLASH_SSn,HIGH);
  flashWaitUntilDone();
  flashDisable();
}

// ======================================================================================= //

void flashTotalErase()
{
  flashInit();
  flashEnable();
  digitalWrite(FLASH_SSn, LOW); 
  (void) SPI.transfer(0x60); // Erase Chip //
  digitalWrite(FLASH_SSn, HIGH);
  flashWaitUntilDone();
  flashDisable();
}

// ======================================================================================= //

void flashSetAddressSector(uint8_t sector, char offset = 0) // offset is used to go back or forward on a sector bytes
{
  uint32_t addr = (4096UL*((unsigned long)sector)) + ((long)offset);
  (void) SPI.transfer(addr >> 16);
  (void) SPI.transfer(addr >> 8);  
  (void) SPI.transfer(addr);
}

// ======================================================================================= //

void flashReadInit(uint8_t sector, char offset = 0) // offset is used to go back or forward on a sector bytes
{
  flashEnable();
  digitalWrite(FLASH_SSn,LOW);
  (void) SPI.transfer(0x03); // Read Memory - 25/33 Mhz //
  flashSetAddressSector(sector, offset);
}

uint8_t flashReadNext() 
{ 
  return SPI.transfer(0); 
}

void flashReadFinish()
{
  digitalWrite(FLASH_SSn,HIGH);
  flashDisable();
}

// ======================================================================================= //

void flashPageWriteInit(uint8_t sector, uint8_t byte1, uint8_t byte2)
{
  flashInit();
  flashEnable();
  digitalWrite(FLASH_SSn,LOW);
  SPI.transfer(0xAD); // AAI Word Program (Page Write)
  flashSetAddressSector(sector);
  SPI.transfer(byte1);
  SPI.transfer(byte2);
  digitalWrite(FLASH_SSn,HIGH);
  flashWaitUntilDone();
}

void flashPageWriteNext(uint8_t byte1, uint8_t byte2)
{ 
  digitalWrite(FLASH_SSn,LOW);
  SPI.transfer(0xAD); // AAI Word Program (Page Write)
  SPI.transfer(byte1);
  SPI.transfer(byte2);
  digitalWrite(FLASH_SSn,HIGH);
  flashWaitUntilDone();
}

void flashPageWriteFinish()
{
  digitalWrite(FLASH_SSn,LOW);
  SPI.transfer(0x04); //write disable instruction
  digitalWrite(FLASH_SSn,HIGH);
  flashWaitUntilDone();
  flashDisable();
}

// ======================================================================================= //

void flashSectorsErase(uint8_t sector, uint8_t amount)
{
  for (int x=0; x<amount; x++)
  {
    flashInit();
    flashEnable();
    digitalWrite(FLASH_SSn,LOW);
    (void) SPI.transfer(0x20); // Erase 4KB Sector //
    flashSetAddressSector(sector+x);
    digitalWrite(FLASH_SSn,HIGH);
    flashWaitUntilDone();
    flashDisable();
  }
}
