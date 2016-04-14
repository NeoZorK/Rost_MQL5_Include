//+------------------------------------------------------------------+
//|                                                         RCat.mqh |
//|                             Copyright 2016, Shcherbyna Rostyslav |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Shcherbyna Rostyslav"
#property link      ""
#property version   "1.00"

#include <Tools\DateTime.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*
1. Save Symbol
2. Calculate Lot ?
3. add constants Ck Signals to global
4. TR_RES = -1 (if errors occures)
5. Get Last Ind Buffers
6. Select Trading Rule  POMI
7.? If Signal -> Save her Minute
8. Count signals in a row (separatly buy & sell)
9. Check TR AutoClose(TR_RES) -> AutoClose DC Spread = true then continue;
10. Check If Future End of period NOW, then CloseAllPositions
11. If Spread>MaxSpread Continue;
12. if TR_RES<0 then exit (err or no signal)
13. Quant mode here ?
14. If any opened position ? bool ,save
15. If No OPen Pos & TR_RES=BUY1 then OpenBuyMarket and Exit (same for Sell)
16. //ADD VOLUME
17. if already open position
18. get pos volume
19. check if posvolume > maxVolume -> exit
20. get pos_open price
21. get pos_current_price
22. get pos_direction
23. get symbol_point (can be once onInit)
24. if CurrentPOs=Buy & TR_RES= BUY then if price Lower then AddVolumeBUY else exit
25. same for sell
26. Ok! Thats All!    
*/
//+------------------------------------------------------------------+
//| Class for Real Time Trading                                      |
//+------------------------------------------------------------------+
class RCat
  {
private:

public:
                     RCat();
                    ~RCat();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
RCat::RCat()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
RCat::~RCat()
  {
  }
//+------------------------------------------------------------------+
