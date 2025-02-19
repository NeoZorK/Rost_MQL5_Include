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
//+------------------------------------------------------------------+
//|  CSV HEADER STRUCT                                               |
//+------------------------------------------------------------------+
struct STRUCT_CSV_HEADER
  {
   ENUM_TIMEFRAMES                     TF;                        // Time Frame
   string                              filename;                  // File Name
   string                              pair;                      // Pair
   string                              arrHeader_Fields[];        // Header Fields
   string                              separator;                 // Separator
   datetime                            start_datetime;            // Start DateTime
   datetime                            stop_datetime;             // Stop  DateTime
   long                                strings_count;             // Strings Count
  };
//+------------------------------------------------------------------+
//|  CSV DATA STRUCT                                                 |
//+------------------------------------------------------------------+
struct STRUCT_CSV_DATA
  {
   datetime                            dt;                        // Date Time
   double                              open;                      // Open Price
   double                              high;                      // High Price
   double                              low;                       // Low Price
   double                              close;                     // Close Price
  };
//+------------------------------------------------------------------+
//|  MAIN CLASS                                                      |
//+------------------------------------------------------------------+
class RExportData
  {
private:

public:
                     RExportData();
                    ~RExportData();
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
