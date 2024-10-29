//+------------------------------------------------------------------+
//|                                                 ROnOpenPrice.mqh |
//|                Copyright 2020-2021 , \x2662 Rostyslav Shcherbyna |
//| Do Not Calculate Each Tick, Only New Bar!                        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020-2021,\x2662 Rostyslav Shcherbyna"
#property description "\x2620 ROnOpenPrice Class"
#property description " Calculate only on New Bars  "
#property link      "\x2620 neozork@protonmail.com"
#property version   "1.00"
/*
Description: NewBar = True, OldBar = False

1) Init to onInit()
2) Call isNewBar() method in onTick() function before any Calculations...
*/
//+------------------------------------------------------------------+
//|  by Open Prices Only (isNewBar)                                  |
//+------------------------------------------------------------------+
class ROnOpenPrice
  {
private:

   // Control of new bar
   datetime          m_arr_open_bars[1];
   datetime          m_new_bar_time;

public:
                     ROnOpenPrice();
                    ~ROnOpenPrice();

   // Init
   void                    Init();

   // Check if NewBar
   bool                    isNewBar(const bool &UseTicks);
  };
//+------------------------------------------------------------------+
//|  Constructor                                                     |
//+------------------------------------------------------------------+
ROnOpenPrice::ROnOpenPrice()
  {
  }
//+------------------------------------------------------------------+
//|  Destructor                                                      |
//+------------------------------------------------------------------+
ROnOpenPrice::~ROnOpenPrice()
  {
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|  INIT                                                            |
//+------------------------------------------------------------------+
void ROnOpenPrice::Init(void)
  {
   m_arr_open_bars[0] = 0;
   m_new_bar_time = 0;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| is New Bar ?                                                     |
//+------------------------------------------------------------------+
bool ROnOpenPrice::isNewBar(const bool &UseTicks)
  {
// Real Ticks -> Calc Each Tick
   if(UseTicks)
      return true;

//Latest Bar Time
   CopyTime(_Symbol, _Period, 0, 1, m_arr_open_bars);
//If NEW Bar, save it time
   if(m_arr_open_bars[0] > m_new_bar_time)
     {
      m_new_bar_time = m_arr_open_bars[0];
      return(true);
     }

//If not New Bar, Exit
   else
      return(false);
  }//END OF IS NEW BAR
//+------------------------------------------------------------------+
