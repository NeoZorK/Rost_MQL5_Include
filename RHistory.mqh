//+------------------------------------------------------------------+
//|                                                     RHistory.mqh |
//|                             Copyright 2016, Shcherbyna Rostyslav |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Shcherbyna Rostyslav"
#property link      ""
#property version   "1.1"

#include <Tools\DateTime.mqh>
#include <RInclude\RStructs.mqh>
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
1.2
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
   bool              m_imported;                //Is Imported
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

public:
                     RHistory(const string pair,const string path_to_ind,const uchar bottlesize);
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
   bool              _ExportDB();
   //Export to readable txt file
   bool              _ExportText();
   //Test Import DB
   bool              _ImportDB(const string pair);
   //Get latest Indicator buffers           
   bool              _GetInd_LastBuffers(double &Signal,double &First,double &Pom,double &Dc);
   //Forms primings data for prediction(copy rates\spreads\ind arrays)
   bool              _FormPrimingData(const bool Priming1,const TIMEMARKS &timemarks,MqlRates &arr_Rates[],
                                      int &arr_Spreads[],double &arr_Signals[],
                                      double &arr_Firsts[],double &arr_Poms[],double &arr_Dc_Close[],
                                      double &arr_Dc_Open[],double &arr_Dc_High[],double &arr_Dc_Low[]);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
RHistory::RHistory(const string pair,const string path_to_ind,const uchar bottlesize):m_initialised(false),
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
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Export first & last days as text file                            |
//+------------------------------------------------------------------+
bool  RHistory::_ExportText(void)
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
  }
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
  }
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

//   ArrayFill(m_arr_day_begins,0,1,0);
//   ArrayFill(m_arr_day_ends,0,1,0);
//   ArrayFill(m_arr_all_time,0,1,0);
  }
//+------------------------------------------------------------------+
//| Import DB                                                        |
//+------------------------------------------------------------------+
bool  RHistory::_ImportDB(const string pair)
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
  }
//+------------------------------------------------------------------+
//| Export DB                                                        |
//+------------------------------------------------------------------+
bool RHistory::_ExportDB(void)
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
  }
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
  }
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
  }
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
  }
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
  }
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
  }
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
  }
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
  }
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
  }
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
  }
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
  }
//+------------------------------------------------------------------+
//| First working day in the week                                     |
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
  }
//----------------------------------------------------------------------------------------------------------------------//
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
  }
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
  }
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
  }
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
  }
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
  }
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
  }
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
  }
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
  }
//+------------------------------------------------------------------+
//| Form priming data rates\spreads\Indicator arrays                 |
//+------------------------------------------------------------------+ 
bool RHistory::_FormPrimingData(const bool Priming1,const TIMEMARKS &timemarks,MqlRates &arr_Rates[],int &arr_Spreads[],
                                double &arr_Signals[],double &arr_Firsts[],double &arr_Poms[],
                                double &arr_Dc_Close[],double &arr_Dc_Open[],double &arr_Dc_High[],double &arr_Dc_Low[])
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
      Priming_Start=timemarks.P1_Start;
      Priming_Stop=timemarks.P1_Stop;
     }
   else //Priming2
     {
      Priming_Start=timemarks.P2_Start;
      Priming_Stop=timemarks.P2_Stop;
     }

//Rates
   int copyed_rates=CopyRates(m_pair,0,Priming_Start,Priming_Stop,arr_Rates);
   if(copyed_rates<0)
     {
      m_result=-24;
      return(false);
     }

//Spread
   int copyed_spread=CopySpread(m_pair,0,Priming_Start,Priming_Stop,arr_Spreads);
   if(copyed_spread<0)
     {
      m_result=-25;
      return(false);
     }

//Signal
   int copyed_singal=CopyBuffer(m_handle_ind_POM,0,Priming_Start,Priming_Stop,arr_Signals);
   if(copyed_singal<0)
     {
      m_result=-23;
      return(false);
     }

//First
   int copyed_first=CopyBuffer(m_handle_ind_POM,1,Priming_Start,Priming_Stop,arr_Firsts);
   if(copyed_first<0)
     {
      m_result=-23;
      return(false);
     }

//Pom
   int copyed_pom=CopyBuffer(m_handle_ind_POM,2,Priming_Start,Priming_Stop,arr_Poms);
   if(copyed_pom<0)
     {
      m_result=-23;
      return(false);
     }

//Dc Open
   int copyed_dc_o=CopyBuffer(m_handle_ind_POM,7,Priming_Start,Priming_Stop,arr_Dc_Open);
   if(copyed_dc_o<0)
     {
      m_result=-23;
      return(false);
     }

//Dc High
   int copyed_dc_h=CopyBuffer(m_handle_ind_POM,11,Priming_Start,Priming_Stop,arr_Dc_High);
   if(copyed_dc_h<0)
     {
      m_result=-23;
      return(false);
     }

//Dc Low
   int copyed_dc_l=CopyBuffer(m_handle_ind_POM,15,Priming_Start,Priming_Stop,arr_Dc_Low);
   if(copyed_dc_l<0)
     {
      m_result=-23;
      return(false);
     }

//Dc Close
   int copyed_dc_c=CopyBuffer(m_handle_ind_POM,3,Priming_Start,Priming_Stop,arr_Dc_Close);
   if(copyed_dc_c<0)
     {
      m_result=-23;
      return(false);
     }

//Check if arrays have identical elements count
   if(((copyed_rates+copyed_singal+copyed_spread+copyed_pom+copyed_first+copyed_dc_c)/6)!=copyed_rates)
     {
      m_result=-26;
      Print("Warning! Data not identical!");
      return(false);
     }

//If Ok
   return(true);
  }
//+------------------------------------------------------------------+
//| CheckLoadHistory                                                 |
//+------------------------------------------------------------------+ 
//+------------------------------------------------------------------+
//| CheckLoadHistory                                                 |
//+------------------------------------------------------------------+ 
