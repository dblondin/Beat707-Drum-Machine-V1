/*

  Created by Beat707 (c) 2011 - http://www.Beat707.com
  
  Storage (external EEPROM) Init, Reading and Saving
    
*/

// ======================================================================================= //
#define prePosLS 28
#define prePos (prePosLS+DRUMTRACKS+2+DRUMTRACKS+(MAXSONGPOS*2)) // 256 bytes - should always be a multple of 64 for the EEPROM page write faster code
#define patternSizeBytes (((DRUMTRACKS+2)*4*2)+128) // First numbers are 16 bits, that's why the extra *2 - Total of 256 bytes //
#define totalSongSize prePos+(patternSizeBytes*MAXSPATTERNS)  // 23296 bytes (99 SongsPos + 90 Patterns) + 14 bytes for the song name = 23310 (6 sectors of Flash has 24576 of space)
                                                              // A special note about totalSongSize, the flash code writes in pairs of 2 bytes, (to speed up) so the song size should be a multiple of 2

// ======================================================================================= //
void savePattern(uint8_t saveAccentsOnly)
{
  patternChanged = wireBufferCounter = 0;
  
  for (char q=0; q<((DRUMTRACKS+2)*4); q++) 
  { 
    if (wireBufferCounter == 0) wireBeginTransmission((prePos+(q*2)+(currentPattern*patternSizeBytes)));
    byte lowByte = (((int)dmSteps[patternBufferN][q] >> 0) & 0xFF);
    byte highByte = (((int)dmSteps[patternBufferN][q] >> 8) & 0xFF);
    if (saveAccentsOnly && q != (((DRUMTRACKS+2)*0)+DRUMTRACKS) && q != (((DRUMTRACKS+2)*1)+DRUMTRACKS) && q != (((DRUMTRACKS+2)*2)+DRUMTRACKS) && q != (((DRUMTRACKS+2)*3)+DRUMTRACKS)) lowByte = highByte = 0;
    Wire.send(lowByte);
    Wire.send(highByte);
    wireBufferCounter += 2;
    wireWrite64check(true);
  }
  wireWrite64check(false);
  
  wireBeginTransmission(prePos+(currentPattern*patternSizeBytes)+((DRUMTRACKS+2)*8));
  for (char q=0; q<64; q++) Wire.send((saveAccentsOnly) ? 0 : dmSynthTrack[0][patternBufferN][q]);
  wireEndTransmission();

  wireBeginTransmission(prePos+(currentPattern*patternSizeBytes)+64+((DRUMTRACKS+2)*8));
  for (char q=0; q<64; q++) Wire.send((saveAccentsOnly) ? 0 : dmSynthTrack[1][patternBufferN][q]);
  wireEndTransmission();
}

// ======================================================================================= //
void loadPattern(uint8_t mergePattern)
{
  wireBeginTransmission(prePos+(currentPattern*patternSizeBytes));
  Wire.endTransmission();
  Wire.requestFrom(0x50,((DRUMTRACKS+2)*8));
  for (char q=0; q<((DRUMTRACKS+2)*4); q++)
  {
    if (mergePattern) dmSteps[!patternBufferN][q] |= ((Wire.receive() << 0) & 0xFF) + ((Wire.receive() << 8) & 0xFF00);
      else dmSteps[!patternBufferN][q] = ((Wire.receive() << 0) & 0xFF) + ((Wire.receive() << 8) & 0xFF00);
  }

  wireBeginTransmission(prePos+(currentPattern*patternSizeBytes)+((DRUMTRACKS+2)*8));
  Wire.endTransmission();
  Wire.requestFrom(0x50,128);
  for (char q=0; q<64; q++) { if (mergePattern) dmSynthTrack[0][!patternBufferN][q] |= Wire.receive(); else dmSynthTrack[0][!patternBufferN][q] = Wire.receive(); }
  for (char q=0; q<64; q++) { if (mergePattern) dmSynthTrack[1][!patternBufferN][q] |= Wire.receive(); else dmSynthTrack[1][!patternBufferN][q] = Wire.receive(); }
}

// ======================================================================================= //
void loadSongPosition()
{
  if (curSongPosition < 0) curSongPosition = 0;
  
  patternSong = EEPROM_READ((prePosLS+(DRUMTRACKS*2))+curSongPosition);
  patternSongRepeat = EEPROM_READ((prePosLS+(DRUMTRACKS*2)+MAXSONGPOS)+curSongPosition);
}

// ======================================================================================= //
void loadSongNextPosition()
{
  if ((curSongPosition+1) < MAXSONGPOS) patternSongNext = EEPROM_READ((prePosLS+(DRUMTRACKS*2))+(curSongPosition+1)); else patternSongNext = patternSong;
    
  if (patternSongNext == 1) 
  {
    patternSongNext = EEPROM_READ((prePosLS+(DRUMTRACKS*2))); 
    patternSongRepeatNext = EEPROM_READ((prePosLS+(DRUMTRACKS*2)+MAXSONGPOS));
    songLoopPos = curSongPosition;
    curSongPosition = -1; 
  }
  else
  {
    patternSongRepeatNext = EEPROM_READ((prePosLS+(DRUMTRACKS*2)+MAXSONGPOS)+curSongPosition+1);
  }
}

// ======================================================================================= //
void saveSongPosition()
{
  songChanged = 0;
  
  EEPROM_WRITE((prePosLS+(DRUMTRACKS*2))+curSongPosition,patternSong);
  EEPROM_WRITE((prePosLS+(DRUMTRACKS*2)+MAXSONGPOS)+curSongPosition,patternSongRepeat);
}

// ======================================================================================= //
void saveSetup()
{
  setupChanged = 0;
  
  wireBeginTransmission(0);
  Wire.send('B');
  Wire.send('7');
  Wire.send('0');
  Wire.send('7');
  for (char q=4; q<prePosLS; q++)
  {
    uint8_t value = 0;
    if (q == 6) value = midiClockType;
      else if (q == 7) value = SONG_VERSION;
      else if (q == 8) value = timeScale;
      else if (q == 9) value = midiClockBPM;
      else if (q == 10) value = sysMIDI_ID;
      else if (q == 11) value = autoSteps;
      else if (q == 12) value = mirrorPatternEdit;
      else if (q == 13) value = midiClockShuffle;
      else if (q == 14) value = numberOfSteps;
      else if (q == 15) value = enableABpattern;
      #if ANALOG_INPUT_A0
      else if (q == 16) value = analogInputMode;
      #endif
      else if (q == 17) value = midiUSBmode;
      else if (q == 18) value = externalMIDIportSelector; // slot 18 is used for an external variable: MIDI Out Port - for the USB to MIDI Converter  
      else if (q == 19) value = midiClockDirection;
      
    Wire.send(value);
  }
  for (char x=0; x<DRUMTRACKS; x++) Wire.send(dmNotes[x]); 
  for (char x=0; x<DRUMTRACKS+2; x++) Wire.send(dmChannel[x]); 
  wireEndTransmission();
}

// ======================================================================================= //
void loadSetup()
{
  midiClockType = EEPROM_READ(6);
  timeScale = EEPROM_READ(8);
  midiClockBPM = EEPROM_READ(9);
  sysMIDI_ID = EEPROM_READ(10);
  autoSteps = EEPROM_READ(11);
  mirrorPatternEdit = EEPROM_READ(12);
  midiClockShuffle = EEPROM_READ(13);
  numberOfSteps = EEPROM_READ(14);
  if (numberOfSteps == 0 || numberOfSteps > 16) numberOfSteps = 16;
  enableABpattern = EEPROM_READ(15);
  #if ANALOG_INPUT_A0
    analogInputMode = EEPROM_READ(16);
  #endif
  midiUSBmode = EEPROM_READ(17);
  externalMIDIportSelector = EEPROM_READ(18); // slot 18 is used for an external variable: MIDI Out Port - for the USB to MIDI Converter  
  midiClockDirection = EEPROM_READ(19);
  
  wireBeginTransmission(prePosLS);
  Wire.endTransmission();
  Wire.requestFrom(0x50,((DRUMTRACKS*2)+2));
  for (char x=0; x<DRUMTRACKS; x++) dmNotes[x] = Wire.receive();
  for (char x=0; x<DRUMTRACKS+2; x++) dmChannel[x] = Wire.receive();
}

// ======================================================================================= //
boolean checkStorageHeader()
{
  #if DISABLE_STORAGE_CHK
    return true;
  #endif
  
  if (EEPROM_READ(7) != SONG_VERSION || EEPROM_READ(0) != 'B' || EEPROM_READ(1) != '7' || EEPROM_READ(2) != '0' || EEPROM_READ(3) != '7') return false;
  return true;
}

// ======================================================================================= //
void storageInit(uint8_t forceInit)
{
  if (STORAGE_FORCE_INIT || !checkStorageHeader() || forceInit)
  {
    lcd.clear();
    lcd.setCursor(2,0);
    lcdPrint(INIT_STORAGE);
    lcd.setCursor(3,1);
    if (!hitShiftToConfirm()) return;

    lcd.clear();
    lcd.setCursor(1,0);        
    lcdPrint(ARE_YOU_SUREQ);
    if (!hitShiftToConfirm()) return; // Just to be sure an accidental INIT doesn't happen //
    
    lcd.clear();
    lcd.setCursor(0,0);
    lcdPrint(INIT_STARTING);
    lcd.setCursor(7,1); lcd.write('3');
  
    // Init Storage //   
    for (char q=0; q<prePosLS; q++) { EEPROM_WRITE(q,0); }
    EEPROM_WRITE(0,'B');
    EEPROM_WRITE(0,'7');
    EEPROM_WRITE(0,'0');
    EEPROM_WRITE(0,'7');
    EEPROM_WRITE(7,SONG_VERSION);

    // Save Setup //
    saveSetup();
    for (int q=0; q<MAXSONGPOS; q++)
    {
      EEPROM_WRITE((prePosLS+(DRUMTRACKS*2))+q,0);
      EEPROM_WRITE((prePosLS+(DRUMTRACKS*2)+MAXSONGPOS)+q,0);
    }
    EEPROM_WRITE((prePosLS+(DRUMTRACKS*2)),2); // So the song is not empty //
    
    lcd.setCursor(7,1); lcd.write('2');
    
    for (char x=0; x<=MAXSPATTERNS; x++) // We go above MAXSPATTERNS as the last is for the Copy/Paste code
    {   
      currentPattern = x; 
      savePattern(0);
    }
    currentPattern = 0;
    
    lcd.setCursor(7,1); lcd.write('1');

    flashTotalErase();
    delayNI(1000);
    
    #if INIT_EMPTY_SONG
      lcd.setCursor(7,1); lcd.write('0');
      fileSelected = 0;
      strcpy(fileSongName,"Init Song");
      delayNI(1000);
      songSave();
    #endif

    lcdOK();
    delayNI(2000);
  }
}

// ======================================================================================= //
// ======================================================================================= //
// ======================================================================================= //
// ======================================================================================= //

/*

  Flash 4Mbit = 4 * 1024 * 1024 = 4194304 bits / 8 = 524288 bytes = 512 KBytes
  The address byte requires 20 bits = 10000000000000000000 = 524288 (the chip requires a 24 bit address number)
  4Kbyte Sectors = 4 * 1024 = 4096 bytes = 128 sectors for the whole chip
  Each song, using 99 SongsPos and 90 Patterns (+14 char for the song name) = 23310 bytes = 6 sectors = 21 Songs on the chip  
  Plus, the Flash Write code saves data in pairs of 2 bytes, therefore, song size should be a multiple of 2.

*/

void loadSongName(void)
{
  memset(fileSongName,0,sizeof(fileSongName));
  
  // Check if the current selected song slot is not empty //
  if (checkSong())
  {
    flashReadInit(fileSelected*6);
    for (int q=0; q<14; q++) { fileSongName[q] = flashReadNext();  }
    flashReadFinish();
  }
  else
  {    
    strcpy(fileSongName,"Empty Song");
  }
}

// ======================================================================================= //

uint8_t checkSong(void)
{   
  uint8_t chSng = true;

  flashReadInit(fileSelected*6, 14);
  if (flashReadNext() != 'B') chSng = false;
  if (flashReadNext() != '7') chSng = false;
  if (flashReadNext() != '0') chSng = false;
  if (flashReadNext() != '7') chSng = false;
  flashReadFinish();
  
  return chSng;
}

// ======================================================================================= //
void songErase()
{
  flashSectorsErase(fileSelected,6);
}

// ======================================================================================= //

void songLoad()
{
  wireBufferCounter = 0;
  flashReadInit(fileSelected*6); 
  for (int q=0; q<14; q++) { fileSongName[q] = flashReadNext();  }     
  for (int q=0; q<totalSongSize; q++) 
  {     
    if (wireBufferCounter == 0) wireBeginTransmission(q);
    Wire.send(flashReadNext());
    wireBufferCounter++;
    wireWrite64check(true);
  }
  wireWrite64check(false);
  flashReadFinish();
  loadSetup();  
}

// ======================================================================================= //

void songSave()
{
  songErase();
  if (!strcmp(fileSongName,"Empty Song")) sprintf(fileSongName, "Song %02d",fileSelected+1);
  flashPageWriteInit(fileSelected*6, fileSongName[0], fileSongName[1]);
  for (int q=2; q<14; q += 2) { flashPageWriteNext(fileSongName[q], fileSongName[q+1]); }
  for (int q=0; q<totalSongSize; q += 2) { flashPageWriteNext(EEPROM_READ(q), EEPROM_READ(q+1)); }
  flashPageWriteFinish();
}

// ======================================================================================= //

#if MIDI_SYSEX_DMP_RC
  void songDump()
  {
    // Each Serial TX Print checks if the next buffer is empty, therefore there's no need to check for "buffer-full" when sending data serially
    
    MSerial.write(0xF0);   // System Exclusive Data
    MSerial.write(0x01);   // Manufacturer's ID - 1
    MSerial.write(0x08);   // Manufacturer's ID - 2
    MSerial.write(0x04);   // Manufacturer's ID - 3
    MSerial.write(0x02);   // Manufacturer's ID - 4
    MSerial.write(0x09);   // Manufacturer's ID - 5
    MSerial.write(sysMIDI_ID); // User's ID - 6
    delayNI(10);
    
    // Send only 4 bits at a time as numbers can't go above F0 //
  
    uint8_t xtemp = 0;
    uint8_t xPerc = 0;
    flashReadInit(fileSelected*6);
    for (int q=0; q<14; q++) 
    { 
      xtemp = flashReadNext();
      MSerial.write((xtemp & 0x0F));    // Send 4 LSB's
      MSerial.write((xtemp>>4) & 0x0F);  // Send 4 MSB's
      delayNI(1);
    }    
    for (int q=0; q<totalSongSize; q++) 
    {
      xPerc++;
      if (xPerc == 100)
      {
        xPerc = 0;
        lcd.setCursor(4,1);
        lcdPrintNumber3Dgts(q/512);
        lcd.write('/');
        lcdPrintNumber3Dgts(totalSongSize/512);
      }
      
      xtemp = flashReadNext();
      MSerial.write((xtemp & 0x0F));    // Send 4 LSB's
      MSerial.write((xtemp>>4) & 0x0F);  // Send 4 MSB's
      delayNI(1);
    }
    flashReadFinish();
    MSerial.write(0xF7);
  }
#endif

  // ======================================================================================= //
  
void songDumpReceive(void)
{
  uint32_t address = 0;
  wireBufferCounter = 0;
  
  if (midiClockRunning) goto sysExEnd;
  
  // First check Manufacturer's ID bytes 1 to 6 and User's ID //
  if (midiInput() != 0x01) goto sysExEnd;
  if (midiInput() != 0x08) goto sysExEnd;
  if (midiInput() != 0x04) goto sysExEnd;
  if (midiInput() != 0x02) goto sysExEnd;
  if (midiInput() != 0x09) goto sysExEnd;
  if (midiInput() == 100)
  {
    if (midiInput() != sysMIDI_ID) goto sysExEnd;
    
    // Special USB Check for the USB to MIDI Program //
    lcd.clear();
    lcd.setCursor(1,0);
    lcdPrint(USB_TO_MIDI_OK);
    #if !MIDIECHO
      MSerial.write(240);
    #endif
    MSerial.write('B'); MSerial.write('7'); MSerial.write('0'); MSerial.write('7'); MSerial.write(EEPROM_READ(18));
    #if !MIDIECHO
      MSerial.write(247);
    #endif
    delayNI(2000);
    goto sysExEnd;
  }
  else if (incomingByte == 101)
  {
    // Stores external selected MIDI Output Port from the USB to MIDI converter program
    if (midiInput() != sysMIDI_ID) goto sysExEnd;
    externalMIDIportSelector = midiInput();
    EEPROM_WRITE(18,externalMIDIportSelector);
    goto sysExEnd;
  }
  else if (incomingByte != sysMIDI_ID) goto sysExEnd;
  
  #if MIDI_SYSEX_DMP_RC
    if (midiClockRunning) MidiClockStop(); // Stop MIDI Clock while receiving SySex Dump //    
    
    lcd.clear();
    lcd.setCursor(2,0);
    lcdPrint(PROCESSING);
    lcd.setCursor(1,1);
    lcdPrint(RECEIVING_SYSEX);
    
    while (1)  
    {
      uint8_t byte4a = midiInput();
      if (byte4a == 247) break;
      uint8_t byte4b = midiInput();
      
      if (address < 14) fileSongName[address-totalSongSize] = ((byte4b << 4) | byte4a);
      else
      {
        if (wireBufferCounter == 0) wireBeginTransmission(address-14);
        Wire.send((byte4b << 4) | byte4a);
        wireBufferCounter++;
        wireWrite64check(true);
      }
      address++;
    }
    wireWrite64check(false);
    
    lcdOK();
    doLCDupdate = 1;
    return;
  #endif
  
  sysExEnd:
  while (incomingByte != 247) { midiInput(); }
  doLCDupdate = 1;
}
