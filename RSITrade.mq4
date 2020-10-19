/*
﻿//+------------------------------------------------------------------+
//| MACD Sample.mq4 |
//| Copyright ? 2005, MetaQuotes Software Corp. |
//| http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
*/
extern double TakeProfit = 500;
extern double StopLoss = 300;
extern double Lots = 0.1;
extern double TrailingStop = 30;
extern double MACDOpenLevel=3;
extern double MACDCloseLevel=2;
extern double MATrendPeriod=26;
input ENUM_MA_METHOD    MA类型=MODE_SMA;

//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
void OnTick()
{
   double MacdCurrent, MacdPrevious, SignalCurrent;
   double SignalPrevious, MaCurrent, MaPrevious;
   int cnt, ticket, total;
   string signal = "";
   double RSIValue;
   
   double ma15, ma30;
   
   if(Bars<100)
   {
      Print("less than 100 bars");
      return(0);
   }
//---

   
// while(true) {
   // Check the fund
   /*if(AccountFreeMargin()<(1000*Lots))
   {
      Print("No free fund. margin fund = ", AccountFreeMargin());
      return(0);
   }
   */
   //RefreshRates();
   total = OrdersTotal();
   RSIValue = iRSI(Symbol(), 0, 14, PRICE_CLOSE,0);
   ma15  = iMA(Symbol(),0,15,0,MA类型,PRICE_CLOSE,1);
   ma30 = iMA(Symbol(),0,30,0,MA类型,PRICE_CLOSE,1);
       
   Print("Total orders:", total);
   Print("Lots:", Lots);
   Print("RSI:", RSIValue);
   
   if(RSIValue > 50 && total == 0 && ma15 > ma30) {
      ticket = OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Bid-StopLoss*Point,Ask+TakeProfit*Point,"open to buy transaction",0,0,Green);
   } 
   
   else if(RSIValue < 50 && total == 0 && ma15 < ma30) {
      ticket = OrderSend(Symbol(), OP_SELL, Lots, Bid,3,Ask+StopLoss*Point,Bid-TakeProfit*Point,"open to sell transaction",0,0,Red);
   }
   
   /*
   for(int i=0;i<total;i++) {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(RSIValue < 50 && total >=1 && OrderType()==OP_BUY) {
         if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,White))
               Print("OrderClose error ",GetLastError());
      }
      else if(RSIValue > 50 && total >=1 && OrderType()==OP_SELL) {
       if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,White))
               Print("OrderClose error ",GetLastError());
      }
   }*/
      //Sleep(5000);
   //}  
   
}
//+------------------------------------------------------------------+
