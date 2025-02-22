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
   string                              arrHeader_Fields[];        // Header Fields
  };
//+------------------------------------------------------------------+
//|  MAIN CLASS                                                      |
//+------------------------------------------------------------------+
class RExportData
  {
private:

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

   STRUCT_CSV_HEADER                   m_csv_header;                                // CSV Header
   STRUCT_CSV_DATA                     m_csv_data[];                                // CSV Data
   int                                 m_header_fields_count;                       // Header Fields Count
   int                                 m_csv_file_handle;                           // CSV File Handle
   bool                                m_header_initialised;                        // Is Header Initialised
   bool                                m_csv_description_header_initialised;        // Is CSV Description Header Initialised
   bool                                m_csv_second_header_initialised;             // Is CSV Second Header Initialised

   // Functions
   void                                m_Prepare_csv_file();                                            // Prepare CSV File
   void                                m_Write_String_To_CSV(const STRUCT_CSV_DATA &Data);              // Write Single String to CSV

public:
                     RExportData();
                    ~RExportData();

   void              Init(const STRUCT_CSV_HEADER &Init);                           // Init Export Data

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
   FileClose(m_csv_file_handle);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|   Init                                                           |
//+------------------------------------------------------------------+
void RExportData::Init(const STRUCT_CSV_HEADER &Init)
  {
// Check Init Struct
   m_header_initialised = false;

// Try to Close Previous File
   if(m_csv_file_handle >= 0)
      FileClose(m_csv_file_handle);

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
void RExportData::m_Prepare_csv_file(void)
  {
// Not Initialised yet
   m_csv_description_header_initialised = false;

// Check Init
   if(m_header_initialised != true)
      return;

// Create\open File
   ResetLastError();

// FileName
   string  fn = "CSVExport" + "_" + _Symbol + "_" + EnumToString(_Period) + ".csv";

// Open File
   m_csv_file_handle = FileOpen(fn, FILE_SHARE_READ | FILE_COMMON | FILE_READ | FILE_WRITE | FILE_CSV | FILE_ANSI);

// Write Description Header
   if(m_csv_file_handle != INVALID_HANDLE)
     {
      FileWrite(m_csv_file_handle,
                TimeToString(TimeCurrent()),
                "TF = " + EnumToString(_Period),
                _Symbol,
                "Additional Fields Count: " + (string)m_header_fields_count
               );

      // Description Header Initialised
      m_csv_description_header_initialised = true;
      Print("Description Header added to CSV");
     }
   else
     {
      Print(__FUNCTION__ + " write description header to csv failed, error ", GetLastError());
      m_csv_description_header_initialised = false;
      return;
     }

//Second Header Not initialised yet
   m_csv_second_header_initialised = false;

// Write Fields Header
   string fields_header = "";

// Additional fields to single string
   for(int i = 0; i < m_header_fields_count; i++)
      fields_header += m_csv_header.arrHeader_Fields[i] + " , ";


// Write Second Header = Fields + Additional Fields
   if(m_csv_file_handle != INVALID_HANDLE)
     {
      FileWrite(m_csv_file_handle,
                "DateTime:",
                "TickVolume",
                "Open",
                "High",
                "Low",
                "Close",
                fields_header
               );

      Print("Second Header added to CSV");

      // Ok
      m_csv_second_header_initialised = true;
     }
   else
     {
      Print(__FUNCTION__ + " write second header to csv failed, error ", GetLastError());
      m_csv_second_header_initialised = false;
      return;
     }
  }
//+------------------------------------------------------------------+
//|   Write String to CSV                                            |
//+------------------------------------------------------------------+
void RExportData::m_Write_String_To_CSV(const STRUCT_CSV_DATA &Data)
  {
   string end_line = "\r\n";
   string separator = ",";

// Form Additional Field
   string additional_fields_str = "";

// Check Length of Header and Data
   if(ArraySize(Data.arrAdditionallFields) != m_header_fields_count)
     {
      printf(__FUNCTION__ + " Additional Fields Count " + (string)ArraySize(Data.arrAdditionallFields) + " Not Equal " + (string)m_header_fields_count);
      return;
     }

// form Additional Fields String
   for(int i = 0; i < m_header_fields_count; i++)
      additional_fields_str += DoubleToString(Data.arrAdditionallFields[i], 5) + separator;


// form Final String
   string s = TimeToString(Data.dt) + separator +
              (string)Data.tick_volume + separator +
              DoubleToString(Data.open) + separator +
              DoubleToString(Data.high) + separator +
              DoubleToString(Data.low) + separator +
              DoubleToString(Data.close) + separator +
              additional_fields_str +
              end_line;

// Write Single String to CSV
   if(m_csv_file_handle != INVALID_HANDLE)
      FileWriteString(m_csv_file_handle, s);
  }
//+------------------------------------------------------------------+
//|   Write ALL Strings to CSV                                       |
//+------------------------------------------------------------------+
void RExportData::Write_ALL_Strings_To_CSV(const STRUCT_CSV_DATA &Data[])
  {
// Check Init
   if(!m_header_initialised || !m_csv_description_header_initialised || !m_csv_second_header_initialised)
      return;

// Write ALL Strings to CSV
   for(int i = 0; i < m_csv_header.strings_count; i++)
      m_Write_String_To_CSV(Data[i]);
  }
//+------------------------------------------------------------------+
