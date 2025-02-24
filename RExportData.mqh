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
/*
Singleton: Class

CSV:
0) Init -> Send buffer indexes for Export:
1) Init -> Get Indicator Name (Should be 1 chart and 1 indicator on chart)
2) when call ExportToCSV -> connect Indicator -> copybuffer of all
3) then export to csv (datetime + ohlcv rates + all buffers)
*/
//
struct STRUCT_CSV_HEADER
  {
   int               indicator_buffer_id;          // Indicator Buffer Id
   string            indicator_buffer_name;        // Indicator Buffer Name
  };
//+------------------------------------------------------------------+
//|  MAIN CLASS                                                      |
//+------------------------------------------------------------------+
class RExportData
  {
private:

   // Indicator Buffer number + count of copied data
   struct STRUCT_IND_BUF
     {
      double                           buf[];                     // Buffer
      int                              copied;                    // Copied
     };

   // line strings
   string                              m_end_line_str;                              // End Line string
   string                              m_separator_str;                             // Field Separator string

   STRUCT_CSV_HEADER                   m_csv_ind_buffers_id[];                      // Indicator buffers ID
   STRUCT_IND_BUF                      m_indicator_buffers[];                       // Indicator Buffers
   string                              m_indicator_name;                            // Indicator Name
   int                                 m_indicator_handle;                          // Indicator handle
   int                                 m_indicator_bars_calculated;                 // Indicator bars calculated
   int                                 m_header_fields_count;                       // Header Fields Count
   int                                 m_csv_file_handle;                           // CSV File Handle

   // Flag to check if Already Exported data to csv
   bool                                m_already_exported_csv;                      // Already Exported CSV

   // Functions
   void                                m_Prepare_csv_file();                        // Prepare CSV File
   void                                m_Write_String_To_CSV();                     // Write Single String to CSV

public:
                     RExportData();
                    ~RExportData();

   // Buffer Indexes To Export, Example: 0,3,4
   void              Init(const STRUCT_CSV_HEADER &IndBufIndexes[]);                // Init
   void              Export_Data_To_CSV();                                          // Export Data to CSV
  };
//+------------------------------------------------------------------+
//|  Constructor                                                     |
//+------------------------------------------------------------------+
RExportData::RExportData()
  {
// Reset Bool Flag
   m_already_exported_csv = false;
   m_end_line_str = "\r\n";
   m_separator_str = ",";
  }
//+------------------------------------------------------------------+
//|  Destructor                                                      |
//+------------------------------------------------------------------+
RExportData::~RExportData()
  {
// Closing Files on Exit
   FileClose(m_csv_file_handle);
  }
//+------------------------------------------------------------------+
//|  Init                                                            |
//+------------------------------------------------------------------+
void RExportData::Init(const STRUCT_CSV_HEADER &IndBufIndexes[])
  {
// Reset Flag Already exported to CSV
   m_already_exported_csv = false;

// Save Size of Additional fields from Indicator
   m_header_fields_count = ArraySize(IndBufIndexes);

// Get Indicator Buffer Indexes
   if(m_header_fields_count <= 0)
     {
      printf(__FUNCTION__, " No Indicator Buffer Indexes selected @");
      return;
     }

   m_indicator_name = ChartIndicatorName(ChartID(), 0, 0);
   printf("Export Data to CSV From -> Indicator Name:" + (string)m_indicator_name + " to COMMON Folder");

// Connect Indicator
   m_indicator_handle =  iCustom(_Symbol, PERIOD_CURRENT, m_indicator_name);

//--- if the handle is not created
   if(m_indicator_handle == INVALID_HANDLE)
     {
      Print(__FUNCTION__ + " Err " + IntegerToString(GetLastError()));
      return;
     }

// Fill Buffers
   ArrayResize(m_csv_ind_buffers_id, m_header_fields_count);

   for(int i = 0; i < m_header_fields_count; i++)
     {
      m_csv_ind_buffers_id[i].indicator_buffer_id = IndBufIndexes[i].indicator_buffer_id;
      m_csv_ind_buffers_id[i].indicator_buffer_name = IndBufIndexes[i].indicator_buffer_name;
     }

// Prepare csv
   m_Prepare_csv_file();
  }
//+------------------------------------------------------------------+
//|  Prepare CSV File                                                |
//+------------------------------------------------------------------+
void RExportData::m_Prepare_csv_file()
  {
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
                _Symbol
               );

      printf("Switched to: " + (string) _Symbol + " " + EnumToString(_Period));
     }
   else
     {
      Print(__FUNCTION__ + " write description header to csv failed, error ", GetLastError());
      return;
     }

// Write Fields Header
   string fields_header = "";

// Additional fields to single string
   for(int i = 0; i < m_header_fields_count; i++)
      fields_header += m_csv_ind_buffers_id[i].indicator_buffer_name + m_separator_str;

// Write Second Header = Fields + Additional Fields
   if(m_csv_file_handle != INVALID_HANDLE)
     {
      FileWrite(m_csv_file_handle,
                "DateTime" + m_separator_str,
                "TickVolume" + m_separator_str,
                "Open" + m_separator_str,
                "High" + m_separator_str,
                "Low" + m_separator_str,
                "Close" + m_separator_str,
                fields_header
               );
     }
   else
     {
      Print(__FUNCTION__ + " write second header to csv failed, error ", GetLastError());
      return;
     }
  }
//+------------------------------------------------------------------+
//|  Export Data To CSV                                              |
//+------------------------------------------------------------------+
void RExportData::Export_Data_To_CSV(void)
  {
// Check if CSV Already Exported
   if(m_already_exported_csv == true)
      return;

// Get Calculated Data
   m_indicator_bars_calculated =  BarsCalculated(m_indicator_handle);

// Set Size if Ind Buffers
   ArrayResize(m_indicator_buffers, m_header_fields_count);

// Get Buffers
   for(int i = 0; i < m_header_fields_count; i++)
     {
      m_indicator_buffers[i].copied = CopyBuffer(m_indicator_handle,
                                      m_csv_ind_buffers_id[i].indicator_buffer_id,
                                      0,
                                      m_indicator_bars_calculated,
                                      m_indicator_buffers[i].buf);

      // No copied, Exit
      if(m_indicator_buffers[i].copied < 0)
        {
         return;
        }

      printf("Indictor Data from Buffer Number : " + (string)i + " copied: " + (string)m_indicator_buffers[i].copied);
     }//END OF FOR

// Write indicator data to CSV
   m_Write_String_To_CSV();
  }
//+------------------------------------------------------------------+
//|   Write String to CSV                                            |
//+------------------------------------------------------------------+
void RExportData::m_Write_String_To_CSV()
  {
// Save Start Time
   ulong start_time = GetMicrosecondCount();

// Get MQL Rates
   MqlRates rates[];

// Copy All Rates from 1970 to Now
   int copied = CopyRates(_Symbol, PERIOD_CURRENT, 0, m_indicator_bars_calculated, rates);

// Debug
   if(copied <= 0)
     {
      Print("Error copying price data ", GetLastError());
      return;
     }
   else
      Print("Additionally DateOHLCV Rates Copied: ", ArraySize(rates), " bars");

// Check File Handle
   if(m_csv_file_handle == INVALID_HANDLE)
     {
      Print(__FUNCTION__ + " err wrong csv file name");

      // Exit
      return;
     }

// Save Datat to disk Each 1024 iteration
   int flush_koef = 127;

   printf("Waiting Indicator...");

// Export All Data
   for(int i = 0; i < copied; i++)
     {
      // Form Additional Field
      string additional_fields_str = "";

      // form Additional Fields String
      for(int x = 0; x < m_header_fields_count; x++)
         additional_fields_str += DoubleToString(m_indicator_buffers[x].buf[i], 5) + m_separator_str;

      // Form Final String
      string s = TimeToString(rates[i].time) + m_separator_str +
                 (string)rates[i].tick_volume + m_separator_str +
                 DoubleToString(rates[i].open) + m_separator_str +
                 DoubleToString(rates[i].high) + m_separator_str +
                 DoubleToString(rates[i].low) + m_separator_str +
                 DoubleToString(rates[i].close) + m_separator_str +
                 additional_fields_str +
                 m_end_line_str;

      // Write Single String to CSV
      FileWriteString(m_csv_file_handle, s);

      // Flush Data to Disk each flush_koef
      if((i & flush_koef) == flush_koef)
         FileFlush(m_csv_file_handle);
     }//END OF FOR

// Close File
   FileClose(m_csv_file_handle);

// Set Flag, CSV Already Exported
   m_already_exported_csv = true;

// Save Stop Time
   ulong stop_time = GetMicrosecondCount();

// Total Time for Export to CSV
   printf("Total Time for Export Indicators data to CSV: " + DoubleToString((stop_time - start_time) / 1000.0, 2) + " msec");
  }
//+------------------------------------------------------------------+
