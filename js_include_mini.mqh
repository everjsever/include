
int PointUnit=10;
 double UpLinePrice=0;
 double DownLinePrice=0;
 double MiddleLinePrice=0;
 double MiddleHLinePriceHigh=0; 
double ShiBaiLot=0.01;//加仓数量
double JiaCangLimit=200;//加仓止盈
 
//--- input parameters of the script 
 string          InpName="HLine";     // Line name 

 color           InpColor=clrRed;     // Line color 
 ENUM_LINE_STYLE InpStyle=STYLE_DASH; // Line style 
 int             InpWidth=1;          // Line width 
 bool            InpBack=false;       // Background line 
 bool            InpSelection=true;   // Highlight to move 
 bool            InpHidden=true;      // Hidden in the object list 
 long            InpZOrder=0;         // Priority for mouse click 
//////////////////////////////////////////




void InitPlatForm(){
   int    vdigits;
   vdigits = MarketInfo("EURUSD",MODE_DIGITS); 
   if(vdigits==5 || vdigits==3) PointUnit=10;
   else if(vdigits==4) PointUnit=1;

   if(Digits==3 || Digits==5)
     {
      dig*=10;
     } 
   if(zhanghuzijin==1)       zhanghuzijin=AccountEquity();       
}
int OpenLong(double volume=0.01,int mymagic=9999,double stop=0,double limit=0,string symbol="")
// the function opens a long position with lot size=volume 
{

  int slippage=5;
  string comment=symbol;//+IntegerToString(mymagic);
  color arrow_color=Red;
  if(ManageEquity()==false) return(-2);
//  if(TodayOrderCount >OrderMaxToday) return(-2); // today max order after call ManageEquity

  double ask=SymbolInfoDouble(symbol,SYMBOL_ASK); 

  int ticket=OrderSend(symbol,OP_BUY,volume,ask,slippage,stop,limit,comment,mymagic);
  if(ticket>0)
  {
      printf("comment=%s ,mymagic=%d ",comment,mymagic);
  return ticket;
  }
  else 
  {
    Print("Error opening Buy order : ",GetLastError()); 
    return(-1);
  }
}
int OpenShort(double volume=0.01,int mymagic=9999,double stop=0,double limit=0,string symbol="")
{

  int slippage=5;
  string comment=symbol;//+IntegerToString(mymagic);
  color arrow_color=Red;
  if(ManageEquity()==false) return(-2); 
  //if(TodayOrderCount >OrderMaxToday) return(-2); // today max order after call ManageEquity

  double bid=SymbolInfoDouble(symbol,SYMBOL_BID); 
  int ticket=OrderSend(symbol,OP_SELL,volume,bid,slippage,stop,limit,comment,mymagic);
  if(ticket>0)
  {
    printf("comment=%s ,mymagic=%d ",comment,mymagic);
  }
  else 
  {
    Print("Error opening Sell order : ",GetLastError(),"Symbol=",symbol,"Stop=",stop,"limit=",limit,"volume=",volume); 
    return(-1);
  }
  return ticket;
}
int JudgeMagicNumberExit(int majic=0,string comment=""){
  int    cmd=0,i; 
  int total=OrdersTotal(); 
  //printf("total=%d %s  %s",total,comment,OrderComment());
 for( i=0; i<total; i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         cmd=OrderMagicNumber();
         if(StringCompare(comment,"")==0){
            if(cmd==majic)    return (100);
            }
         else{

            if(cmd==majic && StringCompare(comment,OrderComment())==0 ) return (100);
         }
            
        }

     }
   return (0);
}
int IsExitMagicNumberCurrentOrder(int majic=0,string comment=""){
  int    cmd=0,i; 
  int total=OrdersTotal(); 
  //printf("total=%d %s  %s",total,comment,OrderSymbol());
 for( i=0; i<total; i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         cmd=OrderMagicNumber();
         if(StringCompare(comment,"")==0){
            if(cmd==majic)    return (100);
            }
         else{

            if(cmd==majic && StringCompare(comment,OrderSymbol())==0 ) return (100);
         }
            
        }

     }
   return (0);
}
int CloseOrderByMagic(int majic=0,string comment=""){
  int    cmd=0,i; 
  int total=OrdersTotal(); 
 for( i=0; i<total; i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         cmd=OrderMagicNumber();
         if(StringCompare(comment,"")==0){
         
            if(cmd==majic)     OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,0);
         
            }
         else{
           
            if(cmd==majic && StringCompare(comment,OrderComment())==0 ){
             // printf(" %d %s  %s",majic,comment,OrderComment());
             OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,0);
            
            }
         }
            
        }

     }
   return (0);
}
double JudgeMagicNumberProfit(int majic=0,string comment=""){
  int    cmd=0,i; 
  int total=OrdersTotal(); 
 for( i=0; i<total; i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         cmd=OrderMagicNumber();
         // if(cmd==majic && StringCompare(comment,OrderComment())==0 ) printf("****%s***%s******=%f",comment,OrderComment(),OrderProfit());

            if(cmd==majic && StringCompare(comment,OrderComment())==0 ) return OrderProfit();
       
        }

     }
   return (0);
}
int JudgeCommentExit(string majic=""){
  int    i; 
  int total=OrdersTotal(); 
 for( i=0; i<total; i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         string cmd=OrderComment();
         //printf("OrderMagicNumber=%d",cmd);
         if(cmd==majic)    return (100);
        }

     }
   return (0);
}
double JudgeCommentProfit(string majic=""){
  int  i; 
  int total=OrdersTotal(); 
 for( i=0; i<total; i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         string cmd=OrderComment();
         //printf("OrderMagicNumber=%d",cmd);
         if(cmd==majic) {

            return OrderProfit();
        
         }
        }

     }
   return (0);
}






//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int dig=1;


int TodayOrderCount=0;
double AccountLoss(int day=1){//1时只算当天的
   double LossCount=0;
   int  total=OrdersHistoryTotal();
   //printf(" total%d",total);
   TodayOrderCount=0;
   for(int i=0; i<total; i++)
   {
        if(OrderSelect(total-i,SELECT_BY_POS,MODE_HISTORY))
        {             
               // printf(" %d",TimeDay(TimeCurrent()- OrderCloseTime()));
            if(  TimeDay(TimeCurrent())- TimeDay(OrderCloseTime()) < day  && TimeDay(TimeCurrent())- TimeDay(OrderCloseTime()) >= 0 ){
         
               LossCount+=OrderProfit();
               TodayOrderCount++;
               //datetime     ctm=OrderCloseTime(); 
              // if(ctm>0) Print("Close time for the order  ", ctm); 
          
            }
            else
            break;
      
         }
     } 
     for(int i=0;i<OrdersTotal();i++)
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()==OP_BUY || OrderType()==OP_SELL)
       {
            LossCount+=OrderProfit();        
       }
     }     
     
     
    return LossCount;      
}

static double zhanghuzijin=1;
double HisLoss;
extern double MaxTodayLoss=0.4;
bool ManageEquity(){
   bool ret=true;
   if(AccountEquity()>zhanghuzijin)
   {
      zhanghuzijin=AccountEquity();
   }//记录账户净值最大值；
   HisLoss=AccountLoss(1);
   if((HisLoss/zhanghuzijin) < (0-MaxTodayLoss) )//如果账户净值小于最大值的x%，则全部清仓；
   {
      Alert(ChartSymbol()+"当亏超限");
      ret=false;
      //zhanghuzijin=1;//还原账户净值最大值记录变量；
   }
   return ret;
}


int day_of_year(datetime date1=D'2008.03.01',datetime date2=D'2009.03.01' ){
  
   MqlDateTime str1,str2; 
   TimeToStruct(date1,str1); 
   TimeToStruct(date2,str2); 
   if(str2.day_of_year >str1.day_of_year)
   return(str2.day_of_year-str1.day_of_year);
   else
   return 10000;
}
int FobidTradeByDay(int mn=0){
      int count=OrdersHistoryTotal();
          //检查上一个单子亏顺情况， 如果亏顺将等到x days后再开单 
        if(count>1){
        for(int i=1;i<2;i++){
        
           if(OrderSelect(count-i,SELECT_BY_POS,MODE_HISTORY))
           {
                int LossMagic=OrderMagicNumber();
                 if(LossMagic== mn  && StringFind(OrderComment(),ChartSymbol())==0  )//("上一个单子Loss                 
                 {

                  return day_of_year(OrderCloseTime(),TimeCurrent())  ;
                         
                 }
            
            }// if(OrderSelect(OrdersHistoryTotal()-1,SELECT_BY_POS,MODE_HISTORY))
           }        
        }
        
        

    return 1000000;      
}
int FobidTradeByHour(int day=1,int mn=0){
      int count=OrdersHistoryTotal();
          //检查上一个单子亏顺情况， 如果亏顺将等到x days后再开单 
        if(count>5){
        for(int i=1;i<6;i++){
        
           if(OrderSelect(count-i,SELECT_BY_POS,MODE_HISTORY))
           {
                int LossMagic=OrderMagicNumber();
               // printf("%d, LossMagic=%d mn=%d, OrderComment()=%s %s ,re=%d",count-i,LossMagic,mn,OrderComment(),ChartSymbol(),StringFind(OrderComment(),ChartSymbol()));
                 //if(OrderProfit()<0 && LossMagic== mn )//("上一个单子Loss
                 if(LossMagic== mn  && StringFind(OrderComment(),ChartSymbol())==0  )//("上一个单子Loss                 
                 {
                  // printf("  %d",TimeDay(TimeCurrent()- OrderCloseTime() ));   
                  if(TimeDay(TimeCurrent()) == TimeDay( OrderCloseTime())   ){
                    if( TimeHour(TimeCurrent())- TimeHour(OrderCloseTime()) <=day) return (0);//x天后交易                 
                  }

                         
                 }
            
            }// if(OrderSelect(OrdersHistoryTotal()-1,SELECT_BY_POS,MODE_HISTORY))
           }        
        }
        
        

    return 1;      
}


int CloseOrderByMagicNumber(int majic=100,string comment=""){
  int    cmd,i,error;
  bool result; 
  double price;
  int total=OrdersTotal(); 
 for( i=0; i<total; i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         cmd=OrderMagicNumber();
         bool bCanClose=false;
         double profit=OrderProfit();

         if(cmd==majic &&  StringCompare(comment,OrderComment())==0  ) 
           {             
                while(true)
                  {
     
                   if(OrderType()==OP_BUY) price=Bid;
                   else            price=Ask;
                   result=OrderClose(OrderTicket(),OrderLots(),price,3,CLR_NONE);
                   if(result!=TRUE) { error=GetLastError(); Alert("Order Close LastError = ",error); }
                   else {error=0;break;}
                   if(error==135) RefreshRates();
                   //else break;
                  }             
            }
        }

     }//for
   return (cmd);
} 