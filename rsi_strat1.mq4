//+------------------------------------------------------------------+
//|                                                       Learn1.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

input int n = 5;
int buy[10], sell[10];
int cur_buy = 0, cur_sell = 0;
input double commission = 7.0;
input double smallLot = 0.1;
input double minProfit = 5;

int OnInit()
{
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{

}

void OnTick()
{
   
   double rsi = iRSI(Symbol(), PERIOD_M1, 14, PRICE_CLOSE, 0); 

   if(rsi >= 70)
   {
      bool ch = true;
      int index = -1;
      if(cur_buy >= 0)
      {
         double max_profit = minProfit;
         for(int i = 0; i < n; i++)
         {
            if(buy[i] > 0 && OrderSelect(buy[i], SELECT_BY_TICKET))
            {
               double cur_profit = OrderProfit()-commission*OrderLots();
               if(cur_profit > max_profit)
               {
                  max_profit = cur_profit;
                  index = i;
               }
            }
         }
         
      }
      if(index != -1)
      { 
         bool temp = OrderSelect(buy[index], SELECT_BY_TICKET);
      }
      if(index != -1 && OrderClose(buy[index], OrderLots(), Bid, 100, clrBrown))
      {
         Print("Closed the lot ", buy[index], " size ", OrderLots());
         ch = false;
         buy[index] = 0;
         cur_buy--;
      }
      if(ch && cur_sell < n)
      {
         int ticket = OrderSend(Symbol(), OP_SELL, smallLot, Bid, 100, 0, 0, NULL, 5, 0, clrCrimson); 
         Print("Sold a lot ", smallLot, "ticket ", ticket);
         for(int i = 0; i < n; i++)
         {
            if(sell[i] == 0)
            {
               sell[i] = ticket;
               cur_sell++;
               break;
            }
         }
      }
   }
   if(rsi <= 30)
   {
      bool ch = true;
      int index = -1;
      if(cur_sell >= 0)
      {
         double max_profit = minProfit;
         for(int i = 0; i < n; i++)
         {
            if(sell[i] > 0 && OrderSelect(sell[i], SELECT_BY_TICKET))
            {
               double cur_profit = OrderProfit()-commission*OrderLots();
               if(cur_profit > max_profit)
               {
                  max_profit = cur_profit;
                  index = i;
               }
            }
         }
         
      }
      if(index != -1)
      { 
         bool temp = OrderSelect(sell[index], SELECT_BY_TICKET);
      }
      if(index != -1 && OrderClose(sell[index], OrderLots(), Ask, 100, clrLimeGreen))
      {
         Print("Closed the lot ", sell[index], " size ", OrderLots());
         ch = false;
         sell[index] = 0;
         cur_sell--;
      }
      if(ch && cur_buy < n)
      {
         int ticket = OrderSend(Symbol(), OP_BUY, smallLot, Ask, 100, 0, 0, NULL, 5, 0, clrGreen); 
         Print("Bought a lot ", smallLot, "ticket ", ticket);
         for(int i = 0; i < n; i++)
         {
            if(buy[i] == 0)
            {
               buy[i] = ticket;
               cur_buy++;
               break;
            }
         }
      }
   }
}