//+------------------------------------------------------------------+
//|                                                     RHistory.mqh |
//|                             Copyright 2016, Shcherbyna Rostyslav |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Shcherbyna Rostyslav"
#property link      ""
#property version   "1.92"

#include <Tools\DateTime.mqh>
#include <RInclude\RStructs.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*
Class for determining first & last days of each working day with user period.
With additional information on getting server data.
Can determine last & first day minute, last week minute, last month minute, last quarter minute;
+ works with Rates, Spreads, canbe find by Date,Index
+ Search time\spread\rate forward & Backward
+ working with pom3 copybuffer
*/
/*
+++++CHANGE LOG+++++
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
//+------------------------------------------------------------------+
//|  CLASS RHISTORY                                                  |
//+------------------------------------------------------------------+
class RHistory
  {
private:
   // Only Parents Access

   // Check
   bool              m_debug;                   //Is Debug
   bool              m_initialised;             //Is Initialised  
   bool              m_processed;               //Is Processed
   bool              m_imported;                //Is Imported first & last minutes
   bool              m_MRS_identical;           //Is 3 arrays identical

                                                // Main   
   string            m_pair;                    //Current Symbol    
   string            m_path;                    //Path to DB (COMMON FOLDER) 
   datetime          m_from_date;               //Requested range from
   datetime          m_to_date;                 //Requested range to
   string            m_ind_path;                //Path to Indicator POM3
   uchar             m_bottle_size;             //Size of bottle in indicator

                                                // Arrays   
   datetime          m_arr_all_time[];          //Arr of all period (minutes) 
   MqlRates          m_arr_all_rate[];          //Arr of all period (rates) 
   int               m_arr_all_spread[];        //Arr of all period (spread)   
   datetime          m_arr_day_begins[];        //First minutes each working day
   datetime          m_arr_day_ends[];          //Latest minutes each working day

                                                // Counts   
   int               m_copyed_all_datetimes;    //Copyed count of all server minutes 
   int               m_copyed_all_rates;        //Copyed count of all Rates(OHLC)
   int               m_copyed_all_spreads;      //Copyed count of all Spreads
   datetime          m_first_server_time;       //First loaded server time
   datetime          m_last_server_time;        //Last loaded server time
   MqlRates          m_first_server_rate;       //First loaded server rate
   MqlRates          m_last_server_rate;        //Last loaded server rate
   uint              m_first_server_spread;     //First loaded server spread
   uint              m_last_server_spread;      //Last loaded server spread

   ENUM_HistResults  m_result;                  //String result of loading history 
   uint              m_total_working_days_count;//Total (working) days in all period

   int               m_handle_ind_POM;          //---Indicators handle

   void              _Reset();                  //Reset private mmbers to defaults
   void              _ClearArrays();            //Clear internal arrays
   bool              _CheckMRS();               //Check Minutes Spreads Rates arrays by dates(First & Last)+Counts
   bool              _ConnectIndicator();       //Connect indicator POM3
                                                //
   //Calculate WhoFirst Universal for Close and OHLC
   char              m_WhoFirst_OHLC(const MqlRates &Rates[],const int &Start,const double &Open,const double &High,
                                     const double &Low,const double &Close);

   //Calculate WhoFirst for placement in OHLC emulation (true=HighFirst)                               
   bool              m_MT5_HighFirst_OHLC(const MqlRates &Rates);

   //Calculates POM & Signal in primings
   double            m_POM_Signal_OHLC(const double &Open,const double &High,const double &Low,const double &Close,
                                       const char &WhoFirst,char &POM_SIGNAL);
   //Calculates DC in primings
   double            m_DC_OHLC(const int OHLC,const MqlRates &Rates[],const int &Start,const double &Open,
                               const double &High,const double &Low,const double &Close,const STRUCT_TICKVOL_OHLC &TickVol[]);

public:
                     RHistory(const string pair,const string path_to_ind,const uchar bottlesize,const bool UseIndicator);
                    ~RHistory();
   //Check
   bool              _IsInitialised()                const       {return(m_initialised);}
   bool              _IsImported()                   const       {return(m_imported);}
   bool              _IsProcessed()                  const       {return(m_processed);}
   bool              _IsMRS_Identical()              const       {return(m_MRS_identical);}

   //CopyTimes   
   ulong             _TotalMinutes()                 const       {return(m_copyed_all_datetimes);}
   datetime          _FirstMinute()                  const       {return(m_first_server_time);}
   uint              _FirstMinuteIndex()             const       {return((int)_TotalMinutes()-1);}
   //Ends in arr_Ends[]
   datetime          _LastMinuteDayEnds() const       {return(m_arr_day_ends[0]);}

   datetime          _LastMinute()                   const       {return(m_last_server_time);}
   uint              _LastMinuteIndex()              const       {return(0);}

   //CopyRate
   ulong             _TotalRates()                 const       {return(m_copyed_all_rates);}
   MqlRates          _FirstRate()                  const       {return(m_first_server_rate);}
   uint              _FirstRateIndex()             const       {return((int)_TotalRates()-1);}
   MqlRates          _LastRate()                   const       {return(m_last_server_rate);}
   uint              _LastRateIndex()              const       {return(0);}

   //CopySpread   
   ulong              _TotalSpreads()              const       {return(m_copyed_all_spreads);}
   uint               _FirstSpread()               const       {return(m_first_server_spread);}
   uint               _FirstSpreadIndex()          const       {return((int)_TotalSpreads()-1);}
   uint               _LastSpread()                const       {return(m_last_server_spread);}
   uint               _LastSpreadIndex()           const       {return(0);}

   //Times
   uint              WorkingDays() const       {return(m_total_working_days_count);}
   datetime          First_DayMinute(const uint Index) const       {return(m_arr_day_begins[Index]);}
   datetime          First_DayMinute(const datetime Date);
   datetime          Last_DayMinute(const uint Index) const       {return(m_arr_day_ends[Index]);}
   datetime          Last_DayMinute(const datetime Date);
   datetime          LastMinute_DaySearch(const datetime Date,const bool SearchDirection); //True forward, false backward);
   datetime          FirstMinute_DaySearch(const datetime Date,const bool SearchDirection); //True forward, false backward);
   datetime          LastMinute_NextPeriod(const uchar period,const datetime StartDate);
   datetime          FirstMinute_NextPeriod(const uchar period,const datetime StartDate);
   datetime          FirstMinute_PreviousPeriod(const uchar period,const datetime StopDate);
   datetime          Last_Work_Day_In_Week(datetime Date);
   datetime          First_Work_Day_In_Week(datetime Date);
   uchar             Last_Work_Day_In_Month(datetime Date);
   uchar             First_Work_Day_In_Month(datetime Date);

   //Rates   
   bool              FindRate_by_Index(const uint Index,MqlRates &Rate);
   int               FindRate_by_Date(const datetime Date,const bool SecondsAccuracy,MqlRates &Rate);
   int               FindRate_by_Date_Nearest(const bool SearchDirection,const bool SecondsAccuracy,
                                              const datetime Date,MqlRates &Rate,const uchar SecondsStep,const ushort Trys);

   //Spreads   
   uint              FindSpread_by_Index(const uint Index);

   ENUM_HistResults  ShowLoad_Result() const       {return(m_result);}
   void              ResetResult() {m_result=0;}

   //Main
   bool              _Init(const datetime from_date,const datetime to_date,const bool debug);

   //Call onInit                         
   bool              _Check_Load_History(const uchar TrysCount,const ENUM_TIMEFRAMES TimeFrame);

   //Calculate(days\weeks\months\quarters)  RequestMode = Don`t load rates,spread,Indicator
   bool              _ProcessDays(const ushort MinSessionMinutes,const bool TimesOnly);

   //Export  first & last minutes               
   bool              _ExportFLMToDB();

   //Export first & last minutes to readable txt file
   bool              _ExportFLMToText();

   //Export Rates structure to CSV file
   bool              _ExportRatesToCSV(const bool ReverseWrite);

   //Export Indicator Feed  to CSV file (date,ohlc,spread,tickvol,WF,POM,DC,SIGNAL)
   bool              _ExportIndicatorFeedToCSV(const bool ReverseWrite,const STRUCT_Priming &Priming,const bool Priming1);

   //Export OHLC Feed to CSV file (date,ohlc,spread,tickvol,WF,POM,DC,SIGNAL)
   bool              _ExportOHLCFeedToCSV(const bool ReverseWrite,const MqlRates &Rates[],const STRUCT_FEED_OHLC &Feed[],
                                          const bool Priming1);

   //Export Close Feed to CSV file (date,ohlc,spread,tickvol,WF,POM,DC,SIGNAL)
   bool              _ExportCloseFeedToCSV(const bool ReverseWrite,const MqlRates &Rates[],const STRUCT_FEED_CLOSE &Feed[],
                                           const bool Priming1);

   //Export OHLC TickVolume Distribution Feed to CSV file (date,OHLC,tickvol)
   bool              _ExportOHLCTickVolFeedToCSV(const bool ReverseWrite,const STRUCT_TICKVOL_OHLC &Feed[],
                                                 const bool Priming1);

   //Export Rates to binary file
   bool              _ExportRatesToBIN(const bool ReverseWrite);

   //Test Import Rates from CSV file
   bool              _ImportRatesFromCSV();

   //Test Import Rates from BIN file
   bool              _ImportRatesFromBIN();

   //Test Import first & last minutes DB
   bool              _ImportFLMFromDB(const string pair);

   //Get latest Indicator buffers           
   bool              _GetInd_LastBuffers(double &Signal,double &First,double &Pom,double &Dc);

   //Version with struct only
   bool              _FormPrimingData(const bool Priming1,const TIMEMARKS &TimeMarks,STRUCT_Priming &Priming);

   //Version WO Indicator (returns copyed count)
   int               _FillPriming(const bool Priming1,const TIMEMARKS &TimeMarks,MqlRates &Priming[]);

   //Calculates each OHLC price tick_volume from Compounding TickVolume
   bool              _CalculateTickVolume(const MqlRates &Rates[],STRUCT_TICKVOL_OHLC &TickVol[]);

   //Calculate OHLC Feed (4 prices in one minute)
   bool              _Calculate_OHLC_Feed(const MqlRates &Rates[],STRUCT_FEED_OHLC &Feed[],const STRUCT_TICKVOL_OHLC &TickVol[]);

   //Calculate Feed for Only Close prices
   bool              _Calculate_CLOSE_Feed(const MqlRates &Rates[],STRUCT_FEED_CLOSE &Feed[],const STRUCT_TICKVOL_OHLC &TickVol[]);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
RHistory::RHistory(const string pair,const string path_to_ind,const uchar bottlesize,
                   const bool UseIndicator):m_initialised(false),
                   m_processed(false),
                   m_imported(false),
                   m_MRS_identical(false),
                   m_copyed_all_datetimes(0),
                   m_first_server_time(0),
                   m_first_server_spread(0),
                   //m_last_server_time(0),
                   m_total_working_days_count(0),
                   m_debug(false)
  {

//Check symbol 
   if(pair==NULL || pair=="")
     {
      m_result=-14;
      m_initialised=false;
      return;
     }
//Check Symbol Select
   if(!SymbolInfoInteger(pair,SYMBOL_SELECT))
     {
      if(GetLastError()==ERR_MARKET_UNKNOWN_SYMBOL)
        {
         m_result=-14;
         m_initialised=false;
         return;
        }

      if(!SymbolSelect(pair,true))
        {
         m_result=-14;
         m_initialised=false;
         return;
        }
     }//end of SymbolInfo

//+If Ok, Save Pair
   m_pair=pair;

//Save BottleSize
   m_bottle_size=bottlesize;

//Save Path to indicator
   m_ind_path=path_to_ind;

//Get Server Broker Name
   string Server=AccountInfoString(ACCOUNT_SERVER);

//+If ok, save path to DB(FL- first & last minute)
   m_path=Server+m_pair+".FLM";

//Connect Indicator
   if(UseIndicator)
      if(!_ConnectIndicator())
        {
         m_result=-22;
         return;
        }
  }//End of Constructor
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
RHistory::~RHistory()
  {
//---Delete Indicator
   IndicatorRelease(m_handle_ind_POM);
  }//END OF Destructor
//+------------------------------------------------------------------+
//| Export first & last days as text file                            |
//+------------------------------------------------------------------+
bool  RHistory::_ExportFLMToText(void)
  {
//Start speed measuring
   uint Start_measure=GetTickCount();

//If NOT Initialised
   if(!m_initialised)
     {
      m_result=-11;
      return(false);
     }

//If NOT Processed     
   if(!m_processed)
     {
      m_result=-13;
      return(false);
     }

//If BD not NULL
   if(m_copyed_all_datetimes<=1)
     {
      m_result=-12;
      return(false);
     }

   string Server=AccountInfoString(ACCOUNT_SERVER);

   string temp_path="//"+Server+m_pair+"export.txt";

//If exist delete
   if(FileIsExist(temp_path,FILE_COMMON)) FileDelete(temp_path,FILE_COMMON);

//Init file for write (csv) \r\n
   int file_h1=FileOpen(temp_path,
                        FILE_READ|FILE_WRITE|FILE_BIN|FILE_COMMON|FILE_CSV|FILE_ANSI);
   if(file_h1==INVALID_HANDLE) return(false);

   int arrSize=ArraySize(m_arr_day_begins);
   string s1,s2;

   for(int i=0;i<arrSize;i++)
     {
      s1=IntegerToString(i)+" First :"+TimeToString(m_arr_day_begins[i],TIME_DATE|TIME_MINUTES|TIME_SECONDS)+"\r\n";
      s2=IntegerToString(i)+" Last :"+TimeToString(m_arr_day_ends[i],TIME_DATE|TIME_MINUTES|TIME_SECONDS)+"\r\n";
      FileWrite(file_h1,s1);
      FileWrite(file_h1,s2);
     }

   FileClose(file_h1);

//Stop speed measuring     
   uint Stop_measuring=GetTickCount()-Start_measure;
   PrintFormat("Export to text in %d ms",Stop_measuring);

   return(true);
  }//END OF FLM To TXT
//+------------------------------------------------------------------+
//| Reset Private members                                            |
//+------------------------------------------------------------------+
void  RHistory::_Reset(void)
  {
   m_initialised=false;         //Is Initialised  
   m_processed=false;           //Is Processed 
   m_imported=false;            //Is Imported 
   m_MRS_identical=false;       //Is MRS Identical 
   m_pair="";                   //Current Symbol    
   m_path="";                   //Path to DB (COMMON FOLDER) 
   m_from_date=0;               //Requested range from
   m_to_date=0;                 //Requested range to
   m_copyed_all_datetimes=0;    //Copyed count of all server minutes 
   m_copyed_all_rates=0;        //Copyed count of all server rates  
   m_copyed_all_spreads=0;      //Copyed count of all server spreads  
   m_first_server_time=0;       //First loaded server time
                                //  m_first_server_rate=0;       //First loaded server rate
   m_first_server_spread=0;       //First loaded server spread
                                  //m_last_server_time=0;        //Last loaded server time
   m_result=0;     //String result of loading history 
   m_total_working_days_count=0;//Total (working) days in all period
                                //m_err="";                    //Error Description
   m_ind_path="";
   m_bottle_size=0;
  }//END OF RESET members
//+------------------------------------------------------------------+
//| Clear Arrays                                                     |
//+------------------------------------------------------------------+
void RHistory::_ClearArrays()
  {
   ArrayResize(m_arr_all_time,0);
   ArrayResize(m_arr_day_begins,0);
   ArrayResize(m_arr_day_ends,0);
   ArrayResize(m_arr_all_rate,0);
   ArrayResize(m_arr_all_spread,0);
  }//END OF ClearArrays
//+------------------------------------------------------------------+
//| Import DB                                                        |
//+------------------------------------------------------------------+
bool  RHistory::_ImportFLMFromDB(const string pair)
  {
//Start speed measuring
   uint Start_measure=GetTickCount();

//Clear   
   _ClearArrays();
   _Reset();

//Check symbol 
   if(pair==NULL || pair=="")
     {
      m_result=-14;
      return(false);
     }
//Check Symbol Select
   if(!SymbolInfoInteger(pair,SYMBOL_SELECT))
     {
      if(GetLastError()==ERR_MARKET_UNKNOWN_SYMBOL)
        {
         m_result=-14;
         return(false);
        }

      if(!SymbolSelect(pair,true))
        {
         m_result=-14;
         return(false);
        }
     }//end of SymbolInfo

   string Server=AccountInfoString(ACCOUNT_SERVER);

//Init file     
   m_path=Server+pair+".FLM";

   int  fh1=FileOpen(m_path,FILE_READ|FILE_WRITE|FILE_BIN|FILE_COMMON);
   if(fh1==INVALID_HANDLE)  return(false);

//Read data
   uint i=0;
   FLM arr_temp[];

   while(!FileIsEnding(fh1) && !IsStopped())
     {
      ArrayResize(arr_temp,ArraySize(arr_temp)+1);
      FileReadStruct(fh1,arr_temp[i]);

      ArrayResize(m_arr_day_begins,ArraySize(m_arr_day_begins)+1);
      ArrayResize(m_arr_day_ends,ArraySize(m_arr_day_ends)+1);

      m_arr_day_begins[i]=arr_temp[i].day_first_minute;
      m_arr_day_ends[i]=arr_temp[i].day_last_minute;
      i++;
     }//end of while

//+If ok
   m_initialised=true;
   m_processed=true;
   m_imported=true;

//Stop speed measuring
   uint Stop_measuring=GetTickCount()-Start_measure;
   PrintFormat("Import complete in %d ms",Stop_measuring);

   return(true);
  }//END OF Import FLM From DB
//+------------------------------------------------------------------+
//| Export FLM to DB                                                 |
//+------------------------------------------------------------------+
bool RHistory::_ExportFLMToDB(void)
  {
//Start speed measuring  
   uint Start_measure=GetTickCount();

//If NOT Initialised
   if(!m_initialised)
     {
      m_result=-11;
      return(false);
     }

//If NOT Processed     
   if(!m_processed)
     {
      m_result=-13;
      return(false);
     }

//If BD not NULL
   if(m_copyed_all_datetimes<=1)
     {
      m_result=-12;
      return(false);
     }

//If ok Save To File
   FLM zFLM;

//If exist delete
   if(FileIsExist(m_path,FILE_COMMON)) FileDelete(m_path,FILE_COMMON);

//Init file
   int  fh1=FileOpen(m_path,FILE_READ|FILE_WRITE|FILE_BIN|FILE_COMMON);
   if(fh1==INVALID_HANDLE)  return(false);

//Export Struct
   int arrsize=ArraySize(m_arr_day_begins);

   for(int i=0;i<arrsize;i++)
     {
      zFLM.day_first_minute= m_arr_day_begins[i];
      zFLM.day_last_minute = m_arr_day_ends[i];
      FileWriteStruct(fh1,zFLM);
     }

   FileClose(fh1);

//Stop speed measuring   
   uint Stop_measuring=GetTickCount()-Start_measure;
   PrintFormat("Export complete in %d ms",Stop_measuring);

   return(true);
  }//END OF Export FLM To DB
//+------------------------------------------------------------------+
//| GetFirstMinute                                                   |
//+------------------------------------------------------------------+
datetime RHistory::First_DayMinute(const datetime Date)
  {

//If NOT Initialised
   if(!m_initialised)
     {
      m_result=-11;
      return(false);
     }

//If NOT Processed     
   if(!m_processed)
     {
      m_result=-13;
      return(false);
     }

   CDateTime cdt,cdt_search;
   TimeToStruct(Date,cdt);

//Reset time to 00:00:00
   cdt.hour=0;
   cdt.min=0;
   cdt.sec=0;

   datetime dt=StructToTime(cdt);

//Days count in db
   int ArrSize=ArraySize(m_arr_day_begins);

//Check if requested date > latest day in db, exit err
   if(dt>_LastMinuteDayEnds())
     {
      m_result=-16;
      return(0);
     }

//Check if requested date < first day in db, exit err
   if(dt<_FirstMinute())
     {
      m_result=-16;
      return(0);
     }

//Find this day (wo time)
   for(int i=0;i<ArrSize;i++)
     {
      TimeToStruct(m_arr_day_begins[i],cdt_search);
      if(cdt_search.year==cdt.year && cdt_search.mon==cdt.mon && cdt_search.day==cdt.day)
        {//found, save first minute
         m_result=1;
         return(StructToTime(cdt_search));
        }
     }

//if not found  
   m_result=-10;
   return(0);
  }//END OF GetFirst Day Minute
//+------------------------------------------------------------------+
//| GetLastMinute                                                    |
//+------------------------------------------------------------------+
datetime RHistory::Last_DayMinute(const datetime Date)
  {
//If NOT Initialised
   if(!m_initialised)
     {
      m_result=-11;
      return(false);
     }

//If NOT Processed     
   if(!m_processed)
     {
      m_result=-13;
      return(false);
     }

   CDateTime cdt,cdt_search;
   TimeToStruct(Date,cdt);

//Days count
   int ArrSize=ArraySize(m_arr_day_ends);

//Check if requested date > latest day in db, exit err
   if(Date>_LastMinuteDayEnds())
     {
      m_result=-16;
      return(0);
     }

//Check if requested date < first day in db, exit err
   if(Date<_FirstMinute())
     {
      m_result=-16;
      return(0);
     }

//Find this day(wo time)
   for(int i=0;i<ArrSize;i++)
     {
      TimeToStruct(m_arr_day_ends[i],cdt_search);
      if(cdt_search.year==cdt.year && cdt_search.mon==cdt.mon && cdt_search.day==cdt.day)
        {//found, save last minute
         m_result=1;
         return(StructToTime(cdt_search));
        }
     }

//if not found  
   m_result=-10;
   return(0);
  }//END OF GetLast Day Minute
//+------------------------------------------------------------------+
//| ProcessDays                                                      |
//+------------------------------------------------------------------+
bool RHistory::_ProcessDays(const ushort MinSessionMinutes,const bool TimesOnly)
  {
/*
   if copyied day_minutes < Minimum_SessionMinutes then this day are passed
   (recommended Minimum_SessionMinutes=>=1)
  */

//Start speed measuring
   uint Start_measure=GetTickCount();

//If NOT Initialised
   if(!m_initialised)
     {
      m_result=-11;
      return(false);
     }

//Time Series for Times[], 0 - now
   if(!ArraySetAsSeries(m_arr_all_time,true))
     {
      m_result=-7;
      return(false);
     }

//Time Series for Rates[], 0 - now     
   if(!ArraySetAsSeries(m_arr_all_rate,true))
     {
      m_result=-7;
      return(false);
     }

//Time Series for Spreads[], 0 - now     
   if(!ArraySetAsSeries(m_arr_all_spread,true))
     {
      m_result=-7;
      return(false);
     }

//Get All T
   m_copyed_all_datetimes=CopyTime(m_pair,PERIOD_M1,m_from_date,m_to_date,m_arr_all_time);
//   Sleep(10);

//Don`t load if TimesOnly
   if(!TimesOnly)
     {
      //Get All Prices
      m_copyed_all_rates=CopyRates(m_pair,PERIOD_M1,m_from_date,m_to_date,m_arr_all_rate);
      //   Sleep(10);

      //Get All Spreads
      m_copyed_all_spreads=CopySpread(m_pair,PERIOD_M1,m_from_date,m_to_date,m_arr_all_spread);

      //If all_rates err, exit
      if(m_copyed_all_rates<=0)
        {
         m_result=-17;
         return(false);
        }

      //If all_spreads err, exit
      if(m_copyed_all_spreads<=0)
        {
         m_result=-18;
         return(false);
        }
/*
      //Connect Indicator
      if(!_ConnectIndicator())
        {
         m_result=-22;
         return(false);
        }
*/
     }//END OF NOT TIMESONLY

//If all_times err, exit
   if(m_copyed_all_datetimes<=0)
     {
      m_result=-8;
      return(false);
     }

//Save begins & Ends of times only
   m_first_server_time=m_arr_all_time[m_copyed_all_datetimes-1];
   m_last_server_time=m_arr_all_time[0];

//TimesOnly   
   if(!TimesOnly)
     {
      //Save begins  
      m_first_server_rate=m_arr_all_rate[m_copyed_all_rates-1];
      m_first_server_spread=m_arr_all_spread[m_copyed_all_spreads-1];

      //Save ends
      m_last_server_rate=m_arr_all_rate[0];
      m_last_server_spread=m_arr_all_spread[0];

      //Check for MRS
      if(!_CheckMRS())
        {
         return(false);
        }
     }//END OF NOT TIMES ONLY

   CDateTime cdt_start,cdt_stop;
   TimeToStruct(m_to_date,cdt_start);
   TimeToStruct(m_to_date,cdt_stop);

   cdt_start.hour=0;
   cdt_start.min=0;
   cdt_start.sec=0;

   cdt_start.DayDec(1);

   cdt_stop.hour=0;
   cdt_stop.min=0;
   cdt_stop.sec=0;

   datetime start= StructToTime(cdt_start);
   datetime stop = StructToTime(cdt_stop);

   int copy_temp=0,z=0;

//+------------------------------------------------------------------+
//| MAIN WHILE                                                       |
//+------------------------------------------------------------------+
   while(!IsStopped())
     {
      //Check if fill all dates,return ok
      if(start<m_from_date)
        {
         //Save total days from z
         m_total_working_days_count=z;
         m_result=1;
         m_processed=true;

         //Stop speed measuring  
         if(m_debug)
           {
            uint Stop_measuring=GetTickCount()-Start_measure;
            string s1=TimeToString(m_from_date,TIME_DATE);
            PrintFormat("ProcessDays from %s in %d ms",s1,Stop_measuring);
           }

         return(true);//return OK
        }

      //Sleep for better perfomance and avoid limitations
      //    Sleep(5);

      //For test_request
      datetime arr_Time_TestRequest[];

      if(!ArraySetAsSeries(arr_Time_TestRequest,true))
        {
         m_result=-7;
         return(false);
        }

      //Copy one day
      copy_temp=CopyTime(m_pair,PERIOD_M1,start,stop,arr_Time_TestRequest);

      //if Sunday or Saturday then next (copy_temp=1==err!)
      if(copy_temp<=MinSessionMinutes)
        {
         //Decriment start & stop time
         cdt_start.DayDec(1);
         cdt_stop.DayDec(1);
         start=StructToTime(cdt_start);
         stop=StructToTime(cdt_stop);
         continue;
        }

      //Save Last minute of the Day
      int ares=ArrayResize(m_arr_day_ends,ArraySize(m_arr_day_ends)+1);

      if(ares<0)
        {
         m_result=-9;
         return(false);
        }

      m_arr_day_ends[z]=arr_Time_TestRequest[1];

      //Save First minute of the Day
      int bres=ArrayResize(m_arr_day_begins,ArraySize(m_arr_day_begins)+1);

      if(bres<0)
        {
         m_result=-9;
         return(false);
        }

      m_arr_day_begins[z]=arr_Time_TestRequest[copy_temp-1];

      //For save next datetime
      z++;

      //Decriment start & stop time
      cdt_start.DayDec(1);
      cdt_stop.DayDec(1);

      start=StructToTime(cdt_start);
      stop=StructToTime(cdt_stop);

     }//end of while

//Stop speed measuring     
   uint Stop_measuring=GetTickCount()-Start_measure;
   PrintFormat("ProcessDays failed in %d ms",Stop_measuring);

//+If Ok
   return(true);
  }//END OF PROCESS (FORM FLM IN MEMORY)
//+------------------------------------------------------------------+
//| Initialisation                                                   |
//+------------------------------------------------------------------+
bool RHistory::_Init(datetime from_date,const datetime to_date,const bool debug)
  {
//Set Debug mode
   m_debug=debug;

//Check From and To Date
   if(from_date>=to_date)
     {
      m_result=-15;
      m_initialised=false;
      return(false);
     }

//+If ok, save From & To Date
   m_from_date=from_date;
   m_to_date=to_date;

//+If All Ok
   m_initialised=true;

   return(true);
  }//END OF _INIT
//+------------------------------------------------------------------+
//| CheckLoadHistory                                                 |
//+------------------------------------------------------------------+  
bool RHistory::_Check_Load_History(const uchar TrysCount,const ENUM_TIMEFRAMES period)
  {
//Start speed measuring
   uint Start_measure=GetTickCount();

//If NOT Initialised
   if(!m_initialised)
     {
      m_result=-11;
      return(false);
     }

   datetime first_date;
   datetime times[];

//--- check if data is present on LocalSymbol
   SeriesInfoInteger(m_pair,period,SERIES_FIRSTDATE,first_date);
//If Ok, Then Exit
   if(first_date>0 && first_date<=m_from_date)
     {
      m_result=1;
      return(true);
     }
//--- if load from indicator,exit otherwise (bug)
   if(MQL5InfoInteger(MQL5_PROGRAM_TYPE)==PROGRAM_INDICATOR && Period()==period && Symbol()==m_pair)
     {
      m_result=-1;
      return(false);
     }
//--- second attempt(get from local terminal) 
   if(SeriesInfoInteger(m_pair,PERIOD_M1,SERIES_TERMINAL_FIRSTDATE,first_date))
     {
      //--- if ok
      if(first_date>0)
        {
         //--- read first date
         CopyTime(m_pair,period,first_date+PeriodSeconds(period),1,times);

         //--- check load
         if(SeriesInfoInteger(m_pair,period,SERIES_FIRSTDATE,first_date))

            //if LocalSymbol has data, exit
            if(first_date>0 && first_date<=m_from_date)
              {
               m_result=2;
               return(true);
              }
        }
     }//END OF TERMINAL ATTEMPT

//--- max bars in chart from terminal options 
   int max_bars=TerminalInfoInteger(TERMINAL_MAXBARS);

//---if no data, load from sever
   datetime first_server_date=0;

//---Get First server date
   while(!SeriesInfoInteger(m_pair,PERIOD_M1,SERIES_SERVER_FIRSTDATE,first_server_date) && !IsStopped())
      Sleep(10);

//--- fix start date for loading
   if(first_server_date>m_from_date) m_from_date=first_server_date;
//if server date too old  
   if(first_date>0 && first_date<first_server_date)
     {
      //  Print("Warning: first server date ",first_server_date," for ",m_pair,
      //      " Symbol data older(better) then Server data ",first_date);
      m_result=-2;
      return(false);
     }

//--- Circle load from server 
   int fail_cnt=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   while(!IsStopped())
     {
      //--- wait for timeseries build 
      while(!SeriesInfoInteger(m_pair,period,SERIES_SYNCHRONIZED) && !IsStopped())
         Sleep(10);

      //--- (initiate build bars)
      int bars=Bars(m_pair,period);
      if(bars>0)
        {
         //if bars > the terminal window, exit,
         if(bars>=max_bars)
           {
            m_result=-3;
            return(false);
           }

         //--- If LocalSymbol ok, exit
         if(SeriesInfoInteger(m_pair,period,SERIES_FIRSTDATE,first_date))
            if(first_date>0 && first_date<=m_from_date)
              {
               m_result=1;
               return(true);
              }
        }//END OF BUILDING BARS

      //--- Get Next Bars
      int copied=CopyTime(m_pair,period,bars,1,times);

      //if ok
      if(copied>0)
        {
         //---if ok, exit  
         if(times[0]<=m_from_date)
           {
            m_result=1;
            return(true);
           }

         //if copy bar err, exit
         if(bars+copied>=max_bars)
           {
            m_result=-4;
            return(false);
           }
         fail_cnt=0;
        }
      else//if nothing get
        {
         //--- no more than trys_count failed attempts 
         fail_cnt++;
         if(fail_cnt>=TrysCount)
           {
            m_result=-6;
            return(false);
           }
         Sleep(10);
        }//end of copyed else

     }//END OF WHILE

//Stop speed measuring     
   uint Stop_measuring=GetTickCount()-Start_measure;
   PrintFormat("Check Load History complete in %d ms",Stop_measuring);

//---if stopped 
   return(false);
  }//END OF CHECK LOAD HOSTORY
//+------------------------------------------------------------------+
//| Latest Minute by date                                            |
//+------------------------------------------------------------------+ 
datetime RHistory::LastMinute_DaySearch(const datetime Date,const bool SearchDirection) //True forward, false backward)
  {
   CDateTime cdt;
   datetime dt_result=0;

   const uchar max_days=10;

   uchar day_counter=0;

//if day not exist , get previous 10 days

   datetime circle_dt=Last_DayMinute(Date);

//If result ok
   if(ShowLoad_Result()>0)
     {
      //      Print("Day:"+TimeToString(Date)+" Last minute = "+TimeToString(circle_dt));
      return(circle_dt);
     }

//if request date > last minute in db
   if(ShowLoad_Result()==-16)
     {
      //      Print(__FUNCTION__+" End of T");
      return(Date);
     }

   if(ShowLoad_Result()<0)
     {
      circle_dt=Date;
      do
        {
         //If trys out, exit
         if(day_counter>max_days)
           {
            Print(__FUNCTION__+"Last minute not found, after all trys from:"
                  +TimeToString(Date,TIME_DATE|TIME_MINUTES|TIME_SECONDS)+
                  "To: "+TimeToString(circle_dt,TIME_DATE|TIME_MINUTES|TIME_SECONDS));
            return(0);
           }

         //Dec or Inc by 1 day 
         TimeToStruct(circle_dt,cdt);

         if(SearchDirection==true) cdt.DayInc(1);
         else cdt.DayDec(1);

         circle_dt=StructToTime(cdt);

         //Check if found
         dt_result=Last_DayMinute(circle_dt);

         day_counter++;
        }
      while(ShowLoad_Result()<0);
     }

//+If ok Print Last Minute
//   Print("Day:"+TimeToString(Date)+" Last minute = "+TimeToString(dt_result));
   return(dt_result);
  }//END OF Latest Minute By Date
//+------------------------------------------------------------------+
//| First minute by date (True forward, false backward)              |
//+------------------------------------------------------------------+ 
datetime RHistory::FirstMinute_DaySearch(const datetime Date,const bool SearchDirection)
  {
   CDateTime cdt;
   datetime dt_result=0;

   const uchar max_days=10;

   uchar day_counter=0;

//(send already shifted date) If day not exist then get next\previous 10 days
   datetime circle_dt=First_DayMinute(Date);

//If result ok
   if(ShowLoad_Result()>0)
     {
      //      Print("Day:"+TimeToString(Date)+" First minute = "+TimeToString(circle_dt));
      ResetResult();
      return(circle_dt);
     }

/*
//If last period & request futured non exist date(>now)
   if(ShowLoad_Result()==-16)
     {
      //  return(Date);
     }
*/

//if date not found
   if(ShowLoad_Result()<0)
     {
      circle_dt=Date;
      do
        {
         //If trys out, exit
         if(day_counter>max_days)
           {
            Print(__FUNCTION__+"First minute not found, after all trys from:"
                  +TimeToString(Date,TIME_DATE|TIME_MINUTES|TIME_SECONDS)+
                  "To: "+TimeToString(circle_dt,TIME_DATE|TIME_MINUTES|TIME_SECONDS));
            return(0);
           }

         //Dec or Inc by 1 day 
         TimeToStruct(circle_dt,cdt);

         if(SearchDirection==true) cdt.DayInc(1);
         else cdt.DayDec(1);

         circle_dt=StructToTime(cdt);

         //Check if found
         dt_result=First_DayMinute(circle_dt);

         day_counter++;
        }
      while(ShowLoad_Result()<0);
     }

//+If ok in circle -> Print First Minute
//   Print("Day:"+TimeToString(Date)+" First minute = "+TimeToString(dt_result));
   return(dt_result);
  }//END OF First Minute By Date
//+------------------------------------------------------------------+
//| First Minute in next period                                      |
//+------------------------------------------------------------------+   
datetime RHistory::FirstMinute_NextPeriod(const uchar period,const datetime StartDate)
  {
   switch(period)
     {
      case  0: //day
        {
         //Shift to next day
         CDateTime cdt;
         TimeToStruct(StartDate,cdt);
         cdt.DayInc(1);

         //Convert to datetime
         datetime dt=StructToTime(cdt);

         //Get First Minute of this day
         datetime CalcDate=FirstMinute_DaySearch(dt,true);
         if(CalcDate==0) return(0);
         else return(CalcDate);
        }
      break;
      /////////////////////////////////////////////////////////////////////////////////////
      case  1: //week
        {
         //Shift to one day to find Friday of next week
         CDateTime cdt;
         TimeToStruct(StartDate,cdt);
         cdt.DayInc(1);

         //Convert to datetime
         datetime dt=StructToTime(cdt);

         //Get last working day in current week(Friday)
         datetime temp_dt=Last_Work_Day_In_Week(dt);

         //Get First Minute of this week
         datetime CalcDate=FirstMinute_DaySearch(temp_dt,true);
         if(CalcDate==0) return(0);
         else return(CalcDate);
        }
      break;
      /////////////////////////////////////////////////////////////////////////////////////
      case  2: //month
        {
         //Shift to find next month
         CDateTime cdt;
         TimeToStruct(StartDate,cdt);

         //Save current month
         int cur_month=cdt.mon;

         //”величиваем день до тех пор: пока не встретитс€ следующий мес€ц
         while(cur_month==cdt.mon)
           {
            cdt.DayInc(1);
           }

         //Convert to datetime
         datetime dt=StructToTime(cdt);

         //Get last workind day in current month
         uint day_num=Last_Work_Day_In_Month(dt);

         //Change to this day          
         cdt.day=(int)day_num;

         //Save day
         datetime temp_dt=StructToTime(cdt);

         //Get First minute of this month
         datetime CalcDate=FirstMinute_DaySearch(temp_dt,true);
         if(CalcDate==0) return(0);
         else return(CalcDate);
        }
      break;
      /////////////////////////////////////////////////////////////////////////////////////
      case  3: //quarter
        {
         CDateTime cdt;
         TimeToStruct(StartDate,cdt);

         //Save current month
         int cur_month=cdt.mon;

         //Inc by day, wait for next month
         while(cur_month==cdt.mon)
           {
            cdt.DayInc(1);
           }

         //Save day
         datetime temp_dt=StructToTime(cdt);

         //Get First Minute of this quarter
         datetime CalcDate=FirstMinute_DaySearch(temp_dt,true);
         if(CalcDate==0) return(0);
         else return(CalcDate);
        }
      break;
      default:
         break;
     }
   return(1);
  }//END OF First Minute at the Next Period
//+------------------------------------------------------------------+
//| First Minute in previous period                                  |
//+------------------------------------------------------------------+   
datetime RHistory::FirstMinute_PreviousPeriod(const uchar period,const datetime Date)
  {
   switch(period)
     {
      case  0: //day
        {
         //Shift to Previous day
         CDateTime cdt;
         TimeToStruct(Date,cdt);

         cdt.DayDec(1);

         //Ignore weekends
         while((cdt.day_of_week==0) || (cdt.day_of_week==6))
           {
            cdt.DayDec(1);
           }

         //Convert to datetime
         datetime dt=StructToTime(cdt);

         //Get First Minute of this day
         datetime CalcDate=FirstMinute_DaySearch(dt,false);
         if(CalcDate==0) return(0);
         else return(CalcDate);
        }
      break;
      /////////////////////////////////////////////////////////////////////////////////////
      case  1: //week
        {
         CDateTime cdt;
         TimeToStruct(Date,cdt);

         //Search for previous Saturday 
         while(cdt.day_of_week!=6)
           {
            cdt.DayDec(1);
           }

         //Convert to datetime
         datetime dt=StructToTime(cdt);

         //Get first working day of this (previous week)
         datetime temp_dt=First_Work_Day_In_Week(dt);

         //Get First Minute of this week
         datetime CalcDate=FirstMinute_DaySearch(temp_dt,false);
         if(CalcDate==0) return(0);
         else return(CalcDate);
        }
      break;
      /////////////////////////////////////////////////////////////////////////////////////
      case  2: //month
        {
         //Shift to find previous month
         CDateTime cdt;
         TimeToStruct(Date,cdt);

         //Save current month
         int cur_month=cdt.mon;

         //Decriment days, while curren month, stop if previous 
         while(cur_month==cdt.mon)
           {
            cdt.DayDec(1);
           }

         //Convert to datetime
         datetime dt=StructToTime(cdt);

         //Get first workind day in current month
         uint day_num=First_Work_Day_In_Month(dt);

         //Change to this day          
         cdt.day=(int)day_num;

         //Save day
         datetime temp_dt=StructToTime(cdt);

         //Get First minute of this month
         datetime CalcDate=FirstMinute_DaySearch(temp_dt,true);
         if(CalcDate==0) return(0);
         else return(CalcDate);
        }
      break;
      /////////////////////////////////////////////////////////////////////////////////////
      case  3: //quarter
        {
         CDateTime cdt;
         TimeToStruct(Date,cdt);

         //Save current month
         int cur_month=cdt.mon;

         //Dec 3 months
         cdt.MonDec(3);

         //Save day
         datetime temp_dt=StructToTime(cdt);

         //Get first workind day in current month
         uint day_num=First_Work_Day_In_Month(temp_dt);

         //Change to this day          
         cdt.day=(int)day_num;

         //Save day
         temp_dt=StructToTime(cdt);

         //Get First Minute of this quarter
         datetime CalcDate=FirstMinute_DaySearch(temp_dt,true);
         if(CalcDate==0) return(0);
         else return(CalcDate);
        }
      break;
      default:
         break;
     }
   return(1);
  }//END OF the First Minute in Previous Period
//+------------------------------------------------------------------+
//| LastMinuteInPeriod                                               |
//+------------------------------------------------------------------+ 
datetime RHistory::LastMinute_NextPeriod(const uchar period,const datetime StartDate)
  {
   switch(period)
     {
      case  0: //day
        {
         //Get Last Minute of this day
         datetime StopDate=LastMinute_DaySearch(StartDate,true);
         if(StopDate==0) return(0);
         else return(StopDate);
        }
      break;
      /////////////////////////////////////////////////////////////////////////////////////
      case  1: //week
        {
         //(From Monday to Saturday)
         //Get last workind day in current week(Friday)
         datetime temp_dt=Last_Work_Day_In_Week(StartDate);

         //Get Last Minute of this week
         datetime StopDate=LastMinute_DaySearch(temp_dt,false);
         if(StopDate==0) return(0);
         else return(StopDate);
        }
      break;
      /////////////////////////////////////////////////////////////////////////////////////
      case  2: //month
        {
         CDateTime cdt;
         TimeToStruct(StartDate,cdt);

         //Get last workind day in current month
         uint day_num=Last_Work_Day_In_Month(StartDate);

         //Change to this day          
         cdt.day=(int)day_num;

         //Save day
         datetime temp_dt=StructToTime(cdt);

         //Get Last Minute of this month
         datetime StopDate=LastMinute_DaySearch(temp_dt,true);
         if(StopDate==0) return(0);
         else return(StopDate);
        }
      break;
      /////////////////////////////////////////////////////////////////////////////////////
      case  3: //quarter
        {
         CDateTime cdt;
         TimeToStruct(StartDate,cdt);

         //Add 2 months
         cdt.mon=cdt.mon+2;

         //set to Feb next year
         if(cdt.mon==14)
           {
            cdt.mon=2;
            cdt.year=cdt.year+1;
           }

         //set to Jan next year
         if(cdt.mon==13)
           {
            cdt.mon=1;
            cdt.year=cdt.year+1;
           }

         //Save day
         datetime temp_dt=StructToTime(cdt);

         //Get last workind day in current month
         uint day_num=Last_Work_Day_In_Month(temp_dt);

         //Change to this day          
         cdt.day=(int)day_num;

         //Save day
         temp_dt=StructToTime(cdt);

         //Get Last Minute of this quarter
         datetime StopDate=LastMinute_DaySearch(temp_dt,true);
         if(StopDate==0) return(0);
         else return(StopDate);
        }
      break;
      default:
         break;
     }
   return(1);
  }//END OF Last Minute at the Next Period
//+------------------------------------------------------------------+
//| Last working day in the week                                     |
//+------------------------------------------------------------------+ 
datetime RHistory::Last_Work_Day_In_Week(datetime Date)
  {
   CDateTime zdate;
   TimeToStruct(Date,zdate);

   while(zdate.day_of_week!=5)
     {
      zdate.DayInc(1);
     }

   return(StructToTime(zdate));
  }//END OF Last Working Day of the Week
//+------------------------------------------------------------------+
//| First working day in the week                                    |
//+------------------------------------------------------------------+ 
datetime RHistory::First_Work_Day_In_Week(datetime Date)
  {
   CDateTime zdate;
   TimeToStruct(Date,zdate);

//Search for Monday
   while(zdate.day_of_week!=1)
     {
      zdate.DayDec(1);
     }

   return(StructToTime(zdate));
  }//End of First Working Day in the Week
//+------------------------------------------------------------------+
//| Last Work Day in the Month                                       |
//+------------------------------------------------------------------+ 
uchar RHistory::Last_Work_Day_In_Month(datetime Date)
  {
   CDateTime zdate;
   TimeToStruct(Date,zdate);

//Gets Last day of the month
   uchar days_in_month=(uchar) zdate.DaysInMonth();

//sets to this date
   zdate.day=days_in_month;

//always convert from cdatetime to datetime
   datetime dt=StructToTime(zdate);
   TimeToStruct(dt,zdate);

//while not working day decriment by 1 
   while((zdate.day_of_week==0) || (zdate.day_of_week==6))
     {
      zdate.DayDec(1);
     }
   return((uchar)zdate.day);
  }//END of last work day in the month
//+------------------------------------------------------------------+
//| First Work Day in the Month                                       |
//+------------------------------------------------------------------+ 
uchar RHistory::First_Work_Day_In_Month(datetime Date)
  {
   CDateTime zdate;
   TimeToStruct(Date,zdate);

   zdate.day=1;

//while not working day inc by 1 
   while((zdate.day_of_week==0) || (zdate.day_of_week==6))
     {
      zdate.DayInc(1);
     }
   return((uchar)zdate.day);
  }//END of first work day in month
//+------------------------------------------------------------------+
//| Find Rate by Index                                               |
//+------------------------------------------------------------------+
bool RHistory::FindRate_by_Index(const uint Index,MqlRates &Rate)
  {
//If unreal index
   if(Index>_TotalRates()-1)
     {
      return(false);
     }

//If Ok
   Rate=m_arr_all_rate[Index];
   return(true);
  }//END of Find Rate by Index
//+------------------------------------------------------------------+
//| Find Rate by Date in minutes or seconds accuracy                 |
//+------------------------------------------------------------------+ 
int RHistory::FindRate_by_Date(const datetime Date,const bool SecondsAccuracy,MqlRates &Rate)
  {
//If Date <  array first Date
   if(Date<_FirstMinute())
     {
      return(-1);
     }

//If Date >  array last Date
//   if(Date>_LastMinuteDayEnds())
   if(Date>_LastMinute())
     {
      return(-2);
     }

//Size of arr
   int arr_size=ArraySize(m_arr_all_rate);

   datetime search_date=Date;

//if Minutes accuracy Reset seconds in searchable date
   if(!SecondsAccuracy)
     {
      CDateTime cdt;
      TimeToStruct(Date,cdt);
      cdt.sec=0;
      search_date=StructToTime(cdt);
     }

//Search by date
   for(int i=0;i<arr_size;i++)
     {
      if(m_arr_all_rate[i].time==search_date)
        {
         //If found
         Rate=m_arr_all_rate[i];
         return(i);
        }
     }

//If Not Found 
   return(-3);
  }//END OF Find Rate by Date in minutes or seconds accuracy  
//+------------------------------------------------------------------+
//| Find Rate by Date, Forward or backward in time                   |
//+------------------------------------------------------------------+  
int RHistory::FindRate_by_Date_Nearest(const bool SearchDirection,const bool SecondsAccuracy,
                                       const datetime Date,MqlRates &Rate,const uchar SecondsStep,const ushort Trys)
  {
//5 days for search by minutes = 60*24*5=7200 minutes
//In seconds = 7200*600= 432000 seconds with Step=1 second 

   int res=-1;

//If Date <  array first Date
   if(Date<_FirstMinute())
     {
      return(-2);
     }

//If Date >  array last Date
//   if(Date>_LastMinuteDayEnds())
   if(Date>_LastMinute())
     {
      return(-3);
     }

//Size of arr
   int arr_size=ArraySize(m_arr_all_rate);

   datetime search_date=Date;
   CDateTime cdt;
   TimeToStruct(search_date,cdt);

//If Minutes Accuracy
   if(!SecondsAccuracy)
     {
      cdt.sec=0;
      search_date=StructToTime(cdt);
     }

//Current try
   ushort current_try_num=0;

//Search by date
   while(current_try_num<Trys)
     {
      for(int i=0;i<arr_size;i++)
        {
         if(m_arr_all_rate[i].time==search_date)
           {
            //If found
            Rate=m_arr_all_rate[i];
            return(i);
           }
        }//END OF FOR

      //if not found Search forward or backward          
      current_try_num++;

      //FORWARD
      if(SearchDirection==true)
        {//Seconds
         if(SecondsAccuracy)
           {
            cdt.SecInc(SecondsStep);
            search_date=StructToTime(cdt);
           }
         else //Minutes
           {
            cdt.MinInc(1);
            search_date=StructToTime(cdt);
           }
        }//END OF FORWARD
      else//BACKWARD
        {//Seconds
         if(SecondsAccuracy)
           {
            cdt.SecDec(SecondsStep);
            search_date=StructToTime(cdt);
           }
         else //Minutes
           {
            cdt.MinDec(1);
            search_date=StructToTime(cdt);
           }
        }//END OF BACKWARD

      //Check if new search date > LastDate or <FirstDate        
      //If Date <  array first Date
      if(Date<_FirstMinute())
        {
         return(-2);
        }

      //If Date >  array last Date
      //   if(Date>_LastMinuteDayEnds())
      if(Date>_LastMinute())
        {
         return(-3);
        }

     }//END OF TRYS

//If Not Found 
   res=-4;

   return(res);
  }//END OF Find Rate by Date, Forward or backward in time
//+------------------------------------------------------------------+
//| Check Minutes,Rates,Spreads by Count & First|Last date           |
//+------------------------------------------------------------------+ 
bool RHistory::_CheckMRS(void)
  {
//WARINIG! LastMinute  always < LastRate (Ex:LastMinute = 2014.12.31 19:58, LastRate == 2015.01.02 09:00  
//Check if MRS count identical ,else -19
   if(_TotalMinutes()!=_TotalRates() || _TotalMinutes()!=_TotalSpreads() || _TotalRates()!=_TotalSpreads())
     {
      m_result=-19;
      return(false);
     }

//Check if MRS First Date identical, else -20
   if(_FirstMinute()!=_FirstRate().time)
     {
      m_result=-20;
      return(false);
     }

//Check if MRS Last Date identical, else -21
//DO NOT CHANGE TO _LastMinute!
   if(m_arr_all_time[0]!=_LastRate().time)
     {
      m_result=-21;
      return(false);
     }

//If Ok
   return(true);
  }//END OF CHECK MRS
//+------------------------------------------------------------------+
//| Find Spread by Index returns spread                              |
//+------------------------------------------------------------------+
uint RHistory::FindSpread_by_Index(const uint Index)
  {
//If unreal index
   if(Index>_TotalSpreads()-1)
     {
      return(0);
     }

//If Ok
   return(m_arr_all_spread[Index]);
  }//END OF Fins Spread by Index
//+------------------------------------------------------------------+
// Get Indicator Last Buffers                                        |
//+------------------------------------------------------------------+ 
bool RHistory::_GetInd_LastBuffers(double &Signal,double &First,double &Pom,double &Dc)
  {
   int copy_count=5;
   int start_copy_index=0;

//If bars not calculated in indicator, then exit
   int bars_calc=BarsCalculated(m_handle_ind_POM);

   if(bars_calc<0)
     {
      //  Print("Waiting for POM calculations...");
      return(false);
     }

   double temp_Signal[],temp_First[],temp_Pom[],temp_Dc[];

//Get buffers 0-3
   if(CopyBuffer(m_handle_ind_POM,0,start_copy_index,copy_count,temp_Signal)<0)
     {
      m_result=-23;
      return(false);
     }

   if(CopyBuffer(m_handle_ind_POM,1,start_copy_index,copy_count,temp_First)<0)
     {
      m_result=-23;
      return(false);
     }

   if(CopyBuffer(m_handle_ind_POM,2,start_copy_index,copy_count,temp_Pom)<0)
     {
      m_result=-23;
      return(false);
     }

   if(CopyBuffer(m_handle_ind_POM,3,start_copy_index,copy_count,temp_Dc)<0)
     {
      m_result=-23;
      return(false);
     }

//If Ok
   Signal=temp_Signal[0];
   First=temp_First[0];
   Pom=temp_Pom[0];
   Dc=temp_Dc[0];

   return(true);

  }//END of GetInd_POMT  
//+------------------------------------------------------------------+
//| Connect Indicator                                                |
//+------------------------------------------------------------------+ 
bool RHistory::_ConnectIndicator(void)
  {//path:RIndicators//POM3
   m_handle_ind_POM=iCustom(m_pair,0,m_ind_path,m_bottle_size);
   if(m_handle_ind_POM<0)
     {
      return(false);
     }
   return(true);
  }//END OF Connect Indicator
//+------------------------------------------------------------------+
//| Form Priming data with Struct only                               |
//+------------------------------------------------------------------+ 
bool RHistory::_FormPrimingData(const bool Priming1,const TIMEMARKS &TimeMarks,STRUCT_Priming &Priming)
  {
//Priming 1 =True , do with p1, else with p2

   datetime Priming_Start=0;
   datetime Priming_Stop=0;

//If bars not calculated in indicator, then exit
   int bars_calc=BarsCalculated(m_handle_ind_POM);

   if(bars_calc<0)
     {
      //  Print("Waiting for POM calculations...");
      return(false);
     }

//Check Priming1 or Priming2
   if(Priming1)
     {
      Priming_Start=TimeMarks.P1_Start;
      Priming_Stop=TimeMarks.P1_Stop;
     }
   else //Priming2
     {
      Priming_Start=TimeMarks.P2_Start;
      Priming_Stop=TimeMarks.P2_Stop;
     }

//Rates
   int copyed_rates=CopyRates(m_pair,0,Priming_Start,Priming_Stop,Priming.Rates);
   if(copyed_rates<0)
     {
      m_result=-24;
      return(false);
     }

//Spread
   int copyed_spread=CopySpread(m_pair,0,Priming_Start,Priming_Stop,Priming.Spread);
   if(copyed_spread<0)
     {
      m_result=-25;
      return(false);
     }

//Signal Open
   int copyed_singal_o=CopyBuffer(m_handle_ind_POM,4,Priming_Start,Priming_Stop,Priming.Signal_Open);
   if(copyed_singal_o<0)
     {
      m_result=-23;
      return(false);
     }

//Signal High
   int copyed_singal_h=CopyBuffer(m_handle_ind_POM,8,Priming_Start,Priming_Stop,Priming.Signal_High);
   if(copyed_singal_h<0)
     {
      m_result=-23;
      return(false);
     }

//Signal Low
   int copyed_singal_l=CopyBuffer(m_handle_ind_POM,12,Priming_Start,Priming_Stop,Priming.Signal_Low);
   if(copyed_singal_l<0)
     {
      m_result=-23;
      return(false);
     }

//Signal Close
   int copyed_singal_c=CopyBuffer(m_handle_ind_POM,0,Priming_Start,Priming_Stop,Priming.Signal_Close);
   if(copyed_singal_c<0)
     {
      m_result=-23;
      return(false);
     }

//First Open
   int copyed_first_o=CopyBuffer(m_handle_ind_POM,5,Priming_Start,Priming_Stop,Priming.First_Open);
   if(copyed_first_o<0)
     {
      m_result=-23;
      return(false);
     }

//First High
   int copyed_first_h=CopyBuffer(m_handle_ind_POM,9,Priming_Start,Priming_Stop,Priming.First_High);
   if(copyed_first_h<0)
     {
      m_result=-23;
      return(false);
     }

//First Low
   int copyed_first_l=CopyBuffer(m_handle_ind_POM,13,Priming_Start,Priming_Stop,Priming.First_Low);
   if(copyed_first_l<0)
     {
      m_result=-23;
      return(false);
     }

//First Close
   int copyed_first_c=CopyBuffer(m_handle_ind_POM,1,Priming_Start,Priming_Stop,Priming.First_Close);
   if(copyed_first_c<0)
     {
      m_result=-23;
      return(false);
     }

//Pom Open
   int copyed_pom_o=CopyBuffer(m_handle_ind_POM,6,Priming_Start,Priming_Stop,Priming.Pom_Open);
   if(copyed_pom_o<0)
     {
      m_result=-23;
      return(false);
     }

//Pom High
   int copyed_pom_h=CopyBuffer(m_handle_ind_POM,10,Priming_Start,Priming_Stop,Priming.Pom_High);
   if(copyed_pom_h<0)
     {
      m_result=-23;
      return(false);
     }

//Pom Low
   int copyed_pom_l=CopyBuffer(m_handle_ind_POM,14,Priming_Start,Priming_Stop,Priming.Pom_Low);
   if(copyed_pom_l<0)
     {
      m_result=-23;
      return(false);
     }

//Pom Close
   int copyed_pom_c=CopyBuffer(m_handle_ind_POM,2,Priming_Start,Priming_Stop,Priming.Pom_Close);
   if(copyed_pom_c<0)
     {
      m_result=-23;
      return(false);
     }

//Dc Open
   int copyed_dc_o=CopyBuffer(m_handle_ind_POM,7,Priming_Start,Priming_Stop,Priming.Dc_Open);
   if(copyed_dc_o<0)
     {
      m_result=-23;
      return(false);
     }

//Dc High
   int copyed_dc_h=CopyBuffer(m_handle_ind_POM,11,Priming_Start,Priming_Stop,Priming.Dc_High);
   if(copyed_dc_h<0)
     {
      m_result=-23;
      return(false);
     }

//Dc Low
   int copyed_dc_l=CopyBuffer(m_handle_ind_POM,15,Priming_Start,Priming_Stop,Priming.Dc_Low);
   if(copyed_dc_l<0)
     {
      m_result=-23;
      return(false);
     }

//Dc Close
   int copyed_dc_c=CopyBuffer(m_handle_ind_POM,3,Priming_Start,Priming_Stop,Priming.Dc_Close);
   if(copyed_dc_c<0)
     {
      m_result=-23;
      return(false);
     }

//Debug
//  _ExportFeedToCSV(true,Priming,Priming1);

//Check if arrays have identical elements count
   if(((copyed_rates+copyed_singal_c+copyed_spread+copyed_pom_c+copyed_first_c+copyed_dc_c)/6)!=copyed_rates)
     {
      m_result=-26;
      Print("Warning! Data not identical!");
      return(false);
     }

//If Ok
   return(true);
  }//END of FormPrimingData (structure)  
//+------------------------------------------------------------------+
//| Fill Priming data wo Indicator                                   |
//+------------------------------------------------------------------+ 
int RHistory::_FillPriming(const bool Priming1,const TIMEMARKS &TimeMarks,MqlRates &Priming[])
  {
//Priming 1 =True , do with p1, else with p2

   datetime Priming_Start=0;
   datetime Priming_Stop=0;

//Check Priming1 or Priming2
   if(Priming1)
     {
      Priming_Start=TimeMarks.P1_Start;
      Priming_Stop=TimeMarks.P1_Stop;
     }
   else //Priming2
     {
      Priming_Start=TimeMarks.P2_Start;
      Priming_Stop=TimeMarks.P2_Stop;
     }

//Rates
   int copyed_rates=CopyRates(m_pair,0,Priming_Start,Priming_Stop,Priming);
   if(copyed_rates<0)
     {
      m_result=-24;
      return(false);
     }
   else
     {//if ok!
      return(copyed_rates);
     }

//Debug
//  _ExportFeedToCSV(true,Priming,Priming1);
  }//END of FillPriming (wo indicator)    
//+------------------------------------------------------------------+
//| Export Rates to CSV                                              |
//+------------------------------------------------------------------+ 
bool RHistory::_ExportRatesToCSV(const bool ReverseWrite)
  {
//Check if Rates already loaded to memory
   if(!m_processed)
     {
      Print(__FUNCTION__+" Data not loaded yet..");
      return(false);
     }

//Get Server Broker Name
   string Server=AccountInfoString(ACCOUNT_SERVER);

//Path for Export ServerRatesEURUSD2010.01.01_2016.04.01
   string path=Server+"Rates"+m_pair+TimeToString(m_from_date,TIME_DATE)+"_"+TimeToString(m_to_date,TIME_DATE)+".csv";

//If BD not NULL
   if(m_copyed_all_rates<=1)
     {
      m_result=-12;
      return(false);
     }

//If exist delete
   if(FileIsExist(path,FILE_COMMON)) FileDelete(path,FILE_COMMON);

//Init file for write (csv) \r\n
   int file_h1=FileOpen(path,FILE_READ|FILE_WRITE|FILE_BIN|FILE_COMMON|FILE_CSV|FILE_ANSI);
   if(file_h1==INVALID_HANDLE) return(false);

//---Export to CSV
//Get Size of Rates Array
   int arrSize=ArraySize(m_arr_all_rate);
   string s1;

//Main Circle
//If not Reverse Write
   if(!ReverseWrite)
     {
      //Write oldest rate to the end of file (and NOW date to the first string)
      for(int i=0;i<arrSize;i++)
        {
         s1=IntegerToString(i)+","                                     //#ID
            +TimeToString(m_arr_all_rate[i].time,TIME_DATE|TIME_MINUTES|TIME_SECONDS)+","     //Time in seconds 
            +DoubleToString(m_arr_all_rate[i].open,5)+","              //OPEN 
            +DoubleToString(m_arr_all_rate[i].high,5)+","              //HIGH
            +DoubleToString(m_arr_all_rate[i].low,5)+","               //LOW
            +DoubleToString(m_arr_all_rate[i].close,5)+","             //CLOSE
            +IntegerToString(m_arr_all_rate[i].tick_volume)+","        //Tick Volume
            +IntegerToString(m_arr_all_rate[i].real_volume)+","        //Real Volume
            +IntegerToString(m_arr_all_rate[i].spread)                 //Spread
            +"\r\n";
         FileWrite(file_h1,s1);
        }//End of for
     }//End of NOT Reverse Write

   if(ReverseWrite)
     {
      //Write oldest date first to file and NOW date to the End of file   
      for(int i=arrSize-1;i>-1;i--)
        {
         s1=IntegerToString(i)+","                                     //#ID
            +TimeToString(m_arr_all_rate[i].time,TIME_DATE|TIME_MINUTES|TIME_SECONDS)+","     //Time in seconds 
            +DoubleToString(m_arr_all_rate[i].open,5)+","              //OPEN 
            +DoubleToString(m_arr_all_rate[i].high,5)+","              //HIGH
            +DoubleToString(m_arr_all_rate[i].low,5)+","               //LOW
            +DoubleToString(m_arr_all_rate[i].close,5)+","             //CLOSE
            +IntegerToString(m_arr_all_rate[i].tick_volume)+","        //Tick Volume
            +IntegerToString(m_arr_all_rate[i].real_volume)+","        //Real Volume
            +IntegerToString(m_arr_all_rate[i].spread)                 //Spread
            +"\r\n";
         FileWrite(file_h1,s1);
        }//End of for
     }//END OF Reverse Write  

//Close file
   FileClose(file_h1);

//If ok    
   Alert("Ok, File Created in COMMON folder: "+path);
   return(true);
  }//END of ExportRates to CSV
//+------------------------------------------------------------------+
//| Export Rates to BIN                                              |
//+------------------------------------------------------------------+ 
bool RHistory::_ExportRatesToBIN(const bool ReverseWrite)
  {
//Check if Rates already loaded to memory
   if(!m_processed)
     {
      Print(__FUNCTION__+" Data not loaded yet..");
      return(false);
     }

//If BD not NULL
   if(m_copyed_all_rates<=1)
     {
      m_result=-12;
      return(false);
     }

//Get Server Broker Name
   string Server=AccountInfoString(ACCOUNT_SERVER);

//Path for Export ServerRatesEURUSD2010.01.01_2016.04.01
   string path=Server+"Rates"+m_pair+TimeToString(m_from_date,TIME_DATE)+"_"+TimeToString(m_to_date,TIME_DATE)+".bin";

//If exist delete
   if(FileIsExist(path,FILE_COMMON)) FileDelete(path,FILE_COMMON);

//Init file
   int  file_h1=FileOpen(path,FILE_READ|FILE_WRITE|FILE_BIN|FILE_COMMON);
   if(file_h1==INVALID_HANDLE)  return(false);

//Get Size of Rates Array
   int arrSize=ArraySize(m_arr_all_rate);

//If not Reverse Write
   if(!ReverseWrite)
     {
      //Write oldest rate to the end of file (and NOW date to the first string)
      for(int i=0;i<arrSize;i++)
         FileWriteStruct(file_h1,m_arr_all_rate[i]);
     }//End of NOT Reverse Write
   else
     {
      //Write oldest date first to file and NOW date to the End of file   
      for(int i=arrSize-1;i>-1;i--)
         FileWriteStruct(file_h1,m_arr_all_rate[i]);
     }//END OF Reverse Write  

//Close file
   FileClose(file_h1);

//If ok    
   Alert("Ok, File Created in COMMON folder: "+path);
   return(true);
  }//END of ExportRates to BIN
//+------------------------------------------------------------------+
//| Export Indicator Feed to CSV (date,ohlc,spread,tickvol,WF,POM,DC,SIGNAL)|
//+------------------------------------------------------------------+ 
bool RHistory::_ExportIndicatorFeedToCSV(const bool ReverseWrite,const STRUCT_Priming &Priming,const bool Priming1)
  {
//Check if Rates already loaded to memory
   if(!m_processed)
     {
      Print(__FUNCTION__+" Data not loaded yet..");
      return(false);
     }

//Get Server Broker Name
   string Server=AccountInfoString(ACCOUNT_SERVER);

//Path for Export (0=Priming1 or 1=Priming2)ServerRatesEURUSD2010.01.01_2016.04.01
   string path=(string)(int)Priming1+Server+"IndFeed"+m_pair+TimeToString(m_from_date,TIME_DATE)+
               "_"+TimeToString(m_to_date,TIME_DATE)+".csv";

//If BD not NULL
   if(m_copyed_all_rates<=1)
     {
      m_result=-12;
      return(false);
     }

//If exist delete
   if(FileIsExist(path,FILE_COMMON)) FileDelete(path,FILE_COMMON);

//Init file for write (csv) \r\n
   int file_h1=FileOpen(path,FILE_READ|FILE_WRITE|FILE_BIN|FILE_COMMON|FILE_CSV|FILE_ANSI);
   if(file_h1==INVALID_HANDLE) return(false);

//---Export to CSV
//Get Size of Rates Array
   int arrSize=ArraySize(Priming.Rates);
   string s1;

//Main Circle
//If not Reverse Write
   if(!ReverseWrite)
     {
      //Write oldest rate to the end of file (and NOW date to the first string)
      for(int i=0;i<arrSize;i++)
        {
         s1=IntegerToString(i)+","                                     //#ID
            +TimeToString(Priming.Rates[i].time,TIME_DATE|TIME_MINUTES|TIME_SECONDS)+","     //Time in seconds 
            +DoubleToString(Priming.Rates[i].open,5)+","              //OPEN 
            +DoubleToString(Priming.Rates[i].high,5)+","              //HIGH
            +DoubleToString(Priming.Rates[i].low,5)+","               //LOW
            +DoubleToString(Priming.Rates[i].close,5)+","             //CLOSE
            +IntegerToString(Priming.Rates[i].tick_volume)+","        //Tick Volume
            +IntegerToString(Priming.Rates[i].real_volume)+","        //Real Volume
            +IntegerToString(Priming.Rates[i].spread)+","             //Spread
            +DoubleToString(Priming.First_Open[i],1)+","              //First Open
            +DoubleToString(Priming.First_High[i],1)+","              //First High  
            +DoubleToString(Priming.First_Low[i],1)+","               //Fist Low
            +DoubleToString(Priming.First_Close[i],1)+","             //First Close
            +DoubleToString(Priming.Pom_Open[i],2)+","                //Pom Open
            +DoubleToString(Priming.Pom_High[i],2)+","                //Pom High  
            +DoubleToString(Priming.Pom_Low[i],2)+","                 //Pom Low
            +DoubleToString(Priming.Pom_Close[i],2)+","               //Pom Close  
            +DoubleToString(Priming.Signal_Open[i],1)+","             //Signal Open
            +DoubleToString(Priming.Signal_High[i],1)+","             //Signal High  
            +DoubleToString(Priming.Signal_Low[i],1)+","              //Signal Low
            +DoubleToString(Priming.Signal_Close[i],1)+","            //Signal Close
            +DoubleToString(Priming.Dc_Open[i],2)+","                 //Dc Open
            +DoubleToString(Priming.Dc_High[i],2)+","                 //Dc High  
            +DoubleToString(Priming.Dc_Low[i],2)+","                  //Dc Low
            +DoubleToString(Priming.Dc_Close[i],2)+","                //Dc Close
            +"\r\n";
         FileWrite(file_h1,s1);
        }//End of for
     }//End of NOT Reverse Write

   if(ReverseWrite)
     {
      //Write oldest date first to file and NOW date to the End of file   
      for(int i=arrSize-1;i>-1;i--)
        {
         s1=IntegerToString(i)+","                                     //#ID
            +TimeToString(Priming.Rates[i].time,TIME_DATE|TIME_MINUTES|TIME_SECONDS)+","     //Time in seconds 
            +DoubleToString(Priming.Rates[i].open,5)+","              //OPEN 
            +DoubleToString(Priming.Rates[i].high,5)+","              //HIGH
            +DoubleToString(Priming.Rates[i].low,5)+","               //LOW
            +DoubleToString(Priming.Rates[i].close,5)+","             //CLOSE
            +IntegerToString(Priming.Rates[i].tick_volume)+","        //Tick Volume
            +IntegerToString(Priming.Rates[i].real_volume)+","        //Real Volume
            +IntegerToString(Priming.Rates[i].spread)+","             //Spread
            +DoubleToString(Priming.First_Open[i],1)+","              //First Open
            +DoubleToString(Priming.First_High[i],1)+","              //First High  
            +DoubleToString(Priming.First_Low[i],1)+","               //Fist Low
            +DoubleToString(Priming.First_Close[i],1)+","             //First Close
            +DoubleToString(Priming.Pom_Open[i],2)+","                //Pom Open
            +DoubleToString(Priming.Pom_High[i],2)+","                //Pom High  
            +DoubleToString(Priming.Pom_Low[i],2)+","                 //Pom Low
            +DoubleToString(Priming.Pom_Close[i],2)+","               //Pom Close  
            +DoubleToString(Priming.Signal_Open[i],1)+","             //Signal Open
            +DoubleToString(Priming.Signal_High[i],1)+","             //Signal High  
            +DoubleToString(Priming.Signal_Low[i],1)+","              //Signal Low
            +DoubleToString(Priming.Signal_Close[i],1)+","            //Signal Close
            +DoubleToString(Priming.Dc_Open[i],2)+","                 //Dc Open
            +DoubleToString(Priming.Dc_High[i],2)+","                 //Dc High  
            +DoubleToString(Priming.Dc_Low[i],2)+","                  //Dc Low
            +DoubleToString(Priming.Dc_Close[i],2)+","                //Dc Close
            +"\r\n";
         FileWrite(file_h1,s1);
        }//End of for
     }//END OF Reverse Write  

//Close file
   FileClose(file_h1);

//If ok    
   Alert("Ok, IndFeed Created in COMMON folder: "+path);
   return(true);
  }//END of Export Indicator Feed to CSV
//+------------------------------------------------------------------+
// Calculate TICK_VOLUME inside OHLC 1 minute                        |
//+------------------------------------------------------------------+ 
bool RHistory::_CalculateTickVolume(const MqlRates &Rates[],STRUCT_TICKVOL_OHLC &TickVol[])
  {
//Get Size of Array
   int ArrSize=ArraySize(Rates);

//Resize TickVol Array
   ArrayResize(TickVol,ArrSize);

//O+H+L+C=0 Counter
   uint zero_ohlc_sum=0;

//Temp Calculations
   double o=0,h=0,l=0,c=0,sum=0,om=0,hm=0,lm=0,cm=0;

//Fill 0 - item with =0
   TickVol[ArrSize-1].Open_TickVol=0;
   TickVol[ArrSize-1].High_TickVol=0;
   TickVol[ArrSize-1].Low_TickVol=0;
   TickVol[ArrSize-1].Close_TickVol=0;
   TickVol[ArrSize-1].Time=Rates[ArrSize-1].time;

//MAIN CIRCLE (-1 for first previous Close calculation & -1 for 0-element)
   for(int i=ArrSize-2;i>-1;i--)
     {
      o=MathAbs(Rates[i].open-Rates[i+1].close);
      h=MathAbs(Rates[i].high-Rates[i].open);
      l=MathAbs(Rates[i].low-Rates[i].high);
      c=MathAbs(Rates[i].close-Rates[i].low);

      //Sum
      sum=o+h+l+c;

      //Exception if SUM[4]=0
      if(sum==0)
        {
         //res = 0
         TickVol[i].Open_TickVol=0;
         TickVol[i].High_TickVol=0;
         TickVol[i].Low_TickVol=0;
         TickVol[i].Close_TickVol=0;
         TickVol[i].Time=Rates[i].time;

         //         Print(__FUNCTION__+" Sum of O,H,L,C==0!");

         //Inc Counter
         zero_ohlc_sum++;
         continue;
        }//End of sum

      //Multyplication
      om=Rates[i].tick_volume*o;
      hm=Rates[i].tick_volume*h;
      lm=Rates[i].tick_volume*l;
      cm=Rates[i].tick_volume*c;

      //Division
      TickVol[i].Open_TickVol=om/sum;
      TickVol[i].High_TickVol=hm/sum;
      TickVol[i].Low_TickVol=lm/sum;
      TickVol[i].Close_TickVol=cm/sum;

      //Fill Time
      TickVol[i].Time=Rates[i].time;
     }//END OF FOR

//If ok return true
   return(true);
  }  //END of Calc TickVol
//+------------------------------------------------------------------+
//| Calculate OHLC FEED                                              |
//+------------------------------------------------------------------+
bool RHistory::_Calculate_OHLC_Feed(const MqlRates &Rates[],STRUCT_FEED_OHLC &Feed[],const STRUCT_TICKVOL_OHLC &TickVol[])
  {
//Get Size of ArrayOHLC
   int ArrSize=ArraySize(Rates);

//Resize Feed Array ONCE
   ArrayResize(Feed,ArrSize);

//Calculate Start position
   int StartZero=ArrSize-1-m_bottle_size;

//Fill first bottle_size=5 params by zero
   for(int i=ArrSize-1;i>StartZero;i--)
     {
      Feed[i].Open_WhoFirst=0;
      Feed[i].High_WhoFirst=0;
      Feed[i].Low_WhoFirst=0;
      Feed[i].Close_WhoFirst=0;
      Feed[i].Open_pom=0;
      Feed[i].High_pom=0;
      Feed[i].Low_pom=0;
      Feed[i].Close_pom=0;
      Feed[i].Open_signal=0;
      Feed[i].High_signal=0;
      Feed[i].Low_signal=0;
      Feed[i].Close_signal=0;
      Feed[i].Open_dc=0;
      Feed[i].High_dc=0;
      Feed[i].Low_dc=0;
      Feed[i].Close_dc=0;
     }//END of Fill Zero

//Current OHLC template (changed in each O,H,L,C)
   double open=0;
   double high=0;
   double low=0;
   double close=0;

//Main Circle
   for(int i=StartZero;i>-1;i--)
     {
      //OHLC CIRCLE
      //+++++++Open
      open=Rates[i].open;
      high=open;
      low=open;
      close=open;

      //WhoFirst:
      Feed[i].Open_WhoFirst=m_WhoFirst_OHLC(Rates,i,open,high,low,close);

      //POM+Signal
      Feed[i].Open_pom=m_POM_Signal_OHLC(open,high,low,close,Feed[i].Open_WhoFirst,Feed[i].Open_signal);

      //DC 
      Feed[i].Open_dc=m_DC_OHLC(0,Rates,i,open,high,low,close,TickVol);

      //Check WhoFirst High or Low inside 1 OHLC minute by MT5 algorithm
      if(m_MT5_HighFirst_OHLC(Rates[i])==true)
        {
         //+++++++High
         open=Rates[i].open;
         high=Rates[i].high;
         low=open;
         close=high;

         //WhoFirst:
         Feed[i].High_WhoFirst=m_WhoFirst_OHLC(Rates,i,open,high,low,close);

         //POM+Signal
         Feed[i].High_pom=m_POM_Signal_OHLC(open,high,low,close,Feed[i].High_WhoFirst,Feed[i].High_signal);

         //DC 
         Feed[i].High_dc=m_DC_OHLC(1,Rates,i,open,high,low,close,TickVol);
        }//END OF HIGH
      else
        {
         //+++++++Low
         open=Rates[i].open;
         high=Rates[i].high;
         low=Rates[i].low;
         close=low;

         //WhoFirst:
         Feed[i].Low_WhoFirst=m_WhoFirst_OHLC(Rates,i,open,high,low,close);

         //POM+Signal
         Feed[i].Low_pom=m_POM_Signal_OHLC(open,high,low,close,Feed[i].Low_WhoFirst,Feed[i].Low_signal);

         //DC 
         Feed[i].Low_dc=m_DC_OHLC(2,Rates,i,open,high,low,close,TickVol);
        }//END OF LOW

      //+++++++Close
      open=Rates[i].open;
      high=Rates[i].high;
      low=Rates[i].low;
      close=Rates[i].close;

      //WhoFirst:
      Feed[i].Close_WhoFirst=m_WhoFirst_OHLC(Rates,i,open,high,low,close);

      //POM+Signal
      Feed[i].Close_pom=m_POM_Signal_OHLC(open,high,low,close,Feed[i].Close_WhoFirst,Feed[i].Close_signal);

      //DC 
      Feed[i].Close_dc=m_DC_OHLC(3,Rates,i,open,high,low,close,TickVol);

     }//END of MAIN CIRCLE

//If Ok
   return(true);
  }//END of CALC OHLC FEED
//+------------------------------------------------------------------+
//| Calculate PomSignal by Last one minute for OHLC                  |
//+------------------------------------------------------------------+
double RHistory::m_POM_Signal_OHLC(const double &Open,const double &High,const double &Low,const double &Close,
                                   const char &WhoFirst,char &POM_SIGNAL)
  {
   double a=0;
   double b=0;
   double c=0;
   uchar m=0;
   uchar n=0;

//Current POM Signal
   POM_SIGNAL=NOSIGNAL;

//Private cases:
   if(WhoFirst<LowFirst || WhoFirst>HighFirst) return(0);
   if(WhoFirst==EqualFirst) return(0);

//Calc abc for HIGH first on last bottle
   if(WhoFirst==HighFirst)
     {
      a=High-Open;// +
      b=Low-High; // -
      c=Close-Low;// +
     }
   else//Calc abc for LOW first on last bottle        
   if(WhoFirst==LowFirst)
     {
      a=Low-Open;// -
      b=High-Low;// +
      c=Close-High;// -
     }

// Jumps +/-
   if(a>0) m++; else if(a<0) n++;
   if(b>0) m++; else if(b<0) n++;
   if(c>0) m++; else if(c<0) n++;

//Limitations
   if(m*n<1 || m*n>2)return(0);
   if(m*n==1 && High==Close) return(0);
   if((m*n==2) && (High-Close+Open-Low==0)) return(0);

//--- POM ver: 10.02.2015 
//2:1
   if(m==2 && n==1)
     {
      //IF A+ >1 then UP Trend  
      double ga=((a+c)/2)/MathAbs(b);

      //(case 4)  
      if(MathAbs(b)>((a+c)/2))
        {
         POM_SIGNAL=SELL;
        }
      double pom=1-(1/(1+ga));

      return(pom);
     }//end of 2:1

//1:2  
   if(m==1 && n==2)
     {
      //IF A- <1 then DOWN Trend
      double ga=b/(MathAbs(a+c)/2);

      //(case 1)  
      if(b>(MathAbs(a+c)/2))
        {
         POM_SIGNAL=BUY;
        }
      double pom=1-(1/(1+ga));

      return(pom);
     }//end of 1:2

//If no POM, private case or unknown error
   return(0);
  }//END of PomSignal for OHLC
//+------------------------------------------------------------------+
//| Calculate DC in last 3 minute for OHLC (include current)         |
//+------------------------------------------------------------------+
double RHistory::m_DC_OHLC(const int OHLC,const MqlRates &Rates[],const int &Start,const double &Open,
                           const double &High,const double &Low,const double &Close,const STRUCT_TICKVOL_OHLC &TickVol[])
  {
   double res=-1;
   uint i=Start;

//Arr for Calc WhoFirst
   MqlRates arr_WF[];
   ArraySetAsSeries(arr_WF,true);
   ArrayResize(arr_WF,3);

//Copy 3 Last minutes to find Min\Max
   for(int j=0;j<3;j++)
     {
      arr_WF[j].open=Rates[i+j].open;
      arr_WF[j].high=Rates[i+j].high;
      arr_WF[j].low=Rates[i+j].low;
      arr_WF[j].close=Rates[i+j].close;
      arr_WF[j].spread=Rates[i+j].spread;

      //All previous tick_volume we get from Total Sum of Tick_Volume
      arr_WF[j].tick_volume=Rates[i+j].tick_volume;

      arr_WF[j].time=Rates[i+j].time;
     }//END of CopyArr   

//Add Current O,H,L,C to last free cell 
   arr_WF[0].open = Open;
   arr_WF[0].high = High;
   arr_WF[0].low=Low;
   arr_WF[0].close=Close;

//Insert Current TickVolume
   switch(OHLC)
     {
      case  0://Open
         arr_WF[0].tick_volume=(long)TickVol[i].Open_TickVol;
         break;

      case  1://High
         arr_WF[0].tick_volume=(long)TickVol[i].High_TickVol;
         break;

      case  2://Low
         arr_WF[0].tick_volume=(long)TickVol[i].Low_TickVol;
         break;

      case  3://Close
         arr_WF[0].tick_volume=(long)TickVol[i].Close_TickVol;
         break;

      case  4://For Close only prices Mode (sum of 4 our voumes)
         arr_WF[0].tick_volume=Rates[i].tick_volume;
         break;
      default:
         break;
     }

   double r0=arr_WF[0].high-arr_WF[0].low;

   double r2=arr_WF[2].high-arr_WF[2].low;

   long t1=arr_WF[2].tick_volume-arr_WF[1].tick_volume;
   double t2=t1*r2;
   if(t2==0)return(res=0); //div 0 exception

   double t3=arr_WF[1].close-arr_WF[2].close;

   double t4=t3/t2;

   long t6=arr_WF[1].tick_volume-arr_WF[0].tick_volume;

   res=t6*t4*r0;
   res= NormalizeDouble(res,5);

//If Ok
   return(res);
  }//END of DC for OHLC
//+------------------------------------------------------------------+
//| WhoFirst in last bottle (5 minutes) for OHLC&Close               |
//+------------------------------------------------------------------+
char RHistory::m_WhoFirst_OHLC(const MqlRates &Rates[],const int &Start,const double &Open,const double &High,
                               const double &Low,const double &Close)
  {
//Iteration num
   int i=Start;

//Default indexes High and Low
   int HighIndex=-1;
   int LowIndex=-1;

//Default High and Low
   double HighMax = INT_MIN;
   double LowMin  = INT_MAX;

//Arr for Calc WhoFirst
   MqlRates arr_WF[];
   ArraySetAsSeries(arr_WF,true);
   ArrayResize(arr_WF,m_bottle_size);

//Copy One Last Bottle to find Min\Max
   for(int j=0;j<m_bottle_size;j++)
     {
      arr_WF[j].open=Rates[i+j].open;
      arr_WF[j].high=Rates[i+j].high;
      arr_WF[j].low=Rates[i+j].low;
      arr_WF[j].close=Rates[i+j].close;
      arr_WF[j].spread=Rates[i+j].spread;
      arr_WF[j].tick_volume=Rates[i+j].tick_volume;
      arr_WF[j].time=Rates[i+j].time;
     }//END of CopyArr   

//Add Current O,H,L,C to last free cell 
   arr_WF[0].open = Open;
   arr_WF[0].high = High;
   arr_WF[0].low=Low;
   arr_WF[0].close=Close;

//Find Max & Min
   for(int z=0;z<m_bottle_size;z++)
     {
      //Max
      if(arr_WF[z].high>HighMax)
        {
         HighMax=arr_WF[z].high;
         HighIndex=z;
        }
      //Min
      if(arr_WF[z].low<LowMin)
        {
         LowMin=arr_WF[z].low;
         LowIndex=z;
        }
     }//END of Find Max & Min

//Find WhoFirst
//Private case H==L
//Private case, when many H or L, and don`t know who >
//Where > Index where early!
   if(HighIndex>LowIndex)  return(HighFirst);
   if(HighIndex<LowIndex)  return(LowFirst);
   if(HighIndex==LowIndex) return(EqualFirst);

//If Err
   return(EqualFirst);
  }//END of WhoFirst for OHLC&ClOSE
//+------------------------------------------------------------------+
//| Calculate Feed on Close prices only                              |
//+------------------------------------------------------------------+
bool RHistory::_Calculate_CLOSE_Feed(const MqlRates &Rates[],STRUCT_FEED_CLOSE &Feed[],const STRUCT_TICKVOL_OHLC &TickVol[])
  {
//Get Size of ArrayOHLC
   int ArrSize=ArraySize(Rates);

//Resize Feed Array ONCE
   ArrayResize(Feed,ArrSize);

//Calculate Start position
   int StartZero=ArrSize-1-m_bottle_size;

//Fill first bottle_size=5 params by zero
   for(int i=ArrSize-1;i>StartZero;i--)
     {
      Feed[i].Close_WhoFirst=0;
      Feed[i].Close_pom=0;
      Feed[i].Close_signal=0;
      Feed[i].Close_dc=0;
     }//END of Fill Zero

//Current OHLC template (changed in each O,H,L,C)
   double open=0;
   double high=0;
   double low=0;
   double close=0;

//Main Circle
   for(int i=StartZero;i>-1;i--)
     {
      //For close prices only
      open=Rates[i].open;
      high=Rates[i].high;
      low=Rates[i].low;
      close=Rates[i].close;

      //WhoFirst:
      Feed[i].Close_WhoFirst=m_WhoFirst_OHLC(Rates,i,open,high,low,close);

      //POM+Signal
      Feed[i].Close_pom=m_POM_Signal_OHLC(open,high,low,close,Feed[i].Close_WhoFirst,Feed[i].Close_signal);

      //DC (OHLC=4 - for Close prices only Mode!)
      Feed[i].Close_dc=m_DC_OHLC(4,Rates,i,open,high,low,close,TickVol);

     }//END of MAIN CIRCLE
//If Ok
   return(true);
  }//End of  CLOSE FEED
//+------------------------------------------------------------------+
//| Export OHLC Feed to CSV (date,ohlc,spread,tickvol,WF,POM,DC,SIGNAL)   |
//+------------------------------------------------------------------+ 
bool RHistory::_ExportOHLCFeedToCSV(const bool ReverseWrite,const MqlRates &Rates[],const STRUCT_FEED_OHLC &Feed[],
                                    const bool Priming1)
  {
//Get Server Broker Name
   string Server=AccountInfoString(ACCOUNT_SERVER);

//Path for Export (0=Priming1 or 1=Priming2)ServerRatesEURUSD2010.01.01_2016.04.01
   string path=(string)(int)Priming1+Server+"OHLCFeed"+m_pair+TimeToString(m_from_date,TIME_DATE)+
               "_"+TimeToString(m_to_date,TIME_DATE)+".csv";

//If exist delete
   if(FileIsExist(path,FILE_COMMON)) FileDelete(path,FILE_COMMON);

//Init file for write (csv) \r\n
   int file_h1=FileOpen(path,FILE_READ|FILE_WRITE|FILE_BIN|FILE_COMMON|FILE_CSV|FILE_ANSI);
   if(file_h1==INVALID_HANDLE) return(false);

//---Export to CSV
//Get Size of Rates Array
   int arrSize=ArraySize(Rates);

//Writable string   
   string s1;

//Main Circle
//If not Reverse Write
   if(!ReverseWrite)
     {
      //Write oldest rate to the end of file (and NOW date to the first string)
      for(int i=0;i<arrSize;i++)
        {
         s1=IntegerToString(i)+","                                     //#ID
            +TimeToString(Rates[i].time,TIME_DATE|TIME_MINUTES|TIME_SECONDS)+","     //Time in seconds 
            +DoubleToString(Rates[i].open,5)+","              //OPEN 
            +DoubleToString(Rates[i].high,5)+","              //HIGH
            +DoubleToString(Rates[i].low,5)+","               //LOW
            +DoubleToString(Rates[i].close,5)+","             //CLOSE
            +IntegerToString(Rates[i].tick_volume)+","        //Tick Volume
            +IntegerToString(Rates[i].real_volume)+","        //Real Volume
            +IntegerToString(Rates[i].spread)+","             //Spread
            +IntegerToString(Feed[i].Open_WhoFirst,1)+","     //First Open
            +IntegerToString(Feed[i].High_WhoFirst,1)+","     //First High  
            +IntegerToString(Feed[i].Low_WhoFirst,1)+","      //Fist Low
            +IntegerToString(Feed[i].Close_WhoFirst,1)+","    //First Close
            +DoubleToString(Feed[i].Open_pom,2)+","           //Pom Open
            +DoubleToString(Feed[i].High_pom,2)+","           //Pom High  
            +DoubleToString(Feed[i].Low_pom,2)+","            //Pom Low
            +DoubleToString(Feed[i].Close_pom,2)+","          //Pom Close  
            +IntegerToString(Feed[i].Open_signal,1)+","       //Signal Open
            +IntegerToString(Feed[i].High_signal,1)+","       //Signal High  
            +IntegerToString(Feed[i].Low_signal,1)+","        //Signal Low
            +IntegerToString(Feed[i].Close_signal,1)+","      //Signal Close
            +DoubleToString(Feed[i].Open_dc,2)+","            //Dc Open
            +DoubleToString(Feed[i].High_dc,2)+","            //Dc High  
            +DoubleToString(Feed[i].Low_dc,2)+","             //Dc Low
            +DoubleToString(Feed[i].Close_dc,2)+","           //Dc Close
            +"\r\n";
         FileWrite(file_h1,s1);
        }//End of for
     }//End of NOT Reverse Write

   if(ReverseWrite)
     {
      //Write oldest date first to file and NOW date to the End of file   
      for(int i=arrSize-1;i>-1;i--)
        {
         s1=IntegerToString(i)+","                                     //#ID
            +TimeToString(Rates[i].time,TIME_DATE|TIME_MINUTES|TIME_SECONDS)+","     //Time in seconds 
            +DoubleToString(Rates[i].open,5)+","              //OPEN 
            +DoubleToString(Rates[i].high,5)+","              //HIGH
            +DoubleToString(Rates[i].low,5)+","               //LOW
            +DoubleToString(Rates[i].close,5)+","             //CLOSE
            +IntegerToString(Rates[i].tick_volume)+","        //Tick Volume
            +IntegerToString(Rates[i].real_volume)+","        //Real Volume
            +IntegerToString(Rates[i].spread)+","             //Spread
            +IntegerToString(Feed[i].Open_WhoFirst,1)+","     //First Open
            +IntegerToString(Feed[i].High_WhoFirst,1)+","     //First High  
            +IntegerToString(Feed[i].Low_WhoFirst,1)+","      //Fist Low
            +IntegerToString(Feed[i].Close_WhoFirst,1)+","    //First Close
            +DoubleToString(Feed[i].Open_pom,2)+","           //Pom Open
            +DoubleToString(Feed[i].High_pom,2)+","           //Pom High  
            +DoubleToString(Feed[i].Low_pom,2)+","            //Pom Low
            +DoubleToString(Feed[i].Close_pom,2)+","          //Pom Close  
            +IntegerToString(Feed[i].Open_signal,1)+","       //Signal Open
            +IntegerToString(Feed[i].High_signal,1)+","       //Signal High  
            +IntegerToString(Feed[i].Low_signal,1)+","        //Signal Low
            +IntegerToString(Feed[i].Close_signal,1)+","      //Signal Close
            +DoubleToString(Feed[i].Open_dc,2)+","            //Dc Open
            +DoubleToString(Feed[i].High_dc,2)+","            //Dc High  
            +DoubleToString(Feed[i].Low_dc,2)+","             //Dc Low
            +DoubleToString(Feed[i].Close_dc,2)+","           //Dc Close
            +"\r\n";
         FileWrite(file_h1,s1);
        }//End of for
     }//END OF Reverse Write  

//Close file
   FileClose(file_h1);

//If ok    
   Alert("Ok, Feed Created in COMMON folder: "+path);
   return(true);
  }//END of Export Non Indicator OHLC Feed to CSV  
//| Export Feed to CSV (date,ohlc,spread,tickvol,WF,POM,DC,SIGNAL)   |
//+------------------------------------------------------------------+ 
bool RHistory::_ExportOHLCTickVolFeedToCSV(const bool ReverseWrite,const STRUCT_TICKVOL_OHLC &Feed[],const bool Priming1)
  {
//Get Server Broker Name
   string Server=AccountInfoString(ACCOUNT_SERVER);

//Path for Export (0=Priming1 or 1=Priming2)ServerRatesEURUSD2010.01.01_2016.04.01
   string path=(string)(int)Priming1+Server+"OHLCTIckVol"+m_pair+TimeToString(m_from_date,TIME_DATE)+
               "_"+TimeToString(m_to_date,TIME_DATE)+".csv";

//If exist delete
   if(FileIsExist(path,FILE_COMMON)) FileDelete(path,FILE_COMMON);

//Init file for write (csv) \r\n
   int file_h1=FileOpen(path,FILE_READ|FILE_WRITE|FILE_BIN|FILE_COMMON|FILE_CSV|FILE_ANSI);
   if(file_h1==INVALID_HANDLE) return(false);

//---Export to CSV
//Get Size of Rates Array
   int arrSize=ArraySize(Feed);

//Writable string   
   string s1;

//Main Circle
//If not Reverse Write
   if(!ReverseWrite)
     {
      //Write oldest rate to the end of file (and NOW date to the first string)
      for(int i=0;i<arrSize;i++)
        {
         s1=IntegerToString(i)+","                                     //#ID
            +TimeToString(Feed[i].Time,TIME_DATE|TIME_MINUTES|TIME_SECONDS)+","     //Time in seconds 
            +DoubleToString(Feed[i].Open_TickVol,5)+","              //OPEN  TickVol
            +DoubleToString(Feed[i].High_TickVol,5)+","              //HIGH  TickVol
            +DoubleToString(Feed[i].Low_TickVol,5)+","               //LOW   TickVol
            +DoubleToString(Feed[i].Close_TickVol,5)+","             //CLOSE TickVol  
            +"\r\n";
         FileWrite(file_h1,s1);
        }//End of for
     }//End of NOT Reverse Write

   if(ReverseWrite)
     {
      //Write oldest date first to file and NOW date to the End of file   
      for(int i=arrSize-1;i>-1;i--)
        {
         s1=IntegerToString(i)+","                                     //#ID
            +TimeToString(Feed[i].Time,TIME_DATE|TIME_MINUTES|TIME_SECONDS)+","     //Time in seconds 
            +DoubleToString(Feed[i].Open_TickVol,5)+","              //OPEN  TickVol
            +DoubleToString(Feed[i].High_TickVol,5)+","              //HIGH  TickVol
            +DoubleToString(Feed[i].Low_TickVol,5)+","               //LOW   TickVol
            +DoubleToString(Feed[i].Close_TickVol,5)+","             //CLOSE TickVol  
            +"\r\n";
         FileWrite(file_h1,s1);
        }//End of for
     }//END OF Reverse Write  

//Close file
   FileClose(file_h1);

//If ok    
   Alert("Ok, OHLC TickVolume Feed Created in COMMON folder: "+path);
   return(true);
  }//END of Export OHLC TickVolume Non Indicator Feed to CSV 
//+------------------------------------------------------------------+
//| Export Close Feed to CSV (date,ohlc,spread,tickvol,WF,POM,DC,SIGNAL)   |
//+------------------------------------------------------------------+ 
bool RHistory::_ExportCloseFeedToCSV(const bool ReverseWrite,const MqlRates &Rates[],const STRUCT_FEED_CLOSE &Feed[],
                                     const bool Priming1)
  {
//Get Server Broker Name
   string Server=AccountInfoString(ACCOUNT_SERVER);

//Path for Export (0=Priming1 or 1=Priming2)ServerRatesEURUSD2010.01.01_2016.04.01
   string path=(string)(int)Priming1+Server+"CloseFeed"+m_pair+TimeToString(m_from_date,TIME_DATE)+
               "_"+TimeToString(m_to_date,TIME_DATE)+".csv";

//If exist delete
   if(FileIsExist(path,FILE_COMMON)) FileDelete(path,FILE_COMMON);

//Init file for write (csv) \r\n
   int file_h1=FileOpen(path,FILE_READ|FILE_WRITE|FILE_BIN|FILE_COMMON|FILE_CSV|FILE_ANSI);
   if(file_h1==INVALID_HANDLE) return(false);

//---Export to CSV
//Get Size of Rates Array
   int arrSize=ArraySize(Rates);

//Writable string   
   string s1;

//Main Circle
//If not Reverse Write
   if(!ReverseWrite)
     {
      //Write oldest rate to the end of file (and NOW date to the first string)
      for(int i=0;i<arrSize;i++)
        {
         s1=IntegerToString(i)+","                                     //#ID
            +TimeToString(Rates[i].time,TIME_DATE|TIME_MINUTES|TIME_SECONDS)+","     //Time in seconds 
            +DoubleToString(Rates[i].open,5)+","              //OPEN 
            +DoubleToString(Rates[i].high,5)+","              //HIGH
            +DoubleToString(Rates[i].low,5)+","               //LOW
            +DoubleToString(Rates[i].close,5)+","             //CLOSE
            +IntegerToString(Feed[i].Close_WhoFirst,5)+","    //Close WhoFirst
            +IntegerToString(Feed[i].Close_signal,5)+","      //Close Signal
            +DoubleToString(Feed[i].Close_pom,5)+","          //Close Pom
            +DoubleToString(Feed[i].Close_dc,5)+","           //Close Dc
            +"\r\n";
         FileWrite(file_h1,s1);
        }//End of for
     }//End of NOT Reverse Write

   if(ReverseWrite)
     {
      //Write oldest date first to file and NOW date to the End of file   
      for(int i=arrSize-1;i>-1;i--)
        {
         s1=IntegerToString(i)+","                                     //#ID
            +TimeToString(Rates[i].time,TIME_DATE|TIME_MINUTES|TIME_SECONDS)+","     //Time in seconds 
            +DoubleToString(Rates[i].open,5)+","              //OPEN 
            +DoubleToString(Rates[i].high,5)+","              //HIGH
            +DoubleToString(Rates[i].low,5)+","               //LOW
            +DoubleToString(Rates[i].close,5)+","             //CLOSE
            +IntegerToString(Feed[i].Close_WhoFirst,5)+","    //Close WhoFirst
            +IntegerToString(Feed[i].Close_signal,5)+","      //Close Signal
            +DoubleToString(Feed[i].Close_pom,5)+","          //Close Pom
            +DoubleToString(Feed[i].Close_dc,5)+","           //Close Dc
            +"\r\n";
         FileWrite(file_h1,s1);
        }//End of for
     }//END OF Reverse Write  

//Close file
   FileClose(file_h1);

//If ok    
   Alert("Ok, Close Feed Created in COMMON folder: "+path);
   return(true);
  }//END of Export Non Indicator Close Feed to CSV  
//+------------------------------------------------------------------+
//| WhoFirst by MT5 OHLC Emulation algorithm (true - High First)     |
//+------------------------------------------------------------------+
bool RHistory::m_MT5_HighFirst_OHLC(const MqlRates &Rates)
  {
//Private Cases:
//Check Zero Tick
   if(Rates.open==Rates.close==Rates.high==Rates.low) return(true);

//Check dogi
   if(Rates.open==Rates.close)
     {
      //Calculate ABS for High and Low
      double absH = MathAbs(Rates.open-Rates.high);
      double absL = MathAbs(Rates.open-Rates.low);

      //Check Dogi O=H=C
      if(Rates.open==Rates.high==Rates.close)
        {
         if(absL > absH) return(false);
         if(absL < absH)  return(true);
        }//END OF O=H=C

      //Check Dogi O=L=C
      if(Rates.open==Rates.low==Rates.close)
        {
         if(absL > absH) return(false);
         if(absL < absH)  return(true);
        }//END OF O=H=C

      //Check dogi absH > absL
      if(absH > absL) return(true);
      if(absH < absL) return(false);
     }//END OF O=C

//Regular cases:
   if(Rates.close > Rates.open) return(false);
   if(Rates.close < Rates.open) return(true);


//If Unknown situation return HighFirst  
   return(true);
  }//END OF WhoFirst by MT5
//+------------------------------------------------------------------+
