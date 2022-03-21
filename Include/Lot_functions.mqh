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
   double MFID1=iMFI(iSymbol,TF[TF_D1],3,0);
   double RSID1=iRSI(iSymbol,TF[TF_D1],3,PRICE_CLOSE,0);
   double MFIH4=iMFI(iSymbol,TF[TF_H4],5,0);
   double RSIH4=iRSI(iSymbol,TF[TF_H4],6,(MACD_Trend[TF_D1]=="Up"? PRICE_HIGH : PRICE_LOW),0);
   double SpreadD1=SpreadNumPeriod(TF_H4,6,0,true);
   double AverageH4Spread=AverageSpreadNumPeriod(TF_H4,1);
   bool ForceUp=(MACD_Trend[TF_D1]=="Up" && MFID1>=40 && RSID1>=51 && MFIH4>=70 && RSIH4>=70 && SpreadD1>=AverageH4Spread*3);
   bool ForceDown=(MACD_Trend[TF_D1]=="Down" && MFID1<=60 && RSID1<=49 && MFIH4<=30 && RSIH4<=30 && SpreadD1<=-AverageH4Spread*3);
   bool Force=(MACD_Trend[TF_D1]==W1Trend && (ForceUp==true || ForceDown==true));
   TotalLot=(Force==true)? TotalLot/3 : TotalLot/4;
   TotalLot=FormatDecimals(TotalLot,2);
   if(TotalLot<MinLot() && Equity>=3) TotalLot=MinLot();
   return TotalLot;
}

double MaxLot(){
   double Risk=(W1Trend!="Ranging")? 3 : 4;
   double Percent = double(1)/(double(ArraySize(Symbols))*Risk);
   Percent=IsTesting()==true? Percent*1 : Percent;
   double MaxLot=TotalLot()*Percent;
   double MaxLotTrading=MarketInfo(iSymbol,MODE_MAXLOT);
   if(MaxLot<MinLot() && MinLot()<=TotalLot()) MaxLot=MinLot();
   if(MaxLot>MaxLotTrading && MaxLotTrading<=TotalLot()) MaxLot=MaxLotTrading;
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
   return(Lot);
}
