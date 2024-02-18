//+------------------------------------------------------------------+
//|                                               Moving Average.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property description "Moving Average sample expert advisor"

#define MAGICMA  20131111
//--- Inputs
input double Lots           = 0.01;
input double MaximumRisk    = 0.02;
input double DecreaseFactor = 3;
input double TrailingStop   = 100;

double buyfuwei = 500;
double sellfuwei = 500;

static int curBarCount = 100;

datetime curTime;

//Added checkOpenConditionMet when opening position

//+------------------------------------------------------------------+
//| Calculate open positions                                         |
//+------------------------------------------------------------------+
int CalculateCurrentOrders(string symbol)
  {
   int buys=0,sells=0;
//---
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
        {
         if(OrderType()==OP_BUY)  buys++;
         if(OrderType()==OP_SELL) sells++;
        }
     }
//--- return orders volume
   if(buys>0) return(buys);
   else       return(-sells);
  }
//+------------------------------------------------------------------+
//| Calculate optimal lot size                                       |
//+------------------------------------------------------------------+
double LotsOptimized()
  {
   double lot=Lots;
   int    orders=HistoryTotal();     // history orders total
   int    losses=0;                  // number of losses orders without a break
//--- select lot size
   lot=NormalizeDouble(AccountFreeMargin()*MaximumRisk/1000.0,1);
//--- calcuulate number of losses orders without a break
   if(DecreaseFactor>0)
     {
      for(int i=orders-1;i>=0;i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false)
           {
            Print("Error in history!");
            break;
           }
         if(OrderSymbol()!=Symbol() || OrderType()>OP_SELL)
            continue;
         //---
         if(OrderProfit()>0) break;
         if(OrderProfit()<0) losses++;
        }
      if(losses>1)
         lot=NormalizeDouble(lot-lot*losses/DecreaseFactor,1);
      if(losses>2)
         curBarCount = Bars + 24;
     }
//--- return lot size
   if(lot<0.4) lot=Lots;
   return(lot);
  }
//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
void CheckForOpen()
  {
   int    res;
   double RSIValue;
   double ma15, ma30;
   double ma5, ma10;
   double bearPower, bullPower;
   double TakeProfitForOpen = 1000;
   double StopLossForOpen = 300;
   double mtm10;
   //double PriceAsk = MarketInfo(Symbol(), MODE_ASK);
   //double PriceBid = MarketInfo(Symbol(), MODE_BID);
//--- go trading only for first tiks of new bar
   if(Volume[0]>1) return;
//--- get RSI and ma15 and ma30
   RSIValue = iRSI(Symbol(), 0, 14, PRICE_CLOSE,0);
   ma5  = iMA(Symbol(),0,5,0,MODE_SMA,PRICE_CLOSE,0);
   //ma30 = iMA(Symbol(),0,30,0,MODE_SMA,PRICE_CLOSE,0);
   //ma5  = iMA(Symbol(),0,5,0,MODE_SMA,PRICE_CLOSE,0);
   ma10 = iMA(Symbol(),0,10,0,MODE_SMA,PRICE_CLOSE,0);
   mtm10 = iMomentum(Symbol(),0,12,PRICE_CLOSE,0);
   //bearPower = iBearsPower(Symbol(),0, 13, PRICE_CLOSE, 0);
   //bullPower = iBullsPower(Symbol(), 0, 13, PRICE_CLOSE, 0);
   //Print("ma5", ma5);
   //Print("ma10", ma10);
//--- sell conditions
   //if(ma5 > ma10 && Open[1] < Close[1])
   if((RSIValue >= 80 || RSIValue >= 60 && RSIValue <= 70) && ma5 - 10 < ma10)
     {
         RefreshRates();
         res = OrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,3,Ask+StopLossForOpen*Point,Bid-TakeProfitForOpen*Point,"",MAGICMA,0,Red);
         if(res != -1) {
            curTime = TimeCurrent();
            Print("Sell order is created, RSI value:" + RSIValue);
            //Print("Current Time is: " + curTime);
         }
         else {
            Print("Error on creating orders: ", GetLastError());
         }
      }
   else if((RSIValue <= 20 || RSIValue >= 30 && RSIValue <= 45) && ma5 + 10 > ma10)
     {
         RefreshRates();
         res=OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,3,Bid-StopLossForOpen*Point,Ask+TakeProfitForOpen*Point,"",MAGICMA,0,Blue);
         if(res != -1) {
            curTime = TimeCurrent();
            Print("Buy order is created, RSI value:" + RSIValue);
            //Print("Current Time is: " + curTime);
         }
         else {
            Print("Error on creating orders: ", GetLastError());
         }
      }
  }

void CheckForModify()
{
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(ORDER_TYPE == OP_BUY)
      {
         if(((Bid - OrderOpenPrice()) / Point) >= buyfuwei) {
            double buysl = OrderStopLoss(); 
            if(OrderModify(OrderTicket(),OrderOpenPrice(),buysl + TrailingStop*Point,OrderTakeProfit(),0) == true) {
                buyfuwei = buyfuwei + TrailingStop;
            }
            else {
               Print("Error details: ", GetLastError());
            }
         }
      }
      else if(ORDER_TYPE == OP_SELL)
      {
         if(((OrderOpenPrice() - Ask) / Point) >= sellfuwei) {
            double sellsl = OrderStopLoss();
            double updatedPrice = sellsl - TrailingStop*Point;
            if(updatedPrice < 0) updatedPrice = 0;
            if(OrderModify(OrderTicket(),OrderOpenPrice(),updatedPrice,OrderTakeProfit(),0) == true) {
               sellfuwei = sellfuwei + TrailingStop;
            }
            else {
               Print("Error details: ", GetLastError());
            }
         }
      }
   }
}
//+------------------------------------------------------------------+
//| Check for close order conditions                                 |
//+------------------------------------------------------------------+
void CheckForClose() {
   double ma15, ma30;
   double ma5, ma10;
   double RSIValue;
   int res;
   double TakeProfit = 200;
   double StopLoss = 100;
   string nowTime;
   string SpecificHrTime;
   double mtm10;
//--- go trading only for first tiks of new bar
   if(Volume[0]>1) return;
//--- get MA15, MA30 and RSIValue 
   RSIValue = iRSI(Symbol(), 0, 14, PRICE_CLOSE,0);
   ma5  = iMA(Symbol(),0,5,0,MODE_SMA,PRICE_CLOSE,0);
   //ma30 = iMA(Symbol(),0,30,0,MODE_SMA,PRICE_CLOSE,0);
   //ma15  = iMA(Symbol(),0,15,0,MODE_SMA,PRICE_CLOSE,0);
   ma10 = iMA(Symbol(),0,10,0,MODE_SMA,PRICE_CLOSE,0);
   nowTime = IntegerToString(24 * 60 * 60);
   SpecificHrTime = IntegerToString(4 * 60 * 60);
   mtm10 = iMomentum(Symbol(),0,12,PRICE_CLOSE,0);
   //FiveDollarProfileForMinLot = 500 * OrderLots();
//---
   for(int i = 0; i < OrdersTotal(); i++) {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == false) break;
      if(OrderMagicNumber() != MAGICMA || OrderSymbol() != Symbol()) continue;
      //--- check order type 
      if(OrderType() == OP_BUY) {
        if(OrderProfit() < 0 && TimeCurrent() - curTime > SpecificHrTime) {
           Print("Profit=", OrderProfit(), " > 0 and time is over 24 hours, closing the buy order...");
           closePosition("buy");
           return;
        } 
        
        if(OrderProfit() > 0 && TimeCurrent() - curTime > nowTime) {
           Print("Profit=", OrderProfit(), " > 0 and time is over 1 day, closing the order...");
           closePosition("buy");
           return;
        }
                 
        if((RSIValue >= 60 && RSIValue <= 80 || RSIValue >= 80 || ma5 + 10 < ma10 || mtm10 < ma10) && OrderProfit() >= 500 * OrderLots() || OrderProfit() <= -150 * OrderLots()) {
         closePosition("buy");
         return;
        } 
      }
      else if(OrderType() == OP_SELL) {
        if(OrderProfit() < 0 && TimeCurrent() - curTime > SpecificHrTime) {
           Print("Profit=", OrderProfit(), " < 0 and time is over 24 hours, closing the sell order...");
           closePosition("sell");
           return;
        }
        if(OrderProfit() > 0 && TimeCurrent() - curTime > nowTime) {
           Print("Profit=", OrderProfit(), " > 0 and time is over 1 day, closing the order...");
           closePosition("sell");
           return;
        }
        if((RSIValue >= 30 && RSIValue <= 50 || RSIValue <= 20 || ma5 - 10 > ma10 || mtm10 > ma10) && OrderProfit() >= 500 * OrderLots() || OrderProfit() <= -150 * OrderLots()) {
         closePosition("sell");
         return;
        } 
      }
   }
}

void OnTick() {
//--- check for history and trading
   if(Bars < curBarCount || IsTradeAllowed() == false)
      return;
      
//--- calculate open orders by current symbol
   if(CalculateCurrentOrders(Symbol()) == 0) CheckForOpen();
   else  
   {
      CheckForModify();
      CheckForClose();
   }
//---
}
//+------------------------------------------------------------------+


bool meetKLineCondition(int num) 
{
   bool isMeetCondition = false;
   for(int i=num;i>1;i--) 
   {
      if((Close[i] < Open[i] && Close[i] > Close[i-1] && Open[i] > Open[i-1]) ||
         (Close[i] > Open[i] && Close[i] < Close[i-1] && Open[i] < Open[i-1]))
         isMeetCondition = true;
      else
      {
         isMeetCondition = false;
         break;
      }
   }
   return isMeetCondition;
}

bool checkOpenConditionMet(string objType, int num)
{
   bool isCheckOpenConditionMet = false;
   for(int i=num;i>2;i--)
   {
      if(objType == "buy") 
      {
         //if(Close[i] > Open[i] && Close[i] < Close[i-1] && Open[i] < Open[i-1]) 
         if(Close[i] > Open[i] && Close[i] < Close[i-1] && Open[i] < Open[i-1]) 
         {
            if(i==3 && Open[1] < Close[1] && High[1] - Close[1] > 200 * Point) {
               isCheckOpenConditionMet = true;
            }
         }
         else
         {
            isCheckOpenConditionMet = false;
            break;
         }
      }
      else 
      {
         //if(Close[i] < Open[i] && Close[i] > Close[i-1] && Open[i] > Open[i-1])
         if(Close[i] < Open[i] && Close[i] > Close[i-1] && Open[i] > Open[i-1])  
         {
            if(i==3 && Open[1] > Close[1] && High[1] - Close[1] > 200 * Point) {
               isCheckOpenConditionMet = true;
            }
         }
         else
         {
            isCheckOpenConditionMet = false;
            break;
         }   
      }
   }
   return isCheckOpenConditionMet;
}

bool ifClosePositionAtOnce(string orderType, double n_profit) 
{
   //Print("OrderProfit:" +OrderProfit());
   if((n_profit < 0 && OrderProfit() < OrderLots() * n_profit) || (n_profit > 0 && OrderProfit() >= OrderLots() * n_profit)) 
   {
      RefreshRates();
      closePosition(orderType);
      return true;
   }
   
   return false;
}

void closePosition(string orderType)
{
   if(orderType == "buy") 
   {
      if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,White))
         Print("OrderClose error ",GetLastError());
      else
         Print("OrderClose succeeded for buy order(over limit).");
   }
   else
   {
      if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,White))
         Print("OrderClose error ",GetLastError());
      else
         Print("OrderClose succeeded for sell order(over limit).");
   }
}

bool is1Down1Up1Down()
{
   if(Close[3] < Close[2] && Close[3] > Close[1] &&
      Close[3] < Open[3] && Close[1] < Open[1] &&
      Close[2] > Open[2])
      return true;
   
   return false;
}

bool is1Up1Down1Up()
{
   if(Close[3] > Close[2] && Close[3] < Close[1] &&
      Close[3] > Open[3] && Close[1] > Open[1] &&
      Close[2] < Open[2])
      return true;
   
   return false;
}