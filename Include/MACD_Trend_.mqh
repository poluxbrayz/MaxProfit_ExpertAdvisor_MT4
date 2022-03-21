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

int FastEMAPeriod,SlowEMAPeriod,SignalLinePeriod;
int Count_Temp;
string MACD_Trend[TF_W1+1];

void Set_MACD_Params(int _MACD_TF){
   if(_MACD_TF<=TF_H1){
      if(CurrentFunction=="CheckForOpen"){
         FastEMAPeriod=12; SlowEMAPeriod=24; SignalLinePeriod=6;
      }else{
         FastEMAPeriod=12; SlowEMAPeriod=48; SignalLinePeriod=6;
      }
   }else if(_MACD_TF<=TF_H4){
      if(CurrentFunction=="CheckForOpen"){
         FastEMAPeriod=3; SlowEMAPeriod=42; SignalLinePeriod=6;
      }else{
         FastEMAPeriod=3; SlowEMAPeriod=42; SignalLinePeriod=6;
      }
   }else if(_MACD_TF<=TF_D1){
      if(CurrentFunction=="CheckForOpen"){
         FastEMAPeriod=2; SlowEMAPeriod=7; SignalLinePeriod=2;
      }else{
         FastEMAPeriod=2; SlowEMAPeriod=7; SignalLinePeriod=2;
      }
   }else if(_MACD_TF==TF_W1){
      if(CurrentFunction=="CheckForOpen"){
         FastEMAPeriod=2; SlowEMAPeriod=3; SignalLinePeriod=2;
      }else{
         FastEMAPeriod=2; SlowEMAPeriod=3; SignalLinePeriod=2;
      }
   }
}
   
string Get_MACD_Trend(int _MACD_TF,int &Count_Periods,int _FastEMAPeriod=0,int _SlowEMAPeriod=0,int _SignalLinePeriod=0,int Shift=0,string _iSymbol=NULL){
   int _MinMACDPeriod=1,_MaxMACDPeriod=1000;
   string Trend;
   _iSymbol = _iSymbol==NULL? iSymbol : _iSymbol;
   if(_FastEMAPeriod==0 && _SlowEMAPeriod==0 && _SignalLinePeriod==0){
      Set_MACD_Params(_MACD_TF);
   }else{
      FastEMAPeriod=_FastEMAPeriod;
      SlowEMAPeriod=_SlowEMAPeriod;
      SignalLinePeriod=_SignalLinePeriod;
   }                        
   
   //Up Conditions
   bool Up=true;
   Count_Periods=CountPeriodTrend("Up",TF[_MACD_TF],FastEMAPeriod,SlowEMAPeriod,SignalLinePeriod,First_MACD_Trend,Shift,_iSymbol);
   Up=Up && Count_Periods>=_MinMACDPeriod && Count_Periods<=_MaxMACDPeriod;
   
   //Down Conditions
   bool Down=false;
   if(Up==false){
      Down=true;
      Count_Periods=CountPeriodTrend("Down",TF[_MACD_TF],FastEMAPeriod,SlowEMAPeriod,SignalLinePeriod,First_MACD_Trend,Shift,_iSymbol);            
      Down=Down && Count_Periods>=_MinMACDPeriod && Count_Periods<=_MaxMACDPeriod;
   }
      
   if(Up==true) Trend="Up";
	else if(Down==true) Trend="Down";
	else Trend="Ranging";
	
   return Trend;
}


string MACD_Trend_By_Change(int _MACD_TF,int Shift=0,string _iSymbol=NULL){
   _iSymbol=_iSymbol==NULL? iSymbol : _iSymbol;
   
   int Count_Periods;   
   string Trend=Get_MACD_Trend(_MACD_TF,Count_Periods,0,0,0,Shift,_iSymbol);
   MACD_Trend[_MACD_TF]=Trend;
   string ExtraVars;   
   double RSI_LongTrend,RSI_Up_LongTrend,RSI_Down_LongTrend,RSI_Periods_LongTrend;
   double RSI_ShortTrend,RSI_Up_ShortTrend,RSI_Down_ShortTrend,RSI_Periods_ShortTrend;
   double Stochastic_Main,Stochastic_Signal;
   int KPeriod,DPeriod,Slowing;
   int Periods;
   bool _CheckZigZag;
   string _ValidateTrend;
   
   if(CurrentFunction=="CheckForOpen" || (CurrentFunction=="CheckForClose" && Trend!=Order_Trend && _MACD_TF<=TF_H4)){
      
      //Fuerza
      if(_MACD_TF<=TF_D1){
         //RSI
         if(_MACD_TF<=TF_H4){
            FirstDay=((Trend==D1MACDTrend && CountPeriodsTrend[TF_D1]<=2 && CountPeriodsTrend[TF_H4]<=12) || (Trend!=D1MACDTrend && CountPeriodsTrend[TF_H4]<=12)) && Trend!=W1Trend;

            if(CurrentFunction=="CheckForOpen"){
               if(FirstDay==true){
                  RSI_Periods_LongTrend=9; RSI_Up_LongTrend=55; RSI_Down_LongTrend=45;
                  RSI_Periods_ShortTrend=3; RSI_Up_ShortTrend=70; RSI_Down_ShortTrend=30;
               }else{
                  RSI_Periods_LongTrend=6; RSI_Up_LongTrend=55; RSI_Down_LongTrend=45;
                  RSI_Periods_ShortTrend=3; RSI_Up_ShortTrend=60; RSI_Down_ShortTrend=40;
               }
            }else if(CurrentFunction=="CheckForClose"){
               RSI_Up_LongTrend=51; RSI_Down_LongTrend=49;
               RSI_Up_ShortTrend=60; RSI_Down_ShortTrend=40;
               if(Order_Profit>=0){
                  RSI_Periods_LongTrend=6; RSI_Periods_ShortTrend=3;
               }else{
                  RSI_Periods_LongTrend=12; RSI_Periods_ShortTrend=6;
               }
            }
            
            KPeriod=12; DPeriod=12; Slowing=2;
            
         }else if(_MACD_TF==TF_D1){
            RSI_Periods_LongTrend=7; RSI_Up_LongTrend=40; RSI_Down_LongTrend=60;
            RSI_Periods_ShortTrend=2; RSI_Up_ShortTrend=60; RSI_Down_ShortTrend=40;
            
            KPeriod=7; DPeriod=7; Slowing=1;
            
         }  
         
         RSI_LongTrend=iRSI(iSymbol,TF[_MACD_TF],RSI_Periods_LongTrend,PRICE_OPEN,Shift);
         RSI_ShortTrend=iRSI(iSymbol,TF[_MACD_TF],RSI_Periods_ShortTrend,PRICE_CLOSE,Shift);
         
         if(RSI_LongTrend>=RSI_Up_LongTrend && RSI_ShortTrend>=RSI_Up_ShortTrend) RSI_Trend[_MACD_TF]="Up";
         else if(RSI_LongTrend<=RSI_Down_LongTrend && RSI_ShortTrend<=RSI_Down_ShortTrend) RSI_Trend[_MACD_TF]="Down";
         else RSI_Trend[_MACD_TF]="Ranging";
          
         //Stochastic
         Stochastic_Main=iStochastic(iSymbol,TF[_MACD_TF],KPeriod,DPeriod,Slowing,MODE_SMMA,1,MODE_MAIN,Shift);
         Stochastic_Signal=iStochastic(iSymbol,TF[_MACD_TF],KPeriod,DPeriod,Slowing,MODE_SMMA,1,MODE_SIGNAL,Shift);
         if(Stochastic_Main>Stochastic_Signal) Stochastic_Trend[_MACD_TF]="Up";
         else if(Stochastic_Main<Stochastic_Signal) Stochastic_Trend[_MACD_TF]="Down";
         else Stochastic_Trend[_MACD_TF]="Ranging";
         
         //Vars_SAR_Trend_By_Change[_MACD_TF]=StringConcatenate(TF_Label[_MACD_TF]," Trend=",Trend,", Count_Periods=",Count_Periods,", RSI_LongTrend=",RSI_LongTrend,", RSI_ShortTrend=",RSI_ShortTrend,", RSI_Trend=",RSI_Trend[_MACD_TF],", Stochastic_Trend=",Stochastic_Trend[_MACD_TF]);
         //Print(Vars_SAR_Trend_By_Change[_MACD_TF]);
                  
         if(Trend=="Up"){
            Trend=RSI_Trend[_MACD_TF]=="Up" && Stochastic_Trend[_MACD_TF]=="Up"? Trend : "Ranging";
         }else if(Trend=="Down"){
            Trend=RSI_Trend[_MACD_TF]=="Down" && Stochastic_Trend[_MACD_TF]=="Down"? Trend : "Ranging";
         }      
         
      }
      
      if(CurrentFunction=="CheckForOpen"){
         //MicroTrend==Trend 
         string MicroTrend;
         /*int MicroTrend_TF=_MACD_TF-1;
         int Count_Periods_MicroTrend;  
         int Shift_MicroTrend=Shift*TF[_MACD_TF]/TF[MicroTrend_TF];
         MicroTrend=Get_MACD_Trend(MicroTrend_TF,Count_Periods_MicroTrend,0,0,0,Shift_MicroTrend,_iSymbol);
         if(MicroTrend!=Trend){
            Trend="Ranging";
         }*/
      }
      
   }//Fuerza
   
   if(_MACD_TF==TF_H4){//H4
      
      Periods=(Trend==D1Trend)? MathMax(CountPeriodsTrend[TF_D1],1)*6 : Count_Periods;
      _CheckZigZag=CheckZigZag(Trend,_MACD_TF,Periods,Shift,_iSymbol);
      
      if(CurrentFunction=="CheckForOpen"){
         
         if(Trend==D1Trend){
            Trend=_CheckZigZag==True? Trend : "Ranging";
         }
         
         if(FirstDay==true){
            Trend=IsConstantTrend(TF_H4,Trend,Count_Periods,MathCeil(Count_Periods/2),0.1,Shift)==true? Trend : "Ranging";
         }
         
      }else if(CurrentFunction=="CheckForClose"){
         if(Trend!=Order_Trend && Order_Profit<0){
         
            Trend=Count_Periods>=6? Trend : "Ranging";
            
            Trend=_CheckZigZag==True? Trend : "Ranging";
               
         }
      }
   }
   
   if(_MACD_TF==TF_D1){//D1
      
      if(CurrentFunction=="CheckForOpen"){
         
         /*Periods=MathMax(Count_Periods,1)*6;
         _CheckZigZag=CheckZigZag(Trend,TF_H4,Periods,Shift*6,_iSymbol);
         Trend=_CheckZigZag==True? Trend : "Ranging";
         */
         
      }else if(CurrentFunction=="CheckForClose"){
            //Trend=Count_Periods<=2? Trend : "Ranging";
      }
      
      
   }      
   
   if(_MACD_TF==TF_W1){//W1
      
      int Count_Periods_D1Trend;  
      int Shift_D1Trend=Shift*7;
      string _D1Trend[2];
      _D1Trend[0]=Get_MACD_Trend(TF_D1,Count_Periods_D1Trend,0,0,0,Shift_D1Trend,_iSymbol);
      _D1Trend[1]=Get_MACD_Trend(TF_D1,Count_Periods_D1Trend,0,0,0,1+Shift_D1Trend,_iSymbol);
      
      /*if(Count_Periods_D1Trend<5){
         for(int i=1+Count_Periods_D1Trend;i<7;i++){
            if(Get_MACD_Trend(TF_D1,Count_Temp,0,0,0,i+Shift_D1Trend,_iSymbol)==_D1Trend) 
               Count_Periods_D1Trend++;   
         }
      }
      
      Trend=Count_Periods_D1Trend>=5? Trend : "Ranging";
      MACD_Trend[_MACD_TF]=Trend;
      Count_Periods=1;
      */
      
      Trend=Trend==_D1Trend[0] || Trend==_D1Trend[1]? Trend : "Ranging";
      
      
      /*_CheckZigZag=CheckZigZag(Trend,TF_H4,5*6,Shift*7*6,_iSymbol);
      Trend=_CheckZigZag==True? Trend : "Ranging";
      */          
      //ExtraVars=StringConcatenate(", W1ChangeTrend=",W1ChangeTrend);
   }
   
   //ValidateTrend
   _ValidateTrend=ValidateTrend(Trend,_MACD_TF,Count_Periods,Shift,_iSymbol);
   
   
   CountPeriodsTrend[_MACD_TF]=Count_Periods;
   
   Vars_MACD_Trend_By_Change[_MACD_TF]=StringConcatenate(TF_Label[_MACD_TF]," Trend=",Trend,", MACD_Trend=",MACD_Trend[_MACD_TF],", Count_Periods=",Count_Periods,", RSI_LongTrend=",RSI_LongTrend,", RSI_Up_LongTrend=",RSI_Up_LongTrend,", RSI_Down_LongTrend=",RSI_Down_LongTrend,", RSI_ShortTrend=",RSI_ShortTrend,", RSI_Up_ShortTrend=",RSI_Up_ShortTrend,", RSI_Down_ShortTrend=",RSI_Down_ShortTrend,", RSI_Trend=",RSI_Trend[_MACD_TF],", Stochastic_Trend=",Stochastic_Trend[_MACD_TF],", MicroTrend=",MicroTrend,", CheckZigZag=",_CheckZigZag,", ValidateTrend=",_ValidateTrend,ExtraVars);
   //Print(Vars_MACD_Trend_By_Change[_MACD_TF]);
   
   return Trend;
}