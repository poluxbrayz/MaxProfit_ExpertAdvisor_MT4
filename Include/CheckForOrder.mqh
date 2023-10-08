//+------------------------------------------------------------------+
//|                                                CheckForOrder.mqh |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"


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
   
   M15Trend=SAR_Trend_By_Change(TF_M15,ShiftM1); 
   
   if(CurrentFunction=="CheckForClose"){
      M5Trend=SAR_Trend_By_Change(TF_M5,ShiftM1);
   }
         
}

void SetLimits(int ShiftM1=0){
   
   D1_Limit_Up=80; D1_Limit_Down=20;
   int D1_Limit_Periods=5;
   H4_Limit_Up=80; H4_Limit_Down=20;
   int H4_Limit_Periods=12;
   //int MaxPeriodsH4=30;
   int ShiftH4=Get_Shift(ShiftM1,PERIOD_H4);
   int ShiftD1=Get_Shift(ShiftM1,PERIOD_D1);
      
   D1_Limit_RSI=iRSI(iSymbol,TF[TF_D1],D1_Limit_Periods,PRICE_CLOSE,ShiftD1);
   H4_Limit_RSI=iRSI(iSymbol,TF[TF_H4],H4_Limit_Periods,PRICE_CLOSE,ShiftH4);
   
   bool IsTrend=!(CountPeriodsTrend[TF_D1]==1 && CountPeriodsH4ofD1_PrevPeriodsH4==1 && CountPeriodsTrend[TF_H4]==1 && CountPeriodsH1ofH4_PrevPeriodsH1<=3);
   
   if(!IsTrend){
      Print("SetLimits=false, IsTrend=",IsTrend,", CountPeriodsTrend[TF_D1]=",CountPeriodsTrend[TF_D1],", CountPeriodsH4ofD1_PrevPeriodsH4=",CountPeriodsH4ofD1_PrevPeriodsH4,", CountPeriodsTrend[TF_H4]=",CountPeriodsTrend[TF_H4],", CountPeriodsH1ofH4_PrevPeriodsH1=",CountPeriodsH1ofH4_PrevPeriodsH1);
   }
   
   bool IsJump=Jump(MACD_Trend[TF_H4],PERIOD_H4,4,0);
   
   IsTrend=(IsTrend==true && ForceH4Trend==true && IsJump==false);
   
   if(!IsTrend){
      Print("SetLimits=false, IsTrend=",IsTrend,", ForceH4Trend=",ForceH4Trend,", IsJump=",IsJump);
   }
   
   UnderLimitBuy=MathFloor(D1_Limit_RSI)<=D1_Limit_Up && IsTrend==true;
   OverLimitSell=MathCeil(D1_Limit_RSI)>=D1_Limit_Down && IsTrend==true;
      
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
               
               Order_Lots=Lots();
               
               SetStopLoss();
               
               SetTakeProfit(Order_Open_Price);
               
               
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
                  
                  Order_Lots=Lots();
                  
                  SetStopLoss();
                  
                  SetTakeProfit(Order_Open_Price);
                     
                  
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
            MinSpreadCloseH4=AverageSpreadNumPeriod(TF_H1,1)*4;
            
            
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
               
               
               double SpreadLastBarH4=MathAbs(SpreadNumPeriod(TF_H4,1,0,true));
               double SpreadLastBarH2=MathAbs(SpreadNumPeriod(TF_H1,2,0,true));
               double SpreadLastBarH1=MathAbs(SpreadNumPeriod(TF_H1,1,0,true));
               double AverageSpreadH1=AverageSpreadNumPeriod(TF_H1,1);
               bool CheckBBollingerH4=(CheckBBollinger(TF_H4,5,0,iSymbol)==true && SpreadLastBarH4>=AverageSpreadH1*2);
               bool CheckBBollingerH1=(CheckBBollinger(TF_H1,5,0,iSymbol)==true && (SpreadLastBarH1>=AverageSpreadH1*1.5 || (SpreadLastBarH2>=AverageSpreadH1*2 && SpreadLastBarH1>=AverageSpreadH1*0.7)));
               Print("CheckBBollingerH4=",CheckBBollingerH4,", SpreadLastBarH4=",SpreadLastBarH4,", AverageSpreadH1*2=",AverageSpreadH1*2);
               Print("CheckBBollingerH1=",CheckBBollingerH1,", SpreadLastBarH1=",SpreadLastBarH1,", AverageSpreadH1*1.5=",AverageSpreadH1*1.5,", SpreadLastBarH2=",SpreadLastBarH2,", AverageSpreadH1*2=",AverageSpreadH1*2);
               
               
               //Short Trend
               if(!(M5Trend==Order_Trend && M15Trend==Order_Trend && M30Trend==Order_Trend && H1Trend==Order_Trend && CheckBBollingerH4==false && CheckBBollingerH1==false) && MathAbs(Order_Spread)<MinSpreadCloseH4){
                  
                  if(M5Trend!=Order_Trend || M15Trend!=Order_Trend || M30Trend!=Order_Trend || H1Trend!=Order_Trend || H4Trend!=Order_Trend){
                     if( (Order_Type==OP_BUY && M5Trend=="Down") || (Order_Type==OP_SELL && M5Trend=="Up") ){
                          Close_TF=TF_M5;
                     }
                     
                     if( (Order_Type==OP_BUY && M15Trend=="Down") || (Order_Type==OP_SELL && M15Trend=="Up") ){
                          Close_TF=TF_M15;
                     }
                     
                     if( (Order_Type==OP_BUY && M30Trend=="Down") || (Order_Type==OP_SELL && M30Trend=="Up") ){
                          Close_TF=TF_M30;
                     }
                     
                     if( (Order_Type==OP_BUY && H1Trend=="Down" ) || (Order_Type==OP_SELL && H1Trend=="Up") ){
                          Close_TF=TF_H1;
                     }
                     
                     if( (Order_Type==OP_BUY && H4Trend=="Down" ) || (Order_Type==OP_SELL && H4Trend=="Up") ){
                          Close_TF=TF_H4;
                     }
                  }
                  
                  
                  if(MACD_Trend[TF_H4]==Order_Trend && (CheckBBollingerH4==true || CheckBBollingerH1==true)){
                     double SpreadM5=AverageSpreadNumPeriod(TF_M5,1);
                     Print("Order_Spread=",MathAbs(Order_Spread),", SpreadM5=",SpreadM5,", ClosePrice=",ClosePrice,", OpenOrder.Order_iClose_Price=",OpenOrder.Order_iClose_Price);
                     if(MathAbs(Order_Spread)>=SpreadM5){
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
               if( (Order_Type==OP_BUY && (H4Trend=="Down" || H1Trend=="Down") && M30Trend=="Down") || (Order_Type==OP_SELL && (H4Trend=="Up" || H1Trend=="Up") && M30Trend=="Up") ){
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
   double AverageSpreadH1=AverageSpreadNumPeriod(TF_H1);
   /*double ForceRSIH4=iRSI(iSymbol,TF[TF_H4],5,(MACD_Trend[TF_H4]=="Up"? PRICE_HIGH : PRICE_LOW),0);
   double ForceMFIH4=iMFI(iSymbol,TF[TF_H4],3,0);
   double ForceRSIH1=iRSI(iSymbol,TF[TF_H1],5,(MACD_Trend[TF_H1]=="Up"? PRICE_HIGH : PRICE_LOW),0);
   double ForceMFIH1=iMFI(iSymbol,TF[TF_H1],4,0);
   double RSIH4=iRSI(iSymbol,TF[TF_H4],4,(MACD_Trend[TF_H4]=="Up"? PRICE_HIGH : PRICE_LOW),0);
   double MFIH4=iMFI(iSymbol,TF[TF_H4],2,0);
   double RSIH1=iRSI(iSymbol,TF[TF_H1],5,(MACD_Trend[TF_H1]=="Up"? PRICE_HIGH : PRICE_LOW),0);
   double MFIH1=iMFI(iSymbol,TF[TF_H1],3,0);
   bool ForceTakeProfit=false;*/
   
   //Print("SetTakeProfit ForceRSIH4=",ForceRSIH4,", ForceMFIH4=",ForceMFIH4,", ForceRSIH1=",ForceRSIH1,", ForceMFIH1=",MFIH1);
   //Print("SetTakeProfit RSIH4=",RSIH4,", MFIH4=",MFIH4,", RSIH1=",RSIH1,", MFIH1=",MFIH1);
   
   if(MACD_Trend[TF_H1]=="Up"){ 
      //if(MathCeil(ForceRSIH4)>=70 && MathCeil(ForceMFIH4)>=70 && MathCeil(ForceRSIH1)>=70 && MathCeil(ForceMFIH1)>=70 && SumSpread4Bars[TF_H4-TF_H1]>=AverageSpreadH1*3){
      if(ForceLotUp==true){
         TakeProfit=AverageSpreadH1*1.4;
         PriceTakeProfit=NormalizeDouble(Order_Open_Price+TakeProfit,(int)MarketInfo(iSymbol,MODE_DIGITS));
      }else /*if(MathCeil(RSIH4)>=70 && MathCeil(MFIH4)>=51 && MathCeil(RSIH1)>=70 && MathCeil(MFIH1)>=60)*/{
         TakeProfit=AverageSpreadH1*0.7;
         PriceTakeProfit=NormalizeDouble(Order_Open_Price+TakeProfit,(int)MarketInfo(iSymbol,MODE_DIGITS));
      }
      //Print("SetTakeProfit: ForceTakeProfit=",ForceTakeProfit,", ForceRSIH4=",ForceRSIH4," >=70, ForceMFIH4=",ForceMFIH4," >=70, ForceRSIH1=",ForceRSIH1," >=70, ForceMFIH1=",MFIH1);
      Print("SetTakeProfit: ForceLotUp=",ForceLotUp,", TakeProfit=",TakeProfit,", PriceTakeProfit=",PriceTakeProfit);
   }
   else if(MACD_Trend[TF_H1]=="Down"){
      //if(MathFloor(ForceRSIH4)<=30 && MathFloor(ForceMFIH4)<=30 && MathFloor(ForceRSIH1)<=30 && MathFloor(ForceMFIH1)<=30 && SumSpread4Bars[TF_H4-TF_H1]<=-AverageSpreadH1*3){
      if(ForceLotDown==true){
         TakeProfit=AverageSpreadH1*1.4;
         PriceTakeProfit=NormalizeDouble(Order_Open_Price-TakeProfit,(int)MarketInfo(iSymbol,MODE_DIGITS));
      }else /*if(MathFloor(RSIH4)<=30 && MathFloor(MFIH4)<=49 && MathFloor(RSIH1)<=30 && MathFloor(MFIH1)<=40)*/{
         TakeProfit=AverageSpreadH1*0.7;
         PriceTakeProfit=NormalizeDouble(Order_Open_Price-TakeProfit,(int)MarketInfo(iSymbol,MODE_DIGITS));
      }
      Print("SetTakeProfit: ForceLotDown=",ForceLotDown,", TakeProfit=",TakeProfit,", PriceTakeProfit=",PriceTakeProfit);
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
            if(ClosePrice-OpenOrder.Order_Open_Price>=AverageH1Spread){
               if(OrderClose(Order_Ticket,OpenOrder.Order_Lots,MarketInfo(iSymbol,MODE_BID),3,White)){
               }
            }/*else{
               PriceTakeProfit=OpenOrder.Order_Open_Price+AverageH1Spread;
               if(OrderModify(Order_Ticket,OpenOrder.Order_Open_Price,OpenOrder.Order_StopLoss,PriceTakeProfit,0,Green)){
               }
            }*/   
         }else if(Order_Type==OP_SELL){
            if(OpenOrder.Order_Open_Price-ClosePrice>=AverageH1Spread){
               if(OrderClose(Order_Ticket,OpenOrder.Order_Lots,MarketInfo(iSymbol,MODE_ASK),3,White)){
               }
            }/*else{
               PriceTakeProfit=OpenOrder.Order_Open_Price-AverageH1Spread;
               if(OrderModify(Order_Ticket,OpenOrder.Order_Open_Price,OpenOrder.Order_StopLoss,PriceTakeProfit,0,Red)){
               }
            }*/
         }
         
      }
   }   
}
