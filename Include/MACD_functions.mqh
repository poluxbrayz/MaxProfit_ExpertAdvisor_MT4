//+------------------------------------------------------------------+
//|                                               MACD_functions.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"


int CountPeriodTrend(int Period_TF,int FastEMAPeriod,int SlowEMAPeriod,int SignalLinePeriod,int ShiftPeriods=0,string _iSymbol=NULL){
   _iSymbol = _iSymbol==NULL? iSymbol : _iSymbol;
   
   int CountPeriod=CountPeriodTrend("Up",Period_TF,FastEMAPeriod,SlowEMAPeriod,SignalLinePeriod,First_MACD_Trend,ShiftPeriods,_iSymbol);
   if(CountPeriod==0)
      CountPeriod=CountPeriodTrend("Down",Period_TF,FastEMAPeriod,SlowEMAPeriod,SignalLinePeriod,First_MACD_Trend,ShiftPeriods,_iSymbol);
      
   return CountPeriod;   
}

int CountPeriodTrend(string Trend,int Period_TF,int FastEMAPeriod,int SlowEMAPeriod,int SignalLinePeriod,double &_First_MACD_Trend,int ShiftPeriods=0,string _iSymbol=NULL){
   double MACD_Main,MACD_Signal;//,Previous_MACD_Main;
   int CountPeriodUp=0,CountPeriodDown=0;
   bool Up=true,Down=true;

   _iSymbol = _iSymbol==NULL? iSymbol : _iSymbol;
      
   if(Trend=="Up"){
      do{
         MACD_Main=iMACD(_iSymbol,Period_TF,FastEMAPeriod,SlowEMAPeriod,SignalLinePeriod,PRICE_CLOSE,MODE_MAIN,CountPeriodUp+ShiftPeriods);
         MACD_Signal=iMACD(_iSymbol,Period_TF,FastEMAPeriod,SlowEMAPeriod,SignalLinePeriod,PRICE_CLOSE,MODE_SIGNAL,CountPeriodUp+ShiftPeriods);

         if(MACD_Main>MACD_Signal){
            CountPeriodUp++;
            Up=true;
         }else{
            Up=false;
         }
         
      }while(Up==true);
      _First_MACD_Trend=MACD_Main;
      return CountPeriodUp;
   }
   else if(Trend=="Down"){
      do{
         MACD_Main=iMACD(_iSymbol,Period_TF,FastEMAPeriod,SlowEMAPeriod,SignalLinePeriod,PRICE_CLOSE,MODE_MAIN,CountPeriodDown+ShiftPeriods);
         MACD_Signal=iMACD(_iSymbol,Period_TF,FastEMAPeriod,SlowEMAPeriod,SignalLinePeriod,PRICE_CLOSE,MODE_SIGNAL,CountPeriodDown+ShiftPeriods);
         
         if(MACD_Main<MACD_Signal){
            CountPeriodDown++;
            Down=true;
         }else{
            Down=false;
         }
      }while(Down==true);
      _First_MACD_Trend=MACD_Main;
      return CountPeriodDown;
   }
   else{
      return 0;
   }
}

double MaxMACDCloseTrend(int _MACD_TF){
   string row_state;
   double MaxMACD=Select_MaxMACDCloseTrend(iSymbol,_MACD_TF,row_state);
   if(MaxMACD!=NULL && row_state=="select"){
      return MaxMACD;
   }else{
      int TotalPeriods=MathFloor(AverageDaysPeriod[_MACD_TF]*24*60/TF[_MACD_TF]),CountPeriods=0;
      if(iBars(iSymbol,ENUM_TF[_MACD_TF])<TotalPeriods) 
         TotalPeriods=iBars(iSymbol,ENUM_TF[_MACD_TF]);
      
      double MACD_Main,SumMACD=0;
      MaxMACD=0;
      int CountMACD=1;
      
      for(int i=0;i<TotalPeriods;i++){
         MACD_Main=MathAbs(iMACD(iSymbol,TF[_MACD_TF],MACD_Close_FastEMAPeriod,MACD_Close_SlowEMAPeriod,MACD_Close_SignalLinePeriod,PRICE_CLOSE,MODE_MAIN,i));
         if(MACD_Main>0 && MACD_Main>MaxMACD){
            SumMACD=SumMACD+MACD_Main;
            CountMACD++; 
            MaxMACD=SumMACD/CountMACD;
         }
      }
      
      Update_MaxMACDCloseTrend(iSymbol,_MACD_TF,MaxMACD,row_state);
      //PrintError(StringConcatenate("MaxMACDCloseTrend Symbol=",iSymbol,", _MACD_TF=",_MACD_TF),GetLastError());
      return MaxMACD;
   }   
}

string MACD_Long_Trend(int _MACD_TF_Long_Trend=4, int _MinMACDPeriod=1,int _MaxMACDPeriod=1000, int FastEMAPeriod=12,int SlowEMAPeriod=60,int SignalLinePeriod=7,int Shift=0,string _iSymbol=NULL){
   double First_MACD_Long_Trend=0;
   int Count_Long_Period_Up, Count_Long_Period_Down;
   string MACD_Long_Trend;
   _iSymbol = _iSymbol==NULL? iSymbol : _iSymbol;
                        
   //Up Conditions
   bool Up=true;
   Count_Long_Period_Up=CountPeriodTrend("Up",TF[_MACD_TF_Long_Trend],FastEMAPeriod,SlowEMAPeriod,SignalLinePeriod,First_MACD_Long_Trend,Shift,_iSymbol);
   Up=Up && Count_Long_Period_Up>=_MinMACDPeriod && Count_Long_Period_Up<=_MaxMACDPeriod;
   
   //Down Conditions
   bool Down=false;
   if(Up==false){
      Down=true;
      Count_Long_Period_Down=CountPeriodTrend("Down",TF[_MACD_TF_Long_Trend],FastEMAPeriod,SlowEMAPeriod,SignalLinePeriod,First_MACD_Long_Trend,Shift,_iSymbol);            
      Down=Down && Count_Long_Period_Down>=_MinMACDPeriod && Count_Long_Period_Down<=_MaxMACDPeriod;
   }
      
   if(Up==true) MACD_Long_Trend="Up";
	else if(Down==true) MACD_Long_Trend="Down";
	else MACD_Long_Trend="Ranging";
	
   return MACD_Long_Trend;
}
