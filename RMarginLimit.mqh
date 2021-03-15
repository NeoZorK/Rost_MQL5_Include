//+------------------------------------------------------------------+
//|                                                 RMarginLimit.mqh |
//|                 Copyright 2020-2021, \x2662 Rostyslav Shcherbyna |
//| Margin Limit for One Symbol (Singleton)                          |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020,\x2662 Rostyslav Shcherbyna"
#property description "\x2620 Margin Limit Class"
#property description " Margin Limit for One Symbol, each class controls only one Symbol"
#property description " use by Open prices only"
#property link      "\x2620 neozork@protonmail.com"
#property version   "1.00"
/*
Description: Limit symbol by FreeMargin if Less, do not open New Positions!

1) Init to onInit()
2) Call Check_Margin_Limit()
*/
//+------------------------------------------------------------------+
//|  RMarginLimit CLASS                                              |
//+------------------------------------------------------------------+
class RMarginLimit
  {
private:



public:
                     RMarginLimit();
                    ~RMarginLimit();

   // Init
   void                    Init();


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
void RMarginLimit::Init(void)
  {

  }
//+------------------------------------------------------------------+

