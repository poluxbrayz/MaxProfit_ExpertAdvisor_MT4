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
   double MFIH4=iMFI(iSymbol,TF[TF_H4],3,0);
   double MFI1H4=iMFI(iSymbol,TF[TF_H4],3,1);
   double MFI2H4=iMFI(iSymbol,TF[TF_H4],3,2);
   double RSIH4=iRSI(iSymbol,TF[TF_H4],5,(MACD_Trend[TF_D1]=="Up"? PRICE_HIGH : PRICE_LOW),0);
   double MFIH1=iMFI(iSymbol,TF[TF_H1],4,0);
   double MFI1H1=iMFI(iSymbol,TF[TF_H1],4,1);
   double MFI2H1=iMFI(iSymbol,TF[TF_H1],4,2);
   double RSIH1=iRSI(iSymbol,TF[TF_H1],5,(MACD_Trend[TF_D1]=="Up"? PRICE_HIGH : PRICE_LOW),0);
   double SpreadD1=SpreadNumPeriod(TF_H4,7,0,true);
   double SpreadH12=SpreadNumPeriod(TF_H1,12,0,true);
   double AverageH1Spread=AverageSpreadNumPeriod(TF_H1,1);
   ForceLotUp=(MACD_Trend[TF_D1]=="Up" && MFIH4>=60 && MFI1H4>=54 && MFI2H4>=49 && RSIH4>=65 && MFIH1>=65 && MFI1H1>=60 && MFI2H1>=55 && RSIH1>=65 && SpreadD1>=AverageH1Spread*3.4 && SpreadH12>=AverageH1Spread*1.6 && SumSpread4Bars[TF_H4-TF_H1]>=AverageH1Spread*2 && SumSpread4Bars[TF_H1-TF_H1]>=AverageH1Spread*1);
   ForceLotDown=(MACD_Trend[TF_D1]=="Down" && MFIH4<=40 && MFI1H4<=46 && MFI2H4<=51 && RSIH4<=35 && MFIH1<=35 && MFI1H1<=40 && MFI2H1<=45 && RSIH1<=35 && SpreadD1<=-AverageH1Spread*3.4 && SpreadH12<=-AverageH1Spread*1.6 && SumSpread4Bars[TF_H4-TF_H1]<=-AverageH1Spread*2 && SumSpread4Bars[TF_H1-TF_H1]<=-AverageH1Spread*1);
   ForceLot=(MACD_Trend[TF_D1]==W1Trend && (ForceLotUp==true || ForceLotDown==true));
   double TotalLotForce=FormatDecimals(TotalLot/3,2);
   double TotalLotNormal=FormatDecimals(TotalLot/5,2);
   TotalLotForce=(FormatDecimals(TotalLotForce/3,2)<=double(0.01))? MathMax(TotalLotForce+0.03,0.06) : TotalLotForce;
   TotalLot=(ForceLot==true)? TotalLotForce : TotalLotNormal;
   if(MACD_Trend[TF_D1]=="Up" /*&& ForceLotUp==true*/){
      Print("TotalLot: ForceLotUp=",ForceLotUp,", TotalLotForce=",TotalLotForce,", MACD_Trend[TF_D1]=",MACD_Trend[TF_D1],", MFIH4=",MFIH4,">=64, MFI1H4=",MFI1H4,">=55, MFI2H4=",MFI2H4,">=49, RSIH4=",RSIH4,">=70, MFIH1=",MFIH1,">=70, MFI1H1=",MFI1H1,">=65, MFI2H1=",MFI2H1,">=60, RSIH1=",RSIH1,">=70, SpreadD1=",SpreadD1,">=AverageH1Spread*3.6=",AverageH1Spread*3.6);
   }else /*if(ForceLotDown==true)*/{
      Print("TotalLot: ForceLotDown=",ForceLotDown,", TotalLotForce=",TotalLotForce,", MACD_Trend[TF_D1]=",MACD_Trend[TF_D1],", MFIH4=",MFIH4,"<=36, MFI1H4=",MFI1H4,"<=45, MFI2H4=",MFI2H4,"<=51, RSIH4=",RSIH4,"<=30, MFIH1=",MFIH1,"<=30, MFI1H1=",MFI1H1,"<=35, MFI2H1=",MFI2H1,"<=40, RSIH1=",RSIH1,"<=30, SpreadD1=",SpreadD1,"<=-AverageH1Spread*3.6=",-AverageH1Spread*3.6);
   }
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
   double Risk=(ForceLot==true)? 3 : 5;
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
