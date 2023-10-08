//+------------------------------------------------------------------+
//|                                             Global_functions.mqh |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"


bool Jump(string Trend,int Period_TF,int CountPeriodTrend,int Shift=0){
   if(CurrentFunction!="CheckForOpen") return false;
   bool Step=true;
   CountPeriodTrend=CountPeriodTrend<2? 2 : CountPeriodTrend;
   double SpreadJump=AverageSpreadNumPeriod(TF_H1,1)*2;
   //double StepM1,OpenPriceM1,ClosePriceM1;
   int i;
   
   /*for(i=0;i<=Period_TF*(CountPeriodTrend);i++){//M1
      OpenPriceM1=iOpen(iSymbol,PERIOD_M1,Shift*Period_TF+i);
      ClosePriceM1=iClose(iSymbol,PERIOD_M1,Shift*Period_TF+i+1);
      StepM1=(OpenPriceM1>0 && ClosePriceM1>0)? MathAbs(OpenPriceM1-ClosePriceM1) : 0;
      Step=Step && (StepM1<=SpreadJump);
      if(Step==false){
         if(Minutes==0 || Minutes % PERIOD_H4 == 0)
            Print("Jump: OpenPriceM1=",OpenPriceM1,", ClosePriceM1=",ClosePriceM1,", StepM1=",StepM1,", SpreadJump=",SpreadJump);
         break;
      }         
   }*/
         
   for(i=0;i<CountPeriodTrend;i++){
      if(Trend=="Up"){
         Step=Step && iLow(iSymbol,Period_TF,Shift+i)<=iHigh(iSymbol,Period_TF,Shift+i+1)+SpreadJump;
      }else if(Trend=="Down"){
         Step=Step && iHigh(iSymbol,Period_TF,Shift+i)>=iLow(iSymbol,Period_TF,Shift+i+1)-SpreadJump;
      }
      if(Step==false){
         Print("Jump=true: Trend=",Trend,", index=",i);
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
   //Print("SpreadNumPeriod: _MACD_TF=",_MACD_TF,", CountPeriods=",CountPeriods,", HighLow=",HighLow,", SpreadPeriod=",SpreadPeriod,", iClose=",iClose(iSymbol,TF[_MACD_TF],Shift),", iOpen=",iOpen(iSymbol,TF[_MACD_TF],CountPeriods-1+Shift));
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
            if(SpreadPeriod>0 && SpreadPeriod>=MaxSpread/20 && (CountPeriods==0 || (CountPeriods>=1 && SpreadPeriod<=AverageSpreadNumPeriod*10))){
               SumSpread+=SpreadPeriod;
               CountPeriods++;
               AverageSpreadNumPeriod=SumSpread/CountPeriods;
               
            }
            if(SpreadPeriod>MaxSpread){
                  MaxSpread=(SpreadPeriod*3+AverageSpreadNumPeriod*2)/5;
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

string IntToTF(int indexTF=0){
   string strTF="TF";
   switch(indexTF)
     {
      case 1: strTF="TF_M1"; break;
      case 2: strTF="TF_M5"; break;
      case 3: strTF="TF_M15"; break;
      case 4: strTF="TF_M30"; break;
      case 5: strTF="TF_H1"; break;
      case 6: strTF="TF_H4"; break;
      case 7: strTF="TF_D1"; break;
      case 8: strTF="TF_W1"; break;
      case 9: strTF="TF_MN1"; break;
      default: strTF="TF"; break;
     }
   return strTF;
}

void PrintError(string ErrorSource="",int Error=0){
   if(Error>0){//ERR_NO_ERROR 
      Print(ErrorSource,", Error=",Error," ",ErrorDescription(Error));
   }   
}