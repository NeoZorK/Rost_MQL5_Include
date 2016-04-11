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
  };
//+------------------------------------------------------------------+
//| Open Position Trading rules                                      |
//+------------------------------------------------------------------+
enum ENUM_OpenRule
  {
   OpenTR_POMI
  };
//+------------------------------------------------------------------+
//| Auto Close Trading rules                                         |
//+------------------------------------------------------------------+
enum ENUM_CloseRule
  {
   CloseTR_DcSpread
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
//---Structure for time marks
/*
struct TIMEMARKS
  {
   datetime          P1_Start;
   datetime          P1_Stop;
   datetime          P2_Start;
   datetime          P2_Stop;
   datetime          Now_Start;
   datetime          Now_Stop;
  };
  */
//Array of TimeMarks  
//TIMEMARKS _arr_tm[];
//---Structure for simulated Qs
struct SIMUL_Q
  {
   double            P1_Q1_Simul;
   double            P1_Q4_Simul;
   double            P1_Q14_Simul;
   double            P2_Q1_Simul;
   double            P2_Q4_Simul;
   double            P2_Q14_Simul;
  };
//Array of Simulated Q  
SIMUL_Q _arr_sim_q[];
//---Structure for simulated NP
struct SIMUL_NP
  {
   double            P1_NP1_Simul;
   double            P1_NP4_Simul;
   double            P1_NP14_Simul;
   double            P2_NP1_Simul;
   double            P2_NP4_Simul;
   double            P2_NP14_Simul;
  };
//Array of Simulated NP  
SIMUL_NP _arr_sim_np[];
//------GLOBAL VARIABLES

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*
Netting position:
	AddVolume:
((p1*v1)+(p2*v2)) / (v1+v2)

)

methods:
+buy\sell\none TR_Caterpillar(params)
+bool AutoCloseDCSpread(dc)

+bool Emul_OpenPos()
	{save to struct: position long\short, time, volume,price,spread,signal,first,pom,dc, bool flag opened\closed.
	if AddVolume then recalculate m_CurrentLot_for_Close, recalculate OpenPrice and save.
	m_Omega++;
	}
		
+bool Emul_ClosePos()
	{save to struct: NP, position long\short, time, volume,price,spread,signal,first,pom,dc,bool flag opened\closed.
	m_NP=m_NP+NP.now;
	}

+bool Emul_Trade()
	{
	  for 0 to m_Total_Minutes_in_period-1
		{
		if !CheckSpread continue
		AutoCloseDCSpread(Emul_ClosePos , continue)
		if TR_Caterpillar == 	Buy\Sell -> Emul_OpenPos, continue
		}
	Save to struct NP & Omega
	m_omega=0;
	m_np=0;
	}
*/

//+------------------------------------------------------------------+
//|Class for Capture Q,NP, Virtual Trading, Caterpillar, Ck          |
//+------------------------------------------------------------------+
class RTrade
  {

private:
   //Emulation
   bool              m_initialised_emul;
   ENUM_CloseRule    m_close_rule_num_emul;
   ENUM_OpenRule     m_open_rule_num_emul;
   uint              m_max_spread_emul;
   double            m_pom_buy_emul;
   double            m_pom_sell_emul;
   double            m_pom_koef_emul;
   uint              m_bottle_size_emul;
   uint              m_one_bottle_size_emul;
   uint              m_all_bottle_size_emul;
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
   bool              m_EMUL_AutoCloseDCSpread(const double Dc,const uint Spread,const double Commission);
   //TR Open Positions(-1,-2=none,-1=sell,+1=buy)
   int               m_EMUL_TR_Caterpillar(const char Case,const int IterationNum);
   char              m_EMUL_CloseRule(const ENUM_CloseRule CloseRuleNum);
   int               m_EMUL_OpenRule(const ENUM_OpenRule OpenRuleNum,const char Case,const int IterationNum);

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
   bool              _InitEmul(const ENUM_CloseRule CloseRuleNum,const ENUM_OpenRule OpenRuleNum,const int MaxSpread,
                               const double PomBuy,const double PomSell,const double PomKoef);

   //   bool              Capture_Q(const TIMEMARKS &_TimeMarks,SIMUL_Q &_SimulQ);
   //   bool              Capture_NP(const TIMEMARKS &_TimeMarks,SIMUL_NP &_SimulNP);
   //Emulate trading inside One Priming
   bool              Emulate_Trading(const bool Priming1);

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
   uint Stop_measuring=GetTickCount()-Start_measure;
   PrintFormat("Init Primings complete in %d ms",Stop_measuring);

//If Ok
   m_Result=0;
   return(true);
  }
//+------------------------------------------------------------------+
//| Main Emulating                                                   |
//+------------------------------------------------------------------+
bool RTrade::Emulate_Trading(const bool Priming1)
  {
//If not initialised, then exit
   if(!m_initialised_emul)
     {
      m_Result=-2;
      return(false);
     }

//Start speed measuring 
   uint Start_measure=GetTickCount();

//Main inPriming1 Circle 
   if(Priming1)
     {
      //Set Current Priming
      m_CurrentPriming=Priming1;

      //Priming length
      int ArrSize=ArraySize(m_arr_Rates_P1);

      //+++++EMULATION++++++\\
      //+++++EMULATION++++++\\
      //+++++EMULATION++++++\\

      //Local Caterpillar params
      double LocalPOM=0;
      double LocalDC=0;
      char   LocalWhoFirst=0;
      char   LocalSignal=0;

      //Do it for 3 Cases :case 1, Case 4, Case14
      for(char Case=0;Case<3;Case++)
        {
         uint BUY_Signal_Count=0;
         uint SELL_Signal_Count=0;

         //From first day 00:00 to 23:50 last day in Priming1
         for(int i=ArrSize-1;i>-1;i--)
           {
            // Print(IntegerToString(i)+" First: "+TimeToString(m_arr_Rates_P1[ArraySize(m_arr_Rates_P1)-1].time,TIME_DATE|TIME_MINUTES));
            //Print(IntegerToString(i)+" Last: "+TimeToString(m_arr_Rates_P1[i].time,TIME_DATE|TIME_MINUTES));

            //Reset parmas
            LocalPOM=0;
            LocalDC=0;
            LocalWhoFirst=0;
            LocalSignal=0;

            //Wait for minimum Indicator Values(3 bottles * 4 price in each bottle)
/*          if(i>i-(int)m_all_bottle_size_emul) //or from (4*3*m_bottle_size_emul)-1 ?
              {
               continue;
              }

            //0.Build Virtual POM,dc,whofirst,signal
            if(!m_EMUL_VirtualCaterpillar(i,LocalPOM,LocalDC,LocalSignal,LocalWhoFirst))
              {
               continue;
              }
*/
            //1. Check Open Rule (TEST IT!!!!!)
            int OTR_RESULT=m_EMUL_OpenRule(m_open_rule_num_emul,Case,i);

            //If Buy
            if(OTR_RESULT==BUY1)
              {
               BUY_Signal_Count++;
               Alert("BUY!");
               Print("BUY "+TimeToString(m_arr_Rates_P1[i].time));

              }

            //If Sell
            if(OTR_RESULT==SELL1)
              {
               SELL_Signal_Count++;
               Alert("SELL!");
               Print("SELL "+TimeToString(m_arr_Rates_P1[i].time));
              }

            //2. Check Close Rule (DONT WORK)
            char CTR_RESULT=m_EMUL_CloseRule(m_close_rule_num_emul);

            //3. Check Spread (if > max then next iteration)
            if(CheckSpread(m_max_spread_emul,m_arr_Spread_P1[i])) continue;

            //4. Check if NOSIGNAL then exit
            if(OTR_RESULT<=0) continue;

            //5. Check if _CanOpenNewPos
            //6. Add Volume
            //7. OpenPosition

           }//END OF CASE
         Print("Case "+IntegerToString(Case)+" Buys: "+IntegerToString(BUY_Signal_Count));
         Print("Case "+IntegerToString(Case)+" Sells: "+IntegerToString(SELL_Signal_Count));
        }//END OF ALL CASES
      Print("All Cases");
     }//END OF PRIMING1

//8. Count Opened Positions & NP priming1

//Stop speed measuring   
// if(m_debug)
// {
   uint Stop_measuring=GetTickCount()-Start_measure;
   PrintFormat("Emulating Priming1 complete in %d ms",Stop_measuring);
//  }

   Print("Ok");
//If Ok
   return(true);
  }
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
bool  RTrade::m_EMUL_AutoCloseDCSpread(const double Dc,const uint Spread,const double Commission)
  {// CLose if NetProfit >= |dC|+spread+commision
   bool res=false;

//Open position?
/*
   if(!PositionSelect(pair)) {return(res);}
   double pos_profit,pos_volume=0;
   PositionGetDouble(POSITION_VOLUME,pos_volume);
   PositionGetDouble(POSITION_PROFIT,pos_profit);
   if(pos_profit>=MathAbs(dc*10)+(spread*pos_volume)+(comission*pos_volume))
     {
      if(Rost_ClosePosition(pair,"Spread="+IntegerToString(spread)+" dC: "+DoubleToString(dc/_inpDeltaC_koef)+"|Closed by|dC|")) {res=true;}
     }
*/
   return(res);
  }
//+------------------------------------------------------------------+
//| Emulated Choosing Close Rule                                     |
//+------------------------------------------------------------------+
char  RTrade::m_EMUL_CloseRule(const ENUM_CloseRule CloseRuleNum)
  {
//TR_RESULT  
   char TR_RES=-1;

   if(CloseRuleNum<0)
     {
      return(-2);
     }

   switch(CloseRuleNum)
     {
      case  0:TR_RES=m_EMUL_AutoCloseDCSpread(0,0,0);

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
int  RTrade::m_EMUL_OpenRule(const ENUM_OpenRule OpenRuleNum,const char Case,const int IterationNum)
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
bool RTrade::_InitEmul(const ENUM_CloseRule CloseRuleNum,const ENUM_OpenRule OpenRuleNum,const int MaxSpread,
                       const double PomBuy,const double PomSell,const double PomKoef)
  {
   m_close_rule_num_emul=CloseRuleNum;
   m_open_rule_num_emul=OpenRuleNum;
   m_max_spread_emul=MaxSpread;
   m_pom_buy_emul=PomBuy;
   m_pom_sell_emul=PomSell;
   m_pom_koef_emul=PomKoef;

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
