//+------------------------------------------------------------------+
//|                                                hashfunctions.mqh |
//|                                               Xantrum Solutions. |
//|                                    https://www.xantrum.solutions |
//+------------------------------------------------------------------+
#property copyright "Xantrum Solutions."
#property link      "https://www.xantrum.solutions"
#include "hash.mqh"


Hash *hashAverageSpreadNumPeriod = new Hash();
Hash *hash_MACD_Trend_By_Change = new Hash();
//HashLoop *hashloop;
int ValidDays=7;

//-------------------------------------------------------------------------------------------------------------------


class ListAverageSpreadNumPeriod : public HashValue {
    private:
    public:
      struct RecordAverageSpreadNumPeriod{
         double AverageSpreadNumPeriod;
         datetime LastRecord;
      };
      
      RecordAverageSpreadNumPeriod List[][TF_W1+1];    
      
      ListAverageSpreadNumPeriod(){ }
      ~ListAverageSpreadNumPeriod(){ }
      
      void SetAverageSpreadNumPeriod(int _MACD_TF,int Periods,double AverageSpreadNumPeriod){
         if(ArrayRange(List,0)<=Periods){
            ArrayResize(List,Periods+1);
         }
         List[Periods][_MACD_TF].AverageSpreadNumPeriod=AverageSpreadNumPeriod;
         List[Periods][_MACD_TF].LastRecord=TimeCurrent();
      }
      
      double GetAverageSpreadNumPeriod(int _MACD_TF,int Periods){
         if(ArrayRange(List,0)>Periods){
            if(List[Periods][_MACD_TF].LastRecord>=(TimeCurrent()-ValidDays*PERIOD_D1*60))
               return List[Periods][_MACD_TF].AverageSpreadNumPeriod;
            else
               return NULL;
         }else{
            return NULL;
         }      
      }
        
};

double Select_AverageSpreadNumPeriod(string _iSymbol,int _MACD_TF,int Periods,string &row_state){
   
   ListAverageSpreadNumPeriod *List=(ListAverageSpreadNumPeriod *)hashAverageSpreadNumPeriod.hGet(_iSymbol);         
   if(List!=NULL){
      double AverageSpreadNumPeriod=List.GetAverageSpreadNumPeriod(_MACD_TF,Periods);
      if(AverageSpreadNumPeriod!=NULL){
         row_state="select";
         return AverageSpreadNumPeriod;
      }else{
         row_state="update";
         return NULL;
      }
         
   }else{
      row_state="insert";
      return NULL;
   }
    
    
}

bool Update_AverageSpreadNumPeriod(string _iSymbol,int _MACD_TF,int Periods,double AverageSpreadNumPeriod,string row_state){
   if(row_state=="insert" || row_state=="update"){
   
      ListAverageSpreadNumPeriod *List;
      if(row_state=="insert"){
         List=new ListAverageSpreadNumPeriod();
      }else if(row_state=="update"){
         List=(ListAverageSpreadNumPeriod *)hashAverageSpreadNumPeriod.hGet(_iSymbol);         
      }
         
      List.SetAverageSpreadNumPeriod(_MACD_TF, Periods, AverageSpreadNumPeriod);
      hashAverageSpreadNumPeriod.hPut(_iSymbol,List);   
      return true;
      
   }else{
      return false;
   }
}

//-------------------------------------------------------------------------------------------------------------------

class List_MACD_Trend_By_Change : public HashValue {
    private:
    public:
      struct Record_MACD_Trend_By_Change{
         datetime _iTime;
         string Trend;
         string Vars_MACD_Trend_By_Change;
      };
      
      Record_MACD_Trend_By_Change List[][TF_W1+1];    
      
      List_MACD_Trend_By_Change(){ }
      ~List_MACD_Trend_By_Change(){ }
      
      void Set_MACD_Trend_By_Change(string _iSymbol,int _MACD_TF,string _Trend){
         //this.Clean_MACD_Trend_By_Change(_MACD_TF,_Trend);
         int Rows=ArrayRange(List,0);
         datetime _iTime=iTime(_iSymbol,Period(),0);
         if(Rows==0){
            ArrayResize(List,1);
         }else if(List[Rows-1][_MACD_TF]._iTime<_iTime){
            ArrayResize(List,Rows+1);
         }
         Rows=ArrayRange(List,0);
         List[Rows-1][_MACD_TF]._iTime=_iTime;
         List[Rows-1][_MACD_TF].Trend=_Trend;
         List[Rows-1][_MACD_TF].Vars_MACD_Trend_By_Change=Vars_MACD_Trend_By_Change[_MACD_TF];
      }
      
      string Get_MACD_Trend_By_Change(int _MACD_TF,int ShiftM1){
         datetime _iTime=TimeCurrent()-ShiftM1*60;
         int Rows=ArrayRange(List,0);
         int index=(Rows-1)-int(ShiftM1/Period());
         for(int i=index;i>=0;i--){
            if(List[i][_MACD_TF].Trend!=NULL && _iTime>=List[i][_MACD_TF]._iTime && _iTime<=datetime(List[i][_MACD_TF]._iTime+TF[TF_M15]*60)){
               Vars_MACD_Trend_By_Change[_MACD_TF]=List[i][_MACD_TF].Vars_MACD_Trend_By_Change;
               return List[i][_MACD_TF].Trend;
            }
             if(datetime(List[i][_MACD_TF]._iTime+TF[TF_M15]*60)<_iTime){
               return NULL;    
             }
         }  
         return NULL;    
      }
      
      void Clean_MACD_Trend_By_Change(int _MACD_TF,string _Trend){
         if(_MACD_TF==TF_D1 && (_Trend=="Up" || _Trend=="Down")){
            int Rows=ArrayRange(List,0);
            int to_index=-1,i=-1;
            for(i=Rows-1;i>=0;i--){
               if((_Trend=="Up" && List[i][_MACD_TF].Trend=="Down") || (_Trend=="Down" && List[i][_MACD_TF].Trend=="Up")){
                  to_index=i;
                  break;
               }
            }
            for(i=to_index;i>=0;i--){
               this.DeleteRecord(i);
            }
         }
      }
      
      void DeleteRecord(int index)
      {
         Record_MACD_Trend_By_Change TempArray[][TF_W1+1];
         int i,j;
         int size_j=ArrayRange(List,1);
         /*for(j=0;j<size_j;j++{
            delete List[index][j];   
         }*/

         int size_i=ArrayRange(List,0);
         
         if(size_i==0){
            ArrayFree(List);
            ArrayResize(List,0);
         }else if(index==0){
            ArrayResize(TempArray,size_i-1);
            for(i=1;i<size_i;i++){
               for(j=0;j<size_j;j++){
                  TempArray[i-1][j].Trend=List[i][j].Trend;
                  TempArray[i-1][j].Vars_MACD_Trend_By_Change=List[i][j].Vars_MACD_Trend_By_Change;
                  TempArray[i-1][j]._iTime=List[i][j]._iTime;
               }
            }
            ArrayFree(List);
            ArrayResize(List,size_i-1);
            for(i=0;i<size_i-1;i++){
               for(j=0;j<size_j;j++){
                  List[i][j].Trend=TempArray[i][j].Trend;
                  List[i][j].Vars_MACD_Trend_By_Change=TempArray[i][j].Vars_MACD_Trend_By_Change;
                  List[i][j]._iTime=TempArray[i][j]._iTime;
              }
            }
           
         }else{
           
            ArrayResize(TempArray,size_i-1);
            for(i=0;i<index;i++){
               for(j=0;j<size_j;j++){
                  TempArray[i][j].Trend=List[i][j].Trend;
                  TempArray[i][j].Vars_MACD_Trend_By_Change=List[i][j].Vars_MACD_Trend_By_Change;
                  TempArray[i][j]._iTime=List[i][j]._iTime;
               }
            }
            for(i=index+1;i<size_i;i++){
               for(j=0;j<size_j;j++){
                  TempArray[i-1][j].Trend=List[i][j].Trend;
                  TempArray[i-1][j].Vars_MACD_Trend_By_Change=List[i][j].Vars_MACD_Trend_By_Change;
                  TempArray[i-1][j]._iTime=List[i][j]._iTime;
               }
            }
            ArrayFree(List);
            ArrayResize(List,size_i-1);
            for(i=0;i<size_i-1;i++){
               for(j=0;j<size_j;j++){
                  List[i][j].Trend=TempArray[i][j].Trend;
                  List[i][j].Vars_MACD_Trend_By_Change=TempArray[i][j].Vars_MACD_Trend_By_Change;
                  List[i][j]._iTime=TempArray[i][j]._iTime;
               }
            }
            
         }
          
      }
        
};

string Select_MACD_Trend_By_Change(string _iSymbol,int _MACD_TF,int ShiftM1,string &row_state){
   
   List_MACD_Trend_By_Change *List=(List_MACD_Trend_By_Change *)hash_MACD_Trend_By_Change.hGet(_iSymbol);         
   if(List!=NULL){
      string Trend=List.Get_MACD_Trend_By_Change(_MACD_TF,ShiftM1);
      if(Trend!=NULL){
         row_state="select";
         return Trend;
      }else{
         row_state="update";
         return NULL;
      }
         
   }else{
      row_state="insert";
      return NULL;
   }
    
    
}

bool Update_MACD_Trend_By_Change(string _iSymbol,int _MACD_TF,string _Trend){
   
   List_MACD_Trend_By_Change *List=(List_MACD_Trend_By_Change *)hash_MACD_Trend_By_Change.hGet(_iSymbol);         
   if(List==NULL){
      List=new List_MACD_Trend_By_Change();
   }
   
   List.Set_MACD_Trend_By_Change(_iSymbol,_MACD_TF,_Trend);
   hash_MACD_Trend_By_Change.hPut(_iSymbol,List);   
   return true;
   
}



//***************************************************************************************************************************