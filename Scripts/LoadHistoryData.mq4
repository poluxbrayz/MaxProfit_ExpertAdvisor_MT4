//+------------------------------------------------------------------+
//|                                                 LoadHistory.mq4
//|                                          Copyright 2012, K Lam
//+------------------------------------------------------------------+
//
//Version 2
// fix in unknow the timeframe H1
//load all timeframe, leave the frame M1

#property copyright "Copyright 2017"
#property link      ""

#define Version  20130121

#import "kernel32.dll"
   int _lopen  (string path, int of);
   int _llseek (int handle, int offset, int origin);
   int _lread  (int handle, string buffer, int bytes);
   int _lclose (int handle);
#import
#import "user32.dll"
   int GetAncestor (int hWnd, int gaFlags);
   int GetParent (int hWnd);
   int GetDlgItem (int hDlg, int nIDDlgItem);
   int SendMessageA (int hWnd, int Msg, int wParam, int lParam);
   int PostMessageA (int hWnd, int Msg, int wParam, int lParam);
#import

#define LVM_GETITEMCOUNT   0x1004
#define WM_MDIACTIVATE     0x222
#define WM_MDIMAXIMIZE     0x0225
#define WM_MDINEXT         0x0224
#define WM_MDIDESTROY      0x0221

#define WM_SCROLL          0x80F9
#define WM_COMMAND         0x0111
#define WM_KEYUP           0x0101
#define WM_KEYDOWN         0x0100
#define WM_CLOSE           0x0010

#define VK_PGUP            0x21
#define VK_PGDN            0x22
#define VK_HOME            0x24
#define VK_END             0x23
#define VK_DOWN            0x28
#define VK_PLUS            0xBB
#define VK_MINUS           0xBD

bool loadhome = true; //false;
int nsymb;

bool Roundload = false;//true; //
//int LastPage=0;  //0 to close all not 0 then will leave the page open at last time frame
int LastPage=0; //0,1,5,15
int Pause=500;//8000               //Wait 500\ 0.5 scend
int KeyHome=500;
int HomeLoop[10]; //1000
string Symbols[];

int TF[10] = {0,1,5,15,30,60,240,1440,10080,43200};
int AverageDaysPeriod[10]={0,30,60,90,180,360,360,360,720,720};

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
void start() {
   int iFrame;
   
//--------------------------------------------------------------------
   if(GlobalVariableCheck("glSymbolHandle")) {
      GlobalVariableSet("glSymbolHandle",WindowHandle(Symbol(),Period()));
      return;
   }
   
   for(int j=1;j<=9;j++){
      HomeLoop[j]=(AverageDaysPeriod[j]+360)*24*60/TF[j];
   }
   
   if(Roundload){
      for(iFrame=1;iFrame<10;iFrame++) {//new add Load all page exclude M1
         LastPage=TF[iFrame];
         MarketInfoToSymbols();
         DownloadHomeKey();
      }
   }else{
      MarketInfoToSymbols();
      DownloadHomeKey();
   }
   return;
}


//+------------------------------------------------------------------+
//| MarketInfoToSymbols()                                            |
//+------------------------------------------------------------------+
void MarketInfoToSymbols() {
      
   ArrayFree(Symbols);
   
   for(int i=0;i<SymbolsTotal(true);i++){
      ArrayResize(Symbols,ArraySize(Symbols)+1);
      Symbols[i]=SymbolName(i,true);
   }

   return;
}

//+------------------------------------------------------------------+
//| DownloadHomeKey()                                                |
//+------------------------------------------------------------------+
void DownloadHomeKey() {
   int i,j,k,l,m;
   int hmain,handle,handlechart,count,num;
//   int tf[9]={1,5,15,30,60,240,1440,10080,43200};
   int TimeF[10]={0,33137,33138,33139,33140,35400,33136,33134,33141,33334};
   int StartBars,PreBars,CurrBars;
   
   GlobalVariableSet("glSymbolHandle",WindowHandle(Symbol(),Period()));
   hmain=GetAncestor(WindowHandle(Symbol(),Period()),2);
   if (hmain!=0) {
      handle=GetDlgItem(hmain,0xE81C);
      handle=GetDlgItem(handle,0x50);
      handle=GetDlgItem(handle,0x8A71);
      count=SendMessageA(handle,LVM_GETITEMCOUNT,0,0);
   } else Print("Error :",GetLastError());

   for(i=0;i<count&&!IsStopped();i++) {
      if(TimeFrameLoaded(Symbols[i])==true) continue;
      num=i+1;
      OpenChart(num,hmain);
      Sleep(Pause);
      PostMessageA(hmain,WM_COMMAND,33042,0);
      Sleep(Pause);
      handlechart=GlobalVariableGet("glSymbolHandle");
         //PostMessageA(handlechart,WM_COMMAND,WM_SCROLL,0);
         SendMessageA(handlechart,WM_COMMAND,WM_MDIMAXIMIZE,0);
         for(m=0;m<8;m++) {
            PostMessageA(handlechart, WM_KEYDOWN, VK_MINUS,0);//Pass - Key for 10 time
            //PostMessageA(handlechart, WM_KEYDOWN, VK_HOME,0);//Pass HOME Key
            Sleep(2);
            }
         /*j=3;
         StartBars=iBars(Symbols[i],TF[j]);
         //LOOP HOME FOR 30   
         if(loadhome)
            for(l=0;l<HomeLoop[j];l++) {
               //key in 30 time
               for(m=0;m<30;m++) {
                  PostMessageA(handlechart, WM_KEYDOWN, VK_HOME,0);//Pass HOME Key
                  Sleep(2);
                  }
               CurrBars=iBars(Symbols[i],TF[j]);
               if(PreBars!=CurrBars) {
                  k=0;
                  PreBars=CurrBars;
                  } else k++;
               if(k>5) { //if 5 time is same then break
                  Print("Start Bar@",StartBars," Bar=",CurrBars," at ",Symbols[i]," Timeframe=",TF[j]);
                  break;
                  }            
             }//if(loadhome)
           */
               
   //switch page each tf[10]
         for(j=1;j<=9+1;j++) {
            LastPage=TF[j];
            Sleep(1000);
            /*switch(LastPage) {
               case 1: PostMessageA(handlechart,WM_COMMAND,TimeF[0],0);j=0; break;
               case 5: PostMessageA(handlechart,WM_COMMAND,TimeF[1],0);j=1; break;
               case 15: PostMessageA(handlechart,WM_COMMAND,TimeF[2],0);j=2; break;
               case 30: PostMessageA(handlechart,WM_COMMAND,TimeF[3],0);j=3; break;
               
               case 60: PostMessageA(handlechart,WM_COMMAND,TimeF[4],0);j=4; break;
               case 240: PostMessageA(handlechart,WM_COMMAND,TimeF[5],0);j=5; break;
               case 1440: PostMessageA(handlechart,WM_COMMAND,TimeF[6],0);j=6; break;
               case 10080: PostMessageA(handlechart,WM_COMMAND,TimeF[7],0);j=7; break;
               case 43200: PostMessageA(handlechart,WM_COMMAND,TimeF[8],0);j=8; break;
                           
               case 0: PostMessageA(GetParent(handlechart),WM_CLOSE,0,0); break;
               default: PostMessageA(handlechart,WM_COMMAND,TimeF[2],0);j=2; break;
            }*/
            if(j<ArraySize(TF)){
               if(TimeFrameLoaded(Symbols[i],j)==true) continue;
               PostMessageA(handlechart,WM_COMMAND,TimeF[j],0);
            }else{
               PostMessageA(GetParent(handlechart),WM_CLOSE,0,0);
               continue;
            }
            StartBars=iBars(Symbols[i],TF[j]);
            Sleep(1000);
            
         if(loadhome)
         for(l=0;l<HomeLoop[j];l++) {
            //key in 30 time
            for(m=0;m<30;m++) {
               PostMessageA(handlechart, WM_KEYDOWN, VK_HOME,0);//Pass HOME Key
               Sleep(2);
               }
            //PostMessageA(handlechart, WM_KEYDOWN, VK_HOME,0);
            Sleep(KeyHome);
            //PostMessageA(handlechart, WM_KEYDOWN, VK_END,0);
            //Sleep(100);
            PostMessageA(handlechart,WM_COMMAND,33324,0);//Refresh
            Sleep(300);
            CurrBars=iBars(Symbols[i],TF[j]);
            
            if(PreBars!=CurrBars) {
               k=0;
               PreBars=CurrBars;
               //Print(Symbols[i]," Timeframe =",tf[j]," PreBars=",PreBars," CurrBars=",CurrBars," Bars=",iBars(Symbols[i],tf[j]));
               //Sleep(500);
               } else k++;
            
            if(k>5) { //if 5 time is same then break
               Print("Start Bar@",StartBars," Bar=",CurrBars," at ",Symbols[i]," Timeframe=",TF[j]);
               break;
               }
            PostMessageA(handlechart, WM_KEYDOWN, VK_END,0);//Sleep(100);
            
            }//for if(loadhome) for(l=0;l<HomeLoop;l++) {
         }//for(j=1;j<=10;j++) {         
//         if(!Roundload) {            PostMessageA(GetParent(handlechart),WM_CLOSE,0,0);         }

         //Sleep(Pause);
   } //for(i=0;i<count&&!IsStopped();i++) {

   GlobalVariableDel("glSymbolHandle");
   return;
}

//+------------------------------------------------------------------+
void OpenChart(int Num, int handle) {
   int hwnd;
   hwnd=GetDlgItem(handle,0xE81C); 
   hwnd=GetDlgItem(hwnd,0x50);
   hwnd=GetDlgItem(hwnd,0x8A71);
   PostMessageA(hwnd,WM_KEYDOWN,VK_HOME,0);
   while(Num>1) {
      PostMessageA(hwnd,WM_KEYDOWN,VK_DOWN,0);
      Num--;
   }
   PostMessageA(handle,WM_COMMAND,33160,0);
   return;
}
//+------------------------------------------------------------------+

bool TimeFrameLoaded(string _iSymbol,int _TF_index=-1){
   bool Loaded=true;
   
   if(_TF_index==-1){
      for(int j=1;j<=9;j++){
         if(iBars(_iSymbol,TF[j])<HomeLoop[j]){
            Loaded=false;
         }else{
            Print(_iSymbol," TF=",TF[j]," iClose=",iClose(_iSymbol,TF[j],HomeLoop[j]-1));
         }
      }
      return Loaded;
   
   }else if(_TF_index>=1){
      j=_TF_index;
      if(iBars(_iSymbol,TF[j])<HomeLoop[j]){
            Loaded=false;
      }else{
            Print(_iSymbol," TF=",TF[j]," iClose=",iClose(_iSymbol,TF[j],HomeLoop[j]-1));
      }
      return Loaded;
   
   }
   return Loaded;
}