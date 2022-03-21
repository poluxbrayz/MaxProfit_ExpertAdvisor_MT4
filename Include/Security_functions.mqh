//+------------------------------------------------------------------+
//|                                           security_functions.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"

/*#import "kernel32.dll" 
int GetComputerNameA(string lpBuffer, int nSize);
#import*/

/*bool ChkS3c(){
   string pc=""; 
   int res;
   bool Allowed=false;

   if(StrategyTester==true ){
      Allowed=true;
      
   }else{
      
      res = GetComputerNameA(pc, StringLen(pc));
      if(pc=="POLUX-PC"){
         Allowed=true;
      
      }else{   
         string url="http://checkip.amazonaws.com/",cookie=NULL,headers,ip;
         uchar post[],result[]; 
         
         if(WebRequest("GET",url,cookie,NULL,5*1000,post,0,result,headers)==-1){
            Allowed=false;
         }else{
            ip=CharArrayToString(result);
            url=StringConcatenate("http://xantrum.solutions/maxprofit/ChkS3c.php?ip=",ip);
            if(WebRequest("GET",url,cookie,NULL,5*1000,post,0,result,headers)==-1){
               Allowed=false;
            }else{
               if(CharArrayToString(result)=="Allowed")
                  Allowed=true;
            }
         } 
         
      }  
         
   }
   
   return Allowed;
}*/