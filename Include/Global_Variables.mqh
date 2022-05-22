//+------------------------------------------------------------------+
//|                                             global_variables.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"

int TF[10] = {0,1,5,15,30,60,240,1440,10080,43200};
//int TF[15] = {0,1,5,15,30,60,120,180,240,360,480,720,1440,10080,43200};
ENUM_TIMEFRAMES ENUM_TF[10] = {PERIOD_CURRENT,PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
string TF_Label[10]={"Current TF","M1","M5","M15","M30","H1","H4","D1","W1","MN1"};
//string TF_Label[15]={"Current TF","M1","M5","M15","M30","H1","H2","H3","H4","H6","H8","H12","D1","W1","MN1"};
int AverageDaysPeriod[10]={0,30,60,90,180,360,360,360,720,720};

enum TF_Index{
   TF_M1=1,
   TF_M5=2,
   TF_M15=3,
   TF_M30=4,
   TF_H1=5,
   TF_H4=6,
   TF_D1=7,
   TF_W1=8,
   TF_MN1=9
};

string Symbols[];
string iSymbol;
string CurrentFunction;
double First_MACD_Trend,Last_MACD_Trend[TF_W1+1],MaxMACD_Trend[TF_W1+1];
string Order_Trend;    
double Order_Profit;  
datetime Order_Open_Time;
string BBollinger_TF[TF_D1+1],Signal[TF_W1+1];
string Vars_BBollinger[TF_D1+1],Vars_MACD_Trend_By_Change[TF_W1+1];
string W1Trend,D1Trend,H4Trend,H1Trend,M30Trend,M15Trend;
int MACD_Close_FastEMAPeriod=20,MACD_Close_SlowEMAPeriod=60,MACD_Close_SignalLinePeriod=6;
int CountPeriodsTrend[TF_W1+1],CountPeriodsD1ofW1,CountPeriodsH4ofD1,CountPeriodsH1ofH4,CountPeriodsH4ofD1_PrevPeriodsH4,CountPeriodsH1ofH4_PrevPeriodsH1;
string MFI_Trend[TF_W1+1],RSI_Trend[TF_W1+1];
double MFITotal[TF_W1+1],MFILastPeriod[TF_W1+1];
double RSITotal[TF_W1+1],RSILastPeriod[TF_W1+1];
bool _CheckZigZag;
bool UnderLimitBuy,OverLimitSell;
double D1_Limit_RSI,H4_Limit_RSI,H4_Limit_Up,H4_Limit_Down,D1_Limit_Up,D1_Limit_Down;
bool OpenBuy,OpenSell;
string MACD_Trend[TF_W1+1],Trends[];
int FastEMAPeriod,SlowEMAPeriod,SignalLinePeriod,Get_MACD_TF;
int Count_Temp;
string StartedSymbols[];
bool ForceH4Trend;