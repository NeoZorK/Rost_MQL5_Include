//+------------------------------------------------------------------+
//|                                                      RStructs.mqh|
//|                             Copyright 2016, Shcherbyna Rostyslav |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Shcherbyna Rostyslav"
#property link      ""
#property version   "1.41"

#include <Tools\DateTime.mqh>

/*
Include all structures and global constants
*/
/*
+++++CHANGE LOG+++++
1.41 28.05.2016--Minor version with ability to Export OHLC to CSV & BIN
1.4 20.05.2016--Stable with AutoCompounding
1.3 19.05.2016--Stable, without Copy Arrays
1.2 15.05.2016--Version with Commented Addition code
1.1 6.05.2016 --Version with working RStructs (separate file)
--Ver 1.0 Stable
*/

//CONSTANTS
const uint MAGIC_IB=3000000;
const uint MAGIC_IS=3100000;
const uchar OP_BUY=0;
const uchar OP_SELL=1;
//Indicator POM3 Signals:
const char Ind_Buy = 1;
const char Ind_Sell=-1;
const int BUY1=1005;
const int SELL1=2006;
const char HighFirst= 1;
const char LowFirst = -1;
const char EqualFirst=0; //High==Open or other Private Case
const ushort     inpDeltaC_koef=1000; //Dc * 
                                      //
//Constants for Ck signals:
const char CkNoSignal=-1;
const char CkBuy1=0;
const char CkSell4=1;
const char CkBuySell14=2;
const char CkSingularityBuy=3;
const char CkSingularitySell=4;
//---Primings structs
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
   ALL_OHLC,      //Use OHLC prices (4)
   ALL_Close,     //Use only Close prices in Open\Close positions
   OHLC_onOpenOnly,   //Use OHLC on Open, and CloseValues on Close positions
   OHLC_onCloseOnly,  //Use OHLC on Close, and CloseValues on Open positions
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
//| Trading Rule for Ck                                              |
//+------------------------------------------------------------------+
enum ENUM_TRCK
  {
   CK_TR18_0330_Virt
  };
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
