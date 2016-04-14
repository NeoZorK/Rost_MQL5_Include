//+------------------------------------------------------------------+
//|                                                       RTrade.mqh |
//|                              Copyright 2016,Shcherbyna Rostyslav |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Shcherbyna Rostyslav"
#property link      ""
#property version   "1.00"

#include <Tools\DateTime.mqh>

//CONSTANTS
const int BUY1=1005;
const int SELL1=2006;
const char HighFirst= 1;
const char LowFirst = -1;
const char EqualFirst=0; //High==Open or other Private Case
const ushort     inpDeltaC_koef=1000; //Dc * 
                                      //Constants for Ck signals:
const char CkNoSignal=-1;
const char CkBuy1=0;
const char CkSell4=1;
const char CkBuySell14=2;
const char CkSingularityBuy=3;
const char CkSingularitySell=4;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//Trade  Results
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
//------GLOBAL VARIABLES

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*
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
   //Caterpillar

   //Other   
   bool              m_debug;
   ENUM_TradeResults m_Result;
   //Current Priming1=true or Priming2=false
   bool              m_CurrentPriming;
   //Elements count in each array (rates,spreads,buffers)
   uint              m_Total_Minutes_in_period;
   //---Emulate Primings
   MqlRates          m_arr_Rates_P1[];
   MqlRates          m_arr_Rates_P2[];
   int               m_arr_Spread_P1[];
   int               m_arr_Spread_P2[];
   double            m_arr_Signal_P1[];
   double            m_arr_Signal_P2[];
   double            m_arr_First_P1[];
   double            m_arr_First_P2[];
   double            m_arr_Pom_P1[];
   double            m_arr_Pom_P2[];
   double            m_arr_dC_P1[];
   double            m_arr_dC_P2[];
   //OHLC in a row
   double            m_arr_RowRates[];

   //Methods
   //Transform primins ohlc rates to row
   bool              m_TransformPriming(void);
   //Convert OHLC to price array, returns Elements Count
   uint              m_OHLC_To_Row(const MqlRates &OHLC[]);
   //Virtual Indicator POM
   bool              m_EMUL_VirtualCaterpillar(const uint CurrentIteration,double &Pom,double &Dc,char &Signal,char &WhoFirst);
   //Who First 0,-1,+1 |No,Low,High
   char              m_EMUL_WhoFirst(const uint iter_start);
   //TR Close Positions
   bool              m_EMUL_AutoCloseDCSpread(const double PositionProfit,const double Dc,const uint Spread,const double Commission);
   double            m_EMUL_CalculateDc(const uint Iteration);
   //TR Open Positions(-1,-2=none,-1=sell,+1=buy)
   int               m_EMUL_TR_Caterpillar(const char Case,const int IterationNum);
   //TR Open OHLC Caterpillar
   int               m_EMUL_TR_Caterpillar(const char Case,const int IterationNum,const double Current_OHLC_Price);
   bool              m_EMUL_CloseRule(const ENUM_EMUL_CloseRule CloseRuleNum,const double CurrentProfit,const double CurrentDC,const uint CurrentSpread);
   int               m_EMUL_OpenRule(const ENUM_EMUL_OpenRule OpenRuleNum,const char Case,const int IterationNum,const double Current_OHLC_Price);
   //Calculate Ck Prediction 0,1,2 : 1,4,14
   char              m_BUILD_CK_TR18_0330_Virt(const bool USDFirst);
public:
                     RTrade();
                    ~RTrade();
   //Is Emulation Initialised ?
   bool              _isInitialised() const       {return(m_initialised_emul);}

   //Real Trade                   
   bool              _Init(const string pair,const string path_to_ind,const uchar bottlesize,
                           const datetime from_date,const datetime to_date,const bool debug);

   bool              CheckSpread(const uint MaxSpread,const uint CurrentSpread);
   //For compounding
   double            CalcLot();

   //Init for Emulating                        
   bool              _InitPriming(const bool Priming1,MqlRates &arr_Rates[],int &arr_Spreads[],
                                  double &arr_Signals[],double &arr_Firsts[],double &arr_Poms[],double &arr_Dc[]);
   //Emulate                         
   bool              _InitEmul(const ENUM_EMUL_CloseRule CloseRuleNum,const ENUM_EMUL_OpenRule OpenRuleNum,const int MaxSpread,
                               const double PomBuy,const double PomSell,const double PomKoef,const double Comission);

   //Emulate trading inside Priming1 & 2:
   bool              Emulate_Trading1();
   bool              Emulate_Trading2();

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
   ArraySetAsSeries(m_arr_First_P1,true);
   ArraySetAsSeries(m_arr_First_P2,true);
   ArraySetAsSeries(m_arr_Pom_P1,true);
   ArraySetAsSeries(m_arr_Pom_P2,true);
   ArraySetAsSeries(m_arr_Rates_P1,true);
   ArraySetAsSeries(m_arr_Rates_P2,true);
   ArraySetAsSeries(m_arr_Signal_P1,true);
   ArraySetAsSeries(m_arr_Signal_P2,true);
   ArraySetAsSeries(m_arr_Spread_P1,true);
   ArraySetAsSeries(m_arr_Spread_P2,true);
   ArraySetAsSeries(m_arr_dC_P1,true);
   ArraySetAsSeries(m_arr_dC_P2,true);
   m_Total_Minutes_in_period=0;
   m_CurrentPriming=0;
   m_debug=false;

//Each 2 simulated primings = 2
   m_simulated_primings_total=0;

//Add +1 Cell to Dynamic Array of Primings Omega
   ArrayResize(m_arr_sim_q,ArraySize(m_arr_sim_q)+1);
  }
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
  }
//+------------------------------------------------------------------+
//| CopyArrays to Local                                              |
//+------------------------------------------------------------------+
bool RTrade::_InitPriming(const bool Priming1,MqlRates &arr_Rates[],int &arr_Spreads[],double &arr_Signals[],
                          double &arr_Firsts[],double &arr_Poms[],double &arr_Dc[])
  {
//Start speed measuring
   uint Start_measure=GetTickCount();

//if Priming 1
   if(Priming1)
     {
      if(ArrayCopy(m_arr_Rates_P1,arr_Rates,0,0,WHOLE_ARRAY)<=0){m_Result=-1; return(false);}
      if(ArrayCopy(m_arr_Spread_P1,arr_Spreads,0,0,WHOLE_ARRAY)<=0){m_Result=-1; return(false);}
      if(ArrayCopy(m_arr_Signal_P1,arr_Signals,0,0,WHOLE_ARRAY)<=0){m_Result=-1; return(false);}
      if(ArrayCopy(m_arr_First_P1,arr_Firsts,0,0,WHOLE_ARRAY)<=0){m_Result=-1; return(false);}
      if(ArrayCopy(m_arr_Pom_P1,arr_Poms,0,0,WHOLE_ARRAY)<=0){m_Result=-1; return(false);}
      if(ArrayCopy(m_arr_dC_P1,arr_Dc,0,0,WHOLE_ARRAY)<=0){m_Result=-1; return(false);}
      m_CurrentPriming=1;

      //Save total minutes in period
      m_Total_Minutes_in_period=ArraySize(m_arr_Rates_P1);
     }
   else//Priming 2
     {
      if(ArrayCopy(m_arr_Rates_P2,arr_Rates,0,0,WHOLE_ARRAY)<=0){m_Result=-1; return(false);}
      if(ArrayCopy(m_arr_Spread_P2,arr_Spreads,0,0,WHOLE_ARRAY)<=0){m_Result=-1; return(false);}
      if(ArrayCopy(m_arr_Signal_P2,arr_Signals,0,0,WHOLE_ARRAY)<=0){m_Result=-1; return(false);}
      if(ArrayCopy(m_arr_First_P2,arr_Firsts,0,0,WHOLE_ARRAY)<=0){m_Result=-1; return(false);}
      if(ArrayCopy(m_arr_Pom_P2,arr_Poms,0,0,WHOLE_ARRAY)<=0){m_Result=-1; return(false);}
      if(ArrayCopy(m_arr_dC_P2,arr_Dc,0,0,WHOLE_ARRAY)<=0){m_Result=-1; return(false);}
      m_CurrentPriming=2;

      //Save total minutes in period
      m_Total_Minutes_in_period=ArraySize(m_arr_Rates_P2);
     }

//Transform Primings ohlc rates to rows
   if(!m_TransformPriming())
     {
      return(false);
     }

//Stop speed measuring     
//  uint Stop_measuring=GetTickCount()-Start_measure;
//  PrintFormat("Init Primings complete in %d ms",Stop_measuring);

//If Ok
   m_Result=0;
   return(true);
  }
//+------------------------------------------------------------------+
//| Main Emulating Priming 1                                         |
//+------------------------------------------------------------------+
bool RTrade::Emulate_Trading1()
  {
//If not initialised, then exit
   if(!m_initialised_emul)
     {
      m_Result=-2;
      return(false);
     }

//Start speed measuring 
   uint Start_measure=GetTickCount();

//Set Current Priming1
   m_CurrentPriming=true;

//Priming length
   int ArrSize=ArraySize(m_arr_Rates_P1);

//+++++EMULATION++++++\\
//+++++EMULATION++++++\\
//+++++EMULATION++++++\\

/*
      //Local Caterpillar params
      double LocalPOM=0;
      double LocalDC=0;
      char   LocalWhoFirst=0;
      char   LocalSignal=0;
*/
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

      //Current Rate 
      double CurrentOHLC=0;

      //From first day 00:00 to 23:50 last day in Priming1
      for(int i=ArrSize-1;i>-1;i--)
        {
         // Print(IntegerToString(i)+" First: "+TimeToString(m_arr_Rates_P1[ArraySize(m_arr_Rates_P1)-1].time,TIME_DATE|TIME_MINUTES));
         //Print(IntegerToString(i)+" Last: "+TimeToString(m_arr_Rates_P1[i].time,TIME_DATE|TIME_MINUTES));

/*
            //Reset parmas
            LocalPOM=0;
            LocalDC=0;
            LocalWhoFirst=0;
            LocalSignal=0;

            //

            //Wait for minimum Indicator Values(3 bottles * 4 price in each bottle)
          if(i>i-(int)m_all_bottle_size_emul) //or from (4*3*m_bottle_size_emul)-1 ?
              {
               continue;
              }

            //0.Build Virtual POM,dc,whofirst,signal
            if(!m_EMUL_VirtualCaterpillar(i,LocalPOM,LocalDC,LocalSignal,LocalWhoFirst))
              {
               continue;
              }
*/
         //0. Circle for OHLC prices (4))
         for(int OHLC_i=0;OHLC_i<4;OHLC_i++)
           {
            //Set Current Price
            switch(OHLC_i)
              {
               case  0:CurrentOHLC=m_arr_Rates_P1[i].open;  break;
               case  1:CurrentOHLC=m_arr_Rates_P1[i].high;  break;
               case  2:CurrentOHLC=m_arr_Rates_P1[i].low;   break;
               case  3:CurrentOHLC=m_arr_Rates_P1[i].close; break;

               default:
                  break;
              }//END OF SWITCH

            //1. Check Open Rule 
            int OTR_RESULT=m_EMUL_OpenRule(m_open_rule_num_emul,Case,i,CurrentOHLC);

            //2. Pass first 3 bars for DC
            if(i>ArrSize-3) continue;

            //2.1 Calculate DC
            Calculated_Dc=0;
            Calculated_Dc= m_EMUL_CalculateDc(i)*inpDeltaC_koef;

            //3. Check if pos opened, try to close
            if(BUY_OPENED || SELL_OPENED)
              {
               //3.1 Calculate Position Profit for buy
               if(BUY_OPENED)
                 {
                  PositionProfit=(m_arr_Rates_P1[i].close-BUY_OPENED_PRICE)/m_pair_point;
                 }

               //3.2 Calculate Position Profit for sell
               if(SELL_OPENED)
                 {
                  PositionProfit=(SELL_OPENED_PRICE-m_arr_Rates_P1[i].close)/m_pair_point;
                 }

               //3.3 Check Close Rule (DONT WORK)
               bool CTR_RESULT=m_EMUL_CloseRule(m_close_rule_num_emul,PositionProfit,Calculated_Dc,m_arr_Spread_P1[i]);

               //3.4 If need to Close position
               if(CTR_RESULT)
                 {
                  BUY_OPENED=false;
                  SELL_OPENED=false;
                  BUY_OPENED_PRICE=0;
                  SELL_OPENED_PRICE=0;
                  PositionProfit=0;
                  continue;
                 }
              }//END OF TRY TO CLOSE

            //4. Check Spread (if > max then next iteration)
            if(CheckSpread(m_max_spread_emul,m_arr_Spread_P1[i])) continue;

            //5. Check if NOSIGNAL then exit
            if(OTR_RESULT<=0) continue;

            //6. +++OPEN POSITION+++

            //If Case14 both can be opened
            if(BUY_OPENED || SELL_OPENED) continue;

            //If Buy
            if(OTR_RESULT==BUY1)
              {
               // Check If already opened Position exist, 
               if(BUY_OPENED) continue;

               BUY_OPENED_PRICE=m_arr_Rates_P1[i].close;
               BUY_Signal_Count++;
               BUY_OPENED=true;
               //  Print("BUY "+TimeToString(m_arr_Rates_P1[i].time)+" "+DoubleToString(Calculated_Dc));
               continue;
              }//END OF BUY

            //If Sell
            if(OTR_RESULT==SELL1)
              {
               //Check If already opened Position exist, 
               if(SELL_OPENED) continue;

               SELL_OPENED_PRICE=m_arr_Rates_P1[i].close;
               SELL_Signal_Count++;
               SELL_OPENED=true;
               //  Print("SELL "+TimeToString(m_arr_Rates_P1[i].time)+" "+DoubleToString(Calculated_Dc));
               continue;
              }//END OF SELL

           }//END OF OHLC CIRCLE (4 prices)

        }//END OF CASE

      //Fill Omega Structures for Priming1:
      switch(Case)
        {
         case  0: m_arr_sim_q[m_simulated_primings_total].P1_Q1_Simul=BUY_Signal_Count;  break; // Case1
         case  1: m_arr_sim_q[m_simulated_primings_total].P1_Q4_Simul=SELL_Signal_Count;  break; // Case4
         case  2: m_arr_sim_q[m_simulated_primings_total].P1_Q14_Simul=BUY_Signal_Count+SELL_Signal_Count;  break; // Case14

         default:
            break;
        }//END OF FILLING Priming1 Omega Structures

      //      Print("Priming 1, Case "+IntegerToString(Case)+" Buys: "+IntegerToString(BUY_Signal_Count));
      //      Print("Priming 1, Case "+IntegerToString(Case)+" Sells: "+IntegerToString(SELL_Signal_Count));
     }//END OF ALL CASES

//   Print("Priming 1, All Cases Completed");

//8. Count Opened Positions & NP priming1

//Stop speed measuring   
// if(m_debug)
// {
// uint Stop_measuring=GetTickCount()-Start_measure;
// PrintFormat("Emulating Priming1 complete in %d ms",Stop_measuring);
//  }

//If Ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Main Emulating Priming 2                                         |
//+------------------------------------------------------------------+
bool RTrade::Emulate_Trading2()
  {
//If not initialised, then exit
   if(!m_initialised_emul)
     {
      m_Result=-2;
      return(false);
     }

//Start speed measuring 
   uint Start_measure=GetTickCount();

//Set Current Priming2
   m_CurrentPriming=false;

//Priming length
   int ArrSize=ArraySize(m_arr_Rates_P2);

//+++++EMULATION++++++\\
//+++++EMULATION++++++\\
//+++++EMULATION++++++\\

/*
      //Local Caterpillar params
      double LocalPOM=0;
      double LocalDC=0;
      char   LocalWhoFirst=0;
      char   LocalSignal=0;
*/
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

      //Current Rate 
      double CurrentOHLC=0;

      //From first day 00:00 to 23:50 last day in Priming1
      for(int i=ArrSize-1;i>-1;i--)
        {
         // Print(IntegerToString(i)+" First: "+TimeToString(m_arr_Rates_P1[ArraySize(m_arr_Rates_P1)-1].time,TIME_DATE|TIME_MINUTES));
         //Print(IntegerToString(i)+" Last: "+TimeToString(m_arr_Rates_P1[i].time,TIME_DATE|TIME_MINUTES));

/*
            //Reset parmas
            LocalPOM=0;
            LocalDC=0;
            LocalWhoFirst=0;
            LocalSignal=0;

            //

            //Wait for minimum Indicator Values(3 bottles * 4 price in each bottle)
          if(i>i-(int)m_all_bottle_size_emul) //or from (4*3*m_bottle_size_emul)-1 ?
              {
               continue;
              }

            //0.Build Virtual POM,dc,whofirst,signal
            if(!m_EMUL_VirtualCaterpillar(i,LocalPOM,LocalDC,LocalSignal,LocalWhoFirst))
              {
               continue;
              }
*/
         //0. Circle for OHLC prices (4))
         for(int OHLC_i=0;OHLC_i<4;OHLC_i++)
           {
            //Set Current Price
            switch(OHLC_i)
              {
               case  0:CurrentOHLC=m_arr_Rates_P2[i].open;  break;
               case  1:CurrentOHLC=m_arr_Rates_P2[i].high;  break;
               case  2:CurrentOHLC=m_arr_Rates_P2[i].low;   break;
               case  3:CurrentOHLC=m_arr_Rates_P2[i].close; break;

               default:
                  break;
              }//END OF SWITCH

            //1. Check Open Rule 
            int OTR_RESULT=m_EMUL_OpenRule(m_open_rule_num_emul,Case,i,CurrentOHLC);

            //2. Pass first 3 bars for DC
            if(i>ArrSize-3) continue;

            //2.1 Calculate DC
            Calculated_Dc=0;
            Calculated_Dc= m_EMUL_CalculateDc(i)*inpDeltaC_koef;

            //3. Check if pos opened, try to close
            if(BUY_OPENED || SELL_OPENED)
              {
               //3.1 Calculate Position Profit for buy
               if(BUY_OPENED)
                 {
                  PositionProfit=(m_arr_Rates_P2[i].close-BUY_OPENED_PRICE)/m_pair_point;
                 }

               //3.2 Calculate Position Profit for sell
               if(SELL_OPENED)
                 {
                  PositionProfit=(SELL_OPENED_PRICE-m_arr_Rates_P2[i].close)/m_pair_point;
                 }

               //3.3 Check Close Rule (DONT WORK)
               bool CTR_RESULT=m_EMUL_CloseRule(m_close_rule_num_emul,PositionProfit,Calculated_Dc,m_arr_Spread_P2[i]);

               //3.4 If need to Close position
               if(CTR_RESULT)
                 {
                  BUY_OPENED=false;
                  SELL_OPENED=false;
                  BUY_OPENED_PRICE=0;
                  SELL_OPENED_PRICE=0;
                  PositionProfit=0;
                  continue;
                 }
              }//END OF TRY TO CLOSE

            //4. Check Spread (if > max then next iteration)
            if(CheckSpread(m_max_spread_emul,m_arr_Spread_P2[i])) continue;

            //5. Check if NOSIGNAL then exit
            if(OTR_RESULT<=0) continue;

            //6. +++OPEN POSITION+++

            //If Case14 both can be opened
            if(BUY_OPENED || SELL_OPENED) continue;

            //If Buy
            if(OTR_RESULT==BUY1)
              {
               // Check If already opened Position exist, 
               if(BUY_OPENED) continue;

               BUY_OPENED_PRICE=m_arr_Rates_P2[i].close;
               BUY_Signal_Count++;
               BUY_OPENED=true;
               //  Print("BUY "+TimeToString(m_arr_Rates_P2[i].time)+" "+DoubleToString(Calculated_Dc));
               continue;
              }//END OF BUY

            //If Sell
            if(OTR_RESULT==SELL1)
              {
               //Check If already opened Position exist, 
               if(SELL_OPENED) continue;

               SELL_OPENED_PRICE=m_arr_Rates_P2[i].close;
               SELL_Signal_Count++;
               SELL_OPENED=true;
               //  Print("SELL "+TimeToString(m_arr_Rates_P2[i].time)+" "+DoubleToString(Calculated_Dc));
               continue;
              }//END OF SELL

           }//END OF OHLC CIRCLE (4 prices)

        }//END OF CASE

      //Fill Omega Structures for Priming2:
      switch(Case)
        {
         case  0: m_arr_sim_q[m_simulated_primings_total].P2_Q1_Simul=BUY_Signal_Count;  break; // Case1
         case  1: m_arr_sim_q[m_simulated_primings_total].P2_Q4_Simul=SELL_Signal_Count;  break; // Case4
         case  2: m_arr_sim_q[m_simulated_primings_total].P2_Q14_Simul=BUY_Signal_Count+SELL_Signal_Count;  break; // Case14

         default:
            break;
        }//END OF FILLING Priming2 Omega Structures

      //      Print("Priming 2, Case "+IntegerToString(Case)+" Buys: "+IntegerToString(BUY_Signal_Count));
      //      Print("Priming 2, Case "+IntegerToString(Case)+" Sells: "+IntegerToString(SELL_Signal_Count));
     }//END OF ALL CASES
//   Print("Priming 2, All Cases Completed");

//8. Count Opened Positions & NP priming1

//Stop speed measuring   
// if(m_debug)
// {
//  uint Stop_measuring=GetTickCount()-Start_measure;
//  PrintFormat("Emulating Priming2 complete in %d ms",Stop_measuring);
//  }

//Add +1 Cell to Dynamic Array of Primings Omegas
   ArrayResize(m_arr_sim_q,ArraySize(m_arr_sim_q)+1);

//Always increase by 1 this counter, otherwise program writes to [0]
   m_simulated_primings_total++;

//If Ok
   return(true);
  }//END OF EMULATING PRIMING 2  
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
  }
//+------------------------------------------------------------------+
//| Emulated AutoClose Dc+Spread+Commisstion                         |
//+------------------------------------------------------------------+
bool  RTrade::m_EMUL_AutoCloseDCSpread(const double PositionProfit,const double Dc,const uint Spread,const double Commission)
  {// CLose if NetProfit >= |dC|+spread+commision
   bool res=false;

//Check for close
   if(PositionProfit>=MathAbs(Dc*10)+Spread+Commission)
     {
      //Close Position
      return(true);
     }

   return(res);
  }
//+------------------------------------------------------------------+
//| Emulated Choosing Close Rule                                     |
//+------------------------------------------------------------------+
bool  RTrade::m_EMUL_CloseRule(const ENUM_EMUL_CloseRule CloseRuleNum,const double CurrentProfit,const double CurrentDC,const uint CurrentSpread)
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
  }
//+------------------------------------------------------------------+
//| Emulated Choosing Open Rule                                      |
//+------------------------------------------------------------------+
int  RTrade::m_EMUL_OpenRule(const ENUM_EMUL_OpenRule OpenRuleNum,const char Case,const int IterationNum,const double Current_OHLC_Price)
  {
//TR_RESULT  
   int TR_RES=-1;

   if(OpenRuleNum<0)
     {
      return(-2);
     }

   switch(OpenRuleNum)
     {
      case  0:TR_RES=m_EMUL_TR_Caterpillar(Case,IterationNum);

      break;
      default:
         break;
     }
//If Ok
   return(TR_RES);
  }
//+------------------------------------------------------------------+
//| Emulated Open TR Caterpillar OHLC                                |
//+------------------------------------------------------------------+
int RTrade::m_EMUL_TR_Caterpillar(const char Case,const int IterationNum,const double Current_OHLC_Price)
  {
//Cases: Case0=1,Case1=4,Case2=14
   int i=IterationNum;

   double signal=0;
   double pom=0;
   double whofirst=0;

//Check Primings 1 or 2?
   if(m_CurrentPriming)
     {
      //PRIMING 1
      datetime a=m_arr_Rates_P1[i].time;
      signal=m_arr_Signal_P1[i];
      pom=m_arr_Pom_P1[i];
      whofirst=m_arr_First_P1[i];
     }
   else
     {
      //PRIMING2
      signal=m_arr_Signal_P2[i];
      pom=m_arr_Pom_P2[i];
      whofirst=m_arr_First_P2[i];
     }

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

//If NO Signal
   return(-1);
  }
//+------------------------------------------------------------------+
//| Emulated Open TR Caterpillar                                     |
//+------------------------------------------------------------------+
int RTrade::m_EMUL_TR_Caterpillar(const char Case,const int IterationNum)
  {
//Cases: Case0=1,Case1=4,Case2=14
   int i=IterationNum;

   double signal=0;
   double pom=0;
   double whofirst=0;

//Check Primings 1 or 2?
   if(m_CurrentPriming)
     {
      //PRIMING 1
      datetime a=m_arr_Rates_P1[i].time;
      signal=m_arr_Signal_P1[i];
      pom=m_arr_Pom_P1[i];
      whofirst=m_arr_First_P1[i];

     }
   else
     {
      //PRIMING2
      signal=m_arr_Signal_P2[i];
      pom=m_arr_Pom_P2[i];
      whofirst=m_arr_First_P2[i];
     }

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
  }
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
  }
//+------------------------------------------------------------------+
//| Virtual Caterpillar: POM,WF,SIGNAL,DC                            |
//+------------------------------------------------------------------+
bool RTrade::m_EMUL_VirtualCaterpillar(const uint CurrentIteration,double &Pom,double &Dc,char &Signal,char &WhoFirst)
  {
//Starts from 4*3*bottleSize   

//1. Calculate WhoFirst in Last Bottle
   WhoFirst=m_EMUL_WhoFirst(CurrentIteration);

//2. Calculate POM

//3. Calculate DC 

//If Ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Converts OHLC to row array, returns Elements Count               |
//+------------------------------------------------------------------+
uint RTrade::m_OHLC_To_Row(const MqlRates &OHLC[])
  {
//Get Arr Size
   int ArrSize=ArraySize(OHLC);

//If Err, return 0 
   if(ArrSize<=0) return(0);

//Setup array
   ArraySetAsSeries(m_arr_RowRates,true);
   ArrayResize(m_arr_RowRates,0);

   int j=0;

//Convert
   for(int i=0;i<ArrSize;i++)
     {
      ArrayResize(m_arr_RowRates,ArraySize(m_arr_RowRates)+4);
      m_arr_RowRates[j]=OHLC[i].open;
      m_arr_RowRates[j+1]= OHLC[i].high;
      m_arr_RowRates[j+2]= OHLC[i].low;
      m_arr_RowRates[j+3]= OHLC[i].close;
      j=j+4;
     }

   return(j-4);
  }
//+------------------------------------------------------------------+
//| Transform priming ohlc rates to row                              |
//+------------------------------------------------------------------+
bool RTrade::m_TransformPriming(void)
  {
//For Priming 1
   if(m_CurrentPriming)
     {
      if(m_OHLC_To_Row(m_arr_Rates_P1)<=0)
        {
         m_Result=-3;
         return(false);
        }//end of cant convert
     }//end of priming1
   else
     {
      //For Priming 2
      if(m_OHLC_To_Row(m_arr_Rates_P2)<=0)
        {
         m_Result=-3;
         return(false);
        }//end of cant convert
     }//end of priming2

//If ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Who will be first High or low ? 0,1,2 |No,Low,High               |
//+------------------------------------------------------------------+
char RTrade::m_EMUL_WhoFirst(const uint iter_start)
  {
//If two maximum then get maximum near now()
   uint index_L=ArrayMinimum(m_arr_RowRates,iter_start-m_one_bottle_size_emul,m_one_bottle_size_emul);
   uint index_H=ArrayMaximum(m_arr_RowRates,iter_start-m_one_bottle_size_emul,m_one_bottle_size_emul);

//Private case H==L
//Private case, when many H or L, and don`t know who >
   if(index_H>index_L)  return(HighFirst);
   if(index_H<index_L)  return(LowFirst);
   if(index_H==index_L) return(EqualFirst);

   return(0);

  }//End of who first  
//+------------------------------------------------------------------+
//| Emulate dc by 3 bars forward                                     |
//+------------------------------------------------------------------+
double RTrade::m_EMUL_CalculateDc(const uint Iteration)
  {
   double res=-1;
   uint i=Iteration;

//Pass first 3 bars

//If Priming 1
   if(m_CurrentPriming)
     {
      double r0=m_arr_Rates_P1[i].high-m_arr_Rates_P1[i].low;

      double r2=m_arr_Rates_P1[i+2].high-m_arr_Rates_P1[i+2].low;

      long t1=m_arr_Rates_P1[i+2].tick_volume-m_arr_Rates_P1[i+1].tick_volume;

      double t2=t1*r2;
      if(t2==0)return(res=0); //div 0 exception

      double t3=m_arr_Rates_P1[i+1].close-m_arr_Rates_P1[i+2].close;

      double t4=t3/t2;

      long t6=m_arr_Rates_P1[i+1].tick_volume-m_arr_Rates_P1[i].tick_volume;

      res=t6*t4*r0;
      res= NormalizeDouble(res,5);
     }
   else
     {
      //For Priming 2
      double r0=m_arr_Rates_P2[i].high-m_arr_Rates_P2[i].low;

      double r2=m_arr_Rates_P2[i+2].high-m_arr_Rates_P2[i+2].low;

      long t1=m_arr_Rates_P2[i+2].tick_volume-m_arr_Rates_P2[i+1].tick_volume;

      double t2=t1*r2;
      if(t2==0)return(res=0); //div 0 exception

      double t3=m_arr_Rates_P2[i+1].close-m_arr_Rates_P2[i+2].close;

      double t4=t3/t2;

      long t6=m_arr_Rates_P2[i+1].tick_volume-m_arr_Rates_P2[i].tick_volume;

      res=t6*t4*r0;
      res= NormalizeDouble(res,5);
     }
//If Ok
   return(res);
  }
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
  }
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
  }
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
  }
//+------------------------------------------------------------------+
