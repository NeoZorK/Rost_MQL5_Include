//+------------------------------------------------------------------+
//|                                                       miniTR.mqh |
//|                             Copyright 2017, Shcherbyna Rostyslav |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Shcherbyna Rostyslav"
#property version   "1.00"
#include <RInclude\RStructs.mqh>
//+------------------------------------------------------------------+
//| miniTR Calculation                                               |
//+------------------------------------------------------------------+
class miniTR
  {
private:
   string            m_FName_miniTR;            //miniTR FileName
   string            m_FName_rNP1;              //Real Net Profit 1
   string            m_FName_rNP4;              //Real Net Profit 4
   string            m_FName_rNP14;             //Real Net Profit 14
                                                //

   //SpeedUp
   double            m_x1;
   double            m_x2;
   double            m_result;
   double            m_AbsA;
   double            m_AbsB;

   //Count of T
   int               m_T_Count;

   //Groups Count
   int               m_groups_count;

   //miniTR Count
   int               m_minitr_count;

   //miniTR Params
   STRUCT_miniTR     m_arr_mtr[];

   //RealTime NP
   RT_NP             m_arr_rNP1[];
   RT_NP             m_arr_rNP4[];
   RT_NP             m_arr_rNP14[];

   //Group ID array
   ENUM_T_GROUP_ID   m_arr_GroupID[];

   //Sum of NP for every group (23-Groups Count))
   double            m_arr_SUM_NP_GROUP[][23];

   //Struct for EXPORT to bin
   STRUCT_miniTRID   m_arr_minitr[23];

   //Statistics T count inside each group
   uint              m_arr_T_Count_in_GRP[];

   //Check GroupID of every interval T                                 
   void              m_Check_GroupID(void);

   //Groups Count
   int               m_GroupsCount(void);

   //MiniTR Count
   int               m_MiniTrCount(void);

   //Calculate miniTR(232) by Num                    
   double            m_Calc_miniTR(ENUM_miniTR_ID const &mini,const int &t_num);

   //Find Best miniTR
   void              m_FindBest_miniTR();

   //Calculation miniTR(232)
   double            m_Abs_Cmpd4_Max_pmm(const int &T_NUM);

public:
                     miniTR(void);
                    ~miniTR(void);
   //Init
   bool              Init(void);

   //Groups Count
   int             GroupsCount(void) const    {return(m_groups_count);}

   //miniTR Count
   int             MiniTRCount(void) const    {return(m_minitr_count);}

   //T Count
   int             TCount(void) const    {return(m_T_Count);}

   //Import miniTR params and RTNP from files
   int               ImportMiniTRParams(const string &Pair,const string &_FName);

   //Process all miniTRs
   void              Process_miniTR();

   //Export miniTR to bin file
   void              ExportMiniTR_ToBin();

   //Print Statistics
   void              PrintStatistics();

   //Export result matrix to csv (Group and miniTRs)
   void              ExportMatrix_CSV(const bool m_csv_separator);

  };
//+------------------------------------------------------------------+
//|  CONSTRUCTOR                                                     |
//+------------------------------------------------------------------+ 
miniTR::miniTR(void)
  {
   m_x1=0;
   m_x2=0;
   m_result=0;
   m_AbsA=0;
   m_AbsB=0;
   m_FName_miniTR="miniTR";
   m_FName_rNP1="rNP1";
   m_FName_rNP4="rNP4";
   m_FName_rNP14="rNP14";
   m_T_Count=0;
  }
//+------------------------------------------------------------------+
//|  DESTRUCTOR                                                      |
//+------------------------------------------------------------------+
miniTR::~miniTR(void)
  {

  }
//+------------------------------------------------------------------+
//| INIT                                                             |
//+------------------------------------------------------------------+
bool miniTR::Init(void)
  {
   m_groups_count=m_GroupsCount();
   m_minitr_count=m_MiniTrCount();
   return(true);
  }
//+------------------------------------------------------------------+
//|  Print Statistics                                                |
//+------------------------------------------------------------------+
void miniTR::PrintStatistics(void)
  {
   Print("_______________________Processing Statistics_________________________");

//Print Best NP with Index  
   for(ENUM_T_GROUP_ID i=NOTRADE;i<Unknown;i++)
      Print(IntegerToString(i)+" | "
            +EnumToString(i)+"| BEST NP = "
            +DoubleToString(m_arr_minitr[i].BestNP,2)+
            "("+EnumToString((ENUM_miniTR_ID)m_arr_minitr[i].minitr)+") T( "
            +(string)m_arr_T_Count_in_GRP[i]+" )");

//How many NO TRADE GROUPS: (SLEEP MARKET)  
   Print("NO TRADES in PRIMINGS T Count: "+(string)m_arr_T_Count_in_GRP[NOTRADE]+" of "+(string)m_T_Count);

//Counter ZeroProfit & Unknown GRP
   int NonProfitGrpCount=0;
   int UnknownGrpCount=0;

//Print Groups Count Without miniTR (Zero or non profitable)+Unknown
   for(int i=0;i<m_groups_count;i++)
     {
      if(m_arr_minitr[i].BestNP==0) NonProfitGrpCount++;
      if(m_arr_GroupID[i]==Unknown) UnknownGrpCount++;
     }

   Print("Non Profit Groups count: "+(string)NonProfitGrpCount+" (of:"+(string)m_groups_count+" totally.)");
   Print("Unknown Groups count: "+IntegerToString(UnknownGrpCount));

   double TotalBestNP=0;

//Print Sum of All NPs
   for(ENUM_T_GROUP_ID i=NOTRADE;i<Unknown;i++)
      TotalBestNP+=m_arr_minitr[i].BestNP;

   Print("Total Sum of all Best NP: "+DoubleToString(TotalBestNP,2));

//   if(NonProfitGrpCount+NeverMetGrpCount==GroupsCount)
//      Alert("SUCCESS! All Groups are Profitable! ");

   Print("________________________________Completed________________________________");
  }
//+------------------------------------------------------------------+
//| Calculate miniTR (227 items)                                     |
//+------------------------------------------------------------------+
double miniTR::m_Calc_miniTR(ENUM_miniTR_ID const &mini,const int &t_num)
  {
   switch(mini)
     {
      case  C1:return(0);break;//arr_rNP1[t_num].NP1_RT); break;
      case  C4:return(0);break;//(arr_rNP4[t_num].NP4_RT); break;
      case  Min_AB:return(MinAB(t_num)); break;
      case  Max_AB:return(MaxAB(t_num)); break;
      case  C14:return(0); break;                              // we have not NP14_RT!!!!
      case  Abs_Min_AB:return(Abs_Min_AB(t_num)); break;
      case  Abs_Max_AB:return(Abs_Max_AB(t_num)); break;                   //6
      case  Min_fAB:return(Min_fAB(t_num)); break;
      case  Max_fAB:return(Max_fAB(t_num)); break;
      case  Abs_Min_fAB:return(Abs_Min_fAB(t_num)); break;
      case  Abs_Max_fAB:return(Abs_Max_fAB(t_num)); break;
      case  Min_f1AB:return(Min_f1AB(t_num)); break;
      case  Max_f1AB:return(Max_f1AB(t_num)); break;
      case  Abs_Min_f1AB:return(Abs_Min_f1AB(t_num)); break;
      case  Abs_Max_f1AB:return(Abs_Max_f1AB(t_num)); break;
      case  Min_betaAB:return(Min_BetaAB(t_num)); break;
      case  Max_betaAB:return(Max_BetaAB(t_num)); break;
      case  Abs_Min_betaAB:return(Abs_Min_BetaAB(t_num)); break;
      case  Abs_Max_betaAB:return(Abs_Max_BetaAB(t_num)); break;
      case  Min_gammaAB:return(Min_GammaAB(t_num)); break;
      case  Max_gammaAB:return(Max_GammaAB(t_num)); break;
      case  Abs_Min_gammaAB:return(Abs_Min_GammaAB(t_num)); break;
      case  Abs_Max_gammaAB:return(Abs_Max_GammaAB(t_num)); break;
      case  NotTrade:return(0);break;                                      //23
      case  Equal_dQ1Q4_C1:return(Equal_dQ1Q4_C1(t_num));break;
      case  Equal_dQ1Q4_C4:return(Equal_dQ1Q4_C4(t_num));break;
      case  Equal_dQ1Q4_C14:return(0); break;
      case  Equal_dQ1Q4_MinAB:return(Equal_dQ1Q4_MinAB(t_num));break;
      case  Equal_dQ1Q4_MaxAB:return(Equal_dQ1Q4_MaxAB(t_num));break;
      case  Zero_dQ1Q4_C1:return(Zero_dQ1Q4_C1(t_num));break;
      case  Zero_dQ1Q4_C4:return(Zero_dQ1Q4_C4(t_num));break;
      case  Zero_dQ1Q4_C14:return(0);
      case  Zero_dQ1Q4_MinAB:return(Zero_dQ1Q4_MinAB(t_num)); break;
      case  Zero_dQ1Q4_MaxAB:return(Zero_dQ1Q4_MaxAB(t_num)); break;
      case  Equal_AB_C1:return(Equal_AB_C1(t_num)); break;
      case  Equal_AB_C4:return(Equal_AB_C4(t_num)); break;
      case  Equal_AB_C14:return(0); break;
      case  Equal_AB_MinAB:return(Equal_AB_MinAB(t_num)); break;
      case  Equal_AB_MaxAB:return(Equal_AB_MaxAB(t_num)); break;
      case  Zero_AmB_C1:return(Zero_AmB_C1(t_num)); break;
      case  Zero_AmB_C4:return(Zero_AmB_C4(t_num)); break;
      case  Zero_AmB_C14:return(0);break;
      case  Zero_AmB_MinAB:return(Zero_AmB_MinAB(t_num)); break;
      case  Zero_AmB_MaxAB:return(Zero_AmB_MaxAB(t_num)); break;           //43
      case  Cmpd2_Min_FF1:return(Cmpd2_Min_FF1(t_num)); break;
      case  Cmpd2_Max_FF1:return(Cmpd2_Max_FF1(t_num)); break;
      case  Abs_Cmpd2_Min_FF1:return(Abs_Cmpd2_Min_FF1(t_num)); break;
      case  Abs_Cmpd2_Max_FF1:return(Abs_Cmpd2_Max_FF1(t_num)); break;
      case  Cmpd2_Min_FBeta:return(Cmpd2_Min_FBeta(t_num)); break;
      case  Cmpd2_Max_FBeta:return(Cmpd2_Max_FBeta(t_num)); break;
      case  Abs_Cmpd2_Min_FBeta:return(Abs_Cmpd2_Min_FBeta(t_num)); break;
      case  Abs_Cmpd2_Max_FBeta:return(Abs_Cmpd2_Max_FBeta(t_num)); break;
      case  Cmpd2_Min_FGamma:return(Cmpd2_Min_FGamma(t_num)); break;
      case  Cmpd2_Max_FGamma:return(Cmpd2_Max_FGamma(t_num)); break;
      case  Abs_Cmpd2_Min_FGamma:return(Abs_Cmpd2_Min_FGamma(t_num)); break;
      case  Abs_Cmpd2_Max_FGamma:return(Abs_Cmpd2_Max_FGamma(t_num)); break;
      case  Cmpd2_Min_F1Beta:return(Cmpd2_Min_F1Beta(t_num)); break;
      case  Cmpd2_Max_F1Beta:return(Cmpd2_Max_F1Beta(t_num)); break;
      case  Abs_Cmpd2_Min_F1Beta:return(Abs_Cmpd2_Min_F1Beta(t_num)); break;
      case  Abs_Cmpd2_Max_F1Beta:return(Abs_Cmpd2_Max_F1Beta(t_num)); break;
      case  Cmpd2_Min_F1Gamma:return(Cmpd2_Min_F1Gamma(t_num)); break;
      case  Cmpd2_Max_F1Gamma:return(Cmpd2_Max_F1Gamma(t_num)); break;
      case  Abs_Cmpd2_Min_F1Gamma:return(Abs_Cmpd2_Min_F1Gamma(t_num)); break;
      case  Abs_Cmpd2_Max_F1Gamma:return(Abs_Cmpd2_Max_F1Gamma(t_num)); break;
      case  Cmpd2_Min_BetaGamma:return(Cmpd2_Min_BetaGamma(t_num)); break;
      case  Cmpd2_Max_BetaGamma:return(Cmpd2_Max_BetaGamma(t_num)); break;
      case  Abs_Cmpd2_Min_BetaGamma:return(Abs_Cmpd2_Min_BetaGamma(t_num)); break;
      case  Abs_Cmpd2_Max_BetaGamma:return(Abs_Cmpd2_Max_BetaGamma(t_num)); break;  //67
      case  Cmpd2_Min_FF1_plus:return(Cmpd2_Min_FF1_plus(t_num)); break;
      case  Cmpd2_Max_FF1_plus:return(Cmpd2_Max_FF1_plus(t_num)); break;
      case  Abs_Cmpd2_Min_FF1_plus:return(Abs_Cmpd2_Min_FF1_plus(t_num)); break;
      case  Abs_Cmpd2_Max_FF1_plus:return(Abs_Cmpd2_Max_FF1_plus(t_num)); break;
      case  Cmpd2_Min_FBeta_plus:return(Cmpd2_Min_FBeta_plus(t_num)); break;
      case  Cmpd2_Max_FBeta_plus:return(Cmpd2_Max_FBeta_plus(t_num)); break;
      case  Abs_Cmpd2_Min_FBeta_plus:return(Abs_Cmpd2_Min_FBeta_plus(t_num)); break;
      case  Abs_Cmpd2_Max_FBeta_plus:return(Abs_Cmpd2_Max_FBeta_plus(t_num)); break;
      case  Cmpd2_Min_FGamma_plus:return(Cmpd2_Min_FGamma_plus(t_num)); break;
      case  Cmpd2_Max_FGamma_plus:return(Cmpd2_Max_FGamma_plus(t_num)); break;
      case  Abs_Cmpd2_Min_FGamma_plus:return(Abs_Cmpd2_Min_FGamma_plus(t_num)); break;
      case  Abs_Cmpd2_Max_FGamma_plus:return(Abs_Cmpd2_Max_FGamma_plus(t_num)); break;
      case  Cmpd2_Min_F1Beta_plus:return(Cmpd2_Min_F1Beta_plus(t_num)); break;
      case  Cmpd2_Max_F1Beta_plus:return(Cmpd2_Max_F1Beta_plus(t_num)); break;
      case  Abs_Cmpd2_Min_F1Beta_plus:return(Abs_Cmpd2_Min_F1Beta_plus(t_num)); break;
      case  Abs_Cmpd2_Max_F1Beta_plus:return(Abs_Cmpd2_Max_F1Beta_plus(t_num)); break;
      case  Cmpd2_Min_F1Gamma_plus:return(Cmpd2_Min_F1Gamma_plus(t_num)); break;
      case  Cmpd2_Max_F1Gamma_plus:return(Cmpd2_Max_F1Gamma_plus(t_num)); break;
      case  Abs_Cmpd2_Min_F1Gamma_plus:return(Abs_Cmpd2_Min_F1Gamma_plus(t_num)); break;
      case  Abs_Cmpd2_Max_F1Gamma_plus:return(Abs_Cmpd2_Max_F1Gamma_plus(t_num)); break;
      case  Cmpd2_Min_BetaGamma_plus:return(Cmpd2_Min_BetaGamma_plus(t_num)); break;
      case  Cmpd2_Max_BetaGamma_plus:return(Cmpd2_Max_BetaGamma_plus(t_num)); break;
      case  Abs_Cmpd2_Min_BetaGamma_plus:return(Abs_Cmpd2_Min_BetaGamma_plus(t_num)); break;
      case  Abs_Cmpd2_Max_BetaGamma_plus:return(Abs_Cmpd2_Max_BetaGamma_plus(t_num)); break;  //91
      case  Cmpd2_Min_FF1_minus:return(Cmpd2_Min_FF1_minus(t_num)); break;
      case  Cmpd2_Max_FF1_minus:return(Cmpd2_Max_FF1_minus(t_num)); break;
      case  Abs_Cmpd2_Min_FF1_minus:return(Abs_Cmpd2_Min_FF1_minus(t_num)); break;
      case  Abs_Cmpd2_Max_FF1_minus:return(Abs_Cmpd2_Max_FF1_minus(t_num)); break;
      case  Cmpd2_Min_FBeta_minus:return(Cmpd2_Min_FBeta_minus(t_num)); break;
      case  Cmpd2_Max_FBeta_minus:return(Cmpd2_Max_FBeta_minus(t_num)); break;
      case  Abs_Cmpd2_Min_FBeta_minus:return(Abs_Cmpd2_Min_FBeta_minus(t_num)); break;
      case  Abs_Cmpd2_Max_FBeta_minus:return(Abs_Cmpd2_Max_FBeta_minus(t_num)); break;
      case  Cmpd2_Min_FGamma_minus:return(Cmpd2_Min_FGamma_minus(t_num)); break;
      case  Cmpd2_Max_FGamma_minus:return(Cmpd2_Max_FGamma_minus(t_num)); break;
      case  Abs_Cmpd2_Min_FGamma_minus:return(Abs_Cmpd2_Min_FGamma_minus(t_num)); break;
      case  Abs_Cmpd2_Max_FGamma_minus:return(Abs_Cmpd2_Max_FGamma_minus(t_num)); break;
      case  Cmpd2_Min_F1Beta_minus:return(Cmpd2_Min_F1Beta_minus(t_num)); break;
      case  Cmpd2_Max_F1Beta_minus:return(Cmpd2_Max_F1Beta_minus(t_num)); break;
      case  Abs_Cmpd2_Min_F1Beta_minus:return(Abs_Cmpd2_Min_F1Beta_minus(t_num)); break;
      case  Abs_Cmpd2_Max_F1Beta_minus:return(Abs_Cmpd2_Max_F1Beta_minus(t_num)); break;
      case  Cmpd2_Min_F1Gamma_minus:return(Cmpd2_Min_F1Gamma_minus(t_num)); break;
      case  Cmpd2_Max_F1Gamma_minus:return(Cmpd2_Max_F1Gamma_minus(t_num)); break;
      case  Abs_Cmpd2_Min_F1Gamma_minus:return(Abs_Cmpd2_Min_F1Gamma_minus(t_num)); break;
      case  Abs_Cmpd2_Max_F1Gamma_minus:return(Abs_Cmpd2_Max_F1Gamma_minus(t_num)); break;
      case  Cmpd2_Min_BetaGamma_minus:return(Cmpd2_Min_BetaGamma_minus(t_num)); break;
      case  Cmpd2_Max_BetaGamma_minus:return(Cmpd2_Max_BetaGamma_minus(t_num)); break;
      case  Abs_Cmpd2_Min_BetaGamma_minus:return(Abs_Cmpd2_Min_BetaGamma_minus(t_num)); break;
      case  Abs_Cmpd2_Max_BetaGamma_minus:return(Abs_Cmpd2_Max_BetaGamma_minus(t_num)); break;  //115
      case  Cmpd3_Min_FF1Beta:return(Cmpd3_Min_FF1Beta(t_num)); break;
      case  Cmpd3_Max_FF1Beta:return(Cmpd3_Max_FF1Beta(t_num)); break;
      case  Abs_Cmpd3_Min_FF1Beta:return(Abs_Cmpd3_Min_FF1Beta(t_num)); break;
      case  Abs_Cmpd3_Max_FF1Beta:return(Abs_Cmpd3_Max_FF1Beta(t_num)); break;
      case  Cmpd3_Min_FF1Gamma:return(Cmpd3_Min_FF1Gamma(t_num)); break;
      case  Cmpd3_Max_FF1Gamma:return(Cmpd3_Max_FF1Gamma(t_num)); break;
      case  Abs_Cmpd3_Min_FF1Gamma:return(Abs_Cmpd3_Min_FF1Gamma(t_num)); break;
      case  Abs_Cmpd3_Max_FF1Gamma:return(Abs_Cmpd3_Max_FF1Gamma(t_num)); break;
      case  Cmpd3_Min_FBetaGamma:return(Cmpd3_Min_FBetaGamma(t_num)); break;
      case  Cmpd3_Max_FBetaGamma:return(Cmpd3_Max_FBetaGamma(t_num)); break;
      case  Abs_Cmpd3_Min_FBetaGamma:return(Abs_Cmpd3_Min_FBetaGamma(t_num)); break;
      case  Abs_Cmpd3_Max_FBetaGamma:return(Abs_Cmpd3_Max_FBetaGamma(t_num)); break;
      case  Cmpd3_Min_F1BetaGamma:return(Cmpd3_Min_F1BetaGamma(t_num)); break;
      case  Cmpd3_Max_F1BetaGamma:return(Cmpd3_Max_F1BetaGamma(t_num)); break;
      case  Abs_Cmpd3_Min_F1BetaGamma:return(Abs_Cmpd3_Min_F1BetaGamma(t_num)); break;
      case  Abs_Cmpd3_Max_F1BetaGamma:return(Abs_Cmpd3_Max_F1BetaGamma(t_num)); break;          //131
      case  Cmpd3_Min_FF1Beta_pp:return(Cmpd3_Min_FF1Beta_pp(t_num)); break;
      case  Cmpd3_Max_FF1Beta_pp:return(Cmpd3_Max_FF1Beta_pp(t_num)); break;
      case  Abs_Cmpd3_Min_FF1Beta_pp:return(Abs_Cmpd3_Min_FF1Beta_pp(t_num)); break;
      case  Abs_Cmpd3_Max_FF1Beta_pp:return(Abs_Cmpd3_Max_FF1Beta_pp(t_num)); break;
      case  Cmpd3_Min_FF1Gamma_pp:return(Cmpd3_Min_FF1Gamma_pp(t_num)); break;
      case  Cmpd3_Max_FF1Gamma_pp:return(Cmpd3_Max_FF1Gamma_pp(t_num)); break;
      case  Abs_Cmpd3_Min_FF1Gamma_pp:return(Abs_Cmpd3_Min_FF1Gamma_pp(t_num)); break;
      case  Abs_Cmpd3_Max_FF1Gamma_pp:return(Abs_Cmpd3_Max_FF1Gamma_pp(t_num)); break;
      case  Cmpd3_Min_FBetaGamma_pp:return(Cmpd3_Min_FBetaGamma_pp(t_num)); break;
      case  Cmpd3_Max_FBetaGamma_pp:return(Cmpd3_Max_FBetaGamma_pp(t_num)); break;
      case  Abs_Cmpd3_Min_FBetaGamma_pp:return(Abs_Cmpd3_Min_FBetaGamma_pp(t_num)); break;
      case  Abs_Cmpd3_Max_FBetaGamma_pp:return(Abs_Cmpd3_Max_FBetaGamma_pp(t_num)); break;
      case  Cmpd3_Min_F1BetaGamma_pp:return(Cmpd3_Min_F1BetaGamma_pp(t_num)); break;
      case  Cmpd3_Max_F1BetaGamma_pp:return(Cmpd3_Max_F1BetaGamma_pp(t_num)); break;
      case  Abs_Cmpd3_Min_F1BetaGamma_pp:return(Abs_Cmpd3_Min_F1BetaGamma_pp(t_num)); break;
      case  Abs_Cmpd3_Max_F1BetaGamma_pp:return(Abs_Cmpd3_Max_F1BetaGamma_pp(t_num)); break;          //147
      case  Cmpd3_Min_FF1Beta_pm:return(Cmpd3_Min_FF1Beta_pm(t_num)); break;
      case  Cmpd3_Max_FF1Beta_pm:return(Cmpd3_Max_FF1Beta_pm(t_num)); break;
      case  Abs_Cmpd3_Min_FF1Beta_pm:return(Abs_Cmpd3_Min_FF1Beta_pm(t_num)); break;
      case  Abs_Cmpd3_Max_FF1Beta_pm:return(Abs_Cmpd3_Max_FF1Beta_pm(t_num)); break;
      case  Cmpd3_Min_FF1Gamma_pm:return(Cmpd3_Min_FF1Gamma_pm(t_num)); break;
      case  Cmpd3_Max_FF1Gamma_pm:return(Cmpd3_Max_FF1Gamma_pm(t_num)); break;
      case  Abs_Cmpd3_Min_FF1Gamma_pm:return(Abs_Cmpd3_Min_FF1Gamma_pm(t_num)); break;
      case  Abs_Cmpd3_Max_FF1Gamma_pm:return(Abs_Cmpd3_Max_FF1Gamma_pm(t_num)); break;
      case  Cmpd3_Min_FBetaGamma_pm:return(Cmpd3_Min_FBetaGamma_pm(t_num)); break;
      case  Cmpd3_Max_FBetaGamma_pm:return(Cmpd3_Max_FBetaGamma_pm(t_num)); break;
      case  Abs_Cmpd3_Min_FBetaGamma_pm:return(Abs_Cmpd3_Min_FBetaGamma_pm(t_num)); break;
      case  Abs_Cmpd3_Max_FBetaGamma_pm:return(Abs_Cmpd3_Max_FBetaGamma_pm(t_num)); break;
      case  Cmpd3_Min_F1BetaGamma_pm:return(Cmpd3_Min_F1BetaGamma_pm(t_num)); break;
      case  Cmpd3_Max_F1BetaGamma_pm:return(Cmpd3_Max_F1BetaGamma_pm(t_num)); break;
      case  Abs_Cmpd3_Min_F1BetaGamma_pm:return(Abs_Cmpd3_Min_F1BetaGamma_pm(t_num)); break;
      case  Abs_Cmpd3_Max_F1BetaGamma_pm:return(Abs_Cmpd3_Max_F1BetaGamma_pm(t_num)); break;          //163
      case  Cmpd3_Min_FF1Beta_mp:return(Cmpd3_Min_FF1Beta_mp(t_num)); break;
      case  Cmpd3_Max_FF1Beta_mp:return(Cmpd3_Max_FF1Beta_mp(t_num)); break;
      case  Abs_Cmpd3_Min_FF1Beta_mp:return(Abs_Cmpd3_Min_FF1Beta_mp(t_num)); break;
      case  Abs_Cmpd3_Max_FF1Beta_mp:return(Abs_Cmpd3_Max_FF1Beta_mp(t_num)); break;
      case  Cmpd3_Min_FF1Gamma_mp:return(Cmpd3_Min_FF1Gamma_mp(t_num)); break;
      case  Cmpd3_Max_FF1Gamma_mp:return(Cmpd3_Max_FF1Gamma_mp(t_num)); break;
      case  Abs_Cmpd3_Min_FF1Gamma_mp:return(Abs_Cmpd3_Min_FF1Gamma_mp(t_num)); break;
      case  Abs_Cmpd3_Max_FF1Gamma_mp:return(Abs_Cmpd3_Max_FF1Gamma_mp(t_num)); break;
      case  Cmpd3_Min_FBetaGamma_mp:return(Cmpd3_Min_FBetaGamma_mp(t_num)); break;
      case  Cmpd3_Max_FBetaGamma_mp:return(Cmpd3_Max_FBetaGamma_mp(t_num)); break;
      case  Abs_Cmpd3_Min_FBetaGamma_mp:return(Abs_Cmpd3_Min_FBetaGamma_mp(t_num)); break;
      case  Abs_Cmpd3_Max_FBetaGamma_mp:return(Abs_Cmpd3_Max_FBetaGamma_mp(t_num)); break;
      case  Cmpd3_Min_F1BetaGamma_mp:return(Cmpd3_Min_F1BetaGamma_mp(t_num)); break;
      case  Cmpd3_Max_F1BetaGamma_mp:return(Cmpd3_Max_F1BetaGamma_mp(t_num)); break;
      case  Abs_Cmpd3_Min_F1BetaGamma_mp:return(Abs_Cmpd3_Min_F1BetaGamma_mp(t_num)); break;
      case  Abs_Cmpd3_Max_F1BetaGamma_mp:return(Abs_Cmpd3_Max_F1BetaGamma_mp(t_num)); break;          //179
      case  Cmpd3_Min_FF1Beta_mm:return(Cmpd3_Min_FF1Beta_mm(t_num)); break;
      case  Cmpd3_Max_FF1Beta_mm:return(Cmpd3_Max_FF1Beta_mm(t_num)); break;
      case  Abs_Cmpd3_Min_FF1Beta_mm:return(Abs_Cmpd3_Min_FF1Beta_mm(t_num)); break;
      case  Abs_Cmpd3_Max_FF1Beta_mm:return(Abs_Cmpd3_Max_FF1Beta_mm(t_num)); break;
      case  Cmpd3_Min_FF1Gamma_mm:return(Cmpd3_Min_FF1Gamma_mm(t_num)); break;
      case  Cmpd3_Max_FF1Gamma_mm:return(Cmpd3_Max_FF1Gamma_mm(t_num)); break;
      case  Abs_Cmpd3_Min_FF1Gamma_mm:return(Abs_Cmpd3_Min_FF1Gamma_mm(t_num)); break;
      case  Abs_Cmpd3_Max_FF1Gamma_mm:return(Abs_Cmpd3_Max_FF1Gamma_mm(t_num)); break;
      case  Cmpd3_Min_FBetaGamma_mm:return(Cmpd3_Min_FBetaGamma_mm(t_num)); break;
      case  Cmpd3_Max_FBetaGamma_mm:return(Cmpd3_Max_FBetaGamma_mm(t_num)); break;
      case  Abs_Cmpd3_Min_FBetaGamma_mm:return(Abs_Cmpd3_Min_FBetaGamma_mm(t_num)); break;
      case  Abs_Cmpd3_Max_FBetaGamma_mm:return(Abs_Cmpd3_Max_FBetaGamma_mm(t_num)); break;
      case  Cmpd3_Min_F1BetaGamma_mm:return(Cmpd3_Min_F1BetaGamma_mm(t_num)); break;
      case  Cmpd3_Max_F1BetaGamma_mm:return(Cmpd3_Max_F1BetaGamma_mm(t_num)); break;
      case  Abs_Cmpd3_Min_F1BetaGamma_mm:return(Abs_Cmpd3_Min_F1BetaGamma_mm(t_num)); break;
      case  Abs_Cmpd3_Max_F1BetaGamma_mm:return(Abs_Cmpd3_Max_F1BetaGamma_mm(t_num)); break;          //195
      case  Cmpd4_Min:return(Cmpd4_Min(t_num));break;
      case  Cmpd4_Max:return(Cmpd4_Max(t_num));break;
      case  Abs_Cmpd4_Min:return(Abs_Cmpd4_Min(t_num));break;
      case  Abs_Cmpd4_Max:return(Abs_Cmpd4_Max(t_num));break;                             //199
      case  Cmpd4_Min_ppp:return(Cmpd4_Min_ppp(t_num));break;
      case  Cmpd4_Max_ppp:return(Cmpd4_Max_ppp(t_num));break;
      case  Abs_Cmpd4_Min_ppp:return(Abs_Cmpd4_Min_ppp(t_num));break;
      case  Abs_Cmpd4_Max_ppp:return(Abs_Cmpd4_Max_ppp(t_num));break;                     //203
      case  Cmpd4_Min_ppm:return(Cmpd4_Min_ppm(t_num));break;
      case  Cmpd4_Max_ppm:return(Cmpd4_Max_ppm(t_num));break;
      case  Abs_Cmpd4_Min_ppm:return(Abs_Cmpd4_Min_ppm(t_num));break;
      case  Abs_Cmpd4_Max_ppm:return(Abs_Cmpd4_Max_ppm(t_num));break;                     //207
      case  Cmpd4_Min_pmp:return(Cmpd4_Min_pmp(t_num));break;
      case  Cmpd4_Max_pmp:return(Cmpd4_Max_pmp(t_num));break;
      case  Abs_Cmpd4_Min_pmp:return(Abs_Cmpd4_Min_pmp(t_num));break;
      case  Abs_Cmpd4_Max_pmp:return(Abs_Cmpd4_Max_pmp(t_num));break;                     //211
      case  Cmpd4_Min_mpp:return(Cmpd4_Min_mpp(t_num));break;
      case  Cmpd4_Max_mpp:return(Cmpd4_Max_mpp(t_num));break;
      case  Abs_Cmpd4_Min_mpp:return(Abs_Cmpd4_Min_mpp(t_num));break;
      case  Abs_Cmpd4_Max_mpp:return(Abs_Cmpd4_Max_mpp(t_num));break;                     //215
      case  Cmpd4_Min_mmm:return(Cmpd4_Min_mmm(t_num));break;
      case  Cmpd4_Max_mmm:return(Cmpd4_Max_mmm(t_num));break;
      case  Abs_Cmpd4_Min_mmm:return(Abs_Cmpd4_Min_mmm(t_num));break;
      case  Abs_Cmpd4_Max_mmm:return(Abs_Cmpd4_Max_mmm(t_num));break;                     //219
      case  Cmpd4_Min_mmp:return(Cmpd4_Min_mmp(t_num));break;
      case  Cmpd4_Max_mmp:return(Cmpd4_Max_mmp(t_num));break;
      case  Abs_Cmpd4_Min_mmp:return(Abs_Cmpd4_Min_mmp(t_num));break;
      case  Abs_Cmpd4_Max_mmp:return(Abs_Cmpd4_Max_mmp(t_num));break;                     //223
      case  Cmpd4_Min_mpm:return(Cmpd4_Min_mpm(t_num));break;
      case  Cmpd4_Max_mpm:return(Cmpd4_Max_mpm(t_num));break;
      case  Abs_Cmpd4_Min_mpm:return(Abs_Cmpd4_Min_mpm(t_num));break;
      case  Abs_Cmpd4_Max_mpm:return(Abs_Cmpd4_Max_mpm(t_num));break;                     //227
      case  Cmpd4_Min_pmm:return(Cmpd4_Min_pmm(t_num));break;
      case  Cmpd4_Max_pmm:return(Cmpd4_Max_pmm(t_num));break;
      case  Abs_Cmpd4_Min_pmm:return(Abs_Cmpd4_Min_pmm(t_num));break;
      case  Abs_Cmpd4_Max_pmm:return(m_Abs_Cmpd4_Max_pmm(t_num));break;                     //231
      case  VirtualLast:return(0);break;                                                  //Virtual 232                 
      default:return(0); break;                                // DEFAULT
     }
  }
//+------------------------------------------------------------------+
//|Read miniTR params and RT NP from files                           |
//+------------------------------------------------------------------+
int miniTR::ImportMiniTRParams(const string &Pair,const string &_FName)
  {
//Start speed measuring
   uint Start_measure=GetTickCount();

//Init filename
//   string fname="//"+AccountInfoString(ACCOUNT_SERVER)+"_"+Symbol()+"_miniTR";
//Check miniTR file

   string s=_FName+Pair+"_";

   int  fh_miniTR=FileOpen(s+m_FName_miniTR,FILE_READ|FILE_WRITE|FILE_BIN|FILE_COMMON);
   if(fh_miniTR==INVALID_HANDLE)
     {
      Print("Can`t open file "+s+m_FName_miniTR);
      return(-2);
     };

//Check rNP1 file
   int  fh1=FileOpen(s+m_FName_rNP1,FILE_READ|FILE_WRITE|FILE_BIN|FILE_COMMON);
   if(fh1==INVALID_HANDLE)
     {
      Print("Can`t open file "+s+m_FName_rNP1);
      return(-3);
     };

//Check rNP4 file
   int  fh4=FileOpen(s+m_FName_rNP4,FILE_READ|FILE_WRITE|FILE_BIN|FILE_COMMON);
   if(fh4==INVALID_HANDLE)
     {
      Print("Can`t open file "+s+m_FName_rNP4);
      return(-4);
     };

//Check rNP14 file
   int  fh14=FileOpen(s+m_FName_rNP14,FILE_READ|FILE_WRITE|FILE_BIN|FILE_COMMON);
   if(fh14==INVALID_HANDLE)
     {
      Print("Can`t open file "+s+m_FName_rNP14);
      return(-5);
     };

//Counters
   int i=0;
   int i1=0;
   int i4=0;
   int i14=0;

   ArrayFree(m_arr_mtr);
//   ArrayFill(m_arr_mtr,0,WHOLE_ARRAY,0);

//Read from bin file miniTR params
   while(!FileIsEnding(fh_miniTR) && !IsStopped())
     {
      ArrayResize(m_arr_mtr,ArraySize(m_arr_mtr)+1,10000);
      FileReadStruct(fh_miniTR,m_arr_mtr[i]);
      i++;
     }//end of while

   Print("Readed miniTR Count: "+(string)i);

   ArrayFree(m_arr_rNP1);
//   ArrayFill(m_arr_rNP1,0,WHOLE_ARRAY,0);

//Read from bin file rNP1 
   while(!FileIsEnding(fh1) && !IsStopped())
     {
      ArrayResize(m_arr_rNP1,ArraySize(m_arr_rNP1)+1,10000);
      FileReadStruct(fh1,m_arr_rNP1[i1]);
      i1++;
     }//end of while

   Print("Readed NP1 Count: "+(string)i1);

   ArrayFree(m_arr_rNP4);
//   ArrayFill(arr_rNP4,0,WHOLE_ARRAY,0);

//Read from bin file rNP4 
   while(!FileIsEnding(fh4) && !IsStopped())
     {
      ArrayResize(m_arr_rNP4,ArraySize(m_arr_rNP4)+1,10000);
      FileReadStruct(fh4,m_arr_rNP4[i4]);
      i4++;
     }//end of while

   Print("Readed NP4 Count: "+(string)i4);

   ArrayFree(m_arr_rNP14);
//   ArrayFill(m_m_arr_rNP14,0,WHOLE_ARRAY,0);

//Read from bin file rNP14 
   while(!FileIsEnding(fh14) && !IsStopped())
     {
      ArrayResize(m_arr_rNP14,ArraySize(m_arr_rNP14)+1,10000);
      FileReadStruct(fh14,m_arr_rNP14[i14]);
      i14++;
     }//end of while

   Print("Readed NP14 Count: "+(string)i14);

//Check if wrong number T imported from any file
   if((i1!=i4) || (i4!=i14) || (i1!=i))
     {
      Print("<<<<<< WARNING >>>>>>> -->>> Imported Various T Count!!!, Exit! ");
      return(-1);
     }

   FileClose(fh_miniTR);
   FileClose(fh1);
   FileClose(fh4);
   FileClose(fh14);

//Stop speed measuring
   uint Stop_measuring=GetTickCount()-Start_measure;
   Print("Import complete in "+(string)Stop_measuring+" ms, Items Count: "+(string)i);

//Save Total imported T Count   
   m_T_Count=i;

//Check Group
   if(m_T_Count>0) m_Check_GroupID();
   else {Print("T Count="+(string)m_T_Count); return(-1);}

   return(m_T_Count);
  }//END OF Import
//+------------------------------------------------------------------+
//| Get size of Group ID                                             |
//+------------------------------------------------------------------+
int miniTR::m_GroupsCount(void)
  {
   int j=0;
   for(int i=NOTRADE;i<Unknown;++i)
      j++;
   return(j);
  }
//+------------------------------------------------------------------+
//| Get size of miniTR ID                                            |
//+------------------------------------------------------------------+
int miniTR::m_MiniTrCount(void)
  {
   int j=0;
   for(int i=C1;i<VirtualLast;++i)
      j++;
   return(j);
  }
//+------------------------------------------------------------------+
//|Check GroupID of every interval T                                 |
//+------------------------------------------------------------------+
void miniTR::m_Check_GroupID()
  {
//Clear m_arr and set size (T)
   ArrayFree(m_arr_GroupID);
   ArrayFree(m_arr_T_Count_in_GRP);

//Interations count 
   int ArrSize=ArraySize(m_arr_mtr);

   ArrayResize(m_arr_GroupID,ArrSize);
   ArrayResize(m_arr_T_Count_in_GRP,m_groups_count);
   ArrayFill(m_arr_T_Count_in_GRP,0,m_groups_count,0);

//Check GROUP  
   for(int i=0;i<ArrSize;i++)
     {
      //If Unknown - > Set it to Unknown
      m_arr_GroupID[i]=Unknown;

      //0 SS SleepMarket
      if((m_arr_mtr[i].dQ1==0) && (m_arr_mtr[i].dQ4==0))
        {m_arr_GroupID[i]=NOTRADE; m_arr_T_Count_in_GRP[NOTRADE]++; continue;}

      //2 FS Singularity      
      if(((m_arr_mtr[i].dQ1*m_arr_mtr[i].dQ4)==0) && ((m_arr_mtr[i].dQ1+m_arr_mtr[i].dQ4)!=0))
        {m_arr_GroupID[i]=FSingul; m_arr_T_Count_in_GRP[FSingul]++; continue;}

      //3 F1S Singularity      
      if(((m_arr_mtr[i].dQ1-m_arr_mtr[i].dQ4)==0) && ((m_arr_mtr[i].dQ1+m_arr_mtr[i].dQ4)!=0))
        {m_arr_GroupID[i]=F1Singul; m_arr_T_Count_in_GRP[F1Singul]++; continue;}

      //4 Beta Singularity
      if(((m_arr_mtr[i].dQ1*m_arr_mtr[i].dQ4)==0) && ((m_arr_mtr[i].dQ4-m_arr_mtr[i].dQ1)!=0))
        {m_arr_GroupID[i]=BetaSingul; m_arr_T_Count_in_GRP[BetaSingul]++; continue;}

      //5 Gamma Singularity
      if(m_arr_mtr[i].dQ14==0)
        {m_arr_GroupID[i]=GammaSingul; m_arr_T_Count_in_GRP[GammaSingul]++; continue;}

      //2 Hybrid Singularity, not to Detect!
      //      if(m_arr_GroupID[i])

      //6 PPpp
      if((m_arr_mtr[i].F==1) && (m_arr_mtr[i].F1==1) && (m_arr_mtr[i].Beta==1) && (m_arr_mtr[i].Gamma==1))
        {
         m_arr_GroupID[i]=PP_pp;
         m_arr_T_Count_in_GRP[PP_pp]++;
         continue;
        }

      //7 PPmm
      if((m_arr_mtr[i].F==1) && (m_arr_mtr[i].F1==1) && (m_arr_mtr[i].Beta==-1) && (m_arr_mtr[i].Gamma==-1))
        {
         m_arr_GroupID[i]=PP_mm;
         m_arr_T_Count_in_GRP[PP_mm]++;
         continue;
        }

      //8 PPpm
      if((m_arr_mtr[i].F==1) && (m_arr_mtr[i].F1==1) && (m_arr_mtr[i].Beta==1) && (m_arr_mtr[i].Gamma==-1))
        {
         m_arr_GroupID[i]=PP_pm;
         m_arr_T_Count_in_GRP[PP_pm]++;
         continue;
        }

      //9 PPmp
      if((m_arr_mtr[i].F==1) && (m_arr_mtr[i].F1==1) && (m_arr_mtr[i].Beta==-1) && (m_arr_mtr[i].Gamma==1))
        {
         m_arr_GroupID[i]=PP_mp;
         m_arr_T_Count_in_GRP[PP_mp]++;
         continue;
        }

      //10 MMpp
      if((m_arr_mtr[i].F==-1) && (m_arr_mtr[i].F1==-1) && (m_arr_mtr[i].Beta==1) && (m_arr_mtr[i].Gamma==1))
        {
         m_arr_GroupID[i]=MM_pp;
         m_arr_T_Count_in_GRP[MM_pp]++;
         continue;
        }

      //11 MMmm
      if((m_arr_mtr[i].F==-1) && (m_arr_mtr[i].F1==-1) && (m_arr_mtr[i].Beta==-1) && (m_arr_mtr[i].Gamma==-1))
        {
         m_arr_GroupID[i]=MM_mm;
         m_arr_T_Count_in_GRP[MM_mm]++;
         continue;
        }

      //12 MMpm
      if((m_arr_mtr[i].F==-1) && (m_arr_mtr[i].F1==-1) && (m_arr_mtr[i].Beta==1) && (m_arr_mtr[i].Gamma==-1))
        {
         m_arr_GroupID[i]=MM_pm;
         m_arr_T_Count_in_GRP[MM_pm]++;
         continue;
        }

      //13 MMmp
      if((m_arr_mtr[i].F==-1) && (m_arr_mtr[i].F1==-1) && (m_arr_mtr[i].Beta==-1) && (m_arr_mtr[i].Gamma==1))
        {
         m_arr_GroupID[i]=MM_mp;
         m_arr_T_Count_in_GRP[MM_mp]++;
         continue;
        }

      //14 PMpp
      if((m_arr_mtr[i].F==1) && (m_arr_mtr[i].F1==-1) && (m_arr_mtr[i].Beta==1) && (m_arr_mtr[i].Gamma==1))
        {
         m_arr_GroupID[i]=PM_pp;
         m_arr_T_Count_in_GRP[PM_pp]++;
         continue;
        }

      //15 PMmm
      if((m_arr_mtr[i].F==1) && (m_arr_mtr[i].F1==-1) && (m_arr_mtr[i].Beta==-1) && (m_arr_mtr[i].Gamma==-1))
        {
         m_arr_GroupID[i]=PM_mm;
         m_arr_T_Count_in_GRP[PM_mm]++;
         continue;
        }

      //16 PMpm
      if((m_arr_mtr[i].F==1) && (m_arr_mtr[i].F1==-1) && (m_arr_mtr[i].Beta==1) && (m_arr_mtr[i].Gamma==-1))
        {
         m_arr_GroupID[i]=PM_pm;
         m_arr_T_Count_in_GRP[PM_pm]++;
         continue;
        }

      //17 PMmp
      if((m_arr_mtr[i].F==1) && (m_arr_mtr[i].F1==-1) && (m_arr_mtr[i].Beta==-1) && (m_arr_mtr[i].Gamma==1))
        {
         m_arr_GroupID[i]=PM_mp;
         m_arr_T_Count_in_GRP[PM_mp]++;
         continue;
        }

      //18 MPpp
      if((m_arr_mtr[i].F==-1) && (m_arr_mtr[i].F1==1) && (m_arr_mtr[i].Beta==1) && (m_arr_mtr[i].Gamma==1))
        {
         m_arr_GroupID[i]=MP_pp;
         m_arr_T_Count_in_GRP[MP_pp]++;
         continue;
        }

      //19 MPmm
      if((m_arr_mtr[i].F==-1) && (m_arr_mtr[i].F1==1) && (m_arr_mtr[i].Beta==-1) && (m_arr_mtr[i].Gamma==-1))
        {
         m_arr_GroupID[i]=MP_mm;
         m_arr_T_Count_in_GRP[MP_mm]++;
         continue;
        }

      //20 MPpm
      if((m_arr_mtr[i].F==-1) && (m_arr_mtr[i].F1==1) && (m_arr_mtr[i].Beta==1) && (m_arr_mtr[i].Gamma==-1))
        {
         m_arr_GroupID[i]=MP_pm;
         m_arr_T_Count_in_GRP[MP_pm]++;
         continue;
        }

      //21 MPmp
      if((m_arr_mtr[i].F==-1) && (m_arr_mtr[i].F1==1) && (m_arr_mtr[i].Beta==-1) && (m_arr_mtr[i].Gamma==1))
        {
         m_arr_GroupID[i]=MP_mp;
         m_arr_T_Count_in_GRP[MP_mp]++;
         continue;
        }
     }//END OF FOR

   Print("Check Group Complete.");
  }//END OF Check Group
//+------------------------------------------------------------------+
//| Process all miniTRs of a Groups                                  |
//+------------------------------------------------------------------+
void miniTR::Process_miniTR()
  {
//Start speed measuring
   uint Start_measure=GetTickCount();

//Result   
   int res=0;
   int ArrSize=ArraySize(m_arr_GroupID);

//   ArrayFree(arr_SUM_NP_GROUP);

//Set 0 dimension size to Count of Functions Like MinAB
   ArrayResize(m_arr_SUM_NP_GROUP,m_minitr_count);

//Always Fill IT!!! Before +=
   ArrayFill(m_arr_SUM_NP_GROUP,0,ArraySize(m_arr_SUM_NP_GROUP),0);

//Cycle by each T interval for every miniTR (T Count - imported from file)
   for(int t=0;t<ArrSize;t++)
     {
      for(ENUM_miniTR_ID mini=0;mini<m_minitr_count;mini++)
        {
         // x - row(227);y - column(23)
         // Sum NP By Group & miniTR#
         m_arr_SUM_NP_GROUP[mini][m_arr_GroupID[t]]+=m_Calc_miniTR(mini,t);
        }//END OF FOR mini
     }//END OF FOR t

//Stop speed measuring
   uint Stop_measuring=GetTickCount()-Start_measure;
   Print("Processing complete in "+(string)Stop_measuring+" ms");//, Items Count: "+(string)i);
                                                                 //
//Find Best miniTR
   m_FindBest_miniTR();
  }
//+------------------------------------------------------------------+
//| Find Best miniTR for every group                                 |
//+------------------------------------------------------------------+
void miniTR::m_FindBest_miniTR()
  {
   double MaximumNP=-9999999999999;

//Find Best miniTR in each Group  
   for(int j=0;j<m_groups_count;j++)
     {
      //Clear Maximum
      MaximumNP=0;

      for(int i=0;i<m_minitr_count;i++)
        {
         if(m_arr_SUM_NP_GROUP[i][j]>MaximumNP)
           {
            //Save Maximum NP
            MaximumNP=m_arr_SUM_NP_GROUP[i][j];

            //Save miniTR Index & Best NP for this GroupID
            m_arr_minitr[j].minitr=i;
            m_arr_minitr[j].BestNP=MaximumNP;
           }
        }//END OF i-miniTRs Count (4+)
     }//END OF J-GROUPS(23)
   Alert("Find best miniTR Complete.");
  }
//+------------------------------------------------------------------+
//| Export miniTR to Bin (23 uchars)                                 |
//+------------------------------------------------------------------+
void miniTR::ExportMiniTR_ToBin()
  {
//Init filename
   string fname="//"+AccountInfoString(ACCOUNT_SERVER)+"_"+Symbol()+"_atr";

//If exist, del file (Replace by new one)
   if(FileIsExist(fname,FILE_READ|FILE_WRITE|FILE_COMMON|FILE_BIN))
      FileDelete(fname,FILE_READ|FILE_WRITE|FILE_COMMON|FILE_BIN);

//Init 
   int  file_h1=FileOpen(fname,FILE_READ|FILE_WRITE|FILE_BIN|FILE_COMMON);
   if(file_h1==INVALID_HANDLE)  return;

//Export
   for(int i=0;i<m_groups_count;i++)
      FileWriteStruct(file_h1,m_arr_minitr[i]);

//Close File
   FileClose(file_h1);
  }
//+------------------------------------------------------------------+
//| Export Matrix to CSV                                             |
//+------------------------------------------------------------------+  
void miniTR::ExportMatrix_CSV(const bool m_csv_separator)
  {
/*
Each Cell consist Best miniTR
Columns Groups (23),Rows T(n)
T1    min   max   ...   n23
T2    min   min   ...   n23
Tn    max   max   ...   n23
*/
//Choose CSV Separator
   string SP="";
   if(m_csv_separator) SP=MacSeparator;
   else SP=WindowsSeparator;

//Get Info:
   string G_Company=AccountInfoString(ACCOUNT_COMPANY);
   string G_Server=AccountInfoString(ACCOUNT_SERVER);
   long G_AccountNumber=AccountInfoInteger(ACCOUNT_LOGIN);
   string G_AccountOwner=AccountInfoString(ACCOUNT_NAME);
   long G_AccountLeverage=AccountInfoInteger(ACCOUNT_LEVERAGE);

//Init filename
   string fname="//"+G_Server+"_"+Symbol()+"_mtrx.csv";
//If exist, del file
   if(FileIsExist(fname,FILE_READ|FILE_WRITE|FILE_COMMON|FILE_CSV|FILE_ANSI))
     {
      FileDelete(fname,FILE_READ|FILE_WRITE|FILE_COMMON|FILE_CSV|FILE_ANSI);
     }

//Create handle
   int file_handle=FileOpen(fname,FILE_READ|FILE_WRITE|FILE_COMMON|FILE_CSV|FILE_ANSI);
//Check if can`t create     
   if(file_handle==INVALID_HANDLE)
     {
      Print(__FUNCTION__+"Err:",GetLastError()," on FileOpen");
      return;
     }

//0  Output HEADER string
   string s="Company: "+G_Company+"\r\n";
   s+=" Server: "+G_Server+"\r\n";
   s+=" Account: "+IntegerToString(G_AccountNumber)+"\r\n";
   s+=" Owner: "+G_AccountOwner+"\r\n";
   s+=" Leverage: "+IntegerToString(G_AccountLeverage)+"\r\n";
   s+=Symbol()+"\r\n";
   s+=" Total T-count: "+IntegerToString(m_T_Count)+"\r\n";
   s+="Groups Count:  "+IntegerToString(m_groups_count)+"\r\n";

//Left side of the Header 1
   s+="   T"+SP+"   NP1"+SP+"   NP4"+SP+"    dQ1"+SP+"   dQ4"+SP+"   Group"+SP+" StartDate"+SP;

//1  Header Row - Groups Names
   for(ENUM_T_GROUP_ID i=NOTRADE;i<Unknown;i++)
      s+=EnumToString(i)+"          "+SP;

//Next Row
   s+="\r\n";

//Left side of the Header 3
   s+="Best NP GROUP SUM:"+SP+SP+SP+SP+SP+SP+SP;

//3  Third Header Row - Best NP  for each group   
   for(ENUM_T_GROUP_ID i=NOTRADE;i<Unknown;i++)
      s+=DoubleToString(m_arr_minitr[i].BestNP,2)+SP;

//Next Row
   s+="\r\n";

//Left side of the Header 2
   s+="Best miniTR:"+SP+SP+SP+SP+SP+SP+SP;

//2  Second Header Row - Best miniTR name for each group   
   for(ENUM_T_GROUP_ID i=NOTRADE;i<Unknown;i++)
     {
      //Don`t Show not trade
      if(m_arr_minitr[i].minitr<2) s+=""+SP;
      else  s+=EnumToString((ENUM_miniTR_ID)m_arr_minitr[i].minitr)+SP;
     }

//Next Row
   s+="\r\n";

   ENUM_miniTR_ID mini=0;
//Circle T -Rows with Best miniTR in each Group 
   for(int i=0;i<m_T_Count;i++)
     {
      //Begin of each ROW
      s+=IntegerToString(i)+SP;
      s+=DoubleToString(m_arr_rNP1[i].NP1_RT,2)+SP;
      s+=DoubleToString(m_arr_rNP4[i].NP4_RT,2)+SP;
      s+=IntegerToString(m_arr_mtr[i].dQ1)+SP;
      s+=IntegerToString(m_arr_mtr[i].dQ4)+SP;
      s+=EnumToString(m_arr_GroupID[i])+SP;
      s+=TimeToString(m_arr_mtr[i].StartTime)+SP;
      for(int j=0;j<m_groups_count;j++)
        {
         //Best TR NP1 or NP4
         mini=(ENUM_miniTR_ID)m_arr_minitr[j].minitr;
         s+=DoubleToString(m_Calc_miniTR(mini,i),2)+SP;
        }//END OF Column-Group FOR  
      //End of each ROW
      s+="\r\n";
     }//END OF T-ROW FOR

//Write String to CSV
   FileWriteString(file_handle,s);

//Close File
   FileClose(file_handle);
   Print("Export matrix to CSV Completed..");
  }
//+------------------------------------------------------------------+
//--------------------------------------------------------------------
//|   #231 ABS Compound 4(+--) Max FF1BetaGamma , miniTR             |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd4_Max_pmm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|   #2 MinAB, miniTR                                               |
//+------------------------------------------------------------------+  
double miniTR::m_MinAB(const int &T_NUM)
  {
   m_result=0;
   m_result=MathMin(arr_mtr[T_NUM].A,arr_mtr[T_NUM].B);

//Sum NP by Group
   if(m_result==arr_mtr[T_NUM].A) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #3  MaxAB, miniTR                                              |
//+------------------------------------------------------------------+  
double miniTR::m_MaxAB(const int &T_NUM)
  {
   m_result=0;
   m_result=MathMax(arr_mtr[T_NUM].A,arr_mtr[T_NUM].B);

//Sum NP by Group
   if(m_result==arr_mtr[T_NUM].A) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #5 ABS  MinAB, miniTR                                          |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Min_AB(const int &T_NUM)
  {
   AbsA=0; AbsB=0; m_result=0;
   AbsA = MathAbs(arr_mtr[T_NUM].A);
   AbsB = MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(AbsA,AbsB);

//Sum NP by Group
   if(m_result==AbsA) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #6 ABS  MaxAB, miniTR                                          |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Max_AB(const int &T_NUM)
  {
   AbsA=0; AbsB=0; m_result=0;
   AbsA = MathAbs(arr_mtr[T_NUM].A);
   AbsB = MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(AbsA,AbsB);

//Sum NP by Group
   if(m_result==AbsA) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #7 Min fAB, miniTR                                             |
//+------------------------------------------------------------------+  
double miniTR::m_Min_fAB(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;
   x1 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].B;
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #8 Max fAB, miniTR                                             |
//+------------------------------------------------------------------+  
double miniTR::m_Max_fAB(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;
   x1 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].B;
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #9 ABS Min fAB, miniTR                                         |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Min_fAB(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;
   x1 = arr_mtr[T_NUM].F*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #10 ABS Max fAB, miniTR                                        |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Max_fAB(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;
   x1 = arr_mtr[T_NUM].F*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #11 Min f1AB, miniTR                                           |
//+------------------------------------------------------------------+  
double miniTR::m_Min_f1AB(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;
   x1 = arr_mtr[T_NUM].F1*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].F1*arr_mtr[T_NUM].B;
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #12 Max f1AB, miniTR                                           |
//+------------------------------------------------------------------+  
double miniTR::m_Max_f1AB(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;
   x1 = arr_mtr[T_NUM].F1*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].F1*arr_mtr[T_NUM].B;
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #13 ABS Min f1AB, miniTR                                       |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Min_f1AB(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;
   x1 = arr_mtr[T_NUM].F1*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F1*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #14 ABS Max f1AB, miniTR                                       |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Max_f1AB(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;
   x1 = arr_mtr[T_NUM].F1*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F1*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #15 Min BetaAB, miniTR                                         |
//+------------------------------------------------------------------+  
double miniTR::m_Min_BetaAB(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;
   x1 = arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].B;
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #16 Max BetaAB, miniTR                                         |
//+------------------------------------------------------------------+  
double miniTR::m_Max_BetaAB(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;
   x1 = arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].B;
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #17 ABS Min BetaAB, miniTR                                     |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Min_BetaAB(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;
   x1 = arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #18 ABS Max BetaAB, miniTR                                     |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Max_BetaAB(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;
   x1 = arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #19 Min HammaAB, miniTR                                        |
//+------------------------------------------------------------------+  
double miniTR::m_Min_GammaAB(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;
   x1 = arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].B;
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #20 Max GammaAB, miniTR                                        |
//+------------------------------------------------------------------+  
double miniTR::m_Max_GammaAB(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;
   x1 = arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].B;
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #21 ABS Min GammaAB, miniTR                                    |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Min_GammaAB(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;
   x1 = arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #22 ABS Max GammaAB, miniTR                                    |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Max_GammaAB(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;
   x1 = arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #24  dQ1=dQ4  C1  , miniTR                                     |
//+------------------------------------------------------------------+  
double miniTR::m_Equal_dQ1Q4_C1(const int &T_NUM)
  {
   if(arr_mtr[T_NUM].dQ1==arr_mtr[T_NUM].dQ4) return(arr_rNP1[T_NUM].NP1_RT);
   else return(0);
  }
//+------------------------------------------------------------------+
//|   #25  dQ1=dQ4  C4  , miniTR                                     |
//+------------------------------------------------------------------+  
double miniTR::m_Equal_dQ1Q4_C4(const int &T_NUM)
  {
   if(arr_mtr[T_NUM].dQ1==arr_mtr[T_NUM].dQ4) return(arr_rNP1[T_NUM].NP1_RT);
   else return(0);
  }
//+------------------------------------------------------------------+
//|   #27 dQ1=dQ4 Min, miniTR                                        |
//+------------------------------------------------------------------+  
double miniTR::m_Equal_dQ1Q4_MinAB(const int &T_NUM)
  {
   if(arr_mtr[T_NUM].dQ1!=arr_mtr[T_NUM].dQ4) return(0);

   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].B;
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #28 dQ1=dQ4 Max, miniTR                                        |
//+------------------------------------------------------------------+  
double miniTR::m_Equal_dQ1Q4_MaxAB(const int &T_NUM)
  {
   if(arr_mtr[T_NUM].dQ1!=arr_mtr[T_NUM].dQ4) return(0);

   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].B;
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #29 dQ1=0 dQ4=0 C1, miniTR                                     |
//+------------------------------------------------------------------+  
double miniTR::m_Zero_dQ1Q4_C1(const int &T_NUM)
  {
   if((arr_mtr[T_NUM].dQ1==0) && (arr_mtr[T_NUM].dQ4==0)) return(arr_rNP1[T_NUM].NP1_RT);
   else return(0);
  }
//+------------------------------------------------------------------+
//|   #30 dQ1=0 dQ4=0 C1, miniTR                                     |
//+------------------------------------------------------------------+  
double miniTR::m_Zero_dQ1Q4_C4(const int &T_NUM)
  {
   if((arr_mtr[T_NUM].dQ1==0) && (arr_mtr[T_NUM].dQ4==0)) return(arr_rNP4[T_NUM].NP4_RT);
   else return(0);
  }
//+------------------------------------------------------------------+
//|   #32 dQ1=0 dQ4=0 Min, miniTR                                    |
//+------------------------------------------------------------------+  
double miniTR::m_Zero_dQ1Q4_MinAB(const int &T_NUM)
  {
   if((arr_mtr[T_NUM].dQ1!=0) && (arr_mtr[T_NUM].dQ4!=0)) return(0);

   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].B;
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #33 dQ1=0 dQ4=0 Max, miniTR                                    |
//+------------------------------------------------------------------+  
double miniTR::m_Zero_dQ1Q4_MaxAB(const int &T_NUM)
  {
   if((arr_mtr[T_NUM].dQ1!=0) && (arr_mtr[T_NUM].dQ4!=0)) return(0);

   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].B;
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #34 A=B C1, miniTR                                             |
//+------------------------------------------------------------------+  
double miniTR::m_Equal_AB_C1(const int &T_NUM)
  {
   if((arr_mtr[T_NUM].A==arr_mtr[T_NUM].B)) return(arr_rNP1[T_NUM].NP1_RT);
   else return(0);
  }
//+------------------------------------------------------------------+
//|   #35 A=B C4, miniTR                                             |
//+------------------------------------------------------------------+  
double miniTR::m_Equal_AB_C4(const int &T_NUM)
  {
   if((arr_mtr[T_NUM].A==arr_mtr[T_NUM].B)) return(arr_rNP4[T_NUM].NP4_RT);
   else return(0);
  }
//+------------------------------------------------------------------+
//|   #37 A=B Min , miniTR                                           |
//+------------------------------------------------------------------+  
double miniTR::m_Equal_AB_MinAB(const int &T_NUM)
  {
   if((arr_mtr[T_NUM].A!=arr_mtr[T_NUM].B)) return(0);

   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].B;
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #38 A=B Max , miniTR                                           |
//+------------------------------------------------------------------+  
double miniTR::m_Equal_AB_MaxAB(const int &T_NUM)
  {
   if((arr_mtr[T_NUM].A!=arr_mtr[T_NUM].B)) return(0);

   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].B;
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #39 A*B=0 C1 , miniTR                                          |
//+------------------------------------------------------------------+  
double miniTR::m_Zero_AmB_C1(const int &T_NUM)
  {
   if((arr_mtr[T_NUM].A*arr_mtr[T_NUM].B)==0) return(arr_rNP1[T_NUM].NP1_RT);
   else return(0);
  }
//+------------------------------------------------------------------+
//|   #40 A*B=0 C4 , miniTR                                          |
//+------------------------------------------------------------------+  
double miniTR::m_Zero_AmB_C4(const int &T_NUM)
  {
   if((arr_mtr[T_NUM].A*arr_mtr[T_NUM].B)==0) return(arr_rNP4[T_NUM].NP4_RT);
   else return(0);
  }
//+------------------------------------------------------------------+
//|   #42 A*B=0 Min , miniTR                                         |
//+------------------------------------------------------------------+  
double miniTR::m_Zero_AmB_MinAB(const int &T_NUM)
  {
   if((arr_mtr[T_NUM].A*arr_mtr[T_NUM].B)!=0) return(0);

   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].B;
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #43 A*B=0 Max , miniTR                                         |
//+------------------------------------------------------------------+  
double miniTR::m_Zero_AmB_MaxAB(const int &T_NUM)
  {
   if((arr_mtr[T_NUM].A*arr_mtr[T_NUM].B)!=0) return(0);

   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].B;
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #44 Compound 2(*) Min FF1 , miniTR                             |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Min_FF1(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].F1*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].F1*arr_mtr[T_NUM].B;
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #45 Compound 2(*) Max FF1 , miniTR                             |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Max_FF1(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].F1*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].F1*arr_mtr[T_NUM].B;
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #46 ABS Compound 2(*) Min FF1 , miniTR                         |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Min_FF1(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].F1*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].F1*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #47 ABS Compound 2(*) Max FF1 , miniTR                         |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Max_FF1(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].F1*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].F1*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #48 Compound 2(*) Min FBeta , miniTR                           |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Min_FBeta(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].B;
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #49 Compound 2(*) Max FBeta , miniTR                           |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Max_FBeta(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].B;
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #50 ABS Compound 2(*) Min FBeta miniTR                         |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Min_FBeta(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #51 ABS Compound 2(*) Max FBeta , miniTR                       |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Max_FBeta(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #52 Compound 2(*) Min FGamma , miniTR                          |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Min_FGamma(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].B;
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #53 Compound 2(*) Max FGamma , miniTR                          |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Max_FGamma(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].B;
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #54 ABS Compound 2(*) Min FGamma miniTR                        |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Min_FGamma(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #55 ABS Compound 2(*) Max FGamma , miniTR                      |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Max_FGamma(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #56 Compound 2(*) Min F1Beta , miniTR                          |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Min_F1Beta(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].B;
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #57 Compound 2(*) Max F1Beta , miniTR                          |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Max_F1Beta(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].B;
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #58 ABS Compound 2(*) Min F1Beta miniTR                        |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Min_F1Beta(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #59 ABS Compound 2(*) Max F1Beta , miniTR                      |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Max_F1Beta(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #60 Compound 2(*) Min F1Gamma , miniTR                         |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Min_F1Gamma(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].B;
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #61 Compound 2(*) Max F1Gamma , miniTR                         |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Max_F1Gamma(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].B;
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #62 ABS Compound 2(*) Min F1Gamma miniTR                       |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Min_F1Gamma(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #63 ABS Compound 2(*) Max F1Gamma , miniTR                     |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Max_F1Gamma(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #64 Compound 2(*) Min BetaGamma , miniTR                       |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Min_BetaGamma(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].B;
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #65 Compound 2(*) Max BetaGamma , miniTR                       |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Max_BetaGamma(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].B;
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #66 ABS Compound 2(*) Min BetaGamma miniTR                     |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Min_BetaGamma(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #67 ABS Compound 2(*) Max BetaGamma , miniTR                   |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Max_BetaGamma(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #68 Compound 2(+) Min FF1 , miniTR                             |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Min_FF1_plus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1*arr_mtr[T_NUM].B;
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #69 Compound 2(+) Max FF1 , miniTR                             |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Max_FF1_plus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1*arr_mtr[T_NUM].B;
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #70 ABS Compound 2(-) Min FF1 , miniTR                         |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Min_FF1_plus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #71 ABS Compound 2(+) Max FF1 , miniTR                         |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Max_FF1_plus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #72 Compound 2(+) Min FBeta , miniTR                           |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Min_FBeta_plus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].B;
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #73 Compound 2(+) Max FBeta , miniTR                           |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Max_FBeta_plus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].B;
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #74 ABS Compound 2(+) Min FBeta miniTR                         |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Min_FBeta_plus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #75 ABS Compound 2(+) Max FBeta , miniTR                       |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Max_FBeta_plus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #76 Compound 2(+) Min FGamma , miniTR                          |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Min_FGamma_plus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].B;
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #77 Compound 2(+) Max FGamma , miniTR                          |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Max_FGamma_plus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].B;
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #78 ABS Compound 2(+) Min FGamma miniTR                        |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Min_FGamma_plus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #79 ABS Compound 2(+) Max FGamma , miniTR                      |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Max_FGamma_plus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #80 Compound 2(+) Min F1Beta , miniTR                          |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Min_F1Beta_plus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].B;
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #81 Compound 2(+) Max F1Beta , miniTR                          |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Max_F1Beta_plus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].B;
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #82 ABS Compound 2(+) Min F1Beta miniTR                        |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Min_F1Beta_plus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #83 ABS Compound 2(+) Max F1Beta , miniTR                      |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Max_F1Beta_plus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #84 Compound 2(+) Min F1Gamma , miniTR                         |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Min_F1Gamma_plus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].B;
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #85 Compound 2(+) Max F1Gamma , miniTR                         |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Max_F1Gamma_plus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].B;
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #86 ABS Compound 2(+) Min F1Gamma miniTR                       |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Min_F1Gamma_plus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #87 ABS Compound 2(+) Max F1Gamma , miniTR                     |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Max_F1Gamma_plus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #88 Compound 2(+) Min BetaGamma , miniTR                       |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Min_BetaGamma_plus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].B;
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #89 Compound 2(+) Max BetaGamma , miniTR                       |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Max_BetaGamma_plus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].B;
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #90 ABS Compound 2(+) Min BetaGamma miniTR                     |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Min_BetaGamma_plus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #91 ABS Compound 2(+) Max BetaGamma , miniTR                   |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Max_BetaGamma_plus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #92 Compound 2(-) Min FF1 , miniTR                             |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd2_Min_FF1_minus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1*arr_mtr[T_NUM].B;
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #93 Compound 2(-) Max FF1 , miniTR                             |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd2_Max_FF1_minus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1*arr_mtr[T_NUM].B;
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #94 ABS Compound 2(-) Min FF1 , miniTR                         |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd2_Min_FF1_minus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #95 ABS Compound 2(-) Max FF1 , miniTR                         |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd2_Max_FF1_minus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #96 Compound 2(-) Min FBeta , miniTR                           |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd2_Min_FBeta_minus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].B;
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #97 Compound 2(-) Max FBeta , miniTR                           |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd2_Max_FBeta_minus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].B;
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #98 ABS Compound 2(-) Min FBeta miniTR                         |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd2_Min_FBeta_minus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #99 ABS Compound 2(-) Max FBeta , miniTR                       |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd2_Max_FBeta_minus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #100 Compound 2(-) Min FGamma , miniTR                         |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd2_Min_FGamma_minus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].B;
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #101 Compound 2(-) Max FGamma , miniTR                         |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd2_Max_FGamma_minus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].B;
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #102 ABS Compound 2(-) Min FGamma miniTR                        |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd2_Min_FGamma_minus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #103 ABS Compound 2(-) Max FGamma , miniTR                      |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd2_Max_FGamma_minus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #104 Compound 2(-) Min F1Beta , miniTR                          |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd2_Min_F1Beta_minus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].B;
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #105 Compound 2(-) Max F1Beta , miniTR                          |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd2_Max_F1Beta_minus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].B;
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #106 ABS Compound 2(-) Min F1Beta miniTR                        |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd2_Min_F1Beta_minus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #107 ABS Compound 2(-) Max F1Beta , miniTR                      |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd2_Max_F1Beta_minus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #108 Compound 2(-) Min F1Gamma , miniTR                         |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd2_Min_F1Gamma_minus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].B;
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #109 Compound 2(-) Max F1Gamma , miniTR                         |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd2_Max_F1Gamma_minus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].B;
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #110 ABS Compound 2(-) Min F1Gamma miniTR                       |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd2_Min_F1Gamma_minus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #111 ABS Compound 2(-) Max F1Gamma , miniTR                     |
//--------------------------------------------------------------------  
double Abs_Cmpd2_Max_F1Gamma_minus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #112 Compound 2(-) Min BetaGamma , miniTR                       |
//--------------------------------------------------------------------  
double Cmpd2_Min_BetaGamma_minus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].B;
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #113 Compound 2(-) Max BetaGamma , miniTR                       |
//--------------------------------------------------------------------  
double Cmpd2_Max_BetaGamma_minus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].A;
   x2 = arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*arr_mtr[T_NUM].B;
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #114 ABS Compound 2(-) Min BetaGamma miniTR                     |
//--------------------------------------------------------------------  
double Abs_Cmpd2_Min_BetaGamma_minus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #115 ABS Compound 2(-) Max BetaGamma , miniTR                  |
//--------------------------------------------------------------------  
double Abs_Cmpd2_Max_BetaGamma_minus(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #116  Compound 3(*) Min FF1Beta , miniTR                       |
//--------------------------------------------------------------------  
double Cmpd3_Min_FF1Beta(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Beta*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Beta*(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #117  Compound 3(*) Max FF1Beta , miniTR                       |
//--------------------------------------------------------------------  
double Cmpd3_Max_FF1Beta(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Beta*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Beta*(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #118 ABS Compound 3(*) Min FF1Beta , miniTR                    |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Min_FF1Beta(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #119  ABS Compound 3(*) Max FF1Beta , miniTR                   |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Max_FF1Beta(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #120  Compound 3(*) Min FF1Gamma , miniTR                      |
//--------------------------------------------------------------------  
double Cmpd3_Min_FF1Gamma(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #121  Compound 3(*) Max FF1Gamma , miniTR                      |
//--------------------------------------------------------------------  
double Cmpd3_Max_FF1Gamma(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #122 ABS Compound 3(*) Min FF1Gamma , miniTR                   |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Min_FF1Gamma(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #123  ABS Compound 3(*) Max FF1Gamma , miniTR                  |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Max_FF1Gamma(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #124  Compound 3(*) Min FBetaGamma , miniTR                    |
//--------------------------------------------------------------------  
double Cmpd3_Min_FBetaGamma(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #125  Compound 3(*) Max FBetaGamma , miniTR                     |
//--------------------------------------------------------------------  
double Cmpd3_Max_FBetaGamma(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #126 ABS Compound 3(*) Min FBetaGamma , miniTR                 |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Min_FBetaGamma(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #127  ABS Compound 3(*) Max FBetaGamma , miniTR                |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Max_FBetaGamma(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #128  Compound 3(*) Min F1BetaGamma , miniTR                   |
//--------------------------------------------------------------------  
double Cmpd3_Min_F1BetaGamma(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #129  Compound 3(*) Max F1BetaGamma , miniTR                   |
//--------------------------------------------------------------------  
double Cmpd3_Max_F1BetaGamma(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #130 ABS Compound 3(*) Min F1BetaGamma , miniTR                |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Min_F1BetaGamma(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #131  ABS Compound 3(*) Max F1BetaGamma , miniTR               |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Max_F1BetaGamma(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #132  Compound 3(++) Min FF1Beta , miniTR                      |
//--------------------------------------------------------------------  
double Cmpd3_Min_FF1Beta_pp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta*(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #133  Compound 3(++) Max FF1Beta , miniTR                      |
//--------------------------------------------------------------------  
double Cmpd3_Max_FF1Beta_pp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta*(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #134 ABS Compound 3(++) Min FF1Beta , miniTR                   |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Min_FF1Beta_pp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #135  ABS Compound 3(++) Max FF1Beta , miniTR                  |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Max_FF1Beta_pp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #136  Compound 3(++) Min FF1Gamma , miniTR                     |
//--------------------------------------------------------------------  
double Cmpd3_Min_FF1Gamma_pp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #137  Compound 3(++) Max FF1Gamma , miniTR                     |
//--------------------------------------------------------------------  
double Cmpd3_Max_FF1Gamma_pp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #138 ABS Compound 3(++) Min FF1Gamma , miniTR                  |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Min_FF1Gamma_pp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #139  ABS Compound 3(++) Max FF1Gamma , miniTR                 |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Max_FF1Gamma_pp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #140  Compound 3(++) Min FBetaGamma , miniTR                   |
//--------------------------------------------------------------------  
double Cmpd3_Min_FBetaGamma_pp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #141  Compound 3(++) Max FBetaGamma , miniTR                   |
//--------------------------------------------------------------------  
double Cmpd3_Max_FBetaGamma_pp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #142 ABS Compound 3(++) Min FBetaGamma , miniTR                |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Min_FBetaGamma_pp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #143  ABS Compound 3(++) Max FBetaGamma , miniTR               |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Max_FBetaGamma_pp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #144  Compound 3(++) Min F1BetaGamma , miniTR                  |
//--------------------------------------------------------------------  
double Cmpd3_Min_F1BetaGamma_pp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #145  Compound 3(++) Max F1BetaGamma , miniTR                  |
//--------------------------------------------------------------------  
double Cmpd3_Max_F1BetaGamma_pp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #146 ABS Compound 3(++) Min F1BetaGamma , miniTR               |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Min_F1BetaGamma_pp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #147  ABS Compound 3(++) Max F1BetaGamma , miniTR              |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Max_F1BetaGamma_pp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #148  Compound 3(+-) Min FF1Beta , miniTR                      |
//--------------------------------------------------------------------  
double Cmpd3_Min_FF1Beta_pm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta*(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #149  Compound 3(+-) Max FF1Beta , miniTR                      |
//--------------------------------------------------------------------  
double Cmpd3_Max_FF1Beta_pm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta*(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #150 ABS Compound 3(+-) Min FF1Beta , miniTR                   |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Min_FF1Beta_pm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #151  ABS Compound 3(+-) Max FF1Beta , miniTR                  |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Max_FF1Beta_pm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #152  Compound 3(+-) Min FF1Gamma , miniTR                     |
//--------------------------------------------------------------------  
double Cmpd3_Min_FF1Gamma_pm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #153  Compound 3(+-) Max FF1Gamma , miniTR                     |
//--------------------------------------------------------------------  
double Cmpd3_Max_FF1Gamma_pm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #154 ABS Compound 3(+-) Min FF1Gamma , miniTR                  |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Min_FF1Gamma_pm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #155  ABS Compound 3(+-) Max FF1Gamma , miniTR                 |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Max_FF1Gamma_pm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #156  Compound 3(+-) Min FBetaGamma , miniTR                   |
//--------------------------------------------------------------------  
double Cmpd3_Min_FBetaGamma_pm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #157  Compound 3(+-) Max FBetaGamma , miniTR                   |
//--------------------------------------------------------------------  
double Cmpd3_Max_FBetaGamma_pm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #158 ABS Compound 3(+-) Min FBetaGamma , miniTR                |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Min_FBetaGamma_pm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #159  ABS Compound 3(+-) Max FBetaGamma , miniTR               |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Max_FBetaGamma_pm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #160  Compound 3(+-) Min F1BetaGamma , miniTR                  |
//--------------------------------------------------------------------  
double Cmpd3_Min_F1BetaGamma_pm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #161  Compound 3(+-) Max F1BetaGamma , miniTR                  |
//--------------------------------------------------------------------  
double Cmpd3_Max_F1BetaGamma_pm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #162 ABS Compound 3(+-) Min F1BetaGamma , miniTR               |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Min_F1BetaGamma_pm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #163  ABS Compound 3(+-) Max F1BetaGamma , miniTR              |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Max_F1BetaGamma_pm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #164  Compound 3(-+) Min FF1Beta , miniTR                      |
//--------------------------------------------------------------------  
double Cmpd3_Min_FF1Beta_mp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta*(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #165  Compound 3(-+) Max FF1Beta , miniTR                      |
//--------------------------------------------------------------------  
double Cmpd3_Max_FF1Beta_mp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta*(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #166 ABS Compound 3(-+) Min FF1Beta , miniTR                   |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Min_FF1Beta_mp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #167  ABS Compound 3(-+) Max FF1Beta , miniTR                  |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Max_FF1Beta_mp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #168  Compound 3(-+) Min FF1Gamma , miniTR                     |
//--------------------------------------------------------------------  
double Cmpd3_Min_FF1Gamma_mp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #169  Compound 3(-+) Max FF1Gamma , miniTR                     |
//--------------------------------------------------------------------  
double Cmpd3_Max_FF1Gamma_mp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #170 ABS Compound 3(-+) Min FF1Gamma , miniTR                  |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Min_FF1Gamma_mp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #171  ABS Compound 3(-+) Max FF1Gamma , miniTR                 |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Max_FF1Gamma_mp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #172  Compound 3(-+) Min FBetaGamma , miniTR                   |
//--------------------------------------------------------------------  
double Cmpd3_Min_FBetaGamma_mp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #173  Compound 3(-+) Max FBetaGamma , miniTR                   |
//--------------------------------------------------------------------  
double Cmpd3_Max_FBetaGamma_mp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #174 ABS Compound 3(-+) Min FBetaGamma , miniTR                |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Min_FBetaGamma_mp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #175  ABS Compound 3(-+) Max FBetaGamma , miniTR               |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Max_FBetaGamma_mp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #176  Compound 3(-+) Min F1BetaGamma , miniTR                  |
//--------------------------------------------------------------------  
double Cmpd3_Min_F1BetaGamma_mp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #177  Compound 3(-+) Max F1BetaGamma , miniTR                  |
//--------------------------------------------------------------------  
double Cmpd3_Max_F1BetaGamma_mp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #178 ABS Compound 3(-+) Min F1BetaGamma , miniTR               |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Min_F1BetaGamma_mp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #179  ABS Compound 3(-+) Max F1BetaGamma , miniTR              |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Max_F1BetaGamma_mp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #180  Compound 3(--) Min FF1Beta , miniTR                      |
//--------------------------------------------------------------------  
double Cmpd3_Min_FF1Beta_mm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta*(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #181  Compound 3(--) Max FF1Beta , miniTR                      |
//--------------------------------------------------------------------  
double Cmpd3_Max_FF1Beta_mm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta*(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #182 ABS Compound 3(--) Min FF1Beta , miniTR                   |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Min_FF1Beta_mm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #183  ABS Compound 3(--) Max FF1Beta , miniTR                  |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Max_FF1Beta_mm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #184  Compound 3(--) Min FF1Gamma , miniTR                     |
//--------------------------------------------------------------------  
double Cmpd3_Min_FF1Gamma_mm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #185  Compound 3(--) Max FF1Gamma , miniTR                     |
//--------------------------------------------------------------------  
double Cmpd3_Max_FF1Gamma_mm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #186 ABS Compound 3(--) Min FF1Gamma , miniTR                  |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Min_FF1Gamma_mm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #187  ABS Compound 3(--) Max FF1Gamma , miniTR                 |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Max_FF1Gamma_mm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #188  Compound 3(--) Min FBetaGamma , miniTR                   |
//--------------------------------------------------------------------  
double Cmpd3_Min_FBetaGamma_mm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #189  Compound 3(--) Max FBetaGamma , miniTR                   |
//--------------------------------------------------------------------  
double Cmpd3_Max_FBetaGamma_mm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #190 ABS Compound 3(--) Min FBetaGamma , miniTR                |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Min_FBetaGamma_mm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #191  ABS Compound 3(--) Max FBetaGamma , miniTR               |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Max_FBetaGamma_mm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #192  Compound 3(--) Min F1BetaGamma , miniTR                  |
//--------------------------------------------------------------------  
double Cmpd3_Min_F1BetaGamma_mm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #193  Compound 3(--) Max F1BetaGamma , miniTR                  |
//--------------------------------------------------------------------  
double Cmpd3_Max_F1BetaGamma_mm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #194 ABS Compound 3(--) Min F1BetaGamma , miniTR               |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Min_F1BetaGamma_mm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #195  ABS Compound 3(--) Max F1BetaGamma , miniTR              |
//--------------------------------------------------------------------  
double Abs_Cmpd3_Max_F1BetaGamma_mm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #196  Compound 4(*) Min FF1BetaGamma , miniTR                  |
//--------------------------------------------------------------------  
double Cmpd4_Min(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #197  Compound 4(*) Max FF1BetaGamma , miniTR                  |
//--------------------------------------------------------------------  
double Cmpd4_Max(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #198 ABS Compound 4(*) Min FF1BetaGamma , miniTR               |
//--------------------------------------------------------------------  
double Abs_Cmpd4_Min(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #199 ABS Compound 4(*) Max FF1BetaGamma , miniTR               |
//--------------------------------------------------------------------  
double Abs_Cmpd4_Max(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F*arr_mtr[T_NUM].F1*arr_mtr[T_NUM].Beta*arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #200  Compound 4(+++) Min FF1BetaGamma , miniTR                |
//--------------------------------------------------------------------  
double Cmpd4_Min_ppp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #201  Compound 4(+++) Max FF1BetaGamma , miniTR                |
//--------------------------------------------------------------------  
double Cmpd4_Max_ppp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #202 ABS Compound 4(+++) Min FF1BetaGamma , miniTR             |
//--------------------------------------------------------------------  
double Abs_Cmpd4_Min_ppp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #203 ABS Compound 4(+++) Max FF1BetaGamma , miniTR             |
//--------------------------------------------------------------------  
double Abs_Cmpd4_Max_ppp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #204  Compound 4(++-) Min FF1BetaGamma , miniTR                |
//--------------------------------------------------------------------  
double Cmpd4_Min_ppm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #205  Compound 4(++-) Max FF1BetaGamma , miniTR                |
//--------------------------------------------------------------------  
double Cmpd4_Max_ppm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #206 ABS Compound 4(++-) Min FF1BetaGamma , miniTR             |
//--------------------------------------------------------------------  
double Abs_Cmpd4_Min_ppm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #207 ABS Compound 4(++-) Max FF1BetaGamma , miniTR             |
//--------------------------------------------------------------------  
double Abs_Cmpd4_Max_ppm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #208  Compound 4(+-+) Min FF1BetaGamma , miniTR                |
//--------------------------------------------------------------------  
double Cmpd4_Min_pmp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #209  Compound 4(+-+) Max FF1BetaGamma , miniTR                |
//--------------------------------------------------------------------  
double Cmpd4_Max_pmp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #210 ABS Compound 4(+-+) Min FF1BetaGamma , miniTR             |
//--------------------------------------------------------------------  
double Abs_Cmpd4_Min_pmp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #211 ABS Compound 4(+-+) Max FF1BetaGamma , miniTR             |
//--------------------------------------------------------------------  
double Abs_Cmpd4_Max_pmp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #212  Compound 4(-++) Min FF1BetaGamma , miniTR                |
//--------------------------------------------------------------------  
double Cmpd4_Min_mpp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #213  Compound 4(-++) Max FF1BetaGamma , miniTR                |
//--------------------------------------------------------------------  
double Cmpd4_Max_mpp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #214 ABS Compound 4(-++) Min FF1BetaGamma , miniTR             |
//--------------------------------------------------------------------  
double Abs_Cmpd4_Min_mpp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #215 ABS Compound 4(-++) Max FF1BetaGamma , miniTR             |
//--------------------------------------------------------------------  
double Abs_Cmpd4_Max_mpp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #216  Compound 4(---) Min FF1BetaGamma , miniTR                |
//--------------------------------------------------------------------  
double Cmpd4_Min_mmm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #217  Compound 4(---) Max FF1BetaGamma , miniTR                |
//--------------------------------------------------------------------  
double Cmpd4_Max_mmm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #218 ABS Compound 4(---) Min FF1BetaGamma , miniTR             |
//--------------------------------------------------------------------  
double Abs_Cmpd4_Min_mmm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #219 ABS Compound 4(---) Max FF1BetaGamma , miniTR             |
//--------------------------------------------------------------------  
double Abs_Cmpd4_Max_mmm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #220  Compound 4(--+) Min FF1BetaGamma , miniTR                |
//--------------------------------------------------------------------  
double Cmpd4_Min_mmp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #221  Compound 4(--+) Max FF1BetaGamma , miniTR                |
//--------------------------------------------------------------------  
double Cmpd4_Max_mmp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #222 ABS Compound 4(--+) Min FF1BetaGamma , miniTR             |
//--------------------------------------------------------------------  
double Abs_Cmpd4_Min_mmp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #223 ABS Compound 4(--+) Max FF1BetaGamma , miniTR             |
//--------------------------------------------------------------------  
double Abs_Cmpd4_Max_mmp(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta+arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #224  Compound 4(-+-) Min FF1BetaGamma , miniTR                |
//--------------------------------------------------------------------  
double Cmpd4_Min_mpm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #225  Compound 4(-+-) Max FF1BetaGamma , miniTR                |
//--------------------------------------------------------------------  
double Cmpd4_Max_mpm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #226 ABS Compound 4(-+-) Min FF1BetaGamma , miniTR             |
//--------------------------------------------------------------------  
double Abs_Cmpd4_Min_mpm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #227 ABS Compound 4(-+-) Max FF1BetaGamma , miniTR             |
//--------------------------------------------------------------------  
double Abs_Cmpd4_Max_mpm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F-arr_mtr[T_NUM].F1+arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #228  Compound 4(+--) Min FF1BetaGamma , miniTR                |
//--------------------------------------------------------------------  
double Cmpd4_Min_pmm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #229  Compound 4(+--) Max FF1BetaGamma , miniTR                |
//--------------------------------------------------------------------  
double Cmpd4_Max_pmm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*(arr_mtr[T_NUM].B);
   m_result=MathMax(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #230 ABS Compound 4(+--) Min FF1BetaGamma , miniTR             |
//--------------------------------------------------------------------  
double Abs_Cmpd4_Min_pmm(const int &T_NUM)
  {
   x1=0; x2=0; m_result=0;

   x1 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].A);
   x2 = arr_mtr[T_NUM].F+arr_mtr[T_NUM].F1-arr_mtr[T_NUM].Beta-arr_mtr[T_NUM].Gamma*MathAbs(arr_mtr[T_NUM].B);
   m_result=MathMin(x1,x2);

//Sum NP by Group
   if(m_result==x1) return(arr_rNP1[T_NUM].NP1_RT);
   else return(arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
