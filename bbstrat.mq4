//+------------------------------------------------------------------+
//|                                                       Learn1.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

input int n = 10;
int buy[n], sell[n];
int cur_buy = 0, cur_sell = 0;
input double commission = 7.0;
input double smallLot = 0.01;
input double minProfit = 5;

const int chk = 25;
double main[25], up[25], down[25], bids[25], asks[25];

int OnInit()
{
   for(int i = 0; i < chk; i++)
   {
      main[i] = up[i] = down[i] = bids[i] = asks[i] = -1;
   }
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
}

void OnTick()
{
   for(int i = 0; i < chk-1; i++)
   {
      main[i] = main[i+1];
      up[i] = up[i+1];
      down[i] = down[i+1];
      bids[i] = bids[i+1];
      asks[i] = asks[i+1];
   } 
   main[chk-1] = iBands(Symbol(), PERIOD_M1, 20, 2, 0, PRICE_CLOSE, MODE_MAIN, 0);
   up[chk-1] = iBands(Symbol(), PERIOD_M1, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, 0);
   down[chk-1] = iBands(Symbol(), PERIOD_M1, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, 0);
   bids[chk-1] = Bid;
   asks[chk-1] = Ask;
   
   int buy_trig = 0, sell_trig = 0;
   for(int i = 0; i < chk; i++)
   {
      if(bids[i] <= down[i]) buy_trig++;
      if(asks[i] >= up[i]) sell_trig++;
   }
   
   if(buy_trig == chk)
   {
      int Sell = find_sell();
      if(Sell != -1 && OrderSelect(Sell, SELECT_BY_TICKET))
      {
         if(OrderClose(sell[Sell], OrderLots(), Bid, 10, clrCrimson))
            sell[Sell] = -1;
      }
      else if(buy == -1)
      {
         buy = OrderSend(Symbol(), OP_BUY, smallLot, Bid, 10, 0, 0, NULL, 5, 0, clrGreen);
      } 
   }
   else if(sell_trig == chk)
   {
      if(buy != -1 && OrderSelect(buy, SELECT_BY_TICKET))
      {
         if(OrderClose(buy, OrderLots(), Ask, 10, clrGreen))
            buy = -1;
      }
      else if(sell == -1)
      {
         sell = OrderSend(Symbol(), OP_SELL, smallLot, Ask, 10, 0, 0, NULL, 5, 0, clrCrimson);
      } 
   }
}