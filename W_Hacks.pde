/*

  Created by Beat707 (c) 2011 - http://www.Beat707.com
  
  Hacks and Mods: as used by several areas of the code
  Check the Config.h file and also the online Hack Area at: 
  http://www.beat707.com/w/downloads/hacks-and-mods  
  
*/

// ======================================================================================= //    
void Hack_and_Mods_Loop()
{
  // ------------------------------------------------------------------------------------- //
  #if ANALOG_INPUT_A0
    #if ANALOG_INPUT_BT
    if (digitalRead(2) == HIGH) prevAnalogButtonCheckState = HIGH;
    if (curMode != 2 && analogInputModeNewDelay < millisNI() && digitalRead(2) == LOW)
    #else
    if (curMode != 2 && !holdingShift && analogInputModeNewDelay < millisNI())
    #endif
    {
      #if ANALOG_INPUT_BT
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

  // ------------------------------------------------------------------------------------- //
  #if GATE_OUTS
    for (int gx=0; gx<3; gx++)
    {
      if (gateOutDelay[gx] != 0 && gateOutDelay[gx] < millisNI())
      {
        gateOutDelay[gx] = 0;
        switch (gx)
        {
          case 0:
            digitalWrite(A0, LOW);
            break;
            
          case 1:
            digitalWrite(2, LOW);
            break;
            
          case 2:
            #if GATE_OUTS_VEL_D3
              analogWrite(3, 0);
            #else
              digitalWrite(3, LOW);
            #endif
            break;
        }
      }
    }
  #endif
}

// ======================================================================================= //    
#if GATE_OUTS
  void Gate_Outs_Midi()
  {
    if (xdtm <= 2)
    {
      switch (xdtm)
      {
        case 0:
          digitalWrite(A0, HIGH);
          break;
          
        case 1:
          digitalWrite(2, HIGH);
          break;
          
        case 2:
          #if GATE_OUTS_VEL_D3
            analogWrite(3, velocity*8);
          #else
            digitalWrite(3, HIGH);
          #endif
          break;
      }
      gateOutDelay[xdtm] = millisNI()+GATE_OUTS_TIME;            
    }
    else
    {
      sendMidiNoteOff(dmNotes[xdtm], dmChannel[xdtm]);
      sendMidiNoteOn(dmNotes[xdtm],velocity, dmChannel[xdtm]);
    }
  }
#endif

#if EXTRA_8_BUTTONS
  // ======================================================================================= //
  /*
    Extra 8 Buttons User Interface (only used if EXTRA_8_BUTTONS is set to 1)
    You can also use the holdingShift variable to check for the Shift key
    Also, if you plan on adding a button on a determinated mode, use the following variable: curMode // 0=Pattern Mode, 1=Song Mode, 2=File Mode
  */  
  void Extra8ButtonsInterface()
  {  
    switch (multiButton)
    {  
      // ------------------------------- Button 1 ------------------------------- //
      case 21:
        // User Code Here //
      break;
      
      // ------------------------------- Button 2 ------------------------------- //
      case 22:
        // User Code Here //
      break;
      
      // ------------------------------- Button 3 ------------------------------- //
      case 23:
        // User Code Here //
      break;
      
      // ------------------------------- Button 4 ------------------------------- //
      case 24:
        // User Code Here //
      break;
      
      // ------------------------------- Button 5 ------------------------------- //
      case 25:
        // User Code Here //
      break;
      
      // ------------------------------- Button 6 ------------------------------- //
      case 26:
        // User Code Here //
      break;
      
      // ------------------------------- Button 7 ------------------------------- //
      case 27:
        // User Code Here //
      break;
      
      // ------------------------------- Button 8 ------------------------------- //
      case 28:
        // User Code Here //
      break;
    }
  }
#endif
