//+------------------------------------------------------------------+
//|                                                         RFee.mqh |
//|                             Copyright 2017, Shcherbyna Rostyslav |
//| Netting Accounts Only                                            |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Shcherbyna Rostyslav"
#property link      ""
#property version   "1.00"
//+------------------------------------------------------------------+
//| Description                                                      |
//+------------------------------------------------------------------+
/*
Fee can be withrawal by Function TesterWithdrawal() or can be Calculated 
as separate parameter VirtualFee

+ For Netting Accounts 
+ Work on TakeProfit and StopLoss

Three types of withdrawal:
1)Full Charge on Position Open
2)Separatly for Open and Close (half*2)
3)Full Charge on Position Close 
*/
//+------------------------------------------------------------------+
//| Types of Withdrawal                                              |
//+------------------------------------------------------------------+
enum ENUM_Withdrawal_Types
  {
   All_on_Open,
   All_on_Close,
   Separatly,
  };
//+------------------------------------------------------------------+
//| Fee Calculation Class                                            |
//+------------------------------------------------------------------+
class RFee
  {
private:

   double            m_VirtualFee;

   //Withdrawal money from account? or Virtually Calculate Fee?
   bool              m_tester_withdrawal;

public:
                     RFee();
                    ~RFee();

   // Init
   void              Init(const bool &Withdrawal_By_Tester);

   // Show Virtual Fee  
   double           Fee(void) const {return(m_VirtualFee);}

  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
RFee::RFee()
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
RFee::~RFee()
  {
  }
//+------------------------------------------------------------------+
//| Init                                                             |
//+------------------------------------------------------------------+
RFee::Init(const bool &Withdrawal_By_Tester)
  {
   m_tester_withdrawal=Withdrawal_By_Tester;
  }
//+------------------------------------------------------------------+
