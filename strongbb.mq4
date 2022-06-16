//+------------------------------------------------------------------+
//|                                                       Learn1.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

input int n = 4;
int buys[10], sells[10];
int cur_buy = 0, cur_sell = 0;
input double commission = 7.0;
input double smallLot = 0.5;
input double minProfit = 5;
input double minProfitPercent = 5;
input double goodProfit = 250;
// input double sl = 500;

int periods[] = {1, 5, 15, 30, 60, 240, 1440, 10080, 43200};

const int chk = 6;
double main[25], up[25], down[25];
double bids, asks;

int OnInit()
{
   for(int i = 0; i < chk; i++)
   {
      main[i] = up[i] = down[i] = -1;
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

double secondsSince()
{
   return TimeCurrent() - OrderOpenTime();
}

double hoursSince()
{
   return (1.0*secondsSince())/3600;
}

double daysSince()
{
   return (1.0*hoursSince())/24;
}

string prev = "";

void OnTick()
{
   for(int i = 0; i < chk; i++)
   {
      main[i] = iBands(Symbol(), periods[i], 20, 2, 0, PRICE_CLOSE, MODE_MAIN, 0);
      up[i] = iBands(Symbol(), periods[i], 20, 2, 0, PRICE_CLOSE, MODE_UPPER, 0);
      down[i] = iBands(Symbol(), periods[i], 20, 2, 0, PRICE_CLOSE, MODE_LOWER, 0);
   } 
   bids = Bid;
   asks = Ask;
   
   // Good profit close
   for(int i = 0; i < n; i++)
   {
      if(buys[i] > 0)
      {
          if(OrderSelect(buys[i], SELECT_BY_TICKET))
          {
            if(Profit() >= OrderLots()*goodProfit)
            {
               if(OrderClose(buys[i], OrderLots(), Bid, 100, clrBrown))
               {
                  buys[i] = 0;
                  cur_buy--;
               }
            }
            else
            {
               double hoursElapsed = hoursSince();
               if(hoursElapsed >= 4)
               {
                  double decentProfit = goodProfit/MathPow(2, hoursElapsed-4);
                  if(Profit() >= OrderLots()*decentProfit)
                  {
                     if(OrderClose(buys[i], OrderLots(), Bid, 100, clrBrown))
                     {
                        buys[i] = 0;
                        cur_buy--;
                     }
                  }
               }    
            }
          }
      }
      if(sells[i] > 0)
      {
         if(OrderSelect(sells[i], SELECT_BY_TICKET))
         {
            if(Profit() >= OrderLots()*goodProfit)
            {
               if(OrderClose(sells[i], OrderLots(), Ask, 100, clrLimeGreen))
               {
                  sells[i] = 0;
                  cur_sell--;
               }
            }
         }
         else
         {
            double hoursElapsed = hoursSince();
            if(hoursElapsed >= 4)
            {
               double decentProfit = goodProfit/MathPow(2, hoursElapsed-4);
               if(Profit() >= OrderLots()*decentProfit)
               {
                  if(OrderClose(sells[i], OrderLots(), Ask, 100, clrLimeGreen))
                  {
                     sells[i] = 0;
                     cur_sell--;
                  }
               }
            }    
         }
      }
   }
   
   // Stop loss close
   /*
   for(int i = 0; i < n; i++)
   {
      if(OrderSelect(buys[i], SELECT_BY_TICKET))
      {
         if(percent_gain() <= sl)
         {
            if(OrderClose(buys[i], OrderLots(), Bid, 10, clrCrimson))
            {
               buys[i] = 0;
               cur_buy--;
            }
         }
      }
      if(OrderSelect(sells[i], SELECT_BY_TICKET))
      {
         if(percent_gain() <= sl)
         {
            if(OrderClose(sells[i], OrderLots(), Ask, 10, clrGreen))
            {
               sells[i] = 0;
               cur_sell--;
            }
         }
      }
   }
   */
   
   int buy_trig = 0, sell_trig = 0;
   for(int i = 0; i < chk; i++)
   {
      if(bids <= down[i]+0.1*(up[i]-down[i])) buy_trig++;
      if(asks >= up[i]-0.1*(up[i]-down[i])) sell_trig++;
   }
   
   if(buy_trig >= 4 && prev == "topdown")
   {
      int sell = find_sell();
      bool done = false;
      if(sell != -1 && OrderSelect(sells[sell], SELECT_BY_TICKET))
      {
         if(percent_gain() >= minProfitPercent)
         {
            if(OrderClose(sells[sell], OrderLots(), Ask, 10, clrGreen))
            {
               prev = "close";
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
            prev = "buy";
            buys[buy] = OrderSend(Symbol(), OP_BUY, smallLot, Ask, 10, 0, 0, NULL, 5, 0, clrGreen);
            cur_buy++;
         }
      } 
   }
   else if(sell_trig >= 4 && prev == "downtop")
   {
      int buy = find_buy();
      bool done = false;
      if(buy != -1 && OrderSelect(buys[buy], SELECT_BY_TICKET))
      {
         if(percent_gain() >= minProfitPercent)
         {
            if(OrderClose(buys[buy], OrderLots(), Bid, 10, clrCrimson))
            {
               prev = "close";
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
            prev = "sell";
            done = true;
            sells[sell] = OrderSend(Symbol(), OP_SELL, smallLot, Bid, 10, 0, 0, NULL, 5, 0, clrCrimson);
            cur_sell++;
         }
      }  
   }
   else
   {
      if(bids >= main[0] && bids <= main[0]+0.1*(up[0]-main[0])) prev = "downtop";
      else if(asks <= main[0] && asks >= main[0]-0.1*(main[0]-down[0])) prev = "topdown";
   }
}