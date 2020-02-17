//+------------------------------------------------------------------+
//| MACD Sample.mq4 |
//| Copyright ? 2005, MetaQuotes Software Corp. |
//| http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
extern double TakeProfit = 800;
extern double StopLoss = 400;
extern double Lots = 0.01;
extern double TrailingStop = 30;
extern double MACDOpenLevel=3;
extern double MACDCloseLevel=2;
extern double MATrendPeriod=26;

//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
int start()
{
   double MacdCurrent, MacdPrevious, SignalCurrent;
   double SignalPrevious, MaCurrent, MaPrevious;
   int cnt, ticket, total;
   
   if(Bars<100)
   {
      Print("less than 100 bars");
      return(0);
   }
   if(TakeProfit<10)
   {
      Print("profit < 10");
      return(0); 
   }
   
   while(true) {
      // Check the fund
      if(AccountFreeMargin()<(1000*Lots))
      {
         Print("No free fund. margin fund = ", AccountFreeMargin());
         return(0);
      }
      RefreshRates();
      total = OrdersTotal();
      Print("Total orders:", total);
      Print("Lots:", Lots);
      Print("Ask...", Ask - 50 * Point);
      if(total < 1)
      {
         ticket = OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Bid-StopLoss*Point,Ask+TakeProfit*Point,"usd/chf transaction",16387,0,Green);
         
      }
      else if(total < 2) {
         //ticket = OrderSend(Symbol(),OP_BUY,Lots,Ask - 200 * Point,3,Bid - 20 * Point-StopLoss*Point,Ask - 20 * Point+TakeProfit*Point,"usd/chf transaction 2",16385,0,Blue);
         ticket = OrderSend(Symbol(), OP_BUYLIMIT, Lots, Ask - 200 * Point,3,Bid - 200 * Point-StopLoss*Point,Ask - 200 * Point+TakeProfit*Point,"usd/chf transaction 2",16388,0,Blue);
      }
      //Sleep(5000);
   }
}
