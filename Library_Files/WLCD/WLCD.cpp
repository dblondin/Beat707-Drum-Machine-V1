#include "WLCD.h"
#include "WProgram.h"

#define _rs_pin 9
#define _enable_pin 10
#define DP1 4
#define DP2 5
#define DP3 6
#define DP4 7

WLCD::WLCD()
{
  pinMode(_rs_pin, OUTPUT);
  pinMode(_enable_pin, OUTPUT);
  pinMode(DP1, OUTPUT);
  pinMode(DP2, OUTPUT);
  pinMode(DP3, OUTPUT);
  pinMode(DP4, OUTPUT);
  
  _displayfunction = LCD_4BITMODE | LCD_1LINE | LCD_5x8DOTS;
}

void WLCD::begin()
{
  _displayfunction |= LCD_2LINE;
  delayMicroseconds(50000); 
  digitalWrite(_rs_pin, LOW);
  digitalWrite(_enable_pin, LOW);
  
	write4bits(0x03);
	delayMicroseconds(4500); // wait min 4.1ms
	write4bits(0x03);
	delayMicroseconds(4500); // wait min 4.1ms
	write4bits(0x03); 
	delayMicroseconds(150);
	write4bits(0x02); 

  command(LCD_FUNCTIONSET | _displayfunction);  

  _displaycontrol = LCD_DISPLAYON | LCD_CURSOROFF | LCD_BLINKOFF;  
  command(LCD_DISPLAYCONTROL | _displaycontrol);
  clear();
  _displaymode = LCD_ENTRYLEFT | LCD_ENTRYSHIFTDECREMENT;
  command(LCD_ENTRYMODESET | _displaymode);

}

/********** high level commands, for the user! */
void WLCD::clear()
{
  command(LCD_CLEARDISPLAY);  // clear display, set cursor position to zero
  delayMicroseconds(2000);  // this command takes a long time!
}

void WLCD::setCursor(uint8_t col, uint8_t row)
{
  command(LCD_SETDDRAMADDR | (col + (row*0x40)));
}

// Turns the underline cursor on/off
void WLCD::noCursor() {
  _displaycontrol &= ~LCD_CURSORON;
  command(LCD_DISPLAYCONTROL | _displaycontrol);
}
void WLCD::cursor() {
  _displaycontrol |= LCD_CURSORON;
  command(LCD_DISPLAYCONTROL | _displaycontrol);
}

// Turn on and off the blinking cursor
void WLCD::noBlink() {
  _displaycontrol &= ~LCD_BLINKON;
  command(LCD_DISPLAYCONTROL | _displaycontrol);
}
void WLCD::blink() {
  _displaycontrol |= LCD_BLINKON;
  command(LCD_DISPLAYCONTROL | _displaycontrol);
}

void WLCD::createChar(uint8_t* charmap) 
{
  for (int location=0; location<8; location++)
  {
	command(LCD_SETCGRAMADDR | (location << 3));
	for (int i=0; i<8; i++) 
	{
	    write(charmap[(location*8)+i]);
	}
  }
}

/*********** mid level commands, for sending data/cmds */

inline void WLCD::command(uint8_t value) {
  send(value, LOW);
}

inline void WLCD::write(uint8_t value) {
  send(value, HIGH);
}

/************ low level data pushing commands **********/

// write either command or data, with automatic 4/8-bit selection
void WLCD::send(uint8_t value, uint8_t mode) {
  digitalWrite(_rs_pin, mode);
  write4bits(value>>4);
  write4bits(value);
}

void WLCD::pulseEnable(void) {
  digitalWrite(_enable_pin, LOW);
  delayMicroseconds(1);    
  digitalWrite(_enable_pin, HIGH);
  delayMicroseconds(1);    // enable pulse must be >450ns
  digitalWrite(_enable_pin, LOW);
  delayMicroseconds(100);   // commands need > 37us to settle
}

void WLCD::write4bits(uint8_t value) {
  digitalWrite(DP1, (value >> 0) & 0x01);
  digitalWrite(DP2, (value >> 1) & 0x01);
  digitalWrite(DP3, (value >> 2) & 0x01);
  digitalWrite(DP4, (value >> 3) & 0x01);

  pulseEnable();
}