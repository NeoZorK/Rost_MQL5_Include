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

//CONSTANTS
const uint MAGIC_IB=3000000;
const uint MAGIC_IS=3100000;
const uchar OP_BUY=0;
const uchar OP_SELL=1;
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
   //Comission for AutoCloseDcSpread
   ushort            m_comission;
   //Latest Position:direction, profit, price (onClose)
   long              m_position_close_direction;
   double            m_position_close_profit;
   double            m_position_close_price;
   double            m_stoploss;
   double            m_takeprofit;

   ENUM_RT_OpenRule  m_current_open_rule;
   ENUM_RT_CloseRule m_current_close_rule;
   //Open TR 
   int               m_OpenRule(const ENUM_RT_OpenRule &OpenRule);
   int               m_POMI();
   //Close TR 
   int               m_CloseRule(const ENUM_RT_CloseRule &CloseRule);
   bool              m_AutoCloseDcSpread();
   //Position params
   uchar             m_sleeppage;

   //Position Counters
   ulong             m_buypos_count;
   ulong             m_sellpos_count;

public:
                     RCat(const string Pair,const double &Pom_Koef,const double &PomBuy,const double &PomSell,
                                            const ushort &Fee,const uchar &SleepPage);
                    ~RCat();
   //Initialisation     
   bool              Init(const char &Ck_Case,const ENUM_RT_OpenRule &OpenRule,const ENUM_RT_CloseRule &CloseRule);
   //Main          
   bool              Trade(const double &First,const double &Pom,const double &Dc,const double &Signal,
                           const double &Sl,const double &Tp);
   //Close Position
   bool              ClosePosition(const string CustomComment);
   bool              CloseAllPositions(const string CustomComment);
   //Open Position
   int               OpenMarketOrder(const double &Vol,const uchar &BuyOrSell,const double &Sl,const double &Tp,
                                     const uint &Magic,const string _Comment,const bool LimitOrder,const ushort LimitShift_Pt);

  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
RCat::RCat(const string Pair,const double &Pom_Koef,const double &PomBuy,const double &PomSell,
           const ushort &Fee,const uchar &SleepPage)
  {
   m_pair=Pair;
   m_pom_koef= Pom_Koef;
   m_pom_buy = PomBuy;
   m_pom_sell= PomSell;
   m_comission=Fee;
   m_sleeppage=SleepPage;
   m_buypos_count=0;
   m_sellpos_count=0;
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
bool RCat::Init(const char &Ck_Case,const ENUM_RT_OpenRule &OpenRule,const ENUM_RT_CloseRule &CloseRule)
  {
   if(Ck_Case>4 || Ck_Case<0)
     {
      return(false);
     }
   m_current_ck=Ck_Case;

   m_current_open_rule=OpenRule;
   m_current_close_rule=CloseRule;

   return(true);
  }
//+------------------------------------------------------------------+
//| Main Real Trade Function                                         |
//+------------------------------------------------------------------+
bool RCat::Trade(const double &First,const double &Pom,const double &Dc,const double &Signal,const double &Sl,const double &Tp)
  {
// Fill Latest Indicator Buffers
   m_first=First;
   m_pom= Pom;
   m_dc = Dc;
   m_signal=Signal;
   m_stoploss=Sl;
   m_takeprofit=Tp;

///---MAIN CALCULATION---///
   m_TR_RES=-1;

// OpenRule
   m_TR_RES=m_OpenRule(m_current_open_rule);

// CloseRule -> if close, exit
   if(m_CloseRule(m_current_close_rule)) return(true);

// Check if Futured EndOFT - is NOW

//Check Spread     

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

   switch(CloseRule)
     {
      case  0:TR_RES=m_AutoCloseDcSpread();

      break;
      default:
         break;
     }

   return(TR_RES);
  }
//+------------------------------------------------------------------+
//| Open TR #0 POMI                                                  |
//+------------------------------------------------------------------+
int RCat::m_POMI()
  {
   int res=-1;

   if(m_signal==0)
     {
      return(-2);
     }

   if(m_first==0)
     {
      return(-2);
     }

//---2:1 
//(case 4) or (case14)
   if(m_current_ck==CkSell4 || m_current_ck==CkBuySell14)
     {
      if((m_signal==SELL1) && (m_pom>=m_pom_sell) && (m_pom<m_pom_sell+m_pom_koef))
        {
         //  Print("SELL PRISHEL");
         return(SELL1);
        }
     }//END of BUY

//---1:2
// (case 1) or (case14)
   if(m_current_ck==CkBuy1 || m_current_ck==CkBuySell14)
     {
      if((m_signal==BUY1) && (m_pom>=m_pom_buy) && (m_pom<m_pom_buy+m_pom_koef))
        {
         return(BUY1);
        }
     }//END OF SELL

   return(res);
  }
//+------------------------------------------------------------------+
//| AutoClose by |DeltaC|+Spread+Commission                          |
//+------------------------------------------------------------------+
bool RCat::m_AutoCloseDcSpread(void)
  {
// CLose if NetProfit >= |dC|+spread+commision
   bool res=false;
   double dc=m_dc;

//If not opened position , exit
   if(!PositionSelect(m_pair)) {return(res);}

//Get position profit & volume
   double pos_profit,pos_volume=0;
   PositionGetDouble(POSITION_VOLUME,pos_volume);
   PositionGetDouble(POSITION_PROFIT,pos_profit);

//GetCurrent Spread
   int temp_spread=(int)SymbolInfoInteger(m_pair,SYMBOL_SPREAD);

//Check to close position   
   if(pos_profit>=MathAbs(dc*10)+(temp_spread*pos_volume)+(m_comission*pos_volume))
     {
      if(ClosePosition("Sprd"+IntegerToString(temp_spread)+" dC:"+DoubleToString(dc/inpDeltaC_koef)+
         " "+TimeToString(TimeCurrent(),TIME_SECONDS)+
         "|Closed by|dC|")) {res=true;}
     }

   return(res);
  }
//+------------------------------------------------------------------+
//|  CLOSE POSITION                                                  |
//+------------------------------------------------------------------+
bool RCat::ClosePosition(const string CustomComment)
  {
   bool res=false;

//Has open Position?
   if(!PositionSelect(m_pair)) {return(res);}

//Position Direction
   m_position_close_direction=PositionGetInteger(POSITION_TYPE);

//Save Current Position ClosePrice\Profit   
   m_position_close_price=PositionGetDouble(POSITION_PRICE_CURRENT);
   m_position_close_profit=PositionGetDouble(POSITION_PROFIT);

//Position Volume
   double pos_volume=PositionGetDouble(POSITION_VOLUME);

//If Buy Opened, Close It  
   if(m_position_close_direction==POSITION_TYPE_BUY)
     {
      OpenMarketOrder(pos_volume,OP_SELL,m_stoploss,m_takeprofit,MAGIC_IS,CustomComment,false,0);
      res=true;
     }//END OF Close BUY

//If Sell Opened, Close it   
   if(m_position_close_direction==POSITION_TYPE_SELL)
     {
      OpenMarketOrder(pos_volume,OP_BUY,m_stoploss,m_takeprofit,MAGIC_IB,CustomComment,false,0);
      res=true;
     }//END OF Close SELL

   return(res);
  }//END Of Close Position 
//+------------------------------------------------------------------+
//| Market Open Position                                             |
//+------------------------------------------------------------------+
int RCat::OpenMarketOrder(const double &Vol,const uchar &BuyOrSell,const double &Sl,const double &Tp,
                          const uint &Magic,const string _Comment,const bool LimitOrder,const ushort LimitShift_Pt)
  {
   double price=0;
   color cvet=clrBlack;
   double zsl=0,ztp=0;

//Not Buy or Not Sell -?, exit
   if(BuyOrSell>1)
     {
      Print(__FUNCTION__+" Signal has no right values...");
      return(-1);
     }

   MqlTick z_ts;
   SymbolInfoTick(m_pair,z_ts);

//Get Pair Point
   double point_size=SymbolInfoDouble(m_pair,SYMBOL_POINT);

//If Limit is to Close to price, then change to minimal value
   double shift=LimitShift_Pt;
   if(shift<5) shift=5;

//+------------------------------------------------------------------+
//| BUY                                                              |
//+------------------------------------------------------------------+
   if(BuyOrSell==OP_BUY)
     {
      cvet=clrAliceBlue;
      price=z_ts.ask;

      if(Sl!=0) { zsl=z_ts.ask-(Sl*point_size);}
      else {zsl=0;}

      if(Tp!=0) {ztp=z_ts.ask+(Tp*point_size);}
      else {ztp=0;}
     }
//+------------------------------------------------------------------+
//| SELL                                                             |
//+------------------------------------------------------------------+
   if(BuyOrSell==OP_SELL)
     {
      cvet=clrRed;
      price=z_ts.bid;

      if(Sl!=0) {zsl=z_ts.bid+(Sl*point_size);}
      else {zsl=0;}

      if(Tp!=0) {ztp=z_ts.bid-(Tp*point_size);}
      else {ztp=0;}
     }

//Prepare SendOrder Struct
   MqlTradeRequest z_mt_req={0};
   ZeroMemory(z_mt_req);
   MqlTradeResult  z_mt_rez={0};
   ZeroMemory(z_mt_rez);

//Limit Order Mode 
   if(LimitOrder)
     {
      z_mt_req.action=TRADE_ACTION_PENDING;
      z_mt_req.type_filling=ORDER_FILLING_FOK;
      z_mt_req.type_time=ORDER_TIME_GTC;//ORDER_TIME_SPECIFIED; worked
      z_mt_req.expiration=0;// TimeCurrent()+_LimitOrder_PlaceExpiration_Seconds;
                            //When price touch her, set order upper or lower 
      z_mt_req.price=0;//NormalizeDouble(price,5);
     }
   else z_mt_req.action=TRADE_ACTION_DEAL;  //Set to Market Order

   z_mt_req.symbol=m_pair;
   z_mt_req.magic=Magic;
   z_mt_req.volume=Vol;
   z_mt_req.sl=zsl;
   z_mt_req.tp=ztp;
   z_mt_req.comment=_Comment;
   z_mt_req.deviation=3;

//added 9.02.2015 (error 10015)
   z_mt_req.price=price;

//  Print("Current price: "+DoubleToString(price));

   if(BuyOrSell==OP_BUY)
     {
      //If limits sets needed type
      if(LimitOrder)
        {
         z_mt_req.type=ORDER_TYPE_BUY_STOP;
         z_mt_req.stoplimit=price-(shift*point_size);
         //     Print("BUY: "+z_mt_req.stoplimit);
        }
      //Market Order
      z_mt_req.type=ORDER_TYPE_BUY;
     }

   if(BuyOrSell==OP_SELL)
     {
      //If limits sets needed type
      if(LimitOrder)
        {
         z_mt_req.type=ORDER_TYPE_SELL_STOP;
         z_mt_req.stoplimit=price+(shift*point_size);
         //      Print("SELL: "+z_mt_req.stoplimit);
        }
      //Market Order 
      z_mt_req.type=ORDER_TYPE_SELL;
     }

// z_mt_req.type_filling=ORDER_FILLING_RETURN; //For market and limit orders  
// z_mt_req.type_time=ORDER_TIME_GTC;

   ResetLastError();

//Check Structures
   MqlTradeCheckResult z_mt_cr={0};
   ZeroMemory(z_mt_cr);
// Print("CheckOrder");
//+------------------------------------------------------------------+
//| Check Order                                                      |
//+------------------------------------------------------------------+
   if(!OrderCheck(z_mt_req,z_mt_cr) && z_mt_cr.retcode!=0)
     {
      Print(__FUNCTION__+" Verify send order failed with : "+z_mt_cr.comment+" Code="+IntegerToString(z_mt_cr.retcode));
      //     Print("check retcode="+z_mt_cr.retcode);

      //Id no money in HISTORY_TESTER_MODE, remove expert
      if((z_mt_cr.retcode==TRADE_RETCODE_NO_MONEY) && (MQLInfoInteger(MQL_TESTER)==true))
        {
         ExpertRemove();
        }
      return(-3);
     }
   int ret=0;
//  Print(z_mt_cr.comment);
//  Print("ok CheckOrder");
//+------------------------------------------------------------------+
//|  Send Order                                                      |
//+------------------------------------------------------------------+
   int res=OrderSend(z_mt_req,z_mt_rez);
   if(res)
     {
      ret=(int)z_mt_rez.retcode;
      //     Print("ordersend="+ret);

      //---If Order Completed , inc buys or sells
      if(ret==TRADE_RETCODE_DONE)
        {
         if(BuyOrSell==OP_BUY) m_buypos_count++;
         if(BuyOrSell==OP_SELL) m_sellpos_count++;
        }
     } // END of ORDER SENDED
   else
     {//If Order Error
      Print("res="+IntegerToString(res)+" ret:"+IntegerToString(ret)+" LastErr: "+IntegerToString(GetLastError())+z_mt_rez.comment);
      return(-1);
     }

   return(res);
  }//END OF OPEN MARKET ORDER
//+------------------------------------------------------------------+
//|  CLOSE ALL POSITIONS                                             |
//+------------------------------------------------------------------+
bool RCat::CloseAllPositions(const string CustomComment)
  {
   bool res=false;
   int pos_total=PositionsTotal();
//   Print("pos total"+IntegerToString(pos_total) );
   if(pos_total<1){return(false);}

   for(int i=0;i<pos_total;i++)
     {
      string pair=PositionGetSymbol(i);
      if(pair=="")
        {
         Print(__FUNCTION__+" Err: "+IntegerToString(GetLastError()));
         return(res=false);
        }

      //Position Direction
      long pos_type=PositionGetInteger(POSITION_TYPE);

      //Position Volume
      double pos_volume=PositionGetDouble(POSITION_VOLUME);

      //If Buy Opened, close it  
      if(pos_type==POSITION_TYPE_BUY)
        {
         OpenMarketOrder(pos_volume,OP_SELL,m_stoploss,m_takeprofit,MAGIC_IS,CustomComment,false,0);
         res=true;
        }//END OF CLOSE BUY

      //If Sell Opened, close it  
      if(pos_type==POSITION_TYPE_SELL)
        {
         OpenMarketOrder(pos_volume,OP_BUY,m_stoploss,m_takeprofit,MAGIC_IB,CustomComment,false,0);
         res=true;
        }//END OF CLOSE SELL
     }//END of FOR
   return(res);
  }//END OF CLOSE ALL POSITIONS  
//+------------------------------------------------------------------+
