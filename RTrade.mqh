//+------------------------------------------------------------------+
//|                                                       RTrade.mqh |
//|                              Copyright 2016,Shcherbyna Rostyslav |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Shcherbyna Rostyslav"
#property link      ""
#property version   "1.41"

#include <Tools\DateTime.mqh>
#include <RInclude\RStructs.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*
+++++CHANGE LOG+++++
1.6  20.06.2016--Add Custom Feed WO Indicator to Emulation and Trading
1.5  30.05.2016--Clear Old Code , better perfomance (33 sec from 2010 to 2016.04 Daily)
1.41 28.05.2016--Minor version with ability to Export OHLC to CSV & BIN
1.4 20.05.2016--Stable with AutoCompounding
1.3 19.05.2016--Stable, without Copy Arrays
1.2 15.05.2016--Version with Commented Addition code
1.1 6.05.2016 --Version with working RStructs (separate file)
--Ver 1.0 Stable

Netting position:
	AddVolume:
((p1*v1)+(p2*v2)) / (v1+v2)

*/
//+------------------------------------------------------------------+
//|Class for Capture Q,NP, Virtual Trading, Caterpillar, Ck          |
//+------------------------------------------------------------------+
class RTrade
  {

private:
   string            m_pair;
   double            m_pair_point;
   //Emulation
   // Each 2 primings = +1  
   uint              m_simulated_primings_total;
   //Ck Predictions
   char              m_arr_ck_predictions[];
   //Array of Simulated Q  
   SIMUL_Q           m_arr_sim_q[];

   bool              m_initialised_emul;
   ENUM_EMUL_CloseRule m_close_rule_num_emul;
   ENUM_EMUL_OpenRule m_open_rule_num_emul;
   uint              m_max_spread_emul;
   double            m_pom_buy_emul;
   double            m_pom_sell_emul;
   double            m_pom_koef_emul;
   uint              m_bottle_size_emul;
   uint              m_one_bottle_size_emul;
   uint              m_all_bottle_size_emul;
   double            m_comission_emul;

   //Other   
   bool              m_debug;
   ENUM_TradeResults m_Result;
   //Current Priming1=true or Priming2=false
   bool              m_CurrentPriming;
   //Elements count in each array (rates,spreads,buffers)
   uint              m_Total_Minutes_in_period;
   //---Emulate Primings

   STRUCT_Priming    m_P1;
   STRUCT_Priming    m_P2;

   //Methods
   //TR Close Positions
   bool              m_EMUL_AutoCloseDCSpread(const double PositionProfit,const double Dc,const uint Spread,
                                              const double Commission);

   double            m_EMUL_CalculateDc(const uint Iteration,const STRUCT_Priming &Priming);
   //TR Open Positions(-1,-2=none,-1=sell,+1=buy)
   int               m_EMUL_TR_Caterpillar(const char Case,const int IterationNum,const STRUCT_Priming &Priming,
                                           const int OHLC);
   //TR Caterpillar WO Indicator for OHLC
   int               m_EMUL_TR_Caterpillar_OHLC_Feed(const char Case,const int IterationNum,const STRUCT_FEED_OHLC &FeedOHLC[],
                                                     const int OHLC);
   //TR Caterpillar WO Indicator Close Only
   int               m_EMUL_TR_Caterpillar_CLOSE_Feed(const char Case,const int IterationNum,const STRUCT_FEED_CLOSE &FeedCLOSE[]);

   bool              m_EMUL_CloseRule(const ENUM_EMUL_CloseRule CloseRuleNum,const double CurrentProfit,const double CurrentDC,
                                      const uint CurrentSpread);
   int               m_EMUL_OpenRule(const ENUM_EMUL_OpenRule OpenRuleNum,const char Case,const int IterationNum,
                                     const int OHLC,const STRUCT_Priming &Priming);
   //Open Rule WO Indicator for OHLC                                 
   int               m_EMUL_OpenRule_OHLC_Feed(const ENUM_EMUL_OpenRule OpenRuleNum,const char Case,const int IterationNum,
                                               const int OHLC,const STRUCT_FEED_OHLC &FeedOHLC[]);
   //Open Rule WO Indicator for CLOSE only                                 
   int               m_EMUL_OpenRule_CLOSE_Feed(const ENUM_EMUL_OpenRule OpenRuleNum,const char Case,const int IterationNum,
                                                const int OHLC,const STRUCT_FEED_CLOSE &FeedClose[]);
   //Calculate Ck Prediction 0,1,2 : 1,4,14
   char              m_BUILD_CK_TR18_0330_Virt(const bool USDFirst);
   //Check for Close Position (:true->continue)
   bool              m_CheckClose(const double Price,bool &BUY_OPENED,bool &SELL_OPENED,double &PositionProfit,
                                  double &BUY_OPENED_PRICE,double &SELL_OPENED_PRICE,const double Dc,const int Spread);
   //Check for Open Position (:true->continue)
   bool              m_CheckOpen(const double Price,const int OTR_RESULT,bool &BUY_OPENED,bool &SELL_OPENED,
                                 double &BUY_OPENED_PRICE,double &SELL_OPENED_PRICE,int &BUY_Signal_Count,
                                 int &SELL_Signal_Count);
public:
                     RTrade();
                    ~RTrade();
   //Is Emulation Initialised ?
   bool              _isInitialised() const       {return(m_initialised_emul);}

   //Emulation Init                   
   bool              _Init(const string pair,const string path_to_ind,const uchar bottlesize,
                           const datetime from_date,const datetime to_date,const bool debug);

   bool              CheckSpread(const uint MaxSpread,const uint CurrentSpread);
   //For Compounding
   double            CalcLot();

   //Emulate                         
   bool              _InitEmul(const ENUM_EMUL_CloseRule CloseRuleNum,const ENUM_EMUL_OpenRule OpenRuleNum,const int MaxSpread,
                               const double PomBuy,const double PomSell,const double PomKoef,const double Comission);

   //Choose Quant Mode for Emulation
   bool              ChooseEmul_QuantMode(const ENUM_EMUL_OHLC_PRICE &QuantMode);

   //4 Quant Mods for Emulation
   bool              Emulate_Trading_AllClose(const bool Priming1,const STRUCT_Priming &CurP);
   bool              Emulate_Trading_AllOHLC(const bool Priming1,const STRUCT_Priming &CurP);
   bool              Emulate_Trading_AllOHLC_WO_Indicator(const bool Priming1,const MqlRates &Rates[],
                                                          const STRUCT_FEED_OHLC &Feed[],const STRUCT_TICKVOL_OHLC &TickVol[]);
   bool              Emulate_Trading_ALLClose_WO_Indicator(const bool Priming1,const MqlRates &Rates[],
                                                           const STRUCT_FEED_CLOSE &Feed[]);

   //Get Selected Results after Emulation
   bool              EmulationResult_Selected(const uint EmulNumber,SIMUL_Q &SimulStruct);
   //Get Latest Results after Emulation
   bool              EmulationResult_Latest(SIMUL_Q &SimulStruct);
   //Choose TR for Ck
   char              TR_PredictCk(const ENUM_TRCK TRCk_Name,const bool USDFirst);
   //Converts Ck Prediction to string
   string            CkResultToString(const char Ck);
   //Get Ck Predictions by Index
   char              CkPredictionByIndex(const uint CkIndex);
  };
//+------------------------------------------------------------------+
//| Init                                                             |
//+------------------------------------------------------------------+
RTrade::RTrade()
  {
   MassiveSetAsSeries(m_P1);
   MassiveSetAsSeries(m_P2);

   m_Total_Minutes_in_period=0;
   m_CurrentPriming=0;
   m_debug=false;

//Each 2 simulated primings = 2
   m_simulated_primings_total=0;

//Add +1 Cell to Dynamic Array of Primings Omega
   ArrayResize(m_arr_sim_q,ArraySize(m_arr_sim_q)+1);
  }//END OF CONSTRUCTOR
//+------------------------------------------------------------------+
//| Deinit                                                           |
//+------------------------------------------------------------------+
RTrade::~RTrade()
  {
  }
//+------------------------------------------------------------------+
//|Custom Init                                                       |
//+------------------------------------------------------------------+
bool RTrade::_Init(const string pair,const string path_to_ind,const uchar bottlesize,
                   const datetime from_date,const datetime to_date,const bool debug)
  {
   m_pair=pair;

//Gey Pair Point value
   if(!SymbolInfoDouble(pair,SYMBOL_POINT,m_pair_point))
     {
      m_Result=-4;
      return(false);
     }

   m_debug=debug;
   m_bottle_size_emul=bottlesize;
   m_one_bottle_size_emul = m_bottle_size_emul*4;
   m_all_bottle_size_emul = m_one_bottle_size_emul*3;

//if ok 
   return(true);
  }//End of Init
//+------------------------------------------------------------------+
//| Check Maximum Spread                                             |
//+------------------------------------------------------------------+
bool  RTrade::CheckSpread(const uint MaxSpread,const uint CurrentSpread)
  {
   if(MaxSpread>CurrentSpread)
     {
      return(false);
     }
   else
     {
      return(true);
     }
  }//END OF Check Maximum Spread
//+------------------------------------------------------------------+
//| Emulated AutoClose Dc+Spread+Commisstion                         |
//+------------------------------------------------------------------+
bool  RTrade::m_EMUL_AutoCloseDCSpread(const double PositionProfit,const double Dc,const uint Spread,
                                       const double Commission)
  {// CLose if NetProfit >= |dC|+spread+commision
   bool res=false;

//Check for close
   if(PositionProfit>=MathAbs(Dc*10)+Spread+Commission)
     {
      //Close Position
      return(true);
     }

   return(res);
  }//END OF Emulated AutoClose 
//+------------------------------------------------------------------+
//| Emulated Choosing Close Rule                                     |
//+------------------------------------------------------------------+
bool  RTrade::m_EMUL_CloseRule(const ENUM_EMUL_CloseRule CloseRuleNum,const double CurrentProfit,
                               const double CurrentDC,const uint CurrentSpread)
  {
//TR_RESULT  
   bool TR_RES=-1;

   if(CloseRuleNum<0)
     {
      return(-2);
     }

   switch(CloseRuleNum)
     {
      case  0:TR_RES=m_EMUL_AutoCloseDCSpread(CurrentProfit,CurrentDC,CurrentSpread,m_comission_emul);

      break;
      default:
         break;
     }
//If Ok
   return(TR_RES);
  }//END OF Emulated Choosing Close Rule 
//+------------------------------------------------------------------+
//| Emulation Initialisation                                         |
//+------------------------------------------------------------------+
bool RTrade::_InitEmul(const ENUM_EMUL_CloseRule CloseRuleNum,const ENUM_EMUL_OpenRule OpenRuleNum,const int MaxSpread,
                       const double PomBuy,const double PomSell,const double PomKoef,const double Comission)
  {
   m_close_rule_num_emul=CloseRuleNum;
   m_open_rule_num_emul=OpenRuleNum;
   m_max_spread_emul=MaxSpread;
   m_pom_buy_emul=PomBuy;
   m_pom_sell_emul=PomSell;
   m_pom_koef_emul=PomKoef;
   m_comission_emul=Comission;

//Init Ok   
   m_initialised_emul=true;

//If Ok
   return(true);
  }//END OF Emulation Initialisation   
//+------------------------------------------------------------------+
//| Emulation Result after Emulation 2 primings (selected)           |
//+------------------------------------------------------------------+
bool RTrade::EmulationResult_Selected(const uint EmulNumber,SIMUL_Q &SimulStruct)
  {
//Get right size of arr
   uint ArrSize=ArraySize(m_arr_sim_q)-2;

//Check if Current I- is available (1 had added on the end of last priming2)
   if(EmulNumber > ArrSize ) return(false);

//If ok
   SimulStruct=m_arr_sim_q[EmulNumber];

//If Ok
   return(true);
  }//END OF SELECTED EMULATION RESULTS
//+------------------------------------------------------------------+
//| Emulation Result after Emulation 2 primings (latest)             |
//+------------------------------------------------------------------+
bool RTrade::EmulationResult_Latest(SIMUL_Q &SimulStruct)
  {
//Get right size of arr
   uint ArrSize=ArraySize(m_arr_sim_q)-2;

//If ok
   SimulStruct=m_arr_sim_q[ArrSize];

//If Ok
   return(true);
  }//END OF LATEST EMULATION RESULTS  
//+------------------------------------------------------------------+
//| Choose TR for Ck                                                 |
//+------------------------------------------------------------------+
char RTrade::TR_PredictCk(const ENUM_TRCK TRCk_Name,const bool USDFirst)
  {
//TR_RESULT  
   char TR_RES=-3;

//Add +1 Cell to Dynamic Array of Ck Prediction
   ArrayResize(m_arr_ck_predictions,ArraySize(m_arr_ck_predictions)+1);

//Set Default Prediction  = none
   m_arr_ck_predictions[ArraySize(m_arr_ck_predictions)-1]=TR_RES;

//Check for Correct TR for Ck
   if(TRCk_Name<0)
     {
      TR_RES=-2;
      m_arr_ck_predictions[ArraySize(m_arr_ck_predictions)-1]=TR_RES;
      return(TR_RES);
     }

   switch(TRCk_Name)
     {//False - EURUSD
      case  CK_TR18_0330_Virt:
        {
         //Get Ck Prediction
         TR_RES=m_BUILD_CK_TR18_0330_Virt(USDFirst);

         //Save to arr prediction
         m_arr_ck_predictions[ArraySize(m_arr_ck_predictions)-1]=TR_RES;
         break;
        } //END OF CK_TR18_0330_Virt

      default:
         break;
     }
//If Ok
   return(TR_RES);
  }//End of Choose TR for Ck
//+------------------------------------------------------------------+
//| TR18_0330_Virt (Ck) 0,1,2,3,4:1,4,14,SingulBuy,SingulSell        |
//+------------------------------------------------------------------+
char RTrade::m_BUILD_CK_TR18_0330_Virt(const bool USDFirst)
  {
//IF USDCHF , err  
   if(USDFirst) return(-2);

//Exceptions Limits:  
   const uchar Ex1_limit = 3;
   const uchar Ex2_limit = 3;
   const uchar Ex3_limit = 3;
   const uchar Ex4_limit = 4;

//For * Exceptions   
   const char Yes= -1;
   const char No = 1;

//Exceptions:
   char Ex1=No;
   char Ex2=No;
   char Ex3=No;
   char Ex4=No;

//0.Save simple value  
   SIMUL_Q Omega=m_arr_sim_q[m_simulated_primings_total-1];

//1.Calculate DeltaOmega
   int dO1 = Omega.P2_Q1_Simul - Omega.P1_Q1_Simul;
   int dO4 = Omega.P2_Q4_Simul - Omega.P1_Q4_Simul;
   int dO14= Omega.P2_Q14_Simul-Omega.P1_Q14_Simul;

//Exception Equal dO1==dO4 --> C14
   if(dO1==dO4)
     {
      return(CkBuySell14);
     }

//Exception 3 Singularity dO1==0 or dO4==0 
   if(dO1==0 || dO4==0)
     {
      Ex3=Yes;
      //SELL For EURUSD Only
      return(CkSingularitySell);
     }

//2.Calculate F (div 0 Error?)
   int f=(dO4*dO1)/MathAbs(dO4*dO1);

//3.Caluclate F1
   int f1=(dO1-dO4)/MathAbs(dO1-dO4);

//4.Calculate F*F1
   int ff1=f*f1;

//5.Calculate -C1
   int mC1=MathAbs(dO14-dO1);

//6.Calculate -C4
   int mC4=MathAbs(dO14-dO4);

//Exception 1 (dO1<3 and dO4<3)
   if(dO1<Ex1_limit && dO4<Ex1_limit)
     {
      Ex1=Yes;
     }

//Exception 2 0<|14-1|<3 or 0<|14-4|<3 or 0<|14|<3  
   if((mC1<Ex2_limit) || (mC4<Ex2_limit) || (MathAbs(dO14)<Ex2_limit))
     {
      Ex2=Yes;
     }

//Exception 4 (||14-1|-|14-4||)<4 
   if(MathAbs(mC1-mC4)<Ex4_limit)
     {
      Ex3=Yes;
     }

//If [..]=0 then C14 -->????

   int ResMin=0;

//Find Min
   if(ff1==-1)
     {
      ResMin=MathMin(f1*mC1*Ex1*Ex2*Ex4,f1*mC4*Ex1*Ex2*Ex4);

      //Show Ck C1
      if(MathAbs(ResMin)==mC1)
        {
         return(CkBuy1);
        }//END of Ck=C1

      //Show Ck C4
      if(MathAbs(ResMin)==mC4)
        {
         return(CkSell4);
        }//END of Ck=C4    
     }//END OF -1 MIN;

   int ResMax=0;

//Find Max
   if(ff1==1)
     {
      ResMax=MathMax(mC1*Ex1*Ex2*Ex4,mC4*Ex1*Ex2*Ex4);

      //Show Ck C1
      if(MathAbs(ResMax)==mC1)
        {
         return(CkBuy1);
        }//END of Ck=C1

      //Show Ck C4
      if(MathAbs(ResMax)==mC4)
        {
         return(CkSell4);
        }//END of Ck=C4    
     }//END OF -1 MIN;

//If No Signal
   return(CkNoSignal);
  }//End of m_BUILD_CK_TR18_0330_Virt
//+------------------------------------------------------------------+
//| Converts Ck Prediction to string                                 |
//+------------------------------------------------------------------+
string RTrade::CkResultToString(const char Ck)
  {
   switch(Ck)
     {
      case  -2: return("USD First");  break;
      case  -1: return("No Ck Signal");  break;
      case  0: return("Ck Buy (Case1)");  break;
      case  1: return("Ck Sell (Case4)");  break;
      case  2: return("Ck Buy & Sell (Case14)");  break;
      case  3: return("Ck Buy Singularity (2 Case1 )");  break;
      case  4: return("Ck Sell Singularity (2 Case4)");  break;

      default: return("Unknown Ck");
      break;
     }
  }//END OF CK to Sring
//+------------------------------------------------------------------+
//| Returns Ck prediction by Index                                   |
//+------------------------------------------------------------------+
char RTrade::CkPredictionByIndex(const uint CkIndex)
  {
   uint ArrSize=ArraySize(m_arr_ck_predictions);

//Check for right request
   if(CkIndex>ArrSize-1) return(-5);

//If Ok
   return(m_arr_ck_predictions[CkIndex]);
  }//End of Ck
//+------------------------------------------------------------------+
//| Check for Close                                                  |
//+------------------------------------------------------------------+
bool RTrade::m_CheckClose(const double Price,bool &BUY_OPENED,bool &SELL_OPENED,double &PositionProfit,
                          double &BUY_OPENED_PRICE,double &SELL_OPENED_PRICE,const double Dc,const int Spread)
  {
   if(BUY_OPENED || SELL_OPENED)
     {
      //3.1 Calculate Position Profit for buy
      if(BUY_OPENED)PositionProfit=(Price-BUY_OPENED_PRICE)/m_pair_point;

      //3.2 Calculate Position Profit for sell
      if(SELL_OPENED) PositionProfit=(SELL_OPENED_PRICE-Price)/m_pair_point;

      //3.3 Check Close Rule (DONT WORK)
      bool CTR_RESULT=m_EMUL_CloseRule(m_close_rule_num_emul,PositionProfit,Dc,Spread);

      //3.4 If need to Close position
      if(CTR_RESULT)
        {
         BUY_OPENED=false;
         SELL_OPENED=false;
         BUY_OPENED_PRICE=0;
         SELL_OPENED_PRICE=0;
         PositionProfit=0;
         return(true);
        }
     }//END OF TRY TO CLOSE

//if Not to Close 
   return(false);
  }//END OF CHECKCLOSE
//+------------------------------------------------------------------+
//| Check for Open                                                   |
//+------------------------------------------------------------------+
bool RTrade::m_CheckOpen(const double Price,const int OTR_RESULT,bool &BUY_OPENED,bool &SELL_OPENED,
                         double &BUY_OPENED_PRICE,double &SELL_OPENED_PRICE,int &BUY_Signal_Count,int &SELL_Signal_Count)
  {
//5. Check if NOSIGNAL then exit
   if(OTR_RESULT<=0) return(true);

//6. +++OPEN POSITION+++

//If Any Position Opened?
   if(BUY_OPENED || SELL_OPENED) return(true);

//If Buy
   if(OTR_RESULT==BUY1)
     {
      // Check If already opened Position exist, 
      if(BUY_OPENED)  return(true);

      BUY_OPENED_PRICE=Price;
      BUY_Signal_Count++;
      BUY_OPENED=true;
      //  Print("BUY "+TimeToString(m_arr_Rates_P1[i].time)+" "+DoubleToString(Calculated_Dc));
      return(true);
     }//END OF BUY

//If Sell
   if(OTR_RESULT==SELL1)
     {
      // Check If already opened Position exist, 
      if(SELL_OPENED)  return(true);

      SELL_OPENED_PRICE=Price;
      SELL_Signal_Count++;
      SELL_OPENED=true;
      //  Print("SELL "+TimeToString(m_arr_Rates_P1[i].time)+" "+DoubleToString(Calculated_Dc));
      return(true);
     }//END OF SELL
   return(false);
  }//End of m_Check_Open
//+------------------------------------------------------------------+
//| Choose Quant mode (4 option)                                     |
//+------------------------------------------------------------------+
bool RTrade::ChooseEmul_QuantMode(const ENUM_EMUL_OHLC_PRICE &QuantMode)
  {
   switch(QuantMode)
     {
      case  IND_CLOSE: //Use Indicator only Close prices in Open\Close positions

         break;

      case IND_OHLC:      //Use Indicator OHLC prices (4)

         break;

      case  FEED_CLOSE:   //Use only Close Prices WO Indicator
         break;

      case FEED_OHLC:  //Use OHLC on Open\Close WO Indicator
         break;

      default: //ALL_Close;
         break;
     }
   return(true);
  }//End of Choose quant mode
//+------------------------------------------------------------------+
//| Emulate Trading All Close                                        |
//+------------------------------------------------------------------+
bool RTrade::Emulate_Trading_AllClose(const bool Priming1,const STRUCT_Priming &CurP)
  {

//If not initialised, then exit
   if(!m_initialised_emul)
     {
      m_Result=-2;
      return(false);
     }

//Priming length
   int ArrSize=0;

//Set Current Priming
   if(Priming1)
     {
      m_CurrentPriming=true;
     }//Priming 2
   else
     {
      m_CurrentPriming=false;
     }

//Get Size of arr
   ArrSize=ArraySize(CurP.Rates);

//+++++EMULATION++++++\\
//+++++EMULATION++++++\\
//+++++EMULATION++++++\\

//Do it for 3 Cases :case 1, Case 4, Case14
   for(char Case=0;Case<3;Case++)
     {
      int BUY_Signal_Count=0;
      int SELL_Signal_Count=0;
      bool BUY_OPENED=false;
      double BUY_OPENED_PRICE=0;
      double SELL_OPENED_PRICE=0;
      bool SELL_OPENED=false;
      double Calculated_Dc=0;
      double PositionProfit=0;

      //From first day 00:00 to 23:50 last day in Priming1
      for(int i=ArrSize-1;i>-1;i--)
        {
         //1. Check Open Rule 
         int OTR_RESULT=m_EMUL_OpenRule(m_open_rule_num_emul,Case,i,-1,CurP);

         //2. Pass first 3 bars for DC
         if(i>ArrSize-3) continue;

         //2.1 Calculate DC
         Calculated_Dc=0;
         Calculated_Dc= m_EMUL_CalculateDc(i,CurP)*inpDeltaC_koef;

         //3. Check if pos opened, try to close,if closed continue   
         if(m_CheckClose(CurP.Rates[i].close,BUY_OPENED,SELL_OPENED,PositionProfit,BUY_OPENED_PRICE,SELL_OPENED_PRICE,
            Calculated_Dc,CurP.Spread[i])) continue;

         //4. Check Spread (if > max then next iteration)
         if(CheckSpread(m_max_spread_emul,CurP.Spread[i])) continue;

         //5. +++OPEN POSITION+++ (:true -> next iteration)
         if(m_CheckOpen(CurP.Rates[i].close,OTR_RESULT,BUY_OPENED,SELL_OPENED,BUY_OPENED_PRICE,
            SELL_OPENED_PRICE,BUY_Signal_Count,SELL_Signal_Count)) continue;

        }//END OF CASE

      //Fill Omega Structures for Priming1:
      if(m_CurrentPriming)
        {
         //Priming 1
         switch(Case)
           {
            case  0: m_arr_sim_q[m_simulated_primings_total].P1_Q1_Simul=BUY_Signal_Count;  break;
            case  1: m_arr_sim_q[m_simulated_primings_total].P1_Q4_Simul=SELL_Signal_Count;  break;
            case  2: m_arr_sim_q[m_simulated_primings_total].P1_Q14_Simul=BUY_Signal_Count+SELL_Signal_Count;break;

            default:
               break;
           }//End of Switch FILLING Priming1 Omega Structures
        }//End of Priming1 Switch
      else
        {
         //Priming 2
         switch(Case)
           {
            case  0: m_arr_sim_q[m_simulated_primings_total].P2_Q1_Simul=BUY_Signal_Count;  break;
            case  1: m_arr_sim_q[m_simulated_primings_total].P2_Q4_Simul=SELL_Signal_Count;  break;
            case  2: m_arr_sim_q[m_simulated_primings_total].P2_Q14_Simul=BUY_Signal_Count+SELL_Signal_Count;

            //Only after Second Priming Case2 : Add +1 Cell to Dynamic Array of Primings Omegas
            ArrayResize(m_arr_sim_q,ArraySize(m_arr_sim_q)+1);

            //Always increase by 1 this counter, otherwise program writes to [0]
            m_simulated_primings_total++;
            break;

            default:
               break;
           }//End of Switch FILLING Priming1 Omega Structures

        }//End of Priming 2 Switch

     }//END OF ALL CASES

//If Ok
   return(true);
  }//END OF Emulate Trading All Close 
//+------------------------------------------------------------------+
//| Emulate Trading All OHLC                                         |
//+------------------------------------------------------------------+
bool RTrade::Emulate_Trading_AllOHLC(const bool Priming1,const STRUCT_Priming &CurP)
  {

//If not initialised, then exit
   if(!m_initialised_emul)
     {
      m_Result=-2;
      return(false);
     }

//Priming length
   int ArrSize=0;

//Set Current Priming
   if(Priming1)
     {
      m_CurrentPriming=true;
     }//Priming 2
   else
     {
      m_CurrentPriming=false;
     }

//Get Size of arr
   ArrSize=ArraySize(CurP.Rates);

//+++++EMULATION++++++\\
//+++++EMULATION++++++\\
//+++++EMULATION++++++\\

//Do it for 3 Cases :case 1, Case 4, Case14
   for(char Case=0;Case<3;Case++)
     {
      int BUY_Signal_Count=0;
      int SELL_Signal_Count=0;
      bool BUY_OPENED=false;
      double BUY_OPENED_PRICE=0;
      double SELL_OPENED_PRICE=0;
      bool SELL_OPENED=false;
      double Calculated_Dc=0;
      double Calculated_DcOld=0;
      double PositionProfit=0;
      double Current_OHLC_Price=0;

      //From first day 00:00 to 23:50 last day in Priming1
      for(int i=ArrSize-1;i>-1;i--)
        {

         //SWITCH between O,H,L,C
         for(int OHLC=0;OHLC<4;OHLC++)
           {
/*
        NONE = -1 
        Open  = 0 
        High  = 1
        Low   = 2
        Close = 3
        */

            //Reset DC
            Calculated_Dc=0;

            //Switch Current O,H,L,C
            switch(OHLC)
              {
               case  -1://All OHLC 
                  Current_OHLC_Price=CurP.Rates[i].close;
                  Calculated_Dc=CurP.Dc_Close[i];
                  break;

               case  0://OPEN 
                  Current_OHLC_Price=CurP.Rates[i].open;
                  Calculated_Dc=CurP.Dc_Open[i];
                  break;

               case  1://HIGH 
                  Current_OHLC_Price=CurP.Rates[i].high;
                  Calculated_Dc=CurP.Dc_High[i];
                  break;

               case  2://LOW 
                  Current_OHLC_Price=CurP.Rates[i].low;
                  Calculated_Dc=CurP.Dc_Low[i];
                  break;

               case  3://CLOSE 
                  Current_OHLC_Price=CurP.Rates[i].close;
                  Calculated_Dc=CurP.Dc_Close[i];
                  break;
               default:
                  break;
              }//END of switch OHLC

            //1. Check Open Rule 
            int OTR_RESULT=m_EMUL_OpenRule(m_open_rule_num_emul,Case,i,OHLC,CurP);

            //2. Pass first 3 bars for DC
            if(i>ArrSize-3) continue;

            //????? How Calculate dc for Open,High,Low,Close ???? Is it one price or many different prices ?
            Calculated_DcOld=m_EMUL_CalculateDc(i,CurP)*inpDeltaC_koef;

            //  Print("OHLC: "+IntegerToString(OHLC)+",dc: "+DoubleToString(Calculated_Dc));

            //3. Check if pos opened, try to close,if closed continue   
            if(m_CheckClose(Current_OHLC_Price,BUY_OPENED,SELL_OPENED,PositionProfit,BUY_OPENED_PRICE,SELL_OPENED_PRICE,
               Calculated_Dc,CurP.Spread[i])) continue;

            //4. Check Spread (if > max then next iteration)
            if(CheckSpread(m_max_spread_emul,CurP.Spread[i])) continue;

            //5. +++OPEN POSITION+++ (:true -> next iteration)
            if(m_CheckOpen(Current_OHLC_Price,OTR_RESULT,BUY_OPENED,SELL_OPENED,BUY_OPENED_PRICE,
               SELL_OPENED_PRICE,BUY_Signal_Count,SELL_Signal_Count)) continue;
           }//END OF OHLC SWITCH
        }//END OF CASE

      //Fill Omega Structures for Priming1:
      if(m_CurrentPriming)
        {
         //Priming 1
         switch(Case)
           {
            case  0: m_arr_sim_q[m_simulated_primings_total].P1_Q1_Simul=BUY_Signal_Count;  break;
            case  1: m_arr_sim_q[m_simulated_primings_total].P1_Q4_Simul=SELL_Signal_Count;  break;
            case  2: m_arr_sim_q[m_simulated_primings_total].P1_Q14_Simul=BUY_Signal_Count+SELL_Signal_Count;break;

            default:
               break;
           }//End of Switch FILLING Priming1 Omega Structures
        }//End of Priming1 Switch
      else
        {
         //Priming 2
         switch(Case)
           {
            case  0: m_arr_sim_q[m_simulated_primings_total].P2_Q1_Simul=BUY_Signal_Count;  break;
            case  1: m_arr_sim_q[m_simulated_primings_total].P2_Q4_Simul=SELL_Signal_Count;  break;
            case  2: m_arr_sim_q[m_simulated_primings_total].P2_Q14_Simul=BUY_Signal_Count+SELL_Signal_Count;

            //Only after Second Priming Case2 : Add +1 Cell to Dynamic Array of Primings Omegas
            ArrayResize(m_arr_sim_q,ArraySize(m_arr_sim_q)+1);

            //Always increase by 1 this counter, otherwise program writes to [0]
            m_simulated_primings_total++;
            break;

            default:
               break;
           }//End of Switch FILLING Priming1 Omega Structures
        }//End of Priming 2 Switch
     }//END OF ALL CASES

//If Ok
   return(true);
  }//END OF Emulate Trading All OHLC
//+------------------------------------------------------------------+
//| Emulate dc by 3 bars forward  (Ver 2)                            |
//+------------------------------------------------------------------+
double RTrade::m_EMUL_CalculateDc(const uint Iteration,const STRUCT_Priming &Priming)
  {
   double res=-1;
   uint i=Iteration;

   double r0=Priming.Rates[i].high-Priming.Rates[i].low;

   double r2=Priming.Rates[i+2].high-Priming.Rates[i+2].low;

   long t1=Priming.Rates[i+2].tick_volume-Priming.Rates[i+1].tick_volume;

   double t2=t1*r2;
   if(t2==0)return(res=0); //div 0 exception

   double t3=Priming.Rates[i+1].close-Priming.Rates[i+2].close;

   double t4=t3/t2;

   long t6=Priming.Rates[i+1].tick_volume-Priming.Rates[i].tick_volume;

   res=t6*t4*r0;
   res= NormalizeDouble(res,5);

//If Ok
   return(res);
  }//END of Emulate dc by 3 bars forward    
//+------------------------------------------------------------------+
//| Emulated Open TR Caterpillar                                     |
//+------------------------------------------------------------------+
int RTrade::m_EMUL_TR_Caterpillar(const char Case,const int IterationNum,const STRUCT_Priming &Priming,const int OHLC)
  {
//Cases: Case0=1,Case1=4,Case2=14
   int i=IterationNum;

   double signal=0;
   double pom=0;
   double whofirst=0;

//Switch OHLC   
   switch(OHLC)
     {
      case  -1: //AllClose
         signal=Priming.Signal_Close[i];
         pom=Priming.Pom_Close[i];
         whofirst=Priming.First_Close[i];
         break;

      case  0: //OPEN
         signal=Priming.Signal_Open[i];
         pom=Priming.Pom_Open[i];
         whofirst=Priming.First_Open[i];
         break;

      case  1: //HIGH
         signal=Priming.Signal_High[i];
         pom=Priming.Pom_High[i];
         whofirst=Priming.First_High[i];
         break;

      case  2: //LOW
         signal=Priming.Signal_Low[i];
         pom=Priming.Pom_Low[i];
         whofirst=Priming.First_Low[i];
         break;

      case  3: //CLOSE
         signal=Priming.Signal_Close[i];
         pom=Priming.Pom_Close[i];
         whofirst=Priming.First_Close[i];
         break;
      default:
         break;
     }//END of switch OHLC

//Check if Signal==0 then exit
   if(signal==0) return(-2);

//Check if WhoFirst==0 then exit
   if(whofirst==0) return(-2);

// (Case 1) or Case4
   if(Case==0 || Case==2)
     {
      if((signal==1) && (pom>=m_pom_buy_emul) && (pom<m_pom_buy_emul+m_pom_koef_emul))
         return(BUY1);
     }//END OF CASE1

//(Case 4) or Case14
   if(Case==1 || Case==2)
     {
      if((signal==-1) && (pom>=m_pom_sell_emul) && (pom<m_pom_sell_emul+m_pom_koef_emul))
         return(SELL1);
     }

//If No Signal
   return(-1);
  }//END OF Emulated Open TR Caterpillar
//+------------------------------------------------------------------+
//| Open Rule For emulation                                          |
//+------------------------------------------------------------------+
int RTrade::m_EMUL_OpenRule(const ENUM_EMUL_OpenRule OpenRuleNum,const char Case,const int IterationNum,
                            const int OHLC,const STRUCT_Priming &Priming)
  {
//TR_RESULT  
   int TR_RES=-1;

   if(OpenRuleNum<0)
     {
      return(-2);
     }

   switch(OpenRuleNum)
     {
      case  0:TR_RES=m_EMUL_TR_Caterpillar(Case,IterationNum,Priming,OHLC);

      break;
      default:
         break;
     }
//If Ok
   return(TR_RES);
  }//End of EmulOpenRule  
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Emulate Trading All OHLC WO Indicator using feed                 |
//+------------------------------------------------------------------+
bool RTrade::Emulate_Trading_AllOHLC_WO_Indicator(const bool Priming1,const MqlRates &Rates[],
                                                  const STRUCT_FEED_OHLC &Feed[],const STRUCT_TICKVOL_OHLC &TickVol[])
  {

//If not initialised, then exit
   if(!m_initialised_emul)
     {
      m_Result=-2;
      return(false);
     }

//Priming length
   int ArrSize=0;

//Set Current Priming
   if(Priming1)
     {
      m_CurrentPriming=true;
     }//Priming 2
   else
     {
      m_CurrentPriming=false;
     }

//Get Size of arr
   ArrSize=ArraySize(Rates);

//+++++EMULATION++++++\\
//+++++EMULATION++++++\\
//+++++EMULATION++++++\\

//Do it for 3 Cases :case 1, Case 4, Case14
   for(char Case=0;Case<3;Case++)
     {
      int BUY_Signal_Count=0;
      int SELL_Signal_Count=0;
      bool BUY_OPENED=false;
      double BUY_OPENED_PRICE=0;
      double SELL_OPENED_PRICE=0;
      bool SELL_OPENED=false;
      double Calculated_Dc=0;
      double Calculated_DcOld=0;
      double PositionProfit=0;
      double Current_OHLC_Price=0;

      //From first day 00:00 to 23:50 last day in Priming1
      for(int i=ArrSize-1;i>-1;i--)
        {

         //SWITCH between O,H,L,C
         for(int OHLC=0;OHLC<4;OHLC++)
           {
/*
        NONE = -1 
        Open  = 0 
        High  = 1
        Low   = 2
        Close = 3
        */

            //Reset DC
            Calculated_Dc=0;

            //Switch Current O,H,L,C
            switch(OHLC)
              {
               case  -1://All CLOSE 
                  Current_OHLC_Price=Rates[i].close;
                  Calculated_Dc=Feed[i].Close_dc*inpDeltaC_koef;
                  break;

               case  0://OPEN 
                  Current_OHLC_Price=Rates[i].open;
                  Calculated_Dc=Feed[i].Open_dc*inpDeltaC_koef;
                  break;

               case  1://HIGH 
                  Current_OHLC_Price=Rates[i].high;
                  Calculated_Dc=Feed[i].High_dc*inpDeltaC_koef;
                  break;

               case  2://LOW 
                  Current_OHLC_Price=Rates[i].low;
                  Calculated_Dc=Feed[i].Low_dc*inpDeltaC_koef;
                  break;

               case  3://CLOSE 
                  Current_OHLC_Price=Rates[i].close;
                  Calculated_Dc=Feed[i].Close_dc*inpDeltaC_koef;
                  break;
               default:
                  break;
              }//END of switch OHLC

            //1. Check Open Rule 
            int OTR_RESULT=m_EMUL_OpenRule_OHLC_Feed(m_open_rule_num_emul,Case,i,OHLC,Feed);

            //2. Check if pos opened, try to close,if closed continue   
            if(m_CheckClose(Current_OHLC_Price,BUY_OPENED,SELL_OPENED,PositionProfit,BUY_OPENED_PRICE,SELL_OPENED_PRICE,
               Calculated_Dc,Rates[i].spread)) continue;

            //3. Check Spread (if > max then next iteration)
            if(CheckSpread(m_max_spread_emul,Rates[i].spread)) continue;

            //4. +++OPEN POSITION+++ (:true -> next iteration)
            if(m_CheckOpen(Current_OHLC_Price,OTR_RESULT,BUY_OPENED,SELL_OPENED,BUY_OPENED_PRICE,
               SELL_OPENED_PRICE,BUY_Signal_Count,SELL_Signal_Count)) continue;
           }//END OF OHLC SWITCH
        }//END OF CASE

      //Fill Omega Structures for Priming1:
      if(m_CurrentPriming)
        {
         //Priming 1
         switch(Case)
           {
            case  0: m_arr_sim_q[m_simulated_primings_total].P1_Q1_Simul=BUY_Signal_Count;  break;
            case  1: m_arr_sim_q[m_simulated_primings_total].P1_Q4_Simul=SELL_Signal_Count;  break;
            case  2: m_arr_sim_q[m_simulated_primings_total].P1_Q14_Simul=BUY_Signal_Count+SELL_Signal_Count;break;

            default:
               break;
           }//End of Switch FILLING Priming1 Omega Structures
        }//End of Priming1 Switch
      else
        {
         //Priming 2
         switch(Case)
           {
            case  0: m_arr_sim_q[m_simulated_primings_total].P2_Q1_Simul=BUY_Signal_Count;  break;
            case  1: m_arr_sim_q[m_simulated_primings_total].P2_Q4_Simul=SELL_Signal_Count;  break;
            case  2: m_arr_sim_q[m_simulated_primings_total].P2_Q14_Simul=BUY_Signal_Count+SELL_Signal_Count;

            //Only after Second Priming Case2 : Add +1 Cell to Dynamic Array of Primings Omegas
            ArrayResize(m_arr_sim_q,ArraySize(m_arr_sim_q)+1);

            //Always increase by 1 this counter, otherwise program writes to [0]
            m_simulated_primings_total++;
            break;

            default:
               break;
           }//End of Switch FILLING Priming1 Omega Structures
        }//End of Priming 2 Switch
     }//END OF ALL CASES

//If Ok
   return(true);
  }//END OF Emulate Trading All OHLC WO Indicator, using Feed
//+------------------------------------------------------------------+
//| Open Rule WO Indicator for OHLC                                  |
//+------------------------------------------------------------------+
int RTrade::m_EMUL_OpenRule_OHLC_Feed(const ENUM_EMUL_OpenRule OpenRuleNum,
                                      const char Case,const int IterationNum,const int OHLC,const STRUCT_FEED_OHLC &FeedOHLC[])
  {
//TR_RESULT  
   int TR_RES=-1;

   if(OpenRuleNum<0)
     {
      return(-2);
     }

   switch(OpenRuleNum)
     {
      case  0:TR_RES=m_EMUL_TR_Caterpillar_OHLC_Feed(Case,IterationNum,FeedOHLC,OHLC);

      break;
      default:
         break;
     }
//If Ok
   return(TR_RES);
  }//END OF Open Rule WO Indicator OHLC 
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| TR Caterpillar WO Indicator                                      |
//+------------------------------------------------------------------+
int RTrade::m_EMUL_TR_Caterpillar_OHLC_Feed(const char Case,const int IterationNum,
                                            const STRUCT_FEED_OHLC &Feed[],const int OHLC)
  {
//Cases: Case0=1,Case1=4,Case2=14
   int i=IterationNum;

   double signal=0;
   double pom=0;
   double whofirst=0;

//Switch OHLC   
   switch(OHLC)
     {
      case  -1: //AllClose
         signal=Feed[i].Close_signal;
         pom=Feed[i].Close_pom;
         whofirst=Feed[i].Close_WhoFirst;
         break;

      case  0: //OPEN
         signal=Feed[i].Open_signal;
         pom=Feed[i].Open_pom;
         whofirst=Feed[i].Open_WhoFirst;
         break;

      case  1: //HIGH
         signal=Feed[i].High_signal;
         pom=Feed[i].High_pom;
         whofirst=Feed[i].High_WhoFirst;
         break;

      case  2: //LOW
         signal=Feed[i].Low_signal;
         pom=Feed[i].Low_pom;
         whofirst=Feed[i].Low_WhoFirst;
         break;

      case  3: //CLOSE
         signal=Feed[i].Close_signal;
         pom=Feed[i].Close_pom;
         whofirst=Feed[i].Close_WhoFirst;
         break;
      default:
         break;
     }//END of switch OHLC

//Check if Signal==0 then exit
   if(signal==0) return(-2);

//Check if WhoFirst==0 then exit
   if(whofirst==0) return(-2);

// (Case 1) or Case4
   if(Case==0 || Case==2)
     {
      if((signal==1) && (pom>=m_pom_buy_emul) && (pom<m_pom_buy_emul+m_pom_koef_emul))
         return(BUY1);
     }//END OF CASE1

//(Case 4) or Case14
   if(Case==1 || Case==2)
     {
      if((signal==-1) && (pom>=m_pom_sell_emul) && (pom<m_pom_sell_emul+m_pom_koef_emul))
         return(SELL1);
     }

//If No Signal
   return(-1);
  }//END OF TR Caterpillar WO Indicator 
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Emulate All CLOSE WO INDICATOR                                   |
//+------------------------------------------------------------------+
bool RTrade::Emulate_Trading_ALLClose_WO_Indicator(const bool Priming1,const MqlRates &Rates[],
                                                   const STRUCT_FEED_CLOSE &Feed[])
  {

//If not initialised, then exit
   if(!m_initialised_emul)
     {
      m_Result=-2;
      return(false);
     }

//Priming length
   int ArrSize=0;

//Set Current Priming
   if(Priming1)
     {
      m_CurrentPriming=true;
     }//Priming 2
   else
     {
      m_CurrentPriming=false;
     }

//Get Size of arr
   ArrSize=ArraySize(Rates);

//+++++EMULATION++++++\\
//+++++EMULATION++++++\\
//+++++EMULATION++++++\\

//Do it for 3 Cases :case 1, Case 4, Case14
   for(char Case=0;Case<3;Case++)
     {
      int BUY_Signal_Count=0;
      int SELL_Signal_Count=0;
      bool BUY_OPENED=false;
      double BUY_OPENED_PRICE=0;
      double SELL_OPENED_PRICE=0;
      bool SELL_OPENED=false;
      double Calculated_Dc=0;
      double Calculated_DcOld=0;
      double PositionProfit=0;
      double Current_OHLC_Price=0;

      //From first day 00:00 to 23:50 last day in Priming1
      for(int i=ArrSize-1;i>-1;i--)
        {

         //Reset DC
         Calculated_Dc=0;
         Current_OHLC_Price=Rates[i].close;
         Calculated_Dc=Feed[i].Close_dc*inpDeltaC_koef;

         //1. Check Open Rule (OHLC=-1 : for Close Only Prices)
         int OTR_RESULT=m_EMUL_OpenRule_CLOSE_Feed(m_open_rule_num_emul,Case,i,-1,Feed);

         //2. Check if pos opened, try to close,if closed continue   
         if(m_CheckClose(Current_OHLC_Price,BUY_OPENED,SELL_OPENED,PositionProfit,BUY_OPENED_PRICE,SELL_OPENED_PRICE,
            Calculated_Dc,Rates[i].spread)) continue;

         //3. Check Spread (if > max then next iteration)
         if(CheckSpread(m_max_spread_emul,Rates[i].spread)) continue;

         //4. +++OPEN POSITION+++ (:true -> next iteration)
         if(m_CheckOpen(Current_OHLC_Price,OTR_RESULT,BUY_OPENED,SELL_OPENED,BUY_OPENED_PRICE,
            SELL_OPENED_PRICE,BUY_Signal_Count,SELL_Signal_Count)) continue;
        }//END OF CASE

      //Fill Omega Structures for Priming1:
      if(m_CurrentPriming)
        {
         //Priming 1
         switch(Case)
           {
            case  0: m_arr_sim_q[m_simulated_primings_total].P1_Q1_Simul=BUY_Signal_Count;  break;
            case  1: m_arr_sim_q[m_simulated_primings_total].P1_Q4_Simul=SELL_Signal_Count;  break;
            case  2: m_arr_sim_q[m_simulated_primings_total].P1_Q14_Simul=BUY_Signal_Count+SELL_Signal_Count;break;

            default:
               break;
           }//End of Switch FILLING Priming1 Omega Structures
        }//End of Priming1 Switch
      else
        {
         //Priming 2
         switch(Case)
           {
            case  0: m_arr_sim_q[m_simulated_primings_total].P2_Q1_Simul=BUY_Signal_Count;  break;
            case  1: m_arr_sim_q[m_simulated_primings_total].P2_Q4_Simul=SELL_Signal_Count;  break;
            case  2: m_arr_sim_q[m_simulated_primings_total].P2_Q14_Simul=BUY_Signal_Count+SELL_Signal_Count;

            //Only after Second Priming Case2 : Add +1 Cell to Dynamic Array of Primings Omegas
            ArrayResize(m_arr_sim_q,ArraySize(m_arr_sim_q)+1);

            //Always increase by 1 this counter, otherwise program writes to [0]
            m_simulated_primings_total++;
            break;

            default:
               break;
           }//End of Switch FILLING Priming1 Omega Structures
        }//End of Priming 2 Switch
     }//END OF ALL CASES

//If Ok
   return(true);
  }//END OF EMUL ALL CLOSE WO INDICATOR
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Open Rule WO Indicator for CLOSE Only                            |
//+------------------------------------------------------------------+
int RTrade::m_EMUL_OpenRule_CLOSE_Feed(const ENUM_EMUL_OpenRule OpenRuleNum,
                                       const char Case,const int IterationNum,const int OHLC,const STRUCT_FEED_CLOSE &FeedClose[])
  {
//TR_RESULT  
   int TR_RES=-1;

   if(OpenRuleNum<0)
     {
      return(-2);
     }

   switch(OpenRuleNum)
     {
      case  0:TR_RES=m_EMUL_TR_Caterpillar_CLOSE_Feed(Case,IterationNum,FeedClose);

      break;
      default:
         break;
     }
//If Ok
   return(TR_RES);
  }//END OF Open Rule WO Indicator for Close Only 
//+------------------------------------------------------------------+
//| TR Caterpillar WO Indicator CLOSE Only Prices                    |
//+------------------------------------------------------------------+
int RTrade::m_EMUL_TR_Caterpillar_CLOSE_Feed(const char Case,const int IterationNum,
                                             const STRUCT_FEED_CLOSE &FeedCLOSE[])
  {
//Cases: Case0=1,Case1=4,Case2=14
   int i=IterationNum;

   double signal=0;
   double pom=0;
   double whofirst=0;

   signal=FeedCLOSE[i].Close_signal;
   pom=FeedCLOSE[i].Close_pom;
   whofirst=FeedCLOSE[i].Close_WhoFirst;

//Check if Signal==0 then exit
   if(signal==0) return(-2);

//Check if WhoFirst==0 then exit
   if(whofirst==0) return(-2);

// (Case 1) or Case4
   if(Case==0 || Case==2)
     {
      if((signal==1) && (pom>=m_pom_buy_emul) && (pom<m_pom_buy_emul+m_pom_koef_emul))
         return(BUY1);
     }//END OF CASE1

//(Case 4) or Case14
   if(Case==1 || Case==2)
     {
      if((signal==-1) && (pom>=m_pom_sell_emul) && (pom<m_pom_sell_emul+m_pom_koef_emul))
         return(SELL1);
     }

//If No Signal
   return(-1);
  }//END OF TR Caterpillar WO Indicator CLOSE Only prices
