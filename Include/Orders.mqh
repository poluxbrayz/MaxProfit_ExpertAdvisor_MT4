//+------------------------------------------------------------------+
//|                                                       Orders.mqh |
//|                                               Xantrum Solutions. |
//|                                    https://www.xantrum.solutions |
//+------------------------------------------------------------------+
#property copyright "Xantrum Solutions."
#property link      "https://www.xantrum.solutions"

class Order{
   public:
   
   string Order_Symbol;
   int Order_Ticket;
   int Order_Type;
   datetime  Order_Open_Time;
   double  Order_Open_Price;
   double  Order_iClose_Price;
   double  Order_Lots;
   double  Order_Commission;
   double  Order_Swap;
   double  Order_StopLoss;
   double  Order_TakeProfit;
   datetime  Order_Close_Time;
   double Order_Profit;
   double Order_Point;
   bool Closed;
   string Order_Trend;
   bool UnderLimitBuy;
   bool OverLimitSell;
   double MACD_H4Trend;
   datetime TimeTakeProfit;
   
   Order(){};
   ~Order(){};
   
   double Get_Order_Profit(){
      double Profit=0;

      if (this.Order_Type == OP_BUY ) {
        Profit = (MarketInfo(this.Order_Symbol,MODE_BID) - this.Order_Open_Price) * this.Order_Lots * (1 / this.Order_Point) * MarketInfo(this.Order_Symbol, MODE_TICKVALUE);
      } else if (this.Order_Type == OP_SELL ) {
        Profit = (this.Order_Open_Price - MarketInfo(this.Order_Symbol,MODE_ASK)) * this.Order_Lots * (1 / this.Order_Point) * MarketInfo(this.Order_Symbol, MODE_TICKVALUE);
      }
   
      if(OrderSelect(this.Order_Ticket,SELECT_BY_TICKET,MODE_TRADES)==true){
         this.Order_Commission=OrderCommission();
         this.Order_Swap=OrderSwap();
      }
      
      this.Order_Profit=Profit-MathAbs(this.Order_Commission)-MathAbs(this.Order_Swap);
      return this.Order_Profit;
   }
   
   int MinutesOpened(){
      return int((TimeCurrent()-this.Order_Open_Time)/60);
   }
   
};


class Orders
{ 
      
   public: 
   
   Order *OrderList[];
   Order *OpenOrderList[];
   
   Orders(){}; 
   ~Orders(){
      for(int i=0;i<ArraySize(OrderList);i++){
         delete OrderList[i];
      }
   }; 
   
   void Agregar(string _Order_Symbol,int _Order_Ticket,int _Order_Type,datetime _Order_Open_Time,double _Order_Open_Price,double _Order_Lots,double _Order_StopLoss,double _Order_TakeProfit){
      this.Limpiar();
      if(OrderTicket()!=_Order_Ticket)
         if(OrderSelect(_Order_Ticket,SELECT_BY_TICKET,MODE_TRADES)==false)  return;
         
      Order *AddOrder=new Order();
      AddOrder.Order_Symbol=_Order_Symbol;
      AddOrder.Order_Ticket=_Order_Ticket;
      AddOrder.Order_Type=_Order_Type;
      AddOrder.Order_Open_Time=_Order_Open_Time;
      AddOrder.Order_Open_Price=_Order_Open_Price;
      AddOrder.Order_iClose_Price=iClose(_Order_Symbol,TF[TF_H1],0);
      AddOrder.Order_Lots=_Order_Lots;
      AddOrder.Order_Commission=OrderCommission();
      AddOrder.Order_Swap=OrderSwap();
      AddOrder.Order_StopLoss=_Order_StopLoss;
      AddOrder.Order_TakeProfit=_Order_TakeProfit;
      AddOrder.TimeTakeProfit=_Order_Open_Time;
      AddOrder.Order_Point=MarketInfo(_Order_Symbol,MODE_POINT);
      AddOrder.Closed=false;
      AddOrder.Order_Trend=_Order_Type==OP_BUY? "Up" : "Down";
      AddOrder.UnderLimitBuy=UnderLimitBuy;
      AddOrder.OverLimitSell=OverLimitSell;
      ArrayResize(OrderList,ArraySize(OrderList)+1);
      OrderList[ArraySize(OrderList)-1]=AddOrder;
      //Print("Agregar Order : OrderSymbol=",AddOrder.Order_Symbol,", OrderTicket=",AddOrder.Order_Ticket,", OrderType()=",AddOrder.Order_Type,", OrderLots=",AddOrder.Order_Lots);      
   };
   
   void Cerrar(int _Order_Ticket){
      Order *OrderClosed=new Order();
      for(int i=0;i<ArraySize(OrderList);i++){
         Print("Cerrar: OrderList[i].Order_Ticket=",OrderList[i].Order_Ticket,", _Order_Ticket=",_Order_Ticket,", OrderList[i].Closed=",OrderList[i].Closed,", OrderList[i].Order_Close_Time=",OrderList[i].Order_Close_Time);
         if(OrderList[i].Order_Ticket==_Order_Ticket){
            if(OrderList[i].Closed==false){
               OrderList[i].Closed=true;
               OrderList[i].Order_Close_Time=TimeCurrent();
               OrderList[i].Get_Order_Profit();
               OrderClosed=OrderList[i];
               break;
            }else{
               return;
            }
         }   
      }
      
      if(this.TotalProfit()>0){
         int EliminarTickets[],j; 
         for(j=0;j<ArraySize(OrderList);j++){
         
            if(OrderList[j].Order_Symbol==OrderClosed.Order_Symbol && 
               OrderList[j].Order_Ticket<OrderClosed.Order_Ticket && OrderList[j].Order_Type!=OrderClosed.Order_Type && OrderList[j].Closed==true){
               
                  ArrayResize(EliminarTickets,ArraySize(EliminarTickets)+1);
                  EliminarTickets[ArraySize(EliminarTickets)-1]=OrderList[j].Order_Ticket;
            }
         }
         
         for(j=0;j<ArraySize(EliminarTickets);j++){
            Print("Eliminar Ticket=",EliminarTickets[j]);
            this.Eliminar(EliminarTickets[j]);
         }
      }
      
      if(OrderClosed.Order_Ticket==NULL){
         delete OrderClosed;
      }
   }
   
   void Eliminar(int _Order_Ticket){
      for(int i=0;i<ArraySize(OrderList);i++){
         if(OrderList[i].Order_Ticket==_Order_Ticket){
            DeleteElementInArray(OrderList,i);
            break;
         }         
      }
   };
   
   
   void DeleteElementInArray(Order *&Arr[],int index)
     {
      Order *TempArray[];
      delete Arr[index];
      int size=ArraySize(Arr);
      int i;
      if(size==0)
        {
         ArrayFree(Arr);
         ArrayResize(Arr,0);
        }
      else if(index==0)
        {
         ArrayResize(TempArray,size-1);
         for(i=1;i<size;i++)
           {
            TempArray[i-1]=Arr[i];
           }
         ArrayFree(Arr);
         ArrayResize(Arr,size-1);
         for(i=0;i<size-1;i++)
           {
            //if(i<ArraySize(Arr) && i<ArraySize(TempArray))
               Arr[i]=TempArray[i];
            //else   
            //   Print("ArraySize(Arr)=",ArraySize(Arr),", ArraySize(TempArray)=",ArraySize(TempArray),", i=",i);
           }
        }
      else
        {
         ArrayResize(TempArray,size-1);
         for(i=0;i<index;i++)
           {
            TempArray[i]=Arr[i];
           }
         for(i=index+1;i<size;i++)
           {
            TempArray[i-1]=Arr[i];
           }
         ArrayFree(Arr);
         ArrayResize(Arr,size-1);
         for(i=0;i<size-1;i++)
           {
            Arr[i]=TempArray[i];
           }
        }
       
     }
   
   bool Buscar(int _Order_Ticket,Order *&OrderFound){
      this.Limpiar();
      for(int i=0;i<ArraySize(OrderList);i++){
         //Print("Buscar i=",i,", OrderList[i].Order_Ticket==_Order_Ticket",OrderList[i].Order_Ticket,"==",_Order_Ticket);
         if(OrderList[i].Order_Ticket==_Order_Ticket && !OrderList[i].Closed){
            OrderFound=OrderList[i];
            //Print("Buscar=true, index=",i,", OrderTicket=",OrderList[i].Order_Ticket,", OrderOpenTime=",TimeToString(OrderList[i].Order_Open_Time,TIME_DATE|TIME_MINUTES));
            return true;
         }   
      }
      //Print("Buscar=false, OrderTicket=",_Order_Ticket);
      return false;   
   };
   
   Order *OrderAt(int index){
      if(index>=0 && index<ArraySize(OrderList)){
         return OrderList[index];
      }else{
         Order *OrderNull=new Order();
         return OrderNull;   
      }   
   }
   
   void Limpiar(){
      double Order_ClosePrice,Price;
      //string _H4Trend;
      bool Order_Mode_Trade,Order_Mode_History;
      
      for(int i=0;i<ArraySize(OrderList);i++){
         Order_Mode_Trade=OrderSelect(OrderList[i].Order_Ticket,SELECT_BY_TICKET,MODE_TRADES);
         Order_Mode_History=OrderSelect(OrderList[i].Order_Ticket,SELECT_BY_TICKET,MODE_HISTORY);
         Order_ClosePrice=OrderClosePrice();
         Price=(OrderList[i].Order_Type==OP_BUY)? MarketInfo(OrderList[i].Order_Symbol,MODE_BID) : MarketInfo(OrderList[i].Order_Symbol,MODE_ASK);
         
         if(Order_Mode_Trade==false && Order_Mode_History==true){
            
            Print("Limpiar=true, Cerrar Order_Ticket=",OrderList[i].Order_Ticket);
            this.Cerrar(OrderList[i].Order_Ticket);
            
         }/*else if(OrderList[i].Order_StopLoss>0 && ( (OrderList[i].Order_Type==OP_BUY && Price<=OrderList[i].Order_StopLoss) || 
                                                     (OrderList[i].Order_Type==OP_SELL && Price>=OrderList[i].Order_StopLoss) )){
            
            Print("Limpiar=true, Cerrar Order_Ticket=",OrderList[i].Order_Ticket);
            this.Cerrar(OrderList[i].Order_Ticket);               
            
         }else if(OrderList[i].Order_TakeProfit>0 && ( (OrderList[i].Order_Type==OP_BUY && Price>=OrderList[i].Order_TakeProfit) || 
                                                       (OrderList[i].Order_Type==OP_SELL && Price<=OrderList[i].Order_TakeProfit) )){
               
            Print("Limpiar=true, Cerrar Order_Ticket=",OrderList[i].Order_Ticket);
            this.Cerrar(OrderList[i].Order_Ticket);
                
         }*/
          
      }//for
   };
   
   double Profit_LastClosedOrder(){
      for(int i=ArraySize(OrderList)-1;i>=0;i--){
         if(OrderList[i].Closed==true){
            return OrderList[i].Order_Profit;
         }
      }
      return 0;
   }
   
   void ImportOrders(){
      
      //bool Order_Mode_History;
      //Print("OrdersTotal=",OrdersTotal());
      for(int i=0;i<OrdersTotal();i++)
      {
         //Order_Mode_History=OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
         
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true){
            if(OrderType()!=OP_BUY && OrderType()!=OP_SELL) { continue; }
            Order *iOrder=new Order();
            iOrder.Order_Symbol=OrderSymbol();
            iOrder.Order_Ticket=OrderTicket();
            iOrder.Order_Type=OrderType();
            iOrder.Order_Open_Time=OrderOpenTime();
            iOrder.Order_Open_Price=OrderOpenPrice();
            iOrder.Order_Lots=OrderLots();
            iOrder.Order_StopLoss=OrderStopLoss();
            iOrder.Order_TakeProfit=OrderTakeProfit();
            Order *OrderFound;
            
            if(this.Buscar(iOrder.Order_Ticket,OrderFound)==false)
            {
               int MinutesOpened=int((TimeCurrent()-iOrder.Order_Open_Time)/60);
               
               iSymbol=iOrder.Order_Symbol;
               CurrentFunction="CheckForOpen";
               SetTrends(MinutesOpened);
               SetLimits(MinutesOpened);
               PriceTakeProfit=0;
               if(OrderModify(iOrder.Order_Ticket,iOrder.Order_Open_Price,iOrder.Order_StopLoss,PriceTakeProfit,0,Green)){
                  iOrder.Order_TakeProfit=PriceTakeProfit;
               }
               this.Agregar(iOrder.Order_Symbol,iOrder.Order_Ticket,iOrder.Order_Type,iOrder.Order_Open_Time,iOrder.Order_Open_Price,iOrder.Order_Lots,iOrder.Order_StopLoss,iOrder.Order_TakeProfit);
               
               if(this.Buscar(iOrder.Order_Ticket,OrderFound)==true){
                  Print("Imported Order ",i,": OrderSymbol=",iOrder.Order_Symbol,", OrderTicket=",iOrder.Order_Ticket,", OrderType()=",iOrder.Order_Type,", OrderLots=",iOrder.Order_Lots,", iOrder.Order_TakeProfit=",iOrder.Order_TakeProfit);
                }
               
               
              
            }
            
            delete iOrder;
            
          } //if
         
      }//for
      
      
      
   }
   
   
   int FillOpenOrderList(bool CurrentSymbol=false){
      this.Limpiar();
      ArrayFree(OpenOrderList);
      bool AddOrder;
      for(int i=0;i<ArraySize(OrderList);i++){
         AddOrder=CurrentSymbol==false || (CurrentSymbol==true && OrderList[i].Order_Symbol==iSymbol);
         if(OrderList[i].Closed==False && AddOrder==true){
            ArrayResize(OpenOrderList,ArraySize(OpenOrderList)+1);
            OpenOrderList[ArraySize(OpenOrderList)-1]=OrderList[i];
         }
      }
      return ArraySize(OpenOrderList);
   }
   
   bool FreeOrders(){
      int TotalOrders=this.FillOpenOrderList(true);
      return TotalOrders==0 || (TotalOrders==1 && MACD_Trend[TF_H4]!=this.OpenOrderList[0].Order_Trend);
   }
   
   void PrintOrders(){
      Print("Total Orders=",ArraySize(OrderList));
      for(int j=0;j<ArraySize(OrderList);j++){
         Print("OrderList[",j,"].Order_Ticket=",OrderList[j].Order_Ticket,", OrderList[",j,"].Closed=",OrderList[j].Closed);
      }
   }
   
   bool FirstOrder(string Trend,int _MACD_TF,int Periods){
      datetime from_date=iTime(iSymbol,TF[_MACD_TF],Periods);
      Print("FirstOrder: Trend=",Trend,", _MACD_TF=",_MACD_TF,", Periods=",Periods,", from_date=",from_date);      
      for(int i=0;i<ArraySize(OrderList);i++){
         //Print("FirstOrder: Order_Symbol=",OrderList[i].Order_Symbol,", Order_Ticket=",OrderList[i].Order_Ticket,", Order_Trend=",OrderList[i].Order_Trend,", Order_Open_Time=",OrderList[i].Order_Open_Time,", Order_Close_Time=",OrderList[i].Order_Close_Time,", from_date=",from_date,", Periods=",Periods);
         if(OrderList[i].Order_Symbol==iSymbol && OrderList[i].Order_Trend==Trend && (OrderList[i].Order_Open_Time>=from_date || OrderList[i].Order_Close_Time>=from_date)){
            Print("FirstOrder: Order_Symbol=",OrderList[i].Order_Symbol,", Order_Ticket=",OrderList[i].Order_Ticket,", Order_Trend=",OrderList[i].Order_Trend,", Order_Open_Time=",OrderList[i].Order_Open_Time,", Order_Close_Time=",OrderList[i].Order_Close_Time,", from_date=",from_date,", Periods=",Periods);
            return false;
         }
      }
      return true;
   }
   
   double TotalProfit(){
      double TotalProfit=0;
      for(int i=0;i<ArraySize(OrderList);i++){
         if(OrderList[i].Closed==true){
            TotalProfit+=OrderList[i].Order_Profit;
         }
      }
      return TotalProfit;
   }
   
}; 
