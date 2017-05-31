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
            +DoubleToString(arr_minitr[i].BestNP,2)+
            "("+EnumToString((ENUM_miniTR_ID)arr_minitr[i].minitr)+") T( "
            +(string)arr_T_Count_in_GRP[i]+" )");

//How many NO TRADE GROUPS: (SLEEP MARKET)  
   Print("NO TRADES in PRIMINGS T Count: "+(string)arr_T_Count_in_GRP[NOTRADE]+" of "+(string)T_Count);

//Counter ZeroProfit & Unknown GRP
   int NonProfitGrpCount=0;
   int UnknownGrpCount=0;

//Print Groups Count Without miniTR (Zero or non profitable)+Unknown
   for(int i=0;i<GroupsCount;i++)
     {
      if(arr_minitr[i].BestNP==0) NonProfitGrpCount++;
      if(arr_GroupID[i]==Unknown) UnknownGrpCount++;
     }

   Print("Non Profit Groups count: "+(string)NonProfitGrpCount+" (of:"+(string)GroupsCount+" totally.)");
   Print("Unknown Groups count: "+IntegerToString(UnknownGrpCount));

   double TotalBestNP=0;

//Print Sum of All NPs
   for(ENUM_T_GROUP_ID i=NOTRADE;i<Unknown;i++)
      TotalBestNP+=arr_minitr[i].BestNP;

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
      case  Abs_Cmpd4_Max_pmm:return(Abs_Cmpd4_Max_pmm(t_num));break;                     //231
      case  VirtualLast:return(0);break;                                                  //Virtual 232                 
      default:return(0); break;                                // DEFAULT
     }
  }
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
         m_arr_SUM_NP_GROUP[mini][m_arr_GroupID[t]]+=Calc_miniTR(mini,t);
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
//MiniTRs Count
   int miniTRCount=GetSizeOf_miniTR_Enum();

   double MaximumNP=-9999999999999;

//Find Best miniTR in each Group  
   for(int j=0;j<GroupsCount;j++)
     {
      //Clear Maximum
      MaximumNP=0;

      for(int i=0;i<miniTRCount;i++)
        {
         if(arr_SUM_NP_GROUP[i][j]>MaximumNP)
           {
            //Save Maximum NP
            MaximumNP=arr_SUM_NP_GROUP[i][j];

            //Save miniTR Index & Best NP for this GroupID
            arr_minitr[j].minitr=i;
            arr_minitr[j].BestNP=MaximumNP;
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
   for(int i=0;i<GroupsCount;i++)
      FileWriteStruct(file_h1,arr_minitr[i]);

//Close File
   FileClose(file_h1);
  }
//+------------------------------------------------------------------+
