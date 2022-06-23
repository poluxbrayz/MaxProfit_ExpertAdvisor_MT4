//+------------------------------------------------------------------+
//|                                                    MaxProfit.mq4 |
//|                                               Xantrum Solutions. |
//|                                    https://www.xantrum.solutions |
//+------------------------------------------------------------------+
#property description "Max Profit Expert Advisor for Metatrader 4"
#property copyright "Xantrum Solutions 2022"
#property link      "https://www.xantrum.solutions"
#property version   "1.7"
#property icon       "../Images/MaxProfit.ico"; 
#property strict

#include <stdlib.mqh>
#include <stderror.mqh>
#include "../Include/Global_Variables.mqh"
#include "../Include/hash_functions.mqh"
#include "../Include/Math_functions.mqh"
#include "../Include/Trend_functions.mqh"
#include "../Include/SAR_Trend.mqh"
#include "../Include/MACD_Trend.mqh"
#include "../Include/Symbol_functions.mqh"
#include "../Include/Security_functions.mqh"
#include "../Include/Display_functions.mqh"
#include "../Include/Orders.mqh"
#include "../Include/Lot_functions.mqh"

//--- Inputs
extern const string EA_Period = "M1";
extern const string Donate_Paypal = "https://www.paypal.com/donate/?hosted_button_id=VHL87XUJENRXQ";
bool Maximum_Lot  = false;
bool Confirm_Order  = false;


string EA_Name = "Max Profit";
int MAGICMA = 333777;
double TakeProfit;
double StopLoss;
int MACD_TF;
int Order_Ticket;
double MinStopLevel;
double PriceStopLoss;
double PriceTakeProfit;
int Count_Period_Up, Count_Period_Down;
Orders objOrders();
datetime TimeInit;
bool PrintSymbols=false;
datetime DateTime_Symbols;
int Max_TF,Min_TF,Close_TF;
int Minutes;

void OnInit(){
   bool SetTimer=false;
   if(!IsTesting()){ 
      for(int i=0;i<10;i++){
         SetTimer=EventSetTimer(60);//M1
         if(SetTimer==true)
            break;
      }
   }
   if(SetTimer==false){
      MessageBox("Cannot init the expert advisor.\n Attach again the expert advisor","Init Expert Advisor"); 
      return;
   }
   TimeInit=TimeCurrent();
   //LoadHistoryData();
   SymbolsList(true);
   objOrders.ImportOrders();
   ShowMessages();
   //Print("UsedLots(false)<TotalLot()=",UsedLots(false),"<",TotalLot());
   //Print("UsedLots(true)<MaxLot()=",UsedLots(true),"<",MaxLot());
   //Print("MinLot=",MarketInfo(iSymbol,MODE_MINLOT),", MaxLot=",MarketInfo(iSymbol,MODE_MAXLOT));
   //Print("Spread=",Bid-Ask,", AverageH4Spread=",AverageSpreadNumPeriod(TF_H4,1));
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
      if(CurrentTimeFrame()>TF_M1){//M1, M5. M15
         Print("Change Period to M1");
      }
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
   
   //TrailingProfit();
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

void SetTrends(int ShiftM1=0){
   
   W1Trend=SAR_Trend_By_Change(TF_W1,ShiftM1);
      
   D1Trend=SAR_Trend_By_Change(TF_D1,ShiftM1);
   
   H4Trend=SAR_Trend_By_Change(TF_H4,ShiftM1);
   
   H1Trend=SAR_Trend_By_Change(TF_H1,ShiftM1);
   
   M30Trend=SAR_Trend_By_Change(TF_M30,ShiftM1);
   
   if(CurrentFunction=="CheckForOpen"){
      M15Trend=SAR_Trend_By_Change(TF_M15,ShiftM1);
   }else{
      M15Trend=MACD_Trend_By_Change(TF_M15,ShiftM1);
   }
         
}

void SetLimits(int ShiftM1=0){
   
   D1_Limit_Up=80; D1_Limit_Down=20;
   int D1_Limit_Periods=5;
   H4_Limit_Up=80; H4_Limit_Down=20;
   int H4_Limit_Periods=12;
   int MaxPeriodsH4=30;
   int ShiftH4=Get_Shift(ShiftM1,PERIOD_H4);
   int ShiftD1=Get_Shift(ShiftM1,PERIOD_D1);
      
   D1_Limit_RSI=iRSI(iSymbol,TF[TF_D1],D1_Limit_Periods,PRICE_CLOSE,ShiftD1);
   H4_Limit_RSI=iRSI(iSymbol,TF[TF_H4],H4_Limit_Periods,PRICE_CLOSE,ShiftH4);
   
   bool IsTrend=!(CountPeriodsTrend[TF_D1]==1 && CountPeriodsH4ofD1==1 && CountPeriodsTrend[TF_H4]==1 && CountPeriodsH1ofH4<=4);
   
   UnderLimitBuy=MathFloor(D1_Limit_RSI)<=D1_Limit_Up && CountPeriodsTrend[TF_H4]<=MaxPeriodsH4 && IsTrend==true;
   OverLimitSell=MathCeil(D1_Limit_RSI)>=D1_Limit_Down && CountPeriodsTrend[TF_H4]<=MaxPeriodsH4 && IsTrend==true;
      
   OpenBuy=( (H4Trend=="Up" && (D1Trend=="Up" || W1Trend=="Up")) || 
             (H1Trend=="Up" && (D1Trend=="Up" || W1Trend=="Up"))  ) && 
           (MACD_Trend[TF_M15]=="Up" || MACD_Trend[TF_M30]=="Up") && MACD_Trend[TF_H1]=="Up" && MACD_Trend[TF_H4]=="Up" && MACD_Trend[TF_D1]!="Down" && W1Trend!="Down" && UnderLimitBuy==true;
              
   OpenSell=( (H4Trend=="Down" && (D1Trend=="Down" || W1Trend=="Down")) || 
              (H1Trend=="Down" && (D1Trend=="Down" || W1Trend=="Down"))  ) && 
            (MACD_Trend[TF_M15]=="Down" ||  MACD_Trend[TF_M30]=="Down") && MACD_Trend[TF_H1]=="Down" && MACD_Trend[TF_H4]=="Down" && MACD_Trend[TF_D1]!="Up" && W1Trend!="Up" && OverLimitSell==true;
   
   /*double SymbolSpread=MathAbs(MarketInfo(iSymbol,MODE_ASK)-MarketInfo(iSymbol,MODE_BID));
   double SpreadH4=AverageSpreadNumPeriod(TF_H4,1);
   bool EnableH1Trend=SymbolSpread<=SpreadH4;*/
      
   
   
}

//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
void CheckForOpen()
  {
   
   //Print("objOrders.FreeOrders()=",objOrders.FreeOrders(),", FreeLots()=",FreeLots());
   if(!objOrders.FreeOrders()) return;
   if(!FreeLots()) return;
   
   Minutes=(int)((TimeCurrent()-TimeInit)/60);          
   CurrentFunction="CheckForOpen";
   SetTrends();
   SetLimits();
   
   if(IsTesting()==true && Minute()%5==0){
      for(int _MACD_TF=TF_W1;_MACD_TF>=TF_M15;_MACD_TF--){
         Print(Vars_MACD_Trend_By_Change[_MACD_TF]);  
      }
      Print("W1Trend=",W1Trend,", D1Trend=",D1Trend,", H4Trend=",H4Trend,", H1Trend=",H1Trend,", M30Trend=",M30Trend,", M15Trend=",M15Trend);
   }
   
   if(OpenBuy==false && OpenSell==false) return;
   
            
   double Order_Lots,Order_Open_Price;      
                  
   for(MACD_TF=TF_H4;MACD_TF>=TF_H1;MACD_TF--){
      
      while(Signal[MACD_TF]!="Ranging"){
      
         if(!objOrders.FreeOrders()) return;
         if(!FreeLots()) return;
      
         if(Signal[MACD_TF]=="Up")
         {
               Order_Open_Price=MarketInfo(iSymbol,MODE_ASK);
               
               SetStopLoss();
               
               SetTakeProfit(Order_Open_Price);
               
               Order_Lots=Lots();
               
               if(Order_Lots<MarketInfo(iSymbol,MODE_MINLOT))
                  return;
                              
               if(MsgConfirmOrder("Up")==false) return;
               
               Print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");                  
               
               Order_Ticket=OrderSend(iSymbol,OP_BUY,Order_Lots,Order_Open_Price,2,PriceStopLoss,PriceTakeProfit,EA_Name,MAGICMA,0,Green);
               objOrders.Agregar(iSymbol,Order_Ticket,OP_BUY,TimeCurrent(),Order_Open_Price,Order_Lots,PriceStopLoss,PriceTakeProfit);               

               if(Order_Ticket>0){
                  
               }else{         
                  PrintError(StringConcatenate("OrderSend ",iSymbol,": "),GetLastError());
                  objOrders.Cerrar(Order_Ticket);
               }  
               Print("OrderSend ",iSymbol,": OrderType=OP_BUY, TF=",TF[MACD_TF],", Order_Open_Price=",Order_Open_Price,", Order_Lots=",Order_Lots,", PriceStopLoss=",PriceStopLoss,", PriceTakeProfit=",PriceTakeProfit,", FreeLots=",FreeLots());
               Print("TotalLot=",TotalLot(),", MaxLot=",MaxLot(),", MinLot=",MinLot(),", MODE_LOTSIZE=",MarketInfo(iSymbol,MODE_LOTSIZE),", MODE_MAXLOT=",MarketInfo(iSymbol,MODE_MAXLOT),", SYMBOL_VOLUME_STEP=",SymbolInfoDouble(iSymbol,SYMBOL_VOLUME_STEP),", SYMBOL_VOLUME_LIMIT=",SymbolInfoDouble(iSymbol,SYMBOL_VOLUME_LIMIT));
               
               if(Signal[MACD_TF]=="Up"){ 
                  Signal[MACD_TF]="Ranging";
                  Print("Vars_MACD_Trend_By_Change[",MACD_TF,"] = ",Vars_MACD_Trend_By_Change[MACD_TF]);  
               }
               Print("Vars_MACD_Trend_By_Change[",TF_D1,"] = ",Vars_MACD_Trend_By_Change[TF_D1]);  
               Print("W1Trend=",W1Trend,", D1Trend=",D1Trend,", H4Trend=",H4Trend,", H1Trend=",H1Trend);
               Print("UnderLimitBuy=",UnderLimitBuy,", D1_Limit_RSI=",D1_Limit_RSI,", H4_Limit_RSI=",H4_Limit_RSI);
               
               
         }
         else if(Signal[MACD_TF]=="Down")
         {
                  Order_Open_Price=MarketInfo(iSymbol,MODE_BID);
                  
                  SetStopLoss();
                  
                  SetTakeProfit(Order_Open_Price);
                     
                  Order_Lots=Lots();
                  
                  if(Order_Lots<MarketInfo(iSymbol,MODE_MINLOT))
                     return;
                                                               
                  if(MsgConfirmOrder("Down")==false) return;
                  
                  Print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");                  
                                    
                  Order_Ticket=OrderSend(iSymbol,OP_SELL,Order_Lots,Order_Open_Price,2,PriceStopLoss,PriceTakeProfit,EA_Name,MAGICMA,0,Red);
                  objOrders.Agregar(iSymbol,Order_Ticket,OP_SELL,TimeCurrent(),Order_Open_Price,Order_Lots,PriceStopLoss,PriceTakeProfit);
                                    
                  if(Order_Ticket>0){
                  
                  }else{
                     PrintError(StringConcatenate("OrderSend ",iSymbol,": "),GetLastError());
                     objOrders.Cerrar(Order_Ticket);
                  }
                  Print("OrderSend ",iSymbol,": OrderType=OP_SELL, TF=",TF[MACD_TF],", Order_Open_Price=",Order_Open_Price,", Order_Lots=",Order_Lots,", PriceStopLoss=",PriceStopLoss,", PriceTakeProfit=",PriceTakeProfit,", FreeLots=",FreeLots());
                  Print("TotalLot=",TotalLot(),", MaxLot=",MaxLot(),", MinLot=",MinLot(),", MODE_LOTSIZE=",MarketInfo(iSymbol,MODE_LOTSIZE),", MODE_MAXLOT=",MarketInfo(iSymbol,MODE_MAXLOT),", SYMBOL_VOLUME_STEP=",SymbolInfoDouble(iSymbol,SYMBOL_VOLUME_STEP),", SYMBOL_VOLUME_LIMIT=",SymbolInfoDouble(iSymbol,SYMBOL_VOLUME_LIMIT));

                  
                  if(Signal[MACD_TF]=="Down"){ 
                     Signal[MACD_TF]="Ranging";
                     Print("Vars_MACD_Trend_By_Change[",MACD_TF,"] = ",Vars_MACD_Trend_By_Change[MACD_TF]);  
                  }
                  Print("Vars_MACD_Trend_By_Change[",TF_D1,"] = ",Vars_MACD_Trend_By_Change[TF_D1]);  
                  Print("W1Trend=",W1Trend,", D1Trend=",D1Trend,", H4Trend=",H4Trend,", H1Trend=",H1Trend);
                  Print("OverLimitSell=",OverLimitSell,", D1_Limit_RSI=",D1_Limit_RSI,", H4_Limit_RSI=",H4_Limit_RSI);
                  
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
   string CloseTrend;
   double Price,ClosePrice,Order_Spread,MinSpreadCloseH4;
   bool TicketOpened;//,PriceOK;
   int i,MinutesOpened,Order_Type,Error,TotalOrders,_MACD_TF;//,ClosePeriods;
   Order *OpenOrder;
   objOrders.ImportOrders();
   TotalOrders=objOrders.FillOpenOrderList();
  
            
                        
   for(i=TotalOrders-1;i>=0;i--)
     {
      //objOrders.PrintOrders();
      OpenOrder=objOrders.OpenOrderList[i];
      Order_Ticket=OpenOrder.Order_Ticket;
      
      if(OpenOrder.Closed==False){
         
         TicketOpened=true; 
         
         MinutesOpened=int((TimeCurrent()-OpenOrder.Order_Open_Time)/60);
         
         //--- check order type 
         if(TicketOpened==true && MinutesOpened>=PERIOD_M15){
         
            iSymbol=OpenOrder.Order_Symbol;
            
            Order_Trend=OpenOrder.Order_Trend;
            Order_Type=OpenOrder.Order_Type;
            Order_Profit=OpenOrder.Get_Order_Profit();
            Order_Open_Time=OpenOrder.Order_Open_Time;
            Price=Order_Type==OP_BUY? MarketInfo(iSymbol,MODE_BID) : MarketInfo(iSymbol,MODE_ASK);
            ClosePrice=iClose(iSymbol,TF[TF_H1],0);
            Order_Spread=ClosePrice-OpenOrder.Order_iClose_Price;//+Buy -Sell
            MinSpreadCloseH4=AverageSpreadNumPeriod(TF_H4,1)*3;
            
            
            SetTrends();
            
            Minutes=(int)((TimeCurrent()-TimeInit)/60);
            
            if(IsTesting()==true && Minute()%5==0){
               Print("Minutes=",Minutes,", Hours=",(Minutes/60),", Days=",((Minutes/60)/24));
               Print("Order_Ticket=",Order_Ticket,", OrderType=",Order_Type,", Order_Profit=",OpenOrder.Get_Order_Profit(),", Price=",Price,", Order_Commission=",OpenOrder.Order_Commission,", Order_Swap=",OpenOrder.Order_Swap,", Order_Spread=",Order_Spread,", MinSpreadCloseH4=",MinSpreadCloseH4);
               //Print("Order_Swap=",OpenOrder.Order_Swap,", Order_Lots=",OpenOrder.Order_Lots,", GetSwap=",GetSwap(Order_Trend,OpenOrder.Order_Lots));
               for(_MACD_TF=TF_W1;_MACD_TF>=TF_M15;_MACD_TF--){
                  Print(Vars_MACD_Trend_By_Change[_MACD_TF]);  
               }
               Print("W1Trend=",W1Trend,", D1Trend=",D1Trend,", H4Trend=",H4Trend,", H1Trend=",H1Trend,", M30Trend=",M30Trend,", M15Trend=",M15Trend);
               Print("OpenOrder.Get_Order_Profit()=",OpenOrder.Get_Order_Profit(),", CountPeriodsH4ofD1=",CountPeriodsH4ofD1,", CountPeriodsH4ofD1_PrevPeriodsH4=",CountPeriodsH4ofD1_PrevPeriodsH4);
            }
            
            /*if((Order_Type==OP_BUY && H4Trend!="Down" && H1Trend!="Down" && M30Trend!="Down" && M15Trend!="Down") || 
               (Order_Type==OP_SELL && H4Trend!="Up" && H1Trend!="Up" && M30Trend!="Up" && M15Trend!="Up")){
               continue;
            }*/
            
                        
            Close_TF=0;
                               
             if(OpenOrder.Get_Order_Profit()>=0){
               
               //Short Trend
               if(!(H1Trend==Order_Trend && D1Trend==Order_Trend && W1Trend==Order_Trend) && MathAbs(Order_Spread)<MinSpreadCloseH4){
                  
                  if(H1Trend!=Order_Trend){
                     if( (Order_Type==OP_BUY && M15Trend=="Down" && MACD_Trend[TF_M30]=="Down") || (Order_Type==OP_SELL && M15Trend=="Up" && MACD_Trend[TF_M30]=="Up") ){
                          Close_TF=TF_M15;
                     }
                     
                     if( (Order_Type==OP_BUY && M30Trend=="Down") || (Order_Type==OP_SELL && M30Trend=="Up") ){
                          Close_TF=TF_M30;
                     }
                     
                     if( (Order_Type==OP_BUY && H1Trend=="Down" ) || (Order_Type==OP_SELL && H1Trend=="Up") ){
                          Close_TF=TF_H1;
                     }
                  }
                  
                  if(MACD_Trend[TF_H4]==Order_Trend && (CheckBBollinger(TF_H4,6,0,iSymbol)==true || CheckBBollinger(TF_H1,6,0,iSymbol)==true)){
                     double SpreadM1=AverageSpreadNumPeriod(TF_M1,1);
                     Print("Order_Spread=",MathAbs(Order_Spread),", SpreadM1=",SpreadM1,", ClosePrice=",ClosePrice,", OpenOrder.Order_iClose_Price=",OpenOrder.Order_iClose_Price);
                     if(MathAbs(Order_Spread)>=SpreadM1){
                        SAR_Trend[TF_M1]=Get_SAR_Trend(TF_M1,CountPeriodsTrend[TF_M1],0,iSymbol,1.0,1.0);
                        MACD_Trend[TF_M1]=Get_MACD_Trend(TF_M1,CountPeriodsTrend[TF_M1],5,15,4,0,iSymbol);
                        Print("CheckForClose: SAR_Trend[TF_M1]=",SAR_Trend[TF_M1],", MACD_Trend[TF_M1]=",MACD_Trend[TF_M1]);
                        if(SAR_Trend[TF_M1]!=Order_Trend || MACD_Trend[TF_M1]!=Order_Trend){
                           MACD_Trend[TF_M1]=(SAR_Trend[TF_M1]!=Order_Trend)? SAR_Trend[TF_M1] : MACD_Trend[TF_M1];
                           Close_TF=TF_M1;
                           
                        }
                     }
                  }
                  
               }
               
               //Long Trend
               if( (Order_Type==OP_BUY && H4Trend=="Down" && M30Trend=="Down") || (Order_Type==OP_SELL && H4Trend=="Up" && M30Trend=="Up") ){
                    Close_TF=TF_H4;
               }
                
             }
             
             
             //Si la ganancia es menor que 0 y CountPeriodsH4ofD1>=1 y CountPeriodsH4ofD1_PrevPeriodsH4>=3
             if(OpenOrder.Get_Order_Profit()<0 && CountPeriodsH4ofD1>=1 && CountPeriodsH4ofD1_PrevPeriodsH4>=3){
             
               if((Order_Type==OP_BUY && MACD_Trend[TF_M30]=="Down" && H1Trend=="Down" && H4Trend=="Down" && D1Trend=="Down") || (Order_Type==OP_SELL && MACD_Trend[TF_M30]=="Up" && H1Trend=="Up" && H4Trend=="Up" && D1Trend=="Up") ){
                  Close_TF=TF_H4;
               }
               
               if((Order_Type==OP_BUY && MACD_Trend[TF_M30]=="Down" && H1Trend=="Down" && H4Trend=="Down" && W1Trend=="Down") || (Order_Type==OP_SELL && MACD_Trend[TF_M30]=="Up" && H1Trend=="Up" && H4Trend=="Up" && W1Trend=="Up") ){
                  Close_TF=TF_H4;
               }
               
             }
             
                        
            if(Close_TF>=TF_M1){                    
               CloseTrend=MACD_Trend[Close_TF];
            }else{
               CloseTrend=Order_Trend;
            }
            
            
            
            if(Order_Type==OP_BUY)
              {
            
               if(CloseTrend=="Down")
                 {
                     Print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");                  
                     
                     if(OrderClose(OpenOrder.Order_Ticket,OpenOrder.Order_Lots,Price,3,White)){
                        objOrders.Cerrar(OpenOrder.Order_Ticket);
                        //OpenOrder.Closed=true;
                        Print("OrderClose ",iSymbol,": OrderTicket=",OpenOrder.Order_Ticket,", OrderProfit=",OpenOrder.Get_Order_Profit(),", Price>=OrderOpenPrice()=",Price,">",OpenOrder.Order_Open_Price);
                        Print("Close_TF=",Close_TF,", OpenOrder.Closed=",OpenOrder.Closed,", CloseTrend=",CloseTrend,", Order_Trend=",Order_Trend,", Order_Type=",Order_Type);
                        for(_MACD_TF=TF_W1;_MACD_TF>=TF_M15;_MACD_TF--){
                           Print(Vars_MACD_Trend_By_Change[_MACD_TF]);  
                        }
                        Print("W1Trend=",W1Trend,", D1Trend=",D1Trend,", H4Trend=",H4Trend,", H1Trend=",H1Trend,", M30Trend=",M30Trend,", M15Trend=",M15Trend);
                        //objOrders.PrintOrders();                        
                     }else{
                        Error=GetLastError();
                        if(Error==4108){//ERR_INVALID_TICKET
                           objOrders.Cerrar(Order_Ticket);
                           //OpenOrder.Closed=true;
                        }
                        PrintError(StringConcatenate("OrderClose ",iSymbol,": OrderTicket=",OpenOrder.Order_Ticket),Error);
                        return;
                     }   
                     
                 }
                    
            }
            if(Order_Type==OP_SELL)
            {

               if(CloseTrend=="Up")
               {                     
                     Print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");                  
                     
                     if(OrderClose(OpenOrder.Order_Ticket,OpenOrder.Order_Lots,Price,3,White)){
                        objOrders.Cerrar(OpenOrder.Order_Ticket);
                        //OpenOrder.Closed=true;
                        Print("OrderClose ",iSymbol,": OrderTicket=",OpenOrder.Order_Ticket,", OrderProfit=",OpenOrder.Get_Order_Profit(),", Price<=OrderOpenPrice()=",Price,"<",OpenOrder.Order_Open_Price);
                        Print("Close_TF=",Close_TF,", OpenOrder.Closed=",OpenOrder.Closed,", CloseTrend=",CloseTrend,", Order_Trend=",Order_Trend,", Order_Type=",Order_Type);
                        for(_MACD_TF=TF_W1;_MACD_TF>=TF_M15;_MACD_TF--){
                           Print(Vars_MACD_Trend_By_Change[_MACD_TF]);  
                        }
                        Print("W1Trend=",W1Trend,", D1Trend=",D1Trend,", H4Trend=",H4Trend,", H1Trend=",H1Trend,", M30Trend=",M30Trend,", M15Trend=",M15Trend);
                        //objOrders.PrintOrders();
                     }else{
                        Error=GetLastError();
                        if(Error==4108){//ERR_INVALID_TICKET
                           objOrders.Cerrar(OpenOrder.Order_Ticket);
                           //OpenOrder.Closed=true;
                        }
                        PrintError(StringConcatenate("OrderClose ",iSymbol,": OrderTicket=",OpenOrder.Order_Ticket),Error);
                        return;
                     }
                     
                 }

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

void SetStopLoss(){
   double AverageH20Spread=AverageSpreadNumPeriod(TF_H4,1)*5;
   double SpreadD1=MathAbs(SpreadNumPeriod(TF_H4,MathMin(7,CountPeriodsH4ofD1_PrevPeriodsH4),0,true));
   double PriceClose=iClose(iSymbol,TF[TF_H4],0);
   
   if(MACD_Trend[TF_H4]=="Up"){
      double LowPriceD1=MathMin(PriceClose-SpreadD1,PriceClose-AverageH20Spread);
      int LowestTrend=iLowest(iSymbol,PERIOD_H4,MODE_LOW,CountPeriodsH4ofD1_PrevPeriodsH4+1,0);
      double LowPriceTrend=iLow(iSymbol,PERIOD_H4,LowestTrend);
      LowPriceTrend=MathMin(LowPriceTrend,PriceClose-AverageH20Spread);
      Print("SetStopLoss: PriceStopLoss=",PriceStopLoss,", LowPriceD1=",LowPriceD1,", LowPriceTrend=",LowPriceTrend,", LowestTrend=",LowestTrend,", CountPeriodsH4ofD1_PrevPeriodsH4=",CountPeriodsH4ofD1_PrevPeriodsH4,", SpreadD1=",SpreadD1,", AverageH20Spread=",AverageH20Spread);
      PriceStopLoss=MathMax(LowPriceD1,LowPriceTrend);
      
   }else{//Down
      double HighPriceD1=MathMax(PriceClose+SpreadD1,PriceClose+AverageH20Spread);
      int HighestTrend=iHighest(iSymbol,PERIOD_H4,MODE_HIGH,CountPeriodsH4ofD1_PrevPeriodsH4+1,0);
      double HighPriceTrend=iHigh(iSymbol,PERIOD_H4,HighestTrend);
      HighPriceTrend=MathMax(HighPriceTrend,PriceClose+AverageH20Spread);
      Print("SetStopLoss: PriceStopLoss=",PriceStopLoss,", HighPriceD1=",HighPriceD1,", HighPriceTrend=",HighPriceTrend,", HighestTrend=",HighestTrend,", CountPeriodsH4ofD1_PrevPeriodsH4=",CountPeriodsH4ofD1_PrevPeriodsH4,", SpreadD1=",SpreadD1,", AverageH20Spread=",AverageH20Spread);
      PriceStopLoss=MathMin(HighPriceD1,HighPriceTrend);
   }
}

void SetTakeProfit(double Order_Open_Price){
   PriceTakeProfit=0;  
   double RSIH4=iRSI(iSymbol,TF[TF_H4],4,(MACD_Trend[TF_H4]=="Up"? PRICE_HIGH : PRICE_LOW),0);
   double MFIH4=iMFI(iSymbol,TF[TF_H4],4,0);
   double RSIH1=iRSI(iSymbol,TF[TF_H1],8,(MACD_Trend[TF_H1]=="Up"? PRICE_HIGH : PRICE_LOW),0);
   double MFIH1=iMFI(iSymbol,TF[TF_H1],8,0);
   TakeProfit=AverageSpreadNumPeriod(TF_H1);
   Print("SetTakeProfit RSIH4=",RSIH4,", MFIH4=",MFIH4,", RSIH1=",RSIH1,", MFIH1=",MFIH1);
   if(MACD_Trend[TF_H1]=="Up" && MathCeil(RSIH4)>=75 && MathCeil(MFIH4)>=70 && MathCeil(RSIH1)>=75 && MathCeil(MFIH1)>=70){
      //double Band_Upper=iBands(iSymbol,PERIOD_H4,12,2,0,PRICE_HIGH,MODE_UPPER,0);
      //PriceTakeProfit=NormalizeDouble(MathMax(Order_Open_Price,Band_Upper)+TakeProfit,(int)MarketInfo(iSymbol,MODE_DIGITS));
      PriceTakeProfit=NormalizeDouble(Order_Open_Price+TakeProfit,(int)MarketInfo(iSymbol,MODE_DIGITS));
   }
   else if(MACD_Trend[TF_H1]=="Down" && MathFloor(RSIH4)<=25 && MathFloor(MFIH4)<=30 && MathFloor(RSIH1)<=25 && MathFloor(MFIH1)<=30){
      //double Band_Lower=iBands(iSymbol,PERIOD_H4,12,2,0,PRICE_LOW,MODE_LOWER,0);
      //PriceTakeProfit=NormalizeDouble(MathMin(Order_Open_Price,Band_Lower)-TakeProfit,(int)MarketInfo(iSymbol,MODE_DIGITS));
      PriceTakeProfit=NormalizeDouble(Order_Open_Price-TakeProfit,(int)MarketInfo(iSymbol,MODE_DIGITS));
   }
}

//+------------------------------------------------------------------+


void ModifyTakeProfit(){
   double ClosePrice,AverageH1Spread;
   AverageH1Spread=AverageSpreadNumPeriod(TF_H1);
   Order *OpenOrder;
   int TotalOrders=objOrders.FillOpenOrderList();
   int Order_Type;
     
   for(int i=0;i<TotalOrders;i++)
   {
      OpenOrder=objOrders.OpenOrderList[i];
      Order_Ticket=OpenOrder.Order_Ticket;
      Order_Type=OpenOrder.Order_Type;
      iSymbol=OpenOrder.Order_Symbol;
      
      if(OrderSelect(Order_Ticket,SELECT_BY_TICKET,MODE_TRADES)==true){
         if(OrderTakeProfit()>0) continue;
         
         ClosePrice=iClose(iSymbol,TF[TF_H4],0);
                           
         if(Order_Type==OP_BUY){
            if(ClosePrice-OpenOrder.Order_Open_Price>AverageH1Spread){
               if(OrderClose(Order_Ticket,OpenOrder.Order_Lots,MarketInfo(iSymbol,MODE_BID),3,White)){
               }
            }else{
               PriceTakeProfit=OpenOrder.Order_Open_Price+AverageH1Spread;
               if(OrderModify(Order_Ticket,OpenOrder.Order_Open_Price,OpenOrder.Order_StopLoss,PriceTakeProfit,0,Green)){
               }
            }   
         }else if(Order_Type==OP_SELL){
            if(OpenOrder.Order_Open_Price-ClosePrice>AverageH1Spread){
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


bool Jump(string Trend,int Period_TF,int CountPeriodTrend,int Shift=0){
   if(CurrentFunction!="CheckForOpen") return false;
   bool Step=true;
   CountPeriodTrend=CountPeriodTrend<2? 2 : CountPeriodTrend;
   double StepM1,SpreadH4=AverageSpreadNumPeriod(TF_H4,1)*4;
   double OpenPriceM1,ClosePriceM1;
   int i;
   
   for(i=0;i<=Period_TF*(CountPeriodTrend);i++){//M1
      OpenPriceM1=iOpen(iSymbol,PERIOD_M1,Shift*Period_TF+i);
      ClosePriceM1=iClose(iSymbol,PERIOD_M1,Shift*Period_TF+i+1);
      StepM1=(OpenPriceM1>0 && ClosePriceM1>0)? MathAbs(OpenPriceM1-ClosePriceM1) : 0;
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


double PeriodChange(int _MACD_TF,int CountPeriods=1, int Shift=0,string Trend=NULL){
   if(_MACD_TF<=0 || _MACD_TF>=ArraySize(TF)) return 0;
   CountPeriods=CountPeriods<1? 1 : CountPeriods;
   Shift=Shift<0? 0 : Shift;
   if(iBars(iSymbol,TF[_MACD_TF])<CountPeriods+Shift){
      Print("PeriodChange: Symbol=",iSymbol,", _MACD_TF=",_MACD_TF,", CountPeriods=",CountPeriods,", Shift=",Shift,", Trend=",Trend,", iBars(iSymbol,TF[_MACD_TF])=",iBars(iSymbol,TF[_MACD_TF]),", CountPeriods+Shift=",CountPeriods+Shift);
      return 0;
   }
   double OpenPriceTrend,ClosePriceTrend,LowPrice,HighPrice;
   int OpenShift=CountPeriods-1+Shift;
   int Periods_TF_1;
   
   if(CountPeriods==1){
      //OpenPriceTrend=iOpen(iSymbol, TF[_MACD_TF], OpenShift);
      //ClosePriceTrend=iClose(iSymbol, TF[_MACD_TF], Shift);
      Periods_TF_1=TF[_MACD_TF]/TF[_MACD_TF-1];
      return PeriodChange(_MACD_TF-1,CountPeriods*Periods_TF_1,Periods_TF_1*Shift);
      
   }else if(Trend!="Up" && Trend!="Down"){
      OpenPriceTrend=iMA(iSymbol, TF[_MACD_TF],2,0,MODE_SMA,PRICE_MEDIAN,OpenShift);
      ClosePriceTrend=iMA(iSymbol, TF[_MACD_TF],2,0,MODE_SMA,PRICE_MEDIAN, Shift);
      Trend=OpenPriceTrend<ClosePriceTrend? "Up" : "Down";
   }
   
   if(Trend=="Up"){//Up
      //Open
      HighPrice=iHigh(iSymbol, TF[_MACD_TF], OpenShift+1);//Prev Bar
      OpenShift=iLowest(iSymbol, TF[_MACD_TF],MODE_LOW,(int)MathCeil(CountPeriods/2),(int)MathCeil((Shift+CountPeriods-1)/2));
      OpenShift=OpenShift==-1? CountPeriods-1+Shift : OpenShift;
      LowPrice=iLow(iSymbol, TF[_MACD_TF], OpenShift);
      
      if(LowPrice<HighPrice && LowPrice>0)
         OpenPriceTrend = LowPrice;
      else
         OpenPriceTrend = HighPrice;
      //Close
      if(Shift>0)
         ClosePriceTrend=iHigh(iSymbol, TF[_MACD_TF], Shift);
      else
         ClosePriceTrend=iClose(iSymbol, TF[_MACD_TF], Shift);
      
   }else{//Down
      //Open
      LowPrice=iLow(iSymbol, TF[_MACD_TF], OpenShift+1);//Prev Bar
      OpenShift=iHighest(iSymbol, TF[_MACD_TF],MODE_HIGH,(int)MathCeil(CountPeriods/2),(int)MathCeil((Shift+CountPeriods-1)/2));
      OpenShift=OpenShift==-1? CountPeriods-1+Shift : OpenShift;
      HighPrice=iHigh(iSymbol, TF[_MACD_TF], OpenShift);
      if(HighPrice>LowPrice)
         OpenPriceTrend = HighPrice;
      else
         OpenPriceTrend = LowPrice;
      //Close
      if(Shift>0)
         ClosePriceTrend=iLow(iSymbol, TF[_MACD_TF], Shift);
      else
         ClosePriceTrend=iClose(iSymbol, TF[_MACD_TF], Shift);
   }
           
      
   double PercChange = 0;
   if(OpenPriceTrend>0 && ClosePriceTrend>0 && OpenPriceTrend!=ClosePriceTrend){
      PercChange=((ClosePriceTrend - OpenPriceTrend)/OpenPriceTrend)*100;
      PercChange=NormalizeDouble(PercChange,2);

   }else if(_MACD_TF>=2){
      Periods_TF_1=TF[_MACD_TF]/TF[_MACD_TF-1];
      PercChange = PeriodChange(_MACD_TF-1,CountPeriods*Periods_TF_1,Periods_TF_1*Shift);
   }else{
      PercChange = 0;
   }
   
   if(PercChange==0){
      Print("PeriodChange: Symbol=",iSymbol,", _MACD_TF=",_MACD_TF,", CountPeriods=",CountPeriods,", Shift=",Shift,", Trend=",Trend,", OpenPriceTrend=",OpenPriceTrend,", ClosePriceTrend=",ClosePriceTrend);
   }
   return PercChange;
}

double SpreadNumPeriod(int _MACD_TF,int CountPeriods=1,int Shift=0,bool HighLow=false){
   if(_MACD_TF<=0 || _MACD_TF>=ArraySize(TF)) return 0;
   CountPeriods=CountPeriods<1? 1 : CountPeriods;
   Shift=Shift<0? 0 : Shift;
   if(iBars(iSymbol,TF[_MACD_TF])<CountPeriods+Shift) return 0;
   
   double SpreadPeriod=iClose(iSymbol,TF[_MACD_TF],Shift)-iOpen(iSymbol,TF[_MACD_TF],CountPeriods-1+Shift);
   if(HighLow==true){
      double HighPrice=iHigh(iSymbol,TF[_MACD_TF],(Trend(SpreadPeriod)=="Up"? Shift : iHighest(iSymbol,TF[_MACD_TF],MODE_HIGH,CountPeriods,Shift)));
      double LowPrice=iLow(iSymbol,TF[_MACD_TF],(Trend(SpreadPeriod)=="Up"? iLowest(iSymbol,TF[_MACD_TF],MODE_LOW,CountPeriods,Shift) : Shift));
      SpreadPeriod=(HighPrice-LowPrice)*TrendSign(SpreadPeriod);
   }
   
   return SpreadPeriod;
}

double AverageSpreadNumPeriod(int _MACD_TF,int Periods=1){
   if(_MACD_TF<=0 || _MACD_TF>=ArraySize(TF)) return 0;
   string row_state;
   double AverageSpreadNumPeriod=Select_AverageSpreadNumPeriod(iSymbol,_MACD_TF,Periods,row_state);
   
   if(AverageSpreadNumPeriod!=NULL && row_state=="select"){
      return AverageSpreadNumPeriod;
   }else{
   
      double SpreadPeriod,SumSpread=0,MaxSpread=0;
      int TotalPeriods=AverageDaysPeriod[_MACD_TF]*24*60/TF[_MACD_TF],CountPeriods=0;
      bool SpreadUp,SpreadDown;
      double MA0=0,MA1=0;
      double MaxSpread_Divisor=(_MACD_TF<=TF_H4)? 12 : 6;
      
      if(iBars(iSymbol,TF[_MACD_TF])<TotalPeriods) 
         TotalPeriods=iBars(iSymbol,TF[_MACD_TF]);
         
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
            SpreadPeriod=MathAbs(SpreadNumPeriod(_MACD_TF,Periods,i,true));
            if(SpreadPeriod>0 && SpreadPeriod>=MaxSpread/MaxSpread_Divisor){
               SumSpread+=SpreadPeriod;
               CountPeriods++;
               AverageSpreadNumPeriod=SumSpread/CountPeriods;
               if(SpreadPeriod>MaxSpread){
                  MaxSpread=(SpreadPeriod*3+AverageSpreadNumPeriod*2)/5;
               }
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
   int TimeFrame=0;
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