//+------------------------------------------------------------------+
//|                                                         RCat.mqh |
//|                             Copyright 2016, Shcherbyna Rostyslav |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Shcherbyna Rostyslav"
#property link      ""
#property version   "1.00"

#include <Tools\DateTime.mqh>
#include <RInclude\RTrade.mqh>
//RealTime Open TR
enum ENUM_RT_OpenRule
  {
   POMI
  };
//RealTime Close TR
enum ENUM_RT_CloseRule
  {
   AutoCloseDcSpread
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*
2. Calculate Lot ?

6. Select Trading Rule  POMI

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
   string            m_pair;
   //Caterpillar Result
   int               m_TR_RES;
   //Current Ck Prediction
   char              m_current_ck;
   //---Latest Indicator Values
   double            m_first;
   double            m_pom;
   double            m_dc;
   double            m_signal;
   //Pom constants
   double            m_pom_koef;
   double            m_pom_buy;
   double            m_pom_sell;

   //Open TR 
   int               m_OpenRule(const ENUM_RT_OpenRule &OpenRule);
   int               m_POMI();
   //Close TR 
   int               m_CloseRule(const ENUM_RT_CloseRule &CloseRule);
   int               m_AutoCloseDcSpread();

public:
                     RCat(const string Pair,const double &Pom_Koef,const double &PomBuy,const double &PomSell);
                    ~RCat();
   //Initialisation     
   bool              Init(const char &Ck_Case);
   //Main          
   bool              Trade(const double &first,const double &pom,const double &dc,const double &signal);

  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
RCat::RCat(const string Pair,const double &Pom_Koef,const double &PomBuy,const double &PomSell)
  {
   m_pair=Pair;
   m_pom_koef= Pom_Koef;
   m_pom_buy = PomBuy;
   m_pom_sell= PomSell;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
RCat::~RCat()
  {
  }
//+------------------------------------------------------------------+
//| Initialisation                                                   |
//+------------------------------------------------------------------+
bool RCat::Init(const char &Ck_Case)
  {
    if(Ck_Case>4 || Ck_Case<0)
     {
      return(false);
     }
 m_current_ck=Ck_Case;
   return(true);
  }
//+------------------------------------------------------------------+
//| Main Real Trade Function                                         |
//+------------------------------------------------------------------+
bool RCat::Trade(const double &first,const double &pom,const double &dc,const double &signal)
  {
 
//Fill Latest Indicator Buffers
   m_first=first;
   m_pom= pom;
   m_dc = dc;
   m_signal=signal;

//If Ok    
  

///---MAIN CALCULATION---///
   m_TR_RES=-1;

//OpenRule

//If Ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Open Rule                                                        |
//+------------------------------------------------------------------+
int RCat::m_OpenRule(const ENUM_RT_OpenRule &OpenRule)
  {
   int TR_RES=-1;

   if(OpenRule<0)
     {
      return(-2);
     }

   switch(OpenRule)
     {
      case  0:TR_RES=m_POMI();

      break;
      default:
         break;
     }
   return(TR_RES);
  }
//+------------------------------------------------------------------+
//| Close Rule                                                       |
//+------------------------------------------------------------------+
int RCat::m_CloseRule(const ENUM_RT_CloseRule &CloseRule)
  {
   int TR_RES=-1;

   if(CloseRule<0)
     {
      return(-2);
     }

   return(TR_RES);
  }
//+------------------------------------------------------------------+
//| Open TR #0 POMI                                                  |
//+------------------------------------------------------------------+
int RCat::m_POMI()
  {

   return(0);
  }
//+------------------------------------------------------------------+
