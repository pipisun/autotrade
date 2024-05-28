//+------------------------------------------------------------------+
//|                                                      MyEA.mq5    |
//|                        Copyright 2024, MetaQuotes Software Corp. |
//|                                             http://www.mql5.com |
//+------------------------------------------------------------------+
#property strict

// Input parameters
input int MA5_Period = 5;
input int MA30_Period = 30;
input int RSI_Period = 14;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // Initializing indicators
    IndicatorCreate(0, IND_MA, 0, MA5_Period, 0, PRICE_CLOSE);
    IndicatorCreate(0, IND_MA, 0, MA30_Period, 0, PRICE_CLOSE);
    IndicatorCreate(0, IND_RSI, 0, RSI_Period);

    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert tick function                                            |
//+------------------------------------------------------------------+
void OnTick()
{
    // Getting indicator values
    double ma5 = iMA(NULL, 0, MA5_Period, 0, MODE_SMA, PRICE_CLOSE, 0);
    double ma30 = iMA(NULL, 0, MA30_Period, 0, MODE_SMA, PRICE_CLOSE, 0);
    double rsi = iRSI(NULL, 0, RSI_Period, PRICE_CLOSE, 0);

    // Getting the latest price
    double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);

    // Opening conditions
    if (ma5 > ma30 && rsi < 25 && price > ma30) // Long entry
    {
        // Place buy order
        // OrderSend(...);
    }
    else if (ma5 < ma30 && rsi > 75 && price < ma30) // Short entry
    {
        // Place sell order
        // OrderSend(...);
    }

    // Closing conditions
    if (rsi < 30) // Close long order
    {
        // Close buy order
        // OrderClose(...);
    }
    else if (rsi > 70) // Close short order
    {
        // Close sell order
        // OrderClose(...);
    }

    // Stop loss conditions
    if (ma5 < ma30) // Close long order
    {
        // Close buy order
        // OrderClose(...);
    }
    else if (ma5 > ma30) // Close short order
    {
        // Close sell order
        // OrderClose(...);
    }
}

//+------------------------------------------------------------------+
