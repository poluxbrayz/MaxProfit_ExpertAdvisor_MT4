//+------------------------------------------------------------------+
//|                                        MaxProfit_BackTesting.mq4 |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property description "Max Profit Expert Advisor for Metatrader 4"
#property copyright "Xantrum Solutions 2022"
#property link      "https://www.xantrum.solutions"
#property version   "1.7"

#property strict

#include <stdlib.mqh>
#include <stderror.mqh>
#include "../Experts/Project/MaxProfit_EA_MT4/Include/Global_Variables.mqh"
#include "../Experts/Project/MaxProfit_EA_MT4/Include/hash_functions.mqh"
#include "../Experts/Project/MaxProfit_EA_MT4/Include/Math_functions.mqh"
#include "../Experts/Project/MaxProfit_EA_MT4/Include/Trend_functions.mqh"
#include "../Experts/Project/MaxProfit_EA_MT4/Include/SAR_Trend.mqh"
#include "../Experts/Project/MaxProfit_EA_MT4/Include/MACD_Trend.mqh"
#include "../Experts/Project/MaxProfit_EA_MT4/Include/Symbol_functions.mqh"
#include "../Experts/Project/MaxProfit_EA_MT4/Include/Security_functions.mqh"
#include "../Experts/Project/MaxProfit_EA_MT4/Include/Display_functions.mqh"
#include "../Experts/Project/MaxProfit_EA_MT4/Include/Orders.mqh"
#include "../Experts/Project/MaxProfit_EA_MT4/Include/Lot_functions.mqh"
#include "../Experts/Project/MaxProfit_EA_MT4/Include/Global_functions.mqh"
#include "../Experts/Project/MaxProfit_EA_MT4/Include/CheckForOrder.mqh"
#include "../Experts/Project/MaxProfit_EA_MT4/Include/MT4Excel_functions.mqh"

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   
   
  }
//+------------------------------------------------------------------+

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

