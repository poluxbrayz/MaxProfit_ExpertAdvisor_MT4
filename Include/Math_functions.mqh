//+------------------------------------------------------------------+
//|                                               math_functions.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"


double MinUInt(double value){
   int Integer=(int)MathAbs(MathFloor(value));
   double Decimal=MathAbs(value-MathFloor(value));
   while(Decimal<1){
      Decimal=Decimal*10;
   }
   return Integer*10+Decimal;
}

bool Compare(double Value1,string Operator,double Value2,int RightTrim=1){
   DoubleRTrim(Value1,Value2,RightTrim);
   if(Operator=="==") return Value1==Value2;
   else if(Operator==">") return Value1>Value2;
   else if(Operator=="<") return Value1<Value2;
   else if(Operator==">=") return Value1>=Value2;
   else if(Operator=="<=") return Value1<=Value2;
   else return false;   
}

void DoubleRTrim(double &value1, double &value2, int digits=1){
   int decimals1=CountDecimals(value1);
   int decimals2=CountDecimals(value2);
   if(decimals1==decimals2){
      value1=DoubleRTrim1(value1,digits);
      value2=DoubleRTrim1(value2,digits);
   }else if(decimals1>decimals2 && decimals2>0){
      value1=DoubleRTrim1(value1,digits);
   }else if(decimals1<decimals2 && decimals1>0){
      value2=DoubleRTrim1(value2,digits);
   }
}

double DoubleRTrim1(double value,int digits=1){
   if(digits<1) return value;
   int decimals=CountDecimals(value);
   return FormatDecimals(value,decimals-digits);
}

int CountDecimals(double value){
   double number=MathAbs(value);
   number=number<1? number+1 : number;
   int decimals=0;
   while(number-MathFloor(number)>0){
      number=number*10;
      decimals++;
   }
   return decimals;
}

double FormatDecimals(double value,int digits){
   if(digits<1) return value;
   double number=value*MathPow(10,digits);
   number=MathFloor(number);
   number=number/MathPow(10,digits);
   return number;
}

double TrendSign(string Trend){
   if(Trend=="Down") return -1;
   else return 1;
}

double TrendSign(double Trend){
   if(Trend!=0){
      return Trend/MathAbs(Trend);
   }else{
      return 1;
   }
}

string Trend(double TrendValue){
   if(TrendValue>=0){
      return "Up";
   }else{
      return "Down";
   }
}

int Get_Shift(int ShiftM1,int PERIOD_TF){
   return iBarShift(iSymbol,PERIOD_TF,TimeCurrent()-ShiftM1*60);
}

bool ArraySearch(string &StringArray[],string Value){
   for(int i=0;i<ArraySize(StringArray);i++){
      if(StringArray[i]==Value)
      {
         return true;
      }
   }
   return false;
}

string BarTrend(int _MACD_TF,int Shift=0){
   double OpenPrice=iOpen(iSymbol,TF[_MACD_TF],Shift);
   double ClosePrice=iClose(iSymbol,TF[_MACD_TF],Shift);
   if(ClosePrice>OpenPrice) return "Up";
   else if(ClosePrice<OpenPrice) return "Down";
   else return "Ranging";
}

double iHighOpenClose2(string _iSymbol,int Period_TF,int Shift){
   double HighPrice=iHigh(_iSymbol,Period_TF,Shift);
   double OpenClosePrice=MathMax(iOpen(_iSymbol,Period_TF,Shift),iClose(_iSymbol,Period_TF,Shift));
   return (HighPrice+OpenClosePrice)/2;
}

double iLowOpenClose2(string _iSymbol,int Period_TF,int Shift){
   double LowPrice=iLow(_iSymbol,Period_TF,Shift);
   double OpenClosePrice=MathMin(iOpen(_iSymbol,Period_TF,Shift),iClose(_iSymbol,Period_TF,Shift));
   return (LowPrice+OpenClosePrice)/2;
}

double iHighOpenClose(string _iSymbol,int Period_TF,int Shift){
   double OpenClosePrice=MathMax(iOpen(_iSymbol,Period_TF,Shift),iClose(_iSymbol,Period_TF,Shift));
   return OpenClosePrice;
}

double iLowOpenClose(string _iSymbol,int Period_TF,int Shift){
   double OpenClosePrice=MathMin(iOpen(_iSymbol,Period_TF,Shift),iClose(_iSymbol,Period_TF,Shift));
   return OpenClosePrice;
}

int iHighestOpenClose(string _iSymbol,int Period_TF,int Periods,int Shift=0){
   int iHighestOpenClose=0;
   double HighestOpenClose=0,OpenClose;
   for(int i=0;i<Periods;i++){
      OpenClose=MathMax(iOpen(_iSymbol,Period_TF,Shift+i),iClose(_iSymbol,Period_TF,Shift+i));
      if(OpenClose>HighestOpenClose || HighestOpenClose==0){
         iHighestOpenClose=i;
         HighestOpenClose=OpenClose;
      }
   }
   return iHighestOpenClose;
}

int iLowestOpenClose(string _iSymbol,int Period_TF,int Periods,int Shift=0){
   int iLowestOpenClose=0;
   double LowestOpenClose=0,OpenClose;
   for(int i=0;i<Periods;i++){
      OpenClose=MathMin(iOpen(_iSymbol,Period_TF,Shift+i),iClose(_iSymbol,Period_TF,Shift+i));
      if(OpenClose<LowestOpenClose || LowestOpenClose==0){
         iLowestOpenClose=i;
         LowestOpenClose=OpenClose;
      }
   }
   return iLowestOpenClose;
}

double GetSwap(string Trend,double Lots){
   double Swap=MarketInfo(iSymbol,(Trend=="Up"? MODE_SWAPLONG : MODE_SWAPSHORT));
   double TickValue;
   int SwapType=(int)MarketInfo(iSymbol,MODE_SWAPTYPE);
   //string SymbolCurrency;
   
   switch(SwapType){
      case 0: //in points
         TickValue=MarketInfo(iSymbol,MODE_TICKVALUE);
         Swap=(TickValue!=0)? Swap*TickValue : Swap;
         break;
      case 1: //in the symbol base currency
         //swapDollar=GetSign(swapDollar)*ConvertToAccountCurrency(MathAbs(swapRate),currencyStr);
         //SymbolCurrency=SymbolInfoString(iSymbol,SYMBOL_CURRENCY_BASE);
         Swap=Swap*MarketInfo(iSymbol,MODE_BID);
         break;
      case 2: //by interest
         Swap=((Swap/100)*MarketInfo(iSymbol,MODE_BID))/365;
         break;
      case 3: //in the margin currency
         break;
   }
   
   return Swap*Lots;
}