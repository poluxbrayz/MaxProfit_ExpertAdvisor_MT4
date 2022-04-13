//+------------------------------------------------------------------+
//|                                                lot_functions.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

double TotalEquity(){
   double Equity=AccountBalance()+AccountCredit();
   int TotalOrders=objOrders.FillOpenOrderList();
   string Symbol_H4Trend;
   Order *iOrder;
   
   for(int i=0;i<TotalOrders;i++){
      iOrder=objOrders.OpenOrderList[i];
      if(iOrder.Get_Order_Profit()>0){
         
         Symbol_H4Trend=Get_MACD_Trend(TF_H4,Count_Temp,0,0,0,0,iOrder.Order_Symbol);

         if(iOrder.MinutesOpened()>=PERIOD_D1 && iOrder.Order_Symbol!=iSymbol && ((iOrder.Order_Trend=="Up" && Symbol_H4Trend!="Down") || (iOrder.Order_Trend=="Down" && Symbol_H4Trend!="Up")) ){
            Equity+=objOrders.OpenOrderList[i].Get_Order_Profit();
         }
         
      }else{
         Equity+=objOrders.OpenOrderList[i].Get_Order_Profit();
      }
      //Print("TotalLot: Order_Symbol=",objOrders.OpenOrderList[i].Order_Symbol,", Order_Ticket=",objOrders.OpenOrderList[i].Order_Ticket,", Order_Profit=",objOrders.OpenOrderList[i].Order_Profit());
   }
   
   return Equity;
}

double TotalLot(){
   double Equity=TotalEquity();
   double TotalLot=Equity/1000;
   double MFIH4=iMFI(iSymbol,TF[TF_H4],6,0);
   double RSIH4=iRSI(iSymbol,TF[TF_H4],6,(MACD_Trend[TF_D1]=="Up"? PRICE_HIGH : PRICE_LOW),0);
   double MFIH1=iMFI(iSymbol,TF[TF_H1],6,0);
   double RSIH1=iRSI(iSymbol,TF[TF_H1],6,(MACD_Trend[TF_D1]=="Up"? PRICE_HIGH : PRICE_LOW),0);
   double SpreadD1=SpreadNumPeriod(TF_H4,6,0,true);
   double AverageH4Spread=AverageSpreadNumPeriod(TF_H4,1);
   bool ForceUp=(MACD_Trend[TF_D1]=="Up" && MFIH4>=65 && RSIH4>=70 && MFIH1>=65 && RSIH1>=70 && SpreadD1>=AverageH4Spread*2);
   bool ForceDown=(MACD_Trend[TF_D1]=="Down" && MFIH4<=35 && RSIH4<=30 && MFIH1<=35 && RSIH1<=30 && SpreadD1<=-AverageH4Spread*2);
   bool Force=(MACD_Trend[TF_D1]==W1Trend && (ForceUp==true || ForceDown==true));
   double TotalLotForce=FormatDecimals(TotalLot/3,2);
   double TotalLotNormal=FormatDecimals(TotalLot/4,2);
   TotalLotForce=(FormatDecimals(TotalLotForce/3,2)<=double(0.01))? MathMax(TotalLotForce+0.03,0.06) : TotalLotForce;
   TotalLot=(Force==true)? TotalLotForce : TotalLotNormal;
   if(TotalLot<MinLot() && Equity>=3) TotalLot=MinLot();
   //Print("TotalLot=",TotalLot,", MinLot=",MinLot(),", Force=",Force,", MACD_Trend[TF_D1]=",MACD_Trend[TF_D1],", W1Trend=",W1Trend,", MFIH4=",MFIH4,", RSIH4=",RSIH4,", MFIH1=",MFIH1,", RSIH1=",RSIH1,", SpreadD1=",SpreadD1,", AverageH4Spread*3=",AverageH4Spread*(MACD_Trend[TF_D1]=="Down"?-3:3)); 
   //Si la ultima orden cerrada tuvo un profit negativo y Force==false, entonces TotalLot=0
   /*if(objOrders.Profit_LastClosedOrder()<0 && Force==false){
      TotalLot=0;
   }*/
   return TotalLot;
}

double MaxLot(){
   double _TotalLot=TotalLot();
   double Risk=(W1Trend!="Ranging")? 3 : 4;
   double Percent = double(1)/(double(ArraySize(Symbols))*Risk);
   double MaxLot=_TotalLot*Percent;
   double MaxLotTrading=MarketInfo(iSymbol,MODE_MAXLOT);
   if(MaxLot<MinLot() && MinLot()<=_TotalLot) MaxLot=MinLot();
   if(MaxLot>MaxLotTrading && MaxLotTrading<=_TotalLot) MaxLot=MaxLotTrading;
   //Print("MaxLot=",MaxLot,", _TotalLot=",_TotalLot,", Percent=",Percent,", Risk=",Risk,", MaxLotTrading=",MaxLotTrading);
   return FormatDecimals(MaxLot,2);
}

double MinLot(){
   return MarketInfo(iSymbol,MODE_MINLOT);
}

double UsedLots(bool CurrentSymbol=true){
   double UsedLots=0;
   int TotalOrders=objOrders.FillOpenOrderList();
   bool ActiveOrder;
   
   for(int i=0;i<TotalOrders;i++)
   {
      ActiveOrder=true;
      if((CurrentSymbol==true && objOrders.OpenOrderList[i].Order_Symbol==iSymbol && ActiveOrder==true) || CurrentSymbol==false)
         UsedLots+=objOrders.OpenOrderList[i].Order_Lots;
   }
   return UsedLots;
}

 
bool FreeLots()
{
   //Print("AccountFreeMargin()=",AccountFreeMargin(),", MarketInfo(iSymbol,MODE_MARGINREQUIRED)=",MarketInfo(iSymbol,MODE_MARGINREQUIRED),", Lots()=",Lots(),",AccountEquity()=",AccountEquity(),", AccountBalance()=",AccountBalance(),", UsedLots(false)=",UsedLots(false),", TotalLot()=",TotalLot(),", MaxLot()=",MaxLot(),", MinLot()=",MinLot());
   return AccountFreeMargin()>=MarketInfo(iSymbol,MODE_MARGINREQUIRED)*Lots() && AccountEquity()>=AccountBalance()*0.6 && UsedLots(false)<=TotalLot()*3 && MaxLot()>=MinLot();
}
  
//+------------------------------------------------------------------+
//| Calculate optimal lot size                                       |
//+------------------------------------------------------------------+
double Lots()
{
   double Divider=1;
   int NewOrders=1;
         
   if(!IsTesting()){
      Divider= Maximum_Lot==true? Divider : Divider*2;
   }
   
   double Lot=(MaxLot()-UsedLots(true))/Divider;
   double LotStep=SymbolInfoDouble(iSymbol,SYMBOL_VOLUME_STEP);
   int LotDecimals=CountDecimals(LotStep);
   Lot=FormatDecimals(Lot,LotDecimals);
   if(Lot<MinLot() && MinLot()<=TotalLot()){
      Lot=MinLot();
   }
   if(MarketInfo(iSymbol,MODE_MARGINREQUIRED)*Lot>AccountFreeMargin()){
      Lot=AccountFreeMargin()/MarketInfo(iSymbol,MODE_MARGINREQUIRED);
   }
   //Print("Lot=",Lot,", MaxLot=",MaxLot(),", UsedLots(true)=",UsedLots(true),", TotalLot=",TotalLot());
   return(Lot);
}
