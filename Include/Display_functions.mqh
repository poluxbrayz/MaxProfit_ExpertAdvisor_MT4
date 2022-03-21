//+------------------------------------------------------------------+
//|                                            display_functions.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"


void ShowMessages(){
   if(IsTesting()==true) return;
   color Color=clrWhite;
   int TotalTrends=MathMin(ArraySize(Trends),10);
   string Order_Type;
   DeleteMessages();
   
   CreateLabel("lblTrends","TRENDS",2,34*(TotalTrends+1),40,clrYellow);
   
   for(int i=0;i<TotalTrends;i++){
      Order_Type=StringFind(Trends[i],"Buy")==0? "Buy" : "Sell";
      if(Order_Type=="Buy") {Color = clrLime;}
      if(Order_Type=="Sell") {Color = clrRed;}
      CreateLabel(StringConcatenate("lblTrend",i),Trends[i],2,34*(TotalTrends-i),40,Color);
   }
   
}

void DeleteMessages(){
   DeleteLabel("lblTrends");
   for(int i=0;i<10;i++){
      DeleteLabel(StringConcatenate("lblTrend",i));
   }
}

void CreateLabel(string lblName,string Text,int Corner_Position,int X_Position,int Y_Position,color Color=Lime,string Font_Name="Verdana",int Font_Size = 11){
   if(ObjectFind(lblName) < 0)
      {
      ObjectCreate(ChartID(), lblName, OBJ_LABEL, 0, 0, 0);
      ObjectSet(lblName, OBJPROP_CORNER, Corner_Position);
      ObjectSet(lblName, OBJPROP_YDISTANCE, X_Position);
      ObjectSet(lblName, OBJPROP_XDISTANCE, Y_Position);
      }
   ObjectSetText(lblName, Text, Font_Size, Font_Name, Color);
   WindowRedraw();
   if(GetLastError()>0) Print("Error : ",GetLastError());
}

void DeleteLabel(string lblName){
   if(ObjectFind(lblName)>=0){
      ObjectDelete(lblName);
   }
}

bool MsgConfirmOrder(string Trend){

   if(Confirm_Order==false || IsTesting()==true) return true;
   
   string Order_Type = Trend=="Up"? "Buy" : "Sell";
   string Msg="Confirm Order";
   Msg=StringConcatenate(Msg,"\n",Order_Type," ",iSymbol);
   /*if(SendNotification(Msg)==false){
      PrintError("SendNotification: ",GetLastError());
   }*/
   if(MessageBox(Msg,iSymbol,MB_YESNO | MB_ICONQUESTION)==IDYES){
      return true;
   }else{
      return false;
   }
}