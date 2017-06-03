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

   //Current Group
   ENUM_T_GROUP_ID   m_current_GroupID;

   //miniTR Count
   int               m_minitr_count;

   //MinMax Only Search for Best miniTR
   bool              m_minmax_Only;

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

   //Sum of Positive T Count for every Group (23)
   uint              m_arr_SUM_PositiveCount[][23];

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

   //Total Positive T Count
   uint              m_TotalPositiveTCount;

   //Calculate miniTR(232) by Num                    
   double            m_Calc_miniTR(ENUM_miniTR_ID const &mini,const int &t_num);

   //Find Best miniTR by Maximum NP in Group
   void              m_FindBestMAX_miniTR();

   //Calculation miniTRs:::
   double            m_Min_AB(const int &T_NUM);                    //2 Simple double m_Min 
   double            m_Max_AB(const int &T_NUM);                    //3 Simple double m_Max 
   double            m_Abs_Min_AB(const int &T_NUM);
   double            m_Abs_Max_AB(const int &T_NUM);
   double            m_Min_fAB(const int &T_NUM);
   double            m_Max_fAB(const int &T_NUM);
   double            m_Abs_Min_fAB(const int &T_NUM);
   double            m_Abs_Max_fAB(const int &T_NUM);                //10
   double            m_Min_f1AB(const int &T_NUM);
   double            m_Max_f1AB(const int &T_NUM);
   double            m_Abs_Min_f1AB(const int &T_NUM);
   double            m_Abs_Max_f1AB(const int &T_NUM);
   double            m_Min_BetaAB(const int &T_NUM);
   double            m_Max_BetaAB(const int &T_NUM);
   double            m_Abs_Min_BetaAB(const int &T_NUM);
   double            m_Abs_Max_BetaAB(const int &T_NUM);
   double            m_Min_GammaAB(const int &T_NUM);
   double            m_Max_GammaAB(const int &T_NUM);
   double            m_Abs_Min_GammaAB(const int &T_NUM);
   double            m_Abs_Max_GammaAB(const int &T_NUM);
   //NotTrade  23 Not Trade
   double            m_Equal_dQ1Q4_C1(const int &T_NUM);
   double            m_Equal_dQ1Q4_C4(const int &T_NUM);
   double            m_Equal_dQ1Q4_C14(const int &T_NUM);                 //26
   double            m_Equal_dQ1Q4_MinAB(const int &T_NUM);
   double            m_Equal_dQ1Q4_MaxAB(const int &T_NUM);
   double            m_Zero_dQ1Q4_C1(const int &T_NUM);
   double            m_Zero_dQ1Q4_C4(const int &T_NUM);
   double            m_Zero_dQ1Q4_C14(const int &T_NUM);                  //31
   double            m_Zero_dQ1Q4_MinAB(const int &T_NUM);
   double            m_Zero_dQ1Q4_MaxAB(const int &T_NUM);
   double            m_Equal_AB_C1(const int &T_NUM);
   double            m_Equal_AB_C4(const int &T_NUM);
   double            m_Equal_AB_C14(const int &T_NUM);                    //36
   double            m_Equal_AB_MinAB(const int &T_NUM);
   double            m_Equal_AB_MaxAB(const int &T_NUM);
   double            m_Zero_AmB_C1(const int &T_NUM);                     //39 A*B==0 C1
   double            m_Zero_AmB_C4(const int &T_NUM);                     //40 A*B==0 C4
   double            m_Zero_AmB_C14(const int &T_NUM);                    //41 A*B==0 C14
   double            m_Zero_AmB_MinAB(const int &T_NUM);                  //42 A*B==0 double m_MinAB
   double            m_Zero_AmB_MaxAB(const int &T_NUM);                  //43 A*B==0 double m_MaxAB
   double            m_Cmpd2_Min_FF1(const int &T_NUM);
   double            m_Cmpd2_Max_FF1(const int &T_NUM);
   double            m_Abs_Cmpd2_Min_FF1(const int &T_NUM);
   double            m_Abs_Cmpd2_Max_FF1(const int &T_NUM);
   double            m_Cmpd2_Min_FBeta(const int &T_NUM);
   double            m_Cmpd2_Max_FBeta(const int &T_NUM);
   double            m_Abs_Cmpd2_Min_FBeta(const int &T_NUM);
   double            m_Abs_Cmpd2_Max_FBeta(const int &T_NUM);
   double            m_Cmpd2_Min_FGamma(const int &T_NUM);
   double            m_Cmpd2_Max_FGamma(const int &T_NUM);
   double            m_Abs_Cmpd2_Min_FGamma(const int &T_NUM);
   double            m_Abs_Cmpd2_Max_FGamma(const int &T_NUM);
   double            m_Cmpd2_Min_F1Beta(const int &T_NUM);
   double            m_Cmpd2_Max_F1Beta(const int &T_NUM);
   double            m_Abs_Cmpd2_Min_F1Beta(const int &T_NUM);
   double            m_Abs_Cmpd2_Max_F1Beta(const int &T_NUM);
   double            m_Cmpd2_Min_F1Gamma(const int &T_NUM);
   double            m_Cmpd2_Max_F1Gamma(const int &T_NUM);
   double            m_Abs_Cmpd2_Min_F1Gamma(const int &T_NUM);
   double            m_Abs_Cmpd2_Max_F1Gamma(const int &T_NUM);
   double            m_Cmpd2_Min_BetaGamma(const int &T_NUM);
   double            m_Cmpd2_Max_BetaGamma(const int &T_NUM);
   double            m_Abs_Cmpd2_Min_BetaGamma(const int &T_NUM);
   double            m_Abs_Cmpd2_Max_BetaGamma(const int &T_NUM);// 67 Last compound 2 (*)
   double            m_Cmpd2_Min_FF1_plus(const int &T_NUM);
   double            m_Cmpd2_Max_FF1_plus(const int &T_NUM);
   double            m_Abs_Cmpd2_Min_FF1_plus(const int &T_NUM);
   double            m_Abs_Cmpd2_Max_FF1_plus(const int &T_NUM);
   double            m_Cmpd2_Min_FBeta_plus(const int &T_NUM);
   double            m_Cmpd2_Max_FBeta_plus(const int &T_NUM);
   double            m_Abs_Cmpd2_Min_FBeta_plus(const int &T_NUM);
   double            m_Abs_Cmpd2_Max_FBeta_plus(const int &T_NUM);
   double            m_Cmpd2_Min_FGamma_plus(const int &T_NUM);
   double            m_Cmpd2_Max_FGamma_plus(const int &T_NUM);
   double            m_Abs_Cmpd2_Min_FGamma_plus(const int &T_NUM);
   double            m_Abs_Cmpd2_Max_FGamma_plus(const int &T_NUM);
   double            m_Cmpd2_Min_F1Beta_plus(const int &T_NUM);
   double            m_Cmpd2_Max_F1Beta_plus(const int &T_NUM);
   double            m_Abs_Cmpd2_Min_F1Beta_plus(const int &T_NUM);
   double            m_Abs_Cmpd2_Max_F1Beta_plus(const int &T_NUM);
   double            m_Cmpd2_Min_F1Gamma_plus(const int &T_NUM);
   double            m_Cmpd2_Max_F1Gamma_plus(const int &T_NUM);
   double            m_Abs_Cmpd2_Min_F1Gamma_plus(const int &T_NUM);
   double            m_Abs_Cmpd2_Max_F1Gamma_plus(const int &T_NUM);
   double            m_Cmpd2_Min_BetaGamma_plus(const int &T_NUM);
   double            m_Cmpd2_Max_BetaGamma_plus(const int &T_NUM);
   double            m_Abs_Cmpd2_Min_BetaGamma_plus(const int &T_NUM);
   double            m_Abs_Cmpd2_Max_BetaGamma_plus(const int &T_NUM);// 91 Last Compound 2 (+)
   double            m_Cmpd2_Min_FF1_minus(const int &T_NUM);
   double            m_Cmpd2_Max_FF1_minus(const int &T_NUM);
   double            m_Abs_Cmpd2_Min_FF1_minus(const int &T_NUM);
   double            m_Abs_Cmpd2_Max_FF1_minus(const int &T_NUM);
   double            m_Cmpd2_Min_FBeta_minus(const int &T_NUM);
   double            m_Cmpd2_Max_FBeta_minus(const int &T_NUM);
   double            m_Abs_Cmpd2_Min_FBeta_minus(const int &T_NUM);
   double            m_Abs_Cmpd2_Max_FBeta_minus(const int &T_NUM);
   double            m_Cmpd2_Min_FGamma_minus(const int &T_NUM);
   double            m_Cmpd2_Max_FGamma_minus(const int &T_NUM);
   double            m_Abs_Cmpd2_Min_FGamma_minus(const int &T_NUM);
   double            m_Abs_Cmpd2_Max_FGamma_minus(const int &T_NUM);
   double            m_Cmpd2_Min_F1Beta_minus(const int &T_NUM);
   double            m_Cmpd2_Max_F1Beta_minus(const int &T_NUM);
   double            m_Abs_Cmpd2_Min_F1Beta_minus(const int &T_NUM);
   double            m_Abs_Cmpd2_Max_F1Beta_minus(const int &T_NUM);
   double            m_Cmpd2_Min_F1Gamma_minus(const int &T_NUM);
   double            m_Cmpd2_Max_F1Gamma_minus(const int &T_NUM);
   double            m_Abs_Cmpd2_Min_F1Gamma_minus(const int &T_NUM);
   double            m_Abs_Cmpd2_Max_F1Gamma_minus(const int &T_NUM);
   double            m_Cmpd2_Min_BetaGamma_minus(const int &T_NUM);
   double            m_Cmpd2_Max_BetaGamma_minus(const int &T_NUM);
   double            m_Abs_Cmpd2_Min_BetaGamma_minus(const int &T_NUM);
   double            m_Abs_Cmpd2_Max_BetaGamma_minus(const int &T_NUM);// 115 Last Compound 2 (-)
   double            m_Cmpd3_Min_FF1Beta(const int &T_NUM);
   double            m_Cmpd3_Max_FF1Beta(const int &T_NUM);
   double            m_Abs_Cmpd3_Min_FF1Beta(const int &T_NUM);
   double            m_Abs_Cmpd3_Max_FF1Beta(const int &T_NUM);
   double            m_Cmpd3_Min_FF1Gamma(const int &T_NUM);
   double            m_Cmpd3_Max_FF1Gamma(const int &T_NUM);
   double            m_Abs_Cmpd3_Min_FF1Gamma(const int &T_NUM);
   double            m_Abs_Cmpd3_Max_FF1Gamma(const int &T_NUM);
   double            m_Cmpd3_Min_FBetaGamma(const int &T_NUM);
   double            m_Cmpd3_Max_FBetaGamma(const int &T_NUM);
   double            m_Abs_Cmpd3_Min_FBetaGamma(const int &T_NUM);
   double            m_Abs_Cmpd3_Max_FBetaGamma(const int &T_NUM);
   double            m_Cmpd3_Min_F1BetaGamma(const int &T_NUM);
   double            m_Cmpd3_Max_F1BetaGamma(const int &T_NUM);
   double            m_Abs_Cmpd3_Min_F1BetaGamma(const int &T_NUM);
   double            m_Abs_Cmpd3_Max_F1BetaGamma(const int &T_NUM);//131 last Compound 3 (*)
   double            m_Cmpd3_Min_FF1Beta_pp(const int &T_NUM);
   double            m_Cmpd3_Max_FF1Beta_pp(const int &T_NUM);
   double            m_Abs_Cmpd3_Min_FF1Beta_pp(const int &T_NUM);
   double            m_Abs_Cmpd3_Max_FF1Beta_pp(const int &T_NUM);
   double            m_Cmpd3_Min_FF1Gamma_pp(const int &T_NUM);
   double            m_Cmpd3_Max_FF1Gamma_pp(const int &T_NUM);
   double            m_Abs_Cmpd3_Min_FF1Gamma_pp(const int &T_NUM);
   double            m_Abs_Cmpd3_Max_FF1Gamma_pp(const int &T_NUM);
   double            m_Cmpd3_Min_FBetaGamma_pp(const int &T_NUM);
   double            m_Cmpd3_Max_FBetaGamma_pp(const int &T_NUM);
   double            m_Abs_Cmpd3_Min_FBetaGamma_pp(const int &T_NUM);
   double            m_Abs_Cmpd3_Max_FBetaGamma_pp(const int &T_NUM);
   double            m_Cmpd3_Min_F1BetaGamma_pp(const int &T_NUM);
   double            m_Cmpd3_Max_F1BetaGamma_pp(const int &T_NUM);
   double            m_Abs_Cmpd3_Min_F1BetaGamma_pp(const int &T_NUM);
   double            m_Abs_Cmpd3_Max_F1BetaGamma_pp(const int &T_NUM);//147 last Compound 3 (++)
   double            m_Cmpd3_Min_FF1Beta_pm(const int &T_NUM);
   double            m_Cmpd3_Max_FF1Beta_pm(const int &T_NUM);
   double            m_Abs_Cmpd3_Min_FF1Beta_pm(const int &T_NUM);
   double            m_Abs_Cmpd3_Max_FF1Beta_pm(const int &T_NUM);
   double            m_Cmpd3_Min_FF1Gamma_pm(const int &T_NUM);
   double            m_Cmpd3_Max_FF1Gamma_pm(const int &T_NUM);
   double            m_Abs_Cmpd3_Min_FF1Gamma_pm(const int &T_NUM);
   double            m_Abs_Cmpd3_Max_FF1Gamma_pm(const int &T_NUM);
   double            m_Cmpd3_Min_FBetaGamma_pm(const int &T_NUM);
   double            m_Cmpd3_Max_FBetaGamma_pm(const int &T_NUM);
   double            m_Abs_Cmpd3_Min_FBetaGamma_pm(const int &T_NUM);
   double            m_Abs_Cmpd3_Max_FBetaGamma_pm(const int &T_NUM);
   double            m_Cmpd3_Min_F1BetaGamma_pm(const int &T_NUM);
   double            m_Cmpd3_Max_F1BetaGamma_pm(const int &T_NUM);
   double            m_Abs_Cmpd3_Min_F1BetaGamma_pm(const int &T_NUM);
   double            m_Abs_Cmpd3_Max_F1BetaGamma_pm(const int &T_NUM);//163 last Compound 3 (+-)
   double            m_Cmpd3_Min_FF1Beta_mp(const int &T_NUM);
   double            m_Cmpd3_Max_FF1Beta_mp(const int &T_NUM);
   double            m_Abs_Cmpd3_Min_FF1Beta_mp(const int &T_NUM);
   double            m_Abs_Cmpd3_Max_FF1Beta_mp(const int &T_NUM);
   double            m_Cmpd3_Min_FF1Gamma_mp(const int &T_NUM);
   double            m_Cmpd3_Max_FF1Gamma_mp(const int &T_NUM);
   double            m_Abs_Cmpd3_Min_FF1Gamma_mp(const int &T_NUM);
   double            m_Abs_Cmpd3_Max_FF1Gamma_mp(const int &T_NUM);
   double            m_Cmpd3_Min_FBetaGamma_mp(const int &T_NUM);
   double            m_Cmpd3_Max_FBetaGamma_mp(const int &T_NUM);
   double            m_Abs_Cmpd3_Min_FBetaGamma_mp(const int &T_NUM);
   double            m_Abs_Cmpd3_Max_FBetaGamma_mp(const int &T_NUM);
   double            m_Cmpd3_Min_F1BetaGamma_mp(const int &T_NUM);
   double            m_Cmpd3_Max_F1BetaGamma_mp(const int &T_NUM);
   double            m_Abs_Cmpd3_Min_F1BetaGamma_mp(const int &T_NUM);
   double            m_Abs_Cmpd3_Max_F1BetaGamma_mp(const int &T_NUM);//179 last Compound 3 (-+)
   double            m_Cmpd3_Min_FF1Beta_mm(const int &T_NUM);
   double            m_Cmpd3_Max_FF1Beta_mm(const int &T_NUM);
   double            m_Abs_Cmpd3_Min_FF1Beta_mm(const int &T_NUM);
   double            m_Abs_Cmpd3_Max_FF1Beta_mm(const int &T_NUM);
   double            m_Cmpd3_Min_FF1Gamma_mm(const int &T_NUM);
   double            m_Cmpd3_Max_FF1Gamma_mm(const int &T_NUM);
   double            m_Abs_Cmpd3_Min_FF1Gamma_mm(const int &T_NUM);
   double            m_Abs_Cmpd3_Max_FF1Gamma_mm(const int &T_NUM);
   double            m_Cmpd3_Min_FBetaGamma_mm(const int &T_NUM);
   double            m_Cmpd3_Max_FBetaGamma_mm(const int &T_NUM);
   double            m_Abs_Cmpd3_Min_FBetaGamma_mm(const int &T_NUM);
   double            m_Abs_Cmpd3_Max_FBetaGamma_mm(const int &T_NUM);
   double            m_Cmpd3_Min_F1BetaGamma_mm(const int &T_NUM);
   double            m_Cmpd3_Max_F1BetaGamma_mm(const int &T_NUM);
   double            m_Abs_Cmpd3_Min_F1BetaGamma_mm(const int &T_NUM);
   double            m_Abs_Cmpd3_Max_F1BetaGamma_mm(const int &T_NUM);//195 last Compound 3 (--)
   double            m_Cmpd4_Min(const int &T_NUM);
   double            m_Cmpd4_Max(const int &T_NUM);
   double            m_Abs_Cmpd4_Min(const int &T_NUM);
   double            m_Abs_Cmpd4_Max(const int &T_NUM);// Last Compound 4(*)
   double            m_Cmpd4_Min_ppp(const int &T_NUM);
   double            m_Cmpd4_Max_ppp(const int &T_NUM);
   double            m_Abs_Cmpd4_Min_ppp(const int &T_NUM);
   double            m_Abs_Cmpd4_Max_ppp(const int &T_NUM);// 203 Last Compound 4(+++)
   double            m_Cmpd4_Min_ppm(const int &T_NUM);
   double            m_Cmpd4_Max_ppm(const int &T_NUM);
   double            m_Abs_Cmpd4_Min_ppm(const int &T_NUM);
   double            m_Abs_Cmpd4_Max_ppm(const int &T_NUM);// Last Compound 4(++-)
   double            m_Cmpd4_Min_pmp(const int &T_NUM);
   double            m_Cmpd4_Max_pmp(const int &T_NUM);
   double            m_Abs_Cmpd4_Min_pmp(const int &T_NUM);
   double            m_Abs_Cmpd4_Max_pmp(const int &T_NUM);// 211 Last Compound 4 (+-+)
   double            m_Cmpd4_Min_mpp(const int &T_NUM);
   double            m_Cmpd4_Max_mpp(const int &T_NUM);
   double            m_Abs_Cmpd4_Min_mpp(const int &T_NUM);
   double            m_Abs_Cmpd4_Max_mpp(const int &T_NUM);// Last Compound 4 (-++)
   double            m_Cmpd4_Min_mmm(const int &T_NUM);
   double            m_Cmpd4_Max_mmm(const int &T_NUM);
   double            m_Abs_Cmpd4_Min_mmm(const int &T_NUM);
   double            m_Abs_Cmpd4_Max_mmm(const int &T_NUM);// 219 Last Compound 4 (---)
   double            m_Cmpd4_Min_mmp(const int &T_NUM);
   double            m_Cmpd4_Max_mmp(const int &T_NUM);
   double            m_Abs_Cmpd4_Min_mmp(const int &T_NUM);
   double            m_Abs_Cmpd4_Max_mmp(const int &T_NUM);// Last Compound 4 (--+)
   double            m_Cmpd4_Min_mpm(const int &T_NUM);
   double            m_Cmpd4_Max_mpm(const int &T_NUM);
   double            m_Abs_Cmpd4_Min_mpm(const int &T_NUM);
   double            m_Abs_Cmpd4_Max_mpm(const int &T_NUM);// 227 Last Compound 4 (-+-)
   double            m_Cmpd4_Min_pmm(const int &T_NUM);
   double            m_Cmpd4_Max_pmm(const int &T_NUM);
   double            m_Abs_Cmpd4_Min_pmm(const int &T_NUM);
   double            m_Abs_Cmpd4_Max_pmm(const int &T_NUM);// Last Compound 4 (+--)
                                                           //VirtualLast 232 N don`t usebale
public:
                     miniTR(void);
                    ~miniTR(void);
   //Init
   bool              Init(const bool &MinMaxOnly);

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

   //Check Current GroupID
   ENUM_T_GROUP_ID   CurrentCheckGroupID(STRUCT_miniTR const &mtr);

   //Calculate Ck signal for current Group
   ENUM_CK_SIGNALS   CalculateCk(STRUCT_miniTR const &mtr,ENUM_miniTR_ID const &miniTRID);

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
   m_current_GroupID=0;
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
bool miniTR::Init(const bool &MinMaxOnly)
  {
   m_groups_count=m_GroupsCount();
   m_minitr_count=m_MiniTrCount();

//Prepare PositiveCounter
   m_TotalPositiveTCount=m_GroupsCount()*m_MiniTrCount();

   m_minmax_Only=MinMaxOnly;
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
            +DoubleToString(m_arr_minitr[i].Max_Balance,2)+
            "("+EnumToString((ENUM_miniTR_ID)m_arr_minitr[i].MiniTR_ID_MaxBalance)+") T( "
            +(string)m_arr_T_Count_in_GRP[i]+" )");

//How many NO TRADE GROUPS: (SLEEP MARKET)  
   Print("NO TRADES in PRIMINGS T Count: "+(string)m_arr_T_Count_in_GRP[NOTRADE]+" of "+(string)m_T_Count);

//Counter ZeroProfit & Unknown GRP
   int NonProfitGrpCount=0;
   int UnknownGrpCount=0;

//Print Groups Count Without miniTR (Zero or non profitable)+Unknown
   for(int i=0;i<m_groups_count;i++)
     {
      if(m_arr_minitr[i].Max_Balance==0) NonProfitGrpCount++;
      if(m_arr_GroupID[i]==Unknown) UnknownGrpCount++;
     }

   Print("Non Profit Groups count: "+(string)NonProfitGrpCount+" (of:"+(string)m_groups_count+" totally.)");
   Print("Unknown Groups count: "+IntegerToString(UnknownGrpCount));

   double TotalBestNP=0;

//Print Sum of All NPs
   for(ENUM_T_GROUP_ID i=NOTRADE;i<Unknown;i++)
      TotalBestNP+=m_arr_minitr[i].Max_Balance;

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
//NO TRADE (dimenish balance by 0.1 cent)
   const double  NoTrade_Dimenish=-0.001;

//Check if MinMax Only
   if(m_minmax_Only)
     {
      if(mini==Min_AB) return(m_Min_AB(t_num));
      if(mini==Max_AB) return(m_Max_AB(t_num));
     }

   switch(mini)
     {
      case  C1:return(NoTrade_Dimenish);break;//arr_rNP1[t_num].NP1_RT); break;
      case  C4:return(NoTrade_Dimenish);break;//(arr_rNP4[t_num].NP4_RT); break;
      case  Min_AB:return(m_Min_AB(t_num)); break;
      case  Max_AB:return(m_Max_AB(t_num)); break;
      case  C14:return(NoTrade_Dimenish); break;                              // we have not NP14_RT!!!!
      case  Abs_Min_AB:return(m_Abs_Min_AB(t_num)); break;
      case  Abs_Max_AB:return(m_Abs_Max_AB(t_num)); break;                   //6
      case  Min_fAB:return(m_Min_fAB(t_num)); break;
      case  Max_fAB:return(m_Max_fAB(t_num)); break;
      case  Abs_Min_fAB:return(m_Abs_Min_fAB(t_num)); break;
      case  Abs_Max_fAB:return(m_Abs_Max_fAB(t_num)); break;
      case  Min_f1AB:return(m_Min_f1AB(t_num)); break;
      case  Max_f1AB:return(m_Max_f1AB(t_num)); break;
      case  Abs_Min_f1AB:return(m_Abs_Min_f1AB(t_num)); break;
      case  Abs_Max_f1AB:return(m_Abs_Max_f1AB(t_num)); break;
      case  Min_BetaAB:return(m_Min_BetaAB(t_num)); break;
      case  Max_BetaAB:return(m_Max_BetaAB(t_num)); break;
      case  Abs_Min_BetaAB:return(m_Abs_Min_BetaAB(t_num)); break;
      case  Abs_Max_BetaAB:return(m_Abs_Max_BetaAB(t_num)); break;
      case  Min_GammaAB:return(m_Min_GammaAB(t_num)); break;
      case  Max_GammaAB:return(m_Max_GammaAB(t_num)); break;
      case  Abs_Min_GammaAB:return(m_Abs_Min_GammaAB(t_num)); break;
      case  Abs_Max_GammaAB:return(m_Abs_Max_GammaAB(t_num)); break;
      case  NotTrade:return(NoTrade_Dimenish);break;                                      //23
      case  Equal_dQ1Q4_C1:return(m_Equal_dQ1Q4_C1(t_num));break;
      case  Equal_dQ1Q4_C4:return(m_Equal_dQ1Q4_C4(t_num));break;
      case  Equal_dQ1Q4_C14:return(NoTrade_Dimenish); break;
      case  Equal_dQ1Q4_MinAB:return(m_Equal_dQ1Q4_MinAB(t_num));break;
      case  Equal_dQ1Q4_MaxAB:return(m_Equal_dQ1Q4_MaxAB(t_num));break;
      case  Zero_dQ1Q4_C1:return(m_Zero_dQ1Q4_C1(t_num));break;
      case  Zero_dQ1Q4_C4:return(m_Zero_dQ1Q4_C4(t_num));break;
      case  Zero_dQ1Q4_C14:return(NoTrade_Dimenish);
      case  Zero_dQ1Q4_MinAB:return(m_Zero_dQ1Q4_MinAB(t_num)); break;
      case  Zero_dQ1Q4_MaxAB:return(m_Zero_dQ1Q4_MaxAB(t_num)); break;
      case  Equal_AB_C1:return(m_Equal_AB_C1(t_num)); break;
      case  Equal_AB_C4:return(m_Equal_AB_C4(t_num)); break;
      case  Equal_AB_C14:return(NoTrade_Dimenish); break;
      case  Equal_AB_MinAB:return(m_Equal_AB_MinAB(t_num)); break;
      case  Equal_AB_MaxAB:return(m_Equal_AB_MaxAB(t_num)); break;
      case  Zero_AmB_C1:return(m_Zero_AmB_C1(t_num)); break;
      case  Zero_AmB_C4:return(m_Zero_AmB_C4(t_num)); break;
      case  Zero_AmB_C14:return(NoTrade_Dimenish);break;
      case  Zero_AmB_MinAB:return(m_Zero_AmB_MinAB(t_num)); break;
      case  Zero_AmB_MaxAB:return(m_Zero_AmB_MaxAB(t_num)); break;           //43
      case  Cmpd2_Min_FF1:return(m_Cmpd2_Min_FF1(t_num)); break;
      case  Cmpd2_Max_FF1:return(m_Cmpd2_Max_FF1(t_num)); break;
      case  Abs_Cmpd2_Min_FF1:return(m_Abs_Cmpd2_Min_FF1(t_num)); break;
      case  Abs_Cmpd2_Max_FF1:return(m_Abs_Cmpd2_Max_FF1(t_num)); break;
      case  Cmpd2_Min_FBeta:return(m_Cmpd2_Min_FBeta(t_num)); break;
      case  Cmpd2_Max_FBeta:return(m_Cmpd2_Max_FBeta(t_num)); break;
      case  Abs_Cmpd2_Min_FBeta:return(m_Abs_Cmpd2_Min_FBeta(t_num)); break;
      case  Abs_Cmpd2_Max_FBeta:return(m_Abs_Cmpd2_Max_FBeta(t_num)); break;
      case  Cmpd2_Min_FGamma:return(m_Cmpd2_Min_FGamma(t_num)); break;
      case  Cmpd2_Max_FGamma:return(m_Cmpd2_Max_FGamma(t_num)); break;
      case  Abs_Cmpd2_Min_FGamma:return(m_Abs_Cmpd2_Min_FGamma(t_num)); break;
      case  Abs_Cmpd2_Max_FGamma:return(m_Abs_Cmpd2_Max_FGamma(t_num)); break;
      case  Cmpd2_Min_F1Beta:return(m_Cmpd2_Min_F1Beta(t_num)); break;
      case  Cmpd2_Max_F1Beta:return(m_Cmpd2_Max_F1Beta(t_num)); break;
      case  Abs_Cmpd2_Min_F1Beta:return(m_Abs_Cmpd2_Min_F1Beta(t_num)); break;
      case  Abs_Cmpd2_Max_F1Beta:return(m_Abs_Cmpd2_Max_F1Beta(t_num)); break;
      case  Cmpd2_Min_F1Gamma:return(m_Cmpd2_Min_F1Gamma(t_num)); break;
      case  Cmpd2_Max_F1Gamma:return(m_Cmpd2_Max_F1Gamma(t_num)); break;
      case  Abs_Cmpd2_Min_F1Gamma:return(m_Abs_Cmpd2_Min_F1Gamma(t_num)); break;
      case  Abs_Cmpd2_Max_F1Gamma:return(m_Abs_Cmpd2_Max_F1Gamma(t_num)); break;
      case  Cmpd2_Min_BetaGamma:return(m_Cmpd2_Min_BetaGamma(t_num)); break;
      case  Cmpd2_Max_BetaGamma:return(m_Cmpd2_Max_BetaGamma(t_num)); break;
      case  Abs_Cmpd2_Min_BetaGamma:return(m_Abs_Cmpd2_Min_BetaGamma(t_num)); break;
      case  Abs_Cmpd2_Max_BetaGamma:return(m_Abs_Cmpd2_Max_BetaGamma(t_num)); break;  //67
      case  Cmpd2_Min_FF1_plus:return(m_Cmpd2_Min_FF1_plus(t_num)); break;
      case  Cmpd2_Max_FF1_plus:return(m_Cmpd2_Max_FF1_plus(t_num)); break;
      case  Abs_Cmpd2_Min_FF1_plus:return(m_Abs_Cmpd2_Min_FF1_plus(t_num)); break;
      case  Abs_Cmpd2_Max_FF1_plus:return(m_Abs_Cmpd2_Max_FF1_plus(t_num)); break;
      case  Cmpd2_Min_FBeta_plus:return(m_Cmpd2_Min_FBeta_plus(t_num)); break;
      case  Cmpd2_Max_FBeta_plus:return(m_Cmpd2_Max_FBeta_plus(t_num)); break;
      case  Abs_Cmpd2_Min_FBeta_plus:return(m_Abs_Cmpd2_Min_FBeta_plus(t_num)); break;
      case  Abs_Cmpd2_Max_FBeta_plus:return(m_Abs_Cmpd2_Max_FBeta_plus(t_num)); break;
      case  Cmpd2_Min_FGamma_plus:return(m_Cmpd2_Min_FGamma_plus(t_num)); break;
      case  Cmpd2_Max_FGamma_plus:return(m_Cmpd2_Max_FGamma_plus(t_num)); break;
      case  Abs_Cmpd2_Min_FGamma_plus:return(m_Abs_Cmpd2_Min_FGamma_plus(t_num)); break;
      case  Abs_Cmpd2_Max_FGamma_plus:return(m_Abs_Cmpd2_Max_FGamma_plus(t_num)); break;
      case  Cmpd2_Min_F1Beta_plus:return(m_Cmpd2_Min_F1Beta_plus(t_num)); break;
      case  Cmpd2_Max_F1Beta_plus:return(m_Cmpd2_Max_F1Beta_plus(t_num)); break;
      case  Abs_Cmpd2_Min_F1Beta_plus:return(m_Abs_Cmpd2_Min_F1Beta_plus(t_num)); break;
      case  Abs_Cmpd2_Max_F1Beta_plus:return(m_Abs_Cmpd2_Max_F1Beta_plus(t_num)); break;
      case  Cmpd2_Min_F1Gamma_plus:return(m_Cmpd2_Min_F1Gamma_plus(t_num)); break;
      case  Cmpd2_Max_F1Gamma_plus:return(m_Cmpd2_Max_F1Gamma_plus(t_num)); break;
      case  Abs_Cmpd2_Min_F1Gamma_plus:return(m_Abs_Cmpd2_Min_F1Gamma_plus(t_num)); break;
      case  Abs_Cmpd2_Max_F1Gamma_plus:return(m_Abs_Cmpd2_Max_F1Gamma_plus(t_num)); break;
      case  Cmpd2_Min_BetaGamma_plus:return(m_Cmpd2_Min_BetaGamma_plus(t_num)); break;
      case  Cmpd2_Max_BetaGamma_plus:return(m_Cmpd2_Max_BetaGamma_plus(t_num)); break;
      case  Abs_Cmpd2_Min_BetaGamma_plus:return(m_Abs_Cmpd2_Min_BetaGamma_plus(t_num)); break;
      case  Abs_Cmpd2_Max_BetaGamma_plus:return(m_Abs_Cmpd2_Max_BetaGamma_plus(t_num)); break;  //91
      case  Cmpd2_Min_FF1_minus:return(m_Cmpd2_Min_FF1_minus(t_num)); break;
      case  Cmpd2_Max_FF1_minus:return(m_Cmpd2_Max_FF1_minus(t_num)); break;
      case  Abs_Cmpd2_Min_FF1_minus:return(m_Abs_Cmpd2_Min_FF1_minus(t_num)); break;
      case  Abs_Cmpd2_Max_FF1_minus:return(m_Abs_Cmpd2_Max_FF1_minus(t_num)); break;
      case  Cmpd2_Min_FBeta_minus:return(m_Cmpd2_Min_FBeta_minus(t_num)); break;
      case  Cmpd2_Max_FBeta_minus:return(m_Cmpd2_Max_FBeta_minus(t_num)); break;
      case  Abs_Cmpd2_Min_FBeta_minus:return(m_Abs_Cmpd2_Min_FBeta_minus(t_num)); break;
      case  Abs_Cmpd2_Max_FBeta_minus:return(m_Abs_Cmpd2_Max_FBeta_minus(t_num)); break;
      case  Cmpd2_Min_FGamma_minus:return(m_Cmpd2_Min_FGamma_minus(t_num)); break;
      case  Cmpd2_Max_FGamma_minus:return(m_Cmpd2_Max_FGamma_minus(t_num)); break;
      case  Abs_Cmpd2_Min_FGamma_minus:return(m_Abs_Cmpd2_Min_FGamma_minus(t_num)); break;
      case  Abs_Cmpd2_Max_FGamma_minus:return(m_Abs_Cmpd2_Max_FGamma_minus(t_num)); break;
      case  Cmpd2_Min_F1Beta_minus:return(m_Cmpd2_Min_F1Beta_minus(t_num)); break;
      case  Cmpd2_Max_F1Beta_minus:return(m_Cmpd2_Max_F1Beta_minus(t_num)); break;
      case  Abs_Cmpd2_Min_F1Beta_minus:return(m_Abs_Cmpd2_Min_F1Beta_minus(t_num)); break;
      case  Abs_Cmpd2_Max_F1Beta_minus:return(m_Abs_Cmpd2_Max_F1Beta_minus(t_num)); break;
      case  Cmpd2_Min_F1Gamma_minus:return(m_Cmpd2_Min_F1Gamma_minus(t_num)); break;
      case  Cmpd2_Max_F1Gamma_minus:return(m_Cmpd2_Max_F1Gamma_minus(t_num)); break;
      case  Abs_Cmpd2_Min_F1Gamma_minus:return(m_Abs_Cmpd2_Min_F1Gamma_minus(t_num)); break;
      case  Abs_Cmpd2_Max_F1Gamma_minus:return(m_Abs_Cmpd2_Max_F1Gamma_minus(t_num)); break;
      case  Cmpd2_Min_BetaGamma_minus:return(m_Cmpd2_Min_BetaGamma_minus(t_num)); break;
      case  Cmpd2_Max_BetaGamma_minus:return(m_Cmpd2_Max_BetaGamma_minus(t_num)); break;
      case  Abs_Cmpd2_Min_BetaGamma_minus:return(m_Abs_Cmpd2_Min_BetaGamma_minus(t_num)); break;
      case  Abs_Cmpd2_Max_BetaGamma_minus:return(m_Abs_Cmpd2_Max_BetaGamma_minus(t_num)); break;  //115
      case  Cmpd3_Min_FF1Beta:return(m_Cmpd3_Min_FF1Beta(t_num)); break;
      case  Cmpd3_Max_FF1Beta:return(m_Cmpd3_Max_FF1Beta(t_num)); break;
      case  Abs_Cmpd3_Min_FF1Beta:return(m_Abs_Cmpd3_Min_FF1Beta(t_num)); break;
      case  Abs_Cmpd3_Max_FF1Beta:return(m_Abs_Cmpd3_Max_FF1Beta(t_num)); break;
      case  Cmpd3_Min_FF1Gamma:return(m_Cmpd3_Min_FF1Gamma(t_num)); break;
      case  Cmpd3_Max_FF1Gamma:return(m_Cmpd3_Max_FF1Gamma(t_num)); break;
      case  Abs_Cmpd3_Min_FF1Gamma:return(m_Abs_Cmpd3_Min_FF1Gamma(t_num)); break;
      case  Abs_Cmpd3_Max_FF1Gamma:return(m_Abs_Cmpd3_Max_FF1Gamma(t_num)); break;
      case  Cmpd3_Min_FBetaGamma:return(m_Cmpd3_Min_FBetaGamma(t_num)); break;
      case  Cmpd3_Max_FBetaGamma:return(m_Cmpd3_Max_FBetaGamma(t_num)); break;
      case  Abs_Cmpd3_Min_FBetaGamma:return(m_Abs_Cmpd3_Min_FBetaGamma(t_num)); break;
      case  Abs_Cmpd3_Max_FBetaGamma:return(m_Abs_Cmpd3_Max_FBetaGamma(t_num)); break;
      case  Cmpd3_Min_F1BetaGamma:return(m_Cmpd3_Min_F1BetaGamma(t_num)); break;
      case  Cmpd3_Max_F1BetaGamma:return(m_Cmpd3_Max_F1BetaGamma(t_num)); break;
      case  Abs_Cmpd3_Min_F1BetaGamma:return(m_Abs_Cmpd3_Min_F1BetaGamma(t_num)); break;
      case  Abs_Cmpd3_Max_F1BetaGamma:return(m_Abs_Cmpd3_Max_F1BetaGamma(t_num)); break;          //131
      case  Cmpd3_Min_FF1Beta_pp:return(m_Cmpd3_Min_FF1Beta_pp(t_num)); break;
      case  Cmpd3_Max_FF1Beta_pp:return(m_Cmpd3_Max_FF1Beta_pp(t_num)); break;
      case  Abs_Cmpd3_Min_FF1Beta_pp:return(m_Abs_Cmpd3_Min_FF1Beta_pp(t_num)); break;
      case  Abs_Cmpd3_Max_FF1Beta_pp:return(m_Abs_Cmpd3_Max_FF1Beta_pp(t_num)); break;
      case  Cmpd3_Min_FF1Gamma_pp:return(m_Cmpd3_Min_FF1Gamma_pp(t_num)); break;
      case  Cmpd3_Max_FF1Gamma_pp:return(m_Cmpd3_Max_FF1Gamma_pp(t_num)); break;
      case  Abs_Cmpd3_Min_FF1Gamma_pp:return(m_Abs_Cmpd3_Min_FF1Gamma_pp(t_num)); break;
      case  Abs_Cmpd3_Max_FF1Gamma_pp:return(m_Abs_Cmpd3_Max_FF1Gamma_pp(t_num)); break;
      case  Cmpd3_Min_FBetaGamma_pp:return(m_Cmpd3_Min_FBetaGamma_pp(t_num)); break;
      case  Cmpd3_Max_FBetaGamma_pp:return(m_Cmpd3_Max_FBetaGamma_pp(t_num)); break;
      case  Abs_Cmpd3_Min_FBetaGamma_pp:return(m_Abs_Cmpd3_Min_FBetaGamma_pp(t_num)); break;
      case  Abs_Cmpd3_Max_FBetaGamma_pp:return(m_Abs_Cmpd3_Max_FBetaGamma_pp(t_num)); break;
      case  Cmpd3_Min_F1BetaGamma_pp:return(m_Cmpd3_Min_F1BetaGamma_pp(t_num)); break;
      case  Cmpd3_Max_F1BetaGamma_pp:return(m_Cmpd3_Max_F1BetaGamma_pp(t_num)); break;
      case  Abs_Cmpd3_Min_F1BetaGamma_pp:return(m_Abs_Cmpd3_Min_F1BetaGamma_pp(t_num)); break;
      case  Abs_Cmpd3_Max_F1BetaGamma_pp:return(m_Abs_Cmpd3_Max_F1BetaGamma_pp(t_num)); break;          //147
      case  Cmpd3_Min_FF1Beta_pm:return(m_Cmpd3_Min_FF1Beta_pm(t_num)); break;
      case  Cmpd3_Max_FF1Beta_pm:return(m_Cmpd3_Max_FF1Beta_pm(t_num)); break;
      case  Abs_Cmpd3_Min_FF1Beta_pm:return(m_Abs_Cmpd3_Min_FF1Beta_pm(t_num)); break;
      case  Abs_Cmpd3_Max_FF1Beta_pm:return(m_Abs_Cmpd3_Max_FF1Beta_pm(t_num)); break;
      case  Cmpd3_Min_FF1Gamma_pm:return(m_Cmpd3_Min_FF1Gamma_pm(t_num)); break;
      case  Cmpd3_Max_FF1Gamma_pm:return(m_Cmpd3_Max_FF1Gamma_pm(t_num)); break;
      case  Abs_Cmpd3_Min_FF1Gamma_pm:return(m_Abs_Cmpd3_Min_FF1Gamma_pm(t_num)); break;
      case  Abs_Cmpd3_Max_FF1Gamma_pm:return(m_Abs_Cmpd3_Max_FF1Gamma_pm(t_num)); break;
      case  Cmpd3_Min_FBetaGamma_pm:return(m_Cmpd3_Min_FBetaGamma_pm(t_num)); break;
      case  Cmpd3_Max_FBetaGamma_pm:return(m_Cmpd3_Max_FBetaGamma_pm(t_num)); break;
      case  Abs_Cmpd3_Min_FBetaGamma_pm:return(m_Abs_Cmpd3_Min_FBetaGamma_pm(t_num)); break;
      case  Abs_Cmpd3_Max_FBetaGamma_pm:return(m_Abs_Cmpd3_Max_FBetaGamma_pm(t_num)); break;
      case  Cmpd3_Min_F1BetaGamma_pm:return(m_Cmpd3_Min_F1BetaGamma_pm(t_num)); break;
      case  Cmpd3_Max_F1BetaGamma_pm:return(m_Cmpd3_Max_F1BetaGamma_pm(t_num)); break;
      case  Abs_Cmpd3_Min_F1BetaGamma_pm:return(m_Abs_Cmpd3_Min_F1BetaGamma_pm(t_num)); break;
      case  Abs_Cmpd3_Max_F1BetaGamma_pm:return(m_Abs_Cmpd3_Max_F1BetaGamma_pm(t_num)); break;          //163
      case  Cmpd3_Min_FF1Beta_mp:return(m_Cmpd3_Min_FF1Beta_mp(t_num)); break;
      case  Cmpd3_Max_FF1Beta_mp:return(m_Cmpd3_Max_FF1Beta_mp(t_num)); break;
      case  Abs_Cmpd3_Min_FF1Beta_mp:return(m_Abs_Cmpd3_Min_FF1Beta_mp(t_num)); break;
      case  Abs_Cmpd3_Max_FF1Beta_mp:return(m_Abs_Cmpd3_Max_FF1Beta_mp(t_num)); break;
      case  Cmpd3_Min_FF1Gamma_mp:return(m_Cmpd3_Min_FF1Gamma_mp(t_num)); break;
      case  Cmpd3_Max_FF1Gamma_mp:return(m_Cmpd3_Max_FF1Gamma_mp(t_num)); break;
      case  Abs_Cmpd3_Min_FF1Gamma_mp:return(m_Abs_Cmpd3_Min_FF1Gamma_mp(t_num)); break;
      case  Abs_Cmpd3_Max_FF1Gamma_mp:return(m_Abs_Cmpd3_Max_FF1Gamma_mp(t_num)); break;
      case  Cmpd3_Min_FBetaGamma_mp:return(m_Cmpd3_Min_FBetaGamma_mp(t_num)); break;
      case  Cmpd3_Max_FBetaGamma_mp:return(m_Cmpd3_Max_FBetaGamma_mp(t_num)); break;
      case  Abs_Cmpd3_Min_FBetaGamma_mp:return(m_Abs_Cmpd3_Min_FBetaGamma_mp(t_num)); break;
      case  Abs_Cmpd3_Max_FBetaGamma_mp:return(m_Abs_Cmpd3_Max_FBetaGamma_mp(t_num)); break;
      case  Cmpd3_Min_F1BetaGamma_mp:return(m_Cmpd3_Min_F1BetaGamma_mp(t_num)); break;
      case  Cmpd3_Max_F1BetaGamma_mp:return(m_Cmpd3_Max_F1BetaGamma_mp(t_num)); break;
      case  Abs_Cmpd3_Min_F1BetaGamma_mp:return(m_Abs_Cmpd3_Min_F1BetaGamma_mp(t_num)); break;
      case  Abs_Cmpd3_Max_F1BetaGamma_mp:return(m_Abs_Cmpd3_Max_F1BetaGamma_mp(t_num)); break;          //179
      case  Cmpd3_Min_FF1Beta_mm:return(m_Cmpd3_Min_FF1Beta_mm(t_num)); break;
      case  Cmpd3_Max_FF1Beta_mm:return(m_Cmpd3_Max_FF1Beta_mm(t_num)); break;
      case  Abs_Cmpd3_Min_FF1Beta_mm:return(m_Abs_Cmpd3_Min_FF1Beta_mm(t_num)); break;
      case  Abs_Cmpd3_Max_FF1Beta_mm:return(m_Abs_Cmpd3_Max_FF1Beta_mm(t_num)); break;
      case  Cmpd3_Min_FF1Gamma_mm:return(m_Cmpd3_Min_FF1Gamma_mm(t_num)); break;
      case  Cmpd3_Max_FF1Gamma_mm:return(m_Cmpd3_Max_FF1Gamma_mm(t_num)); break;
      case  Abs_Cmpd3_Min_FF1Gamma_mm:return(m_Abs_Cmpd3_Min_FF1Gamma_mm(t_num)); break;
      case  Abs_Cmpd3_Max_FF1Gamma_mm:return(m_Abs_Cmpd3_Max_FF1Gamma_mm(t_num)); break;
      case  Cmpd3_Min_FBetaGamma_mm:return(m_Cmpd3_Min_FBetaGamma_mm(t_num)); break;
      case  Cmpd3_Max_FBetaGamma_mm:return(m_Cmpd3_Max_FBetaGamma_mm(t_num)); break;
      case  Abs_Cmpd3_Min_FBetaGamma_mm:return(m_Abs_Cmpd3_Min_FBetaGamma_mm(t_num)); break;
      case  Abs_Cmpd3_Max_FBetaGamma_mm:return(m_Abs_Cmpd3_Max_FBetaGamma_mm(t_num)); break;
      case  Cmpd3_Min_F1BetaGamma_mm:return(m_Cmpd3_Min_F1BetaGamma_mm(t_num)); break;
      case  Cmpd3_Max_F1BetaGamma_mm:return(m_Cmpd3_Max_F1BetaGamma_mm(t_num)); break;
      case  Abs_Cmpd3_Min_F1BetaGamma_mm:return(m_Abs_Cmpd3_Min_F1BetaGamma_mm(t_num)); break;
      case  Abs_Cmpd3_Max_F1BetaGamma_mm:return(m_Abs_Cmpd3_Max_F1BetaGamma_mm(t_num)); break;          //195
      case  Cmpd4_Min:return(m_Cmpd4_Min(t_num));break;
      case  Cmpd4_Max:return(m_Cmpd4_Max(t_num));break;
      case  Abs_Cmpd4_Min:return(m_Abs_Cmpd4_Min(t_num));break;
      case  Abs_Cmpd4_Max:return(m_Abs_Cmpd4_Max(t_num));break;                             //199
      case  Cmpd4_Min_ppp:return(m_Cmpd4_Min_ppp(t_num));break;
      case  Cmpd4_Max_ppp:return(m_Cmpd4_Max_ppp(t_num));break;
      case  Abs_Cmpd4_Min_ppp:return(m_Abs_Cmpd4_Min_ppp(t_num));break;
      case  Abs_Cmpd4_Max_ppp:return(m_Abs_Cmpd4_Max_ppp(t_num));break;                     //203
      case  Cmpd4_Min_ppm:return(m_Cmpd4_Min_ppm(t_num));break;
      case  Cmpd4_Max_ppm:return(m_Cmpd4_Max_ppm(t_num));break;
      case  Abs_Cmpd4_Min_ppm:return(m_Abs_Cmpd4_Min_ppm(t_num));break;
      case  Abs_Cmpd4_Max_ppm:return(m_Abs_Cmpd4_Max_ppm(t_num));break;                     //207
      case  Cmpd4_Min_pmp:return(m_Cmpd4_Min_pmp(t_num));break;
      case  Cmpd4_Max_pmp:return(m_Cmpd4_Max_pmp(t_num));break;
      case  Abs_Cmpd4_Min_pmp:return(m_Abs_Cmpd4_Min_pmp(t_num));break;
      case  Abs_Cmpd4_Max_pmp:return(m_Abs_Cmpd4_Max_pmp(t_num));break;                     //211
      case  Cmpd4_Min_mpp:return(m_Cmpd4_Min_mpp(t_num));break;
      case  Cmpd4_Max_mpp:return(m_Cmpd4_Max_mpp(t_num));break;
      case  Abs_Cmpd4_Min_mpp:return(m_Abs_Cmpd4_Min_mpp(t_num));break;
      case  Abs_Cmpd4_Max_mpp:return(m_Abs_Cmpd4_Max_mpp(t_num));break;                     //215
      case  Cmpd4_Min_mmm:return(m_Cmpd4_Min_mmm(t_num));break;
      case  Cmpd4_Max_mmm:return(m_Cmpd4_Max_mmm(t_num));break;
      case  Abs_Cmpd4_Min_mmm:return(m_Abs_Cmpd4_Min_mmm(t_num));break;
      case  Abs_Cmpd4_Max_mmm:return(m_Abs_Cmpd4_Max_mmm(t_num));break;                     //219
      case  Cmpd4_Min_mmp:return(m_Cmpd4_Min_mmp(t_num));break;
      case  Cmpd4_Max_mmp:return(m_Cmpd4_Max_mmp(t_num));break;
      case  Abs_Cmpd4_Min_mmp:return(m_Abs_Cmpd4_Min_mmp(t_num));break;
      case  Abs_Cmpd4_Max_mmp:return(m_Abs_Cmpd4_Max_mmp(t_num));break;                     //223
      case  Cmpd4_Min_mpm:return(m_Cmpd4_Min_mpm(t_num));break;
      case  Cmpd4_Max_mpm:return(m_Cmpd4_Max_mpm(t_num));break;
      case  Abs_Cmpd4_Min_mpm:return(m_Abs_Cmpd4_Min_mpm(t_num));break;
      case  Abs_Cmpd4_Max_mpm:return(m_Abs_Cmpd4_Max_mpm(t_num));break;                     //227
      case  Cmpd4_Min_pmm:return(m_Cmpd4_Min_pmm(t_num));break;
      case  Cmpd4_Max_pmm:return(m_Cmpd4_Max_pmm(t_num));break;
      case  Abs_Cmpd4_Min_pmm:return(m_Abs_Cmpd4_Min_pmm(t_num));break;
      case  Abs_Cmpd4_Max_pmm:return(m_Abs_Cmpd4_Max_pmm(t_num));break;                     //231
      case  VirtualLast:return(NoTrade_Dimenish);break;                                                  //Virtual 232                 
      default:return(NoTrade_Dimenish); break;                                // DEFAULT
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

   string s=_FName+"_"+Pair+"_";

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
//|Check GroupID of one T interval                                   |
//+------------------------------------------------------------------+
ENUM_T_GROUP_ID miniTR::CurrentCheckGroupID(const STRUCT_miniTR &mtr)
  {
//If Unknown - > Set it to Unknown
   m_current_GroupID=Unknown;

//0 SS SleepMarket
   if((mtr.dQ1==0) && (mtr.dQ4==0))
     {m_current_GroupID=NOTRADE; return(NOTRADE);}

//2 FS Singularity      
   if(((mtr.dQ1*mtr.dQ4)==0) && ((mtr.dQ1+mtr.dQ4)!=0))
     {m_current_GroupID=FSingul; return(FSingul);}

//3 F1S Singularity      
   if(((mtr.dQ1-mtr.dQ4)==0) && ((mtr.dQ1+mtr.dQ4)!=0))
     {m_current_GroupID=F1Singul; return(F1Singul);}

//4 Beta Singularity
   if(((mtr.dQ1*mtr.dQ4)==0) && ((mtr.dQ4-mtr.dQ1)!=0))
     {m_current_GroupID=BetaSingul; return(BetaSingul);}

//5 Gamma Singularity
   if(mtr.dQ14==0)
     {m_current_GroupID=GammaSingul; return(GammaSingul);}

//2 Hybrid Singularity, not to Detect!
//      if(m_current_GroupID)

//6 PPpp
   if((mtr.F==1) && (mtr.F1==1) && (mtr.Beta==1) && (mtr.Gamma==1))
     {
      m_current_GroupID=PP_pp;
      return(PP_pp);
     }

//7 PPmm
   if((mtr.F==1) && (mtr.F1==1) && (mtr.Beta==-1) && (mtr.Gamma==-1))
     {
      m_current_GroupID=PP_mm;
      return(PP_mm);
     }

//8 PPpm
   if((mtr.F==1) && (mtr.F1==1) && (mtr.Beta==1) && (mtr.Gamma==-1))
     {
      m_current_GroupID=PP_pm;
      return(PP_pm);
     }

//9 PPmp
   if((mtr.F==1) && (mtr.F1==1) && (mtr.Beta==-1) && (mtr.Gamma==1))
     {
      m_current_GroupID=PP_mp;
      return(PP_mp);
     }

//10 MMpp
   if((mtr.F==-1) && (mtr.F1==-1) && (mtr.Beta==1) && (mtr.Gamma==1))
     {
      m_current_GroupID=MM_pp;
      return(MM_pp);
     }

//11 MMmm
   if((mtr.F==-1) && (mtr.F1==-1) && (mtr.Beta==-1) && (mtr.Gamma==-1))
     {
      m_current_GroupID=MM_mm;
      return(MM_mm);
     }

//12 MMpm
   if((mtr.F==-1) && (mtr.F1==-1) && (mtr.Beta==1) && (mtr.Gamma==-1))
     {
      m_current_GroupID=MM_pm;
      return(MM_pm);
     }

//13 MMmp
   if((mtr.F==-1) && (mtr.F1==-1) && (mtr.Beta==-1) && (mtr.Gamma==1))
     {
      m_current_GroupID=MM_mp;
      return(MM_mp);
     }

//14 PMpp
   if((mtr.F==1) && (mtr.F1==-1) && (mtr.Beta==1) && (mtr.Gamma==1))
     {
      m_current_GroupID=PM_pp;
      return(PM_pp);
     }

//15 PMmm
   if((mtr.F==1) && (mtr.F1==-1) && (mtr.Beta==-1) && (mtr.Gamma==-1))
     {
      m_current_GroupID=PM_mm;
      return(PM_mm);
     }

//16 PMpm
   if((mtr.F==1) && (mtr.F1==-1) && (mtr.Beta==1) && (mtr.Gamma==-1))
     {
      m_current_GroupID=PM_pm;
      return(PM_pm);
     }

//17 PMmp
   if((mtr.F==1) && (mtr.F1==-1) && (mtr.Beta==-1) && (mtr.Gamma==1))
     {
      m_current_GroupID=PM_mp;
      return(PM_mp);
     }

//18 MPpp
   if((mtr.F==-1) && (mtr.F1==1) && (mtr.Beta==1) && (mtr.Gamma==1))
     {
      m_current_GroupID=MP_pp;
      return(MP_pp);
     }

//19 MPmm
   if((mtr.F==-1) && (mtr.F1==1) && (mtr.Beta==-1) && (mtr.Gamma==-1))
     {
      m_current_GroupID=MP_mm;
      return(MP_mm);
     }

//20 MPpm
   if((mtr.F==-1) && (mtr.F1==1) && (mtr.Beta==1) && (mtr.Gamma==-1))
     {
      m_current_GroupID=MP_pm;
      return(MP_pm);
     }

//21 MPmp
   if((mtr.F==-1) && (mtr.F1==1) && (mtr.Beta==-1) && (mtr.Gamma==1))
     {
      m_current_GroupID=MP_mp;
      return(MP_mp);
     }
//If no
   return(Unknown);
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
   ArrayResize(m_arr_SUM_PositiveCount,m_minitr_count);

//Always Fill IT!!! Before +=
   ArrayFill(m_arr_SUM_NP_GROUP,0,ArraySize(m_arr_SUM_NP_GROUP),0);
   ArrayFill(m_arr_SUM_PositiveCount,0,ArraySize(m_arr_SUM_PositiveCount),0);

//Temp result
   double NP_Result=0;

//Cycle by each T interval for every miniTR (T Count - imported from file)
   for(int t=0;t<ArrSize;t++)
     {
      for(ENUM_miniTR_ID mini=0;mini<m_minitr_count;mini++)
        {
         // x - row(227);y - column(23)
         NP_Result=m_Calc_miniTR(mini,t);

         // Sum NP By Group & miniTR#
         m_arr_SUM_NP_GROUP[mini][m_arr_GroupID[t]]+=NP_Result;

         //Check Every T, is it Positive?
         if(NP_Result>0) m_arr_SUM_PositiveCount[mini][m_arr_GroupID[t]]++;

        }//END OF FOR mini
     }//END OF FOR t

//Stop speed measuring
   uint Stop_measuring=GetTickCount()-Start_measure;
   Print("Processing complete in "+(string)Stop_measuring+" ms");//, Items Count: "+(string)i);
                                                                 //
//Find Best miniTR
   m_FindBestMAX_miniTR();
  }
//+------------------------------------------------------------------+
//| Find Best miniTR for every group  by Maximum NP in Group         |
//+------------------------------------------------------------------+
void miniTR::m_FindBestMAX_miniTR()
  {
   double MaximumNP=-9999999999999;
   double MaximumPositiveCount=-9999999999999;

//Find Best miniTR in each Group  
   for(int j=0;j<m_groups_count;j++)
     {
      //Clear Maximum
      MaximumNP=-9999999999999;
      MaximumPositiveCount=-9999999999999;

      for(int i=0;i<m_minitr_count;i++)
        {
         //MaxNP
         if(m_arr_SUM_NP_GROUP[i][j]>MaximumNP)
           {
            //Save Maximum NP
            MaximumNP=m_arr_SUM_NP_GROUP[i][j];

            //Save miniTR Index & Best NP for this GroupID
            m_arr_minitr[j].MiniTR_ID_MaxBalance=i;
            m_arr_minitr[j].Max_Balance=MaximumNP;
           }

         //Max PositiveCount
         if(m_arr_SUM_PositiveCount[i][j]>MaximumPositiveCount)
           {
            //Save Maximum NP
            MaximumPositiveCount=m_arr_SUM_PositiveCount[i][j];

            //Save miniTR Index & Best NP for this GroupID
            m_arr_minitr[j].MiniTR_ID_MaxPositiveCount=i;
            m_arr_minitr[j].Max_PositiveCount=MaximumPositiveCount;
           }

        }//END OF i-miniTRs Count (4+)
     }//END OF J-GROUPS(23)
   Print("Find best miniTR Complete.");
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
      s+=DoubleToString(m_arr_minitr[i].Max_Balance,2)+SP;

//Next Row
   s+="\r\n";

//Left side of the Header 2
   s+="Best miniTR:"+SP+SP+SP+SP+SP+SP+SP;

//2  Second Header Row - Best miniTR name for each group   
   for(ENUM_T_GROUP_ID i=NOTRADE;i<Unknown;i++)
     {
      //Don`t Show not trade
      if(m_arr_minitr[i].Max_Balance<2) s+=""+SP;
      else  s+=EnumToString((ENUM_miniTR_ID)m_arr_minitr[i].MiniTR_ID_MaxBalance)+SP;
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
         mini=(ENUM_miniTR_ID)m_arr_minitr[j].MiniTR_ID_MaxBalance;
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
double miniTR::m_Min_AB(const int &T_NUM)
  {
   m_result=0;
   m_result=MathMin(m_arr_mtr[T_NUM].A,m_arr_mtr[T_NUM].B);

//Sum NP by Group
   if(m_result==m_arr_mtr[T_NUM].A) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #3  MaxAB, miniTR                                              |
//+------------------------------------------------------------------+  
double miniTR::m_Max_AB(const int &T_NUM)
  {
   m_result=0;
   m_result=MathMax(m_arr_mtr[T_NUM].A,m_arr_mtr[T_NUM].B);

//Sum NP by Group
   if(m_result==m_arr_mtr[T_NUM].A) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #5 ABS  MinAB, miniTR                                          |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Min_AB(const int &T_NUM)
  {
   m_AbsA=0; m_AbsB=0; m_result=0;
   m_AbsA = MathAbs(m_arr_mtr[T_NUM].A);
   m_AbsB = MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_AbsA,m_AbsB);

//Sum NP by Group
   if(m_result==m_AbsA) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #6 ABS  MaxAB, miniTR                                          |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Max_AB(const int &T_NUM)
  {
   m_AbsA=0; m_AbsB=0; m_result=0;
   m_AbsA = MathAbs(m_arr_mtr[T_NUM].A);
   m_AbsB = MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_AbsA,m_AbsB);

//Sum NP by Group
   if(m_result==m_AbsA) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #7 Min fAB, miniTR                                             |
//+------------------------------------------------------------------+  
double miniTR::m_Min_fAB(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;
   m_x1 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].B;
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #8 Max fAB, miniTR                                             |
//+------------------------------------------------------------------+  
double miniTR::m_Max_fAB(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;
   m_x1 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].B;
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #9 ABS Min fAB, miniTR                                         |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Min_fAB(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;
   m_x1 = m_arr_mtr[T_NUM].F*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #10 ABS Max fAB, miniTR                                        |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Max_fAB(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;
   m_x1 = m_arr_mtr[T_NUM].F*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #11 Min f1AB, miniTR                                           |
//+------------------------------------------------------------------+  
double miniTR::m_Min_f1AB(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;
   m_x1 = m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].B;
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #12 Max f1AB, miniTR                                           |
//+------------------------------------------------------------------+  
double miniTR::m_Max_f1AB(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;
   m_x1 = m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].B;
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #13 ABS Min f1AB, miniTR                                       |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Min_f1AB(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;
   m_x1 = m_arr_mtr[T_NUM].F1*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F1*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #14 ABS Max f1AB, miniTR                                       |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Max_f1AB(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;
   m_x1 = m_arr_mtr[T_NUM].F1*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F1*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #15 Min BetaAB, miniTR                                         |
//+------------------------------------------------------------------+  
double miniTR::m_Min_BetaAB(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;
   m_x1 = m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].B;
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #16 Max BetaAB, miniTR                                         |
//+------------------------------------------------------------------+  
double miniTR::m_Max_BetaAB(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;
   m_x1 = m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].B;
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #17 ABS Min BetaAB, miniTR                                     |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Min_BetaAB(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;
   m_x1 = m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #18 ABS Max BetaAB, miniTR                                     |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Max_BetaAB(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;
   m_x1 = m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #19 Min HammaAB, miniTR                                        |
//+------------------------------------------------------------------+  
double miniTR::m_Min_GammaAB(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;
   m_x1 = m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].B;
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #20 Max GammaAB, miniTR                                        |
//+------------------------------------------------------------------+  
double miniTR::m_Max_GammaAB(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;
   m_x1 = m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].B;
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #21 ABS Min GammaAB, miniTR                                    |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Min_GammaAB(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;
   m_x1 = m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #22 ABS Max GammaAB, miniTR                                    |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Max_GammaAB(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;
   m_x1 = m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #24  dQ1=dQ4  C1  , miniTR                                     |
//+------------------------------------------------------------------+  
double miniTR::m_Equal_dQ1Q4_C1(const int &T_NUM)
  {
   if(m_arr_mtr[T_NUM].dQ1==m_arr_mtr[T_NUM].dQ4) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(0);
  }
//+------------------------------------------------------------------+
//|   #25  dQ1=dQ4  C4  , miniTR                                     |
//+------------------------------------------------------------------+  
double miniTR::m_Equal_dQ1Q4_C4(const int &T_NUM)
  {
   if(m_arr_mtr[T_NUM].dQ1==m_arr_mtr[T_NUM].dQ4) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(0);
  }
//+------------------------------------------------------------------+
//|   #27 dQ1=dQ4 Min, miniTR                                        |
//+------------------------------------------------------------------+  
double miniTR::m_Equal_dQ1Q4_MinAB(const int &T_NUM)
  {
   if(m_arr_mtr[T_NUM].dQ1!=m_arr_mtr[T_NUM].dQ4) return(0);

   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].B;
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #28 dQ1=dQ4 Max, miniTR                                        |
//+------------------------------------------------------------------+  
double miniTR::m_Equal_dQ1Q4_MaxAB(const int &T_NUM)
  {
   if(m_arr_mtr[T_NUM].dQ1!=m_arr_mtr[T_NUM].dQ4) return(0);

   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].B;
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #29 dQ1=0 dQ4=0 C1, miniTR                                     |
//+------------------------------------------------------------------+  
double miniTR::m_Zero_dQ1Q4_C1(const int &T_NUM)
  {
   if((m_arr_mtr[T_NUM].dQ1==0) && (m_arr_mtr[T_NUM].dQ4==0)) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(0);
  }
//+------------------------------------------------------------------+
//|   #30 dQ1=0 dQ4=0 C1, miniTR                                     |
//+------------------------------------------------------------------+  
double miniTR::m_Zero_dQ1Q4_C4(const int &T_NUM)
  {
   if((m_arr_mtr[T_NUM].dQ1==0) && (m_arr_mtr[T_NUM].dQ4==0)) return(m_arr_rNP4[T_NUM].NP4_RT);
   else return(0);
  }
//+------------------------------------------------------------------+
//|   #32 dQ1=0 dQ4=0 Min, miniTR                                    |
//+------------------------------------------------------------------+  
double miniTR::m_Zero_dQ1Q4_MinAB(const int &T_NUM)
  {
   if((m_arr_mtr[T_NUM].dQ1!=0) && (m_arr_mtr[T_NUM].dQ4!=0)) return(0);

   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].B;
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #33 dQ1=0 dQ4=0 Max, miniTR                                    |
//+------------------------------------------------------------------+  
double miniTR::m_Zero_dQ1Q4_MaxAB(const int &T_NUM)
  {
   if((m_arr_mtr[T_NUM].dQ1!=0) && (m_arr_mtr[T_NUM].dQ4!=0)) return(0);

   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].B;
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #34 A=B C1, miniTR                                             |
//+------------------------------------------------------------------+  
double miniTR::m_Equal_AB_C1(const int &T_NUM)
  {
   if((m_arr_mtr[T_NUM].A==m_arr_mtr[T_NUM].B)) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(0);
  }
//+------------------------------------------------------------------+
//|   #35 A=B C4, miniTR                                             |
//+------------------------------------------------------------------+  
double miniTR::m_Equal_AB_C4(const int &T_NUM)
  {
   if((m_arr_mtr[T_NUM].A==m_arr_mtr[T_NUM].B)) return(m_arr_rNP4[T_NUM].NP4_RT);
   else return(0);
  }
//+------------------------------------------------------------------+
//|   #37 A=B Min , miniTR                                           |
//+------------------------------------------------------------------+  
double miniTR::m_Equal_AB_MinAB(const int &T_NUM)
  {
   if((m_arr_mtr[T_NUM].A!=m_arr_mtr[T_NUM].B)) return(0);

   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].B;
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #38 A=B Max , miniTR                                           |
//+------------------------------------------------------------------+  
double miniTR::m_Equal_AB_MaxAB(const int &T_NUM)
  {
   if((m_arr_mtr[T_NUM].A!=m_arr_mtr[T_NUM].B)) return(0);

   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].B;
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #39 A*B=0 C1 , miniTR                                          |
//+------------------------------------------------------------------+  
double miniTR::m_Zero_AmB_C1(const int &T_NUM)
  {
   if((m_arr_mtr[T_NUM].A*m_arr_mtr[T_NUM].B)==0) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(0);
  }
//+------------------------------------------------------------------+
//|   #40 A*B=0 C4 , miniTR                                          |
//+------------------------------------------------------------------+  
double miniTR::m_Zero_AmB_C4(const int &T_NUM)
  {
   if((m_arr_mtr[T_NUM].A*m_arr_mtr[T_NUM].B)==0) return(m_arr_rNP4[T_NUM].NP4_RT);
   else return(0);
  }
//+------------------------------------------------------------------+
//|   #42 A*B=0 Min , miniTR                                         |
//+------------------------------------------------------------------+  
double miniTR::m_Zero_AmB_MinAB(const int &T_NUM)
  {
   if((m_arr_mtr[T_NUM].A*m_arr_mtr[T_NUM].B)!=0) return(0);

   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].B;
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #43 A*B=0 Max , miniTR                                         |
//+------------------------------------------------------------------+  
double miniTR::m_Zero_AmB_MaxAB(const int &T_NUM)
  {
   if((m_arr_mtr[T_NUM].A*m_arr_mtr[T_NUM].B)!=0) return(0);

   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].B;
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #44 Compound 2(*) Min FF1 , miniTR                             |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Min_FF1(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].B;
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #45 Compound 2(*) Max FF1 , miniTR                             |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Max_FF1(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].B;
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #46 ABS Compound 2(*) Min FF1 , miniTR                         |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Min_FF1(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].F1*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].F1*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #47 ABS Compound 2(*) Max FF1 , miniTR                         |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Max_FF1(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].F1*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].F1*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #48 Compound 2(*) Min FBeta , miniTR                           |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Min_FBeta(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].B;
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #49 Compound 2(*) Max FBeta , miniTR                           |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Max_FBeta(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].B;
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #50 ABS Compound 2(*) Min FBeta miniTR                         |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Min_FBeta(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #51 ABS Compound 2(*) Max FBeta , miniTR                       |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Max_FBeta(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #52 Compound 2(*) Min FGamma , miniTR                          |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Min_FGamma(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].B;
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #53 Compound 2(*) Max FGamma , miniTR                          |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Max_FGamma(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].B;
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #54 ABS Compound 2(*) Min FGamma miniTR                        |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Min_FGamma(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #55 ABS Compound 2(*) Max FGamma , miniTR                      |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Max_FGamma(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #56 Compound 2(*) Min F1Beta , miniTR                          |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Min_F1Beta(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].B;
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #57 Compound 2(*) Max F1Beta , miniTR                          |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Max_F1Beta(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].B;
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #58 ABS Compound 2(*) Min F1Beta miniTR                        |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Min_F1Beta(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #59 ABS Compound 2(*) Max F1Beta , miniTR                      |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Max_F1Beta(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #60 Compound 2(*) Min F1Gamma , miniTR                         |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Min_F1Gamma(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].B;
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #61 Compound 2(*) Max F1Gamma , miniTR                         |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Max_F1Gamma(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].B;
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #62 ABS Compound 2(*) Min F1Gamma miniTR                       |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Min_F1Gamma(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #63 ABS Compound 2(*) Max F1Gamma , miniTR                     |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Max_F1Gamma(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #64 Compound 2(*) Min BetaGamma , miniTR                       |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Min_BetaGamma(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].B;
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #65 Compound 2(*) Max BetaGamma , miniTR                       |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Max_BetaGamma(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].B;
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #66 ABS Compound 2(*) Min BetaGamma miniTR                     |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Min_BetaGamma(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #67 ABS Compound 2(*) Max BetaGamma , miniTR                   |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Max_BetaGamma(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #68 Compound 2(+) Min FF1 , miniTR                             |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Min_FF1_plus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].B;
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #69 Compound 2(+) Max FF1 , miniTR                             |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Max_FF1_plus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].B;
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #70 ABS Compound 2(-) Min FF1 , miniTR                         |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Min_FF1_plus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #71 ABS Compound 2(+) Max FF1 , miniTR                         |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Max_FF1_plus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #72 Compound 2(+) Min FBeta , miniTR                           |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Min_FBeta_plus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].B;
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #73 Compound 2(+) Max FBeta , miniTR                           |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Max_FBeta_plus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].B;
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #74 ABS Compound 2(+) Min FBeta miniTR                         |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Min_FBeta_plus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #75 ABS Compound 2(+) Max FBeta , miniTR                       |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Max_FBeta_plus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #76 Compound 2(+) Min FGamma , miniTR                          |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Min_FGamma_plus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].B;
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #77 Compound 2(+) Max FGamma , miniTR                          |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Max_FGamma_plus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].B;
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #78 ABS Compound 2(+) Min FGamma miniTR                        |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Min_FGamma_plus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #79 ABS Compound 2(+) Max FGamma , miniTR                      |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Max_FGamma_plus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #80 Compound 2(+) Min F1Beta , miniTR                          |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Min_F1Beta_plus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].B;
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #81 Compound 2(+) Max F1Beta , miniTR                          |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Max_F1Beta_plus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].B;
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #82 ABS Compound 2(+) Min F1Beta miniTR                        |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Min_F1Beta_plus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #83 ABS Compound 2(+) Max F1Beta , miniTR                      |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Max_F1Beta_plus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #84 Compound 2(+) Min F1Gamma , miniTR                         |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Min_F1Gamma_plus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].B;
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #85 Compound 2(+) Max F1Gamma , miniTR                         |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Max_F1Gamma_plus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].B;
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #86 ABS Compound 2(+) Min F1Gamma miniTR                       |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Min_F1Gamma_plus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #87 ABS Compound 2(+) Max F1Gamma , miniTR                     |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Max_F1Gamma_plus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #88 Compound 2(+) Min BetaGamma , miniTR                       |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Min_BetaGamma_plus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].B;
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #89 Compound 2(+) Max BetaGamma , miniTR                       |
//+------------------------------------------------------------------+  
double miniTR::m_Cmpd2_Max_BetaGamma_plus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].B;
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #90 ABS Compound 2(+) Min BetaGamma miniTR                     |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Min_BetaGamma_plus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//|   #91 ABS Compound 2(+) Max BetaGamma , miniTR                   |
//+------------------------------------------------------------------+  
double miniTR::m_Abs_Cmpd2_Max_BetaGamma_plus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #92 Compound 2(-) Min FF1 , miniTR                             |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd2_Min_FF1_minus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].B;
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #93 Compound 2(-) Max FF1 , miniTR                             |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd2_Max_FF1_minus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].B;
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #94 ABS Compound 2(-) Min FF1 , miniTR                         |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd2_Min_FF1_minus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #95 ABS Compound 2(-) Max FF1 , miniTR                         |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd2_Max_FF1_minus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #96 Compound 2(-) Min FBeta , miniTR                           |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd2_Min_FBeta_minus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].B;
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #97 Compound 2(-) Max FBeta , miniTR                           |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd2_Max_FBeta_minus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].B;
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #98 ABS Compound 2(-) Min FBeta miniTR                         |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd2_Min_FBeta_minus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #99 ABS Compound 2(-) Max FBeta , miniTR                       |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd2_Max_FBeta_minus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #100 Compound 2(-) Min FGamma , miniTR                         |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd2_Min_FGamma_minus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].B;
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #101 Compound 2(-) Max FGamma , miniTR                         |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd2_Max_FGamma_minus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].B;
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #102 ABS Compound 2(-) Min FGamma miniTR                       |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd2_Min_FGamma_minus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #103 ABS Compound 2(-) Max FGamma , miniTR                     |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd2_Max_FGamma_minus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #104 Compound 2(-) Min F1Beta , miniTR                         |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd2_Min_F1Beta_minus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].B;
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #105 Compound 2(-) Max F1Beta , miniTR                         |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd2_Max_F1Beta_minus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].B;
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #106 ABS Compound 2(-) Min F1Beta miniTR                       |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd2_Min_F1Beta_minus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #107 ABS Compound 2(-) Max F1Beta , miniTR                     |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd2_Max_F1Beta_minus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #108 Compound 2(-) Min F1Gamma , miniTR                        |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd2_Min_F1Gamma_minus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].B;
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #109 Compound 2(-) Max F1Gamma , miniTR                        |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd2_Max_F1Gamma_minus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].B;
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #110 ABS Compound 2(-) Min F1Gamma miniTR                      |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd2_Min_F1Gamma_minus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #111 ABS Compound 2(-) Max F1Gamma , miniTR                    |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd2_Max_F1Gamma_minus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #112 Compound 2(-) Min BetaGamma , miniTR                      |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd2_Min_BetaGamma_minus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].B;
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #113 Compound 2(-) Max BetaGamma , miniTR                      |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd2_Max_BetaGamma_minus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].A;
   m_x2 = m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*m_arr_mtr[T_NUM].B;
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #114 ABS Compound 2(-) Min BetaGamma miniTR                    |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd2_Min_BetaGamma_minus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #115 ABS Compound 2(-) Max BetaGamma , miniTR                  |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd2_Max_BetaGamma_minus(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #116  Compound 3(*) Min FF1Beta , miniTR                       |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Min_FF1Beta(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Beta*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Beta*(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #117  Compound 3(*) Max FF1Beta , miniTR                       |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Max_FF1Beta(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Beta*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Beta*(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #118 ABS Compound 3(*) Min FF1Beta , miniTR                    |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Min_FF1Beta(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #119  ABS Compound 3(*) Max FF1Beta , miniTR                   |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Max_FF1Beta(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #120  Compound 3(*) Min FF1Gamma , miniTR                      |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Min_FF1Gamma(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #121  Compound 3(*) Max FF1Gamma , miniTR                      |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Max_FF1Gamma(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #122 ABS Compound 3(*) Min FF1Gamma , miniTR                   |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Min_FF1Gamma(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #123  ABS Compound 3(*) Max FF1Gamma , miniTR                  |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Max_FF1Gamma(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #124  Compound 3(*) Min FBetaGamma , miniTR                    |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Min_FBetaGamma(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #125  Compound 3(*) Max FBetaGamma , miniTR                    |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Max_FBetaGamma(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #126 ABS Compound 3(*) Min FBetaGamma , miniTR                 |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Min_FBetaGamma(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #127  ABS Compound 3(*) Max FBetaGamma , miniTR                |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Max_FBetaGamma(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #128  Compound 3(*) Min F1BetaGamma , miniTR                   |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Min_F1BetaGamma(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #129  Compound 3(*) Max F1BetaGamma , miniTR                   |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Max_F1BetaGamma(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #130 ABS Compound 3(*) Min F1BetaGamma , miniTR                |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Min_F1BetaGamma(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #131  ABS Compound 3(*) Max F1BetaGamma , miniTR               |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Max_F1BetaGamma(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #132  Compound 3(++) Min FF1Beta , miniTR                      |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Min_FF1Beta_pp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta*(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #133  Compound 3(++) Max FF1Beta , miniTR                      |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Max_FF1Beta_pp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta*(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #134 ABS Compound 3(++) Min FF1Beta , miniTR                   |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Min_FF1Beta_pp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #135  ABS Compound 3(++) Max FF1Beta , miniTR                  |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Max_FF1Beta_pp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #136  Compound 3(++) Min FF1Gamma , miniTR                     |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Min_FF1Gamma_pp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #137  Compound 3(++) Max FF1Gamma , miniTR                     |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Max_FF1Gamma_pp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #138 ABS Compound 3(++) Min FF1Gamma , miniTR                  |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Min_FF1Gamma_pp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #139  ABS Compound 3(++) Max FF1Gamma , miniTR                 |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Max_FF1Gamma_pp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #140  Compound 3(++) Min FBetaGamma , miniTR                   |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Min_FBetaGamma_pp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #141  Compound 3(++) Max FBetaGamma , miniTR                   |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Max_FBetaGamma_pp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #142 ABS Compound 3(++) Min FBetaGamma , miniTR                |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Min_FBetaGamma_pp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #143  ABS Compound 3(++) Max FBetaGamma , miniTR               |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Max_FBetaGamma_pp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #144  Compound 3(++) Min F1BetaGamma , miniTR                  |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Min_F1BetaGamma_pp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #145  Compound 3(++) Max F1BetaGamma , miniTR                  |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Max_F1BetaGamma_pp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #146 ABS Compound 3(++) Min F1BetaGamma , miniTR               |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Min_F1BetaGamma_pp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #147  ABS Compound 3(++) Max F1BetaGamma , miniTR              |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Max_F1BetaGamma_pp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #148  Compound 3(+-) Min FF1Beta , miniTR                      |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Min_FF1Beta_pm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta*(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #149  Compound 3(+-) Max FF1Beta , miniTR                      |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Max_FF1Beta_pm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta*(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #150 ABS Compound 3(+-) Min FF1Beta , miniTR                   |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Min_FF1Beta_pm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #151  ABS Compound 3(+-) Max FF1Beta , miniTR                  |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Max_FF1Beta_pm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #152  Compound 3(+-) Min FF1Gamma , miniTR                     |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Min_FF1Gamma_pm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #153  Compound 3(+-) Max FF1Gamma , miniTR                     |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Max_FF1Gamma_pm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #154 ABS Compound 3(+-) Min FF1Gamma , miniTR                  |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Min_FF1Gamma_pm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #155  ABS Compound 3(+-) Max FF1Gamma , miniTR                 |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Max_FF1Gamma_pm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #156  Compound 3(+-) Min FBetaGamma , miniTR                   |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Min_FBetaGamma_pm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #157  Compound 3(+-) Max FBetaGamma , miniTR                   |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Max_FBetaGamma_pm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #158 ABS Compound 3(+-) Min FBetaGamma , miniTR                |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Min_FBetaGamma_pm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #159  ABS Compound 3(+-) Max FBetaGamma , miniTR               |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Max_FBetaGamma_pm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #160  Compound 3(+-) Min F1BetaGamma , miniTR                  |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Min_F1BetaGamma_pm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #161  Compound 3(+-) Max F1BetaGamma , miniTR                  |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Max_F1BetaGamma_pm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #162 ABS Compound 3(+-) Min F1BetaGamma , miniTR               |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Min_F1BetaGamma_pm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #163  ABS Compound 3(+-) Max F1BetaGamma , miniTR              |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Max_F1BetaGamma_pm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #164  Compound 3(-+) Min FF1Beta , miniTR                      |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Min_FF1Beta_mp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta*(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #165  Compound 3(-+) Max FF1Beta , miniTR                      |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Max_FF1Beta_mp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta*(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #166 ABS Compound 3(-+) Min FF1Beta , miniTR                   |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Min_FF1Beta_mp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #167  ABS Compound 3(-+) Max FF1Beta , miniTR                  |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Max_FF1Beta_mp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #168  Compound 3(-+) Min FF1Gamma , miniTR                     |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Min_FF1Gamma_mp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #169  Compound 3(-+) Max FF1Gamma , miniTR                     |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Max_FF1Gamma_mp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #170 ABS Compound 3(-+) Min FF1Gamma , miniTR                  |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Min_FF1Gamma_mp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #171  ABS Compound 3(-+) Max FF1Gamma , miniTR                 |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Max_FF1Gamma_mp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #172  Compound 3(-+) Min FBetaGamma , miniTR                   |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Min_FBetaGamma_mp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #173  Compound 3(-+) Max FBetaGamma , miniTR                   |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Max_FBetaGamma_mp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #174 ABS Compound 3(-+) Min FBetaGamma , miniTR                |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Min_FBetaGamma_mp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #175  ABS Compound 3(-+) Max FBetaGamma , miniTR               |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Max_FBetaGamma_mp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #176  Compound 3(-+) Min F1BetaGamma , miniTR                  |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Min_F1BetaGamma_mp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #177  Compound 3(-+) Max F1BetaGamma , miniTR                  |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Max_F1BetaGamma_mp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #178 ABS Compound 3(-+) Min F1BetaGamma , miniTR               |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Min_F1BetaGamma_mp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #179  ABS Compound 3(-+) Max F1BetaGamma , miniTR              |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Max_F1BetaGamma_mp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #180  Compound 3(--) Min FF1Beta , miniTR                      |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Min_FF1Beta_mm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta*(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #181  Compound 3(--) Max FF1Beta , miniTR                      |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Max_FF1Beta_mm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta*(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #182 ABS Compound 3(--) Min FF1Beta , miniTR                   |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Min_FF1Beta_mm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #183  ABS Compound 3(--) Max FF1Beta , miniTR                  |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Max_FF1Beta_mm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #184  Compound 3(--) Min FF1Gamma , miniTR                     |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Min_FF1Gamma_mm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #185  Compound 3(--) Max FF1Gamma , miniTR                     |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Max_FF1Gamma_mm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #186 ABS Compound 3(--) Min FF1Gamma , miniTR                  |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Min_FF1Gamma_mm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #187  ABS Compound 3(--) Max FF1Gamma , miniTR                 |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Max_FF1Gamma_mm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #188  Compound 3(--) Min FBetaGamma , miniTR                   |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Min_FBetaGamma_mm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #189  Compound 3(--) Max FBetaGamma , miniTR                   |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Max_FBetaGamma_mm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #190 ABS Compound 3(--) Min FBetaGamma , miniTR                |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Min_FBetaGamma_mm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #191  ABS Compound 3(--) Max FBetaGamma , miniTR               |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Max_FBetaGamma_mm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #192  Compound 3(--) Min F1BetaGamma , miniTR                  |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Min_F1BetaGamma_mm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #193  Compound 3(--) Max F1BetaGamma , miniTR                  |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd3_Max_F1BetaGamma_mm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #194 ABS Compound 3(--) Min F1BetaGamma , miniTR               |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Min_F1BetaGamma_mm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #195  ABS Compound 3(--) Max F1BetaGamma , miniTR              |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd3_Max_F1BetaGamma_mm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #196  Compound 4(*) Min FF1BetaGamma , miniTR                  |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd4_Min(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #197  Compound 4(*) Max FF1BetaGamma , miniTR                  |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd4_Max(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #198 ABS Compound 4(*) Min FF1BetaGamma , miniTR               |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd4_Min(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #199 ABS Compound 4(*) Max FF1BetaGamma , miniTR               |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd4_Max(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F*m_arr_mtr[T_NUM].F1*m_arr_mtr[T_NUM].Beta*m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #200  Compound 4(+++) Min FF1BetaGamma , miniTR                |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd4_Min_ppp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #201  Compound 4(+++) Max FF1BetaGamma , miniTR                |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd4_Max_ppp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #202 ABS Compound 4(+++) Min FF1BetaGamma , miniTR             |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd4_Min_ppp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #203 ABS Compound 4(+++) Max FF1BetaGamma , miniTR             |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd4_Max_ppp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #204  Compound 4(++-) Min FF1BetaGamma , miniTR                |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd4_Min_ppm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #205  Compound 4(++-) Max FF1BetaGamma , miniTR                |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd4_Max_ppm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #206 ABS Compound 4(++-) Min FF1BetaGamma , miniTR             |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd4_Min_ppm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #207 ABS Compound 4(++-) Max FF1BetaGamma , miniTR             |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd4_Max_ppm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #208  Compound 4(+-+) Min FF1BetaGamma , miniTR                |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd4_Min_pmp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #209  Compound 4(+-+) Max FF1BetaGamma , miniTR                |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd4_Max_pmp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #210 ABS Compound 4(+-+) Min FF1BetaGamma , miniTR             |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd4_Min_pmp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #211 ABS Compound 4(+-+) Max FF1BetaGamma , miniTR             |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd4_Max_pmp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #212  Compound 4(-++) Min FF1BetaGamma , miniTR                |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd4_Min_mpp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #213  Compound 4(-++) Max FF1BetaGamma , miniTR                |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd4_Max_mpp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #214 ABS Compound 4(-++) Min FF1BetaGamma , miniTR             |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd4_Min_mpp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #215 ABS Compound 4(-++) Max FF1BetaGamma , miniTR             |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd4_Max_mpp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #216  Compound 4(---) Min FF1BetaGamma , miniTR                |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd4_Min_mmm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #217  Compound 4(---) Max FF1BetaGamma , miniTR                |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd4_Max_mmm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #218 ABS Compound 4(---) Min FF1BetaGamma , miniTR             |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd4_Min_mmm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #219 ABS Compound 4(---) Max FF1BetaGamma , miniTR             |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd4_Max_mmm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #220  Compound 4(--+) Min FF1BetaGamma , miniTR                |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd4_Min_mmp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #221  Compound 4(--+) Max FF1BetaGamma , miniTR                |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd4_Max_mmp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #222 ABS Compound 4(--+) Min FF1BetaGamma , miniTR             |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd4_Min_mmp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #223 ABS Compound 4(--+) Max FF1BetaGamma , miniTR             |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd4_Max_mmp(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta+m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #224  Compound 4(-+-) Min FF1BetaGamma , miniTR                |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd4_Min_mpm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #225  Compound 4(-+-) Max FF1BetaGamma , miniTR                |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd4_Max_mpm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #226 ABS Compound 4(-+-) Min FF1BetaGamma , miniTR             |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd4_Min_mpm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #227 ABS Compound 4(-+-) Max FF1BetaGamma , miniTR             |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd4_Max_mpm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F-m_arr_mtr[T_NUM].F1+m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #228  Compound 4(+--) Min FF1BetaGamma , miniTR                |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd4_Min_pmm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #229  Compound 4(+--) Max FF1BetaGamma , miniTR                |
//--------------------------------------------------------------------  
double miniTR::m_Cmpd4_Max_pmm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*(m_arr_mtr[T_NUM].B);
   m_result=MathMax(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//--------------------------------------------------------------------
//|   #230 ABS Compound 4(+--) Min FF1BetaGamma , miniTR             |
//--------------------------------------------------------------------  
double miniTR::m_Abs_Cmpd4_Min_pmm(const int &T_NUM)
  {
   m_x1=0; m_x2=0; m_result=0;

   m_x1 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].A);
   m_x2 = m_arr_mtr[T_NUM].F+m_arr_mtr[T_NUM].F1-m_arr_mtr[T_NUM].Beta-m_arr_mtr[T_NUM].Gamma*MathAbs(m_arr_mtr[T_NUM].B);
   m_result=MathMin(m_x1,m_x2);

//Sum NP by Group
   if(m_result==m_x1) return(m_arr_rNP1[T_NUM].NP1_RT);
   else return(m_arr_rNP4[T_NUM].NP4_RT);
  }
//+------------------------------------------------------------------+
//--------------------------------------------------------------------
//|   Calculate Ck signal for current Group                          |
//-------------------------------------------------------------------- 
ENUM_CK_SIGNALS  miniTR::CalculateCk(const STRUCT_miniTR &mtr,const ENUM_miniTR_ID &miniTRID)
  {
//Resize Arr
   ArrayResize(m_arr_rNP1,1,10);
   ArrayResize(m_arr_rNP4,1,10);
   ArrayResize(m_arr_mtr,1,10);

//Plomb Signals directly to ARR
   m_arr_rNP1[0].NP1_RT=CkBuy1;
   m_arr_rNP4[0].NP4_RT=CkSell4;

//Save struct to Zero array
   m_arr_mtr[0]=mtr;

   int t=0;

//Calculate Current Ck
   double res=m_Calc_miniTR(miniTRID,t);

   return((ENUM_CK_SIGNALS)res);
  }
//+------------------------------------------------------------------+
