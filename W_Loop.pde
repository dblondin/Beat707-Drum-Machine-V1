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
    
  // ======================================================================================= //  
  if (doPatternLCDupdate && !holdingShift) { doPatternLCDupdate = 0; updateLCDPatNumber(); } // Its in the W_LCD_Patt File

  // ======================================================================================= //    
  #if ANALOG_INPUT_A0
    #if ANALOG_INPUT_CHECK
    if (digitalRead(2) == HIGH) prevAnalogButtonCheckState = HIGH;
    if (curMode != 2 && analogInputModeNewDelay < millisNI() && digitalRead(2) == LOW)
    #else
    if (curMode != 2 && !holdingShift && analogInputModeNewDelay < millisNI())
    #endif
    {
      #if ANALOG_INPUT_CHECK
        if (prevAnalogButtonCheckState == HIGH)
        {
          analogInputModeNewDelay = millisNI()+ANALOG_MDLY;
          prevAnalogButtonCheckState = LOW;
          return;
        }
      #endif     
      
      int val = analogRead(A0);
      if (val != prevAnalogA0value)
      {
        prevAnalogA0value = val;
        switch (analogInputMode)
        {
          case 0: midiClockBPM = map(val, 0, 1023, 25, 255); if (midiClockRunning) MidiClockNewTime(); break;
          case 1: nextPattern = map(val, 0, 1023, 0, ANALOG_PATT_MAX); break;
          case 2: numberOfSteps = map(val, 0, 1023, 1, 16); break;
          case 3: currentTrack = map(val, 0, 1023, 0, (DRUMTRACKS+3)); break;
          case 4: 
            dbStepsCalc();
            if (currentTrack < DRUMTRACKS)
            {
              dmNotes[currentTrack] = map(val, 0, 1023, 0, 127);
            }
            else if (currentTrack < (DRUMTRACKS+2))
            {
              uint8_t dTrack = currentTrack-DRUMTRACKS;
              if (mirrorPatternEdit)
              {
                dmSynthTrack[dTrack][patternBufferN][dmSynthTrackStepPos[1]+(16*editDoubleSteps)] = map(val, 0, 1023, 0, 255);;
                dmSynthTrack[dTrack][patternBufferN][dmSynthTrackStepPos[1]+(16*editDoubleSteps)+32] = dmSynthTrack[dTrack][patternBufferN][dmSynthTrackStepPos[1]+(16*editDoubleSteps)];
                if (dmSynthTrack[dTrack][patternBufferN][dmSynthTrackStepPos[1]+(16*editDoubleSteps)] > 1) dmSynthTrackLastNoteEdit[dTrack] = dmSynthTrack[dTrack][patternBufferN][dmSynthTrackStepPos[1]+(16*editDoubleSteps)];
              }
              else
              {
                dmSynthTrack[dTrack][patternBufferN][dmSynthTrackStepPos[1]+(16*editDoubleSteps)] = map(val, 0, 1023, 0, 255);;
                if (dmSynthTrack[dTrack][patternBufferN][dbStepsSpos] > 1) dmSynthTrackLastNoteEdit[dTrack] = dmSynthTrack[dTrack][patternBufferN][dbStepsSpos];
              }
              patternChanged = 1;
            }
            break;
        }
        setupChanged = 1;
        doLCDupdate = 1;
      }
    }
  #endif
}
