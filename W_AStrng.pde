/*

  Created by Beat707 (c) 2011 - http://www.Beat707.com
  
  Strings to be stored as Program (not in RAM, but in Flash)
  
*/

// GM Drum Set //
#if EXTENDED_DRUM_NAMES
  prog_char string_1[] PROGMEM   = "AcBass";  // 35
  prog_char string_2[] PROGMEM   = "Bass";    // 36
  prog_char string_3[] PROGMEM   = "Stick";   // 37
  prog_char string_4[] PROGMEM   = "Snare";   // 38
  prog_char string_5[] PROGMEM   = "Clap";    // 39
  prog_char string_6[] PROGMEM   = "Snare2";  // 40
  prog_char string_7[] PROGMEM   = "LFlTom";  // 41
  prog_char string_8[] PROGMEM   = "ClosHat"; // 42
  prog_char string_9[] PROGMEM   = "HFlTom";  // 43
  prog_char string_10[] PROGMEM  = "PedlHat"; // 44
  prog_char string_11[] PROGMEM  = "LowTom";  // 45
  prog_char string_12[] PROGMEM  = "OpenHat"; // 46
  prog_char string_13[] PROGMEM  = "LMTom";   // 47
  prog_char string_14[] PROGMEM  = "HMTom";   // 48
  prog_char string_15[] PROGMEM  = "Crash";   // 49
  prog_char string_16[] PROGMEM  = "HiTom";   // 50
  prog_char string_17[] PROGMEM  = "RideCmb"; // 51
  prog_char string_18[] PROGMEM  = "Chinese"; // 52
  prog_char string_19[] PROGMEM  = "RdeBell"; // 53
  prog_char string_20[] PROGMEM  = "Tmbrine"; // 54
  prog_char string_21[] PROGMEM  = "Splash";  // 55
  prog_char string_22[] PROGMEM  = "Cowbell"; // 56
  prog_char string_23[] PROGMEM  = "Crash2";  // 57
  prog_char string_24[] PROGMEM  = "VbrSlap"; // 58
  prog_char string_25[] PROGMEM  = "Ride2";   // 59
  prog_char string_26[] PROGMEM  = "BongoH";  // 60
  prog_char string_27[] PROGMEM  = "BongoL";  // 61
  prog_char string_28[] PROGMEM  = "CongaMt"; // 62
  prog_char string_29[] PROGMEM  = "CongaOp"; // 63
  prog_char string_30[] PROGMEM  = "CongaLw"; // 64
  prog_char string_31[] PROGMEM  = "TmbaleH"; // 65
  prog_char string_32[] PROGMEM  = "TmbaleL"; // 66
  prog_char string_33[] PROGMEM  = "AgogoH";  // 67
  prog_char string_34[] PROGMEM  = "AgogoL";  // 68
  prog_char string_35[] PROGMEM  = "Cabasa";  // 69
  prog_char string_36[] PROGMEM  = "Maracas"; // 70
#else
  prog_char string_2[] PROGMEM   = "Bass";
  prog_char string_3[] PROGMEM   = "Stick";
  prog_char string_4[] PROGMEM   = "Snare";
  prog_char string_5[] PROGMEM   = "Clap";
  prog_char string_8[] PROGMEM   = "ClosHat";
  prog_char string_12[] PROGMEM  = "OpenHat";
  prog_char string_15[] PROGMEM  = "Crash";
#endif

prog_char empty_Str[] PROGMEM  = ""; 
#define EMPTY_STR 0

prog_char myStrings_001[] PROGMEM  = "ReceivingSysEx";
#define RECEIVING_SYSEX 40
prog_char myStrings_002[] PROGMEM  = "Shift to Confirm"; 
#define SHIFT_TO_CONFIRM 41
prog_char myStrings_003[] PROGMEM  = "Pattern"; 
#define PATTERN 42
prog_char myStrings_004[] PROGMEM  = "Next"; 
#define NEXT 43
prog_char myStrings_005[] PROGMEM  = "Init Storage"; 
#define INIT_STORAGE 44
prog_char myStrings_006[] PROGMEM  = "Are you Sure?"; 
#define ARE_YOU_SUREQ 45
prog_char myStrings_007[] PROGMEM  = "Init Starting..."; 
#define INIT_STARTING 46
prog_char myStrings_008[] PROGMEM  = "Change Mode?"; 
#define CHANGE_MODE 47
prog_char myStrings_009[] PROGMEM  = "1/"; 
#define N1_SLASH 48
prog_char myStrings_010[] PROGMEM  = "16"; 
#define N16 49
prog_char myStrings_011[] PROGMEM  = "32";
#define N32 50
prog_char myStrings_012[] PROGMEM  = "64";
#define N64 51
prog_char myStrings_013[] PROGMEM  = "Steps Mode";
#define STEPS_MODE 52
prog_char myStrings_014[] PROGMEM  = "Init Pattern?";
#define INIT_PATTERNQ 53
prog_char myStrings_015[] PROGMEM  = "Paste Pattern?";
#define PASTE_PATTERNQ 54
prog_char myStrings_016[] PROGMEM  = "Shift Mode";
#define SHIFT_MODE 55
prog_char myStrings_017[] PROGMEM  = "Track Selection";
#define TRACK_SELECTION 56
prog_char myStrings_018[] PROGMEM  = "Mute Tracks";
#define MUTE_TRACKS 57
prog_char myStrings_019[] PROGMEM  = "Solo Tracks";
#define SOLO_TRACKS 58
prog_char myStrings_020[] PROGMEM  = "Init Pattern";
#define INIT_PATTERN 59
prog_char myStrings_021[] PROGMEM  = "Copy Pattern";
#define COPY_PATTERN 60
prog_char myStrings_022[] PROGMEM  = "CopyPtr.Accents";
#define COPY_PTR_ACCENTS 61
prog_char myStrings_023[] PROGMEM  = "Paste Pattern";
#define PASTE_PATTERN 62
prog_char myStrings_024[] PROGMEM  = "Pst.MergePattrn";
#define PST_MERGEPATTERN 63
prog_char myStrings_025[] PROGMEM  = "Patt";
#define PATT 64
prog_char myStrings_026[] PROGMEM  = "BPM";
#define BPM 65
prog_char myStrings_027[] PROGMEM  = "Speed Mode";
#define SPEED_MODE 66
prog_char myStrings_028[] PROGMEM  = "GoTo";
#define GOTO 67
prog_char myStrings_029[] PROGMEM  = "Accent";
#define ACCENT 68
prog_char myStrings_030[] PROGMEM  = "MidiChan";
#define MIDICHAN 69
prog_char myStrings_031[] PROGMEM  = "Pattrn.Mode";
#define PATTRN_MODE 70
prog_char myStrings_032[] PROGMEM  = "B707";
#define B707 71
prog_char myStrings_033[] PROGMEM  = "SPos";
#define POSP 72
prog_char myStrings_034[] PROGMEM  = "End";
#define END 73
prog_char myStrings_035[] PROGMEM  = "Song Mode";
#define SONG_MODE 74
prog_char myStrings_036[] PROGMEM  = "Lop";
#define LOP 75
prog_char myStrings_037[] PROGMEM  = "SLV";
#define SLV 76
prog_char myStrings_038[] PROGMEM  = "A1";
#define A1 77
prog_char myStrings_039[] PROGMEM  = "A2";
#define A2 78
prog_char myStrings_040[] PROGMEM  = "S1";
#define S1 79
prog_char myStrings_041[] PROGMEM  = "S2";
#define S2 80
prog_char myStrings_042[] PROGMEM  = "Master";
#define MASTER 81
prog_char myStrings_043[] PROGMEM  = "Sync Mode";
#define SYNC_MODE 82
prog_char myStrings_044[] PROGMEM  = "None";
#define NONE 83
prog_char myStrings_045[] PROGMEM  = "Slave";
#define SLAVE 84
prog_char myStrings_046[] PROGMEM  = "System Init";
#define SYSTEM_INIT 85
prog_char myStrings_047[] PROGMEM  = "None";
#define NONE 86
prog_char myStrings_048[] PROGMEM  = "Note-Off";
#define NOTE_OFF 87
prog_char myStrings_049[] PROGMEM  = "AutoStepsEdt";
#define AUTOSTEPSEDT 88
prog_char myStrings_050[] PROGMEM  = "Song Init";
#define SONGINIT 89
prog_char myStrings_051[] PROGMEM  = "File Mode";
#define FILE_MODE 90
prog_char myStrings_052[] PROGMEM  = "Song";
#define SONG 91
prog_char myStrings_053[] PROGMEM  = "Load";
#define LOAD 92
prog_char myStrings_054[] PROGMEM  = "Save";
#define SAVE 93
prog_char myStrings_055[] PROGMEM  = "Dump";
#define DUMP 94
prog_char myStrings_056[] PROGMEM  = "Erase";
#define ERASE 95
prog_char myStrings_057[] PROGMEM  = "SysEx MIDI ID";
#define SYSEX_MIDI_ID 96
prog_char myStrings_058[] PROGMEM  = "Processing";
#define PROCESSING 97
prog_char myStrings_059[] PROGMEM  = "! Empty Song !";
#define E_EMPTY_SONG_E 98
prog_char myStrings_060[] PROGMEM  = "C C#D D#E F F#G G#A A#B ";
#define NOTENAMESLIST 99
prog_char myStrings_061[] PROGMEM  = "On";
#define ON_ 100
prog_char myStrings_062[] PROGMEM  = "Off";
#define OFF_ 101
prog_char myStrings_063[] PROGMEM  = "Sld";
#define SLD 102
prog_char myStrings_064[] PROGMEM  = "MirrorEdMode";
#define MIRROREDMODE 103
prog_char myStrings_065[] PROGMEM  = "ClockShuffle";
#define CLOCKSHUFFLE 104
prog_char myStrings_066[] PROGMEM  = "# Of Steps";
#define N_OF_STEPS 105


PROGMEM const char *stringlist[] = { empty_Str, 
#if EXTENDED_DRUM_NAMES
  string_1, string_1, string_1, string_1, string_2, string_3, string_4, string_5, string_6, string_7, string_8, string_9, string_10, string_11, string_12, string_13, string_14, string_15, 
  string_16, string_17, string_18, string_19, string_20, string_21, string_22, string_23, string_24, string_25, string_26, string_27, string_28, string_29, string_30, string_31, string_32, string_33, string_34, string_35, string_36, 
#else
  empty_Str, empty_Str, empty_Str, empty_Str, string_2, string_3, string_4, string_5, empty_Str, empty_Str, string_8, empty_Str, empty_Str, empty_Str, string_12, empty_Str, empty_Str, string_15, 
  empty_Str, empty_Str, empty_Str, empty_Str, empty_Str, empty_Str, empty_Str, empty_Str, empty_Str, empty_Str, empty_Str, empty_Str, empty_Str, empty_Str, empty_Str, empty_Str, empty_Str, empty_Str, empty_Str, empty_Str, empty_Str, 
#endif
  myStrings_001, myStrings_002, myStrings_003, myStrings_004, myStrings_005, myStrings_006, myStrings_007, myStrings_008, myStrings_009, myStrings_010, myStrings_011,
  myStrings_012, myStrings_013, myStrings_014, myStrings_015, myStrings_016, myStrings_017, myStrings_018, myStrings_019, myStrings_020, myStrings_021, myStrings_022,
  myStrings_023, myStrings_024, myStrings_025, myStrings_026, myStrings_027, myStrings_028, myStrings_029, myStrings_030, myStrings_031, myStrings_032, myStrings_033,
  myStrings_034, myStrings_035, myStrings_036, myStrings_037, myStrings_038, myStrings_039, myStrings_040, myStrings_041, myStrings_042, myStrings_043, myStrings_044,
  myStrings_045, myStrings_046, myStrings_047, myStrings_048, myStrings_049, myStrings_050, myStrings_051, myStrings_052, myStrings_053, myStrings_054, myStrings_055,
  myStrings_056, myStrings_057, myStrings_058, myStrings_059, myStrings_060, myStrings_061, myStrings_062, myStrings_063, myStrings_064, myStrings_065, myStrings_066};
