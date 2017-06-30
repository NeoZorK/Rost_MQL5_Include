//+------------------------------------------------------------------+
//|                                                     IDensity.mqh |
//|                             Copyright 2017, Shcherbyna Rostyslav |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Shcherbyna Rostyslav"
#property link      ""
#property version   "1.0"
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
   Trend=1,
   Flat=-1,
   NONE=0,
  };
//+------------------------------------------------------------------+
//| Init Density Structure                                           |
//+------------------------------------------------------------------+
struct STRUCT_INIT_DENSITY
  {
   ENUM_POM_VECTOR   pom_vector;              // POM Vector Trend\Flat
   int               ticks_bottle_size;       // One Bottle Tick Size
   char              pom_buy;                 // POM Buy
   char              pom_sell;                // POM Sell
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
