//+------------------------------------------------------------------+
//|                                              MTK_TP_Controls.mqh |
//|                       Copyright 2014, MTK Beijing Tech. Co., Ltd |
//|                                        https://www.mt4xitong.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MTK Lab"
#property strict
#property version "2.00"
//2015-03 
#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
#include <Controls\Edit.mqh>
//#include <Controls\Label.mqh>
#include <Controls\ListView.mqh>
#include <Controls\MTKComboBox.mqh>
#include <Controls\Picture.mqh>
#include <Controls\VolEdit.mqh>
#include <Controls\Panel.mqh>
#include <Controls\Scrolls.mqh>
#include <stderror.mqh>
#include <stdlib.mqh>
#include <Tool_TP_CONFIG.mqh>


  

//+------------------------------------------------------------------+//| Constructor                                                      |
//+------------------------------------------------------------------+
CMTKTradePadDialog::CMTKTradePadDialog(void)
{
   BACK_COLOR = clrBlack;
   BORDER_COLOR = clrCyan;
   TEXT_COLOR = clrWhite;
   PRICE_COLOR = clrGreen;
   PAYOFF_COLOR = clrDarkBlue;
   OPERATE_PANEL_BG_COLOR = clrBlack;
   PAYOFF_PANEL_BG_COLOR = clrDarkGray;
   OPERATE_PANEL_COLOR = clrBlack;
   PAYOFF_PANEL_COLOR = clrWhite;
   BUTTON_UP_COLOR = clrLime;
   BUTTON_DOWN_COLOR = clrRed;
   CHART_BAR_DOWN_COLOR = clrRed;
   CHART_BAR_UP_COLOR = clrLime;
   POSITION_BACK_COLOR = clrGray;

   PanelLoaded = false;





  
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CMTKTradePadDialog::~CMTKTradePadDialog(void)
{
   //int ntx = Dll_Stop();
   //if(ntx>0)
   //   printf("EA Threads="+ntx);
   //else
   //   printf("Config-Loader stopped, %d requests for %s received", Dll_TotalRequests(), BytesNumber(Dll_TotalBytes()));
}

//---- Init



//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
bool CMTKTradePadDialog::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
{
   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2)) {
      Print("Create Window Fail");
      return(false);
   }
   
//--- create dependent controls
   return(true);
}
bool CMTKTradePadDialog::OnResize(void)
  {
//--- call method of parent class
   if(!CAppDialog::OnResize()) return(false);
   return(true);
}
//---- Event handlers
void CMTKTradePadDialog::Minimize(void)
{
   int heightChart=ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0);
   int widthChart=ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);
   int heightDialog = Bottom()-Top();
   int widthDialog = Right()-Left();
   /*
   if(heightChart>heightDialog-5)
   {
      CAppDialog::Minimize();
   }
   else
   {
      return;
   }*/
   return;
}

int OrderTodayCNT=10;
int OrderMaxToday=10;
void CMTKTradePadDialog::OnClickButtonA(void) {
   //double PriceHigh= High[iHighest(NULL,0,MODE_HIGH,barCount,1)]; //for 5MIN
   //double PriceLow=Low[iLowest(NULL,0,MODE_LOW,barCount,1)];
   if(OrderTodayCNT >OrderMaxToday){ Alert("超过当天交易次数"); return;}//超过当天次数
   if(HistoryTodayDirection==OP_SELL && bTrendDirection==false) { Alert("交易方向与当天第一个交易不符！"); return;}
   if(HistoryTodayDirection==OP_BUY && bTrendDirection==true) { Alert("交易方向与当天第一个交易不符！"); return;} 
   /////////////////////////////
   int MBTrend= MessageBox( "趋势明显吗?","提高胜率",MB_YESNO);
   if(MBTrend==IDYES){
      int MBPrice= MessageBox( "有价格优势吗?","提高胜率",MB_YESNO);
      if(MBPrice==IDYES){
         int MBData= MessageBox( "有新闻数据及基本面优势吗?  是否过滤毛刺等耍流氓行为？","提高胜率",MB_YESNO);
            if(MBData==IDNO) return;
         
      
      }else return;
   
   }else return;
   
   ///////////////////////////////     
   double stoploss,takeprofit;
   if(bTrendDirection){//sell
         double bid=SymbolInfoDouble(ChartSymbol(),SYMBOL_BID); 
         stoploss=NormalizeDouble(bid+SellStop_StopLoss*Point*PointUnit,Digits);
         printf("A:MN=%d,takeprofit=%f  ,stoploss=%f ",BreakOutMagicSell,takeprofit,stoploss);         
         takeprofit=NormalizeDouble(bid-SellStop_TakeProfit*Point*PointUnit,Digits);    
         if(JudgeMagicNumberExit(BreakOutMagicSell,ChartSymbol())==0) {
          OpenShort(SellStop_Lot,BreakOutMagicSell,stoploss,takeprofit,ChartSymbol()); 
                   
         }
         else MessageBox( "不能下单","重复下单",0);    
   }
   else{
         stoploss=NormalizeDouble(Ask-BuyStop_StopLoss*Point*PointUnit,Digits);
         takeprofit=NormalizeDouble(Ask+BuyStop_TakeProfit*Point*PointUnit,Digits);
         if(JudgeMagicNumberExit(BreakOutMagicBuy,ChartSymbol())==0) {
             OpenLong(BuyStop_Lot,BreakOutMagicBuy,stoploss,takeprofit,ChartSymbol());
                   
         } 
         else MessageBox( "不能下单","重复下单",0); 
   }

}

void CMTKTradePadDialog::OnClickButtonB(void) {
   double stoploss,takeprofit;
   if(OrderTodayCNT >OrderMaxToday){ Alert("超过当天交易次数"); return;}//超过当天次数   
   if(HistoryTodayDirection==OP_SELL && bTrendDirection==false) { Alert("交易方向与当天第一个交易不符！"); return;}
   if(HistoryTodayDirection==OP_BUY && bTrendDirection==true) { Alert("交易方向与当天第一个交易不符！"); return;}  
   /////////////////////////////
   int MBTrend= MessageBox( "趋势明显吗?","提高胜率",MB_YESNO);
   if(MBTrend==IDYES){
      int MBPrice= MessageBox( "有价格优势吗?","提高胜率",MB_YESNO);
      if(MBPrice==IDYES){
         int MBData= MessageBox( "有新闻数据及基本面优势吗?","提高胜率",MB_YESNO);
            if(MBData==IDNO) return;
         
      
      }else return;
   
   }else return;
   
   ///////////////////////////////         
   if(bTrendDirection){//sell
         double bid=SymbolInfoDouble(ChartSymbol(),SYMBOL_BID); 
         stoploss=NormalizeDouble(bid+SellStop_StopLoss*Point*PointUnit,Digits);
         takeprofit=NormalizeDouble(bid-SellStop_TakeProfit*Point*PointUnit,Digits);    
         if(JudgeMagicNumberExit(FollowTrendSell,ChartSymbol())==0) {
          OpenShort(SellStop_Lot,FollowTrendSell,stoploss,takeprofit,ChartSymbol()); 
                   
         }
         else MessageBox( "不能下单","重复下单",0);    
   }
   else{
         stoploss=NormalizeDouble(Ask-BuyStop_StopLoss*Point*PointUnit,Digits);
         takeprofit=NormalizeDouble(Ask+BuyStop_TakeProfit*Point*PointUnit,Digits);
         if(JudgeMagicNumberExit(FollowTrendBuy,ChartSymbol())==0) {
             OpenLong(BuyStop_Lot,FollowTrendBuy,stoploss,takeprofit,ChartSymbol());
                   
         }
         else MessageBox( "不能下单","重复下单",0);  
   }
}

void CMTKTradePadDialog::OnClickButtonC(void) {
   double stoploss,takeprofit;
   if(OrderTodayCNT >OrderMaxToday){ Alert("超过当天交易次数"); return;}//超过当天次数   
   if(HistoryTodayDirection==OP_SELL && bTrendDirection==false) { Alert("交易方向与当天第一个交易不符！"); return;}
   if(HistoryTodayDirection==OP_BUY && bTrendDirection==true) { Alert("交易方向与当天第一个交易不符！"); return;}
   /////////////////////////////
   int MBTrend= MessageBox( "趋势明显吗?","提高胜率",MB_YESNO);
   if(MBTrend==IDYES){
      int MBPrice= MessageBox( "有价格优势吗?","提高胜率",MB_YESNO);
      if(MBPrice==IDYES){
         int MBData= MessageBox( "有新闻数据及基本面优势吗?","提高胜率",MB_YESNO);
            if(MBData==IDNO) return;
         
      
      }else return;
   
   }else return;
   
   ///////////////////////////////           
   if(bTrendDirection){//sell
         double bid=SymbolInfoDouble(ChartSymbol(),SYMBOL_BID); 
         stoploss=NormalizeDouble(bid+SellStop_StopLoss*Point*PointUnit,Digits);
         takeprofit=NormalizeDouble(bid-SellStop_TakeProfit*Point*PointUnit,Digits);    
         if(JudgeMagicNumberExit(MagicSellStop,ChartSymbol())==0) {
          OpenShort(SellStop_Lot,MagicSellStop,stoploss,takeprofit,ChartSymbol()); 
                   
         }
         else MessageBox( "不能下单","重复下单",0);    
   }
   else{
         stoploss=NormalizeDouble(Ask-BuyStop_StopLoss*Point*PointUnit,Digits);
         takeprofit=NormalizeDouble(Ask+BuyStop_TakeProfit*Point*PointUnit,Digits);
         if(JudgeMagicNumberExit(MagicBuyStop,ChartSymbol())==0) {
             OpenLong(BuyStop_Lot,MagicBuyStop,stoploss,takeprofit,ChartSymbol());
                   
         }
         else MessageBox( "不能下单","重复下单",0);  
   }
}


   





bool CMTKTradePadDialog::InitializeDialog(const long chart,const int subwin,const int lang_id,const int defaultTradeType)
{

   int retStart;   
  string _host;
   string _path;
  
   if(!PanelLoaded) { //first call
 
      PanelLoaded = true;

      if (!Create(chart, "赌博", subwin, PANEL_X,PANEL_Y,PANEL_X+PANEL_WIDTH,PANEL_Y+PANEL_HEIGHT)) return (false);
 
       //Panel Operation   
      if(!panel_operation.Create(m_chart_id, "paneloperation", m_subwin, 0, 0, 100, 120)) return (false);
      if(!Add(panel_operation)) return (false);
   

      //Buttons
      //--- button UP
      if(!buttonA.Create(m_chart_id, "btnA", m_subwin, 0 , 0, 90 , 40)) return (false);
      if(!Add(buttonA)) return (false);
      buttonA.FontSize(DEFAULT_FONTSIZE/111);
      //buttonA.Locking(false);
      buttonA.ColorBorder(Pad_BG_Color);
      buttonA.ColorBackground(clrYellowGreen);
      buttonA.Color(clrBlue);
 


      if(!buttonB.Create(m_chart_id, "btnB", m_subwin, 0, 50, 90, 90)) return (false);
      if(!Add(buttonB)) return (false);
      buttonB.FontSize(DEFAULT_FONTSIZE/111);
      //buttonB.Locking(false);
      buttonB.ColorBorder(Pad_BG_Color);      
      buttonB.ColorBackground(clrAliceBlue);
      buttonB.Color(clrBlue);
      
      if(!buttonC.Create(m_chart_id, "btnC", m_subwin, 0 , 100, 90 , 140)) return (false);
      if(!Add(buttonC)) return (false);
      buttonC.FontSize(DEFAULT_FONTSIZE/111);
      //buttonA.Locking(false);
      buttonC.ColorBorder(Pad_BG_Color);
      buttonC.ColorBackground(clrYellowGreen);
      buttonC.Color(clrBlue);      

   }      

   panel_operation.ColorBackground(OPERATE_PANEL_BG_COLOR);
   panel_operation.ColorBorder(OPERATE_PANEL_BG_COLOR);
   string WTitle="";   
   if(bTrendDirection) WTitle="做空";
   else WTitle="做多"; 
      

   buttonA.Text(WTitle+"突破");
   buttonA.ColorBackground(BUTTON_UP_COLOR);

   buttonB.Text(WTitle+"趋势");
   buttonB.ColorBackground(BUTTON_DOWN_COLOR);
      

   buttonC.Text(WTitle+"右侧");
   buttonC.ColorBackground(BUTTON_UP_COLOR);


     
   return true;
}

CMTKTradePadDialog ExtDialog;   
 string ServerID = "";
 color Text_Color = clrWhite;
 color Price_Color = clrWhite;//clrSteelBlue;
 color Pad_BG_Color = clrBlack;
 color Pad_Border_Color = clrAzure;
 color Operation_Panel_BG_Color = clrYellowGreen;
 color Operation_Panel_Color = clrBlack;
 color Payoff_Panel_BG_Color = clrBrown;
 color Payoff_Panel_Color = clrBlack;
 color Payoff_Text_Color = clrBlack;
 color ChartBarUp = clrLightGreen;
 color ChartBarDown = clrRed;
 color ButtonUp = clrWhite;
 color ButtonDown = clrWhite;
 color PositionBack = clrSteelBlue;
 color CTLSteelBlue = clrSteelBlue;


int WindowInit(){

   if(!ExtDialog.InitializeDialog(0,0,0,0)) {
      return(INIT_FAILED);
   }

//--- run application
   if(!ExtDialog.Run()) {  
      return(INIT_FAILED);
   }

       
   return(INIT_SUCCEEDED); 
  }
  
  //+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---

   ExtDialog.ChartEvent(id,lparam,dparam,sparam);
   if(ExtDialog.Left()<0||ExtDialog.Top()<0)
   {
      ExtDialog.Move(PANEL_X,PANEL_X);
   }
   
  }