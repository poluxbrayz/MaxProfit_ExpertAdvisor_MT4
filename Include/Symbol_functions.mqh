//+------------------------------------------------------------------+
//|                                             symbol_functions.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"


int SymbolsList(bool Selected=true)//Seleccionados en Observacion del Mercado
{

   ArrayFree(Symbols);

   if(IsTesting()==true){
      iSymbol=Symbol();
      if(FirstBar()==true){
         ArrayResize(Symbols,1);
         Symbols[0]=iSymbol;
      }
      return(ArraySize(Symbols));
      
   }else{
        
      for(int i=0;i<SymbolsTotal(Selected);i++){
         iSymbol=SymbolName(i,Selected);

         //Print(iSymbol," Market starting date=",MarketInfo(iSymbol,MODE_STARTING)); 
         //Print(iSymbol," The last incoming tick time=",(MarketInfo(iSymbol,MODE_TIME))); 
         
         if(MarketInfo(iSymbol,MODE_TIME)==0 || MarketInfo(iSymbol,MODE_TRADEALLOWED)==false){
            continue;
         }
         
         bool History_Data=true;
         
         for(int _MACD_TF=TF_M15;_MACD_TF<=TF_W1;_MACD_TF++){
            if(iBars(iSymbol,TF[_MACD_TF])==0){
               History_Data=false;
            }
         }
         
         if(History_Data==false){
            continue;
         }
         
         double Price=iClose(iSymbol,TF_H4,0);
         
         bool _FreeLots=true;
         double MinPrice_HighSpread=3.0;
         double _MaxLot=TotalLot()/3;
         if(Price>=MinPrice_HighSpread && MinLot()>_MaxLot){
            _FreeLots=false;
         }
         
         if(_FreeLots==true ){
            ArrayResize(Symbols,ArraySize(Symbols)+1);
            Symbols[ArraySize(Symbols)-1]=iSymbol;
         }
      }//for
      
      
      SortSymbols();   
      return(ArraySize(Symbols));
   }   
   
   
}

void SortSymbols(){
   double Change[];
   double Spread[][2];
   bool LimitOK[];
   string OrderTypes[];
   ArrayResize(Change,ArraySize(Symbols));
   ArrayResize(Spread,ArraySize(Symbols));
   ArrayResize(LimitOK,ArraySize(Symbols));
   ArrayResize(OrderTypes,ArraySize(Symbols));
   int index_Symbols,index_Spread,index_SortedSymbols;
   double MinSpread=0.000001;
   double MinChange=0.1;
   
   for(index_Symbols=0;index_Symbols<ArraySize(Symbols);index_Symbols++){
      iSymbol=Symbols[index_Symbols];
      Change[index_Symbols]=MathAbs(PeriodChange(TF_H4,1));
      Spread[index_Symbols][0]=MathAbs(SpreadNumPeriod(TF_H4,1));
      Spread[index_Symbols][1]=index_Symbols;
      
      if(Spread[index_Symbols][0]>=MinSpread && Change[index_Symbols]>=MinChange){
         CurrentFunction="CheckForOpen";

         if(FirstBar()==true){
            LimitOK[index_Symbols]=true;
            OrderTypes[index_Symbols]=OpenBuy==true? "Buy" : "Sell";
         }else{
            Change[index_Symbols]=0;
            Spread[index_Symbols][0]=0;
            LimitOK[index_Symbols]=false;
         }
      }else{
         Change[index_Symbols]=0;
         Spread[index_Symbols][0]=0;
         LimitOK[index_Symbols]=false;
      }
      
      
   }
   
   if(ArrayRange(Spread,0)>0){
      ArraySort(Spread,WHOLE_ARRAY,0,MODE_DESCEND);
   }
   
   string SortedSymbols[];
   Minutes=(int)((TimeCurrent()-TimeInit)/60);
   ArrayFree(Trends);
   
   for(index_Spread=0;index_Spread<ArrayRange(Spread,0);index_Spread++){
      index_Symbols=int(Spread[index_Spread][1]);
      
      if(Spread[index_Spread][0]>=MinSpread && Change[index_Symbols]>=MinChange && LimitOK[index_Symbols]==true){
         ArrayResize(SortedSymbols,ArraySize(SortedSymbols)+1);
         ArrayResize(Trends,ArraySize(Trends)+1);
         index_SortedSymbols=ArraySize(SortedSymbols)-1;
         SortedSymbols[index_SortedSymbols]=Symbols[index_Symbols];
         Trends[index_SortedSymbols]=StringConcatenate(OrderTypes[index_Symbols]," ",Symbols[index_Symbols]);
         if(Minutes==0 || Minutes % PERIOD_H1 == 0){
            Print(Trends[index_SortedSymbols],", Spread=",Spread[index_Spread][0],", Change=",Change[index_Symbols],"%");
         }
      }
   }
   
   ArrayFree(Symbols);
   ArrayCopy(Symbols,SortedSymbols,0,0,WHOLE_ARRAY);
   //Print("SortSymbols: ArraySize(SortedSymbols)=",ArraySize(SortedSymbols),", ArraySize(Symbols)=",ArraySize(Symbols));
}


bool FirstBar(){
   CurrentFunction="CheckForOpen";
   bool _OpenBuy[2],_OpenSell[2],_FirstBar=false;
   SetTrends(0);
   SetLimits(0);
   _OpenBuy[0]=OpenBuy;
   _OpenSell[0]=OpenSell;
   _OpenBuy[1]=false;
   _OpenSell[1]=false;
   int CountPeriodsH4=MathMax(CountPeriodsH4ofD1,CountPeriodsTrend[TF_H4]);
   //int CountPeriodsH4=CountPeriodsTrend[TF_H4];
   
   if(ArraySearch(StartedSymbols,iSymbol)==false){
      if(CountPeriodsTrend[TF_D1]==1 && CountPeriodsH4ofD1==1){
         ArrayResize(StartedSymbols,ArraySize(StartedSymbols)+1);
         StartedSymbols[ArraySize(StartedSymbols)-1]=iSymbol;
      }else{
         _FirstBar=false;
         return _FirstBar;
      }
   }
      
   if(_OpenBuy[0]==false && _OpenSell[0]==false){
   
       _FirstBar=false;
      
   }else if(IsTesting()==true){
      
      if((_OpenBuy[0]==true && objOrders.FirstOrder("Up",TF_H4,CountPeriodsH4)==true) || 
         (_OpenSell[0]==true && objOrders.FirstOrder("Down",TF_H4,CountPeriodsH4)==true)){//First bar
         _FirstBar=true;
      }
      
   }else{
         
      
      if((_OpenBuy[0]==true && objOrders.FirstOrder("Up",TF_H4,CountPeriodsH4)==true) || 
         (_OpenSell[0]==true && objOrders.FirstOrder("Down",TF_H4,CountPeriodsH4)==true)){//First bar
         _FirstBar=true;
      }
      
      
   }
   
        
   
   if(objOrders.FreeOrders()){
      
      for(MACD_TF=TF_W1;MACD_TF>=TF_M15;MACD_TF--){
         Print("iSymbol=",iSymbol,", ",Vars_MACD_Trend_By_Change[MACD_TF]);  
      }
      Print("iSymbol=",iSymbol,", W1Trend=",W1Trend,", D1Trend=",D1Trend,", H4Trend=",H4Trend,", H1Trend=",H1Trend,", M30Trend=",M30Trend,", M15Trend=",M15Trend);
      Print("iSymbol=",iSymbol,", OpenBuy=",OpenBuy,", OpenSell=",OpenSell,", D1_Limit_RSI=",D1_Limit_RSI,", D1_Limit_Up=",D1_Limit_Up,", D1_Limit_Down=",D1_Limit_Down,", H4_Limit_RSI=",H4_Limit_RSI,", H4_Limit_Up=",H4_Limit_Up,", H4_Limit_Down=",H4_Limit_Down,", FirstBar=",_FirstBar);
   }
   
   return _FirstBar;
   
}


/*
class SymbolTrend{
   public:
   string iSymbol;
   string W1Trend,D1Trend,H4Trend,H1Trend;
   double W1Change,D1Change,H12Change;
   
   void SymbolTrend(string _iSymbol,string _W1Trend,string _D1Trend,string _H4Trend,string _H1Trend){
      this.iSymbol=_iSymbol;
      this.W1Trend=_W1Trend;
      this.D1Trend=_D1Trend;
      this.H4Trend=_H4Trend;
      this.H1Trend=_H1Trend;
      this.W1Change=PeriodChange(8,1,0);
      this.D1Change=PeriodChange(7,1,0);
      this.H12Change=PeriodChange(6,3,0);
   }
}

SymbolTrend *SymbolTrends[];

void BestOpportunities(){
   
   
}*/