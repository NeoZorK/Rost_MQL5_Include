//+------------------------------------------------------------------+
//|                                                         RCat.mqh |
//|                             Copyright 2016, Shcherbyna Rostyslav |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Shcherbyna Rostyslav"
#property link      ""
#property version   "1.41"

#include <Tools\DateTime.mqh>
#include <RInclude\RTrade.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*
+++++CHANGE LOG+++++
1.41 28.05.2016--Minor version with ability to Export OHLC to CSV & BIN
1.4 20.05.2016--Stable with AutoCompounding
1.3 19.05.2016--Stable, without Copy Arrays
1.2 15.05.2016--Version with Commented Addition code
1.1 6.05.2016 --Version with working RStructs (separate file)
--Ver 1.0 Stable
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
   //---Latest Feed Values
   double            m_Opens[];
   double            m_Highs[];
   double            m_Lows[];
   double            m_Closes[];
   long              m_TickVols[];
   double            m_first;
   double            m_pom;
   double            m_dc;
   double            m_signal;
   //Pom constants
   uint              m_bottle_size;
   double            m_pom_koef;
   double            m_pom_buy;
   double            m_pom_sell;
   ushort            m_max_spread;
   //Comission for AutoCloseDcSpread
   ushort            m_comission;
   //Latest Position:direction, profit, price (onClose)
   long              m_position_close_direction;
   double            m_position_close_profit;
   double            m_position_close_price;
   double            m_stoploss;
   double            m_takeprofit;
   double            m_start_volume;
   double            m_step_volume;
   double            m_max_volume;
   double            m_start_vol_koef;
   double            m_max_vol_koef;
   double            m_add_vol_shift_points;

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

   //Add Volume to opened position
   bool              m_AddVolume();

   //WhoFirst RealTime
   bool              m_WhoFirst();

   //Pom & Signal RealTime   
   bool              m_PomSignal();

   //DC RealTime
   bool              m_DC();

public:
                     RCat(const string Pair,const double &Pom_Koef,const double &PomBuy,const double &PomSell,
                                            const ushort &Fee,const uchar &SleepPage,const ushort &MaxSpread,const uint &BottleSize);
                    ~RCat();
   //Initialisation     
   bool              Init(const char &Ck_Case,const ENUM_RT_OpenRule &OpenRule,const ENUM_RT_CloseRule &CloseRule,
                          const double AddVol_Shift_Pt);
   //Main Trade on Ind Feed         
   bool              TradeInd(const double &First,const double &Pom,const double &Dc,const double &Signal,
                              const double &Sl,const double &Tp,const double &StartVol,const double &MaxVol,
                              const ENUM_AutoLot &AutoLot);
   //Trade on Calculated Feed (WO Indicator)
   bool              Trade(const double &Sl,const double &Tp,const double &StartVol,const double &MaxVol,
                           const ENUM_AutoLot &AutoLot);

   //Close Position
   bool              ClosePosition(const string CustomComment);
   bool              CloseAllPositions(const string CustomComment);
   //Open Position
   int               OpenMarketOrder(const double &Vol,const uchar &BuyOrSell,const double &Sl,const double &Tp,
                                     const uint &Magic,const string _Comment,const bool LimitOrder,const ushort LimitShift_Pt);
   //Compounding (AutoLot)
   bool              AutoCompounding(const ENUM_AutoLot &Enum_AutoLot);

   //Calculate RT Feed (WF,Pom,Signal,DC)
   bool              CalculateRTFeed();

  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
RCat::RCat(const string Pair,const double &Pom_Koef,const double &PomBuy,const double &PomSell,
           const ushort &Fee,const uchar &SleepPage,const ushort &MaxSpread,const uint &BottleSize)
  {
   m_pair=Pair;
   m_pom_koef= Pom_Koef;
   m_pom_buy = PomBuy;
   m_pom_sell= PomSell;
   m_comission=Fee;
   m_sleeppage=SleepPage;
   m_buypos_count=0;
   m_sellpos_count=0;
   m_max_spread=MaxSpread;
   m_start_vol_koef=0;
   m_max_vol_koef=0;
   m_bottle_size=BottleSize;
   ArraySetAsSeries(m_Opens,true);
   ArraySetAsSeries(m_Highs,true);
   ArraySetAsSeries(m_Lows,true);
   ArraySetAsSeries(m_Closes,true);
   ArraySetAsSeries(m_TickVols,true);
   ArrayResize(m_Opens,m_bottle_size);
   ArrayResize(m_Highs,m_bottle_size);
   ArrayResize(m_Lows,m_bottle_size);
   ArrayResize(m_Closes,m_bottle_size);
   ArrayResize(m_TickVols,m_bottle_size);
  }//END OF Constructor
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
RCat::~RCat()
  {
  }//END OF Destructor
//+------------------------------------------------------------------+
//| Initialisation                                                   |
//+------------------------------------------------------------------+
bool RCat::Init(const char &Ck_Case,const ENUM_RT_OpenRule &OpenRule,
                const ENUM_RT_CloseRule &CloseRule,const double AddVol_Shift_Pt)
  {
   if(Ck_Case>4 || Ck_Case<0)
     {
      return(false);
     }
   m_current_ck=Ck_Case;
   m_current_open_rule=OpenRule;
   m_current_close_rule=CloseRule;
   m_add_vol_shift_points=AddVol_Shift_Pt;
   return(true);
  }//END OF Init
//+------------------------------------------------------------------+
//| Main Ind Real Trade Function:True if Open\Close Position         |
//+------------------------------------------------------------------+
bool RCat::TradeInd(const double &First,const double &Pom,const double &Dc,const double &Signal,
                    const double &Sl,const double &Tp,const double &StartVol,const double &MaxVol,
                    const ENUM_AutoLot &AutoLot)
  {
// Fill Latest Indicator Buffers
   m_first=First;
   m_pom= Pom;
   m_dc = Dc;
   m_signal=Signal;
   m_stoploss=Sl;
   m_takeprofit=Tp;
   m_start_volume=StartVol;
   m_max_volume=MaxVol;
//Compounding   
//Check if enabled
   if(AutoLot!=Disabled)
     {
      bool compound_result=AutoCompounding(AutoLot);
      //if true - lots changed, false - not changed
     }//End of Compounding

///---MAIN CALCULATION---///
   m_TR_RES=-1;

// OpenRule
   m_TR_RES=m_OpenRule(m_current_open_rule);

// CloseRule -> if close, exit
   if(m_CloseRule(m_current_close_rule)) return(true);

// Check Spread
   if(m_max_spread <(int)SymbolInfoInteger(m_pair,SYMBOL_SPREAD)) return(false);

// NoSignal, Err -> Exit
   if(m_TR_RES <0) return(false);

//QuantMode here?

//  If any Open Position?
   bool Opened_Position=PositionSelect(m_pair);
//-----NEW POSITION-----//
   if(!Opened_Position)
     {
      switch(m_TR_RES)
        {
         //BUY
         case  1005: OpenMarketOrder(m_start_volume,OP_BUY,m_stoploss,m_takeprofit,MAGIC_IB,
                                     DoubleToString(m_pom,2)+"|"+DoubleToString(m_dc,5)+"|"+
                                     TimeToString(TimeCurrent(),TIME_SECONDS),false,0);
            return(true); break;

            //SELL
         case  2006: OpenMarketOrder(m_start_volume,OP_SELL,m_stoploss,m_takeprofit,MAGIC_IS,
                                     DoubleToString(m_pom,2)+"|"+DoubleToString(m_dc,5)+"|"+
                                     TimeToString(TimeCurrent(),TIME_SECONDS),false,0);
            return(true); break;

         default:
            break;
        }//END OF SWITCH
     }//END OF NEW POSITION
//-----ADD VOLUME-----//    
   if(Opened_Position)
     {
      if(!m_AddVolume()) return(false);
     }//END OF ADD VOLUME

//If No Opened Position then false
   return(false);
  }//+++++++END OF IND TRADE!
//+------------------------------------------------------------------+
//| Open Rule                                                        |
//+------------------------------------------------------------------+
int RCat::m_OpenRule(const ENUM_RT_OpenRule &OpenRule)
  {
   int TR_RES=-1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(OpenRule<0)
     {
      return(-2);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   switch(OpenRule)
     {
      case  0:TR_RES=m_POMI();

      break;
      default:
         break;
     }
   return(TR_RES);
  }//END OF OPEN RULE
//+------------------------------------------------------------------+
//| Close Rule                                                       |
//+------------------------------------------------------------------+
int RCat::m_CloseRule(const ENUM_RT_CloseRule &CloseRule)
  {
   int TR_RES=-1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(CloseRule<0)
     {
      return(-2);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   switch(CloseRule)
     {
      case  0:TR_RES=m_AutoCloseDcSpread();

      break;
      default:
         break;
     }

   return(TR_RES);
  }//END OF CLOSE RULE
//+------------------------------------------------------------------+
//| Open TR #0 POMI                                                  |
//+------------------------------------------------------------------+
int RCat::m_POMI()
  {
   int res=-1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(m_signal==0)
     {
      return(-2);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(m_first==0)
     {
      return(-2);
     }
//---2:1 
//(case 4) or (case14)
   if(m_current_ck==CkSell4 || m_current_ck==CkBuySell14)
     {
      if((m_signal==Ind_Sell) && (m_pom>=m_pom_sell) && (m_pom<m_pom_sell+m_pom_koef))
        {
         //  Print("SELL PRISHEL");
         return(SELL1);
        }
     }//END of BUY
//---1:2
// (case 1) or (case14)
   if(m_current_ck==CkBuy1 || m_current_ck==CkBuySell14)
     {
      if((m_signal==Ind_Buy) && (m_pom>=m_pom_buy) && (m_pom<m_pom_buy+m_pom_koef))
        {
         return(BUY1);
        }
     }//END OF SELL

   return(res);
  }//END OF POMI
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
      if(ClosePosition("Sprd"+IntegerToString(temp_spread)+"dC"+DoubleToString(dc/inpDeltaC_koef,5)+
         " "+TimeToString(TimeCurrent(),TIME_SECONDS))) {res=true;}
     }

   return(res);
  }//END OF AutoCloseDCSpread
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
     }//END OF SELL

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
     }//END OF LIMIT ORDER
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
     }//END OF BUY
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
     }//END OF BUY

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
      //If wrong volume, show it
      if((z_mt_cr.retcode==TRADE_RETCODE_INVALID_VOLUME) && (MQLInfoInteger(MQL_TESTER)==true))
        {
         Print("Open Position Volume: "+DoubleToString(z_mt_req.volume));
         ExpertRemove();
        }

      //If no money in HISTORY_TESTER_MODE, remove expert
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
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
//| AutoCompounding                                                  |
//+------------------------------------------------------------------+
bool RCat::AutoCompounding(const ENUM_AutoLot &Enum_AutoLot)
  {
//Get Current Balance
   double balance=AccountInfoDouble(ACCOUNT_BALANCE);

//Get Maximum Availables Volume on broker
   double max_broker_vol=SymbolInfoDouble(m_pair,SYMBOL_VOLUME_MAX);
//Check if first run : Calculate fixed lot koef
   if(m_start_vol_koef==0 || m_max_vol_koef==0)
     {
      //Calculate first start volume koeficient
      m_start_vol_koef=NormalizeDouble(balance/m_start_volume,2);

      //Calculate first max volume koeficient
      m_max_vol_koef=NormalizeDouble(balance/m_max_volume,2);
     }//End of first run

//Save Start\Max Volume
   double   saved_start_vol=m_start_volume;
   double   saved_max_vol=m_max_volume;

//Calculate lot
   double current_start_vol_koef=0;
   double current_max_vol_koef=0;
//Select Calculation mode Dynamic or MaximalOnly
   switch(Enum_AutoLot)
     {
      case  Dynamic:
         //Calculate Current Start volume koeficient
         current_start_vol_koef=NormalizeDouble(balance/m_start_volume,2);

         //Calculate Current Max volume koeficient
         current_max_vol_koef=NormalizeDouble(balance/m_max_volume,2);

         //Check if balance changed
         if(current_start_vol_koef!=m_start_vol_koef)
           {
            //if changed set current lot to new
            m_start_volume=NormalizeDouble(balance/m_start_vol_koef,2);
            m_max_volume=NormalizeDouble(balance/m_max_vol_koef,2);

            //Compare Maximum broker volume with our calculated
            if(m_start_volume>max_broker_vol || m_max_volume>max_broker_vol)
              {
               //return to saved volume
               m_start_volume=saved_start_vol;
               m_max_volume=saved_max_vol;
               return(false);
              }//End of compare

            return(true);
           }
         break;

      case  MaximalOnly:
         //Calculate Current Start volume koeficient
         current_start_vol_koef=NormalizeDouble(balance/m_start_volume,2);

         //Calculate Current Max volume koeficient
         current_max_vol_koef=NormalizeDouble(balance/m_max_volume,2);

         //Check if balance > previous
         if(current_start_vol_koef>m_start_vol_koef)
           {
            //if changed set current lot to new
            m_start_volume=NormalizeDouble(balance/m_start_vol_koef,2);
            m_max_volume=NormalizeDouble(balance/m_max_vol_koef,2);

            //Compare Maximum broker volume with our calculated
            if(m_start_volume>max_broker_vol || m_max_volume>max_broker_vol)
              {
               //return to saved volume
               m_start_volume=saved_start_vol;
               m_max_volume=saved_max_vol;
               return(false);
              }//End of compare
            return(true);
           }
         break;

      case Disabled:return(false); break;

      default:
         break;
     }//End of switch

//If Not Change 
   return(false);
  }//End of AutoCompounding
//+------------------------------------------------------------------+
//| Add Volume to opened position                                    |
//+------------------------------------------------------------------+
bool RCat::m_AddVolume(void)
  {
//Position Volume
   double pos_volume=PositionGetDouble(POSITION_VOLUME);

//Check MaxVolume
   if(pos_volume>=m_max_volume) {return(false);}

//Position Open Price
   double pos_open_price=PositionGetDouble(POSITION_PRICE_OPEN);

//Current Price(Bid for BuyClose & Ask for SellClose)
   double pos_current_price=PositionGetDouble(POSITION_PRICE_CURRENT);

//Position Direction
   long pos_type=PositionGetInteger(POSITION_TYPE);

//Pair point
   double point_size=SymbolInfoDouble(m_pair,SYMBOL_POINT);
//Add Volume BUY
   if(pos_type==POSITION_TYPE_BUY && m_TR_RES==BUY1)
     {
      //If Price lower->Add Vol Buy, else Exit
      if(pos_current_price>pos_open_price-(m_add_vol_shift_points*point_size)) return(false);

      //Add BUY
      OpenMarketOrder(m_start_volume,OP_BUY,m_stoploss,m_takeprofit,MAGIC_IB,"+V"+
                      DoubleToString(m_pom,2)+"|"+DoubleToString(m_dc,5)+"|"+
                      TimeToString(TimeCurrent(),TIME_SECONDS),false,0);
      return(true);
     }//END OF ADD VOL BUY
//Add Volume SELL
   if((pos_type==POSITION_TYPE_SELL) && (m_TR_RES==SELL1))
     {
      //If Price Higher->Add Vol Sell, else Exit
      if(pos_current_price<pos_open_price+(m_add_vol_shift_points*point_size)) return(false);

      //Add SELL
      OpenMarketOrder(m_start_volume,OP_SELL,m_stoploss,m_takeprofit,MAGIC_IS,"+V"+
                      DoubleToString(m_pom,2)+"|"+DoubleToString(m_dc,5)+"|"+
                      TimeToString(TimeCurrent(),TIME_SECONDS),false,0);
      return(true);
     }//END OF ADD VOL SELL
//If no pos,
   return(false);
  }//END of AddVolume
//+------------------------------------------------------------------+
//| Calculate WF,Pom,Signal,DC for real time trading                 |
//+------------------------------------------------------------------+
bool RCat::CalculateRTFeed(void)
  {
//Calculate WhoFirst
   if(!m_WhoFirst())
     {
      return(false);
     }

//Calculate POM & Signal
   if(!m_PomSignal())
     {
      return(false);
     }

//Calculate DC
   if(!m_DC())
     {
      return(false);
     }

//If ok
   return(true);
  }//END OF RT Feed
//+------------------------------------------------------------------+
//| Trade WO Ind                                                     |
//+------------------------------------------------------------------+
bool RCat::Trade(const double &Sl,const double &Tp,const double &StartVol,const double &MaxVol,const ENUM_AutoLot &AutoLot)
  {

//If Ok
   return(true);
  }//END of Trade WO Indicator
//+------------------------------------------------------------------+
//| Who will be first High or low ? 0,1,2 |No,Low,High               |
//+------------------------------------------------------------------+
bool RCat::m_WhoFirst(void)
  {
//Get Last Highs
   if(CopyHigh(m_pair,0,0,m_bottle_size,m_Highs)<=0) {m_first=EqualFirst; return(false);}

//Get Last Lows
   if(CopyLow(m_pair,0,0,m_bottle_size,m_Lows)<=0) {m_first=EqualFirst; return(false);}

//If two maximum then get maximum near now()
   uint index_L=ArrayMinimum(m_Lows,0,m_bottle_size);
   uint index_H=ArrayMaximum(m_Highs,0,m_bottle_size);

//Private case H==L
//Private case, when many H or L, and don`t know who >
   if(index_H>index_L) { m_first = HighFirst; return(true);}
   if(index_H<index_L) { m_first =  LowFirst;  return(true);}
   if(index_H==index_L){ m_first= EqualFirst;  return(true);}

   return(true);
  }//End of Who First
//+------------------------------------------------------------------+
//|Calculate POM                                                     |
//+------------------------------------------------------------------+
bool RCat::m_PomSignal(void)
  {
//Get Last Opens
   if(CopyOpen(m_pair,0,0,m_bottle_size,m_Opens)<=0)
     {
      m_pom=0;
      m_signal=NOSIGNAL;
      return(false);
     }

//Get Last Highs
   if(CopyHigh(m_pair,0,0,m_bottle_size,m_Highs)<=0)
     {
      m_pom=0;
      m_signal=NOSIGNAL;
      return(false);
     }

//Get Last Lows
   if(CopyLow(m_pair,0,0,m_bottle_size,m_Lows)<=0)
     {
      m_pom=0;
      m_signal=NOSIGNAL;
      return(false);
     }

//Get Last Closes
   if(CopyClose(m_pair,0,0,m_bottle_size,m_Closes)<=0)
     {
      m_pom=0;
      m_signal=NOSIGNAL;
      return(false);
     }

   double a=0;
   double b=0;
   double c=0;
   uchar m=0;
   uchar n=0;

//Private cases:
   if(m_first<LowFirst || m_first>HighFirst || m_first==EqualFirst)
     {
      m_pom=0;
      m_signal=NOSIGNAL;
      return(false);
     }

//Calc abc for HIGH first
   if(m_first==HighFirst)
     {
      a=m_Highs[0]-m_Opens[0];// +
      b=m_Lows[0]-m_Highs[0]; // -
      c=m_Closes[0]-m_Lows[0];// +
     }
   else//Calc abc for LOW first         
   if(m_first==LowFirst)
     {
      a=m_Lows[0]-m_Opens[0];// -
      b=m_Highs[0]-m_Lows[0];// +
      c=m_Closes[0]-m_Highs[0];// -
     }

// Jumps +/-
   if(a>0) m++; else if(a<0) n++;
   if(b>0) m++; else if(b<0) n++;
   if(c>0) m++; else if(c<0) n++;

//3 Limitations:
//1
   if(m*n<1 || m*n>2)
     {
      m_pom=0;
      m_signal=NOSIGNAL;
      return(false);
     }
//2     
   if(m*n==1 && m_Highs[0]==m_Closes[0])
     {
      m_pom=0;
      m_signal=NOSIGNAL;
      return(false);
     }
//3     
   if((m*n==2) && (m_Highs[0]-m_Closes[0]+m_Opens[0]-m_Lows[0]==0))
     {
      m_pom=0;
      m_signal=NOSIGNAL;
      return(false);
     }

//If no signal occured
   m_signal=NOSIGNAL;

//--- POM ver: 10.02.2015 
//2:1
   if(m==2 && n==1)
     {
      //IF A+ >1 then UP Trend  
      double ga=((a+c)/2)/MathAbs(b);

      //(case 4)  
      if(MathAbs(b)>((a+c)/2))
        {
         m_signal=SELL1;
         m_pom=1-(1/(1+ga));
         return(true);
        }
      else
        {
         m_pom=1-(1/(1+ga));
         return(true);
        }
     }//end of 2:1

//1:2  
   if(m==1 && n==2)
     {
      //IF A- <1 then DOWN Trend
      double ga=b/(MathAbs(a+c)/2);

      //(case 1)  
      if(b>(MathAbs(a+c)/2))
        {
         m_signal=BUY1;
         m_pom=1-(1/(1+ga));
         return(true);
        }
      else
        {
         m_pom=1-(1/(1+ga));
         return(true);
        }
     }//end of 1:2

//If no POM, private case or unknown error
   m_pom=0;
   m_signal=NOSIGNAL;
   return(false);
  }//END OF CALC POM
//+------------------------------------------------------------------+
//| Calculate DeltaC                                                 |
//+------------------------------------------------------------------+
bool RCat::m_DC(void)
  {
//Get Last Highs
   if(CopyHigh(m_pair,0,0,m_bottle_size,m_Highs)<=0)
     {
      m_dc=0;
      return(false);
     }

//Get Last Lows
   if(CopyLow(m_pair,0,0,m_bottle_size,m_Lows)<=0)
     {
      m_dc=0;
      return(false);
     }

//Get Last Closes
   if(CopyClose(m_pair,0,0,m_bottle_size,m_Closes)<=0)
     {
      m_dc=0;
      return(false);
     }

//Get Last Tick Volumes     
   if(CopyTickVolume(m_pair,0,0,m_bottle_size,m_TickVols)<=0)
     {
      m_dc=0;
      return(false);
     }

   double t2=(m_TickVols[2]-m_TickVols[1])*(m_Highs[2]-m_Lows[2]);

//div 0 exception
   if(t2==0)
     {
      m_dc=0;
      return(true);
     }

   double t4=(m_Closes[1]-m_Closes[2])/t2;

   m_dc=NormalizeDouble((m_TickVols[1]-m_TickVols[0])*t4*(m_Highs[0]-m_Lows[0]),5);

   return(true);
  }//END OF CALC_DC
