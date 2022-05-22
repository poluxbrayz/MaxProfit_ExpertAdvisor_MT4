//+------------------------------------------------------------------+
//|                                                    SAR_Trend.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

double SAR_Step,SAR_Maximun;
string SAR_Trend[TF_W1+1];
int Get_SAR_TF;

int Count_Periods_SAR_Trend(string Trend,int _MACD_TF,double _SAR_Step,double _SAR_Maximun,int Shift=0,string _iSymbol=NULL){
   if(Trend=="Ranging") return 0;
   _iSymbol=_iSymbol==NULL? iSymbol : _iSymbol;
   
   int Count_Periods=0;
   double SAR,ClosePrice;
      
   while(Count_Periods<iBars(_iSymbol,TF[_MACD_TF])){
      SAR=iSAR(_iSymbol,TF[_MACD_TF],_SAR_Step,_SAR_Maximun,Shift+Count_Periods);
      ClosePrice=iClose(_iSymbol,TF[_MACD_TF],Shift+Count_Periods);
      if((Trend=="Up" && SAR<ClosePrice) || (Trend=="Down" && SAR>ClosePrice)){
          Count_Periods++;  
      }else{
         break;
      }
      
   }
   
   return Count_Periods;
}

void Set_SAR_Params(int _MACD_TF,int ShiftM1=0){
   Get_SAR_TF=_MACD_TF;
   
   if(_MACD_TF<=TF_M15){
         SAR_Step=0.25;//1/4
         SAR_Maximun=0.25;
   }else if(_MACD_TF<=TF_H1){
      if(CurrentFunction=="CheckForOpen"){
         SAR_Step=0.14;//1/7
         SAR_Maximun=0.14;
      }else{
         SAR_Step=1;
         SAR_Maximun=1;
      }
   }else if(_MACD_TF<=TF_H4){
      if(CurrentFunction=="CheckForOpen"){
         SAR_Step=0.5;//1/2
         SAR_Maximun=0.5;
      }else{
         SAR_Step=1;
         SAR_Maximun=1;
      }
   }else if(_MACD_TF<=TF_D1){
      Get_SAR_TF=TF_H4;
      SAR_Step=0.06;  // 1/18
      SAR_Maximun=0.06;
   }else if(_MACD_TF==TF_W1){
      SAR_Step=0.14;  // 1/7
      SAR_Maximun=0.14;
      Get_SAR_TF=TF_D1;
   }
}
   
string Get_SAR_Trend(int _MACD_TF,int &Count_Periods,int ShiftM1=0,string _iSymbol=NULL,double _SAR_Step=NULL,double _SAR_Maximun=NULL){
   _iSymbol=_iSymbol==NULL? iSymbol : _iSymbol;
   
   if(_SAR_Step==NULL || _SAR_Maximun==NULL){
      Set_SAR_Params(_MACD_TF,ShiftM1);
   }else{
      SAR_Step=_SAR_Step;
      SAR_Maximun=_SAR_Maximun;
      Get_SAR_TF=_MACD_TF;
   }
   
   string Trend;
   int Shift=Get_Shift(ShiftM1,TF[Get_SAR_TF]);
   Count_Periods=Count_Periods_SAR_Trend("Up",Get_SAR_TF,SAR_Step,SAR_Maximun,Shift,_iSymbol);
   if(Count_Periods>=1){
      Trend="Up";
   }else{
      Count_Periods=Count_Periods_SAR_Trend("Down",Get_SAR_TF,SAR_Step,SAR_Maximun,Shift,_iSymbol);
      if(Count_Periods>=1){
         Trend="Down";
      }else{
         Trend="Ranging";
      }
   }
      
   if(_MACD_TF==TF_H1){
      CountPeriodsH1ofH4=Count_Periods_SAR_Trend(Trend,TF_H1,0.08,0.08,Shift,_iSymbol);
   	int PrevPeriodsH1=Count_Periods_SAR_Trend(Trend,TF_H1,0.2,0.2,Shift+CountPeriodsH1ofH4,_iSymbol);
   	CountPeriodsH1ofH4_PrevPeriodsH1=CountPeriodsH1ofH4+PrevPeriodsH1;
	}
   if(_MACD_TF==TF_D1){
	   if(Get_SAR_TF==TF_H4){
   	   int PrevPeriodsH4=Count_Periods_SAR_Trend(Trend,TF_H4,0.2,0.2,Shift+Count_Periods,_iSymbol);
   	   CountPeriodsH4ofD1=Count_Periods;
   	   Count_Periods=Count_Periods+PrevPeriodsH4;
   	   CountPeriodsH4ofD1_PrevPeriodsH4=Count_Periods;
      	Count_Periods=(int)MathCeil(double(Count_Periods)/double(6));
   	}
   	//CountPeriodsH4ofD1=Count_Periods_SAR_Trend(Trend,TF_H4,0.06,0.06,Get_Shift(ShiftM1,TF[TF_H4]),_iSymbol);
	}
	if(_MACD_TF==TF_W1 && Get_SAR_TF==TF_D1){
	   MACD_Trend[TF_D1]=Get_SAR_Trend(TF_D1,CountPeriodsTrend[TF_D1],ShiftM1,_iSymbol,1.0,1.0);
	   Count_Periods=(Trend!=MACD_Trend[TF_D1])? Count_Periods-CountPeriodsTrend[TF_D1] : Count_Periods;
	   CountPeriodsD1ofW1=(Count_Periods>0)? Count_Periods : CountPeriodsD1ofW1;
	   //CountPeriodsD1ofW1=MathMin(CountPeriodsD1ofW1,21);
	   Count_Periods=(int)MathCeil(double(Count_Periods)/double(7));
	}
	CountPeriodsTrend[_MACD_TF]=Count_Periods;
	
   return Trend;

}

string SAR_Trend_By_Change(int _MACD_TF,int ShiftM1=0,string _iSymbol=NULL){
   _iSymbol=_iSymbol==NULL? iSymbol : _iSymbol;
   
   string Trend, SAR_Params;
   int Count_Periods;   
   Trend=Get_SAR_Trend(_MACD_TF,Count_Periods,ShiftM1,_iSymbol);
   MACD_Trend[_MACD_TF]=Trend;
   Set_SAR_Params(_MACD_TF,ShiftM1);
   SAR_Params=StringConcatenate(SAR_Step,",",SAR_Maximun);
   string ExtraVars;   
   string _ValidateMFI;
   Get_SAR_TF=_MACD_TF;
   
      
   if(_MACD_TF==TF_H1){//H1
      
      if(CurrentFunction=="CheckForOpen"){
      
         ExtraVars=StringConcatenate(", CountPeriodsH1ofH4=",CountPeriodsH1ofH4);
         
      }else if(CurrentFunction=="CheckForClose"){
   
      }
      
   }      
   
   if(_MACD_TF==TF_D1){//D1
      
      if(CurrentFunction=="CheckForOpen"){
      
         ExtraVars=StringConcatenate(", CountPeriodsH4ofD1=",CountPeriodsH4ofD1);
         
      }else if(CurrentFunction=="CheckForClose"){
   
      }
      
   }      
   
   if(_MACD_TF==TF_W1){//W1
      
      int Count_Periods_D1Trend;  
      string _D1Trend[3];
      MACD_Trend[TF_H4]=Get_SAR_Trend(TF_H4,CountPeriodsTrend[TF_H4],ShiftM1,_iSymbol);
      _D1Trend[2]=Get_SAR_Trend(TF_D1,Count_Periods_D1Trend,2*PERIOD_D1+ShiftM1,_iSymbol);
      _D1Trend[1]=Get_SAR_Trend(TF_D1,Count_Periods_D1Trend,1*PERIOD_D1+ShiftM1,_iSymbol);
      MACD_Trend[TF_D1]=Get_SAR_Trend(TF_D1,CountPeriodsTrend[TF_D1],ShiftM1,_iSymbol);
            
      Trend = (Trend==MACD_Trend[TF_H4] || Trend==MACD_Trend[TF_D1] || Trend==_D1Trend[1] || Trend==_D1Trend[2])? Trend : "Ranging";
      
      ExtraVars=StringConcatenate(", CountPeriodsD1ofW1=",CountPeriodsD1ofW1,", MACD_Trend[TF_H4]=",MACD_Trend[TF_H4],", MACD_Trend[TF_D1]=",MACD_Trend[TF_D1],", _D1Trend[1]=",_D1Trend[1],", _D1Trend[2]=",_D1Trend[2]);
      
   }
   
   
   
   //ValidateTrend
   _ValidateMFI=ValidateMFI(Trend,_MACD_TF,Count_Periods,ShiftM1,_iSymbol);
   
   
   Signal[_MACD_TF]=Trend;
   
   Vars_MACD_Trend_By_Change[_MACD_TF]=StringConcatenate(TF_Label[_MACD_TF],"SARTrend=",Trend,", SAR_Trend(",SAR_Params,")=",MACD_Trend[_MACD_TF],", ShiftM1=",ShiftM1,", Count_Periods=",Count_Periods,", ValidateMFI : ",_ValidateMFI,ExtraVars);
      
   
   return Trend;
}