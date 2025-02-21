//+------------------------------------------------------------------+
//|                                                 RExportData.mqh  |
//|                      Copyright 2025, \x2662 Rostyslav Shcherbyna |
//| Exports data to CSV                                              |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025,\x2662 Rostyslav Shcherbyna"
#property description "\x2620 RExportData Class"
#property description " Exports Data to CSV "
#property link      "\x2620 neozork@protonmail.com"
#property version   "1.00"
//
//
//
/*
Singleton: Class

CSV has:
1) filename.csv
2) header-description
3) header of data :
datetime, open,high,low,close, tick volume

*/
//+------------------------------------------------------------------+
//|  CSV HEADER STRUCT                                               |
//+------------------------------------------------------------------+
struct STRUCT_CSV_HEADER
  {
   ENUM_TIMEFRAMES                     TF;                        // Time Frame
   string                              filename;                  // File Name
   string                              symbol;                    // Symbol
   string                              separator;                 // Separator
   datetime                            start_datetime;            // Start DateTime
   datetime                            stop_datetime;             // Stop  DateTime
   long                                strings_count;             // Strings Count
   string                              arrHeader_Fields[];        // Header Fields
  };
//+------------------------------------------------------------------+
//|  CSV DATA STRUCT                                                 |
//+------------------------------------------------------------------+
struct STRUCT_CSV_DATA
  {
   datetime                            dt;                        // Date Time
   long                                tick_volume;               // Tick Volume
   double                              open;                      // Open Price
   double                              high;                      // High Price
   double                              low;                       // Low Price
   double                              close;                     // Close Price
   double                              arrAdditionallFields[];    // Fields
  };
//+------------------------------------------------------------------+
//|  MAIN CLASS                                                      |
//+------------------------------------------------------------------+
class RExportData
  {
private:

   STRUCT_CSV_HEADER                   m_csv_header;               // CSV Header
   STRUCT_CSV_DATA                     m_csv_data[];               // CSV Data
   int                                 m_header_fields_count;      // Header Fields Count
   bool                                m_header_initialised;       // Is Header Initialised

// Functions
   bool                                m_prepare_csv_file();       // Prepare CSV File
   void                                m_close_file();             // Close File
   

public:
                     RExportData();
                    ~RExportData();

   void              Init(const STRUCT_CSV_HEADER &Init);                           // Init Export Data
   void              Write_String_To_CSV(const STRUCT_CSV_DATA &Data);              // Write Single String to CSV
   void              Write_ALL_Strings_To_CSV(const STRUCT_CSV_DATA &Data[]);       // Write ALL Strings to CSV
  };
//+------------------------------------------------------------------+
//|  Constructor                                                     |
//+------------------------------------------------------------------+
RExportData::RExportData()
  {
  }
//+------------------------------------------------------------------+
//|  Destructor                                                      |
//+------------------------------------------------------------------+
RExportData::~RExportData()
  {
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|   Init                                                           |
//+------------------------------------------------------------------+
void RExportData::Init(const STRUCT_CSV_HEADER &Init)
  {
// Check Init Struct
   m_header_initialised = false;

// Check TF
   if(Init.TF == 0)
     {
      printf(__FUNCTION__ + " TF == Current! , Exit");
      return;
     }

// Check File Name
   int str_length = StringLen(Init.filename);
   if(str_length <= 5 || str_length > 50)
     {
      printf(__FUNCTION__ + " Wrong FileName length," + (string)str_length);
      return;
     }

// Check Symbol
   int symbol_length = StringLen(Init.symbol);
   if(symbol_length <= 2 || symbol_length > 20)
     {
      printf(__FUNCTION__ + " Wrong Symbol length," + (string)symbol_length);
      return;
     }

// Check Separator
   int separator_length = StringLen(Init.separator);
   if(separator_length <= 2 || separator_length > 1)
     {
      printf(__FUNCTION__ + " Wrong Separator length," + (string)separator_length);
      return;
     }

// Check Start Date
   if(Init.start_datetime <= 0 || Init.start_datetime >= TimeCurrent())
     {
      printf(__FUNCTION__ + " Wrong Start Date," + (string)Init.start_datetime);
      return;
     }

// Check Stop Date
   if(Init.stop_datetime <= 0)
     {
      printf(__FUNCTION__ + " Wrong Stop Date," + (string)Init.stop_datetime);
      return;
     }

// Check Start > Stop Date
   if(Init.stop_datetime >= Init.start_datetime)
     {
      printf(__FUNCTION__ + " Wrong Start Date: " + (string)Init.start_datetime + " OR Stop Date: " + (string)Init.stop_datetime);
      return;
     }

// Check Strings Count, must be > 0
   if(Init.strings_count <= 0)
     {
      printf(__FUNCTION__ + " Wrong Strings Count," + (string)Init.strings_count);
      return;
     }

// Check Header Fields Count
   m_header_fields_count = ArraySize(Init.arrHeader_Fields);

// If Everethyng Ok, Save Struct;
   m_csv_header = Init;

// Ok
   m_header_initialised = true;
  }
//+------------------------------------------------------------------+
//|  Prepare CSV File                                                |
//+------------------------------------------------------------------+
bool RExportData::m_prepare_csv_file(void)
  {

// Check Init
   if(m_header_initialised != true)
      return(false);
      
      // Create\open File
      
      // Initialize File for writing
      
      // Write Description Header 
      
      // Write Fields Header


// Ok
   return(true);
  }
//+------------------------------------------------------------------+
