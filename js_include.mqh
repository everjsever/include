
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


extern string BuyStop_TrendName = "buy";
extern int    BuyStop_TakeProfit = 80;
extern int    BuyStop_StopLoss = 30;
extern double BuyStop_Lot = 0.01;
int    BuyStop_StepUpper = 4;
int    BuyStop_StepLower =4;

extern string SellStop_TrendName = "sell";
extern int    SellStop_TakeProfit = 80;
extern int    SellStop_StopLoss = 30;
extern double SellStop_Lot = 0.01;
int    SellStop_StepUpper = 4;
int    SellStop_StepLower = 4;
extern int    TuPo_StopLoss=17;//突破交易止损
extern int    TuPo_TakeProfit=15;//突破交易止盈
string BuyStop_TrendName_up= "up";
string SellStop_TrendName_down = "down";

//------
int MagicBuyStop = 1101;
int MagicSellStop = 1102;
int MagicBuyStopUp = 1103;
int MagicSellStopDown = 1104;
int glbOrderType;
int glbOrderTicket;

int MiddleUpStatus=-1; 
int MiddleDownStatus=-1; 
void MiddleUpPriceStatus(){

   switch(MiddleUpStatus){
   case 1://处于下方
      if(Bid>MiddleHLinePriceHigh){
         MiddleUpStatus=2;//突破
         Alert("向上突破："+ChartSymbol());
      }   
   break;
   
   case 2://回到区间
      if(Bid<=MiddleHLinePriceHigh){
         MiddleUpStatus=3;
      }   
   break;
   
   case 3://回撤
      if(Bid>MiddleHLinePriceHigh){
         MiddleUpStatus=2;
      }   
   break;
   
   default:
      if(Bid<=MiddleHLinePriceHigh){
         MiddleUpStatus=1;
      }
      if(Bid>MiddleHLinePriceHigh){
         MiddleUpStatus=2;
      }
   break;
   
   }
   

}

void MiddleDownPriceStatus(){

   switch(MiddleDownStatus){
   case 1://处于上方
      if(Ask<=MiddleLinePrice){
         MiddleDownStatus=2;
         Alert("向下突破："+ChartSymbol());         
      }   
   break;
   
   case 2://下突破
      if(Ask>MiddleLinePrice){
         MiddleDownStatus=3;
      }   
   break;
   
   case 3://回撤
      if(Ask<=MiddleLinePrice){
         MiddleDownStatus=2;
      }   
   break;
   
   default:
      if(Ask<=MiddleLinePrice){
         MiddleDownStatus=2;
      }
      if(Ask>MiddleLinePrice){
         MiddleDownStatus=1;
      }
   break;
   
   }
}
//+------------------------------------------------------------------+
int UpStatus=-1; 
int DownStatus=-1; 
void UpPriceStatus(){

   switch(UpStatus){
   case 1://处于下方
      if(Bid>UpLinePrice){
         UpStatus=2;//突破
      }   
   break;
   
   case 2://回到区间
      
      if(Bid<=UpLinePrice){
         UpStatus=3;
      }   
   break;
   
   case 3://回撤
      if(Bid>UpLinePrice){
         UpStatus=2;
      }   
   break;
   
   default:
      if(Bid<=UpLinePrice){
         UpStatus=1;
      }
      if(Bid>UpLinePrice){
         UpStatus=2;
      }
   break;
   
   }
   

}

void DownPriceStatus(){

   switch(DownStatus){
   case 1://处于上方
      if(Ask<=DownLinePrice){
         DownStatus=2;
      }   
   break;
   
   case 2://回到区间
      if(Ask>DownLinePrice){
         DownStatus=3;
      }   
   break;
   
   case 3://回撤
      if(Ask<=DownLinePrice){
         DownStatus=2;
      }   
   break;
   
   default:
      if(Ask<=DownLinePrice){
         DownStatus=2;
      }
      if(Ask>DownLinePrice){
         DownStatus=1;
      }
   break;
   
   }
}

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
int OpenLong(double volume=0.01,int mymagic=0,double stop=0,double limit=0,string symbol="")
// the function opens a long position with lot size=volume 
{

  int slippage=5;
  string comment=symbol;//+IntegerToString(mymagic);
  color arrow_color=Red;

  double ask=SymbolInfoDouble(symbol,SYMBOL_ASK); 

  int ticket=OrderSend(symbol,OP_BUY,volume,ask,slippage,stop,limit,comment,mymagic);
  if(ticket>0)
  {
  return ticket;
  }
  else 
  {
    Print("Error opening Buy order : ",GetLastError()); 
    return(-1);
  }
}
int OpenShort(double volume=0.01,int mymagic=0,double stop=0,double limit=0,string symbol="")
{

  int slippage=5;
  string comment=symbol;//+IntegerToString(mymagic);
  color arrow_color=Red;
 
  double bid=SymbolInfoDouble(symbol,SYMBOL_BID); 
  int ticket=OrderSend(symbol,OP_SELL,volume,bid,slippage,stop,limit,comment,mymagic);
  if(ticket>0)
  {

  }
  else 
  {
    Print("Error opening Sell order : ",GetLastError()); 
    return(-1);
  }
  return ticket;
}
int JudgeMagicNumberExit(int majic=0,string comment=""){
  int    cmd=0,i; 
  int total=OrdersTotal(); 
 for( i=0; i<total; i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         cmd=OrderMagicNumber();
         if(StringCompare(comment,"")==0){
            if(cmd==majic)    return (100);
            }
         else{
            // printf(" %s  %s",comment,OrderComment());
            if(cmd==majic && StringCompare(comment,OrderComment())==0 ) return (100);
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
         if(StringCompare(comment,"")==0)
            if(cmd==majic)    return OrderProfit();
         else{
            if(cmd==majic && StringCompare(comment,OrderComment())==0 ) return OrderProfit();
         }
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

int FobidTrade(int day=1,int mn=0){
      int count=OrdersHistoryTotal();
          //检查上一个单子亏顺情况， 如果亏顺将等到x days后再开单 
        if(count>0){
        for(int i=1;i<count+1;i++){
        
           if(OrderSelect(count-i,SELECT_BY_POS,MODE_HISTORY))
           {
                int LossMagic=OrderMagicNumber();
   
                 //if(OrderProfit()<0 && LossMagic== mn )//("上一个单子Loss
                 if(LossMagic== mn )//("上一个单子Loss                 
                 {
                  // printf("  %d",TimeDay(TimeCurrent()- OrderCloseTime() ));   
                  //if( TimeDay(TimeCurrent()- OrderCloseTime())<=day) return (0);//x天后交易
                  if( TimeDay(TimeCurrent()- OrderOpenTime())<=day) return (0);//x天后交易
                         
                 }
            
            }// if(OrderSelect(OrdersHistoryTotal()-1,SELECT_BY_POS,MODE_HISTORY))
           }        
        }
        
        

    return 1;      
}

void CloseHalfTrade(){
  for(int i=0;i<OrdersTotal();i++)
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol())
        {
         if(OrderType()==OP_BUY){
            if(Bid-OrderOpenPrice()>  NormalizeDouble(40*Point*PointUnit,Digits))
            OrderClose(OrderTicket(),OrderLots()/2,OrderClosePrice(),3,0);
         }
         if(OrderType()==OP_SELL) 
         {
            if(OrderOpenPrice()-Ask>  NormalizeDouble(40*Point*PointUnit,Digits))
            OrderClose(OrderTicket(),OrderLots()/2,OrderClosePrice(),3,0);
         }
        }
     }
}

void PrintAllOrderByMagic(int start=200,int step=20,int count=30){
 int error;
 int total=OrdersHistoryTotal();
 double profit[1000];
 for( int i=0; i<total; i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
        {
         int mn=OrderMagicNumber();
         for(int j=1;j<=count;j++){
         if(mn == start+j)
         profit[start+j] += OrderProfit()+OrderCommission()+OrderSwap();       
         }

         
         
        }
      else {
       error++;
       Print( "Error when order select ", GetLastError()); break; }
     
     
    }
     
     for(int k=1;k<=count;k++){
         Print("Er ",error,"  start=",start," step=",step," count=",count," k =" ,k," profit[k]=",profit[start+k]);      
      }   
    
}

void PrintAllOrder(int magic=0){
   bool   result;
   double t1=0,s1=0,t2=0,s2=0,t3=0,s3=0,t4=0,s5=0,s6=0,s7=0,t5=0,s8=0,s9=0;
   int    cmd,error=0,i,cnt1=0,cnt2,cnt3,cnt4,cnt6,cnt7,cnt8,cnt9,cnt10,cnt11; 
   cnt1=0; cnt2=0;cnt3=0;cnt4=0;cnt6=0;cnt7=0;cnt8=0;cnt9=0;cnt10=0;cnt11=0;
   int total=OrdersHistoryTotal();
 for( i=0; i<total; i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
        {
         //---- print selected rder
         //OrderPrint();
         switch(OrderMagicNumber()){
         
         case 10:
            s1=s1+OrderProfit()+OrderCommission()+OrderSwap();
         break;
         
         case 11:
            t1=t1+OrderProfit()+OrderCommission()+OrderSwap();
            
         break;
         
         case 12:
            t2=t2+OrderProfit()+OrderCommission()+OrderSwap();

         break;
         
         case 1:
             t3=t3+OrderProfit()+OrderCommission()+OrderSwap();
             cnt4++;
         break; 
          case 4:   
             s7=s7+OrderProfit()+OrderCommission()+OrderSwap();      
          break;     
          case 3:
             s2=s2+OrderProfit()+OrderCommission()+OrderSwap();
             cnt6++;
         break;   
         case 2:
             s3=s3+OrderProfit()+OrderCommission()+OrderSwap();
         break;  

                 
         
         case 4002:
             s6=s6+OrderProfit()+OrderCommission()+OrderSwap();
             break;
         case 4003:
         break;
         case 13:         
             s5=s5+OrderProfit()+OrderCommission()+OrderSwap(); 
         break;
         case 4004:
             t4=t4+OrderProfit()+OrderCommission()+OrderSwap();
             cnt2++;
         break;  
         case 4005:
             t5=t5+OrderProfit()+OrderCommission()+OrderSwap();  
             cnt3++;   
         break;  
         case 4006:
             s8=s8+OrderProfit()+OrderCommission()+OrderSwap();
         break;  
         case 4007:
             s9=s9+OrderProfit()+OrderCommission()+OrderSwap();
             cnt1++;       
         break;  
         }
         
        }
      else {
       error++;
       Print( "Error when order select ", GetLastError()); break; }
     
     
    }
    Print("Er ",error,"  12=",t2," 10=",s1," 11=",t1," 3=",s2," 1=",t3 ," 2=",s3," 4 =",s7, " Total:",t1+t2+t3+s1+s2+s3+s5+s6+s7+t4+t5+s8+s9);
    Print(" 13=",s5," 4002=",s6," 4004=",t4,"=",cnt2," 4005=",t5 ,"=",cnt3," 4006=",s8," 4007=",s9," 07=",cnt1, " Total:",t1+t2+t3+s1+s2+s3+s5+s6+s7+t4+t5+s8+s9);
   
}
 bool bAccountCanTrade=false;
 bool bAccount(string name="Song Jin"){
  if( AccountName()==name)
  return (true);
  else return (false);
  
 } 
 void XTradeTick()//图形化交易
  {
   double vH, vL, vM, sl, tp;
   double uH, uL, uM;  
   if(ObjectFind(BuyStop_TrendName) == 0)
     {
       SetObject("High" + BuyStop_TrendName,
                 ObjectGet(BuyStop_TrendName, OBJPROP_TIME1),
                 ObjectGet(BuyStop_TrendName, OBJPROP_PRICE1) + BuyStop_StepUpper*Point*PointUnit,
                 ObjectGet(BuyStop_TrendName, OBJPROP_TIME2),
                 ObjectGet(BuyStop_TrendName, OBJPROP_PRICE2) + BuyStop_StepUpper*Point*PointUnit,
                 ObjectGet(BuyStop_TrendName, OBJPROP_COLOR));
       SetObject("Low" + BuyStop_TrendName,
                 ObjectGet(BuyStop_TrendName, OBJPROP_TIME1),
                 ObjectGet(BuyStop_TrendName, OBJPROP_PRICE1) - BuyStop_StepLower*Point*PointUnit,
                 ObjectGet(BuyStop_TrendName, OBJPROP_TIME2),
                 ObjectGet(BuyStop_TrendName, OBJPROP_PRICE2) - BuyStop_StepLower*Point*PointUnit,
                 ObjectGet(BuyStop_TrendName, OBJPROP_COLOR));
       vH = NormalizeDouble(ObjectGetValueByShift("High"+BuyStop_TrendName,0),Digits);
       vM = NormalizeDouble(ObjectGetValueByShift(BuyStop_TrendName,0),Digits);
       vL = NormalizeDouble(ObjectGetValueByShift("Low"+BuyStop_TrendName,0),Digits);
       sl = NormalizeDouble(vH - BuyStop_StopLoss*Point*PointUnit,Digits);
       tp = NormalizeDouble(vH + BuyStop_TakeProfit*Point*PointUnit,Digits);
       if(Ask <= vM && Ask >= vL && OrderFind(MagicBuyStop) == false && vM >0.001 )
           if(OrderSend(Symbol(), OP_BUYSTOP, BuyStop_Lot, vH, 3, sl, tp,
              "", MagicBuyStop, 0, Green) < 0)
               Print("Err (", GetLastError(), ") Open BuyStop Price= ", vH, " SL= ", 
                     sl," TP= ", tp);
       if(Ask <= vM && Ask >= vL && OrderFind(MagicBuyStop) == true && 
          glbOrderType == OP_BUYSTOP)
         {
           OrderSelect(glbOrderTicket, SELECT_BY_TICKET, MODE_TRADES);
           if(vH != OrderOpenPrice())
               if(OrderModify(glbOrderTicket, vH, sl, tp, 0, Green) == false)
                   Print("Err (", GetLastError(), ") Modify BuyStop Price= ", vH, 
                         " SL= ", sl, " TP= ", tp);
         }

       if(Ask >= vM - NormalizeDouble(5*Point*PointUnit,Digits) && Ask <= vM && OrderFind(1200) == false  && bTuXingHuaTuPo ){
             sl = NormalizeDouble(Bid + TuPo_StopLoss*Point*PointUnit,Digits);
             tp = NormalizeDouble(Bid - TuPo_TakeProfit*Point*PointUnit,Digits); 
             OpenShort(SellStop_Lot,1200,sl,tp,ChartSymbol());         
        
         }           
         
     }

   if(ObjectFind(SellStop_TrendName) == 0)
     {
       SetObject("High" + SellStop_TrendName,
                 ObjectGet(SellStop_TrendName, OBJPROP_TIME1),
                 ObjectGet(SellStop_TrendName, OBJPROP_PRICE1) + SellStop_StepUpper*Point*PointUnit,
                 ObjectGet(SellStop_TrendName, OBJPROP_TIME2),
                 ObjectGet(SellStop_TrendName, OBJPROP_PRICE2) + SellStop_StepUpper*Point*PointUnit,
                 ObjectGet(SellStop_TrendName, OBJPROP_COLOR));
       SetObject("Low" + SellStop_TrendName, ObjectGet(SellStop_TrendName, OBJPROP_TIME1),
                 ObjectGet(SellStop_TrendName, OBJPROP_PRICE1) - SellStop_StepLower*Point*PointUnit,
                 ObjectGet(SellStop_TrendName, OBJPROP_TIME2),
                 ObjectGet(SellStop_TrendName, OBJPROP_PRICE2) - SellStop_StepLower*Point*PointUnit,
                 ObjectGet(SellStop_TrendName, OBJPROP_COLOR));
       vH = NormalizeDouble(ObjectGetValueByShift("High" + SellStop_TrendName, 0), Digits);
       vM = NormalizeDouble(ObjectGetValueByShift(SellStop_TrendName, 0), Digits);
       vL = NormalizeDouble(ObjectGetValueByShift("Low" +SellStop_TrendName, 0), Digits);
       sl = NormalizeDouble(vL + SellStop_StopLoss*Point*PointUnit,Digits);
       tp = NormalizeDouble(vL - SellStop_TakeProfit*Point*PointUnit,Digits);
       if(Bid >= vM && Bid <= vH && OrderFind(MagicSellStop ) == false && vM >0.001  )
           if(OrderSend(Symbol(), OP_SELLSTOP, SellStop_Lot, vL, 3, sl, tp, "", 
              MagicSellStop, 0, Red) < 0)
               Print("Err (", GetLastError(), ") Open SellStop Price= ", vL, " SL= ", sl, 
                     " TP= ", tp," vM=",vM);
       if(Bid >= vM && Bid <= vH && OrderFind(MagicSellStop) == true && 
          glbOrderType == OP_SELLSTOP)
         {
           OrderSelect(glbOrderTicket, SELECT_BY_TICKET, MODE_TRADES);
           if(vL != OrderOpenPrice())
               if(OrderModify(glbOrderTicket, vL, sl, tp, 0, Red) == false)
                   Print("Err (", GetLastError(), ") Modify Sell Price= ", vL, " SL= ", sl, 
                         " TP= ", tp);
         }
       if(Ask >= vM && Ask <= vM + NormalizeDouble(5*Point*PointUnit,Digits) && OrderFind(1201) == false && bTuXingHuaTuPo ){
         sl = NormalizeDouble(Ask - TuPo_StopLoss*Point*PointUnit,Digits);
         tp = NormalizeDouble(Ask + TuPo_TakeProfit*Point*PointUnit,Digits); 
         OpenLong(BuyStop_Lot,1201,sl,tp,ChartSymbol());  
       
       }              
       
     }
/*     
   //////////////////////////up and down/////////////////////////////     
     if(ObjectFind(BuyStop_TrendName_up) == 0)
     {
       SetObject("High" + BuyStop_TrendName_up,
                 ObjectGet(BuyStop_TrendName_up, OBJPROP_TIME1),
                 ObjectGet(BuyStop_TrendName_up, OBJPROP_PRICE1) + BuyStop_StepUpper*Point*PointUnit,
                 ObjectGet(BuyStop_TrendName_up, OBJPROP_TIME2),
                 ObjectGet(BuyStop_TrendName_up, OBJPROP_PRICE2) + BuyStop_StepUpper*Point*PointUnit,
                 ObjectGet(BuyStop_TrendName_up, OBJPROP_COLOR));
       SetObject("Low" + BuyStop_TrendName_up,
                 ObjectGet(BuyStop_TrendName_up, OBJPROP_TIME1),
                 ObjectGet(BuyStop_TrendName_up, OBJPROP_PRICE1) - BuyStop_StepLower*Point*PointUnit,
                 ObjectGet(BuyStop_TrendName_up, OBJPROP_TIME2),
                 ObjectGet(BuyStop_TrendName_up, OBJPROP_PRICE2) - BuyStop_StepLower*Point*PointUnit,
                 ObjectGet(BuyStop_TrendName_up, OBJPROP_COLOR));
       vH = NormalizeDouble(ObjectGetValueByShift("High"+BuyStop_TrendName_up,0),Digits);
       vM = NormalizeDouble(ObjectGetValueByShift(BuyStop_TrendName_up,0),Digits);
       vL = NormalizeDouble(ObjectGetValueByShift("Low"+BuyStop_TrendName_up,0),Digits);
       sl = NormalizeDouble(vH - BuyStop_StopLoss*Point*PointUnit,Digits);
       tp = NormalizeDouble(vH + BuyStop_TakeProfit*Point*PointUnit,Digits);
       if(Ask <= vM && Ask >= vL && OrderFind(MagicBuyStopUp) == false && vM >0.001 )
           if(OrderSend(Symbol(), OP_BUYSTOP, BuyStop_Lot, vH, 3, sl, tp,
              "", MagicBuyStopUp, 0, Green) < 0)
               Print("Err (", GetLastError(), ") Open BuyStop Price= ", vH, " SL= ", 
                     sl," TP= ", tp);
       if(Ask <= vM && Ask >= vL && OrderFind(MagicBuyStopUp) == true && 
          glbOrderType == OP_BUYSTOP)
         {
           OrderSelect(glbOrderTicket, SELECT_BY_TICKET, MODE_TRADES);
           if(vH != OrderOpenPrice())
               if(OrderModify(glbOrderTicket, vH, sl, tp, 0, Green) == false)
                   Print("Err (", GetLastError(), ") Modify BuyStop Price= ", vH, 
                         " SL= ", sl, " TP= ", tp);
         }
     }
 
   if(ObjectFind(SellStop_TrendName_down) == 0)
     {
       SetObject("High" + SellStop_TrendName_down,
                 ObjectGet(SellStop_TrendName_down, OBJPROP_TIME1),
                 ObjectGet(SellStop_TrendName_down, OBJPROP_PRICE1) + SellStop_StepUpper*Point*PointUnit,
                 ObjectGet(SellStop_TrendName_down, OBJPROP_TIME2),
                 ObjectGet(SellStop_TrendName_down, OBJPROP_PRICE2) + SellStop_StepUpper*Point*PointUnit,
                 ObjectGet(SellStop_TrendName_down, OBJPROP_COLOR));
       SetObject("Low" + SellStop_TrendName_down, ObjectGet(SellStop_TrendName_down, OBJPROP_TIME1),
                 ObjectGet(SellStop_TrendName_down, OBJPROP_PRICE1) - SellStop_StepLower*Point*PointUnit,
                 ObjectGet(SellStop_TrendName_down, OBJPROP_TIME2),
                 ObjectGet(SellStop_TrendName_down, OBJPROP_PRICE2) - SellStop_StepLower*Point*PointUnit,
                 ObjectGet(SellStop_TrendName_down, OBJPROP_COLOR));
       vH = NormalizeDouble(ObjectGetValueByShift("High" + SellStop_TrendName_down, 0), Digits);
       vM = NormalizeDouble(ObjectGetValueByShift(SellStop_TrendName_down, 0), Digits);
       vL = NormalizeDouble(ObjectGetValueByShift("Low" +SellStop_TrendName_down, 0), Digits);
       sl = NormalizeDouble(vL + SellStop_StopLoss*Point*PointUnit,Digits);
       tp = NormalizeDouble(vL - SellStop_TakeProfit*Point*PointUnit,Digits);
       if(Bid >= vM && Bid <= vH && OrderFind(MagicSellStopDown) == false && vM >0.001 )
           if(OrderSend(Symbol(), OP_SELLSTOP, SellStop_Lot, vL, 3, sl, tp, "", 
              MagicSellStopDown, 0, Red) < 0)
               Print("Err (", GetLastError(), ") Open SellStop Price= ", vL, " SL= ", sl, 
                     " TP= ", tp);
       if(Bid >= vM && Bid <= vH && OrderFind(MagicSellStopDown) == true && 
          glbOrderType == OP_SELLSTOP)
         {
           OrderSelect(glbOrderTicket, SELECT_BY_TICKET, MODE_TRADES);
           if(vL != OrderOpenPrice())
               if(OrderModify(glbOrderTicket, vL, sl, tp, 0, Red) == false)
                   Print("Err (", GetLastError(), ") Modify Sell Price= ", vL, " SL= ", sl, 
                         " TP= ", tp);
         }

         
     } */ 
   return;
  }

 
 void XTradeTickRealTime()//图形化实时交易
  {
   double vH, vL, vM, sl, tp;
   double high,low;
   high=High[iHighest(NULL,0,MODE_HIGH,5,0)];
   low=Low[iLowest(NULL,0,MODE_LOW,5,0)] ;
   if(ObjectFind(BuyStop_TrendName) == 0)
     {
       SetObject("High" + BuyStop_TrendName,
                 ObjectGet(BuyStop_TrendName, OBJPROP_TIME1),
                 ObjectGet(BuyStop_TrendName, OBJPROP_PRICE1) + BuyStop_StepUpper*Point*PointUnit,
                 ObjectGet(BuyStop_TrendName, OBJPROP_TIME2),
                 ObjectGet(BuyStop_TrendName, OBJPROP_PRICE2) + BuyStop_StepUpper*Point*PointUnit,
                 ObjectGet(BuyStop_TrendName, OBJPROP_COLOR));
       SetObject("Low" + BuyStop_TrendName,
                 ObjectGet(BuyStop_TrendName, OBJPROP_TIME1),
                 ObjectGet(BuyStop_TrendName, OBJPROP_PRICE1) - BuyStop_StepLower*Point*PointUnit,
                 ObjectGet(BuyStop_TrendName, OBJPROP_TIME2),
                 ObjectGet(BuyStop_TrendName, OBJPROP_PRICE2) - BuyStop_StepLower*Point*PointUnit,
                 ObjectGet(BuyStop_TrendName, OBJPROP_COLOR));
       vH = NormalizeDouble(ObjectGetValueByShift("High"+BuyStop_TrendName,0),Digits);
       vM = NormalizeDouble(ObjectGetValueByShift(BuyStop_TrendName,0),Digits);
       vL = NormalizeDouble(ObjectGetValueByShift("Low"+BuyStop_TrendName,0),Digits);
       sl = NormalizeDouble(vH - BuyStop_StopLoss*Point*PointUnit,Digits);
       tp = NormalizeDouble(vH + BuyStop_TakeProfit*Point*PointUnit,Digits);
       if(low < vM && Ask >= vH && OrderFind(MagicBuyStop) == false)
         OpenLong(BuyStop_Lot,MagicBuyStop,sl,tp,ChartSymbol());                        
     }

   if(ObjectFind(SellStop_TrendName) == 0)
     {
       SetObject("High" + SellStop_TrendName,
                 ObjectGet(SellStop_TrendName, OBJPROP_TIME1),
                 ObjectGet(SellStop_TrendName, OBJPROP_PRICE1) + SellStop_StepUpper*Point*PointUnit,
                 ObjectGet(SellStop_TrendName, OBJPROP_TIME2),
                 ObjectGet(SellStop_TrendName, OBJPROP_PRICE2) + SellStop_StepUpper*Point*PointUnit,
                 ObjectGet(SellStop_TrendName, OBJPROP_COLOR));
       SetObject("Low" + SellStop_TrendName, ObjectGet(SellStop_TrendName, OBJPROP_TIME1),
                 ObjectGet(SellStop_TrendName, OBJPROP_PRICE1) - SellStop_StepLower*Point*PointUnit,
                 ObjectGet(SellStop_TrendName, OBJPROP_TIME2),
                 ObjectGet(SellStop_TrendName, OBJPROP_PRICE2) - SellStop_StepLower*Point*PointUnit,
                 ObjectGet(SellStop_TrendName, OBJPROP_COLOR));
       vH = NormalizeDouble(ObjectGetValueByShift("High" + SellStop_TrendName, 0), Digits);
       vM = NormalizeDouble(ObjectGetValueByShift(SellStop_TrendName, 0), Digits);
       vL = NormalizeDouble(ObjectGetValueByShift("Low" +SellStop_TrendName, 0), Digits);
       sl = vL + NormalizeDouble(SellStop_StopLoss*Point*PointUnit,Digits);
       tp = vL - NormalizeDouble(SellStop_TakeProfit*Point*PointUnit,Digits);
       if(Bid < vL && vM <= high && OrderFind(MagicSellStop) == false)
           OpenShort(SellStop_Lot,MagicSellStop,sl,tp,ChartSymbol()); 

     }
   return;
  }


 //+------------------------------------------------------------------+
void SetObject(string name,datetime T1,double P1,datetime T2,double P2,color clr)
  {
   if(ObjectFind(name) == -1)
     {
       ObjectCreate(name, OBJ_TREND, 0, T1, P1, T2, P2);
       ObjectSet(name, OBJPROP_COLOR, clr);
       ObjectSet(name, OBJPROP_STYLE, STYLE_DOT);
     }
   else
     {
       ObjectSet(name, OBJPROP_TIME1, T1);
       ObjectSet(name, OBJPROP_PRICE1, P1);
       ObjectSet(name, OBJPROP_TIME2, T2);
       ObjectSet(name, OBJPROP_PRICE2, P2);
       ObjectSet(name, OBJPROP_COLOR, clr);
       ObjectSet(name, OBJPROP_STYLE, STYLE_DOT);
     } 
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderFind(int Magic)
  {
   glbOrderType = -1;
   glbOrderTicket = -1;
   int total = OrdersTotal();
   bool res = false;
   for(int cnt = 0 ; cnt < total ; cnt++)
     {
       OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
       if(OrderMagicNumber() == Magic && OrderSymbol() == Symbol())
         {
           glbOrderType = OrderType();
           glbOrderTicket = OrderTicket();
           res = true;
         }
     }
   return(res);
  }
//+------------------------------------------------------------------+
//|                                                                  |


//+------------------------------------------------------------------+ 
//| Create the horizontal line                                       | 
//+------------------------------------------------------------------+ 
bool HLineCreate(const long            chart_ID=0,        // chart's ID 
                 const string          name="HLine",      // line name 
                 const int             sub_window=0,      // subwindow index 
                 double                price=0,           // line price 
                 const color           clr=clrRed,        // line color 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                 const int             width=1,           // line width 
                 const bool            back=false,        // in the background 
                 const bool            selection=true,    // highlight to move 
                 const bool            hidden=true,       // hidden in the object list 
                 const long            z_order=0)         // priority for mouse click 
  { 
//--- if the price is not set, set it at the current Bid price level 
   if(!price) 
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID); 
//--- reset the error value 
   ResetLastError(); 
//--- create a horizontal line 
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price)) 
     { 
      Print(__FUNCTION__, 
            ": failed to create a horizontal line! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- set line color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- set line display style 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style); 
//--- set line width 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width); 
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- enable (true) or disable (false) the mode of moving the line by mouse 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
//--- successful execution 
   return(true); 
  } 

//+------------------------------------------------------------------+ 
//| Delete a horizontal line                                         | 
//+------------------------------------------------------------------+ 
bool HLineDelete(const long   chart_ID=0,   // chart's ID 
                 const string name="HLine") // line name 
  { 
//--- reset the error value 
   ResetLastError(); 
//--- delete a horizontal line 
   if(!ObjectDelete(chart_ID,name)) 
     { 
      Print(__FUNCTION__, 
            ": failed to delete a horizontal line! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- successful execution 
   return(true); 
  } 
//+------------------------------------------------------------------+ 
//| Script program start function                                    | 
//+------------------------------------------------------------------+ 
void HlineStart(double price=0.0,const string          name="HLine" ,const color           clr=clrRed  ) 
  { 


//--- create a horizontal line 
   if(!HLineCreate(0,name,0,price,clr,InpStyle,InpWidth,InpBack, 
      InpSelection,InpHidden,InpZOrder)) 
     { 
      return; 
     } 
//--- redraw the chart and wait for 1 second 
   ChartRedraw(); 

//--- delete from the chart 

//   ChartRedraw(); 
//--- 1 second of delay 
  
//--- 
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+   


string    Ma1="First Ma settings";
 int       Ma1Period=5;//5
 int       Ma1Shift=0;
 int       Ma1Method=0;

string    Ma2="Second Ma settings";
 int       Ma2Period=15;//15
 int       Ma2Shift=0;
 int       Ma2Method=0;


string    Ma3="Third Ma settings";
 int       Ma3Period=80;//
 int       Ma3Shift=0;
 int       Ma3Method=0;


// Ma strategy one
double B_MA1_0=0;
double B_MA1_1=0;
double B_MA1_2=0;

// Ma constant
double B_MA2_0=0;
double B_MA2_1=0;
double B_MA2_2=0;
double B_MA2_x=0;

// Ma constant
double B_MA3_0=0;
double B_MA3_1=0;
double B_MA3_2=0;
double B_MA3_x=0;

// Ma strategy one
double MA1_0=0;
double MA1_1=0;
double MA1_2=0;

// Ma constant
double MA2_0=0;
double MA2_1=0;
double MA2_2=0;
double MA2_x=0;
// Ma constant
double MA3_0=0;
double MA3_1=0;
double MA3_2=0;
double MA3_x=0;



int TrendStatus=1;

int JudgeBigTrend(int HighOrLow=3,int Peorid1=5,int Peorid2=15,int Peorid3=80,int InitCount=60){

for(int i=InitCount ;i>=0;i--){
// Ma strategy one
 B_MA1_0=iMA(NULL,0,Peorid1,Ma1Shift,Ma1Method,HighOrLow,1+i);
 B_MA1_1=iMA(NULL,0,Peorid1,Ma1Shift,Ma1Method,HighOrLow,2+i);
 B_MA1_2=iMA(NULL,0,Peorid1,Ma1Shift,Ma1Method,HighOrLow,3+i);
// MA1_n=iMA(NULL,0,1,Ma1Shift,Ma1Method,HighOrLow,0+i);
// Ma constant
 B_MA2_0=iMA(NULL,0,Peorid2,Ma2Shift,Ma2Method,HighOrLow,1+i);
 B_MA2_1=iMA(NULL,0,Peorid2,Ma2Shift,Ma2Method,HighOrLow,2+i);
 B_MA2_2=iMA(NULL,0,Peorid2,Ma2Shift,Ma2Method,HighOrLow,3+i);
 B_MA2_x=iMA(NULL,0,Peorid2,Ma2Shift,Ma2Method,HighOrLow,10+i);
// Ma constant
 B_MA3_0=iMA(NULL,0,Peorid3,Ma3Shift,Ma3Method,HighOrLow,1+i);
 B_MA3_1=iMA(NULL,0,Peorid3,Ma3Shift,Ma3Method,HighOrLow,2+i);
 B_MA3_2=iMA(NULL,0,Peorid3,Ma3Shift,Ma3Method,HighOrLow,3+i);
 B_MA3_x=iMA(NULL,0,Peorid3,Ma3Shift,Ma3Method,HighOrLow,10+i);
 //printf( "%d  ,%d",TrendStatus,i);
 switch(TrendStatus)
 {
   case 1000: //下降
   
   if ((B_MA1_0>B_MA2_0)&&(B_MA2_0<B_MA3_0)&&(B_MA1_1<B_MA2_1))
   {
 
        TrendStatus=1002; //短线上传穿中线，短线在中间，长线最上面
   }

   break;

 
   case 1002://下跌反转，短线上传穿中线，短线在中间，长线最上面
      if ((B_MA1_0<B_MA2_0)&&(B_MA2_0<B_MA3_0)) //标准下降通道，三线并行
       {
        TrendStatus=1000; //下跌中的反转过程，形成震荡,短线又回到最下面
       }
      
      if ((B_MA1_0>B_MA2_0)&&(B_MA1_1>B_MA2_1)&&(B_MA2_0<B_MA3_0)&&(B_MA1_0>B_MA3_0))  //短线上穿长线,长线在中间，中线在最下面
       {
        TrendStatus=1007; //短线上穿长线,长线在中间，中线在最下面
       }
                
   break;   


   case 1007://短线上穿长线,长线在中间，中线在最下面 ,此时做多

    if ((B_MA1_0>B_MA2_0)&&(B_MA1_1>B_MA2_1)&&(B_MA2_0>B_MA3_0))
   {
        TrendStatus=3000; //标准上升，三线并排
   }   
    if ((B_MA1_0>B_MA2_0)&&(B_MA1_1>B_MA2_1)&&(B_MA1_0<B_MA3_0))//短线又回到中间，开始继续下跌 ，长线最高

   {
        TrendStatus=1008; //短线又回到中间，开始继续下跌，长线最高
   } 
     
   break; 
   case 1008://短线又回到中间，开始继续下跌，长线最高
      if ((B_MA1_0<B_MA2_0)&&(B_MA1_1<B_MA2_1)&&(B_MA2_0<B_MA3_0)) 
         {
              TrendStatus=1000; //下跌中的后段过程
         }
      if ((B_MA1_0>B_MA2_0)&&(B_MA1_1>B_MA2_1)&&(B_MA2_0<B_MA3_0)) //短线上穿中线,长线在中间
       {
        TrendStatus=1007; //短线同时上穿中线和长线
       }        
            
   break;       
   case 3000://上升
    if ((B_MA1_0<B_MA2_0)&&(B_MA2_0>B_MA3_0)&&(B_MA2_1>B_MA3_1))
   {
        TrendStatus=3003; //上升中的反转过程,短线在中间，短线下穿中线
   }  
   if ((B_MA1_0<B_MA2_0)&&(B_MA1_0<B_MA2_0)&&(B_MA2_0<B_MA3_0)) 
   {
        TrendStatus=1000; //下跌
   }
   break;
 
   case 3003:
    if ((B_MA1_0>B_MA2_0)&&(B_MA1_1>B_MA2_1)&&(B_MA2_0>B_MA3_0)){
       TrendStatus=3000;//上升中的反转过程，形成震荡,第二次三线并行上升，标准上升趋势
    }
    
   if ((B_MA1_0<B_MA3_0)&&(B_MA2_0>B_MA3_0)){//短线下穿长线，长线在中间
       TrendStatus=3004;//////短线下穿长线，长线在中间
    }
    if ((B_MA1_0<B_MA2_0)&&(B_MA1_1<B_MA2_1)&&(B_MA2_0<B_MA3_0)) 
     {
              TrendStatus=1000; //下跌
     }       

   break; 
    

   case 3004://////短线下穿长线，长线在中间
    if ((B_MA1_0>B_MA2_0)&&(B_MA1_1>B_MA2_1)&&(B_MA2_0>B_MA3_0)){
              TrendStatus=3000; //
       } 
       
    if ((B_MA1_0<B_MA3_0)&&(B_MA2_0<B_MA3_0)){//短线同时刺穿中线，长线,长线在最上方，标准下行
       TrendStatus=1000;////短线同时刺穿中线，长线
    }         
    if ((B_MA1_0<B_MA2_0)&&(B_MA2_0>B_MA3_0)&&(B_MA2_1>B_MA3_1))
    {
        TrendStatus=3003; //上升中的反转过程,短线在中间，短线下穿中线
    } 
  
    break;     
    if ((B_MA1_0>B_MA2_0)&&(B_MA2_0<B_MA3_0)&&(B_MA2_0<B_MA3_0))
    {
        TrendStatus=3005; //下跌中的反转过程,长线在中间，短线在上方
    }  
    break; 
   case 3005:
    if ((B_MA1_0>B_MA2_0)&&(B_MA1_1>B_MA2_1)&&(B_MA2_0>B_MA3_0)){
       TrendStatus=3000;//上升中的反转过程，形成震荡,第二次三线并行上升，标准上升趋势
    }
    
   if ((B_MA1_0<B_MA3_0)&&(B_MA2_0>B_MA3_0)){//短线下穿长线，长线在中间
       //TrendStatus=3004;//////短线下穿长线，长线在中间
    }
    
   
    if ((B_MA1_0<B_MA3_0)&&(B_MA2_0<B_MA3_0)){//短线同时刺穿中线，长线,长线在最上方，标准下行
       TrendStatus=1000;////短线同时刺穿中线，长线
    }
   break;      
   default:
   
         if ((B_MA1_0<B_MA2_0)&&(B_MA1_1<B_MA2_1)&&(B_MA2_0<B_MA3_0)) 
         {
              TrendStatus=1000; //下跌
         }
 
          if ((B_MA1_0>B_MA2_0)&&(B_MA1_1>B_MA2_1)&&(B_MA2_0>B_MA3_0))
         {

              TrendStatus=3000; //上升
         }

      break;
   

   }
  //Print("TrendStatus : ",TrendStatus); 
  BuyMAJiaTuPo(i);
  BuyMA(i);
  BuyMATuPo(i);
 }//for

  return    (TrendStatus);
}
int SellTrendStatus=1;


int JudgeBigTrendSell(int HighOrLow=3,int Peorid1=5,int Peorid2=15,int Peorid3=80,int InitCount=80){

for(int i=InitCount ;i>=0;i--){
// Ma strategy one
 MA1_0=iMA(NULL,0,Peorid1,Ma1Shift,Ma1Method,HighOrLow,0+i);
 MA1_1=iMA(NULL,0,Peorid1,Ma1Shift,Ma1Method,HighOrLow,1+i);
 MA1_2=iMA(NULL,0,Peorid1,Ma1Shift,Ma1Method,HighOrLow,2+i);
 //MA1_n=iMA(NULL,0,Peorid1,Ma1Shift,Ma1Method,HighOrLow,3+i);
// Ma constant
 MA2_0=iMA(NULL,0,Peorid2,Ma2Shift,Ma2Method,HighOrLow,0+i);
 MA2_1=iMA(NULL,0,Peorid2,Ma2Shift,Ma2Method,HighOrLow,1+i);
 MA2_2=iMA(NULL,0,Peorid2,Ma2Shift,Ma2Method,HighOrLow,2+i);
 MA2_x=iMA(NULL,0,Peorid2,Ma2Shift,Ma2Method,HighOrLow,10+i);
// Ma constant
 MA3_0=iMA(NULL,0,Peorid3,Ma3Shift,Ma3Method,HighOrLow,0+i);
 MA3_1=iMA(NULL,0,Peorid3,Ma3Shift,Ma3Method,HighOrLow,1+i);
 MA3_2=iMA(NULL,0,Peorid3,Ma3Shift,Ma3Method,HighOrLow,2+i);
 MA3_x=iMA(NULL,0,Peorid3,Ma3Shift,Ma3Method,HighOrLow,10+i);
 //printf( "%d, %d",SellTrendStatus,i);
 switch(SellTrendStatus)
 {
   case 1000: //下降
   
   if ((MA1_0>MA2_0)&&(MA2_0<MA3_0)&&(MA1_1<MA2_1))
   {
 
        SellTrendStatus=1002; //短线上传穿中线，短线在中间，长线最上面
   }

   break;

 
   case 1002://下跌反转，短线上传穿中线，短线在中间，长线最上面
      if ((MA1_0<MA2_0)&&(MA2_0<MA3_0)) //标准下降通道，三线并行
       {
        SellTrendStatus=1000; //下跌中的反转过程，形成震荡,短线又回到最下面
       }
      
      if ((MA1_0>MA2_0)&&(MA1_1>MA2_1)&&(MA2_0<MA3_0)&&(MA1_0>MA3_0))  //短线上穿长线,长线在中间，中线在最下面
       {
        SellTrendStatus=1007; //短线上穿长线,长线在中间，中线在最下面
       }
                
   break;   


   case 1007://短线上穿长线,长线在中间，中线在最下面 ,此时做多

    if ((MA1_0>MA2_0)&&(MA1_1>MA2_1)&&(MA2_0>MA3_0))
   {
        SellTrendStatus=3000; //标准上升，三线并排
   }   
    if ((MA1_0>MA2_0)&&(MA1_1>MA2_1)&&(MA1_0<MA3_0))//短线又回到中间，开始继续下跌 ，长线最高

   {
        SellTrendStatus=1008; //短线又回到中间，开始继续下跌，长线最高
   } 
     
   break; 
   case 1008://短线又回到中间，开始继续下跌，长线最高
      if ((MA1_0<MA2_0)&&(MA1_1<MA2_1)&&(MA2_0<MA3_0)) 
         {
              SellTrendStatus=1000; //下跌中的后段过程
         }
      if ((MA1_0>MA2_0)&&(MA1_1>MA2_1)&&(MA2_0<MA3_0)) //短线上穿中线,长线在中间
       {
        SellTrendStatus=1007; //短线同时上穿中线和长线
       }        
            
   break;       
   case 3000://上升
    if ((MA1_0<MA2_0)&&(MA2_0>MA3_0)&&(MA2_1>MA3_1))
   {
        SellTrendStatus=3003; //上升中的反转过程,短线在中间，短线下穿中线
   }  
   if ((MA1_0<MA2_0)&&(MA1_0<MA2_0)&&(MA2_0<MA3_0)) 
   {
        SellTrendStatus=1000; //下跌
   }
 
   break;
 
   case 3003:
    if ((MA1_0>MA2_0)&&(MA1_1>MA2_1)&&(MA2_0>MA3_0)){
       SellTrendStatus=3000;//上升中的反转过程，形成震荡,第二次三线并行上升，标准上升趋势
    }
    
   if ((MA1_0<MA3_0)&&(MA2_0>MA3_0)){//短线下穿长线，长线在中间
       SellTrendStatus=3004;//////短线下穿长线，长线在中间
    }
   
    if ((MA1_0<MA2_0)&&(MA1_1<MA2_1)&&(MA2_0<MA3_0)) 
     {
              SellTrendStatus=1000; //下跌
     } 
   //printf(" %f,%f,%f",MA1_0,MA2_0,MA3_0);    
   break; 
    

   case 3004://////短线下穿长线，长线在中间
    if ((MA1_0>MA2_0)&&(MA1_1>MA2_1)&&(MA2_0>MA3_0)){
              SellTrendStatus=3000; //
       } 
       
    if ((MA1_0<MA3_0)&&(MA2_0<MA3_0)){//短线同时刺穿中线，长线,长线在最上方，标准下行
       SellTrendStatus=1000;////短线同时刺穿中线，长线
    }         
    if ((MA1_0<MA2_0)&&(MA2_0>MA3_0)&&(MA2_1>MA3_1) && (MA1_0<MA3_0))
    {
        SellTrendStatus=3003; //上升中的反转过程,短线在中间，短线下穿中线
    }  
    break;     
    if ((MA1_0>MA2_0)&&(MA2_0<MA3_0)&&(MA2_0<MA3_0))
    {
        SellTrendStatus=3005; //下跌中的反转过程,长线在中间，短线在上方
    }  
    break; 
   case 3005:
    if ((MA1_0>MA2_0)&&(MA1_1>MA2_1)&&(MA2_0>MA3_0)){
       SellTrendStatus=3000;//上升中的反转过程，形成震荡,第二次三线并行上升，标准上升趋势
    }
    
   if ((MA1_0<MA3_0)&&(MA2_0>MA3_0)){//短线下穿长线，长线在中间
       //SellTrendStatus=3004;//////短线下穿长线，长线在中间
    }
    
   
    if ((MA1_0<MA3_0)&&(MA2_0<MA3_0)){//短线同时刺穿中线，长线,长线在最上方，标准下行
       SellTrendStatus=1000;////短线同时刺穿中线，长线
    }
   break;      
   default:
   
         if ((MA1_0<MA2_0)&&(MA1_1<MA2_1)&&(MA2_0<MA3_0)) 
         {
              SellTrendStatus=1000; //下跌
         }
 
          if ((MA1_0>MA2_0)&&(MA1_1>MA2_1)&&(MA2_0>MA3_0))
         {

              SellTrendStatus=3000; //上升
         }

      break;
   

   }
 // Print("SellTrendStatus : ",SellTrendStatus," i= " ,i); 
  SellByMA(i);
  SellByMAJiaTuPo(i);
 }//for

  return    (SellTrendStatus);
}

void CloseTodayTrade(){
  for(int i=0;i<OrdersTotal();i++)
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol())
        {
         if(OrderType()==OP_BUY ){
         

                        
            //关闭一天以上单子
            if( TimeDay(TimeCurrent()- OrderOpenTime())>10){
               //if(OrderMagicNumber()==1)    OrderClose(OrderTicket(),OrderLots(),Bid,3,clrNONE); 
             }
            if( TimeHour(TimeCurrent())>=2 &&  TimeHour(TimeCurrent())<4 )            
            {
            
             
              //if(OrderMagicNumber()==3)   OrderClose(OrderTicket(),OrderLots(),Bid,3,clrNONE);  
            }

         }
         if(OrderType()==OP_SELL ) //信号单
         {
 
                        
            //关闭一天以上单子
            if( TimeDay(TimeCurrent()- OrderOpenTime())>10){
               //if(OrderMagicNumber()==10)   OrderClose(OrderTicket(),OrderLots(),Ask,3,clrNONE); 
               if(OrderMagicNumber()==12)   OrderClose(OrderTicket(),OrderLots(),Ask,3,clrNONE);                 
               if(OrderMagicNumber()==13)   OrderClose(OrderTicket(),OrderLots(),Ask,3,clrNONE);   
            }
            if( TimeHour(TimeCurrent())>=2 &&  TimeHour(TimeCurrent())<4 )
            {
                                       
             if(OrderMagicNumber()==11)   OrderClose(OrderTicket(),OrderLots(),Ask,3,clrNONE);     
                
            }
         }
        }
     }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int dig=1;
/*input double  Risk           = 0.25;
input double  Lot            = 0.01;
input int     StopLoss       = 50;
int dig=1;
double MoneyManagement()
  {
   double lots=0;
   double Free_Equity=AccountEquity();
   if(Free_Equity<=0)return(0);
   double TickValue=MarketInfo(Symbol(),MODE_TICKVALUE);
   double LotStep=MarketInfo(Symbol(),MODE_LOTSTEP);
   lots=MathFloor((Free_Equity*MathMin(Risk,100)/100)/(StopLoss*dig*TickValue)/LotStep)*LotStep;
   //printf("TickValue %f, %f ",TickValue,LotStep);
   double MinLots=MarketInfo(Symbol(),MODE_MINLOT);
   double MaxLots=MarketInfo(Symbol(),MODE_MAXLOT);
   if(lots<MinLots)lots=MinLots;
   if(lots>MaxLots)lots=MaxLots;
   if(Risk<=0)lots=Lot;
   return(lots);
  }
  
double CalculateLots(){
   double MinLots=MarketInfo(Symbol(),MODE_MINLOT);
   double MaxLots=MarketInfo(Symbol(),MODE_MAXLOT);
   double lot=0.01;
   if(Risk>0)lot=MoneyManagement();
   if(lot<MinLots)lot=MinLots;
   if(lot>MaxLots)lot=MaxLots;
   if(Risk<=0)lot=Lot;

   if(lot>MaxLots)lot=NormalizeDouble(MaxLots,2);
   lot=NormalizeLots(lot,_Symbol);
   return lot;
}
double NormalizeLots(double lots,string l_Symbol)
  {
   double result=0;
   double minLot=SymbolInfoDouble(l_Symbol,SYMBOL_VOLUME_MIN);
   double maxLot=SymbolInfoDouble(l_Symbol,SYMBOL_VOLUME_MAX);
   double stepLot=SymbolInfoDouble(l_Symbol,SYMBOL_VOLUME_STEP);
   if(lots>0)
     {
      lots=MathMax(minLot,lots);
      lots=minLot+NormalizeDouble((lots-minLot)/stepLot,0)*stepLot;
      result=MathMin(maxLot,lots);
     }
   else
      result=minLot;
   return (NormalizeDouble(result,2));
  }
  bool SellConditionCross(){
  bool doOrder=false;
  if( TimeHour(TimeCurrent())>9 && TimeHour(TimeCurrent())<23 ){
        
     double PriceHigh= High[iHighest(NULL,0,MODE_HIGH,22,1)]; 
     double PriceLow=Low[iLowest(NULL,0,MODE_LOW,22,1)];
     double LongPeriodPriceHigh= High[iHighest(NULL,0,MODE_HIGH,120,1)];       
     if(Close[3]>Open[3] && Close[2]>Open[2] && MathAbs(Close[1]-Open[1]) < NormalizeDouble(10*Point*PointUnit,Digits) && MathAbs(Close[1]-Open[1]) + NormalizeDouble(5*Point*PointUnit,Digits) < MathAbs(High[1]-Close[1]) && Bid >Close[1] && PriceHigh-Bid < NormalizeDouble(60*Point*PointUnit,Digits) && LongPeriodPriceHigh -Bid > NormalizeDouble(10*Point*PointUnit,Digits) && PriceHigh -PriceLow < NormalizeDouble(100*Point*PointUnit,Digits ))
      {
      doOrder=true;
     }
  }
  return doOrder;
  
}*/
bool SellTuPoCondition(){
  bool doOrder=false;
  if(JudgeMagicNumberExit(540)!=0)    return doOrder;    
  if( TimeHour(TimeCurrent())>4 && TimeHour(TimeCurrent())<23 ){//FobidTrade(1,10)==1 && UpOrDownBefore()==false 
     
  double PriceHigh= High[iHighest(NULL,0,MODE_HIGH,4,1)]; 
  double PriceLow=Low[iLowest(NULL,0,MODE_LOW,240,1)];   
  double LongPeriodPriceHigh= High[iHighest(NULL,0,MODE_HIGH,40,10)]; 
  UpLinePrice=LongPeriodPriceHigh;   
//  if(Close[1]<Open[1] &&  Bid<PriceLow  && PriceHigh-Bid < NormalizeDouble(60*Point*PointUnit,Digits)  )//突破交易
  if( PriceHigh > LongPeriodPriceHigh &&  Bid < LongPeriodPriceHigh &&  LongPeriodPriceHigh -Bid <  NormalizeDouble(10*Point*PointUnit,Digits) &&  PriceHigh -Bid <  NormalizeDouble(40*Point*PointUnit,Digits) )//假突破交易
    {
     if(Bid-PriceLow > NormalizeDouble(250*Point*PointUnit,Digits))
      doOrder=true;
     }
  } 
  return doOrder;
  
} 
double AccountLoss(int day=1){//1时只算当天的
   double LossCount=0;
   int  total=OrdersHistoryTotal();
   //printf(" total%d",total);
   for(int i=0; i<total; i++)
   {
        if(OrderSelect(total-i,SELECT_BY_POS,MODE_HISTORY))
        {             
               // printf(" %d",TimeDay(TimeCurrent()- OrderCloseTime()));
            if( TimeDay(TimeCurrent()- OrderCloseTime()) <= day && TimeDay(TimeCurrent()- OrderCloseTime())>0 ){
         
               LossCount+=OrderProfit();
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
void CloseAllTrade(){
  for(int i=0;i<OrdersTotal();i++)
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      //if(OrderSymbol()==Symbol())
        {
         if(OrderType()==OP_BUY)
         OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,0);
         if(OrderType()==OP_SELL) 
         OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,0);
        }
     }
}
  
static double zhanghuzijin=1;
double HisLoss;
bool ManageEquity(){
   int    j;
   bool ret=true;
   if(AccountEquity()>zhanghuzijin)
   {
      zhanghuzijin=AccountEquity();
   }//记录账户净值最大值；
   HisLoss=AccountLoss(1);
   if((HisLoss/zhanghuzijin) < (0-MaxTodayLoss) )//如果账户净值小于最大值的x%，则全部清仓；
   {
      CloseAllTrade();
      ret=false;
      //zhanghuzijin=1;//还原账户净值最大值记录变量；
   }
   return ret;
}
