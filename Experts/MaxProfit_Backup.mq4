//+------------------------------------------------------------------+
//|                                                    MaxProfit.mq4 |
//|                                               Xantrum Solutions. |
//|                                    https://www.xantrum.solutions |
//+------------------------------------------------------------------+
#property description "Max Profit Expert Advisor"
#property copyright "Xantrum Solutions 2017-12-15"
#property link      "https://www.xantrum.solutions"
#property version   "1.7"
#include <stdlib.mqh>
#include <stderror.mqh>
#include "../Include/Global_Variables.mqh"
#include "../Include/hash_functions.mqh"
#include "../Include/Math_functions.mqh"
#include "../Include/MACD_functions.mqh"
//#include "../Include/MACD_Trend.mqh"
#include "../Include/SAR_Trend.mqh"
#include "../Include/Symbol_functions.mqh"
#include "../Include/Security_functions.mqh"
#include "../Include/Display_functions.mqh"
#include "../Include/Orders.mqh"
#include "../Include/Lot_functions.mqh"
//#include "../Include/LoadHistoryData.mqh"
//#include "../Include/PeriodConverter_H2H3H6H8H12.mqh"

//--- Inputs
extern const string EA_Period = "M1";
extern bool Maximum_Lot  = false;
extern bool Confirm_Order=false;
extern bool Use_TakeProfit=false;


string EA_Name = "Max Profit";
int MAGICMA = 333777;
double TakeProfit;
double StopLoss;

int MACD_TF;

int MACD_Short_FastEMAPeriod=3;
int MACD_Short_SlowEMAPeriod=60;
int MACD_Short_SignalLinePeriod=3;

int MACD_Long_FastEMAPeriod=7;
int MACD_Long_SlowEMAPeriod=18;
int MACD_Long_SignalLinePeriod=7;

int MACD_NewTrend_FastEMAPeriod=40;
int MACD_NewTrend_SlowEMAPeriod=180;
int MACD_NewTrend_SignalLinePeriod=9;
int MACD_NewTrendH1_SignalLinePeriod=12;

int MACD_Close_FastEMAPeriod=20;
int MACD_Close_SlowEMAPeriod=60;
int MACD_Close_SignalLinePeriod=6;

int MinMACDPeriod;
int MaxMACDPeriod;
int Order_Ticket;
double MinStopLevel;
string Vars_MA_Trend;
string Vars_ShortTrend;
double PriceStopLoss;
double PriceTakeProfit;
int Count_Period_Up, Count_Period_Down;
string NewTrend_TF[TF_H4+1];
string ShortTrend_TF[TF_H4+1];
string BBollinger_TF[TF_H4+1];
string RSI_TF[TF_H4+1];
string RVI_TF[TF_H4+1];
string SAR_TF[TF_H4+1];
string Vars_MACD_NewTrend[TF_H4+1],Vars_MACD_ShortTrend[TF_H4+1],Vars_BBollinger[TF_H4+1],Vars_RSI[TF_H4+1],Vars_RVI[TF_H4+1],Vars_SAR[TF_H4+1],Vars_SAR_Trend_By_Change[TF_W1+1];
Orders objOrders();
datetime TimeInit;
string iSymbol;
bool PrintSymbols=false;
int CountPeriodsTrend[TF_W1+1];
string RSI_Trend[TF_D1+1],Stochastic_Trend[TF_D1+1];
string PreviousH4Trend="Ranging";
datetime DateTime_Symbols;
string W1Trend,W1SARTrend,W1ChangeTrend,D1Trend,D1ShortTrend,H4Trend,H4SARTrend,H1Trend,M30Trend,M15Trend;
double First_MACD_Trend,Last_MACD_Trend[TF_W1+1],MaxMACD_Trend[TF_W1+1];
int Max_TF,Min_TF,Close_TF;
string CurrentFunction;
bool UnderLimitBuy,OverLimitSell,CoverTrendUp[TF_H4+1],CoverTrendDown[TF_H4+1];
double MFI_H4,MFI_D1;
string MACDTrend[TF_D1+1];
bool H4Signal;
string Order_Trend;    
double Order_Profit;  
int Minutes;
string Trends[];
bool FirstDay;

void OnInit(){
   if(!IsTesting()){ 
      for(int i=0;i<10;i++){
         if(EventSetTimer(60*1)==true)
            break;
      }
   }
   TimeInit=TimeCurrent();
   //LoadHistoryData();
   SymbolsList(true);
   objOrders.ImportOrders();
   ShowMessages();
   //Print("UsedLots(false)<TotalLot()=",UsedLots(false),"<",TotalLot());
   //Print("UsedLots(true)<MaxLot()=",UsedLots(true),"<",MaxLot());
   //Print("MinLot=",MarketInfo(iSymbol,MODE_MINLOT),", MaxLot=",MarketInfo(iSymbol,MODE_MAXLOT));
   Print("Spread=",Bid-Ask,", AverageH4Spread=",AverageSpreadNumPeriod(TF_H4,1));
}  

/*double OnTester(){
   return 0;
}*/

void OnTimer(){
   if(IsTesting()==false){
      ProcessTick();
      ShowMessages();
   }
}

void OnTick(){
   
   if(iVolume(Symbol(),Period(),0)>1) return;   
   
   if(IsTesting()==true){
      if(CurrentTimeFrame()>TF_M15)//M1, M5 or M15
         Print("Change Period to M1, M5 or M15");
      ProcessTick();
      //Test();
   }
}

void OnChartEvent(const int id,const long& lparam,const double& dparam,const string& sparam){
   if(id==CHARTEVENT_CHART_CHANGE)
      ShowMessages();
}

void OnDeinit(const int reason)
{
   ModifyTakeProfit();
   DeleteMessages();
   EventKillTimer();
   Print("AccountBalance=",AccountBalance(),", AccountProfit=",AccountProfit());   
   
}


void ProcessTick(){
   //Print("ProcessTick()");
   //--- check for history and trading
   if(IsTradeAllowed()==false /*|| ChkS3c()==false*/) return;
   //if(MarketInfo(iSymbol,MODE_TRADEALLOWED)==false) return;
   
   CheckForClose();
   
   string strSymbols="";
   int CountSymbols;
   CountSymbols=SymbolsList(true);
   //Print("CountSymbols=",CountSymbols);
   if(CountSymbols>0){
      for(int i=0;i<ArraySize(Symbols);i++){
         iSymbol=Symbols[i];
         //if(iBars(iSymbol,PERIOD_M1)<PERIOD_D1) return;
         strSymbols = i==0? iSymbol : StringConcatenate(strSymbols,",",iSymbol);
         
         //init_PeriodConverter();         
         //start_PeriodConverter();
         CheckForOpen();
         //Print("Tick Error ",GetLastError());
      }
      if(PrintSymbols==false){
         Print("Symbols=",strSymbols,", CountSymbols=",CountSymbols);
         PrintSymbols=true;
      }
    }else{
      PrintError(StringConcatenate("CountSymbols=",CountSymbols),GetLastError());
    }
   
}

  
bool IsFastTrend(int _MACD_TF=TF_H1){
   string TF_Trend;
   switch(_MACD_TF){
      case TF_H1: TF_Trend=H1Trend; break; 
      case TF_H4: TF_Trend=H4Trend; break; 
      case TF_D1: TF_Trend=D1Trend; break; 
   }
   //int CountPeriods=CountPeriodTrend(TF_Trend,_MACD_TF,MACD_Short_FastEMAPeriod,MACD_Long_SlowEMAPeriod,MACD_Short_SignalLinePeriod,First_MACD_Trend,0);
   
   double ChangeTrend,MinChangeTrend;
   Last_MACD_Trend[_MACD_TF]=iMACD(iSymbol,TF[_MACD_TF],MACD_Close_FastEMAPeriod,MACD_Close_SlowEMAPeriod,MACD_Close_SignalLinePeriod,PRICE_CLOSE,MODE_MAIN,0);
   MaxMACD_Trend[_MACD_TF]=MaxMACDCloseTrend(_MACD_TF);
   bool IsFastTrend;
   if(H4Trend==TF_Trend && ((TF_Trend=="Up" && Last_MACD_Trend[_MACD_TF]<MaxMACD_Trend[_MACD_TF]*0.6) || 
                            (TF_Trend=="Down" && Last_MACD_Trend[_MACD_TF]>-MaxMACD_Trend[_MACD_TF]*0.6)))
      IsFastTrend=true;
   else
      IsFastTrend=false;   
   
   int Periods;
   int CountPeriods=_MACD_TF<=TF_H4? 4 : 2;   
   double Percentage=_MACD_TF<=TF_H4? 1.5 : 0.7; 
     
   for(int i=2;i<=CountPeriods;i++){
      Periods=i<CountPeriods? 2 : 1;
      ChangeTrend=PeriodChange(_MACD_TF,Periods,CountPeriods-i);
      MinChangeTrend=AveragePeriodChange(_MACD_TF,Periods)*Percentage;
      if(TF_Trend=="Up")   
         IsFastTrend=IsFastTrend && ChangeTrend>=MinChangeTrend;
      if(TF_Trend=="Down")   
         IsFastTrend=IsFastTrend && ChangeTrend<=-MinChangeTrend;   
   }
   //if(IsFastTrend==true)
      //Print("IsFastTrend: CountPeriods=",CountPeriods,", ChangeTrend=",ChangeTrend,", MinChangeTrend=",MinChangeTrend);   
   return IsFastTrend;
}
 

void MACD_NewTrend(){
   double ShortChange,MinChangeNewTrend;
   int TotalPeriodsNewTrend,CountPeriodsNewTrend,CountPeriodsShortTrend,PreviousPeriodsNewTrend,CountPeriodsMACDTrend,MaxPeriodsNewTrend;
   string ShortTrend,CompareChange;
           
   for(MACD_TF=TF_M5;MACD_TF<=TF_H4;MACD_TF++){
      NewTrend_TF[MACD_TF]="Ranging";
      
      ShortTrend=MACD_Long_Trend(MACD_TF-1,1,1000,MACD_Short_FastEMAPeriod,MACD_Long_SlowEMAPeriod,MACD_Short_SignalLinePeriod);
                  
      //Trend Up
      
      MaxPeriodsNewTrend=MACD_TF<TF_H4? 12 : 4;
      
      if(MACD_TF==TF_H4 && H4Signal==false) continue;
            
      if(CoverTrendUp[MACD_TF]==true && UnderLimitBuy==true && MACDTrend[MACD_TF]=="Up" && ShortTrend=="Up"){
         
         TotalPeriodsNewTrend=CountPeriodTrend("Up",TF[MACD_TF],MACD_Close_FastEMAPeriod,MACD_Close_SlowEMAPeriod,MACD_Close_SignalLinePeriod,First_MACD_Trend,0);
                  
         CountPeriodsNewTrend=0;
         
         if(TotalPeriodsNewTrend>=1 && TotalPeriodsNewTrend<=MaxPeriodsNewTrend){
            
            if(objOrders.BeginTrend(iSymbol,OP_BUY,CountPeriodsMACDTrend)==true){ 
               
               CountPeriodsShortTrend=CountPeriodTrend("Up",TF[MACD_TF],MACD_Long_FastEMAPeriod,MACD_Long_SlowEMAPeriod,MACD_Long_SignalLinePeriod,First_MACD_Trend,0);
               if(CountPeriodsShortTrend>TotalPeriodsNewTrend) PreviousPeriodsNewTrend=CountPeriodsShortTrend-TotalPeriodsNewTrend;
               else PreviousPeriodsNewTrend=0;
                           
               ShortChange=PeriodChange(MACD_TF,(PreviousPeriodsNewTrend+TotalPeriodsNewTrend));
               MinChangeNewTrend=AveragePeriodChange(MACD_TF,(PreviousPeriodsNewTrend+TotalPeriodsNewTrend))*(Last_MACD_Trend[TF_H4]<=0? 0.7 : 1);   
               if(ShortChange>=MinChangeNewTrend){
                  CountPeriodsNewTrend++;
                  CompareChange=StringConcatenate("ShortChange>=MinChangeNewTrend=",ShortChange,">=",MinChangeNewTrend);
               }
            
            }
         
         }
         
         //Vars_MACD_NewTrend[MACD_TF]=StringConcatenate("MACD_NewTrend=Up, TF[MACD_TF]=",TF[MACD_TF],", TotalPeriodsNewTrend=",TotalPeriodsNewTrend,", CountPeriodsNewTrend=",CountPeriodsNewTrend,", CountPeriodsShortTrend=",CountPeriodsShortTrend,", ",CompareChange);
         
         if(CountPeriodsNewTrend==1 && !Jump("Up",TF[MACD_TF],TotalPeriodsNewTrend+PreviousPeriodsNewTrend) && IsNewTrend("Up",TotalPeriodsNewTrend)==true){
            NewTrend_TF[MACD_TF]="Up";
            Vars_MACD_NewTrend[MACD_TF]=StringConcatenate("MACD_NewTrend=Up, TF[MACD_TF]=",TF[MACD_TF],", TotalPeriodsNewTrend=",TotalPeriodsNewTrend,", PreviousPeriodsNewTrend=",PreviousPeriodsNewTrend,", CountPeriodsNewTrend=",CountPeriodsNewTrend,", ",CompareChange);
         }   
         
      }else if(CoverTrendDown[MACD_TF]==true && OverLimitSell==true && MACDTrend[MACD_TF]=="Down" && ShortTrend=="Down"){
         
         //Trend Down
         
         TotalPeriodsNewTrend=CountPeriodTrend("Down",TF[MACD_TF],MACD_Close_FastEMAPeriod,MACD_Close_SlowEMAPeriod,MACD_Close_SignalLinePeriod,First_MACD_Trend,0);
            
         CountPeriodsNewTrend=0;
      
         if(TotalPeriodsNewTrend>=1 && TotalPeriodsNewTrend<=MaxPeriodsNewTrend){ 
                           
            if(objOrders.BeginTrend(iSymbol,OP_SELL,CountPeriodsMACDTrend)==true){ 
               
               CountPeriodsShortTrend=CountPeriodTrend("Down",TF[MACD_TF],MACD_Long_FastEMAPeriod,MACD_Long_SlowEMAPeriod,MACD_Long_SignalLinePeriod,First_MACD_Trend,0);
            
               if(CountPeriodsShortTrend>TotalPeriodsNewTrend) PreviousPeriodsNewTrend=CountPeriodsShortTrend-TotalPeriodsNewTrend;
               else PreviousPeriodsNewTrend=0;
               
               ShortChange=PeriodChange(MACD_TF,(PreviousPeriodsNewTrend+TotalPeriodsNewTrend));
               MinChangeNewTrend=AveragePeriodChange(MACD_TF,(PreviousPeriodsNewTrend+TotalPeriodsNewTrend))*(Last_MACD_Trend[TF_H4]>=0? 0.7 : 1);   
               if(ShortChange<=-MinChangeNewTrend){
                  CountPeriodsNewTrend++;
                  CompareChange=StringConcatenate("ShortChange<=-MinChangeNewTrend=",ShortChange,"<=",-MinChangeNewTrend);
               }   
               
            }
         }
      
         //Vars_MACD_NewTrend[MACD_TF]=StringConcatenate("MACD_NewTrend=Down, TF[MACD_TF]=",TF[MACD_TF],", TotalPeriodsNewTrend=",TotalPeriodsNewTrend,", CountPeriodsNewTrend=",CountPeriodsNewTrend,", CountPeriodsShortTrend=",CountPeriodsShortTrend,", ",CompareChange);               
         
         if(CountPeriodsNewTrend==1 && !Jump("Down",TF[MACD_TF],TotalPeriodsNewTrend+PreviousPeriodsNewTrend) && IsNewTrend("Down",TotalPeriodsNewTrend)==true){
            NewTrend_TF[MACD_TF]="Down";
            Vars_MACD_NewTrend[MACD_TF]=StringConcatenate("MACD_NewTrend=Down, TF[MACD_TF]=",TF[MACD_TF],", TotalPeriodsNewTrend=",TotalPeriodsNewTrend,", PreviousPeriodsNewTrend=",PreviousPeriodsNewTrend,", CountPeriodsNewTrend=",CountPeriodsNewTrend,", ",CompareChange);               
         }               
      
         
      }//else
      
   }//for

}

void MACD_ShortTrend(){
   int CountPeriodShortTrend,MinPeriodsShortTrend,MaxPeriodsShortTrend;
   double ChangeShortTrend,MinChangeShortTrend; 
      
   for(MACD_TF=TF_M5;MACD_TF<=TF_H4;MACD_TF++){
      ShortTrend_TF[MACD_TF]="Ranging";
      MinPeriodsShortTrend=MACD_TF<=2? 6 : 3;
      MaxPeriodsShortTrend=MACD_TF<6? (int)MathCeil(PERIOD_H4*3/TF[MACD_TF]) : (int)MathCeil(PERIOD_H4*3/TF[MACD_TF]);
      
      if(MACD_TF==TF_H4 && H4Signal==false) continue;
      
      //Trend Up      
      if(CoverTrendUp[MACD_TF]==true && UnderLimitBuy==true && MACDTrend[MACD_TF]=="Up"){
         
         CountPeriodShortTrend=CountPeriodTrend("Up",TF[MACD_TF],MACD_Long_FastEMAPeriod,MACD_Long_SlowEMAPeriod,MACD_Short_SignalLinePeriod,First_MACD_Trend,0);
         
         /*if(CoverTrendUp==true){
            ChangeShortTrend=PeriodChange(MACD_TF,CountPeriodShortTrend);
            MinChangeShortTrend=AveragePeriodChange(MACD_TF,CountPeriodShortTrend)*1.9;
            Vars_MACD_ShortTrend[MACD_TF]=StringConcatenate("MACD_ShortTrend=Up, TF[MACD_TF]=",TF[MACD_TF],", H4Trend=",H4Trend,", M30Trend=",M30Trend,", CountPeriodShortTrend=",CountPeriodShortTrend,", ChangeShortTrend>MinChangeShortTrend, ",ChangeShortTrend,">",MinChangeShortTrend,", Last_MACD_Trend<=MaxMACD=",Last_MACD_Trend,"<=",MaxMACD);      
         }*/
         
         if(CountPeriodShortTrend>=MinPeriodsShortTrend && CountPeriodShortTrend<=MaxPeriodsShortTrend &&  !Jump("Up",TF[MACD_TF],CountPeriodShortTrend) && 
            objOrders.BeginTrend(iSymbol,OP_BUY,CountPeriodsTrend[MACD_TF])==true){
            //Evaluate Force Change
            
            ChangeShortTrend=PeriodChange(MACD_TF,CountPeriodShortTrend);
            MinChangeShortTrend=AveragePeriodChange(MACD_TF,CountPeriodShortTrend,MACD_Long_FastEMAPeriod,MACD_Long_SlowEMAPeriod,MACD_Short_SignalLinePeriod)*(D1Trend!="Up"? 3 : 1.4);
           
               if(ChangeShortTrend>=MinChangeShortTrend && IsShortTrend("Up",CountPeriodShortTrend)==true){
                  ShortTrend_TF[MACD_TF]="Up";
                  Vars_MACD_ShortTrend[MACD_TF]=StringConcatenate("MACD_ShortTrend=Up, TF[MACD_TF]=",TF[MACD_TF],", CountPeriodShortTrend=",CountPeriodShortTrend,", ChangeShortTrend>MinChangeShortTrend, ",ChangeShortTrend,">",MinChangeShortTrend);
               }   
         }     
         
      }else if(CoverTrendDown[MACD_TF]==true && OverLimitSell==true && MACDTrend[MACD_TF]=="Down"){
      
         //Trend Down
                  
         CountPeriodShortTrend=CountPeriodTrend("Down",TF[MACD_TF],MACD_Long_FastEMAPeriod,MACD_Long_SlowEMAPeriod,MACD_Short_SignalLinePeriod,First_MACD_Trend,0);
         
         /*if(CoverTrendDown==true){
            ChangeShortTrend=PeriodChange(MACD_TF,CountPeriodShortTrend);
            MinChangeShortTrend=AveragePeriodChange(MACD_TF,CountPeriodShortTrend)*1.9;   
            Vars_MACD_ShortTrend[MACD_TF]=StringConcatenate("MACD_ShortTrend=Down TF[MACD_TF]=",TF[MACD_TF],", H4Trend=",H4Trend,", CountPeriodShortTrend=",CountPeriodShortTrend,", MaxPeriodsShortTrend=",MaxPeriodsShortTrend,", ChangeShortTrend<-MinChangeShortTrend, ",ChangeShortTrend,"<",-MinChangeShortTrend);
         }*/
                  
         if(CountPeriodShortTrend>=MinPeriodsShortTrend && CountPeriodShortTrend<=MaxPeriodsShortTrend && !Jump("Down",TF[MACD_TF],CountPeriodShortTrend) && 
            objOrders.BeginTrend(iSymbol,OP_SELL,CountPeriodsTrend[MACD_TF])==true){
            //Evaluate Force Change
            ChangeShortTrend=PeriodChange(MACD_TF,CountPeriodShortTrend);
            MinChangeShortTrend=AveragePeriodChange(MACD_TF,CountPeriodShortTrend,MACD_Long_FastEMAPeriod,MACD_Long_SlowEMAPeriod,MACD_Short_SignalLinePeriod)*(D1Trend!="Down"? 3 : 1.4);
            
               if(ChangeShortTrend<=-MinChangeShortTrend && IsShortTrend("Down",CountPeriodShortTrend)==true){
                  ShortTrend_TF[MACD_TF]="Down";
                  Vars_MACD_ShortTrend[MACD_TF]=StringConcatenate("MACD_ShortTrend=Down TF[MACD_TF]=",TF[MACD_TF],", CountPeriodShortTrend=",CountPeriodShortTrend,", ChangeShortTrend<-MinChangeShortTrend, ",ChangeShortTrend,"<",-MinChangeShortTrend);

               }   
   
         }   
           
      }//else
   }

}

void BBollinger(){
   double Band_Lower,Band_Upper,Price,SpreadM5;
   SpreadM5=AverageSpreadNumPeriod(TF_M5,1);
   
   for(MACD_TF=TF_H1;MACD_TF<=TF_H4;MACD_TF++){
      BBollinger_TF[MACD_TF]="Ranging";
      
      //if(MACD_TF==TF_H4 && H4Signal==false) continue;
      
      Price=iClose(iSymbol,TF[MACD_TF],0);
                       
      //Trend Up      
      if(CoverTrendUp[MACD_TF]==true && UnderLimitBuy==true){
         
         Band_Upper=iBands(iSymbol,TF[MACD_TF],6,2,0,PRICE_HIGH,MODE_UPPER,0);
         CountPeriodsTrend[MACD_TF]=CountPeriodTrend("Up",TF[MACD_TF],MACD_Long_FastEMAPeriod,MACD_Long_SlowEMAPeriod,MACD_Short_SignalLinePeriod,First_MACD_Trend,0);
         
         if(Price>Band_Upper+SpreadM5 && IsNewTrend("Up",CountPeriodsTrend[MACD_TF])==true && !Jump("Up",TF[MACD_TF],CountPeriodsTrend[MACD_TF])){
            BBollinger_TF[MACD_TF]="Up";
            Vars_BBollinger[MACD_TF]=StringConcatenate("BBollinger=Up TF[MACD_TF]=",TF[MACD_TF],", Price=",Price,", Band_Upper=",Band_Upper,", SpreadM5=",SpreadM5);
         }   
         
      }else if(CoverTrendDown[MACD_TF]==true && OverLimitSell==true){
      
         //Trend Down
         Band_Lower=iBands(iSymbol,TF[MACD_TF],6,2,0,PRICE_LOW,MODE_LOWER,0);
         CountPeriodsTrend[MACD_TF]=CountPeriodTrend("Down",TF[MACD_TF],MACD_Long_FastEMAPeriod,MACD_Long_SlowEMAPeriod,MACD_Short_SignalLinePeriod,First_MACD_Trend,0);
         
         if(Price<Band_Lower-SpreadM5 && IsNewTrend("Down",CountPeriodsTrend[MACD_TF])==true && !Jump("Down",TF[MACD_TF],CountPeriodsTrend[MACD_TF])){
            BBollinger_TF[MACD_TF]="Down";
            Vars_BBollinger[MACD_TF]=StringConcatenate("BBollinger=Down TF[MACD_TF]=",TF[MACD_TF],", Price=",Price,", Band_Lower=",Band_Lower,", SpreadM5=",SpreadM5);
         }
                             
      }//else
   }

}

void RSI(){
   double RSI,RSI_Up=85,RSI_Down=15;
   int Periods;
   
   for(MACD_TF=TF_M5;MACD_TF<=TF_H4;MACD_TF++){
      RSI_TF[MACD_TF]="Ranging";
            
      if(MACD_TF==TF_H4 && H4Signal==false) continue;
      
      Periods=MACD_TF<=TF_H1? 6 : 4;
      
      RSI=iRSI(iSymbol,TF[MACD_TF],Periods,PRICE_CLOSE,0);
                 
      //Trend Up      
      if(CoverTrendUp[MACD_TF]==true && UnderLimitBuy==true){
          
         CountPeriodsTrend[MACD_TF]=CountPeriodTrend("Up",TF[MACD_TF],MACD_Long_FastEMAPeriod,MACD_Long_SlowEMAPeriod,MACD_Short_SignalLinePeriod,First_MACD_Trend,0);
          
         if(RSI>RSI_Up && IsNewTrend("Up",CountPeriodsTrend[MACD_TF])==true && !Jump("Up",TF[MACD_TF],CountPeriodsTrend[MACD_TF])){
            RSI_TF[MACD_TF]="Up";
            Vars_RSI[MACD_TF]=StringConcatenate("RSI=Up TF[MACD_TF]=",TF[MACD_TF],", RSI=",RSI,", RSI_Up=",RSI_Up);
         }   
         
      }else if(CoverTrendDown[MACD_TF]==true && OverLimitSell==true){
      
         //Trend Down
         
         CountPeriodsTrend[MACD_TF]=CountPeriodTrend("Down",TF[MACD_TF],MACD_Long_FastEMAPeriod,MACD_Long_SlowEMAPeriod,MACD_Short_SignalLinePeriod,First_MACD_Trend,0);
                 
         if(RSI<RSI_Down && IsNewTrend("Down",CountPeriodsTrend[MACD_TF])==true && !Jump("Down",TF[MACD_TF],CountPeriodsTrend[MACD_TF])){
            RSI_TF[MACD_TF]="Down";
            Vars_RSI[MACD_TF]=StringConcatenate("RSI=Down TF[MACD_TF]=",TF[MACD_TF],", RSI=",RSI,", RSI_Down=",RSI_Down);
         }
                             
      }//else
   }

}


void RVI(){
   double RVI_Main,RVI_Signal;
   int RVI_Period;
   
   for(MACD_TF=TF_M5;MACD_TF<=TF_H4;MACD_TF++){
      RVI_TF[MACD_TF]="Ranging";
      
      if(MACD_TF==TF_H4 && H4Signal==false) continue;
      
      RVI_Period=TF[TF_H4]/TF[MACD_TF];
      RVI_Main=iRVI(iSymbol,TF[MACD_TF],RVI_Period,MODE_MAIN,0);
      RVI_Signal=iRVI(iSymbol,TF[MACD_TF],RVI_Period,MODE_SIGNAL,0);
                 
      //Trend Up      
      if(CoverTrendUp[MACD_TF]==true && UnderLimitBuy==true && MACDTrend[MACD_TF]=="Up"){
         
         CountPeriodsTrend[MACD_TF]=CountPeriodTrend("Up",TF[MACD_TF],MACD_Long_FastEMAPeriod,MACD_Long_SlowEMAPeriod,MACD_Short_SignalLinePeriod,First_MACD_Trend,0);
         
         if(RVI_Main>RVI_Signal /*&& IsNewTrend("Up",CountPeriodsTrend[MACD_TF])==true*/ && !Jump("Up",TF[MACD_TF],CountPeriodsTrend[MACD_TF])){
            RVI_TF[MACD_TF]="Up";
            Vars_RVI[MACD_TF]=StringConcatenate("RVI=Up TF[MACD_TF]=",TF[MACD_TF],", RVI_Main=",RVI_Main,", RVI_Signal=",RVI_Signal);
         }   
         
      }else if(CoverTrendDown[MACD_TF]==true && OverLimitSell==true && MACDTrend[MACD_TF]=="Down"){
      
         //Trend Down
         
         CountPeriodsTrend[MACD_TF]=CountPeriodTrend("Down",TF[MACD_TF],MACD_Long_FastEMAPeriod,MACD_Long_SlowEMAPeriod,MACD_Short_SignalLinePeriod,First_MACD_Trend,0);
                  
         if(RVI_Main<RVI_Signal /*&& IsNewTrend("Down",CountPeriodsTrend[MACD_TF])==true*/ && !Jump("Down",TF[MACD_TF],CountPeriodsTrend[MACD_TF])){
            RVI_TF[MACD_TF]="Down";
            Vars_RVI[MACD_TF]=StringConcatenate("RVI=Down TF[MACD_TF]=",TF[MACD_TF],", RVI_Main=",RVI_Main,", RVI_Signal=",RVI_Signal);
         }
                             
      }//else
   }

}

void SAR(){
   double SAR,PrevSAR,Price,PrevPrice;
    
   for(MACD_TF=TF_M5;MACD_TF<=TF_H4;MACD_TF++){
      SAR_TF[MACD_TF]="Ranging";
            
      if(MACD_TF==TF_H4 && H4Signal==false) continue;
                  
      SAR=iSAR(iSymbol,TF[MACD_TF],0.02,0.2,0);
      PrevSAR=iSAR(iSymbol,TF[MACD_TF],0.02,0.2,1);
      Price=iClose(iSymbol,TF[MACD_TF],0);
      PrevPrice=iClose(iSymbol,TF[MACD_TF],1);
                 
      //Trend Up      
      if(CoverTrendUp[MACD_TF]==true && UnderLimitBuy==true){
          
         CountPeriodsTrend[MACD_TF]=CountPeriodTrend("Up",TF[MACD_TF],MACD_Long_FastEMAPeriod,MACD_Long_SlowEMAPeriod,MACD_Short_SignalLinePeriod,First_MACD_Trend,0);
          
         if(SAR<Price && PrevSAR>PrevPrice && !Jump("Up",TF[MACD_TF],CountPeriodsTrend[MACD_TF])){
            SAR_TF[MACD_TF]="Up";
            Vars_SAR[MACD_TF]=StringConcatenate("SAR=Up TF[MACD_TF]=",TF[MACD_TF],", SAR<Price=",SAR,"<",Price,", PrevSAR>PrevPrice",PrevSAR,">",PrevPrice);
         }   
         
      }else if(CoverTrendDown[MACD_TF]==true && OverLimitSell==true){
      
         //Trend Down
         
         CountPeriodsTrend[MACD_TF]=CountPeriodTrend("Down",TF[MACD_TF],MACD_Long_FastEMAPeriod,MACD_Long_SlowEMAPeriod,MACD_Short_SignalLinePeriod,First_MACD_Trend,0);
                 
         if(SAR>Price && PrevSAR<PrevPrice && !Jump("Down",TF[MACD_TF],CountPeriodsTrend[MACD_TF])){
            SAR_TF[MACD_TF]="Down";
            Vars_SAR[MACD_TF]=StringConcatenate("SAR=Down TF[MACD_TF]=",TF[MACD_TF],", SAR>Price=",SAR,">",Price,", PrevSAR<PrevPrice",PrevSAR,"<",PrevPrice);
         }
                             
      }//else
   }

}

void SetTrends(int ShiftM1=0){
   int ShiftW1=MathFloor(ShiftM1/PERIOD_W1);
   int ShiftD1=MathFloor(ShiftM1/PERIOD_D1);
   int ShiftH4=MathFloor(ShiftM1/PERIOD_H4);
   int ShiftH1=MathFloor(ShiftM1/PERIOD_H1);
   int ShiftM30=MathFloor(ShiftM1/PERIOD_M30);
   int ShiftM15=MathFloor(ShiftM1/PERIOD_M15);
   W1Trend=SAR_Trend_By_Change(TF_W1,ShiftW1);
   W1SARTrend=SAR_Trend(TF_W1,1,ShiftW1);
   D1Trend=SAR_Trend_By_Change(TF_D1,ShiftD1);
   H4SARTrend=SAR_Trend(TF_H4,1,ShiftH4);
   H4SARTrend=!Jump(H4SARTrend,TF[TF_H4],1,ShiftH4)? H4SARTrend : "Ranging";
   H4Trend=SAR_Trend_By_Change(TF_H4,ShiftH4);   
   H1Trend=SAR_Trend_By_Change(TF_H1,ShiftH1);
   M30Trend=SAR_Trend_By_Change(TF_M30,ShiftM30);
   M15Trend=MACD_Long_Trend(TF_M15,2,1000,MACD_Short_FastEMAPeriod,MACD_Long_SlowEMAPeriod,MACD_Short_SignalLinePeriod,ShiftM15);
   Last_MACD_Trend[TF_H1]=iMACD(iSymbol,TF[TF_H1],MACD_Close_FastEMAPeriod,MACD_Close_SlowEMAPeriod,MACD_Close_SignalLinePeriod,PRICE_CLOSE,MODE_MAIN,ShiftH1);
   MaxMACD_Trend[TF_H1]=MaxMACDCloseTrend(TF_H1);
   Last_MACD_Trend[TF_H4]=iMACD(iSymbol,TF[TF_H4],MACD_Close_FastEMAPeriod,MACD_Close_SlowEMAPeriod,MACD_Close_SignalLinePeriod,PRICE_CLOSE,MODE_MAIN,ShiftH4);
   MaxMACD_Trend[TF_H4]=MaxMACDCloseTrend(TF_H4);
   Last_MACD_Trend[TF_D1]=iMACD(iSymbol,TF[TF_D1],MACD_Close_FastEMAPeriod,MACD_Close_SlowEMAPeriod,MACD_Close_SignalLinePeriod,PRICE_CLOSE,MODE_MAIN,ShiftD1);
   MaxMACD_Trend[TF_D1]=MaxMACDCloseTrend(TF_D1);
   
   FirstDay=((H4Trend==D1Trend && CountPeriodsTrend[TF_D1]<=2 && CountPeriodsTrend[TF_H4]<9) || (H4Trend!=D1Trend && CountPeriodsTrend[TF_H4]<9)) && H4Trend!=W1Trend; 
   
}

void SetCoverTrend(){
   
   for(MACD_TF=TF_M5;MACD_TF<=TF_H4;MACD_TF++){

      CoverTrendUp[MACD_TF]= ((W1Trend=="Up" && D1Trend!="Down" && H4Trend=="Up") || 
                              (D1Trend=="Up" && H4Trend=="Up" && W1Trend!="Down") || 
                              (H4Trend=="Up" && H1Trend=="Up" && D1Trend!="Down" && W1Trend=="Up") ) 
                              && Stochastic_Trend[TF_D1]=="Up" && H4SARTrend=="Up";
      CoverTrendUp[MACD_TF]= MACD_TF<=TF_M30? CoverTrendUp[MACD_TF] && H1Trend=="Up" && M15Trend=="Up" : CoverTrendUp[MACD_TF];
      
      CoverTrendDown[MACD_TF]=((W1Trend=="Down" && D1Trend!="Up" && H4Trend=="Down") || 
                               (D1Trend=="Down" && H4Trend=="Down" && W1Trend!="Up") || 
                               (H4Trend=="Down" && H1Trend=="Down" && D1Trend!="Up" && W1Trend=="Down") ) 
                               && Stochastic_Trend[TF_D1]=="Down" && H4SARTrend=="Down";
      CoverTrendDown[MACD_TF]= MACD_TF<=TF_M30? CoverTrendDown[MACD_TF] && H1Trend=="Down" && M15Trend=="Down" : CoverTrendDown[MACD_TF];
   }   
   
}

void SetLimits(int ShiftM1=0){
   UnderLimitBuy=true;
   OverLimitSell=true;
   
   double MFI_Up,MFI_Down,MFI_Periods_H4,MFI_Periods_D1;
   int ShiftH4=MathFloor(ShiftM1/PERIOD_H4);
   int ShiftD1=MathFloor(ShiftM1/PERIOD_D1);
   MFI_Periods_H4=12;
   MFI_H4=iMFI(iSymbol,TF[TF_H4],MFI_Periods_H4,ShiftH4);
   MFI_Periods_D1=8;
   MFI_D1=iMFI(iSymbol,TF[TF_D1],MFI_Periods_D1,ShiftD1);
   
   int MinPeriodsH4;
   double Equity=TotalEquity(), MinEquity;
      
   if(H4Trend!="Ranging"){
      
      if(H4Trend!=W1Trend){
         
         MinPeriodsH4=FirstDay==true? 3 : 3;   
         
         MFI_Up=75; MFI_Down=25;
         
         MinEquity=FirstDay==true? 100 : 30;
         
      }else if (H4Trend==W1Trend){
      
         MinPeriodsH4=2;
         
         MFI_Up=80; MFI_Down=20;
         
         MinEquity=1;
      }
      
   }
   
   UnderLimitBuy=UnderLimitBuy && CountPeriodsTrend[TF_H4]>=MinPeriodsH4 && CountPeriodsTrend[TF_H4]<=30;
   OverLimitSell=OverLimitSell && CountPeriodsTrend[TF_H4]>=MinPeriodsH4 && CountPeriodsTrend[TF_H4]<=30;   
      
   UnderLimitBuy=UnderLimitBuy && MFI_H4<MFI_Up && MFI_D1<MFI_Up;
   OverLimitSell=OverLimitSell && MFI_H4>MFI_Down && MFI_D1>MFI_Down;
   
   UnderLimitBuy=UnderLimitBuy && Equity>=MinEquity;
   OverLimitSell=OverLimitSell && Equity>=MinEquity;
   
}

//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
void CheckForOpen()
  {
   
   if(!FreeLots()) return;
   
   int TotalOrders=objOrders.FillOpenOrderList(true);   
   if(TotalOrders>=1) return;
   
   Minutes=(int)((TimeCurrent()-TimeInit)/60);
            
   CurrentFunction="CheckForOpen";
   
   SetTrends();
   SetCoverTrend();
   SetLimits();
         
   for(MACD_TF=TF_M5;MACD_TF<=TF_H4;MACD_TF++){
      NewTrend_TF[MACD_TF]="Ranging";
      ShortTrend_TF[MACD_TF]="Ranging";
      BBollinger_TF[MACD_TF]="Ranging";
      RSI_TF[MACD_TF]="Ranging";
      RVI_TF[MACD_TF]="Ranging";
      SAR_TF[MACD_TF]="Ranging";

      MACDTrend[MACD_TF]=SAR_Trend_By_Change(MACD_TF);
   }   
         
   if(IsTesting()==true && Minutes % PERIOD_H4 == 0 && TotalOrders==0){
      Print("Minutes=",Minutes,", Hours=",(Minutes/60),", Days=",((Minutes/60)/24));
      Print(Vars_SAR_Trend_By_Change[TF_W1]);   
      Print(Vars_SAR_Trend_By_Change[TF_D1]);   
      Print(Vars_SAR_Trend_By_Change[TF_H4]);
      Print(Vars_SAR_Trend_By_Change[TF_H1]);
      Print("W1Trend=",W1Trend,", W1SARTrend=",W1SARTrend,", D1Trend=",D1Trend,", RSI_Trend[TF_D1]=",RSI_Trend[TF_D1],", Stochastic_Trend[TF_D1]=",Stochastic_Trend[TF_D1],", H4Trend=",H4Trend,", H4SARTrend=",H4SARTrend,", H1Trend=",H1Trend,", M30Trend=",M30Trend,", M15Trend=",M15Trend);
      if(H4SARTrend=="Up"){
         Print("CoverTrendUp[TF_H4]=",CoverTrendUp[TF_H4],", CoverTrendUp[TF_H1]=",CoverTrendUp[TF_H1],", CoverTrendUp[TF_M30]=",CoverTrendUp[TF_M30],", CoverTrendUp[TF_M15]=",CoverTrendUp[TF_M15],", CoverTrendUp[TF_M5]=",CoverTrendUp[TF_M5]);
         Print("UnderLimitBuy=",UnderLimitBuy,", CountPeriodsTrend[TF_H4]=",CountPeriodsTrend[TF_H4],", CountPeriodsTrend[TF_D1]=",CountPeriodsTrend[TF_D1]);
      }
      if(H4SARTrend=="Down"){
         Print("CoverTrendDown[TF_H4]=",CoverTrendDown[TF_H4],", CoverTrendDown[TF_H1]=",CoverTrendDown[TF_H1],", CoverTrendDown[TF_M30]=",CoverTrendDown[TF_M30],", CoverTrendDown[TF_M15]=",CoverTrendDown[TF_M15],", CoverTrendDown[TF_M5]=",CoverTrendDown[TF_M5]);
         Print("OverLimitSell=",OverLimitSell,", CountPeriodsTrend[TF_H4]=",CountPeriodsTrend[TF_H4],", CountPeriodsTrend[TF_D1]=",CountPeriodsTrend[TF_D1]);
      }
      //Print("Last_MACD_Trend[TF_H1]=",Last_MACD_Trend[TF_H1],", MaxMACD_Trend[TF_H1]=",MaxMACD_Trend[TF_H1],", Last_MACD_Trend[TF_H4]=",Last_MACD_Trend[TF_H4],", MaxMACD_Trend[TF_H4]=",MaxMACD_Trend[TF_H4]);
      Print("MFI_H4=",MFI_H4,", MFI_D1=",MFI_D1);
      /*Print("NewTrend_TF[TF_H4]=",NewTrend_TF[TF_H4],", NewTrend_TF[TF_H1]=",NewTrend_TF[TF_H1],", NewTrend_TF[TF_M30]=",NewTrend_TF[TF_M30],", NewTrend_TF[TF_M15]=",NewTrend_TF[TF_M15],", NewTrend_TF[TF_M5]=",NewTrend_TF[TF_M5]);
      Print("ShortTrend_TF[TF_H4]=",ShortTrend_TF[TF_H4],", ShortTrend_TF[TF_H1]=",ShortTrend_TF[TF_H1],", ShortTrend_TF[TF_M30]=",ShortTrend_TF[TF_M30],", ShortTrend_TF[TF_M15]=",ShortTrend_TF[TF_M15],", ShortTrend_TF[TF_M5]=",ShortTrend_TF[TF_M5]);
      Print("BBollinger_TF[TF_H4]=",BBollinger_TF[TF_H4],", BBollinger_TF[TF_H1]=",BBollinger_TF[TF_H1],", BBollinger_TF[TF_M30]=",BBollinger_TF[TF_M30],", BBollinger_TF[TF_M15]=",BBollinger_TF[TF_M15],", BBollinger_TF[TF_M5]=",BBollinger_TF[TF_M5]);
      Print("RSI_TF[TF_H4]=",RSI_TF[TF_H4],", RSI_TF[TF_H1]=",RSI_TF[TF_H1],", RSI_TF[TF_M30]=",RSI_TF[TF_M30],", RSI_TF[TF_M15]=",RSI_TF[TF_M15],", RSI_TF[TF_M5]=",RSI_TF[TF_M5]);
      Print("RVI_TF[TF_H4]=",RVI_TF[TF_H4],", RVI_TF[TF_H1]=",RVI_TF[TF_H1],", RVI_TF[TF_M30]=",RVI_TF[TF_M30],", RVI_TF[TF_M15]=",RVI_TF[TF_M15],", RVI_TF[TF_M5]=",RVI_TF[TF_M5]);
      */
   }
   
   bool OpenTrendUp=(CoverTrendUp[TF_H1]==true || CoverTrendUp[TF_M15]==true) && UnderLimitBuy==true;
   bool OpenTrendDown=(CoverTrendDown[TF_H1]==true || CoverTrendDown[TF_M15]==true) && OverLimitSell==true;
   
   if(OpenTrendUp==false && OpenTrendDown==false) return;
      
   
   H4Signal=(H4Trend==H1Trend && IsNewTrend(H4Trend,CountPeriodsTrend[TF_H4],6) && IsConstantTrend(TF_H1,H1Trend,4,2,1.7) && CountPeriodsTrend[TF_D1]==1);
      
   //MACD_ShortTrend();
   //MACD_NewTrend();
   BBollinger();
   //RSI();
   //RVI();
   //SAR();
            
   double Order_Lots,Order_Open_Price;      
                  
   for(MACD_TF=TF_H4;MACD_TF>=TF_M5;MACD_TF--){
      
      while(NewTrend_TF[MACD_TF]!="Ranging" || ShortTrend_TF[MACD_TF]!="Ranging" || BBollinger_TF[MACD_TF]!="Ranging" || RSI_TF[MACD_TF]!="Ranging" || RVI_TF[MACD_TF]!="Ranging" || SAR_TF[MACD_TF]!="Ranging"){
      
         if(!FreeLots()) return;
      
         if(NewTrend_TF[MACD_TF]=="Up" || ShortTrend_TF[MACD_TF]=="Up" || BBollinger_TF[MACD_TF]=="Up" || RSI_TF[MACD_TF]=="Up" || RVI_TF[MACD_TF]=="Up" || SAR_TF[MACD_TF]=="Up")
         {
               CalculateStopLoss(TF[MACD_TF],"Up");
               PriceStopLoss=NormalizeDouble(MarketInfo(iSymbol,MODE_ASK)-StopLoss,MarketInfo(iSymbol,MODE_DIGITS));  
                              
               if(TakeProfit>0){      
                  PriceTakeProfit=NormalizeDouble(MarketInfo(iSymbol,MODE_ASK)+TakeProfit,MarketInfo(iSymbol,MODE_DIGITS));
               }
               else{
                  PriceTakeProfit=0;
               }   
               
               Order_Lots=Lots();
               
               if(Order_Lots<MarketInfo(iSymbol,MODE_MINLOT))
                  return;
               
               Order_Open_Price=MarketInfo(iSymbol,MODE_ASK);
               
               if(MsgConfirmOrder("Up")==false) return;
                                 
               Order_Ticket=OrderSend(iSymbol,OP_BUY,Order_Lots,Order_Open_Price,2,PriceStopLoss,PriceTakeProfit,EA_Name,MAGICMA,0,Green);
               
               if(Order_Ticket>0){
                  objOrders.Agregar(iSymbol,MACD_TF,Order_Ticket,OP_BUY,TimeCurrent(),Order_Open_Price,Order_Lots,PriceStopLoss,PriceTakeProfit,Last_MACD_Trend[TF_H4]);
               }else{         
                  PrintError(StringConcatenate("OrderSend ",iSymbol,": "),GetLastError());
               }  
               Print("OrderSend ",iSymbol,": OrderType=OP_SELL, TF=",TF[MACD_TF],", Order_Open_Price=",Order_Open_Price,", Order_Lots=",Order_Lots,", PriceStopLoss=",PriceStopLoss,", PriceTakeProfit=",PriceTakeProfit,", FreeLots=",FreeLots());
               Print("TotalLot=",TotalLot(),", MaxLot=",MaxLot(),", MinLot=",MinLot(),", MODE_LOTSIZE=",MarketInfo(iSymbol,MODE_LOTSIZE),", MODE_MAXLOT=",MarketInfo(iSymbol,MODE_MAXLOT),", SYMBOL_VOLUME_STEP=",SymbolInfoDouble(iSymbol,SYMBOL_VOLUME_STEP),", SYMBOL_VOLUME_LIMIT=",SymbolInfoDouble(iSymbol,SYMBOL_VOLUME_LIMIT));

               if(NewTrend_TF[MACD_TF]=="Up"){
                  NewTrend_TF[MACD_TF]="Ranging";
                  Print("Vars_MACD_NewTrend[",MACD_TF,"] = ",Vars_MACD_NewTrend[MACD_TF]);
               }else if(ShortTrend_TF[MACD_TF]=="Up"){ 
                  ShortTrend_TF[MACD_TF]="Ranging";
                  Print("Vars_MACD_ShortTrend[",MACD_TF,"] = ",Vars_MACD_ShortTrend[MACD_TF]);  
               }else if(BBollinger_TF[MACD_TF]=="Up"){ 
                  BBollinger_TF[MACD_TF]="Ranging";
                  Print("Vars_BBollinger[",MACD_TF,"] = ",Vars_BBollinger[MACD_TF]);  
               }else if(RSI_TF[MACD_TF]=="Up"){ 
                  RSI_TF[MACD_TF]="Ranging";
                  Print("Vars_RSI[",MACD_TF,"] = ",Vars_RSI[MACD_TF]);  
               }else if(RVI_TF[MACD_TF]=="Up"){ 
                  RVI_TF[MACD_TF]="Ranging";
                  Print("Vars_RVI[",MACD_TF,"] = ",Vars_RVI[MACD_TF]);  
               }else if(SAR_TF[MACD_TF]=="Up"){ 
                  SAR_TF[MACD_TF]="Ranging";
                  Print("Vars_SAR[",MACD_TF,"] = ",Vars_SAR[MACD_TF]);  
               }
               Print(objOrders.Vars_BeginTrend[MACD_TF]);  
               //Print("Last_MACD_Trend[TF_H1]=",Last_MACD_Trend[TF_H1],", MaxMACD_Trend[TF_H1]=",MaxMACD_Trend[TF_H1],", Last_MACD_Trend[TF_H4]=",Last_MACD_Trend[TF_H4],", MaxMACD_Trend[TF_H4]=",MaxMACD_Trend[TF_H4]);
               Print("CoverTrendUp[",MACD_TF,"]=",CoverTrendUp[MACD_TF],", UnderLimitBuy=",UnderLimitBuy);
               Print("MFI_H4=",MFI_H4,", MFI_D1=",MFI_D1);
               Print(Vars_SAR_Trend_By_Change[TF_M30]);   
               Print(Vars_SAR_Trend_By_Change[TF_H1]);   
               Print(Vars_SAR_Trend_By_Change[TF_H4]);
               Print(Vars_SAR_Trend_By_Change[TF_D1]);   
               Print(Vars_SAR_Trend_By_Change[TF_W1]);   
               Print("W1Trend=",W1Trend,", W1SARTrend=",W1SARTrend,", D1Trend=",D1Trend,", RSI_Trend[TF_D1]=",RSI_Trend[TF_D1],", Stochastic_Trend[TF_D1]=",Stochastic_Trend[TF_D1],", H4Trend=",H4Trend,", H4SARTrend=",H4SARTrend,", H1Trend=",H1Trend,", M30Trend=",M30Trend,", M15Trend=",M15Trend);
               
               
         }
         else if(NewTrend_TF[MACD_TF]=="Down" || ShortTrend_TF[MACD_TF]=="Down" || BBollinger_TF[MACD_TF]=="Down" || RSI_TF[MACD_TF]=="Down" || RVI_TF[MACD_TF]=="Down" || SAR_TF[MACD_TF]=="Down")
         {
                  CalculateStopLoss(TF[MACD_TF],"Down");
                  PriceStopLoss=NormalizeDouble(MarketInfo(iSymbol,MODE_BID)+StopLoss,MarketInfo(iSymbol,MODE_DIGITS)); 
                  
                  if(TakeProfit>0){            
                     PriceTakeProfit=NormalizeDouble(MarketInfo(iSymbol,MODE_BID)-TakeProfit,MarketInfo(iSymbol,MODE_DIGITS));
                  }
                  else{
                     PriceTakeProfit=0;
                  }
                  
                  Order_Lots=Lots();
                  
                  if(Order_Lots<MarketInfo(iSymbol,MODE_MINLOT))
                     return;
                  
                  Order_Open_Price=MarketInfo(iSymbol,MODE_BID);
                           
                  if(MsgConfirmOrder("Down")==false) return;
                                    
                  Order_Ticket=OrderSend(iSymbol,OP_SELL,Order_Lots,Order_Open_Price,2,PriceStopLoss,PriceTakeProfit,EA_Name,MAGICMA,0,Red);
                  
                  if(Order_Ticket>0){
                     objOrders.Agregar(iSymbol,MACD_TF,Order_Ticket,OP_SELL,TimeCurrent(),Order_Open_Price,Order_Lots,PriceStopLoss,PriceTakeProfit,Last_MACD_Trend[TF_H4]);
                     //objOrders.PrintOrders();
                  }else{
                     PrintError(StringConcatenate("OrderSend ",iSymbol,": "),GetLastError());
                  }
                  Print("OrderSend ",iSymbol,": OrderType=OP_SELL, TF=",TF[MACD_TF],", Order_Open_Price=",Order_Open_Price,", Order_Lots=",Order_Lots,", PriceStopLoss=",PriceStopLoss,", PriceTakeProfit=",PriceTakeProfit,", FreeLots=",FreeLots());
                  Print("TotalLot=",TotalLot(),", MaxLot=",MaxLot(),", MinLot=",MinLot(),", MODE_LOTSIZE=",MarketInfo(iSymbol,MODE_LOTSIZE),", MODE_MAXLOT=",MarketInfo(iSymbol,MODE_MAXLOT),", SYMBOL_VOLUME_STEP=",SymbolInfoDouble(iSymbol,SYMBOL_VOLUME_STEP),", SYMBOL_VOLUME_LIMIT=",SymbolInfoDouble(iSymbol,SYMBOL_VOLUME_LIMIT));

                  
                  if(NewTrend_TF[MACD_TF]=="Down"){
                     NewTrend_TF[MACD_TF]="Ranging";
                     Print("Vars_MACD_NewTrend[",MACD_TF,"] = ",Vars_MACD_NewTrend[MACD_TF]);
                  }else if(ShortTrend_TF[MACD_TF]=="Down"){ 
                     ShortTrend_TF[MACD_TF]="Ranging";
                     Print("Vars_MACD_ShortTrend[",MACD_TF,"] = ",Vars_MACD_ShortTrend[MACD_TF]);  
                  }else if(BBollinger_TF[MACD_TF]=="Down"){ 
                     BBollinger_TF[MACD_TF]="Ranging";
                     Print("Vars_BBollinger[",MACD_TF,"] = ",Vars_BBollinger[MACD_TF]);  
                  }else if(RSI_TF[MACD_TF]=="Down"){ 
                     RSI_TF[MACD_TF]="Ranging";
                     Print("Vars_RSI[",MACD_TF,"] = ",Vars_RSI[MACD_TF]);  
                  }else if(RVI_TF[MACD_TF]=="Down"){ 
                     RVI_TF[MACD_TF]="Ranging";
                     Print("Vars_RVI[",MACD_TF,"] = ",Vars_RVI[MACD_TF]);  
                  }else if(SAR_TF[MACD_TF]=="Down"){ 
                     SAR_TF[MACD_TF]="Ranging";
                     Print("Vars_SAR[",MACD_TF,"] = ",Vars_SAR[MACD_TF]);  
                  }
                  Print(objOrders.Vars_BeginTrend[MACD_TF]);     
                  //Print("Last_MACD_Trend[TF_H1]=",Last_MACD_Trend[TF_H1],", MaxMACD_Trend[TF_H1]=",MaxMACD_Trend[TF_H1],", Last_MACD_Trend[TF_H4]=",Last_MACD_Trend[TF_H4],", MaxMACD_Trend[TF_H4]=",MaxMACD_Trend[TF_H4]);
                  Print("CoverTrendDown[",MACD_TF,"]=",CoverTrendDown[MACD_TF],", OverLimitSell=",OverLimitSell);
                  Print("MFI_H4=",MFI_H4,", MFI_D1=",MFI_D1);
                  Print(Vars_SAR_Trend_By_Change[TF_M30]);   
                  Print(Vars_SAR_Trend_By_Change[TF_H1]);   
                  Print(Vars_SAR_Trend_By_Change[TF_H4]);
                  Print(Vars_SAR_Trend_By_Change[TF_D1]);   
                  Print(Vars_SAR_Trend_By_Change[TF_W1]);   
                  Print("W1Trend=",W1Trend,", W1SARTrend=",W1SARTrend,", D1Trend=",D1Trend,", RSI_Trend[TF_D1]=",RSI_Trend[TF_D1],", Stochastic_Trend[TF_D1]=",Stochastic_Trend[TF_D1],", H4Trend=",H4Trend,", H4SARTrend=",H4SARTrend,", H1Trend=",H1Trend,", M30Trend=",M30Trend,", M15Trend=",M15Trend);
         }//else
      }//while
   }//for i       
//---
}
//+------------------------------------------------------------------+
//| Check for close order conditions                                 |
//+------------------------------------------------------------------+
void CheckForClose()
  {
//---
   CurrentFunction="CheckForClose";
   string ShortTrend,LongTrend,MaxTrend,MinTrend;//,CloseTrend,NewTrend[8];
   double Price,W1Change,AverageW1Change,OrderSpread,AverageSpreadH8,AverageSpreadD1;//Commision,,H4Change;
   bool TicketOpened;//,PriceOK;
   int i,MinutesOpened/*,Long_TF*/,Error,TotalOrders;//,ClosePeriods;
   Order *OpenOrder;
   objOrders.ImportOrders();
   TotalOrders=objOrders.FillOpenOrderList();
  
            
                        
   for(i=TotalOrders-1;i>=0;i--)
     {
      //objOrders.PrintOrders();
      OpenOrder=objOrders.OpenOrderList[i];
      Order_Ticket=OpenOrder.Order_Ticket;
      
      if(OrderSelect(OpenOrder.Order_Ticket,SELECT_BY_TICKET,MODE_TRADES)==true && OpenOrder.Closed==False){
         
         TicketOpened=true; 
         
         MinutesOpened=(TimeCurrent()-OpenOrder.Order_Open_Time)/60;
         
         //--- check order type 
         if(TicketOpened==true && MinutesOpened>=60){
         
            iSymbol=OpenOrder.Order_Symbol;
            
            MACD_TF=OpenOrder.MACD_TF;
            
            Order_Trend=OpenOrder.Order_Trend;
            Order_Profit=OpenOrder.Order_Profit();
            
            SetTrends();
            SetCoverTrend();
            SetLimits();
   
            Price=OrderType()==OP_BUY? MarketInfo(iSymbol,MODE_BID) : MarketInfo(iSymbol,MODE_ASK);
            
            W1Change=PeriodChange(TF_D1,3);
            AverageW1Change=FormatDecimals(AveragePeriodChange(TF_D1,3)*-1,2);
            OrderSpread=Price-OpenOrder.Order_Open_Price;
            AverageSpreadH8=AverageSpreadNumPeriod(TF_H4,2);
            AverageSpreadD1=AverageSpreadNumPeriod(TF_D1,1);
            
            Minutes=(int)((TimeCurrent()-TimeInit)/60);
            if(IsTesting()==true && Minutes % PERIOD_H4 == 0){
               Print("Minutes=",Minutes,", Hours=",(Minutes/60),", Days=",((Minutes/60)/24));
               Print("Order_Ticket=",Order_Ticket,", OrderType=",OrderType(),", Order_Profit=",OpenOrder.Order_Profit(),", Price=",Price,",OrderSpread=",OrderSpread,", AverageSpreadH8=",AverageSpreadH8,", AverageSpreadD1=",AverageSpreadD1);
               Print(Vars_SAR_Trend_By_Change[TF_W1]);   
               Print(Vars_SAR_Trend_By_Change[TF_D1]);   
               Print(Vars_SAR_Trend_By_Change[TF_H4]);
               Print(Vars_SAR_Trend_By_Change[TF_H1]);
               Print(Vars_SAR_Trend_By_Change[TF_M30]);
               Print("W1Trend=",W1Trend,", W1SARTrend=",W1SARTrend,", D1Trend=",D1Trend,", RSI_Trend[TF_D1]=",RSI_Trend[TF_D1],", Stochastic_Trend[TF_D1]=",Stochastic_Trend[TF_D1],", H4Trend=",H4Trend,", H4SARTrend=",H4SARTrend,", H1Trend=",H1Trend,", M30Trend=",M30Trend,", M15Trend=",M15Trend);
               Print("MFI_H4=",MFI_H4,", MFI_D1=",MFI_D1);
            }
            
            if((OrderType()==OP_BUY && H4Trend=="Up" && H1Trend=="Up") || (OrderType()==OP_SELL && H4Trend=="Down" && H1Trend=="Down")){
               continue;
            }
            
            
            /*if((OrderType()==OP_BUY && D1Trend=="Up") || (OrderType()==OP_SELL && D1Trend=="Down") || (D1Trend=="Ranging")){
               ClosePeriods=4;
            }else{
               ClosePeriods=1;      
            }   

                        
            CloseTrend="Ranging";
            CloseTrend=H1Trend=="Up" && H4NewTrend=="Up"? "Up":CloseTrend;
            CloseTrend=H1Trend=="Down" && H4NewTrend=="Down"? "Down":CloseTrend;
            */
            
            OverLimitSell=Last_MACD_Trend[TF_H4]>-MaxMACD_Trend[TF_H4]*0.4;
            UnderLimitBuy=Last_MACD_Trend[TF_H4]<MaxMACD_Trend[TF_H4]*0.4;
               
            //Commision=MathAbs(OpenOrder.Order_Commission)+MathAbs(OpenOrder.Order_Swap+MathAbs(Spread));
         
            Close_TF=0;
                                    
            
            for(Max_TF=TF_W1;Max_TF>=TF_M15;Max_TF--){
               Min_TF=Max_TF-1;
               MaxTrend=SAR_Trend_By_Change(Max_TF);
               MinTrend=SAR_Trend_By_Change(Min_TF);
               Last_MACD_Trend[Min_TF]=iMACD(iSymbol,TF[Min_TF],MACD_Close_FastEMAPeriod,MACD_Close_SlowEMAPeriod,MACD_Close_SignalLinePeriod,PRICE_CLOSE,MODE_MAIN,0);
               MaxMACD_Trend[Min_TF]=MaxMACDCloseTrend(Min_TF);            
               //Last_MACD_Trend[Min_TF-1]=iMACD(iSymbol,TF[Min_TF-1],MACD_Close_FastEMAPeriod,MACD_Close_SlowEMAPeriod,MACD_Close_SignalLinePeriod,PRICE_CLOSE,MODE_MAIN,0);
               //MaxMACD_Trend[Min_TF-1]=MaxMACDCloseTrend(Min_TF-1);            
               
               if( (OrderType()==OP_BUY && MaxTrend=="Up" && MinTrend!="Down" && Last_MACD_Trend[Min_TF]<=MaxMACD_Trend[Min_TF]) || 
                   (OrderType()==OP_SELL && MaxTrend=="Down" && MinTrend!="Up" && Last_MACD_Trend[Min_TF]>=-MaxMACD_Trend[Min_TF]) ){
                  Close_TF=Max_TF;
                  break;
               }
               
            }
            
            
            bool Close_W1Trend=((W1Trend=="Up" && W1Change>=AverageW1Change && OrderSpread>=AverageSpreadD1 && OpenOrder.UnderLimitBuy==true) || 
                                (W1Trend=="Down" && W1Change<=-AverageW1Change && OrderSpread<=-AverageSpreadD1 && OpenOrder.OverLimitSell==true));
                                       
            if(Order_Trend==W1Trend &&  Close_W1Trend==true){
                               
                if(OpenOrder.Order_Profit()>=0){
                
                  if( (OrderType()==OP_BUY && H4Trend=="Down" && D1Trend!="Up" && Last_MACD_Trend[TF_H4]>MaxMACD_Trend[TF_H4]*0.6) || 
                      (OrderType()==OP_SELL && H4Trend=="Up" && D1Trend!="Down" && Last_MACD_Trend[TF_H4]<-MaxMACD_Trend[TF_H4]*0.6) ){
                       Close_TF=TF_H4;
                  }
                  
                  if( (OrderType()==OP_BUY && H4Trend=="Down" && D1Trend=="Down" && Last_MACD_Trend[TF_H4]<=MaxMACD_Trend[TF_H4]*0.6) || 
                      (OrderType()==OP_SELL && H4Trend=="Up" && D1Trend=="Up" && Last_MACD_Trend[TF_H4]>=-MaxMACD_Trend[TF_H4]*0.6) ){
                       Close_TF=TF_H4;
                  }
                               
                
                   if( (OrderType()==OP_BUY && M15Trend=="Down" && H4Trend!="Up" && D1Trend!="Up" && Last_MACD_Trend[TF_H4]>MaxMACD_Trend[TF_H4]) || 
                       (OrderType()==OP_SELL && M15Trend=="Up" && H4Trend!="Down" && D1Trend!="Down" && Last_MACD_Trend[TF_H4]<-MaxMACD_Trend[TF_H4]) ){
                        Close_TF=TF_M15;
                   }
                   
                }
                
                if(OpenOrder.Order_Profit()<0){
                
                  if((OrderType()==OP_BUY && Last_MACD_Trend[TF_H4]>MaxMACD_Trend[TF_H4]*0.6 && M15Trend=="Down" && H4Trend!="Up" && D1Trend!="Up") || 
                     (OrderType()==OP_SELL && Last_MACD_Trend[TF_H4]<-MaxMACD_Trend[TF_H4]*0.6 && M15Trend=="Up" && H4Trend!="Down" && D1Trend!="Down") ){
                     Close_TF=TF_M15;
                  }
                  if((OrderType()==OP_BUY && Last_MACD_Trend[TF_H4]<=MaxMACD_Trend[TF_H4]*0.6 && H4Trend=="Down" && D1Trend=="Down") || 
                     (OrderType()==OP_SELL && Last_MACD_Trend[TF_H4]>=-MaxMACD_Trend[TF_H4]*0.6 && H4Trend=="Up" && D1Trend=="Up") ){
                     Close_TF=TF_H4;
                  }
                }
            }
            
            
            if( (Order_Trend!=W1Trend) || (Order_Trend==W1Trend && Close_W1Trend==false) ){
                               
                if(OpenOrder.Order_Profit()>=0){
                  
                   if(MathAbs(OrderSpread)<AverageSpreadH8){
                     
                     D1ShortTrend=SAR_Trend(TF_D1,1,0,iSymbol,0.5,0.5);
                     double RSI_H1,RSI_Up=90,RSI_Down=10,RSI_Periods=4;
                     RSI_H1=iRSI(iSymbol,TF[TF_H1],RSI_Periods,PRICE_CLOSE,0);
                     H4SARTrend=SAR_Trend(TF_H4,1);
                     string H1SARTrend=SAR_Trend(TF_H1,1);
                     
                      if( (OrderType()==OP_BUY && H1SARTrend=="Down" && ((D1ShortTrend=="Down" && H4SARTrend=="Down") || RSI_H1<RSI_Down)) || 
                          (OrderType()==OP_SELL && H1SARTrend=="Up" && ((D1ShortTrend=="Up" && H4SARTrend=="Up") ||  RSI_H1>RSI_Up)) ){
                         Close_TF=TF_M30;
                         Print("D1ShortTrend=",D1ShortTrend,", RSI_H1=",RSI_H1);
                         Print(Vars_SAR_Trend_By_Change[TF_M30]);
                      }
                      
                      if( (OrderType()==OP_BUY && H1Trend=="Down" && CountPeriodsTrend[TF_H1]>=8 && Order_Trend!=W1Trend) || 
                          (OrderType()==OP_SELL && H1Trend=="Up" && CountPeriodsTrend[TF_H1]>=8 && Order_Trend!=W1Trend) ){
                         Close_TF=TF_H1;
                         Print("H1Trend=",H1Trend,", H4Trend=",H4Trend);
                         Print(Vars_SAR_Trend_By_Change[TF_H1]);
                      }
                    
                   }else{
                   
                      if( (OrderType()==OP_BUY && H4Trend=="Down" && D1Trend!="Up") || (OrderType()==OP_SELL && H4Trend=="Up" && D1Trend!="Down") ){
                         Close_TF=TF_H4;
                      }
                                      
                      if( (OrderType()==OP_BUY && M15Trend=="Down" && H4Trend!="Up" && Last_MACD_Trend[TF_H4]>=MaxMACD_Trend[TF_H4]*0.6) || 
                          (OrderType()==OP_SELL && M15Trend=="Up" && H4Trend!="Down" && Last_MACD_Trend[TF_H4]<=-MaxMACD_Trend[TF_H4]*0.6) ){
                           Close_TF=TF_M15;
                      }
                      
                      if( (OrderType()==OP_BUY && H1Trend=="Down" && H4Trend!="Up" && D1Trend!="Up") || 
                          (OrderType()==OP_SELL && H1Trend=="Up" && H4Trend!="Down" && D1Trend!="Down") ){
                           Close_TF=TF_H1;
                      }
                      
                      if( (OrderType()==OP_BUY && M15Trend=="Down" && H1Trend!="Up" && Last_MACD_Trend[TF_H1]>=MaxMACD_Trend[TF_H1]) || 
                          (OrderType()==OP_SELL && M15Trend=="Up" && H1Trend!="Down" && Last_MACD_Trend[TF_H1]<=-MaxMACD_Trend[TF_H1]) ){
                           Close_TF=TF_M15;
                      }
                   }
                   
                }
                 
                               
                if(OpenOrder.Order_Profit()<0){
                
                  if((OrderType()==OP_BUY && Last_MACD_Trend[TF_H4]>=MaxMACD_Trend[TF_H4] && M15Trend=="Down" && H4Trend!="Up" && D1Trend!="Up") || 
                     (OrderType()==OP_SELL && Last_MACD_Trend[TF_H4]<=-MaxMACD_Trend[TF_H4] && M15Trend=="Up" && H4Trend!="Down" && D1Trend!="Down") ){
                     Close_TF=TF_M15;
                  }
                  /*if((OrderType()==OP_BUY && H1Trend=="Down" && H4Trend=="Up" && D1Trend!="Up") || 
                     (OrderType()==OP_SELL && H1Trend=="Up" && H4Trend=="Down" && D1Trend!="Down") ){
                     Close_TF=TF_H1;
                  }*/
                  
                  //bool Close_D1Trend = (W1Trend!="Ranging")? D1Trend!=OrderTrend && D1Trend==H4Trend : D1Trend!=OrderTrend;
                  
                  if((OrderType()==OP_BUY && H1Trend=="Down" && H4Trend=="Down" && D1Trend=="Down") || 
                     (OrderType()==OP_SELL && H1Trend=="Up" && H4Trend=="Up" && D1Trend=="Up") ){
                     Close_TF=TF_H4;
                  }
                  
                }
            }
                        
            if(Close_TF>=1)                    
               ShortTrend=SAR_Trend_By_Change(Close_TF);
            else
               ShortTrend=Order_Trend;
            
            /*int Minutes=(int)((TimeCurrent()-TimeInit)/60);
            if(Minutes % PERIOD_H1 == 0){
               Print("Minutes=",Minutes,", Hours=",(Minutes/60),", Days=",((Minutes/60)/24));
               for(int t=7;t>=1;t--){
                  Print(Vars_SAR_Trend_By_Change[t]);   
               }
               Print("Max_TF=",Max_TF,", Min_TF=",Min_TF,", Close_TF=",Close_TF,", ShortTrend=",ShortTrend);
               Print("OrderType=",OrderType(),", Order_Open_Price=",OpenOrder.Order_Open_Price,", Bid=",MarketInfo(iSymbol,MODE_BID),", Ask=",MarketInfo(iSymbol,MODE_ASK));
            }*/
            
            if(OrderType()==OP_BUY)
              {
               //StopLoss=H1Trend!="Up" && ShortTrend=="Down"? AverageSpreadNumPeriod(TF_H1,1) : 0;
               //PriceOK=(D1Trend=="Up" && H4Trend!="Down" && H1Trend!="Down")? (OpenOrder.Order_Profit()>=0) : (Price>=OpenOrder.Order_Open_Price-StopLoss);
               
               //if((PriceOK==true && ShortTrend=="Down") || (Price<OpenOrder.Order_Open_Price && D1Trend!="Up" && H4Trend=="Down" && H1Trend=="Down" && ShortTrend=="Down"))
               if(ShortTrend=="Down")
                 {
                     if(OrderClose(OpenOrder.Order_Ticket,OpenOrder.Order_Lots,Price,3,White)){
                        OpenOrder.Closed=true;
                        objOrders.Cerrar(OpenOrder.Order_Ticket);
                        Print("OrderClose ",iSymbol,": OrderTicket=",OpenOrder.Order_Ticket,", OrderProfit=",OpenOrder.Order_Profit(),", Price>=OrderOpenPrice()=",Price,">",OpenOrder.Order_Open_Price,", ShortTrend=",ShortTrend);
                        Print("Close_TF=",Close_TF,", Max_TF=",Max_TF,", OpenOrder.Closed=",OpenOrder.Closed);
                        Print("Last_MACD_Trend[TF_H4]=",Last_MACD_Trend[TF_H4],", MaxMACD_Trend[TF_H4]=",MaxMACD_Trend[TF_H4],", Last_MACD_Trend[TF_H1]=",Last_MACD_Trend[TF_H1],", MaxMACD_Trend[TF_H1]=",MaxMACD_Trend[TF_H1]);
                        Print(Vars_SAR_Trend_By_Change[TF_W1]);   
                        Print(Vars_SAR_Trend_By_Change[TF_D1]);   
                        Print(Vars_SAR_Trend_By_Change[TF_H4]);
                        Print(Vars_SAR_Trend_By_Change[TF_H1]);
                        Print(Vars_SAR_Trend_By_Change[TF_M30]);
                        Print("W1Change=",W1Change,", AverageW1Change=",AverageW1Change);
                        //objOrders.PrintOrders();                        
                     }else{
                        Error=GetLastError();
                        if(Error==4108){//ERR_INVALID_TICKET
                           OpenOrder.Closed=true;
                           objOrders.Cerrar(Order_Ticket);
                        }
                        PrintError(StringConcatenate("OrderClose ",iSymbol,": OrderTicket=",OpenOrder.Order_Ticket),Error);
                        return;
                     }   
                     
                 }
               //if(MinutesOpened % PERIOD_H4 == 0) 
               //   Print("Order_Ticket=",Order_Ticket,", Close_TF=",Close_TF,", MinutesOpened=",MinutesOpened,", ShortTrend=",ShortTrend,", OrderLots=",ListOpenOrders[i].Order_Lots,", OrderProfit=",objOrders.Order_Profit(i),", Ask>OrderOpenPrice=",Ask,">",ListOpenOrders[i].Order_Open_Price);
                    
            }
            if(OrderType()==OP_SELL)
              {
               //StopLoss=H1Trend!="Down" && ShortTrend=="Up"? AverageSpreadNumPeriod(TF_H1,1) : 0;
               //PriceOK=(D1Trend=="Down" && H4Trend!="Up" && H1Trend!="Up")? (OpenOrder.Order_Profit()>=0) : (Price<=OpenOrder.Order_Open_Price-StopLoss);
                       
               //if((PriceOK==true && ShortTrend=="Up") || (Price>OpenOrder.Order_Open_Price && D1Trend!="Down" && H4Trend=="Up" && H1Trend=="Up" && ShortTrend=="Up"))
               if(ShortTrend=="Up")
                 {                     
                     if(OrderClose(OpenOrder.Order_Ticket,OpenOrder.Order_Lots,Price,3,White)){
                        OpenOrder.Closed=true;
                        objOrders.Cerrar(OpenOrder.Order_Ticket);
                        Print("OrderClose ",iSymbol,": OrderTicket=",OpenOrder.Order_Ticket,", OrderProfitn=",OpenOrder.Order_Profit(),", Price<=OrderOpenPrice()=",Price,"<",OpenOrder.Order_Open_Price,", ShortTrend=",ShortTrend);
                        Print("Close_TF=",Close_TF,", Max_TF=",Max_TF,", OpenOrder.Closed=",OpenOrder.Closed);
                        Print("Last_MACD_Trend[TF_H4]=",Last_MACD_Trend[TF_H4],", MaxMACD_Trend[TF_H4]=",MaxMACD_Trend[TF_H4],", Last_MACD_Trend[TF_H1]=",Last_MACD_Trend[TF_H1],", MaxMACD_Trend[TF_H1]=",MaxMACD_Trend[TF_H1]);
                        Print(Vars_SAR_Trend_By_Change[TF_W1]);   
                        Print(Vars_SAR_Trend_By_Change[TF_D1]);   
                        Print(Vars_SAR_Trend_By_Change[TF_H4]);
                        Print(Vars_SAR_Trend_By_Change[TF_H1]);
                        Print(Vars_SAR_Trend_By_Change[TF_M30]);
                        Print("W1Change=",W1Change,", AverageW1Change=",AverageW1Change);
                        //objOrders.PrintOrders();
                     }else{
                        Error=GetLastError();
                        if(Error==4108){//ERR_INVALID_TICKET
                           OpenOrder.Closed=true;
                           objOrders.Cerrar(OpenOrder.Order_Ticket);
                        }
                        PrintError(StringConcatenate("OrderClose ",iSymbol,": OrderTicket=",OpenOrder.Order_Ticket),Error);
                        return;
                     }
                     
                 }
                //if(MinutesOpened % PERIOD_H4 == 0) 
                //  Print("Order_Ticket=",Order_Ticket,", Close_TF=",Close_TF,", MinutesOpened=",MinutesOpened,", ShortTrend=",ShortTrend,", OrderLots=",ListOpenOrders[i].Order_Lots,", OrderProfit=",objOrders.Order_Profit(i),", Bid<OrderOpenPrice=",Bid,"<",ListOpenOrders[i].Order_Open_Price);
              }
              
          }//if TicketOpened 
          else{
            //Print("Ticket not found ",Order_Ticket," or MinutesOpened=",MinutesOpened,"<20",", TimeCurrent-OrderOpenTime=",TimeCurrent()-OrderOpenTime());
          }   
       }//if OrderSelect
       else{
         //Print("Ticket not found ",Order_Ticket);
       }
     }//for i
//---
}
//+------------------------------------------------------------------+

void ModifyTakeProfit(){
   double Price,AverageH1Spread;
   
   AverageH1Spread=AverageSpreadNumPeriod(TF_H1);
   Order *OpenOrder;
   int TotalOrders=objOrders.FillOpenOrderList();
   
   for(int i=0;i<TotalOrders;i++)
   {
      OpenOrder=objOrders.OpenOrderList[i];
      Order_Ticket=OpenOrder.Order_Ticket;
      iSymbol=OpenOrder.Order_Symbol;
      
      if(OrderSelect(Order_Ticket,SELECT_BY_TICKET,MODE_TRADES)==true){
         if(OrderTakeProfit()>0) continue;
         
         Price=OrderType()==OP_BUY? MarketInfo(iSymbol,MODE_ASK) : MarketInfo(iSymbol,MODE_BID);
                           
         if(OrderType()==OP_BUY){
            if(Price-OpenOrder.Order_Open_Price>AverageH1Spread){
               if(OrderClose(Order_Ticket,OpenOrder.Order_Lots,MarketInfo(iSymbol,MODE_BID),3,White)){
               }
            }else{
               PriceTakeProfit=OpenOrder.Order_Open_Price+AverageH1Spread;
               if(OrderModify(Order_Ticket,OpenOrder.Order_Open_Price,OpenOrder.Order_StopLoss,PriceTakeProfit,0,Green)){
               }
            }   
         }else if(OrderType()==OP_SELL){
            if(OpenOrder.Order_Open_Price-Price>AverageH1Spread){
               if(OrderClose(Order_Ticket,OpenOrder.Order_Lots,MarketInfo(iSymbol,MODE_ASK),3,White)){
               }
            }else{
               PriceTakeProfit=OpenOrder.Order_Open_Price-AverageH1Spread;
               if(OrderModify(Order_Ticket,OpenOrder.Order_Open_Price,OpenOrder.Order_StopLoss,PriceTakeProfit,0,Red)){
               }
            }
         }
         
      }
   }   
}

bool IsShortTrend(string Trend,int Count_Period,int _MACD_TF=0){
   double ChangeTrend,MinChangeTrend;
   bool IsShortTrend=true;
   double PercentChange=W1Trend!=Trend ? 1.9 : 0.7;
   _MACD_TF=_MACD_TF==0? MACD_TF : _MACD_TF;
   
   for(int i=3;i<=Count_Period;i++){
      ChangeTrend=PeriodChange(_MACD_TF,3,Count_Period-i);
      MinChangeTrend=AveragePeriodChange(_MACD_TF,3)*PercentChange;
      if(Trend=="Up")   
         IsShortTrend=IsShortTrend && ChangeTrend>=MinChangeTrend;
      if(Trend=="Down")   
         IsShortTrend=IsShortTrend && ChangeTrend<=-MinChangeTrend;   
   }
   //Last Period
   ChangeTrend=PeriodChange(_MACD_TF,1,0);
   PercentChange=W1Trend!=Trend? 1.9 : 1.3;
   MinChangeTrend=AveragePeriodChange(_MACD_TF,1)*PercentChange;
   if(Trend=="Up")   
      IsShortTrend=IsShortTrend && ChangeTrend>=MinChangeTrend;
   if(Trend=="Down")   
      IsShortTrend=IsShortTrend && ChangeTrend<=-MinChangeTrend;   
      
   return IsShortTrend;
}

bool IsNewTrend(string Trend,int Count_Period,int _MACD_TF=0){
   double ChangeTrend,MinChangeTrend;
   bool IsNewTrend=true;
   double PercentChange=W1Trend!=Trend? 0.6 : 0.1;
   _MACD_TF=_MACD_TF==0? MACD_TF : _MACD_TF;
   
   for(int i=6;i<=Count_Period;i++){
      ChangeTrend=PeriodChange(_MACD_TF,6,Count_Period-i);
      MinChangeTrend=AveragePeriodChange(_MACD_TF,6)*PercentChange;
      if(Trend=="Up")   
         IsNewTrend=IsNewTrend && ChangeTrend>=MinChangeTrend;
      if(Trend=="Down")   
         IsNewTrend=IsNewTrend && ChangeTrend<=-MinChangeTrend;   
   }
   
   //Last Period
   int Periods=_MACD_TF<=TF_M30? 3 : 1;
   ChangeTrend=PeriodChange(_MACD_TF,Periods,0);
   PercentChange=W1Trend!=Trend? 1.3 : (_MACD_TF<TF_H4? 0.9 : 1.3);
   MinChangeTrend=AveragePeriodChange(_MACD_TF,Periods)*PercentChange;
   if(Trend=="Up")   
      IsNewTrend=IsNewTrend && ChangeTrend>=MinChangeTrend;
   if(Trend=="Down")   
      IsNewTrend=IsNewTrend && ChangeTrend<=-MinChangeTrend;   
      
   return IsNewTrend;
}

bool IsConstantTrend(int _MACD_TF,string Trend,int Count_Periods,int Count_Group=6,double PercentChange_Group=0.1,int Shift=0){
   double ChangeTrend,MinChangeTrend;
   bool IsConstantTrend = Trend!="Ranging"? true : false;
   
   if(Count_Periods>=Count_Group){
      for(int i=Count_Group;i<=Count_Periods;i++){
         ChangeTrend=PeriodChange(_MACD_TF,Count_Group,Count_Periods-i+Shift);
         MinChangeTrend=AveragePeriodChange(_MACD_TF,Count_Group)*PercentChange_Group;
         if(Trend=="Up")   
            IsConstantTrend=IsConstantTrend && ChangeTrend>=MinChangeTrend;
         if(Trend=="Down")   
            IsConstantTrend=IsConstantTrend && ChangeTrend<=-MinChangeTrend;   
      }
   }
   if(CurrentFunction=="CheckForOpen"){
      Count_Group=2;
      PercentChange_Group=0.1;
      ChangeTrend=PeriodChange(_MACD_TF,Count_Group,Shift);
      MinChangeTrend=AveragePeriodChange(_MACD_TF,Count_Group)*PercentChange_Group;
      if(Trend=="Up")   
         IsConstantTrend=IsConstantTrend && ChangeTrend>=MinChangeTrend;
      if(Trend=="Down")   
         IsConstantTrend=IsConstantTrend && ChangeTrend<=-MinChangeTrend;   
   }         
   return IsConstantTrend;
}


bool Jump(string Trend,int Period_TF,int CountPeriodTrend,int Shift=0){
   bool Step=true;
   CountPeriodTrend=CountPeriodTrend<2? 2 : CountPeriodTrend;
   double StepM1,SpreadH4=AverageSpreadNumPeriod(TF_H4,1);
   double OpenPriceM1,ClosePriceM1;
   
   for(int i=0;i<=Period_TF*(CountPeriodTrend);i++){//M1
      OpenPriceM1=iOpen(iSymbol,PERIOD_M1,Shift*Period_TF+i);
      ClosePriceM1=iClose(iSymbol,PERIOD_M1,Shift*Period_TF+i+1);
      StepM1=MathAbs(OpenPriceM1-ClosePriceM1);
      Step=Step && (StepM1<=SpreadH4);
      if(Step==false){
         if(Minutes==0 || Minutes % PERIOD_H4 == 0)
            Print("Jump: OpenPriceM1=",OpenPriceM1,", ClosePriceM1=",ClosePriceM1,", StepM1=",StepM1,", SpreadH4=",SpreadH4);
         break;
      }         
   }
         
   for(i=0;i<CountPeriodTrend;i++){
      if(Trend=="Up"){
         Step=Step && iLow(iSymbol,Period_TF,Shift+i)<=iHigh(iSymbol,Period_TF,Shift+i+1)+SpreadH4;
      }else if(Trend=="Down"){
         Step=Step && iHigh(iSymbol,Period_TF,Shift+i)>=iLow(iSymbol,Period_TF,Shift+i+1)-SpreadH4;
      }
   }
   return !Step;
}

void CalculateStopLoss(int Period_TF,string Trend){
   StopLoss=AverageSpreadNumPeriod(TF_D1,3);
   
   if(FirstDay==true){
      TakeProfit=AverageSpreadNumPeriod(TF_H1,1); 
   }else{
      TakeProfit=0;
   }
      
}

double PeriodChange(int _MACD_TF,int CountPeriods=1, int ShiftPeriods=0){
   CountPeriods=CountPeriods<1? 1 : CountPeriods;
   ShiftPeriods=ShiftPeriods<0? 0 : ShiftPeriods;
   if(iBars(iSymbol,ENUM_TF[_MACD_TF])<CountPeriods+ShiftPeriods) return 0;
   
   if(CountPeriods==1 && _MACD_TF>1){
      int PeriodsTF_1=TF[_MACD_TF]/TF[_MACD_TF-1];
      return PeriodChange(_MACD_TF-1,PeriodsTF_1,PeriodsTF_1*ShiftPeriods);
   }else{
      double OpenPrice,ClosePrice;
      if(iOpen(iSymbol, ENUM_TF[_MACD_TF], CountPeriods-1+ShiftPeriods)<iClose(iSymbol, ENUM_TF[_MACD_TF],ShiftPeriods)){
         OpenPrice = iLow(iSymbol, ENUM_TF[_MACD_TF], CountPeriods-1+ShiftPeriods); 
      }else{
         OpenPrice = iHigh(iSymbol, ENUM_TF[_MACD_TF], CountPeriods-1+ShiftPeriods);
      }
      ClosePrice=iClose(iSymbol, ENUM_TF[_MACD_TF], ShiftPeriods);
      double Price = OpenPrice<MarketInfo(iSymbol,MODE_BID)? MarketInfo(iSymbol,MODE_ASK) : MarketInfo(iSymbol,MODE_BID); //Up : Down
      ClosePrice  = (ShiftPeriods==0)? Price : ClosePrice;
              
         
      double PercChange = 0;
      if(OpenPrice>0 && ClosePrice>0) PercChange=((ClosePrice - OpenPrice)/OpenPrice)*100;
      //else PrintError(StringConcatenate("PeriodChange: OpenPrice_TF=",OpenPrice_TF,", ActualBid=",ActualBid,", CountPeriods=",CountPeriods,", ShiftPeriods=",ShiftPeriods),GetLastError());
      //if(_MACD_TF==7 && CountPeriods==1 && ShiftPeriods==0 && PercChange==0)
         //Print("PeriodChange: _MACD_TF=",_MACD_TF,", CountPeriods=",CountPeriods,", ShiftPeriods=",ShiftPeriods,", OpenPrice=",OpenPrice,", ActualPrice=",ActualPrice);   
      PercChange=NormalizeDouble(PercChange,2);
      return PercChange;
   }
}

double AveragePeriodChange(int _MACD_TF, int Periods=1,int FastEMAPeriod=7,int SlowEMAPeriod=60,int SignalLinePeriod=6){
   FastEMAPeriod=7; SlowEMAPeriod=60; SignalLinePeriod=6;
   string row_state;
   double AveragePeriodChange=Select_AveragePeriodChange(iSymbol,_MACD_TF,Periods,FastEMAPeriod,SlowEMAPeriod,SignalLinePeriod,row_state);
   
   if(AveragePeriodChange!=NULL && row_state=="select"){
      return AveragePeriodChange;
   }else{
   
      double SumPeriodChange=0,PeriodChange,MinPeriodChange=100;
      int TotalPeriods=AverageDaysPeriod[_MACD_TF]*24*60/TF[_MACD_TF];
      if(iBars(iSymbol,ENUM_TF[_MACD_TF])<TotalPeriods) 
         TotalPeriods=iBars(iSymbol,ENUM_TF[_MACD_TF]);
         
      int i=0,Count_Periods_Trend,CountSum=0,Shift;
      int PeriodsExtra=_MACD_TF<=TF_H4? 9 : 4;
      
      while(i<TotalPeriods-1){
         Count_Periods_Trend=CountPeriodTrend(TF[_MACD_TF],FastEMAPeriod,SlowEMAPeriod,SignalLinePeriod,i);
         
         if(Count_Periods_Trend>Periods+PeriodsExtra){
            Shift=i+Count_Periods_Trend-Periods;
            PeriodChange=MathAbs(PeriodChange(_MACD_TF,Periods,Shift));
            if(PeriodChange>0 && PeriodChange<MinPeriodChange){
               SumPeriodChange+=PeriodChange;
               CountSum++;
               MinPeriodChange=PeriodChange;
            }
         }
         if(Count_Periods_Trend>0)
            i+=Count_Periods_Trend;
         else
            break;   
      }
      
      if(CountSum==0){
         if(Periods>1)
            return AveragePeriodChange(_MACD_TF,1,FastEMAPeriod,SlowEMAPeriod,SignalLinePeriod)*Periods*0.8;  
         else
            CountSum=1;
      }
      AveragePeriodChange=NormalizeDouble(SumPeriodChange/CountSum,2);
      Update_AveragePeriodChange(iSymbol,_MACD_TF,Periods,FastEMAPeriod,SlowEMAPeriod,SignalLinePeriod,AveragePeriodChange,row_state);
      //PrintError(StringConcatenate("AveragePeriodChange Symbol=",iSymbol,", _MACD_TF=",_MACD_TF),GetLastError());
      return AveragePeriodChange;
   }    
}


double SpreadNumPeriod(int _MACD_TF,int CountPeriods=1,int ShiftPeriods=0){
   CountPeriods=CountPeriods<1? 1 : CountPeriods;
   ShiftPeriods=ShiftPeriods<0? 0 : ShiftPeriods;
   if(iBars(iSymbol,ENUM_TF[_MACD_TF])<CountPeriods+ShiftPeriods) return 0;
   
   double SpreadPeriod=iClose(iSymbol,TF[_MACD_TF],ShiftPeriods)-iOpen(iSymbol,TF[_MACD_TF],CountPeriods-1+ShiftPeriods);
   return SpreadPeriod;
}

double AverageSpreadNumPeriod(int _MACD_TF,int Periods=1){
   string row_state;
   double AverageSpreadNumPeriod=Select_AverageSpreadNumPeriod(iSymbol,_MACD_TF,Periods,row_state);
   
   if(AverageSpreadNumPeriod!=NULL && row_state=="select"){
      return AverageSpreadNumPeriod;
   }else{
   
      double SpreadPeriod,SumSpread=0,MaxSpread=0;
      int TotalPeriods=AverageDaysPeriod[_MACD_TF]*24*60/TF[_MACD_TF],CountPeriods=0;
      bool SpreadUp,SpreadDown;
      double MA0,MA1;
      
      if(iBars(iSymbol,ENUM_TF[_MACD_TF])<TotalPeriods) 
         TotalPeriods=iBars(iSymbol,ENUM_TF[_MACD_TF]);
         
      for(int i=0;i<TotalPeriods;i++){
         SpreadUp=true;
         SpreadDown=true;
         
         for(int j=i;j<i+Periods-1;j++){
            MA0=iMA(iSymbol,ENUM_TF[_MACD_TF],3,0,MODE_SMA,PRICE_CLOSE,j);
            MA0=iMA(iSymbol,ENUM_TF[_MACD_TF],3,0,MODE_SMA,PRICE_CLOSE,j+1);
            SpreadUp=SpreadUp && MA0>MA1;
            SpreadDown=SpreadDown && MA0<MA1;
         }
         
         if(SpreadUp==true || SpreadDown==true){
            SpreadPeriod=MathAbs(SpreadNumPeriod(_MACD_TF,Periods,i));
            if(SpreadPeriod>MaxSpread){
               SumSpread+=SpreadPeriod;
               CountPeriods++;
               MaxSpread=SpreadPeriod;
            }
         }
      }
      if(CountPeriods==0) return 0;
      AverageSpreadNumPeriod=SumSpread/CountPeriods;
      Update_AverageSpreadNumPeriod(iSymbol,_MACD_TF,Periods,AverageSpreadNumPeriod,row_state);
      //PrintError(StringConcatenate("AverageSpreadNumPeriod Symbol=",iSymbol,", _MACD_TF=",_MACD_TF),GetLastError());
      return AverageSpreadNumPeriod;
   }      
}

int CurrentTimeFrame(){
   int TimeFrame;
   for(int i=1;i<ArraySize(TF);i++){
      if(Period()==TF[i]){
         TimeFrame=i;
         break;
      }
   }
   return TimeFrame;
}


void PrintError(string ErrorSource="",int Error=0){
   if(Error>0){//ERR_NO_ERROR 
      Print(ErrorSource,", Error=",Error," ",ErrorDescription(Error));
   }   
}