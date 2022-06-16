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
int buys[10], sells[10];
int cur_buy = 0, cur_sell = 0;
input double commission = 7.0;
input double smallLot = 0.01;
input double minProfit = 5;
input double minProfitPercent = 5;

const int chk = 10;
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

int find_sell()
{
   double cur_min = minProfit;
   int ind = -1;
   for(int i = 0; i < n; i++)
   {
      if(sells[i] != 0 && OrderSelect(sells[i], SELECT_BY_TICKET))
      {
         if(OrderProfit() > cur_min)
         {
            cur_min = OrderProfit();
            ind = i;
         }
      }
   }
   return ind;
}

int find_buy()
{
   double cur_min = minProfit;
   int ind = -1;
   for(int i = 0; i < n; i++)
   {
      if(buys[i] != 0 && OrderSelect(buys[i], SELECT_BY_TICKET))
      {
         if(OrderProfit() > cur_min)
         {
            cur_min = OrderProfit();
            ind = i;
         }
      }
   }
   return ind;
}


int find_free_buy()
{
   for(int i = 0; i < n; i++)
   {
      if(buys[i] <= 0) return i;
   }
   return -1;
}

int find_free_sell()
{
   for(int i = 0; i < n; i++)
   {
      if(sells[i] <= 0) return i;
   }
   return -1;
}

double Profit()
{
   return OrderProfit()-commission*OrderLots();
}

double percent_gain()
{
   double pro = Profit();
   double deposit = OrderLots()*1000;
   double percent = 100.0*pro/deposit;
   return percent;
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
      if(bids[i] <= down[i]+0.1*(up[i]-down[i])) buy_trig++;
      if(asks[i] >= up[i]-0.1*(up[i]-down[i])) sell_trig++;
   }
   
   if(buy_trig == chk)
   {
      int sell = find_sell();
      bool done = false;
      if(sell != -1 && OrderSelect(sells[sell], SELECT_BY_TICKET))
      {
         if(percent_gain() >= minProfitPercent)
         {
            if(OrderClose(sells[sell], OrderLots(), Ask, 10, clrGreen))
            {
               done = true;
               sells[sell] = 0;
               cur_sell--;
            }
         }
      }
      if(!done)
      {
         int buy = find_free_buy();
         if(buy != -1)
         {
            buys[buy] = OrderSend(Symbol(), OP_BUY, smallLot, Ask, 10, 0, 0, NULL, 5, 0, clrGreen);
            cur_buy++;
         }
      } 
   }
   else if(sell_trig == chk)
   {
      int buy = find_buy();
      bool done = false;
      if(buy != -1 && OrderSelect(buys[buy], SELECT_BY_TICKET))
      {
         if(percent_gain() >= minProfitPercent)
         {
            if(OrderClose(buys[buy], OrderLots(), Bid, 10, clrCrimson))
            {
               done = true;
               buys[buy] = 0;
               cur_buy--;
            }
         }
      }
      if(!done)
      {
         int sell = find_free_sell();
         if(sell != -1)
         {
            sells[sell] = OrderSend(Symbol(), OP_SELL, smallLot, Bid, 10, 0, 0, NULL, 5, 0, clrCrimson);
            cur_sell++;
         }
      }  
   }
}