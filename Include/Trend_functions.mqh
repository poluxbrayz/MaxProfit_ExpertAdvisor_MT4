//+------------------------------------------------------------------+
//|                                               MACD_functions.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"



string ValidateForce(string &Trend,int _MACD_TF,int Count_Periods,int ShiftM1,string _iSymbol){
   int MFITotal_TF=0,MFITotal_Periods=0,MFITotal_Up=0,MFITotal_Down=0,RSITotal_Up=0,RSITotal_Down=0;
   int MFILastPeriod_TF=0,MFILastPeriod_Periods=0,MFILastPeriod_Up=0,MFILastPeriod_Down=0,RSILastPeriod_Up=0,RSILastPeriod_Down=0;
   bool MFI_Force=false;
   bool _IsConstantTrend=false;
   
   
   if(CurrentFunction=="CheckForOpen"){
      if(_MACD_TF<=TF_H4 && _MACD_TF>=TF_H1){

         int Periods=(MACD_Trend[TF_D1]!=MACD_Trend[TF_W1])? MathMax(7-CountPeriodsTrend[TF_D1],4)*6 : MathMax(6-CountPeriodsTrend[TF_D1],4)*6;
         if(CheckZigZag(MACD_Trend[TF_H4],TF_H4,Periods,ShiftM1,_iSymbol)==false){
            Print("MFI_Force=true, CheckZigZag(TF_H4,",Periods,",",ShiftM1,",",_iSymbol,")=false");
            MFI_Force=true;
         }
        
         if(MACD_Trend[_MACD_TF]!=D1Trend){
            Print("MFI_Force=true, MACD_Trend[",_MACD_TF,"]!=D1Trend");
            MFI_Force=true;
         }
      }
      
      if(_MACD_TF<=TF_H1){
         
         if(MFI_Force==false){
            MFITotal_TF=TF_H1; MFITotal_Periods=3; MFITotal_Up=40; MFITotal_Down=60; RSITotal_Up=51; RSITotal_Down=49;
            MFILastPeriod_TF=TF_H1; MFILastPeriod_Periods=2; MFILastPeriod_Up=40; MFILastPeriod_Down=60; RSILastPeriod_Up=60; RSILastPeriod_Down=40;
         }else{
            MFITotal_TF=TF_H4; MFITotal_Periods=5; MFITotal_Up=20; MFITotal_Down=80; RSITotal_Up=60; RSITotal_Down=40;
            MFILastPeriod_TF=TF_H1; MFILastPeriod_Periods=4; MFILastPeriod_Up=40; MFILastPeriod_Down=60; RSILastPeriod_Up=65; RSILastPeriod_Down=35;
         }
      }
      else if(_MACD_TF==TF_H4){
         if(MFI_Force==false){
            MFITotal_TF=TF_H4; MFITotal_Periods=2; MFITotal_Up=40; MFITotal_Down=60; RSITotal_Up=51; RSITotal_Down=49;
            MFILastPeriod_TF=TF_H1; MFILastPeriod_Periods=2; MFILastPeriod_Up=40; MFILastPeriod_Down=60; RSILastPeriod_Up=60; RSILastPeriod_Down=40;
         }else{
            MFITotal_TF=TF_H4; MFITotal_Periods=5; MFITotal_Up=20; MFITotal_Down=80; RSITotal_Up=60; RSITotal_Down=40;
            MFILastPeriod_TF=TF_H1; MFILastPeriod_Periods=4; MFILastPeriod_Up=40; MFILastPeriod_Down=60; RSILastPeriod_Up=65; RSILastPeriod_Down=35;
         }
      }
      else if(_MACD_TF==TF_D1){ 

         if(Trend!=W1Trend){
            if(CheckZigZag(MACD_Trend[TF_D1],TF_D1,6,ShiftM1,_iSymbol)==true){
               MFITotal_TF=TF_H4; MFITotal_Periods=3; MFITotal_Up=30; MFITotal_Down=70; RSITotal_Up=40; RSITotal_Down=60;
               MFILastPeriod_TF=TF_H1; MFILastPeriod_Periods=4; MFILastPeriod_Up=40; MFILastPeriod_Down=60; RSILastPeriod_Up=51; RSILastPeriod_Down=49;
            }else{
               if(MACD_Trend[TF_D1]==MACD_Trend[TF_W1] && CountPeriodsTrend[TF_W1]>=2){
                  MFITotal_TF=TF_H4; MFITotal_Periods=6;
               }else{
                  MFITotal_TF=TF_H4; MFITotal_Periods=6;
               }
               MFITotal_Up=10; MFITotal_Down=90; RSITotal_Up=60; RSITotal_Down=40;
               MFILastPeriod_TF=TF_H4; MFILastPeriod_Periods=5; MFILastPeriod_Up=20; MFILastPeriod_Down=80; RSILastPeriod_Up=65; RSILastPeriod_Down=35;
            }
            
         }else{
            MFITotal_TF=TF_D1; MFITotal_Periods=2; MFITotal_Up=10; MFITotal_Down=90; RSITotal_Up=51; RSITotal_Down=49;
            MFILastPeriod_TF=TF_H1; MFILastPeriod_Periods=4; MFILastPeriod_Up=40; MFILastPeriod_Down=60; RSILastPeriod_Up=60; RSILastPeriod_Down=40;
         }
          
      }
      else if(_MACD_TF==TF_W1){ 
         MFITotal_TF=TF_D1; MFILastPeriod_TF=TF_D1; 
         
         if(MACD_Trend[TF_W1]==MACD_Trend[TF_H4]){
            MFITotal_Periods=6; MFITotal_Up=52; MFITotal_Down=48; RSITotal_Up=52; RSITotal_Down=48;
            MFILastPeriod_Periods=3; MFILastPeriod_Up=52; MFILastPeriod_Down=48; RSILastPeriod_Up=60; RSILastPeriod_Down=40;
         }else{
            MFITotal_Periods=7; MFITotal_Up=52; MFITotal_Down=48;
            MFILastPeriod_Periods=3; MFILastPeriod_Up=52; MFILastPeriod_Down=48;
         }
         
      }
      
   }else if(CurrentFunction=="CheckForClose" && Trend!=Order_Trend){
      if(_MACD_TF<=TF_H1){
         MFITotal_TF=_MACD_TF; MFITotal_Periods=3; MFITotal_Up=40; MFITotal_Down=60; RSITotal_Up=51; RSITotal_Down=49;
         MFILastPeriod_TF=_MACD_TF; MFILastPeriod_Periods=3; MFILastPeriod_Up=40; MFILastPeriod_Down=60; RSILastPeriod_Up=51; RSILastPeriod_Down=49;
      }
      else if(_MACD_TF<=TF_H4){
         MFITotal_TF=TF_H4; MFITotal_Periods=3; MFITotal_Up=40; MFITotal_Down=60; RSITotal_Up=51; RSITotal_Down=49;
         MFILastPeriod_TF=TF_H1; MFILastPeriod_Periods=3; MFILastPeriod_Up=40; MFILastPeriod_Down=60; RSILastPeriod_Up=51; RSILastPeriod_Down=49;
      }
      else if(_MACD_TF<=TF_D1){ 
         MFITotal_TF=TF_D1; MFITotal_Periods=2; MFITotal_Up=10; MFITotal_Down=90; RSITotal_Up=46; RSITotal_Down=54;
         MFILastPeriod_TF=TF_H4; MFILastPeriod_Periods=5; MFILastPeriod_Up=55; MFILastPeriod_Down=45; RSILastPeriod_Up=60; RSILastPeriod_Down=40;
      }
      else if(_MACD_TF<=TF_W1){ 
         MFITotal_TF=TF_D1; MFITotal_Periods=5; MFITotal_Up=40; MFITotal_Down=60; RSITotal_Up=55; RSITotal_Down=45;
         MFILastPeriod_TF=TF_D1; MFILastPeriod_Periods=3; MFILastPeriod_Up=51; MFILastPeriod_Down=49; RSILastPeriod_Up=55; RSILastPeriod_Down=45;
      }
      
   }else if(CurrentFunction=="CheckForClose" && Trend==Order_Trend){
      if(_MACD_TF<=TF_H1){
         MFITotal_TF=_MACD_TF; MFITotal_Periods=3; MFITotal_Up=70; MFITotal_Down=30;
         MFILastPeriod_TF=_MACD_TF; MFILastPeriod_Periods=3; MFILastPeriod_Up=70; MFILastPeriod_Down=30;
      }
      else if(_MACD_TF<=TF_H4){
         MFITotal_TF=TF_H4; MFITotal_Periods=3; MFITotal_Up=55; MFITotal_Down=45;
         MFILastPeriod_TF=TF_H4; MFILastPeriod_Periods=3; MFILastPeriod_Up=55; MFILastPeriod_Down=45;
      }
      else if(_MACD_TF<=TF_D1){//Close H4 
         MFITotal_TF=TF_H4; MFITotal_Periods=4; MFITotal_Up=60; MFITotal_Down=40;
         MFILastPeriod_TF=TF_H1; MFILastPeriod_Periods=3; MFILastPeriod_Up=70; MFILastPeriod_Down=30;
      }
      else if(_MACD_TF<=TF_W1){//Close H4
         MFITotal_TF=TF_D1; MFITotal_Periods=4; MFITotal_Up=51; MFITotal_Down=49;
         MFILastPeriod_TF=TF_D1; MFILastPeriod_Periods=3; MFILastPeriod_Up=60; MFILastPeriod_Down=40;
      }
   }
   //MFI
   MFITotal[_MACD_TF]=iMFI(_iSymbol,TF[MFITotal_TF],MFITotal_Periods,Get_Shift(ShiftM1,TF[MFITotal_TF]));
   MFILastPeriod[_MACD_TF]=iMFI(_iSymbol,TF[MFILastPeriod_TF],MFILastPeriod_Periods,Get_Shift(ShiftM1,TF[MFILastPeriod_TF]));
   
   MFI_Trend[_MACD_TF]="Ranging";
   if(MACD_Trend[_MACD_TF]=="Up") MFI_Trend[_MACD_TF]=(MathCeil(MFITotal[_MACD_TF])>=MFITotal_Up && MathCeil(MFILastPeriod[_MACD_TF])>=MFILastPeriod_Up)? "Up" : MFI_Trend[_MACD_TF];
   if(MACD_Trend[_MACD_TF]=="Down") MFI_Trend[_MACD_TF]=(MathFloor(MFITotal[_MACD_TF])<=MFITotal_Down && MathFloor(MFILastPeriod[_MACD_TF])<=MFILastPeriod_Down)? "Down" : MFI_Trend[_MACD_TF];
   
   //RSI
   RSITotal[_MACD_TF]=iRSI(_iSymbol,TF[MFITotal_TF],MFITotal_Periods,(Trend=="Up"? PRICE_HIGH: PRICE_LOW),Get_Shift(ShiftM1,TF[MFITotal_TF]));
   RSILastPeriod[_MACD_TF]=iRSI(_iSymbol,TF[MFILastPeriod_TF],MFILastPeriod_Periods,(Trend=="Up"? PRICE_HIGH: PRICE_LOW),Get_Shift(ShiftM1,TF[MFILastPeriod_TF]));
   
    
   RSI_Trend[_MACD_TF]="Ranging";
   if(MACD_Trend[_MACD_TF]=="Up"){
      RSITotal_Up=RSITotal_Up>0? RSITotal_Up : MFITotal_Up;
      RSILastPeriod_Up=RSILastPeriod_Up>0? RSILastPeriod_Up : MFILastPeriod_Up;
      RSI_Trend[_MACD_TF]=(MathCeil(RSITotal[_MACD_TF])>=RSITotal_Up && MathCeil(RSILastPeriod[_MACD_TF])>=RSILastPeriod_Up)? "Up" : RSI_Trend[_MACD_TF];
   }
   if(MACD_Trend[_MACD_TF]=="Down"){
      RSITotal_Down=RSITotal_Down>0? RSITotal_Down : MFITotal_Down;
      RSILastPeriod_Down=RSILastPeriod_Down>0? RSILastPeriod_Down : MFILastPeriod_Down;
      RSI_Trend[_MACD_TF]=(MathFloor(RSITotal[_MACD_TF])<=RSITotal_Down && MathFloor(RSILastPeriod[_MACD_TF])<=RSILastPeriod_Down)? "Down" : RSI_Trend[_MACD_TF];
   }
   
   if(MACD_Trend[_MACD_TF]=="Up") Trend=(MFI_Trend[_MACD_TF]=="Up" && RSI_Trend[_MACD_TF]=="Up")? Trend : "Ranging";
   if(MACD_Trend[_MACD_TF]=="Down") Trend=(MFI_Trend[_MACD_TF]=="Down" && RSI_Trend[_MACD_TF]=="Down")? Trend : "Ranging";
   
   //ForceH4Trend
   if(CurrentFunction=="CheckForOpen"){
      //if(_MACD_TF<=TF_D1){
         ForceH4Trend=false;
         double RSI_H4=iRSI(_iSymbol,TF[TF_H4],5,(MACD_Trend[TF_H4]=="Up"? PRICE_HIGH : PRICE_LOW),Get_Shift(ShiftM1,TF[TF_H4]));
         double RSI_H1=iRSI(_iSymbol,TF[TF_H1],5,(MACD_Trend[TF_H4]=="Up"? PRICE_HIGH : PRICE_LOW),Get_Shift(ShiftM1,TF[TF_H1]));
         double RSI_M30=iRSI(_iSymbol,TF[TF_M30],5,(MACD_Trend[TF_H4]=="Up"? PRICE_HIGH : PRICE_LOW),Get_Shift(ShiftM1,TF[TF_M30]));
         double MFI_H4=iMFI(_iSymbol,TF[TF_H4],3,Get_Shift(ShiftM1,TF[TF_H4]));
         double MFI_H1=iMFI(_iSymbol,TF[TF_H1],4,Get_Shift(ShiftM1,TF[TF_H1]));
         double MFI_M30=iMFI(_iSymbol,TF[TF_M30],5,Get_Shift(ShiftM1,TF[TF_M30]));
         if(MACD_Trend[TF_H4]=="Up"){
            ForceH4Trend=(MathCeil(RSI_H4)>=60 && MathCeil(MFI_H4)>=60 && MathCeil(RSI_H1)>=65 && MathCeil(MFI_H1)>=60 && MathCeil(RSI_M30)>=65 && MathCeil(MFI_M30)>=60)? true:false;
         }else if(MACD_Trend[TF_H4]=="Down"){
            ForceH4Trend=(MathFloor(RSI_H4)<=40 && MathFloor(MFI_H4)<=40 && MathFloor(RSI_H1)<=35 && MathFloor(MFI_H1)<=40 && MathFloor(RSI_M30)<=35 && MathFloor(MFI_M30)<=40)? true:false;
         }
         
         if(_MACD_TF==TF_D1){
            Print("ForceH4Trend=",ForceH4Trend,", MACD_Trend[TF__H4]=",MACD_Trend[TF_H4],", RSI_H4=",RSI_H4,", MFI_H4=",MFI_H4,", RSI_H1=",RSI_H1,", MFI_H1=",MFI_H1,", RSI_M30=",RSI_M30,", MFI_M30=",MFI_M30);
         }
         
      //}
      
   }  
   
   if(_MACD_TF>=TF_D1){
      if(_MACD_TF==TF_W1){
         W1Trend=Trend;
      } 
      if(CurrentFunction=="CheckForOpen" && MACD_Trend[_MACD_TF]==MACD_Trend[TF_H4] && Trend!="Ranging"){
         _IsConstantTrend=IsConstantTrend(MACD_Trend[_MACD_TF],MathMin(MFITotal_Periods,7),ShiftM1);     
         Trend=(_IsConstantTrend==true)? Trend : "Ranging";
      }
      if(CurrentFunction=="CheckForClose" && Trend!=Order_Trend){
         Trend=(CheckZigZag(MACD_Trend[TF_D1],TF_D1,2,ShiftM1,_iSymbol)==True)?  Trend : "Ranging";
      }
   }
   
   string MFITotal_Limit=(MACD_Trend[_MACD_TF]=="Up")? StringConcatenate(", MFITotal_Up=",MFITotal_Up,", RSITotal_Up=",RSITotal_Up) : StringConcatenate(", MFITotal_Down=",MFITotal_Down,", RSITotal_Down=",RSITotal_Down);
   string MFILastPeriod_Limit=(MACD_Trend[_MACD_TF]=="Up")? StringConcatenate(", MFILastPeriod_Up=",MFILastPeriod_Up,", RSILastPeriod_Up=",RSILastPeriod_Up) : StringConcatenate(", MFILastPeriod_Down=",MFILastPeriod_Down,", RSILastPeriod_Down=",RSILastPeriod_Down);
   
   return StringConcatenate("MFI_Trend[",_MACD_TF,"]=",MFI_Trend[_MACD_TF],", MFITotal[",_MACD_TF,"]=",MFITotal[_MACD_TF],", MFILastPeriod[",_MACD_TF,"]=",MFILastPeriod[_MACD_TF],", RSI_Trend[",_MACD_TF,"]=",RSI_Trend[_MACD_TF],", RSITotal[",_MACD_TF,"]=",RSITotal[_MACD_TF],", RSILastPeriod[",_MACD_TF,"]=",RSILastPeriod[_MACD_TF],", MFITotal_Periods=",MFITotal_Periods,", MFILastPeriod_Periods=",MFILastPeriod_Periods,MFITotal_Limit,MFILastPeriod_Limit,", Count_Periods=",Count_Periods,", MFI_Force=",MFI_Force,", _IsConstantTrend=",_IsConstantTrend);
}

bool CheckBBollinger(int _MACD_TF,int BB_Periods=5,int ShiftM1=0,string _iSymbol=NULL){
   _iSymbol=_iSymbol==NULL? iSymbol : _iSymbol;
   BB_Periods=MathMax(BB_Periods,5);
   int Shift=Get_Shift(ShiftM1,TF[_MACD_TF]);
   double Band_Lower,Band_Upper,Price;
   Vars_BBollinger[_MACD_TF]="";
   
   if(_MACD_TF<=TF_D1){
        
      if(MACD_Trend[_MACD_TF]=="Up"){
         //Trend Up    
            
         Price=iHigh(_iSymbol,TF[_MACD_TF],Shift);  
         Band_Upper=iBands(_iSymbol,TF[_MACD_TF],BB_Periods,2,0,PRICE_CLOSE,MODE_UPPER,Shift);
         Vars_BBollinger[_MACD_TF]=StringConcatenate("CheckBBollinger=",Price>Band_Upper,", BBollinger[",_MACD_TF,"]=Up, Price=",Price,", Band_Upper=",Band_Upper);
         Print(Vars_BBollinger[_MACD_TF]);
                           
         if(Price>=Band_Upper){//"Up"
            //Print("Vars_BBollinger[",_MACD_TF,"]=",Vars_BBollinger[_MACD_TF]);
            return true;
         }   
         
      }else if(MACD_Trend[_MACD_TF]=="Down"){
      
         //Trend Down
         Price=iLow(_iSymbol,TF[_MACD_TF],Shift);
         Band_Lower=iBands(_iSymbol,TF[_MACD_TF],BB_Periods,2,0,PRICE_CLOSE,MODE_LOWER,Shift);
         Vars_BBollinger[_MACD_TF]=StringConcatenate("CheckBBollinger=",Price<Band_Lower,", BBollinger[",_MACD_TF,"]=Down, Price=",Price,", Band_Lower=",Band_Lower);
         Print(Vars_BBollinger[_MACD_TF]);
         
         if(Price<=Band_Lower){//"Down";
            //Print("Vars_BBollinger[",_MACD_TF,"]=",Vars_BBollinger[_MACD_TF]);
            return true;
         }
                             
      }//else
   }
   
   return false;

}

bool CheckZigZag(string Trend,int _MACD_TF,int Count_Periods=0,int ShiftM1=0,string _iSymbol=NULL){
   _iSymbol=_iSymbol==NULL? iSymbol : _iSymbol;
   double Toppers[2],Bottoms[2];
   Toppers[0]=0; Toppers[1]=0; Bottoms[0]=0; Bottoms[1]=0;
   int index=(_MACD_TF<=TF_H4)? 3 : 1,Count_Toppers=0,Count_Bottoms=0,PeriodsZigZagH1=0;
   double AverageSpread=0;
   double AverageH4Spread=AverageSpreadNumPeriod(TF_H4,1);
   double AverageM30Spread=AverageSpreadNumPeriod(TF_M30,1);
   bool _IsConstantRSI=true;
   Count_Periods=Count_Periods*TF[_MACD_TF]/TF[TF_H1];
   
   if(Trend=="Up"){
      index=iHighest(_iSymbol,TF[TF_H1],MODE_HIGH,4,Get_Shift(ShiftM1,TF[TF_H1]));
      Toppers[0]=iHigh(_iSymbol,TF[TF_H1],Get_Shift(ShiftM1,TF[TF_H1])+index); //Precio mas alto de la ultima barra 
      index=iHighest(_iSymbol,TF[TF_H1],MODE_HIGH,Count_Periods,Get_Shift(ShiftM1,TF[TF_H1])+index);
      Toppers[1]=iHigh(_iSymbol,TF[TF_H1],Get_Shift(ShiftM1,TF[TF_H1])+index); //Precio mas alto de las barras anterioriores 
      PeriodsZigZagH1=index+1;
      
      if(Toppers[1]>0){
         _IsConstantRSI=IsConstantRSI(Trend,TF_H1,PeriodsZigZagH1,6,ShiftM1);
         if(_IsConstantRSI==false){
            AverageSpread=( ((Trend==W1Trend && PeriodsZigZagH1>8*4) || ForceH4Trend==true) && CurrentFunction=="CheckForOpen")? -AverageM30Spread : 0;
         }else{
            AverageSpread=-AverageH4Spread*2;
         }
      }
      if((Toppers[1]>0 && Toppers[0]>=Toppers[1]+AverageSpread) || (Toppers[0]>0 && Toppers[1]==0)){
         if(ShiftM1==0){
            Print("Print iSymbol=",iSymbol,", CheckZigZag=true, Trend=",Trend,", _MACD_TF=TF_H1, Count_Periods=",Count_Periods,", Toppers[0]=",Toppers[0]," >= Toppers[1]+AverageSpread=",Toppers[1]+AverageSpread,", Toppers[1]=",Toppers[1],", AverageSpread=",AverageSpread,", IsConstantRSI=",_IsConstantRSI,", from iTime=",iTime(_iSymbol,TF[TF_H1],Get_Shift(ShiftM1,TF[TF_H1])+index));
         }
         return true;
      }else{
         if(ShiftM1==0){
            Print("iSymbol=",iSymbol,", CheckZigZag=false, Trend=",Trend,", _MACD_TF=TF_H1, Count_Periods=",Count_Periods,", Toppers[0]=",Toppers[0]," < Toppers[1]+AverageSpread=",Toppers[1]+AverageSpread,", Toppers[1]=",Toppers[1],", AverageSpread=",AverageSpread,", IsConstantRSI=",_IsConstantRSI,", from iTime=",iTime(_iSymbol,TF[TF_H1],Get_Shift(ShiftM1,TF[TF_H1])+index));
         }
         return false;
      }
      
   }else if(Trend=="Down"){
      index=iLowest(_iSymbol,TF[TF_H1],MODE_LOW,4,Get_Shift(ShiftM1,TF[TF_H1]));
      Bottoms[0]=iLow(_iSymbol,TF[TF_H1],Get_Shift(ShiftM1,TF[TF_H1])+index);//Precio mas bajo de la ultima barra
      index=iLowest(_iSymbol,TF[TF_H1],MODE_LOW,Count_Periods,Get_Shift(ShiftM1,TF[TF_H1])+index);
      Bottoms[1]=iLow(_iSymbol,TF[TF_H1],Get_Shift(ShiftM1,TF[TF_H1])+index);//Precio mas bajo de las barras anteriores
      PeriodsZigZagH1=index+1;
      
      if(Bottoms[1]>0){
         _IsConstantRSI=IsConstantRSI(Trend,TF_H1,PeriodsZigZagH1,6,ShiftM1);
         if(_IsConstantRSI==false){
            AverageSpread=( ((Trend==W1Trend && PeriodsZigZagH1>8*4) || ForceH4Trend==true) && CurrentFunction=="CheckForOpen")? AverageM30Spread : 0;
         }else{
            AverageSpread=AverageH4Spread*2;
         }
      }
      if((Bottoms[1]>0 && Bottoms[0]<=MathAbs(Bottoms[1]+AverageSpread)) || (Bottoms[0]>0 && Bottoms[1]==0)) {
         if(ShiftM1==0){
            Print("Print iSymbol=",iSymbol,", CheckZigZag=true, Trend=",Trend,", _MACD_TF=TF_H1, Count_Periods=",Count_Periods,", Bottoms[0]=",Bottoms[0]," <= Bottoms[1]+AverageSpread=",MathAbs(Bottoms[1]+AverageSpread),", Bottoms[1]=",Bottoms[1],", AverageSpread=",AverageSpread,", IsConstantESI=",_IsConstantRSI,", from iTime=",iTime(_iSymbol,TF[TF_H1],Get_Shift(ShiftM1,TF[TF_H1])+index));
         }
        return true;
      }else{
         if(ShiftM1==0){
            Print("iSymbol=",iSymbol,", CheckZigZag=false, Trend=",Trend,", _MACD_TF=TF_H1, Count_Periods=",Count_Periods,", Bottoms[0]=",Bottoms[0]," > Bottoms[1]+AverageSpread=",MathAbs(Bottoms[1]+AverageSpread),", Bottoms[1]=",Bottoms[1],", AverageSpread=",AverageSpread,", IsConstantRSI=",_IsConstantRSI,", from iTime=",iTime(_iSymbol,TF[TF_H1],Get_Shift(ShiftM1,TF[TF_H1])+index));
         }
         return false;
      }
      
   }else{
      return false;
   }
}

bool CheckZigZagPrev(string Trend,int ShiftM1=0,string _iSymbol=NULL){
   _iSymbol=_iSymbol==NULL? iSymbol : _iSymbol;
   int Max_Periods=5,Shift;
   double AverageH4Spread=AverageSpreadNumPeriod(TF_H4,1);
   double MinSpread=0;
   
   if(Trend=="Up"){
      Shift=iHighest(iSymbol,TF[TF_H4],MODE_HIGH,1*6,Get_Shift(ShiftM1,TF[TF_H4]));
      double HighD1=iHigh(iSymbol,TF[TF_H4],Get_Shift(ShiftM1,TF[TF_H4])+Shift);
      int iHighestW1=iHighestOpenClose(iSymbol,TF[TF_H4],3*6,Get_Shift(ShiftM1,TF[TF_H4]));
      double HighW1=iHighOpenClose(iSymbol,TF[TF_H4],Get_Shift(ShiftM1,TF[TF_H4])+iHighestW1);
      MinSpread=(iHighestW1>=8)? AverageH4Spread : 0;
      if(HighW1>HighD1+MinSpread){
         Print("CheckZigZagPrev=false, Trend=",Trend,", HighW1=",HighW1," > HighD1+MinSpread=",(HighD1+MinSpread),", HighD1=", HighD1,", Shift=",Shift,", iHighestW1=",iHighestW1,", Max_Periods=",Max_Periods,", Get_Shift(ShiftM1,TF[TF_D1])=",Get_Shift(ShiftM1,TF[TF_D1]),", ShiftM1=",ShiftM1);
         return false;
      }else{
         return true;
      }
   }else if(Trend=="Down"){
      Shift=iLowest(iSymbol,TF[TF_H4],MODE_LOW,1*6,Get_Shift(ShiftM1,TF[TF_H4]));
      double LowD1=iLow(iSymbol,TF[TF_H4],Get_Shift(ShiftM1,TF[TF_H4])+Shift);
      int iLowestW1=iLowestOpenClose(iSymbol,TF[TF_H4],3*6,Get_Shift(ShiftM1,TF[TF_H4]));
      double LowW1=iLowOpenClose(iSymbol,TF[TF_H4],Get_Shift(ShiftM1,TF[TF_H4])+iLowestW1);
      MinSpread=(iLowestW1>=8)? AverageH4Spread : 0;
      if(LowW1<LowD1-MinSpread){
         Print("CheckZigZagPrev=false, Trend=",Trend,", LowW1=",LowW1," < LowD1-MinSpread=",(LowD1-MinSpread),", LowD1=",LowD1,", Shift=",Shift,", iLowestW1=",iLowestW1,", Max_Periods=",Max_Periods,", Get_Shift(ShiftM1,TF[TF_D1])=",Get_Shift(ShiftM1,TF[TF_D1]),", ShiftM1=",ShiftM1);
         return false;
      }else{
         return true;
      }
   }else{
      return false;
   }
}

int FirstZigZag(string Trend,int _MACD_TF,int Periods=0,int Shift=0,string _iSymbol=NULL){
   Periods=(Periods<=0)? iBars(_iSymbol,TF[_MACD_TF]) : Periods;
   _iSymbol=_iSymbol==NULL? iSymbol : _iSymbol;
   int ExtDepth=5; int ExtDeviation=3; int ExtBackstep=3;
   int Buffer=(Trend=="Up")? 1 : 2;
   double Value=0;
   int i=(Shift>=1)? 0 : 1;
      
   while(Value==0 && i<Periods){
      Value=iCustom(_iSymbol,TF[_MACD_TF],"ZigZag",ExtDepth,ExtDeviation,ExtBackstep,Buffer,Shift+i);
      if(Value==0){
         i++;
      }else{
         break;
      }
   }
   i=(Value==0)? -1 : Shift+i;
   return i;
   
}

//
//Verifica que la onda mantenga la tendencia en todas sus barras
//
bool IsConstantRSI(string Trend,int _MACD_TF,int Total_Periods,int Group_Periods,int ShiftM1=0){
      double RSI,RSI_Up=60,RSI_Down=40;
      int Shift=Get_Shift(ShiftM1,TF[_MACD_TF]);
      
      for(int i=0;i<Total_Periods;i++){
         RSI=iRSI(iSymbol,TF[_MACD_TF],Group_Periods,(Trend=="Up"? PRICE_HIGH : PRICE_LOW),i+Shift);
         if(Trend=="Up" && RSI<RSI_Up) return false;
         if(Trend=="Down" && RSI>RSI_Down) return false;
      }
      
      return true;
      
}

bool IsConstantTrend(string Trend,int Max_Periods,int ShiftM1=0){
     
      //CheckZigZagPrev
      if(CheckZigZagPrev(Trend,ShiftM1,iSymbol)==false) return false;
      
      int TrendH4_IndexHighestLowest,CountPeriodsH4ofD1_HighestLowest;
      if(Trend=="Up"){ 
         TrendH4_IndexHighestLowest=iLowest(iSymbol,TF[TF_H4],MODE_OPEN,15,Get_Shift(ShiftM1,TF[TF_H4]))+1;
      }else{
         TrendH4_IndexHighestLowest=iHighest(iSymbol,TF[TF_H4],MODE_OPEN,15,Get_Shift(ShiftM1,TF[TF_H4]))+1;
      }
      CountPeriodsH4ofD1_HighestLowest=MathMax(CountPeriodsH4ofD1_PrevPeriodsH4,TrendH4_IndexHighestLowest);
      CountPeriodsH4ofD1_HighestLowest=MathMin(CountPeriodsH4ofD1_HighestLowest+4,15);
      
      if(CheckZigZag(MACD_Trend[TF_H4],TF_H4,CountPeriodsH4ofD1_HighestLowest,ShiftM1)==false){
         Print("IsConstantTrend=false, CheckZigZag=false, TrendH4_IndexHighestLowest=",TrendH4_IndexHighestLowest,", CountPeriodsH4ofD1_PrevPeriodsH4=",CountPeriodsH4ofD1_PrevPeriodsH4,", CountPeriodsH4ofD1_HighestLowest=",CountPeriodsH4ofD1_HighestLowest);
         return false;
      }
      
      int _MACD_TF,CountPeriodsTF=0;
      double SpreadTrend,MinSpread=0;
      double AverageH4Spread=AverageSpreadNumPeriod(TF_H4,1);
      double AverageH1Spread=AverageSpreadNumPeriod(TF_H1,1);
      double AverageM30Spread=AverageSpreadNumPeriod(TF_M30,1);
      double AverageM15Spread=AverageSpreadNumPeriod(TF_M15,1);
      
      
      //Verifica el Spread en cada TimeFrame
      for(_MACD_TF=TF_H4;_MACD_TF>=TF_M15;_MACD_TF--){
            switch(_MACD_TF){
               case TF_H4: CountPeriodsTF=MathMin(MathMax(CountPeriodsH4ofD1_PrevPeriodsH4,7),15); MinSpread=AverageH1Spread*3.5; break;//D1- D1*2.5
               case TF_H1: CountPeriodsTF=16; MinSpread=AverageH1Spread*2.6; break;//H4*4
               case TF_M30: CountPeriodsTF=16; MinSpread=AverageH1Spread*1.7; break;//H4*2
               case TF_M15: CountPeriodsTF=12; MinSpread=AverageH1Spread*0.9; break;//H1*3
            }
            SpreadTrend=MathAbs(SpreadNumPeriod(_MACD_TF,CountPeriodsTF,Get_Shift(ShiftM1,TF[_MACD_TF]),true));
            
            if(SpreadTrend<MinSpread){ 
               Print("IsConstantTrend=false: _MACD_TF=",_MACD_TF,", SpreadTrend=",SpreadTrend," < MinSpread=",MinSpread,", CountPeriodsTF=",CountPeriodsTF);
               return false;
            }
        
      }
      
      
      //Verifica el spread de la ultima barra
      double SpreadLastBar;
      for(_MACD_TF=TF_H1;_MACD_TF<=TF_H4;_MACD_TF++){
         MinSpread=(_MACD_TF==TF_H4)? AverageH1Spread*0.3 : AverageH1Spread*0.3;
         SpreadLastBar=SpreadNumPeriod(_MACD_TF,1,Get_Shift(ShiftM1,TF[_MACD_TF]),true);
         
         if(Trend=="Up" && SpreadLastBar<MinSpread){
            Print("IsConstantTrend=false: Trend=",Trend,", _MACD_TF=",_MACD_TF,", SpreadLastBar=",SpreadLastBar," < MinSpread=",MinSpread);
            return false;
         }else if(Trend=="Down" && SpreadLastBar>-MinSpread){
            Print("IsConstantTrend=false: Trend=",Trend,", _MACD_TF=",_MACD_TF,", SpreadLastBar=",SpreadLastBar," > -MinSpread=",-MinSpread);
            return false;
         }
      }
      
            
      //Verifica la sumatoria del Spread de las ultimas 4 barras
      int index;
      for(_MACD_TF=TF_H1;_MACD_TF<=TF_H4;_MACD_TF++){
         index=_MACD_TF-TF_H1;//5-5,6-5
         SumSpread4Bars[index]=0;
         MinSpread4Bars[index]=(_MACD_TF==TF_H4)? AverageH1Spread*2.25 : AverageH1Spread;
         for(int i=0;i<=3;i++){
            SpreadTrend=SpreadNumPeriod(_MACD_TF,1,i+Get_Shift(ShiftM1,TF[_MACD_TF]),true);
            SumSpread4Bars[index]+=SpreadTrend;
         }
         if(Trend=="Up" && SumSpread4Bars[index]<MinSpread4Bars[index]){
            Print("IsConstantTrend=false: Trend=",Trend,", _MACD_TF=",_MACD_TF,", SumSpread4Bars=",SumSpread4Bars[index]," < MinSpread4Bars=",MinSpread4Bars[index]);
            return false;
         }else if(Trend=="Down" && SumSpread4Bars[index]>-MinSpread4Bars[index]){
            Print("IsConstantTrend=false: Trend=",Trend,", _MACD_TF=",_MACD_TF,", SumSpread4Bars=",SumSpread4Bars[index]," > -MinSpread4Bars=",-MinSpread4Bars[index]);
            return false;
         }
      }
         
      
      
      _MACD_TF=TF_D1;
      int Min_Periods=2;
      Max_Periods=MathMax(Max_Periods,4);
      int Shift=Get_Shift(ShiftM1,TF[_MACD_TF]);
      double RSI,RSI_Up=50,RSI_Down=50;
      double MFI,MFI_Up=10,MFI_Down=90;
      int Periods;
         
  
      //Verifica que la onda aumente la tendencia en el periodo D1
      
      for(Periods=Min_Periods;Periods<=Max_Periods;Periods++){
         RSI=iRSI(iSymbol,TF[_MACD_TF],Periods,PRICE_CLOSE,Shift);
         if(Trend=="Up") {
            RSI=MathCeil(RSI); RSI_Up=58-4*Periods;//50,46,42,38,34,30
            if(RSI<RSI_Up){
               Print("IsConstantTrend=false: Trend=",Trend,", _MACD_TF=",_MACD_TF,", Periods=",Periods,", RSI=",RSI,", RSI_Up=",RSI_Up);
               return false;
            }
         }
         if(Trend=="Down"){
            RSI=MathFloor(RSI); RSI_Down=42+4*Periods;//50,54,58,62,66,70
            if(RSI>RSI_Down){
               Print("IsConstantTrend=false: Trend=",Trend,", _MACD_TF=",_MACD_TF,", Periods=",Periods,", RSI=",RSI,", RSI_Down=",RSI_Down);
               return false;
            }
         }
      }

     
      Min_Periods=2;
      Max_Periods=8;
      
      //Verifica que la onda aumente la tendencia en los periodos H4 y H1
      
      for(_MACD_TF=TF_H4;_MACD_TF>=TF_H1;_MACD_TF--){
         Shift=Get_Shift(ShiftM1,TF[_MACD_TF]);
         for(Periods=Min_Periods;Periods<=Max_Periods;Periods++){
            if(Trend=="Up") {
               RSI=iRSI(iSymbol,TF[_MACD_TF],Periods,PRICE_HIGH,Shift);
               RSI=MathCeil(RSI); RSI_Up=62-Periods;
               if(RSI<RSI_Up){
                  Print("IsConstantTrend=false: Trend=",Trend,", _MACD_TF=",_MACD_TF,", Periods=",Periods,", RSI=",RSI,", RSI_Up=",RSI_Up);
                  return false;
               }
            }
            if(Trend=="Down"){
               RSI=iRSI(iSymbol,TF[_MACD_TF],Periods,PRICE_LOW,Shift);
               RSI=MathFloor(RSI); RSI_Down=38+Periods;
               if(RSI>RSI_Down){
                  Print("IsConstantTrend=false: Trend=",Trend,", _MACD_TF=",_MACD_TF,", Periods=",Periods,", RSI=",RSI,", RSI_Down=",RSI_Down);
                  return false;
               }
            }
         }
      }
      
      
      
      //Verifica la fuerza del indicador MFI en el final de la tendencia
      Min_Periods=2;
      
      for(_MACD_TF=TF_H1;_MACD_TF>=TF_M30;_MACD_TF--){
         Shift=Get_Shift(ShiftM1,TF[_MACD_TF]);
         Max_Periods=(_MACD_TF==TF_H1)? 4 : 5; 
         for(Periods=Min_Periods;Periods<=Max_Periods;Periods++){
            MFI=iMFI(iSymbol,TF[_MACD_TF],Periods,Shift);
            
            if(Trend=="Up") {
               MFI=MathCeil(MFI); MFI_Up=20; MFI_Down=80;
               if(MFI<MFI_Up){
                  Print("IsConstantTrend=false: Trend=",Trend,", _MACD_TF=",_MACD_TF,", Periods=",Periods,", MFI=",MFI,", MFI_Up=",MFI_Up,", MFI_Down=",MFI_Down);
                  return false;
               }
            }
            if(Trend=="Down"){
               MFI=MathFloor(MFI); MFI_Up=20; MFI_Down=80;
               if(MFI>MFI_Down){
                  Print("IsConstantTrend=false: Trend=",Trend,", _MACD_TF=",_MACD_TF,", Periods=",Periods,", MFI=",MFI,", MFI_Up=",MFI_Up,", MFI_Down=",MFI_Down);
                  return false;
               }
            }
         }
      }
         
      //Verifica la fuerza de 2 barras de tendencia final
      int CountPeriodsFinalTrend,CountForce2BarsTrend;
      
      for(_MACD_TF=TF_H1;_MACD_TF>=TF_H1;_MACD_TF--){
         CountPeriodsFinalTrend=Count_Periods_SAR_Trend(Trend,_MACD_TF,0.14,0.14,Get_Shift(ShiftM1,TF[_MACD_TF]),iSymbol);
         CountForce2BarsTrend=0;
         for(Shift=0;Shift<12;Shift++){
            MFI=iMFI(iSymbol,TF[_MACD_TF],5,Shift);
            if(Trend=="Up") {
               MFI_Up=60;
               if(MFI>=MFI_Up){
                  CountForce2BarsTrend++;
               }
            }
            if(Trend=="Down"){
               MFI_Down=40;
               if(MFI<=MFI_Down){
                  CountForce2BarsTrend++;
               }
            }
         }//for
         if(CountForce2BarsTrend<2){
            Print("IsConstantTrend=false: Trend=",Trend,", _MACD_TF=",_MACD_TF,", CountForce2BarsTrend=",CountForce2BarsTrend,", CountPeriodsFinalTrend=",CountPeriodsFinalTrend);
            return false;
         }      
      }
      
      //Verifica la fuerza de los toros para la tendencia alcista y la fuerza de los osos para tendencia bajista    
      //BullsBears D7-D4
      for(_MACD_TF=TF_D1;_MACD_TF>=TF_H1;_MACD_TF--){   
         if(_MACD_TF==TF_D1){
            Max_Periods=(MACD_Trend[TF_D1]==W1Trend || ForceH4Trend==true)? 4 : ( ((MACD_Trend[TF_D1]==MACD_Trend[TF_W1]) || (MACD_Trend[TF_D1]!=MACD_Trend[TF_W1] && CountPeriodsTrend[TF_W1]==1))? 5 : 5);
            Periods=BullBearsPower(Trend,_MACD_TF,Max_Periods,ShiftM1);
      
            if(iBullsBears(Trend,_MACD_TF,Periods,ShiftM1)==false) return false;
         }else{
            Max_Periods=(MACD_Trend[TF_D1]==MACD_Trend[TF_W1] || (MACD_Trend[TF_D1]!=MACD_Trend[TF_W1] && CountPeriodsTrend[TF_W1]==1) || (ForceH4Trend==true))? 24*TF[TF_H4]/TF[_MACD_TF] : 30*TF[TF_H4]/TF[_MACD_TF];
            Print("ForceH4Trend=",ForceH4Trend,", Max_Periods=",Max_Periods);
            Periods=BullBearsPower(Trend,_MACD_TF,Max_Periods,ShiftM1);
            if(iBullsBears(Trend,_MACD_TF,Periods,ShiftM1)==false) return false;
         }
      }
      
      //Verifica la fuerza de los toros para la tendencia alcista y la fuerza de los osos para tendencia bajista para el ultimo dia   
      //BullsBears D1
      for(_MACD_TF=TF_H4;_MACD_TF>=TF_H1;_MACD_TF--){
         Max_Periods=9*TF[TF_H4]/TF[_MACD_TF];
         Periods=BullBearsPower(Trend,_MACD_TF,Max_Periods,ShiftM1);
         if(iBullsBears(Trend,_MACD_TF,Periods,ShiftM1)==false) return false;
      }
             

            
      //Diagonal
      //Verifica la subida y bajada del precio en las ultimas horas
      if(Trend=="Up"){
         Shift=iHighest(iSymbol,TF[TF_H1],MODE_HIGH,8,Get_Shift(ShiftM1,TF[TF_H1]));
         double HighH8=iHigh(iSymbol,TF[TF_H1],Get_Shift(ShiftM1,TF[TF_H1])+Shift);
         Shift=iLowest(iSymbol,TF[TF_H1],MODE_LOW,24,Get_Shift(ShiftM1,TF[TF_H1]));
         double LowD1=iLow(iSymbol,TF[TF_H1],Get_Shift(ShiftM1,TF[TF_H1])+Shift);
         
         double MA0,MA,LowestMA=0;
         int MA_Period=2;
         bool DiagonalMA=true;
         
         for(_MACD_TF=TF_D1;_MACD_TF>=TF_M15;_MACD_TF--){
            switch(_MACD_TF){
               case TF_D1: MA_Period=2; Max_Periods=(Hour()<=12? 3 : 2); MinSpread=AverageH1Spread*2; break;
               case TF_H4: MA_Period=2; Max_Periods=9; MinSpread=AverageH1Spread*2; break;
               case TF_H1: MA_Period=2; Max_Periods=9; MinSpread=AverageH1Spread*1; break;
               case TF_M30: MA_Period=2; Max_Periods=8; MinSpread=AverageM30Spread*1; break;
               case TF_M15: MA_Period=2; Max_Periods=8; MinSpread=AverageM30Spread; break;
            }
            
            MA0=iMA(iSymbol,TF[TF_M30],MA_Period,0,MODE_LWMA,PRICE_HIGH,Get_Shift(ShiftM1,TF[TF_M30]));
            LowestMA=0;
            for(Shift=1;Shift<Max_Periods;Shift++){
               MA=iMA(iSymbol,TF[_MACD_TF],MA_Period,0,MODE_LWMA,PRICE_MEDIAN,Get_Shift(ShiftM1,TF[_MACD_TF])+Shift);
               if(MA<LowestMA || LowestMA==0){
                  LowestMA=MA;
               }
            }
            
            if(!(MA0>=LowestMA+MinSpread)){
               DiagonalMA=false;
               break;      
            }
            
         }
         
         if(!(DiagonalMA==true && HighH8>=LowD1+AverageH4Spread)){
            Print("Diagonal=false: _MACD_TF=",_MACD_TF,", MA0=",MA0,", LowestMA=",LowestMA,", LowestMA+MinSpread=",LowestMA+MinSpread,", HighH8=",HighH8,", LowD1=",LowD1,", LowD1+AverageH4Spread=",LowD1+AverageH4Spread); 
            return false;            
         }else{
            Print("Print Diagonal=true: _MACD_TF=",_MACD_TF,", MA0=",MA0,", LowestMA=",LowestMA,", LowestMA+MinSpread=",LowestMA+MinSpread,", HighH8=",HighH8,", LowD1=",LowD1,", LowD1+AverageH4Spread=",LowD1+AverageH4Spread); 
         }
      }else{
         Shift=iLowest(iSymbol,TF[TF_H1],MODE_LOW,8,Get_Shift(ShiftM1,TF[TF_H1]));
         double LowH8=iLow(iSymbol,TF[TF_H1],Get_Shift(ShiftM1,TF[TF_H1])+Shift);
         Shift=iHighest(iSymbol,TF[TF_H1],MODE_HIGH,24,Get_Shift(ShiftM1,TF[TF_H1]));
         double HighD1=iHigh(iSymbol,TF[TF_H1],Get_Shift(ShiftM1,TF[TF_H1])+Shift);
         
         double MA0,MA,HighestMA=0;
         int MA_Period=2;
         bool DiagonalMA=true;
         
         for(_MACD_TF=TF_D1;_MACD_TF>=TF_M15;_MACD_TF--){
            switch(_MACD_TF){
               case TF_D1: MA_Period=2; Max_Periods=(Hour()<=12? 3 : 2); MinSpread=AverageH1Spread*2; break;
               case TF_H4: MA_Period=2; Max_Periods=9; MinSpread=AverageH1Spread*2; break;
               case TF_H1: MA_Period=2; Max_Periods=9; MinSpread=AverageH1Spread*1; break;
               case TF_M30: MA_Period=2; Max_Periods=8; MinSpread=AverageM30Spread*1; break;
               case TF_M15: MA_Period=2; Max_Periods=8; MinSpread=AverageM30Spread; break;
            }
            
            MA0=iMA(iSymbol,TF[TF_M30],MA_Period,0,MODE_LWMA,PRICE_LOW,Get_Shift(ShiftM1,TF[TF_M30]));
            HighestMA=0;
            for(Shift=1;Shift<Max_Periods;Shift++){
               MA=iMA(iSymbol,TF[_MACD_TF],MA_Period,0,MODE_LWMA,PRICE_MEDIAN,Get_Shift(ShiftM1,TF[_MACD_TF])+Shift);
               if(MA>HighestMA || HighestMA==0){
                  HighestMA=MA;
               }
            }
            
            if(!(MA0<=HighestMA-MinSpread)){
               DiagonalMA=false;
               break;      
            }
            
         }
         
         if(!(DiagonalMA==true && LowH8<=HighD1-AverageH4Spread)){
            Print("Diagonal=false: _MACD_TF=",_MACD_TF,", MA0=",MA0,", HighestMA=",HighestMA,", HighestMA-MinSpread=",HighestMA-MinSpread,", LowH8=",LowH8,", HighD1=",HighD1,", HighD1-AverageH4Spread=",HighD1-AverageH4Spread); 
            return false;            
         }else{
            Print("Print Diagonal=true: _MACD_TF=",_MACD_TF,", MA0=",MA0,", HighestMA=",HighestMA,", HighestMA-MinSpread=",HighestMA-MinSpread,", LowH8=",LowH8,", HighD1=",HighD1,", HighD1-AverageH4Spread=",HighD1-AverageH4Spread); 
         }
      }
      
      //
      return true;
      
}

int BullBearsPower(string Trend,int _MACD_TF,int Max_Periods,int ShiftM1=0){
   int Periods;
   int Shift=(_MACD_TF>=TF_D1)? 0 : 1;
   
   if(Trend=="Up"){
      Periods=iHighestOpenClose(iSymbol,TF[_MACD_TF],Max_Periods-Shift,Get_Shift(ShiftM1,TF[_MACD_TF])+Shift);
   }else{
      Periods=iLowestOpenClose(iSymbol,TF[_MACD_TF],Max_Periods-Shift,Get_Shift(ShiftM1,TF[_MACD_TF])+Shift);
   }
   /*if(_MACD_TF<=TF_H4)*/ Periods++;
      
   Print("BullBearsPower: Trend=",Trend,", _MACD_TF=",_MACD_TF,", Max_Periods=",Max_Periods,", ShiftM1=",ShiftM1,", Periods=",Periods);
   return Periods;
}

bool BullsBears(string Trend,int _MACD_TF,int Periods,double AverageSpread,int ShiftM1=0){
   if(Periods<2) return true;
   int Shift=Get_Shift(ShiftM1,TF[_MACD_TF]);
   int i;
   double SumSpread=0,MAi,MAi1;
       
   for(i=0;i<Periods;i++){
      MAi=iMA(iSymbol,TF[_MACD_TF],(_MACD_TF>=TF_D1? 2 : 3),0,MODE_SMA,(Trend=="Up"? PRICE_HIGH : PRICE_LOW),Shift+i);
      MAi1=iMA(iSymbol,TF[_MACD_TF],(_MACD_TF>=TF_D1? 2 : 3),0,MODE_SMA,(Trend=="Up"? PRICE_HIGH : PRICE_LOW),Shift+i+1);
      SumSpread+=MAi-MAi1;
   }
   
   //Print("Print BullsBears: Trend=",Trend,", _MACD_TF=",_MACD_TF,", Periods=",Periods,", SumSpread=",SumSpread,", AverageSpread=",AverageSpread,", from iTime=",iTime(iSymbol,TF[_MACD_TF],Periods-1));
   if(Trend=="Up" && !(SumSpread>=AverageSpread)) {
      Print("BullsBears=false: Trend=",Trend,", _MACD_TF=",_MACD_TF,", Periods=",Periods,", SumSpread=",SumSpread,", AverageSpread=",AverageSpread,", from iTime=",iTime(iSymbol,TF[_MACD_TF],Periods-1));
      return false;
   }
   if(Trend=="Down" && !(SumSpread<=-AverageSpread)) {
      Print("BullsBears=false: Trend=",Trend,", _MACD_TF=",_MACD_TF,", Periods=",Periods,", SumSpread=",SumSpread,", AverageSpread=",-AverageSpread,", from iTime=",iTime(iSymbol,TF[_MACD_TF],Periods-1));
      return false;
   }
   return true;
}


bool iBullsBears(string Trend,int _MACD_TF,int Periods,int ShiftM1=0){
   if(Periods<=4*TF[MathMax(_MACD_TF,TF_H4)]/TF[_MACD_TF]) return true;
   
   ENUM_APPLIED_PRICE APPLIED_PRICE=(Periods<=12? PRICE_OPEN : (Trend=="Up"? PRICE_HIGH : PRICE_LOW));
   
   double Bulls=iBullsPower(iSymbol,TF[_MACD_TF],Periods,APPLIED_PRICE,Get_Shift(ShiftM1,TF[_MACD_TF])); 
   double Bears=iBearsPower(iSymbol,TF[_MACD_TF],Periods,APPLIED_PRICE,Get_Shift(ShiftM1,TF[_MACD_TF]));     
      
   if((Trend=="Up" && Bulls>-Bears) || (Trend=="Down" && Bears<-Bulls)){
      Print("Print iBullsBears=true: Trend=",Trend,", _MACD_TF=",_MACD_TF,", Periods=",Periods,", Bulls=",Bulls,", Bears=",Bears,", from iTime=",iTime(iSymbol,TF[_MACD_TF],Periods-1));
      return true;   
   }else{
      Print("iBullsBears=false: Trend=",Trend,", _MACD_TF=",_MACD_TF,", Periods=",Periods,", Bulls=",Bulls,", Bears=",Bears,", from iTime=",iTime(iSymbol,TF[_MACD_TF],Periods-1));
      return false;
   }
      
   
}