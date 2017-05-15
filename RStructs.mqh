//+------------------------------------------------------------------+
//|                                                      RStructs.mqh|
//|                             Copyright 2016, Shcherbyna Rostyslav |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Shcherbyna Rostyslav"
#property link      ""
#property version   "1.98"

#include <Tools\DateTime.mqh>

/*
Include all structures and global constants
*/
/*
+++++CHANGE LOG+++++
1.98 12.03.2017--Add Real Ticks EURUSD D1+MN1 and USDCHF MN1 Trs
1.97 03.02.2017--Add 2 new Caterpillars
1.96 01.12.2016--Add new CHF and GBP Tick TRs
1.95 16.11.2016--Add Additional Report Info+New TRs
1.94 10.10.2016--Tick USDJPY USDx working TR
1.92 09.09.2016--Fully Stable Tick CVTR
1.91 03.09.2016--Caterpillar perfomance optimisation
1.90 02.09.2016--Add RealTick support + Perfomance optimisation
1.84 09.08.2016--Add USDJPY TR & Build Ck Params & Exceptions
1.82 28.07.2016--Add 4 Version for POM TR (+Reverse)
1.78 22.07.2016--Add to Emulated QNP -  RT QNP
1.75 19.07.2016--Add CkTR 0711 xUSD with Singularity (f,f1)
1.7  04.07.2016--Add QNP Export
1.6  20.06.2016--Add Custom Feed WO Indicator to Emulation and Trading
1.5  30.05.2016--Clear Old Code , better perfomance (33 sec from 2010 to 2016.04 Daily)
1.41 28.05.2016--Minor version with ability to Export OHLC to CSV & BIN
1.4 20.05.2016--Stable with AutoCompounding
1.3 19.05.2016--Stable, without Copy Arrays
1.2 15.05.2016--Version with Commented Addition code
1.1 6.05.2016 --Version with working RStructs (separate file)
--Ver 1.0 Stable
*/

//CONSTANTS
const char Yes = -1;
const char No  = 1;
const string MacSeparator="\t";
const string WindowsSeparator=",";
const uint MAGIC_IB=3000000;
const uint MAGIC_IS=3100000;
const uchar OP_BUY=0;
const uchar OP_SELL=1;
//Indicator POM3 Signals:
const char Ind_Buy = 1;
const char Ind_Sell=-1;
const int BUY1=1005;
const int SELL1=2006;
const char BUY=1;
const char SELL=-1;
const char NOSIGNAL=0;
const char HighFirst= 1;
const char LowFirst = -1;
const char EqualFirst=0; //High==Open or other Private Case
const ushort     inpDeltaC_koef=1000; //Dc * 
                                      //
//Global VAR
ulong draw_object_counter=0;
//---Primings structs
struct STRUCT_TICKVOL_OHLC
  {
   datetime          Time;
   double            Open_TickVol;
   double            High_TickVol;
   double            Low_TickVol;
   double            Close_TickVol;
   bool              High_First;// (true or low first =false)
  };
//---OHLC Feed Struct
struct STRUCT_FEED_OHLC
  {
   datetime          Time;
   char              Open_WhoFirst;
   char              High_WhoFirst;
   char              Low_WhoFirst;
   char              Close_WhoFirst;

   double            Open_pom;
   double            High_pom;
   double            Low_pom;
   double            Close_pom;

   char              Open_signal;
   char              High_signal;
   char              Low_signal;
   char              Close_signal;

   double            Open_dc;
   double            High_dc;
   double            Low_dc;
   double            Close_dc;
  };
//---CLOSE Feed Struct
struct STRUCT_FEED_CLOSE
  {
   datetime          Time;
   char              Close_WhoFirst;
   double            Close_pom;
   char              Close_signal;
   double            Close_dc;
  };
//Old Priming Structs
struct STRUCT_Priming
  {
   MqlRates          Rates[];
   uint              Spread[];
   //Signal
   double            Signal_Open[];
   double            Signal_High[];
   double            Signal_Low[];
   double            Signal_Close[];
   //First
   double            First_Open[];
   double            First_High[];
   double            First_Low[];
   double            First_Close[];
   //Pom
   double            Pom_Open[];
   double            Pom_High[];
   double            Pom_Low[];
   double            Pom_Close[];
   //Dc
   double            Dc_Open[];
   double            Dc_High[];
   double            Dc_Low[];
   double            Dc_Close[];
  };
//Struct for DB (first & last minute)
struct FLM
  {
   datetime          day_first_minute;
   datetime          day_last_minute;
  };
//---Structure for time marks
struct TIMEMARKS
  {
   datetime          P1_Start;
   datetime          P1_Stop;
   datetime          P2_Start;
   datetime          P2_Stop;
   datetime          Now_Start;
   datetime          Now_Stop;
  };
//---Structure for simulated Qs
struct SIMUL_Q
  {
   int               P1_Q1_Simul;
   int               P1_Q4_Simul;
   int               P1_Q14_Simul;
   int               P2_Q1_Simul;
   int               P2_Q4_Simul;
   int               P2_Q14_Simul;
  };
//---Structure for simulated NPs
struct SIMUL_NP
  {
   double            P1_NP1;
   double            P1_NP4;
   double            P1_NP14;
   double            P2_NP1;
   double            P2_NP4;
   double            P2_NP14;
  };
//---Structure for real time Qs
struct RT_Q
  {
   int               Q1_RT;
   int               Q4_RT;
  };
//---Structure for real time NPs
struct RT_NP
  {
   double            NP1_RT;
   double            NP4_RT;
  };
//---Structure for Ck values
struct STRUCT_CK
  {
   int               f;
   int               f1;
   int               f_f1;
   int               a;
   int               b;
   int               g;
   bool              beta;
   int               Beta;
   double            gamma;
   double            w;     //Q1/|Q1|
   double            aa;    //A/|A|
  };
//+------------------------------------------------------------------+
//| Export Struct for miniTRs                                        |
//+------------------------------------------------------------------+
struct STRUCT_miniTR
  {
   datetime          StartTime;
   double            Gamma;
   double            w;
   double            aa;
   int               F;
   int               F1;
   int               A;
   int               B;
   int               Beta;
   int               dQ1;
   int               dQ4;
   int               dQ14;
   char              FSingul;
   char              F1Singul;
   char              BetaSingul;
   char              GammaSingul;
  };
//---Exceptions for Ck
struct STRUCT_EXCK
  {
   uchar             ex_Limit;                        // Limit=3
   char              ex_F_Singularity;                // F div 0
   char              ex_Daily_F_Singularity;          // 1*4=0
   char              ex_F1_Singularity;               // F1 div 0
   char              ex_Beta_Singularity;             // A*B=0 && A+B!=0
   char              ex_Daily_Beta_Singularity;       // A*B=0 && A-B!=0
   char              ex_Gamma_Singularity;            // dO14=0
   char              ex_NormalNavigators;             // |f|==|f1|==|Beta|==1
   char              ex_SleepMarket;                  // dO1=dO4=dO14
   char              ex_FS_Singularity;               // 1*4=0 && 1+4<>0 
   char              ex_F1S_Singularity;              // 1-4=0 && 1+4<>0 
   char              ex_SS_SleepMarket;               // 1=0 && 4=0 (SS)
   char              ex_G_Zero;                       // G = 0
   char              ex_G_Less_Limit;                 // G <= 3
   char              ex_A_Eq_B;                       // A==B
   char              ex_A_Minus_B_Zero;               // A-B==0
   char              ex_A_Minus_B_LessLimit;          // (A-B)<=3
   char              ex_B_LessLimit;                  // B<3   
   char              ex_A_LessLimit;                  // A<3
   char              ex_Abs14_LessLimit;              // 0<|14|<=3
   char              ex_Abs14_LessTwo;                // |14|<2
   char              ex_Abs14_LessOrEqualTwo;         // |14|<=2; (Gamma singularity)
   char              ex_Abs1Abs4_LessLimit;           // 0<|1|<3 && 0<|4|<3
   char              ex_dQ1_Equal_dQ4;                // 1=4
   char              ex_AMinusB_0_AND_Q1NotEqualQ4;   // (A-B==0) AND Q1!=Q4
   char              ex_Abs_dO1_LessLimit;            // |1|<3
   char              ex_Abs_dO4_LessLimit;            // |4|<3   
   char              ex_A_LessLimit_AND_NOT_ZERO;     // A<3 AND A-B!=0   
   char              ex_B_LessLimit_AND_NOT_ZERO;     // B<3 AND A-B!=0   
   char              ex_A_Eq_B_Eq_Zero;               // A=B=0
   char              ex_AbsA_LessLimit;               // 0<=|A|<3
   char              ex_AbsB_LessLimit;               // 0<=|B|<3
   char              ex_AbsA_LessLim_AND_B_NOTZERO;   // 0<|A|<=Lim AND B!=0;
   char              ex_AbsB_LessLim_AND_A_NOTZERO;   // 0<|B|<=Lim AND A!=0;
   char              ex_AbsA_LessFour_AND_B_NOTZERO;  // 0<|A|<=4 AND B!=0;
   char              ex_AbsB_LessFour_AND_A_NOTZERO;  // 0<|B|<=4 AND A!=0;
   char              ex_AbsA_StrongLessFour_AND_B_NOTZERO;  // 0<|A|<4 AND B!=0;
   char              ex_AbsB_StrongLessFour_AND_A_NOTZERO;  // 0<|B|<4 AND A!=0;
   char              ex_AbsA_Minus_AbsB_LessLim;      // 0<|A-B|<=Lim
   char              ex_AbsA_Minus_AbsB_StrongLessLim;// 0<|A-B|<Lim
                                                      //
   //Daily Exs:
   char              ex_AOne;                         // A==1
   char              ex_BOne;                         // B==1
   char              ex_AplusB_LessEqual_Lim;         // 0<=A+B<=Lim
   char              ex_AminusB_LessEqual_Lim;        // 0<=A-B<=Lim
   char              ex_BminusA_LessEqual_Lim;        // 0<=B-A<=Lim
   char              ex_Abs_AminusB_LessEqual_Lim;    // 0<|A-B|<=Lim
   char              ex_Abs_AplusB_LessEqual_Lim;     // 0<|A+B|<=Lim
   char              ex_Strong_Abs_AminusB_LessEqual_Lim;//|A-B|<=Lim
   char              ex_Strong_Abs_AplusB_LessEqual_Lim; //|A+B|<=Lim


   char              ex_TOTAL;                        // SUM of Exceptions   
  };
//+------------------------------------------------------------------+
//|DNK7 struct wf,pom,pomsignal,y1,y2,dc,inflection point            |
//+------------------------------------------------------------------+ 
struct STRUCT_DNK7 //(80+2 bytes)
  {
   double            price;
   double            pom;
   double            dc;
   double            y1;
   double            y2;
   double            ip;
   char              signal;
   char              wf;
  };
//+------------------------------------------------------------------+
//|Groups ID 5 Singularities + 16=(21)+1 NOTRADE=22                  |
//+------------------------------------------------------------------+
enum ENUM_T_GROUP_ID
  {
   NOTRADE,                   //#0
   HybridSingul,
   FSingul,                   //#2
   F1Singul,                  //#3
   BetaSingul,                //#4
   GammaSingul,               //#5
   FF1_PPpp,                  //#6 p-plus
   FF1_PPmm,                  //#7 m-minus
   FF1_PPpm,                  //#8
   FF1_PPmp,                  //#9
   FF1_MMpp,                  //#10 p-plus
   FF1_MMmm,                  //#11 m-minus
   FF1_MMpm,                  //#12
   FF1_MMmp,                  //#13
   FF1_PMpp,                  //#14 p-plus
   FF1_PMmm,                  //#15 m-minus
   FF1_PMpm,                  //#16
   FF1_PMmp,                  //#17
   FF1_MPpp,                  //#18 p-plus
   FF1_MPmm,                  //#19 m-minus
   FF1_MPpm,                  //#20
   FF1_MPmp,                  //#21 
   Unknown                    //#22   
  };//TOTALLY 23!
//+------------------------------------------------------------------+
//| miniTR functions ID (ex:MinAB = 0)                               |
//+------------------------------------------------------------------+  
enum ENUM_miniTR_ID
  {
   C1,
   C4,
   Min_A_B,
   Max_A_B,
   VirtualLast,
  };   
//+------------------------------------------------------------------+
//|Requested ranges for periods in day count(left range)             |
//+------------------------------------------------------------------+
enum ENUM_RequestRange
  {
   rDay=10,
   rWeek=30,
   rMonth=90,
   rQuarter=300,
   rMinimumSessionMinutes=60,        //Minimum session minutes foe ProcessDay, If minutes < 60 then this day skips
   rMaxDaysWithoutMinutes=30,        //Maximum days without minutes(<rMinimumSessionMinutes)
   rMaximumRequestTrysCount=100,     //Maximum trys count to get requested CopyArrays (Price\Times\Spreads)
   rShifted_fwd_Seconds=300,         //Shifted End Of T (5 min =300 seconds, if closes in 23:50)
   rShifted_fwd_Hours=12,            //Shift hours for the next day                                   
   rFnp_day=1,                       //For searching NextPeriod (increments by day)
   rFnp_week=3,
   rFnp_month=2,
   rFnp_quarter=1,
  };
//+------------------------------------------------------------------+
//| Quant Modes for All ticks(real ticks) MT5 Setup                  |
//+------------------------------------------------------------------+
enum ENUM_QuantMode
  {
   None,             // Calculate All ticks
   CloseOnly,        // Only Close Price in 59 second
   OpenClose,        // Open and Close Prices(0,59)
   MT5_OHLC,         // MT5 OHLC
   Every_10,         // Every 10 seconds
   SmartMode,        // SmartMode
  };
//+------------------------------------------------------------------+
//| Compounding (Dynamic or Maximal Only)                            |
//+------------------------------------------------------------------+
enum ENUM_AutoLot
  {
   Disabled,
   Dynamic,
   MaximalOnly
  };
//+------------------------------------------------------------------+
//| Prediction Period                                                |
//+------------------------------------------------------------------+
enum ENUM_myPredictPeriod
  {
   Day,
   Week,
   Month,
   Quarter
  };
//+------------------------------------------------------------------+
//| OHLC Mode in Emulation                                           |
//+------------------------------------------------------------------+
enum ENUM_EMUL_OHLC_PRICE
  {
   IND_OHLC,      //Ind OHLC prices(4)
   IND_CLOSE,     //Ind Only Close prices(1)
   FEED_OHLC,   //OHLC own Volume
   FEED_CLOSE,  //Only Close, own Volume
  };
//+------------------------------------------------------------------+
//| Trade  Results                                                   |
//+------------------------------------------------------------------+
enum ENUM_TradeResults
  {
   TRR_DONE=0,
   TRR_CANT_COPY_ARR=-1,
   TRR_NOT_INIT_EMUL=-2,
   TRR_CANT_CONVERT_OHLC_TO_ROW=-3,
   TRR_BAD_SYMBOL_POINT=-4,
  };
//+------------------------------------------------------------------+
//| Open Position Trading rules  Emulated                            |
//+------------------------------------------------------------------+
enum ENUM_EMUL_OpenRule
  {
   OpenTR_POMI
  };
//+------------------------------------------------------------------+
//| Auto Close Trading rules   Emulated                              |
//+------------------------------------------------------------------+
enum ENUM_EMUL_CloseRule
  {
   CloseTR_DcSpread
  };
//+------------------------------------------------------------------+
//| CK SIGNALS                                                       |
//+------------------------------------------------------------------+
enum ENUM_CK_SIGNALS
  {
   //Constants for Ck signals:
   CkArrayBoundErr=-5,
   Ck=-4,
   CkDefaultErr=-3,
   CkUnknownTR=-2,
   CkNoSignal=-1,
   CkBuy1=0,
   CkSell4=1,
   CkBuySell14=2,
   CkSingularityBuy=3,
   CkSingularitySell=4,
   Ck_F_Singularity_Buy=5,
   Ck_F_Singularity_Sell=6,
   Ck_F1_SingularityBuySell=7,
   Ck_Beta_Singularity_Buy=8,
   Ck_Beta_Singularity_Sell=9,
   Ck_F1_Singularity_Buy=10,
   Ck_F1_Singularity_Sell=11,
   Ck_SS_SleepMarket=12,
   Ck_FS_Singularity_Buy=13,
   Ck_FS_Singularity_Sell=14,
   Ck_F1S_Singularity=15,
   Ck_Gamma_Singularity_Buy,
   Ck_Gamma_Singularity_Sell,
   Ck_Hybrid_F_F1_Buy,
   Ck_Hybrid_F_F1_Sell,
   Ck_Hybrid_F_Gamma_Buy,
   Ck_Hybrid_F_Gamma_Sell,
  };
//+------------------------------------------------------------------+
//| Trading Rule for Ck      T-ticks                                 |
//+------------------------------------------------------------------+
enum ENUM_TRCK
  {
   CK_TR1,
   CK_TR4,
   CK_TR14,
   CK_TR18_0330_Virt,
   CK_TR18_0330_Orig,//With Abs on A,B (For Billions)
   CK_TR_0711,
   CK_TR_0722,
   CKT_0808JPY,
   CKT_20160918_USDX,
   CKT_20161009_EURUSD,
   CKT_20161009_USDJPY,
   CKT_20161104_USDCHF,
   CKT_20161120_USDCHF,
   CKT_20161122_USDCHF,
   CKT_20161105_GBPUSD,
   CKT_20161111_GBPUSD,
   CKT_20161125_GBPUSD,
   CKT_20161126_GBPUSD,
   CKT_20161130_GBPUSD,
   CKT_20161130a_GBPUSD,
   CKT_D_20161225_EURUSD,
   CKT_D_20170311_USDCHF,
  };
//RealTime Open TR (BBB->CkBuy,SignalBuy,->OpenBuy)
enum ENUM_RT_OpenRule
  {
   POMI_BBB,
   POMI_BBS,
   POMI_BSB,
   POMI_BSS,
   POM_Z1,//Tick Version 1
   POM_Z2,//Tick Version 2 New Singularities
   POM_Z2_Signal,//Same with pom_signal
   POM_Z3_BBB,//Same as BBB
  };
//RealTime Close TR
enum ENUM_RT_CloseRule
  {
   AutoCloseDcSpread,
   AutoCloseInflectionPoint,
   AutoCloseReverseYY,
   AutoClose_TickDC,
   AutoCloseIP_ReverseYY,
   AutoCloseIP_TickDC,
   AutoCloseReverse_TickDC,
  };
//TCVTR Caterpillar POM Versions
enum ENUM_POM_Versions
  {
   POM_with_out_Signal=1,
   POM_With_Signal=2,
   POM_With_Signal_WO_DIV0=3,
  };
//History Load Results
enum ENUM_HistResults
  {
   HIST_DEFAULT=0,
   HIST_LOCAL_READY=1,
   HIST_TERMINAL_DATA_READY=2,
   HIST_LOAD_FROM_INDICATOR=-1,
   HIST_TOO_OLD_SERVER_DATA=-2,
   HIST_BARS_MUCH_MORE_TERMINAL=-3,
   HIST_BARS_COPY_ERR=-4,
   HIST_TRYS_OUT=-5,
   HIST_TRYS_ISSTOPPED=-6,
   HIST_SET_TIMESERIES_ERR=-7,
   HIST_CANT_COPY_ALLHIST_TIMES=-8,
   HIST_CANT_RESIZE_ARRAY=-9,
   HIST_DATA_NOT_FOUND=-10,
   HIST_DATA_NOT_INITIALISED=-11,
   HIST_DB_IS_EMTPY=-12,
   HIST_DATA_NOT_PROCESSED=-13,
   HIST_UNKNOWN_SYMBOL=-14,
   HIST_STOPDATE_BEFORE_STARTDATE=-15,
   HIST_REQUESTED_DATE_NOT_EXIST_IN_DB=-16,
   HIST_CANT_COPY_ALLHIST_RATES=-17,
   HIST_CANT_COPY_ALLHIST_SPREADS=-18,
   HIST_MRS_COUNT_NOT_IDENTICAL=-19,
   HIST_MRS_FIRST_MINUTE_NOT_IDENTICAL=-20,
   HIST_MRS_LAST_MINUTE_NOT_IDENTICAL=-21,
   HIST_CANT_CONNECT_INDICATOR=-22,
   HIST_CANT_COPY_IND_BUFFER=-23,
   HIST_CANT_COPY_RATES=-24,
   HIST_CANT_COPY_SPREADS=-25,
   HIST_DATA_NOT_IDENTICAL=-26,
  };
//+------------------------------------------------------------------+
// Massive SetAsSeries                                               |
//+------------------------------------------------------------------+ 
bool MassiveSetAsSeries(STRUCT_Priming &Priming)
  {
   bool res=false;
//Dc
   ArraySetAsSeries(Priming.Dc_Open,true);
   ArraySetAsSeries(Priming.Dc_High,true);
   ArraySetAsSeries(Priming.Dc_Low,true);
   ArraySetAsSeries(Priming.Dc_Close,true);
//First
   ArraySetAsSeries(Priming.First_Open,true);
   ArraySetAsSeries(Priming.First_High,true);
   ArraySetAsSeries(Priming.First_Low,true);
   ArraySetAsSeries(Priming.First_Close,true);
//Pom
   ArraySetAsSeries(Priming.Pom_Open,true);
   ArraySetAsSeries(Priming.Pom_High,true);
   ArraySetAsSeries(Priming.Pom_Low,true);
   ArraySetAsSeries(Priming.Pom_Close,true);
//Signal
   ArraySetAsSeries(Priming.Signal_Open,true);
   ArraySetAsSeries(Priming.Signal_High,true);
   ArraySetAsSeries(Priming.Signal_Low,true);
   ArraySetAsSeries(Priming.Signal_Close,true);
//Rates
   ArraySetAsSeries(Priming.Rates,true);
//Spread
   ArraySetAsSeries(Priming.Spread,true);

//If Ok
   res=true;
   return(res);
  }//End Of MassiveSetAsSeries
//+------------------------------------------------------------------+
// Compare 2 arrays by elements                                      |
//+------------------------------------------------------------------+ 
bool CompareDoubleArrays(const double &Arr1[],const double &Arr2[])
  {
//Get size of 2 arrays
   int ArrSize1 = ArraySize(Arr1);
   int ArrSize2 = ArraySize(Arr2);

/* DO NOT REMOVE - PREVENT FOR BUG!!!
//Check identical size
   if(ArrSize1!=ArrSize2)
     {
      Print(__FUNCTION__+" Arrays don`t much in size!!");
      return(false);
     }
*/

//Compare every element in arrays 
   for(int i=0;i<ArrSize1;i++)
     {
      if(Arr1[i]!=Arr2[i])
        {
         Print(__FUNCTION__+" Arrays don`t much!! "+IntegerToString(i));
         return(false);
        }
     }//End of for

//If Ok
   return(true);
  }//End of compare arrays
//+------------------------------------------------------------------+
//| Draw Objects                                                     |
//+------------------------------------------------------------------+
bool DrawObject(const double Price,const ENUM_OBJECT DrawObject,const long DrawColor)
  {
//Create
   ObjectCreate(0,IntegerToString(draw_object_counter),DrawObject,0,TimeCurrent(),Price);

//Set Color
   ObjectSetInteger(0,IntegerToString(draw_object_counter),OBJPROP_COLOR,DrawColor);

   draw_object_counter++;
   return(true);
  }//END OF DRAW Objects

//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
