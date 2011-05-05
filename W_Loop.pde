/*

  Created by Beat707 (c) 2011 - http://www.Beat707.com
  
  Main Loop
  
*/

// ======================================================================================= //
void loop()
{
  midiInputCheck();
  
  // ======================================================================================= //
  if (doLCDupdate || (lastMillisLateLCDupdate > 0 && lastMillisLateLCDupdate < millisNI()))
  {
    // Force the LCD to be Updated Now //
    doLCDupdate = 0;
    lastMillisLateLCDupdate = 0;
    if (curMode == 0) updateLCDPattern(); 
      else if (curMode == 1) updateLCDSong();
      else updateLCDFile();
  }
      
  // ======================================================================================= //
  if (curMode == 0)
  {
    // PATTERN MODE //
    LEDsPatternTick();
    shiftButtonPattern(); 
  }
  else if (curMode == 1)
  {
    // SONG MODE //
    LEDsSongTick();
    shiftButtonSong();
  }
  else if (curMode == 2)
  {
    // FILE MODE //
    buttonsInputAndLEDsOutput();
    shiftButtonFile();
  }
  
  // ======================================================================================= //
  if (nextPattern != currentPattern)
  {
    // PreLoad New Pattern //
    
    if (patternChanged) savePattern(0);
    if (setupChanged) saveSetup();
    currentPattern = nextPattern;
    loadPattern(0);

    if (!midiClockRunning)
    {
      patternBufferN = !patternBufferN;
      if (curMode == 0) updateLCDPattern(); else updateLCDSong();
    }
    else
    {
      nextPatternReady = 1;
    }
  }
  
  // ======================================================================================= //
  if (curMode == 1 && songNextPosition)
  {
    songNextPosition = 0;
      
    if (patternSongNext == 0)
    {
      if (setupChanged) saveSetup();
      checkPatternLoader();
      recordEnabled = 0;
      curZone = curSongPosition = 0;
      loadSongPosition();
    }
    else
    {
      curSongPosition++;
      patternSongRepeat = patternSongRepeatNext;
      patternSong = patternSongNext;
      loadSongNextPosition();
      if (patternSongNext > 1) nextPattern = patternSongNext-2;
    }
    
    updateLCDSong();
  }

  // ======================================================================================= //
  if (lateAutoSave)
  {
      lateAutoSave = 0;
      if (patternChanged) savePattern(0);
      if (setupChanged) saveSetup();
      if (songChanged) saveSongPosition();
  }

  // ======================================================================================= //
  if (curMode == 0) InterfaceTickPattern(); 
    else if (curMode == 1) InterfaceTickSong();
    else if (curMode == 2) InterfaceTickFile();
  #if EXTRA_8_BUTTONS
    Extra8ButtonsInterface();
  #endif
    
  // ======================================================================================= //  
  if (doPatternLCDupdate && !holdingShift) { doPatternLCDupdate = 0; updateLCDPatNumber(); } // Its in the W_LCD_Patt File

  // ======================================================================================= //    
  Hack_and_Mods_Loop();
}
