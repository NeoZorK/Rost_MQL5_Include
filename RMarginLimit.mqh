//+------------------------------------------------------------------+
//|                                                 RMarginLimit.mqh |
//|                 Copyright 2020-2021, \x2662 Rostyslav Shcherbyna |
//| Margin Limit for One Symbol (Singleton)                          |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020,\x2662 Rostyslav Shcherbyna"
#property description "\x2620 Margin Limit Class"
#property description " Margin Limit for One Symbol, each class controls only one Symbol."
#property description " max limit % from total margin"
#property description " use by Open prices only"
#property link      "\x2620 neozork@protonmail.com"
#property version   "1.00"
/*
Description: Limit symbol by FreeMargin if more, do not open New Positions!

1) Init to onInit()
2) Call Check_Margin_Limit_in_pcnt()

Limit for margin in use up to 100% (no limit)
0% means no free margin for open new positions at all

*/
//+------------------------------------------------------------------+
//| STRUCT INIT                                                      |
//+------------------------------------------------------------------+
struct STRUCT_INIT_MARGINLIMIT
  {
   string                              pair;                               // Symbol
   double                              max_Available_Margin_prcnt;         // max available margin %
  };
//+------------------------------------------------------------------+
//|  RMarginLimit CLASS                                              |
//+------------------------------------------------------------------+
class RMarginLimit
  {
private:

   string                  m_pair;
   double                  m_max_margin_prcnt;                             // max margin percent


public:
                     RMarginLimit();
                    ~RMarginLimit();

   // Init
   void                    Init(const STRUCT_INIT_MARGINLIMIT &Init);

   // Check Available Margin Percent (true - can open new positions)
   bool                    Pass_Margin_pcnt_Limit();


  };
//+------------------------------------------------------------------+
//|  Constructor                                                     |
//+------------------------------------------------------------------+
RMarginLimit::RMarginLimit()
  {
  }
//+------------------------------------------------------------------+
//|  Destructor                                                      |
//+------------------------------------------------------------------+
RMarginLimit::~RMarginLimit()
  {
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|  INIT                                                            |
//+------------------------------------------------------------------+
void RMarginLimit::Init(const STRUCT_INIT_MARGINLIMIT &Init)
  {
   m_pair = Init.pair;
   m_max_margin_prcnt = Init.max_Available_Margin_prcnt;
  }
//+------------------------------------------------------------------+
//|    PASS margin Limit (true - was passed)                         |
//+------------------------------------------------------------------+
bool RMarginLimit::Pass_Margin_pcnt_Limit(void)
  {
  

// Max Limit reached, no new positions, exit
   return(false);
  }
//+------------------------------------------------------------------+
