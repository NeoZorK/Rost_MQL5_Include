//+------------------------------------------------------------------+
//|                                                     RDensity.mqh |
//|                             Copyright 2017, Shcherbyna Rostyslav |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Shcherbyna Rostyslav"
#property link      ""
#property version   "1.00"
//+------------------------------------------------------------------+
//| Ticks Density Class                                              |
//+------------------------------------------------------------------+
class RDensity
  {
private:

double               m_open_dc;                 // DC For Open Position
double               m_arr_ticks_bottle_0;      // Ticks in Bottle 0
double               m_arr_ticks_bottle_1;      // Ticks in Bottle 1
double               m_arr_ticks_bottle_2;      // Ticks in Bottle 2
double               m_dt1;                     // dT in Bottle 1
double               m_dt2;                     // dT in Bottle 2
double               m_dc;                      // dC
double               m_pom_0;                   // POM Zero Bottle
double               m_pom_1;                   // POM First Bottle
double               m_pom_2;                   // POM Second Bottle
double               m_y_1;                     // Y1 
double               m_y_2;                     // Y2 
string               m_ident_magic;             // Robot Identificator
uint                 m_max_spread;              // Maximum Spread
uint                 m_ticks_bottle_size;       // One Bottle Tick Size
ushort               m_fee;                     // Internal TakeProfit
char                 m_wf_0;                    // WhoFirst Zero Bottle
char                 m_wf_1;                    // WhoFirst First Bottle
char                 m_wf_2;                    // WhoFirst Second Bottle


public:
                     RDensity();
                    ~RDensity();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
RDensity::RDensity()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
RDensity::~RDensity()
  {
  }
//+------------------------------------------------------------------+
