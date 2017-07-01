//+------------------------------------------------------------------+
//|                                                     IDensity.mqh |
//|                             Copyright 2017, Shcherbyna Rostyslav |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Shcherbyna Rostyslav"
#property link      ""
#property version   "1.0"
//+------------------------------------------------------------------+
//| Who First                                                        |
//+------------------------------------------------------------------+
enum ENUM_WF
  {
   Equal=0,
   LowFirst=-1,
   HighFirst=1,
  };
//+------------------------------------------------------------------+
//| Density Status Enum                                              |
//+------------------------------------------------------------------+
enum ENUM_DENSITY_STATUS
  {
   ClassInitialised,              //Class Initialised
   InitReady,                     // Init Ready
   Reseted,                       // Reset private members
   FilledBottle2,                 // Filled Bottle 2
   DensityReady,                  // Density Ready
   CalcError,                     // Error in Calculation
   WaitingNewTicks,               // Waiting..
   ClassDestroyed,                // Class Destructor
  };
//+------------------------------------------------------------------+
//| POM Vector ENUM                                                  |
//+------------------------------------------------------------------+
enum ENUM_POM_VECTOR
  {
   NONE=0,
   Trend=1,
   Flat=-1,
  };
//+------------------------------------------------------------------+
//| Result Struct                                                    |
//+------------------------------------------------------------------+
struct STRUCT_RESULT_DENSITY
  {
   double            pom0;          // Pom in  Bottle 0
   double            pom1;          // Pom in  Bottle 1
   double            pom2;          // Pom in  Bottle 2
   double            y1;            // First derivative
   double            y2;            // Second derivative
   double            density;       // Tick Density
   ulong             dt1;           // Delta Time Captured ticks in bottle 1
   ulong             dt2;           // Delta Time Captured ticks in bottle 2
  };
//+------------------------------------------------------------------+
//| Init Density Struct                                              |
//+------------------------------------------------------------------+
struct STRUCT_INIT_DENSITY
  {
   ENUM_POM_VECTOR   pom_vector;              // POM Vector Trend\Flat
   int               ticks_bottle_size;       // One Bottle Tick Size
   char              pom_buy;                 // POM Buy
   char              pom_sell;                // POM Sell
  };
//+------------------------------------------------------------------+
//| OHLC Struct                                                      |
//+------------------------------------------------------------------+
struct STRUCT_OHLC
  {
   double            Open;
   double            High;
   double            Low;
   double            Close;
  };
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
