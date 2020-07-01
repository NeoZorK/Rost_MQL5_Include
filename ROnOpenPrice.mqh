//+------------------------------------------------------------------+
//|                                                 ROnOpenPrice.mqh |
//|                                           Copyright 2020,NeoZorK |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020,NeoZorK"
#property link      ""
#property version   "1.00"
/*
Description: NewBar = True, OldBar = False
Call This method in onTick() function before any Calculations...

on Constructor:
1) Create 

on Destructor:

*/

class ROnOpenPrice
  {
private:

// Control of new bar
   datetime          m_arr_open_bars[1];
   datetime          m_new_bar_time;

public:
                     ROnOpenPrice();
                    ~ROnOpenPrice();
  };
//+------------------------------------------------------------------+
//|  Constructor                                                     |
//+------------------------------------------------------------------+
ROnOpenPrice::ROnOpenPrice()
  {
   m_arr_open_bars[0]=0;
   m_new_bar_time=0;
  }
//+------------------------------------------------------------------+
//|  Destructor                                                      |
//+------------------------------------------------------------------+
ROnOpenPrice::~ROnOpenPrice()
  {
  }
//+------------------------------------------------------------------+
