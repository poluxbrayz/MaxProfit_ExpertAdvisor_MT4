//+------------------------------------------------------------------+
//|                                         MACD_Trend_By_Change.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+



int CountPeriodTrend(int Period_TF,int _FastEMAPeriod,int _SlowEMAPeriod,int _SignalLinePeriod,int ShiftPeriods,string _iSymbol,string &Trend){
   ShiftPeriods = ShiftPeriods==NULL? 0 : ShiftPeriods;
   _iSymbol = _iSymbol==NULL? iSymbol : _iSymbol;
   
   Trend="Up";
   int CountPeriod=CountPeriodsMACDTrend(Trend,Period_TF,_FastEMAPeriod,_SlowEMAPeriod,_SignalLinePeriod,First_MACD_Trend,ShiftPeriods,_iSymbol);
   if(CountPeriod==0){
      Trend="Down";
      CountPeriod=CountPeriodsMACDTrend(Trend,Period_TF,_FastEMAPeriod,_SlowEMAPeriod,_SignalLinePeriod,First_MACD_Trend,ShiftPeriods,_iSymbol);
      if(CountPeriod==0){
         Trend="Ranging";
      }
   }
   
   return CountPeriod;   
}

int CountPeriodsMACDTrend(string Trend,int Period_TF,int _FastEMAPeriod,int _SlowEMAPeriod,int _SignalLinePeriod,double &_First_MACD_Trend,int Shift=0,string _iSymbol=NULL){
   double MACD_Main=0,MACD_Signal=0;//,Previous_MACD_Main;
   int CountPeriods;
   bool Up=true,Down=true;
   ENUM_APPLIED_PRICE APPLIED_PRICE;
   if(Period_TF==PERIOD_D1 && _FastEMAPeriod==7){
      APPLIED_PRICE=(Trend=="Up")? PRICE_HIGH : PRICE_LOW;
   }else{
      APPLIED_PRICE=PRICE_CLOSE;
   }
   _iSymbol = _iSymbol==NULL? iSymbol : _iSymbol;
      
   if(Trend=="Up"){
      CountPeriods=0;
      do{
         MACD_Main=iMACD(_iSymbol,Period_TF,_FastEMAPeriod,_SlowEMAPeriod,_SignalLinePeriod,APPLIED_PRICE,MODE_MAIN,CountPeriods+Shift);
         MACD_Signal=iMACD(_iSymbol,Period_TF,_FastEMAPeriod,_SlowEMAPeriod,_SignalLinePeriod,APPLIED_PRICE,MODE_SIGNAL,CountPeriods+Shift);

         if(MACD_Main>MACD_Signal){
            CountPeriods++;
            Up=true;
            /*if(Period_TF==TF[TF_H4]){
               Print("Trend=",Trend,", Period_TF=",Period_TF,", Shift=",Shift,", MACD_Main=",MACD_Main,", MACD_Signal=",MACD_Signal,", CountPeriods=",CountPeriods,", FastEMAPeriod=",_FastEMAPeriod,", SlowEMAPeriod=",_SlowEMAPeriod,", SignalLinePeriod=",_SignalLinePeriod);
            }*/
         }else{
            Up=false;
         }
         
      }while(Up==true);
      _First_MACD_Trend=MACD_Main;
      
   }
   else if(Trend=="Down"){
      CountPeriods=0;
      do{
         MACD_Main=iMACD(_iSymbol,Period_TF,_FastEMAPeriod,_SlowEMAPeriod,_SignalLinePeriod,APPLIED_PRICE,MODE_MAIN,CountPeriods+Shift);
         MACD_Signal=iMACD(_iSymbol,Period_TF,_FastEMAPeriod,_SlowEMAPeriod,_SignalLinePeriod,APPLIED_PRICE,MODE_SIGNAL,CountPeriods+Shift);
         
         if(MACD_Main<MACD_Signal){
            CountPeriods++;
            Down=true;
            /*if(Period_TF==TF[TF_H4]){
               Print("Trend=",Trend,", Period_TF=",Period_TF,", Shift=",Shift,", MACD_Main=",MACD_Main,", MACD_Signal=",MACD_Signal,", CountPeriods=",CountPeriods,", FastEMAPeriod=",_FastEMAPeriod,", SlowEMAPeriod=",_SlowEMAPeriod,", SignalLinePeriod=",_SignalLinePeriod);
            }*/
         }else{
            Down=false;
         }
      }while(Down==true);
      _First_MACD_Trend=MACD_Main;
      
   }
   else{
      CountPeriods=0;
   }
   
   //if(CountPeriods==0 && Trend=="Down")
     //Print("CountPeriodsMACDTrend: Trend=",Trend,", Period_TF=",Period_TF,", Shift=",Shift,", CountPeriods=",CountPeriods,", MACD_Main=",MACD_Main,", MACD_Signal=",MACD_Signal,", MACD_Main<MACD_Signal=",MACD_Main<MACD_Signal);
   
   return CountPeriods;
}


void Set_MACD_Params(int _MACD_TF){
   Get_MACD_TF=_MACD_TF;
   
   if(_MACD_TF<=TF_H1){
      if(CurrentFunction=="CheckForOpen"){
         FastEMAPeriod=4; SlowEMAPeriod=12; SignalLinePeriod=4;
      }else{
         FastEMAPeriod=4; SlowEMAPeriod=12; SignalLinePeriod=4;
      }
   }else if(_MACD_TF<=TF_H4){
      if(CurrentFunction=="CheckForOpen"){
         FastEMAPeriod=4; SlowEMAPeriod=6; SignalLinePeriod=4;
      }else{
         FastEMAPeriod=4; SlowEMAPeriod=6; SignalLinePeriod=4;
      }
   }else if(_MACD_TF<=TF_D1){
      if(CurrentFunction=="CheckForOpen"){
         if(MACD_Trend[TF_W1]==MACD_Trend[TF_H4] && (iHighest(iSymbol,TF[TF_D1],MODE_HIGH,7)==0 || iLowest(iSymbol,TF[TF_D1],MODE_LOW,7)==0)){
            FastEMAPeriod=12; SlowEMAPeriod=24; SignalLinePeriod=5; Get_MACD_TF=TF_H4;//TF_H4
         }else{
            FastEMAPeriod=3; SlowEMAPeriod=7; SignalLinePeriod=3;//TF_D1
         }
      }else{
         FastEMAPeriod=7; SlowEMAPeriod=14; SignalLinePeriod=6;
      }
   }else if(_MACD_TF==TF_W1){
      if(CurrentFunction=="CheckForOpen"){
         FastEMAPeriod=7; SlowEMAPeriod=MathMin(MathMax(CountPeriodsD1ofW1,14),21); SignalLinePeriod=6;//TF_D1
      }else{
         FastEMAPeriod=7; SlowEMAPeriod=MathMin(MathMax(CountPeriodsD1ofW1,14),21); SignalLinePeriod=6;//TF_D1
      }
      Get_MACD_TF=TF_D1;
   }
}
   
string Get_MACD_Trend(int _MACD_TF,int &Count_Periods,int _FastEMAPeriod=0,int _SlowEMAPeriod=0,int _SignalLinePeriod=0,int ShiftM1=0,string _iSymbol=NULL){
   int _MinMACDPeriod=1,_MaxMACDPeriod=1000;
   string Trend;
   _iSymbol = _iSymbol==NULL? iSymbol : _iSymbol;
   if(_FastEMAPeriod==0 && _SlowEMAPeriod==0 && _SignalLinePeriod==0){
      Set_MACD_Params(_MACD_TF);
   }else{
      FastEMAPeriod=_FastEMAPeriod;
      SlowEMAPeriod=_SlowEMAPeriod;
      SignalLinePeriod=_SignalLinePeriod;
      Get_MACD_TF=_MACD_TF;
   }                        
      
   //Print("_MACD_TF=",_MACD_TF,", Get_MACD_TF=",Get_MACD_TF,", CurrentFunction=",CurrentFunction);
   
   //Up Conditions
   bool Up=true;
   Count_Periods=CountPeriodsMACDTrend("Up",TF[Get_MACD_TF],FastEMAPeriod,SlowEMAPeriod,SignalLinePeriod,First_MACD_Trend,Get_Shift(ShiftM1,TF[Get_MACD_TF]),_iSymbol);
   Up=Up && Count_Periods>=_MinMACDPeriod && Count_Periods<=_MaxMACDPeriod;
   
   //Down Conditions
   bool Down=false;
   if(Up==false){
      Down=true;
      Count_Periods=CountPeriodsMACDTrend("Down",TF[Get_MACD_TF],FastEMAPeriod,SlowEMAPeriod,SignalLinePeriod,First_MACD_Trend,Get_Shift(ShiftM1,TF[Get_MACD_TF]),_iSymbol);            
      Down=Down && Count_Periods>=_MinMACDPeriod && Count_Periods<=_MaxMACDPeriod;
   }
      
   if(Up==true) Trend="Up";
	else if(Down==true) Trend="Down";
	else Trend="Ranging";
	
	if(_MACD_TF==TF_D1){
	   if(Get_MACD_TF==TF_H4){
   	   int PrevPeriodsH4=CountPeriodsMACDTrend(Trend,TF[TF_H4],4,12,4,First_MACD_Trend,Get_Shift(ShiftM1,TF[Get_MACD_TF])+Count_Periods,_iSymbol);
   	   Count_Periods=Count_Periods+PrevPeriodsH4;
   	   Count_Periods=(int)MathCeil(double(Count_Periods)/double(6));
   	}
   	CountPeriodsH4ofD1=CountPeriodsMACDTrend(Trend,TF[TF_D1],4,7,3,First_MACD_Trend,Get_Shift(ShiftM1,TF[TF_D1]),_iSymbol)*6;
	}
	if(_MACD_TF==TF_W1 && Get_MACD_TF==TF_D1){
	   int PrevPeriodsD1=CountPeriodsMACDTrend(Trend,TF[Get_MACD_TF],3,7,2,First_MACD_Trend,Get_Shift(ShiftM1,TF[Get_MACD_TF])+Count_Periods,_iSymbol);
	   //Print("_MACD_TF==TF_W1 && Get_MACD_TF==TF_D1, Count_Periods=",Count_Periods,", PrevPeriodsD1=",PrevPeriodsD1);
	   Count_Periods=Count_Periods+PrevPeriodsD1;
	   CountPeriodsD1ofW1=(Count_Periods>0)? Count_Periods : CountPeriodsD1ofW1;
	   //CountPeriodsD1ofW1=MathMin(CountPeriodsD1ofW1,21);
	   Count_Periods=(int)MathCeil(double(Count_Periods)/double(7));
	}
	CountPeriodsTrend[_MACD_TF]=Count_Periods;
	
   return Trend;
}


string MACD_Trend_By_Change(int _MACD_TF,int ShiftM1=0,string _iSymbol=NULL){
   _iSymbol=_iSymbol==NULL? iSymbol : _iSymbol;
   
   string Trend, MACD_Params;
   int Count_Periods;   
   Trend=Get_MACD_Trend(_MACD_TF,Count_Periods,0,0,0,ShiftM1,_iSymbol);
   MACD_Trend[_MACD_TF]=Trend;
   CountPeriodsTrend[_MACD_TF]=Count_Periods;
   MACD_Params=StringConcatenate(FastEMAPeriod,",",SlowEMAPeriod,",",SignalLinePeriod);
   string ExtraVars;   
   double Bears,Bulls;
   int PowerPeriods=0;
   string _ValidateMFI;
   Get_MACD_TF=_MACD_TF;
   
   //TF_W1
   if(_MACD_TF<=TF_W1){
      
      if(_MACD_TF<=TF_M15){

         if(CurrentFunction=="CheckForOpen"){
            PowerPeriods=8;
            
         }else if(CurrentFunction=="CheckForClose"){
            PowerPeriods=8;
         }
         
      }else if(_MACD_TF<=TF_H1){

         if(CurrentFunction=="CheckForOpen"){
            PowerPeriods=12;
            
         }else if(CurrentFunction=="CheckForClose"){
            PowerPeriods=12;
         }
         
      }else if(_MACD_TF<=TF_H4){
      
         if(CurrentFunction=="CheckForOpen"){
            PowerPeriods=12;
            
         }else if(CurrentFunction=="CheckForClose"){
            PowerPeriods=12;
         }
         
      }else if(_MACD_TF==TF_D1){
         
         if(CurrentFunction=="CheckForOpen"){
            PowerPeriods = (MACD_Trend[TF_D1]==MACD_Trend[TF_W1])? 3 : 5; 
                           
         }else if(CurrentFunction=="CheckForClose"){
            PowerPeriods = (MACD_Trend[TF_D1]==MACD_Trend[TF_W1])? 3 : 5; 
         }
         
      }else if(_MACD_TF==TF_W1){
         PowerPeriods = 5; 
         Get_MACD_TF=TF_D1;
      }
       
      
      Bulls=iBullsPower(_iSymbol,TF[Get_MACD_TF],PowerPeriods,PRICE_OPEN,Get_Shift(ShiftM1,TF[Get_MACD_TF])); 
      Bears=iBearsPower(_iSymbol,TF[Get_MACD_TF],PowerPeriods,PRICE_OPEN,Get_Shift(ShiftM1,TF[Get_MACD_TF]));     
         
      if(Trend=="Up"){
         
         Trend = Bulls>-Bears? Trend : "Ranging";
         
      }else if(Trend=="Down"){
         
         Trend = Bears<-Bulls? Trend : "Ranging";
         
      }      
      
   }//TF_W1
      
      
   
   
   if(_MACD_TF==TF_D1){//D1
      
      if(CurrentFunction=="CheckForOpen"){
      
         ExtraVars=StringConcatenate(", CountPeriodsH4ofD1=",CountPeriodsH4ofD1);
         
      }else if(CurrentFunction=="CheckForClose"){
      }
      
   }      
   
   if(_MACD_TF==TF_W1){//W1
      
      int Count_Periods_D1Trend;  
      string _D1Trend[3];
      MACD_Trend[TF_H4]=Get_MACD_Trend(TF_H4,CountPeriodsTrend[TF_H4],4,18,4,ShiftM1,_iSymbol);
      _D1Trend[2]=Get_MACD_Trend(TF_D1,Count_Periods_D1Trend,3,7,2,2*PERIOD_D1+ShiftM1,_iSymbol);
      _D1Trend[1]=Get_MACD_Trend(TF_D1,Count_Periods_D1Trend,3,7,2,1*PERIOD_D1+ShiftM1,_iSymbol);
      MACD_Trend[TF_D1]=Get_MACD_Trend(TF_D1,CountPeriodsTrend[TF_D1],3,7,2,ShiftM1,_iSymbol);
      
      Trend = (Trend==MACD_Trend[TF_H4] || Trend==MACD_Trend[TF_D1] || Trend==_D1Trend[1] || Trend==_D1Trend[2])? Trend : "Ranging";
      
      ExtraVars=StringConcatenate(", CountPeriodsD1ofW1=",CountPeriodsD1ofW1,", MACD_Trend[TF_H4]=",MACD_Trend[TF_H4],", MACD_Trend[TF_D1]=",MACD_Trend[TF_D1],", _D1Trend[1]=",_D1Trend[1],", _D1Trend[2]=",_D1Trend[2]);
      
   }
   
   
   //ValidateTrend
   _ValidateMFI=ValidateMFI(Trend,_MACD_TF,Count_Periods,ShiftM1,_iSymbol);
   
   
   Signal[_MACD_TF]=Trend;
   
   Vars_MACD_Trend_By_Change[_MACD_TF]=StringConcatenate(TF_Label[_MACD_TF],"MACDTrend=",Trend,", MACD_Trend(",MACD_Params,")=",MACD_Trend[_MACD_TF],", ShiftM1=",ShiftM1,", Count_Periods=",Count_Periods,", Bulls=",Bulls,", Bears=",Bears,", PowerPeriods=",PowerPeriods,", ValidateMFI : ",_ValidateMFI,ExtraVars);
      
   return Trend;
}