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
#include <MTK_TP_Language.mqh>
#include <stderror.mqh>
#include <stdlib.mqh>
#include <MQH\Lib\SQLite3\SQLite3Base.mqh>
#include <MTK_TP_CONFIG.mqh>

#resource "Controls\\res\\chartbg.bmp"                // image file


//+------------------------------------------------------------------+
//| Class CMTKTradePadDialog                                         |
//| Usage: main dialog of the BO Trade Pad                           |
//+------------------------------------------------------------------+
class CMTKTradePadDialog : public CAppDialog
{

public:
   string            symbolSelected;
   int               tradeType;
   int               tradeCmd;
   int               tradeExpiration;
   bool              needConfirm;
   bool              tradeSignal;
   string            serialNo;
   int               uid;
   bool              displayPositions;
   string            host_head;
   bool              isDemo;
   bool              first_reload;
   CSQLite3Base sql3;
   CSQLite3Table tbl;   
   string ExpiList[10];
   string symbols[100];
   string playtype[20];
   string updateTime;
   string accountname;    
   long login;
private:

   bool              PanelLoaded;
   bool              firstEAThread;
   bool              showPosition;
   int               PriceDigits;
/*   
   int               PriceMode[2];
   double            PriceOffset[2];
   int               MaxVols[2];
   int               MinVols[2];
   int               StepVols[2];
   double            Payoff[2];
   double            LvPayoff[2];
  */    
   bool              hasExpiVal;

   
   bool              tradeCheck(const int _type);
   void              tradeDisable();   
   void              tradeEnable(); 
   POSITIONS         openning[];
   BOCONFIG          special_config;
   BOCONFIG          normal_config;  
   BOCONFIG          cur_config;     
   int               openning_max;
   int               openning_total;
   CScrollV          openning_scroll;
   CPanel            open_ticket;
   CPanel            open_symbol;
   CPanel            open_expiration;
   CPanel            open_cmd;
   CPanel            open_invest;
   CPanel            open_return;
   CPanel            open_process;
   
   CEdit             edit_openning[5][6];
   
   int               magic_number;
   int               mt4login;
   //Color
   color             BACK_COLOR;
   color             BORDER_COLOR;
   color             TEXT_COLOR;
   color             PRICE_COLOR;
   color             PAYOFF_COLOR;
   color             OPERATE_PANEL_BG_COLOR;
   color             PAYOFF_PANEL_BG_COLOR;
   color             OPERATE_PANEL_COLOR;
   color             PAYOFF_PANEL_COLOR;
   color             BUTTON_UP_COLOR;
   color             BUTTON_DOWN_COLOR;
   color             CHART_BAR_UP_COLOR;
   color             CHART_BAR_DOWN_COLOR; 
   color             POSITION_BACK_COLOR;

   //---- static info
   CEdit             edit_expiration;
   CEdit             edit_volume;
   CEdit             edit_tradeType;
   
   CEdit             edit_status;
   CEdit             edit_detail;
   CEdit             edit_position;
   
   CPanel            panel_operation;
   CPanel            panel_payoff;
   CPanel            panel_trade;   

   
   //---- dynamic info
   CEdit             edit_symbol_price;
   CEdit             edit_payoff;
   CEdit             edit_payoffl;
   CEdit             edit_return;
   CEdit             edit_txtpayoff;
   
   //---- combobox/option
   CComboBox         combo_symbol;

   CVolEdit          combo_volume;
   CComboBox         combo_expiration;
   CComboBox         combo_tradeType;
   
   //---- Buttons
   CButton           buttonA;
   CButton           buttonB;

   //---- other config parameters
   int               language_idx;
   bool              withHistoryPad;
   
   //---- chart element
   CPanel            Candles[UCHART_CANDLES_NUMBER][3];
   CEdit             PriceLabel[4];
   int               periodSelected;
   int               lastPeriod;
   string            lastSymbol;
   MqlRates          rate_array[];
   int               copiedNumber;
   datetime          lastTime;
   int               lastTickVol;
   double            tickHigh;
   double            tickLow;
   int               symbolDigits;
   int               ChartBottomY;
   bool              chartReady;
   double            quote, _bid, _ask;
   datetime          quotetime;
public:
                     CMTKTradePadDialog(void);
                    ~CMTKTradePadDialog(void);
   void              Disconnect();
   int               SqlInit();
   int               Sqlquery();
   bool              checkTrader(void);     

   bool              SymbolTablePrint(CSQLite3Table &tbl);   
   int               CalcMagicNumber(string symbol, const int _expi, const int _invest, const int _cmd, const int _dayOfYear);
   //--- chart event handler
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   bool              reloadConfig();
   bool              reloadSymbol();
   bool              reloadType(string symbol);
   bool              reloadExp();
   
   void              OutToStatus(string txt, color fcolor = clrBlack);
   void              OutToPosition(const int orders, const double invest);

   void              RefreshPositions();
      
   void              setColor_Back(const color _clr) { BACK_COLOR = _clr; }
   void              setColor_Border(const color _clr) { BORDER_COLOR = _clr; }
   void              setColor_Text(const color _clr) { TEXT_COLOR = _clr; }
   void              setColor_Price(const color _clr) { PRICE_COLOR = _clr; }
   void              setColor_Payoff(const color _clr) { PAYOFF_COLOR = _clr; }
   void              setColor_OperatePanelBG(const color _clr) { OPERATE_PANEL_BG_COLOR = _clr; }
   void              setColor_PayoffPanelBG(const color _clr) { PAYOFF_PANEL_BG_COLOR = _clr; }
   void              setColor_OperatePanel(const color _clr) { OPERATE_PANEL_COLOR = _clr; }
   void              setColor_PayoffPanel(const color _clr) { PAYOFF_PANEL_COLOR = _clr; }
   void              setColor_ButtonUp(const color _clr) { BUTTON_UP_COLOR = _clr; }
   void              setColor_ButtonDown(const color _clr) { BUTTON_DOWN_COLOR = _clr; }
   void              setColor_BarUp(const color _clr) { CHART_BAR_UP_COLOR = _clr; }
   void              setColor_BarDown(const color _clr) { CHART_BAR_DOWN_COLOR = _clr; }
   void              setColor_PositionBG(const color _clr) { POSITION_BACK_COLOR = _clr; }
   
   bool              InitializeDialog(const long chart, const int subwin, const int lang_id, const int defaultTradeTyp);
   
   bool              ClearDialog(const int defaultradeType);
   //---- AddItem
   bool              AddComboItem(const ComboID cmbID, int position, const string item);
   //---- default show
   bool              ShowComboItem(const ComboID cmdID, const string item);

   //---- update
   bool              updatePrice(const double bid, const double ask, const datetime dt);   
protected:
   //--- create
   virtual bool      Create(const long chart,const string name,const int subwin, const int x1,const int y1,const int x2,const int y2);
   
   //--- internal event handlers
   virtual bool      OnResize(void);
   //--- handlers of the dependent controls events
   void              OnClickButtonA(void);
   void              OnClickButtonB(void);
   void              OnChangeComboSymbol(void);
   void              OnChangeComboVolume(void);
   void              OnChangeComboExpiration(void);
   void              OnChangeComboTradeType(void);
   void              OnChangeComboPeriod(void);
   void              OnPosScrollDown(void);
   void              OnPosScrollUp(void);
   
      
   void              OnClickLogo(void);

 private:
   void              ReDrawChart();
   bool              TimeSections();
   bool              TimeSectionsEnabled();
   void              CalculateReturn(int which);
   string            Exp_Sec2Str(const int _exp, const bool isShort=true);
   int               Exp_Str2Sec(string _exp);
   void              InsertOrder(const int ticket);
   void              ShowOrdersFromPosition(const int pos, const int orderCount);
   void              ShowOrderAsItem(POSITIONS &order, const int atPos);
   string            BytesNumber(const int _byte);
 };
//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CMTKTradePadDialog)
   ON_EVENT(ON_CLICK,buttonA,OnClickButtonA)
   ON_EVENT(ON_CLICK,buttonB,OnClickButtonB)
   //ON_EVENT(ON_CLICK,pic_Logo,OnClickLogo);
   ON_EVENT(ON_CHANGE,combo_symbol,OnChangeComboSymbol)
   ON_EVENT(ON_CHANGE,combo_volume,OnChangeComboVolume)
   ON_EVENT(ON_END_EDIT, combo_volume,OnChangeComboVolume)
   ON_EVENT(ON_CHANGE,combo_expiration,OnChangeComboExpiration)
   ON_EVENT(ON_CHANGE,combo_tradeType,OnChangeComboTradeType)

   ON_EVENT(ON_SCROLL_DEC, openning_scroll, OnPosScrollUp)
   ON_EVENT(ON_SCROLL_INC, openning_scroll, OnPosScrollDown)
EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CMTKTradePadDialog::CMTKTradePadDialog(void)
{
   BACK_COLOR = clrBlack;
   BORDER_COLOR = clrCyan;
   TEXT_COLOR = clrWhite;
   PRICE_COLOR = clrGreen;
   PAYOFF_COLOR = clrDarkBlue;
   OPERATE_PANEL_BG_COLOR = clrBeige;
   PAYOFF_PANEL_BG_COLOR = clrDarkGray;
   OPERATE_PANEL_COLOR = clrBlack;
   PAYOFF_PANEL_COLOR = clrWhite;
   BUTTON_UP_COLOR = clrLime;
   BUTTON_DOWN_COLOR = clrRed;
   CHART_BAR_DOWN_COLOR = clrRed;
   CHART_BAR_UP_COLOR = clrLime;
   POSITION_BACK_COLOR = clrGray;
   symbolSelected = "";
   periodSelected = 1;
   lastSymbol = "";
   lastTickVol = -1;
   lastPeriod = -1;
   chartReady = false;
   PanelLoaded = false;
   quote = 0;
   uid = 0;
   magic_number = 888888;
   tradeSignal = false;
   displayPositions = true;
   firstEAThread = false;
   hasExpiVal = false;
   showPosition = false;
   host_head = "";
   isDemo = true;
   first_reload=false;
   SqlInit(); 
   mt4login=AccountCompany(); 
   accountname=AccountInfoString(ACCOUNT_NAME);  
   login=AccountInfoInteger(ACCOUNT_LOGIN);      
   needConfirm=true;
   special_config.time_section_mode="daily";       
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CMTKTradePadDialog::~CMTKTradePadDialog(void)
{
   int ntx = Dll_Stop();
   if(ntx>0)
      printf("EA Threads="+ntx);
   else
      printf("Config-Loader stopped, %d requests for %s received", Dll_TotalRequests(), BytesNumber(Dll_TotalBytes()));
}

//---- Init
bool CMTKTradePadDialog::updatePrice(const double bid, const double ask, const datetime dt) {
   if(m_minimized) return(true);
   _bid = bid;
   _ask = ask;
   quotetime = dt;
   if(cur_config.PriceMode[0] == PMODE_ASK)
      quote = bid + cur_config.PriceOffset[0];
   else if (cur_config.PriceMode[0] == PMODE_BID)
      quote = ask + cur_config.PriceOffset[0];
   else
      quote = (ask+bid)/2 + cur_config.PriceOffset[0];
   edit_symbol_price.Text(DoubleToString(quote, PriceDigits));
   //ReDrawChart();
   return(true);
}
void CMTKTradePadDialog::OutToStatus(string txt,color fcolor) {
   edit_status.Color(fcolor);
   edit_status.Text(txt);
}
void CMTKTradePadDialog::OutToPosition(const int orders, const double invest) {
   edit_position.Text(STATUS_TEXT[language_idx][S_STATUS_BO_ORDERS]+IntegerToString(orders)+ " / "+STATUS_TEXT[language_idx][S_STATUS_BO_INVEST]+DoubleToString(invest,0));
   //edit_position.Text(IntegerToString(orders)+ " / "+DoubleToString(invest,2));
}
void CMTKTradePadDialog::tradeDisable(void){
   buttonA.ColorBackground(clrGray); 
   buttonA.Disable();
   buttonB.ColorBackground(clrGray); 
   buttonB.Disable();
   combo_expiration.ItemsClear();         
   combo_symbol.ItemsClear();         
  
   combo_tradeType.ItemsClear();
   tradeType=-1;  
                  
}
void CMTKTradePadDialog::tradeEnable(void){
    buttonA.Enable();
    buttonA.ColorBackground(BUTTON_UP_COLOR); 
    buttonB.Enable();
    buttonB.ColorBackground(BUTTON_DOWN_COLOR); 
                  
}
bool CMTKTradePadDialog::checkTrader(void){
  //在mtk_bo_symbols中选择有效的货币对，货币对是否有效取决于enabled字段的值，0的话，无效，另外，putcall_enabled和smallbig_enabled等字段的值决定多种相应玩法的有效性，比如putcall和smallbig玩法 
    string chartSymbol = Symbol();
    string sqlquery="select enabled from mtk_bo_symbols where ";
    sqlquery+="symbol ='" + chartSymbol + "'"; 
 //   printf(" %s ", sqlquery);
    if(sql3.Query(tbl,sqlquery)!=SQLITE_DONE)
     {
      Print(sql3.ErrorMsg());
      return false ;
     }     
   int c,cs,count=0;
   string temps[20];
   int rs=ArraySize(tbl.m_data);
   for(int r=0; r<rs; r++)
     {
      CSQLite3Row *row=tbl.Row(r);
      cs=ArraySize(row.m_data);
      for( c=0; c<cs; c++){
         temps[count]=row.m_data[c].GetString();
         //printf(" %s    %d",row.m_data[c].GetString(),rs);
         count++;
      }
     }
   if(StringCompare(temps[0],"0")==0){//1 means enabled,0 disabled
      OutToStatus(STATUS_TEXT[language_idx][S_STATUS_BO_NOCFG]);   
      return false;
   } 
   //select count(*) as CNT from mtk_bo_mt4group_symbol where mt4_group='BOTest' and symbol='Gold.bx'
     sqlquery="select count(*) as CNT from mtk_bo_mt4group_symbol where mt4_group='"+accountname + "' and symbol='" +chartSymbol+"'"; 
   // printf(" %s ", sqlquery);
    if(sql3.Query(tbl,sqlquery)!=SQLITE_DONE)
     {
      Print(sql3.ErrorMsg());
      return false ;
     }     

   rs=ArraySize(tbl.m_data);
   if(rs<1){
   //
      OutToStatus(STATUS_TEXT[language_idx][S_STATUS_BO_NOCFG]);   
      return false;
   }
  
    /////////////////////////////////////////
   tradeEnable();          
    return true;  

}
bool CMTKTradePadDialog::reloadConfig(void){
  if(Dll_EACount() == 0) { // not started
      if(Dll_Start()>0) {
         printf("Config-Loader(Version %.2f) restart OK", (double)Dll_GetVersion()/100.0);
         if(checkTrader()) reloadSymbol();         
         }
      else {
         printf("Config-Loader(Version %.2f) restart FAIL", (double)Dll_GetVersion()/100.0);
         //reloadSymbol();
         OutToStatus(STATUS_TEXT[language_idx][S_STATUS_BO_NOCFG]);
         return true;      
      }   
   }
   

// 账号登陆时获取自己所在组，然后通过与mtk_bo_mt4group_symbol表中定义的数据进行比较来获得自己能够交易的货币，比如mt4_group字段里的用户组能够交易的货币在symbol字段里被定义  


// if first reload
   if(!first_reload){
      if(checkTrader()) reloadSymbol();
      else
      {
         tradeDisable();            
      }   
      first_reload=true;   
   }   

//query tha data whether changed or not, if changed then reload.
    string sqlquery="select flag,time from  mtk_bo_data_change"; 
    if(sql3.Query(tbl,sqlquery)!=SQLITE_DONE)
     {
      Print(sql3.ErrorMsg());
      return false ;
     }     

   string temps1[4];
   int count;
   count=0;
   int rs=ArraySize(tbl.m_data);
   for(int r=0; r<rs; r++)
     {
      CSQLite3Row *row=tbl.Row(r);
      int cs=ArraySize(row.m_data);
      for( int c=0; c<cs; c++){
         temps1[count]=row.m_data[c].GetString();
         //printf(" %s    %d",row.m_data[c].GetString(),rs);
         count++;
      }
     }
   if(StringCompare(temps1[0],"1")==0){//1 means changed
      if(StringCompare(temps1[1],updateTime)!=0){
         if(checkTrader()) reloadSymbol();
         else
         {   
            tradeDisable();                   
         }   
            
        updateTime=temps1[1];
        printf("Update %s",updateTime);
        }
   }
   
    if(TimeSectionsEnabled()==true){//in special time section ,the trade is disable
      OutToStatus(STATUS_TEXT[language_idx][S_STATUS_BO_NOCFG]);
      tradeDisable();   
    } 
    else{
       tradeEnable();    
    }
   return true;
}
int CMTKTradePadDialog::SqlInit()
  {
  //--- open database connection
   if(sql3.Connect("d:bo/conf/bodll.db")!=SQLITE_OK){
        printf("sql open fail");
      return INIT_FAILED;
  }
   printf("sql open ok!");
   updateTime="";//mtk_bo_data_change ,time field        
   return(INIT_SUCCEEDED);
  } 

 void  CMTKTradePadDialog::Disconnect(){
   sql3.Disconnect();
}
bool CMTKTradePadDialog::InitializeDialog(const long chart,const int subwin,const int lang_id,const int defaultTradeType)
{
   language_idx = lang_id;
   //setColor_ClientBG(BACK_COLOR);
   //setColor_ClientBorder(BORDER_COLOR);
   //setColor_CaptionBG(BORDER_COLOR);
   Dll_InitEnvParam(AccountCompany(), TerminalInfoInteger(TERMINAL_BUILD), 0, _VERSION, AccountNumber(), AccountServer(), 30);
   string _host;
   string _path;

   if(!PanelLoaded) { //first call
     
      int retStart = Dll_Start();

      if(retStart == 1) firstEAThread = true;
      printf("TradePad(Version %.2f) initializing...", (double)(_VERSION / 100.0));
      if(retStart>0) printf("Config-Loader(Version %.2f) start OK, %d EA Threads", (double)Dll_GetVersion()/100.0, retStart);   
      PanelLoaded = true;
      int wholeHeight = PANEL_HEIGHT+STATUS_HEIGHT-CONTROLS_GAP_Y;
      if(displayPositions) 
      wholeHeight+=PANEL_POSITION_HEIGHT+LABEL_POSITION_HEIGHT+CONTROLS_GAP_Y*2; 
      
      if (!Create(chart, DISPLAY_LANG[language_idx][S_PANEL_TITLE], subwin, PANEL_X,PANEL_Y,PANEL_X+PANEL_WIDTH,PANEL_Y+wholeHeight)) return (false);
   
      int x1,x2,x11,x22;
      int y1,y2,y11,y22;
   
      y1 = CONTROLS_SUBWINDOW_GAP+CONTROLS_GAP_Y;
      y2 = y1+LABEL_HEIGHT;
      y11= y2+CONTROLS_GAP_Y;
      y22= y11+CHART_HEIGHT;
   
      //Product Name
      x1 = SPACE_LEFT;
      x2 = SYMBOL_WIDTH;  
   
      if(!combo_symbol.Create(m_chart_id, "cmbsymbol", m_subwin, x1, y1, x2, y2)) return (false);
      if(!Add(combo_symbol)) return (false);
      combo_symbol.SetReadOnly(true);
      
      //------ test ----
      
    
      //--- TradeType
      //Text
      x1 = x2+CONTROLS_GAP_X+30;
      x2 = SPACE_LEFT+CHART_WIDTH-30;
      x11 = x2+CONTROLS_GAP_X;
      x22 = x11 + BTN_WIDTH+CONTROLS_GAP_X * 4;
      if(!edit_tradeType.Create(m_chart_id, "txttradetype", m_subwin, x1, y1, x2, y2)) return (false);
      if(!Add(edit_tradeType)) return (false);
      edit_tradeType.TextAlign(ALIGN_CENTER);
      edit_tradeType.ReadOnly(true);
   
   
      if(!combo_tradeType.Create(m_chart_id, "cmbtradetype", m_subwin, x11, y1, x22, y2)) return (false);
      if(!Add(combo_tradeType)) return (false);
      combo_tradeType.SetReadOnly(true);
      
      //Chart
      x1 = SPACE_LEFT;
      x2 = x1+CHART_WIDTH;

      ChartBottomY = y22 - UCHART_SPACE_BOTTOM;
      
      //Panel Operation   
      if(!panel_operation.Create(m_chart_id, "paneloperation", m_subwin, 9, y11, 309, y22)) return (false);
      if(!Add(panel_operation)) return (false);
      //printf("x1 =%d x2 =%d", x11-CHART_WIDTH,SPACE_LEFT+CHART_WIDTH+CONTROLS_GAP_X); 
      //Panel Payoff
      x1 = x22 + CONTROLS_GAP_X;
      x2 = ClientAreaWidth() - SPACE_RIGHT; 
      if(!panel_payoff.Create(m_chart_id, "panelpayoff", m_subwin, 309, 36, 587, 196)) return (false);
      if(!Add(panel_payoff)) return (false);

      //Expiration
      x2 = x1+EXP_TXT_WIDTH;
      if(!edit_expiration.Create(m_chart_id, "txtexpiration", m_subwin, x1, y1, x2+30, y2)) return (false);
      if(!Add(edit_expiration)) return (false);
      edit_expiration.TextAlign(ALIGN_CENTER) ;
      edit_expiration.ReadOnly(true);
      
      x1 = x2+CONTROLS_GAP_X;
      x2 = ClientAreaWidth() - SPACE_RIGHT; 
      if(!combo_expiration.Create(m_chart_id, "cmbexpiration", m_subwin, x1+30, y1, x2, y2)) return (false);
      if(!Add(combo_expiration)) return (false);
      //combo_expiration.AddItem("2222/22/22 23:34:56");
      combo_expiration.SetReadOnly(true);
      
      
      //Investment
      //Text
      x1 = SPACE_LEFT+CONTROLS_GAP_X;
      x2 = x1+panel_operation.Width();
      y1 = y11;
      y2 = y11+LABEL_HEIGHT;//61
      if(!edit_volume.Create(m_chart_id, "txtvolume", m_subwin, 10, y1+10, 150, y2+10)) return (false);
      if(!Add(edit_volume)) return (false);
      edit_volume.TextAlign(ALIGN_CENTER);
      edit_volume.ReadOnly(true);

      y1 = y2+CONTROLS_GAP_X;//65
      y2 = y1+LABEL_HEIGHT; //90
      if(!combo_volume.Create(m_chart_id, "cmbvolume", m_subwin, 10, y1+10, 150, y2+10)) return (false);
      if(!Add(combo_volume)) return (false);
    
      //test 
      combo_volume.MaxValue(1000);
      combo_volume.MinValue(1);
      combo_volume.Decimals(0);
      combo_volume.Step(0);
      combo_volume.Value(10);
      
      //Buttons
      y1 = y2+CONTROLS_GAP_Y;
      y2 = y1+BTN_HEIGHT;
      x1 = x11+CONTROLS_GAP_X*2;
      x2 = x1+BTN_WIDTH;
      //--- button UP
      if(!buttonA.Create(m_chart_id, "btnA", m_subwin, 220, 140, 300, 170)) return (false);
      if(!Add(buttonA)) return (false);
      buttonA.FontSize(DEFAULT_FONTSIZE);
      buttonA.Locking(false);
      
      
      int y31 = y2 + CONTROLS_GAP_Y;
      //--- button down
      y2 = y22 - CONTROLS_GAP_Y;
      y1 = y2 - BTN_HEIGHT;
      CButton tmp;
      if(!buttonB.Create(m_chart_id, "btnB", m_subwin, 130, 140, 210, 170)) return (false);
      if(!Add(buttonB)) return (false);
      buttonB.FontSize(DEFAULT_FONTSIZE);
      buttonB.Locking(false);
      int y32 = y1 - CONTROLS_GAP_Y;
      
      //--- realtime quote
      if(!edit_symbol_price.Create(m_chart_id, "txtsymprice", m_subwin, 10, 140, 130, 170)) return (false);
      if(!Add(edit_symbol_price)) return (false);
      edit_symbol_price.Text("------");
      edit_symbol_price.FontSize(DEFAULT_FONTSIZE);
      edit_symbol_price.TextAlign(ALIGN_CENTER);
      edit_symbol_price.ReadOnly(true);
      
      //--- return
      x2 = ClientAreaWidth() - SPACE_RIGHT;
      x1 = x2 - panel_payoff.Width();
      y2 = y22 - CONTROLS_GAP_Y;
      y1 = y2 - BTN_HEIGHT;
      if(!edit_return.Create(m_chart_id, "txtreturn", m_subwin, 180, 75, 250, 100)) return (false);
      if(!Add(edit_return)) return (false);
      edit_return.TextAlign(ALIGN_CENTER);
      edit_return.Text("-------");
      edit_return.FontSize(DEFAULT_FONTSIZE);
      edit_return.ReadOnly(true);
      
      //Text return/payoff
      y2 = y1 - CONTROLS_GAP_Y;
      y1 = y2 - LABEL_HEIGHT;
      if(!edit_txtpayoff.Create(m_chart_id, "txtpayoff", m_subwin, 180, 46, 250, 71)) return (false);
      if(!Add(edit_txtpayoff)) return (false);
      edit_txtpayoff.TextAlign(ALIGN_CENTER);
      edit_txtpayoff.ReadOnly(true);
      
      
      //LV Payoff value
      y2 = y1 - CONTROLS_GAP_Y;
      y1 = y2 - BTN_HEIGHT;
      if(!edit_payoffl.Create(m_chart_id, "lvpayoffvalue", m_subwin, x1, 130, x2, 160)) return (false);
      if(!Add(edit_payoffl)) return (false);
      edit_payoffl.TextAlign(ALIGN_CENTER);
      edit_payoffl.ReadOnly(true);
      edit_payoffl.Text("");
      
      //Payoff value
      y2 = y1 - CONTROLS_GAP_Y;
      y1 = y11 + CONTROLS_GAP_Y;
      if(!edit_payoff.Create(m_chart_id, "payoffvalue", m_subwin, x1, 60, x2, y2+10)) return (false);
      if(!Add(edit_payoff)) return (false);
      edit_payoff.TextAlign(ALIGN_CENTER);
      edit_payoff.ReadOnly(true);
      edit_payoff.FontSize(PAYOFF_FONTSIZE);
      edit_payoff.Text("--%");
      //printf("  %d",y1);
      //product info
      y1 = ChartBottomY + UCHART_SPACE_BOTTOM + CONTROLS_GAP_Y;
      y2 = y1+STATUS_HEIGHT;
      x1 = 0;
      x2 = ClientAreaWidth();
      if(!edit_detail.Create(m_chart_id, "detailBar", m_subwin, x1, y1, x2, y2)) return (false);
      if(!Add(edit_detail)) return (false);
      edit_detail.TextAlign(ALIGN_LEFT);
      edit_detail.ReadOnly(true);
      edit_detail.Color(clrBlue);
      edit_detail.ColorBackground(clrLightGray);
      edit_detail.ColorBorder(BORDER_COLOR);
      edit_detail.FontSize(8);
      
      //openning position windows
      if(displayPositions) {
         showPosition = true;
         //ticket
         int k,j;         
         y1 = y2+3;
         y2 = y1+2 + LABEL_POSITION_HEIGHT;
         x1 = SPACE_LEFT;
         x2 = x1+PANEL_POS_TICKET_W-1;
         if(!open_ticket.Create(m_chart_id, "poopen_ticket", m_subwin, x1, y2, x2, y2+PANEL_POSITION_HEIGHT)) return (false);
         if(!Add(open_ticket)) return (false);
         if(!edit_openning[0][0].Create(m_chart_id, "editOp00", m_subwin, x1, y1, x2, y2)) return (false);
         for(k=1;k<5;k++){
            if(!edit_openning[k][0].Create(m_chart_id, "editOp"+k+"0", m_subwin, x1, y2+(k-1)*POSITION_LINE_H, x2, y2+k*POSITION_LINE_H)) return (false);
         }
         //Symbol
         x1 = x2+1;
         x2 = x1+PANEL_POS_SYMBOL_W-1;
         if(!open_symbol.Create(m_chart_id, "poopen_symbol", m_subwin, x1, y2, x2, y2+PANEL_POSITION_HEIGHT)) return (false);
         if(!Add(open_symbol)) return (false);
         if(!edit_openning[0][1].Create(m_chart_id, "editOp01", m_subwin, x1, y1, x2, y2)) return (false);
         for(k=1;k<5;k++){
            if(!edit_openning[k][1].Create(m_chart_id, "editOp"+k+"1", m_subwin, x1, y2+(k-1)*POSITION_LINE_H, x2, y2+k*POSITION_LINE_H)) return (false);
         }

         //Invest
         x1 = x2+1;
         x2 = x1+PANEL_POS_INVEST_W-1;
         if(!open_invest.Create(m_chart_id, "poopen_invest", m_subwin, x1, y2, x2, y2+PANEL_POSITION_HEIGHT)) return (false);
         if(!Add(open_invest)) return (false);
         if(!edit_openning[0][2].Create(m_chart_id, "editOp02", m_subwin, x1, y1, x2, y2)) return (false);
         for(k=1;k<5;k++){
            if(!edit_openning[k][2].Create(m_chart_id, "editOp"+k+"2", m_subwin, x1, y2+(k-1)*POSITION_LINE_H, x2, y2+k*POSITION_LINE_H)) return (false);
         }
         
         //Cmd
         x1 = x2+1;
         x2 = SPACE_LEFT+CHART_WIDTH+CONTROLS_GAP_X-1+40;
         if(!open_cmd.Create(m_chart_id, "poopen_cmd", m_subwin, x1, y2, x2, y2+PANEL_POSITION_HEIGHT)) return (false);
         if(!Add(open_cmd)) return (false);
         if(!edit_openning[0][3].Create(m_chart_id, "editOp03", m_subwin, x1, y1, x2, y2)) return (false);
         for(k=1;k<5;k++){
            if(!edit_openning[k][3].Create(m_chart_id, "editOp"+k+"3", m_subwin, x1, y2+(k-1)*POSITION_LINE_H, x2, y2+k*POSITION_LINE_H)) return (false);
         }
                 
         //return
         x1 = x2+1;
         x2 = ClientAreaWidth() - SPACE_RIGHT - panel_payoff.Width() - CONTROLS_GAP_X+160;
         if(!open_return.Create(m_chart_id, "poopen_return", m_subwin, x1, y2, x2, y2+PANEL_POSITION_HEIGHT)) return (false);
         if(!Add(open_return)) return (false);
         if(!edit_openning[0][4].Create(m_chart_id, "editOp04", m_subwin, x1, y1, x2, y2)) return (false);
         for(k=1;k<5;k++){
            if(!edit_openning[k][4].Create(m_chart_id, "editOp"+k+"4", m_subwin, x1, y2+(k-1)*POSITION_LINE_H, x2, y2+k*POSITION_LINE_H)) return (false);
         }
         
         //process
         x1 = x2+1;
         x2 = ClientAreaWidth() - SPACE_RIGHT - PANEL_POSITION_SCROLL;
         if(!open_process.Create(m_chart_id, "poopen_proc", m_subwin, x1, y2, x2, y2+PANEL_POSITION_HEIGHT)) return (false);
         if(!Add(open_process)) return (false);
         if(!edit_openning[0][5].Create(m_chart_id, "editOp05", m_subwin, x1, y1, x2, y2)) return (false);
         for(k=1;k<5;k++){
            if(!edit_openning[k][5].Create(m_chart_id, "editOp"+k+"5", m_subwin, x1, y2+(k-1)*POSITION_LINE_H, x2, y2+k*POSITION_LINE_H)) return (false);
         }
         
         //init all
         for(j=0;j<6;j++) {
            for(k=0;k<5;k++) {
               if(!Add(edit_openning[k][j])) return(false);
               edit_openning[k][j].ReadOnly(true);
               edit_openning[k][j].TextAlign(ALIGN_CENTER);
            }
         }
         
         //scroll
         x1 = x2;
         x2 = ClientAreaWidth() - SPACE_RIGHT;
         if(!openning_scroll.Create(m_chart_id, "poopen_Scroll", m_subwin, x1, y2, x2, y2+PANEL_POSITION_HEIGHT)) return (false);
         if(!Add(openning_scroll)) return (false);
         openning_scroll.MinPos(1);
         openning_scroll.MaxPos(4);
      }
      
      
      //Status Edit
      x1 = 0;
      y1 = ClientAreaHeight()-STATUS_HEIGHT; //ChartBottomY + UCHART_SPACE_BOTTOM + CONTROLS_GAP_Y+3;
      int offsetGap = CONTROLS_GAP_X / 2;
      x2 = x1 + SPACE_LEFT + CHART_WIDTH + CONTROLS_GAP_X+offsetGap;
      y2 = y1 + STATUS_HEIGHT;
      if(!edit_status.Create(m_chart_id, "editstatus", m_subwin, x1, y1, x2, y2)) return (false);
      if(!Add(edit_status)) return (false);
      edit_status.TextAlign(ALIGN_LEFT);
      edit_status.ReadOnly(true);
      edit_status.Text(STATUS_TEXT[language_idx][S_STATUS_INIT_PAD]);
      edit_status.FontSize(8);
      edit_status.Color(clrBlack);
      edit_status.ColorBackground(clrLightGray);
      edit_status.ColorBorder(BORDER_COLOR);
      
      x1 = x2;
      x2 = ClientAreaWidth();
      if(!edit_position.Create(m_chart_id, "editposition", m_subwin, x1, y1, x2, y2)) return (false);
      if(!Add(edit_position)) return (false);
      edit_position.TextAlign(ALIGN_CENTER);
      edit_position.ReadOnly(true);
      edit_position.Text("");
      edit_position.FontSize(8);
      edit_position.Color(clrBlack);
      edit_position.ColorBackground(clrLightGray);
      edit_position.ColorBorder(BORDER_COLOR);
   
      OutToPosition(0,0);   
      //Chart preparation

   }
    
   //Change the Settings
   Caption(DISPLAY_LANG[language_idx][S_PANEL_TITLE]);
   
   combo_symbol.SetFont(DISPLAY_LANG[language_idx][0]);
   

   
   edit_tradeType.Text(DISPLAY_LANG[language_idx][S_TRADETYPE]);
   edit_tradeType.Font(DISPLAY_LANG[language_idx][0]);
   edit_tradeType.ColorBackground(BACK_COLOR);
   edit_tradeType.ColorBorder(BACK_COLOR);
   edit_tradeType.Color(TEXT_COLOR);
      
   combo_tradeType.SetFont(DISPLAY_LANG[language_idx][0]);

   panel_operation.ColorBackground(OPERATE_PANEL_BG_COLOR);
   panel_operation.ColorBorder(OPERATE_PANEL_BG_COLOR);
      
   panel_payoff.ColorBackground(PAYOFF_PANEL_BG_COLOR);
   panel_payoff.ColorBorder(PAYOFF_PANEL_BG_COLOR);
      
   edit_expiration.Font(DISPLAY_LANG[language_idx][0]);
   edit_expiration.Text(DISPLAY_LANG[language_idx][S_EXPIRATION]);
   edit_expiration.ColorBackground(BACK_COLOR);
   edit_expiration.ColorBorder(BACK_COLOR);
   edit_expiration.Color(TEXT_COLOR);
      
   combo_expiration.SetFont(DISPLAY_LANG[language_idx][0]);
      
   edit_volume.Font(DISPLAY_LANG[language_idx][0]);
   edit_volume.Text(DISPLAY_LANG[language_idx][S_VOLUME]);
   edit_volume.ColorBackground(OPERATE_PANEL_BG_COLOR);
   edit_volume.ColorBorder(OPERATE_PANEL_BG_COLOR);
   edit_volume.Color(OPERATE_PANEL_COLOR);
      
   combo_volume.SetFont(DISPLAY_LANG[language_idx][0]);
      
   buttonA.Font(DISPLAY_LANG[language_idx][0]);
   buttonA.Text(DISPLAY_LANG[language_idx][S_BUTTON_CALL]);
   buttonA.ColorBackground(BUTTON_UP_COLOR);
  
      
   buttonB.Font(DISPLAY_LANG[language_idx][0]);
   buttonB.Text(DISPLAY_LANG[language_idx][S_BUTTON_PUT]);
   buttonB.ColorBackground(BUTTON_DOWN_COLOR);
      
   edit_symbol_price.Font(DISPLAY_LANG[language_idx][0]);
   edit_symbol_price.Color(PRICE_COLOR);
   edit_symbol_price.ColorBackground(OPERATE_PANEL_BG_COLOR);
   edit_symbol_price.ColorBorder(OPERATE_PANEL_BG_COLOR);
      
   edit_return.Font(DISPLAY_LANG[language_idx][0]);
   edit_return.ColorBackground(PAYOFF_PANEL_BG_COLOR);
   edit_return.ColorBorder(PAYOFF_PANEL_BG_COLOR);
   edit_return.Color(PAYOFF_COLOR);
      
   edit_txtpayoff.Font(DISPLAY_LANG[language_idx][0]);
   edit_txtpayoff.Text(DISPLAY_LANG[language_idx][S_PAYOFF]);
   edit_txtpayoff.ColorBackground(PAYOFF_PANEL_BG_COLOR);
   edit_txtpayoff.ColorBorder(PAYOFF_PANEL_BG_COLOR);
   edit_txtpayoff.Color(PAYOFF_PANEL_COLOR);
   
   edit_payoff.Font(DISPLAY_LANG[language_idx][0]);
   edit_payoff.ColorBackground(PAYOFF_PANEL_BG_COLOR);
   edit_payoff.ColorBorder(PAYOFF_PANEL_BG_COLOR);
   edit_payoff.Color(PAYOFF_COLOR);
   
   //*
   edit_payoffl.Font(DISPLAY_LANG[language_idx][0]);
   edit_payoffl.ColorBackground(PAYOFF_PANEL_BG_COLOR);
   edit_payoffl.ColorBorder(PAYOFF_PANEL_BG_COLOR);
   edit_payoffl.Color(PAYOFF_COLOR);
   //*/
   
   //position
   open_ticket.ColorBackground(POSITION_BACK_COLOR);
   open_ticket.ColorBorder(POSITION_BACK_COLOR);
   //Symbol
   open_symbol.ColorBackground(POSITION_BACK_COLOR);
   open_symbol.ColorBorder(POSITION_BACK_COLOR);
   //Invest
   open_invest.ColorBackground(POSITION_BACK_COLOR);
   open_invest.ColorBorder(POSITION_BACK_COLOR);
   //Cmd
   open_cmd.ColorBackground(POSITION_BACK_COLOR);
   open_cmd.ColorBorder(POSITION_BACK_COLOR);
   //return
   open_return.ColorBackground(POSITION_BACK_COLOR);
   open_return.ColorBorder(POSITION_BACK_COLOR);
   //process
   open_process.ColorBackground(POSITION_BACK_COLOR);
   open_process.ColorBorder(POSITION_BACK_COLOR);

   //type
   if(tradeType>0) {
      long sval = combo_tradeType.Value();
      int idx = combo_tradeType.Current();
      combo_tradeType.ItemUpdate(idx, DISPLAY_LANG[language_idx][sval+TTEXT_OFFSET], sval);
      combo_tradeType.Select(idx);
   }
   //text
   int k;
   for(k=0;k<6;k++) {
      edit_openning[0][k].ColorBackground(BACK_COLOR);
      edit_openning[0][k].ColorBorder(BACK_COLOR);
      edit_openning[0][k].Color(TEXT_COLOR);
      edit_openning[0][k].Text(DISPLAY_LANG[language_idx][S_POS_TICKET+k]);      
   }
   for(k=0;k<4;k++) {
      PriceLabel[k].ColorBackground(BACK_COLOR);
      PriceLabel[k].ColorBorder(BACK_COLOR);
      PriceLabel[k].Color(TEXT_COLOR);
   }
   //detail
   if(symbolSelected=="")
      edit_detail.Text(DISPLAY_LANG[language_idx][S_PRODUCT_DETAIL]);
   else {
      int bidx = 1;//(show1)?1:0;
      string out = DISPLAY_LANG[language_idx][S_PRODUCT_DETAIL] + DISPLAY_LANG[language_idx][S_VOLUME]+" : " + DISPLAY_LANG[language_idx][S_VOL_MIN] + "=" +cur_config.MinVols[bidx] + "; "
         + DISPLAY_LANG[language_idx][S_VOL_MAX] + "=" + cur_config.MaxVols[bidx] + "; " 
         + DISPLAY_LANG[language_idx][S_VOL_STEP] + "=" + cur_config.StepVols[bidx];
      
      edit_detail.Text(out);
   }
   //this.ColorUpdate();
   //ReDrawChart();
   StringReplace(accountname,login,"");
   //printf("[%s]  , %d",accountname,login);
   return true;
}
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
bool CMTKTradePadDialog::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
{
   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2)) {
      Print(ERROR_TEXT[language_idx][ERR_PANEL_LOAD_FAIL]);
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
bool CMTKTradePadDialog::tradeCheck(const int _type) {
   if(IsTradeContextBusy()) {
      //MessageBox(ERROR_TEXT[language_idx][ERR_TRADE_BUSY], DISPLAY_LANG[language_idx][S_MESSAGE_CAPTION], MB_ICONSTOP);
      OutToStatus(ERROR_TEXT[language_idx][ERR_TRADE_BUSY], clrRed);
      return false;
   }
   if(!IsTradeAllowed() || !IsExpertEnabled() || !IsConnected()) {
      //MessageBox(ERROR_TEXT[language_idx][ERR_TRADE_NOTRADE], DISPLAY_LANG[language_idx][S_MESSAGE_CAPTION], MB_ICONSTOP);
      OutToStatus(ERROR_TEXT[language_idx][ERR_TRADE_NOTRADE], clrRed);
      return false;
   }
   double vol = combo_volume.Value();
   if(vol>cur_config.MaxVols[_type] || vol<cur_config.MinVols[_type]) {
      //MessageBox(ERROR_TEXT[language_idx][ERR_TRADE_VOLUME], DISPLAY_LANG[language_idx][S_MESSAGE_CAPTION], MB_ICONSTOP);
      OutToStatus(ERROR_TEXT[language_idx][ERR_TRADE_VOLUME], clrRed);
      return false;
   }
   double fmargin = AccountFreeMargin();
   if(vol>fmargin) {
      //MessageBox(ERROR_TEXT[language_idx][ERR_TRADE_VOLUME], DISPLAY_LANG[language_idx][S_MESSAGE_CAPTION], MB_ICONSTOP);
      OutToStatus(ERROR_TEXT[language_idx][ERR_TRADE_NO_MONEY], clrRed);
      return false;
   }
   return true;
}
void CMTKTradePadDialog::OnClickButtonA(void) {

   if(!tradeCheck(1)) return;
   int ct = tradeType;
   string stype;
   if(ct==UP_DOWN)
      stype = "UP";
   else if(ct == BIG_SMALL)
      stype = "BIG";
   else if(ct == ODD_EVEN)
      stype = "ODD";
   else if(ct == RANGE)
      stype = "IN";
   else {

      OutToStatus(STATUS_TEXT[language_idx][S_STATUS_BO_INVALID_TYPE], clrRed);
      return;
   }

   if(needConfirm) {
      string msg = DISPLAY_LANG[language_idx][S_CONFIRM_ORDER] 
         + "    " + DoubleToString(combo_volume.Value(),2) + " " + symbolSelected + "[" + buttonA.Text() + "] "+ DISPLAY_LANG[language_idx][S_WITH_EXP_OF] + Exp_Sec2Str(tradeExpiration, false) + "\r\n"
         + "    " + DISPLAY_LANG[language_idx][S_PAYOFF] + " : " + DoubleToString(cur_config.Payoff[1]*100, 1) + "% ==> " + DoubleToString(cur_config.Payoff[1]*combo_volume.Value(),2) + "\r\n";
      int msg_ret = MessageBox(msg, DISPLAY_LANG[language_idx][S_MESSAGE_CAPTION], MB_YESNO + MB_ICONINFORMATION);
      if( msg_ret == IDNO) {
         OutToStatus(STATUS_TEXT[language_idx][S_STATUS_BO_ORDERCANCEL]);
         return;
      }
   }


   string cmt = "[" + stype + "]/" + combo_expiration.Select() + "/" + DoubleToString(cur_config.Payoff[1], 3);

   //printf("cmt=%s",cmt);
   
   tradeSignal = true;


   int mn = CalcMagicNumber(symbolSelected, combo_expiration.Value(), combo_volume.Value(), OP_BUY, DayOfYear());
   OutToStatus(StringConcatenate(STATUS_TEXT[language_idx][S_STATUS_BO_SENDORDER], cmt, ", ", STATUS_TEXT[language_idx][S_STATUS_BO_WAITING]));
   int order = OrderSend(symbolSelected, OP_BUY, combo_volume.Value(), SymbolInfoDouble(symbolSelected, SYMBOL_BID), 1, 0, 0, cmt, mn);
   int _err = GetLastError();
   if(_err == 0) 
      OutToStatus(StringConcatenate(STATUS_TEXT[language_idx][S_STATUS_BO_ORDEROK], IntegerToString(order)));
   else 
      OutToStatus(StringConcatenate(STATUS_TEXT[language_idx][S_STATUS_BO_ORDERKO], ErrorDescription(_err)), clrRed);
   tradeSignal = false;
  // Sleep(5);
}
int CMTKTradePadDialog::CalcMagicNumber(string _symbol, const int _expi, const int _invest, const int _cmd, const int _dayOfYear) {
	int ret = 0;
	if(mt4login<=0) return ret;
	if(_symbol==NULL) return ret;

	//ret = (((mt4login % _expi) % 1000) * 1000 + _invest + _cmd * 100 + _symbol[0]*10 + _symbol[1]) * 1000 + _dayOfYear;
	ret = (((mt4login % _expi) % 1000) * 1000 + _invest + _cmd * 100  ) * 1000 + _dayOfYear;
	printf("ret= %d",ret);
	return ret;
}
void CMTKTradePadDialog::OnClickButtonB(void) {
   if(!tradeCheck(0)) return;
   int ct = tradeType;
   string stype;
   if(ct==UP_DOWN)
      stype = "DOWN";
   else if(ct == BIG_SMALL)
      stype = "SMALL";
   else if(ct == ODD_EVEN)
      stype = "EVEN";
   else if(ct == RANGE)
      stype = "OUT";
   else {
      OutToStatus(STATUS_TEXT[language_idx][S_STATUS_BO_INVALID_TYPE], clrRed);
      return;
   }
   if(needConfirm) {
      string msg = DISPLAY_LANG[language_idx][S_CONFIRM_ORDER] 
         + "    " + DoubleToString(combo_volume.Value(),2) + " " + symbolSelected + "[" + buttonB.Text() + "] "+ DISPLAY_LANG[language_idx][S_WITH_EXP_OF] + Exp_Sec2Str(tradeExpiration, false) + "\r\n"
         + "    " + DISPLAY_LANG[language_idx][S_PAYOFF] + " : " + DoubleToString(cur_config.Payoff[0]*100, 1) + "% ==> " + DoubleToString(cur_config.Payoff[0]*combo_volume.Value(),2) + "\r\n";
      int msg_ret = MessageBox(msg, DISPLAY_LANG[language_idx][S_MESSAGE_CAPTION], MB_YESNO + MB_ICONINFORMATION);
      if(msg_ret == IDNO) {
         OutToStatus(STATUS_TEXT[language_idx][S_STATUS_BO_ORDERCANCEL]);
         return;
      }      
   }
//   string cmt = "[" + stype + "]/" + Exp_Sec2Str(tradeExpiration) + "/" + DoubleToString(Payoff[0], 3);
   string cmt = "[" + stype + "]/" + combo_expiration.Select() + "/" + DoubleToString(cur_config.Payoff[0], 3);   
   tradeSignal = true;
   int mn = CalcMagicNumber(symbolSelected, combo_expiration.Value(), combo_volume.Value(), OP_BUY, DayOfYear());
   OutToStatus(StringConcatenate(STATUS_TEXT[language_idx][S_STATUS_BO_SENDORDER], cmt, ", ", STATUS_TEXT[language_idx][S_STATUS_BO_WAITING]));
   int order = OrderSend(symbolSelected, OP_SELL, combo_volume.Value(), SymbolInfoDouble(symbolSelected, SYMBOL_ASK), 1, 0, 0, cmt, mn);
   int _err = GetLastError();
   if(_err == 0) 
      OutToStatus(StringConcatenate(STATUS_TEXT[language_idx][S_STATUS_BO_ORDEROK], IntegerToString(order)));
   else 
      OutToStatus(StringConcatenate(STATUS_TEXT[language_idx][S_STATUS_BO_ORDERKO], ErrorDescription(_err)), clrRed);
   tradeSignal = false;
   //Sleep(5);   
}
int CMTKTradePadDialog::Sqlquery(){
//--- 6. How to get data from table
   if(sql3.Query(tbl,"SELECT * FROM `mtk_bo_symbols`")!=SQLITE_DONE)
     {
      Print(sql3.ErrorMsg());
      return INIT_FAILED;
     }
   Print(SymbolTablePrint(tbl)); // printed in Experts log
   return(INIT_SUCCEEDED);   
 }
bool CMTKTradePadDialog::SymbolTablePrint(CSQLite3Table &tbl)
  {
  int c;
   int rs=ArraySize(tbl.m_data);
   int recordcs=rs;   
   for(int r=0; r<rs; r++)
     {
      CSQLite3Row *row=tbl.Row(r);
      if(CheckPointer(row))
        {
         //str+="-e\n";
         //continue;
        }
      int cs=ArraySize(row.m_data);
      //for( c=0; c<cs; c++){
         symbols[r]=row.m_data[0].GetString();
        // printf(" %s    %d",row.m_data[c].GetString(),rs);
      //}
     }

   combo_symbol.ItemsClear();

   string chartSymbol = Symbol();
   special_config.symbol=chartSymbol;
   printf("% s",chartSymbol);
   int selectID = -1;
   int used = 0;
   string symbol;
   string curSymbol;
   for(int ic=0;ic<recordcs;ic++) {
     if(StringCompare(symbols[ic], chartSymbol)==0) { //(SymbolInfoInteger(symbols[ic], SYMBOL_SELECT)!=1) {
         //printf("Symbol[%s] not available in the Market Watch, ignored", symbols[ic]);
         
         combo_symbol.AddItem(symbols[ic], 0);
         selectID=0;
      }    

  }    
   if(selectID==-1) return false;//not find the correct symbol
   
   symbolSelected =chartSymbol;
   combo_symbol.Select(0);
   cur_config.symbol=chartSymbol;
/*
*/
   return reloadType(chartSymbol);
}

bool CMTKTradePadDialog::reloadSymbol(void){
   PriceDigits = MarketInfo(symbolSelected, MODE_DIGITS);
   if(sql3.Query(tbl,"select symbol from mtk_bo_expirations where period not null and enabled='1' group by symbol ")!=SQLITE_DONE)
     {
      Print(sql3.ErrorMsg());
      return INIT_FAILED;
     }
   SymbolTablePrint(tbl); // printed in Experts log
   return(INIT_SUCCEEDED);  
}

bool CMTKTradePadDialog::reloadType(string symbol){
   int TypeList=0;
   int ret;
   int selectID=0;
   combo_tradeType.ItemsClear();
   string sqlQuery="select play_mode from (select symbol ,play_mode from mtk_bo_expirations where period not null and enabled='1' group by symbol,play_mode) where symbol='"+symbol + "'";
   if(sql3.Query(tbl,sqlQuery)!=SQLITE_DONE)
     {
      Print(sql3.ErrorMsg());
      return INIT_FAILED;
     } 

   int cs=ArraySize(tbl.m_colname);
   int rs=ArraySize(tbl.m_data);
   int recordcs=rs;  
   //printf("  %s" ,sqlQuery );    
   for(int r=0; r<rs; r++)
     {
      CSQLite3Row *row=tbl.Row(r);
      cs=ArraySize(row.m_data);
      playtype[r]=row.m_data[0].GetString();
      //printf("  %s" ,type[r] );
     }
      if(recordcs>0) 
      {
         for(int ic=0;ic<recordcs;ic++) {
            if(!combo_tradeType.ItemAdd(playtype[ic],TypeList)) continue;
            TypeList++;
             
         }
      
      }
      else
       tradeType = -1;
       combo_tradeType.Select(0); 
       special_config.play_mode= combo_tradeType.Select(); 
       cur_config.play_mode=combo_tradeType.Select(); 
       tradeType = 0;
   return reloadExp();
}
bool CMTKTradePadDialog::reloadExp(void) {

   int selectID=0;
   combo_expiration.ItemsClear();
   if(tradeType<0 || StringTrimRight(symbolSelected)=="") {
      tradeExpiration = 0;
      return false;
   }
  
  if(sql3.Query(tbl,"select  period from (select symbol ,period from mtk_bo_expirations where period not null and enabled='1' group by symbol,period) where symbol='"+symbolSelected + "'")!=SQLITE_DONE)
     {
      Print(sql3.ErrorMsg());
      return INIT_FAILED;
     } 

   int cs;
   int rs=ArraySize(tbl.m_data);
   int recordcs=rs;   
   for(int r=0; r<rs; r++)
     {
      CSQLite3Row *row=tbl.Row(r);
      cs=ArraySize(row.m_data);
      ExpiList[r]=row.m_data[0].GetString();
     }
      if(recordcs>0) {
         for(int ic=0;ic<recordcs;ic++) {
            if(!combo_expiration.ItemAdd(ExpiList[ic],ic)) continue;

         }
        
         combo_expiration.Select(selectID);
         tradeExpiration = 0;
         special_config.expiration=combo_expiration.Select();
         cur_config.expiration=combo_expiration.Select();
         OnChangeComboExpiration();
         
      }

        
   return true;
}
bool CMTKTradePadDialog::TimeSections(void){
   string sql="select  payoff_ratio,payoff_lv_ratio,single_order_limit,group_open_investment_limit,group_open_order_num_limit,login_open_investment_limit,login_open_order_num_limit from mtk_bo_time_sections where ";
    sql+=" enabled=1 and period="+special_config.expiration+" and symbol='"+special_config.symbol + "' and play_mode='" +special_config.play_mode + "'and prohibited=0 and time_section_mode='" + special_config.time_section_mode + "' and ltrim(time_section_begin,'time=') <time('now','Localtime') and ltrim(time_section_end,'time=') > time('now','Localtime') ";
   //需要过夜时间段处理
   if(sql3.Query(tbl,sql)!=SQLITE_DONE)
     {
      Print(sql3.ErrorMsg());
      return INIT_FAILED;
     } 
   string RecordData[20];
   int cs,c;
   int rs=ArraySize(tbl.m_data);
   int recordcs=rs; 
   for(int r=0; r<rs; r++){
      CSQLite3Row *row=tbl.Row(r);
      cs=ArraySize(row.m_data);
      for( c=0; c<cs; c++){
         RecordData[c]=row.m_data[c].GetString();
         //printf(" %s    %d",row.m_data[c].GetString(),cs);
      }      
     }
    if(recordcs==1){// special time
      special_config.pay_off= RecordData[0];   
      special_config.payoff_lv= RecordData[1]; 
      special_config.single_order_limit= RecordData[2];
      special_config.group_open_investment_limit= RecordData[3];
      special_config.group_open_order_num_limit =RecordData[4];
      special_config.login_open_investment_limit= RecordData[5];
      special_config.login_open_order_num_limit= RecordData[6]; 
      
      cur_config.pay_off=normal_config.pay_off * special_config.pay_off;
      cur_config.payoff_lv=normal_config.payoff_lv*special_config.payoff_lv ;  
      
      cur_config.Payoff[0]=normal_config.Payoff[0]* special_config.pay_off;
      cur_config.LvPayoff[0]=normal_config.Payoff[0]*special_config.payoff_lv ;
      cur_config.Payoff[1]=normal_config.Payoff[1]* special_config.pay_off;
      cur_config.LvPayoff[1]=normal_config.Payoff[1]*special_config.payoff_lv ;
      
/*    cur_config.MaxVols[0]=normal_config.Payoff[0]
      cur_config.MinVols[0]=normal_config.Payoff[0]
      cur_config.StepVols[0]=normal_config.Payoff[0]
      cur_config.PriceMode[0]=normal_config.Payoff[0]
      cur_config.PriceOffset[0]=normal_config.Payoff[0]*/
   	return true;    
    
    }
    else
    {
      special_config.pay_off=0;   
      special_config.payoff_lv= 0; 
      special_config.single_order_limit= 0;
      special_config.group_open_investment_limit=0;
      special_config.group_open_order_num_limit =0;
      special_config.login_open_investment_limit= 0;
      special_config.login_open_order_num_limit= 0; 
      
      cur_config.pay_off=normal_config.pay_off;
      cur_config.payoff_lv=normal_config.payoff_lv;
      
      cur_config.Payoff[0]=normal_config.Payoff[0];
      cur_config.LvPayoff[0]=normal_config.Payoff[0] ;
      cur_config.Payoff[1]=normal_config.Payoff[1];
      cur_config.LvPayoff[1]=normal_config.Payoff[1] ;             
   	return false;    
 
    } 

}
   
bool CMTKTradePadDialog::TimeSectionsEnabled(void){
   string sql="select  payoff_ratio,payoff_lv_ratio,single_order_limit,group_open_investment_limit,group_open_order_num_limit,login_open_investment_limit,login_open_order_num_limit from mtk_bo_time_sections where ";
   sql+=" enabled=1 and period="+special_config.expiration+" and symbol='"+special_config.symbol + "' and play_mode='" +special_config.play_mode + "' and prohibited=1 and time_section_mode='" + special_config.time_section_mode + "' and ltrim(time_section_begin,'time=') <time('now','Localtime') and ltrim(time_section_end,'time=') > time('now','Localtime') ";
   //printf(" %s",sql);
  if(sql3.Query(tbl,sql)!=SQLITE_DONE)
     {
      Print(sql3.ErrorMsg());
      return INIT_FAILED;
     } 
   string RecordData[20];
   int cs;
   int rs=ArraySize(tbl.m_data);
   int recordcs=rs;   
   for(int r=0; r<rs; r++)
     {
      CSQLite3Row *row=tbl.Row(r);
      cs=ArraySize(row.m_data);
      RecordData[r]=row.m_data[0].GetString();
     }
    if(recordcs>0){// special time
          

   	return true;    
    
    }
    else
    {
   	return false;    
 
    } 

}
void CMTKTradePadDialog::OnChangeComboSymbol(void)
{
/*   if(StringCompare(symbolSelected,combo_symbol.Select())==0) return;
   symbolSelected = combo_symbol.Select();
   PriceDigits = MarketInfo(symbolSelected, MODE_DIGITS);
   //tradeType = -1;
   reloadType(symbolSelected);
   ReDrawChart();*/
}
void CMTKTradePadDialog::OnChangeComboPeriod(void)
{
//   periodSelected = StrToInteger(StringSubstr(combo_period.Select(),1));
//   ReDrawChart();
}
void CMTKTradePadDialog::OnChangeComboVolume(void){
   CalculateReturn(0);
}
void CMTKTradePadDialog::OnChangeComboExpiration(void) {
   if(StringTrimRight(symbolSelected)=="") return;
   int ret;
   for(ret=0;ret<2;ret++) {
         normal_config.Payoff[ret] = 0;
         normal_config.LvPayoff[ret]=0;
         normal_config.PriceMode[ret]=0;
         normal_config.MaxVols[ret]=0;
         normal_config.MinVols[ret]=0;
         normal_config.StepVols[ret]=0;
      }
    tradeExpiration = combo_expiration.Value();
    if(tradeExpiration==-1) return;
    //printf("tradeExpiration%d",tradeExpiration);
    string sqlquery="select payoff_win,payoff_lv,price_mode,invest_max,invest_min,invest_step from mtk_bo_expirations where ";
    sqlquery+="period ='"+ExpiList[tradeExpiration] +"'";  
    sqlquery+=" and symbol ='"+symbolSelected +"'"; 
    sqlquery+=" and play_mode ='"+playtype[tradeType] +"'";
    //printf(" %s ", sqlquery);
    if(sql3.Query(tbl,sqlquery)!=SQLITE_DONE)
     {
      Print(sql3.ErrorMsg());
      return ;
     }     
   int c,cs,count=0;
   string temps[20];
   int rs=ArraySize(tbl.m_data);
   for(int r=0; r<rs; r++)
     {
      CSQLite3Row *row=tbl.Row(r);
      cs=ArraySize(row.m_data);
      for( c=0; c<cs; c++){
         temps[count]=row.m_data[c].GetString();
         //printf(" %s    %d",row.m_data[c].GetString(),rs);
         count++;
      }
     }
      //always have two record rows
      //price mode
      int pm1,pm2;     
      if(StringCompare(temps[2],"ask",false)==0)pm1=1;
      else if(StringCompare(temps[2],"bid",false)==0) pm1=2;
      else if(StringCompare(temps[2],"middle",false)==0) pm1=3;
      
      if(StringCompare(temps[8],"ask",false)==0) pm2=1;
      else if(StringCompare(temps[8],"bid",false)==0) pm2=2;
      else if(StringCompare(temps[8],"middle",false)==0) pm2=3;
      
      normal_config.Payoff[0] = temps[0];
      normal_config.LvPayoff[0]=temps[1];
      cur_config.PriceMode[0]=normal_config.PriceMode[0]=pm1;
      cur_config.MaxVols[0]=normal_config.MaxVols[0]=temps[3];
      cur_config.MinVols[0]=normal_config.MinVols[0]=temps[4];
      cur_config.StepVols[0]=normal_config.StepVols[0]=temps[5];
      
      cur_config.Payoff[1] = temps[6];
      cur_config.LvPayoff[1]=temps[7];
      cur_config.PriceMode[1]=normal_config.PriceMode[1]=pm2;
      cur_config.MaxVols[1]=normal_config.MaxVols[1]=temps[9];
      cur_config.MinVols[1]=normal_config.MinVols[1]=temps[10];
      cur_config.StepVols[1]=normal_config.StepVols[1]=temps[11];
      
      //--- other info
      double maxVol = MathMax(normal_config.MaxVols[0], normal_config.MaxVols[1]); 
      double minVol = MathMin(normal_config.MinVols[0], normal_config.MinVols[1]);
      double stepVol = MathMax(normal_config.StepVols[0], normal_config.StepVols[1]);
      double val =  combo_volume.Value();
      
      edit_payoff.Text(DoubleToString(normal_config.Payoff[0]*100, 1)+"%");
      double pfl = normal_config.LvPayoff[0];
      if(pfl>=0) 
         edit_payoffl.Text(DISPLAY_LANG[language_idx][S_PAYOFFLV]+" : "+DoubleToString(pfl*100, 1)+"%");
      else
         edit_payoffl.Text("");
      
      //printf("%s,%d ==> %f|%f, %d|%d=%d|%d=>%d|%d", symbolSelected, tradeExpiration, LvPayoff[0], LvPayoff[1], MinVols[0], MinVols[1], StepVols[0], StepVols[1], MaxVols[0], MaxVols[1]);
      
      //string btxt = (show1)?buttonA.Text():buttonB.Text();
      int bidx = 1; //(show1)?1:0;
      string out = DISPLAY_LANG[language_idx][S_PRODUCT_DETAIL] + DISPLAY_LANG[language_idx][S_VOLUME]+" : " + DISPLAY_LANG[language_idx][S_VOL_MIN] + "=" + normal_config.MinVols[bidx] + "; "
         + DISPLAY_LANG[language_idx][S_VOL_MAX] + "=" + normal_config.MaxVols[bidx] + "; " 
         + DISPLAY_LANG[language_idx][S_VOL_STEP] + "=" + normal_config.StepVols[bidx];
      
      edit_detail.Text(out);
      /*if(show1)
         show1 = false;
      else
         show1 = true;
      */

    combo_volume.SetValues(minVol, maxVol, stepVol, val);
    
    TimeSections();//check the special mode
    special_config.expiration=combo_expiration.Select();
    CalculateReturn(0);
}
void CMTKTradePadDialog::OnChangeComboTradeType(void) {
   if(StringTrimRight(symbolSelected)=="") return;
   if(tradeType == combo_tradeType.Value()) return;
   tradeType = combo_tradeType.Value();
   reloadExp();
}
void CMTKTradePadDialog::OnClickLogo(void)
{
   MessageBox(DISPLAY_LANG[language_idx][S_ABOUT], DISPLAY_LANG[language_idx][S_CAPTION_ABOUT], MB_ICONINFORMATION);
}

void CMTKTradePadDialog::ReDrawChart(void) {
}

void CMTKTradePadDialog::CalculateReturn(int which){
   if(StringTrimRight(symbolSelected)=="") return;
   edit_return.Text(DoubleToStr(combo_volume.Value()*cur_config.Payoff[which],2));
}

string CMTKTradePadDialog::Exp_Sec2Str(const int _exp, const bool isShort) {
   if(_exp==0) return (isShort)?"0s":"0 SEC";
      
   int hh = 0;
   int mm = 0;
   int ss = 0;
   int val = _exp;
   hh = MathFloor(val / 3600);
   val -= hh*3600;
   mm = MathFloor(val / 60);
   val -= mm*60;
   ss = val;
   if (isShort)
      return ((hh==0)?"":IntegerToString(hh)+"h")+((mm==0)?"":IntegerToString(mm)+"m")+((ss==0)?"":IntegerToString(ss)+"s");
   //Long format
   return ((hh==0)?"":IntegerToString(hh)+" HOUR")+((mm==0)?"":IntegerToString(mm)+" MIN")+((ss==0)?"":IntegerToString(ss)+" SEC");
}
int CMTKTradePadDialog::Exp_Str2Sec(string _exp) {
   if(_exp=="") return 0; 
   int hh = 0;
   int mm = 0;
   int ss = 0;
   int pos = StringFind(_exp, "h", 0);
   int pos_end = 0;
   int sl = 1;
   if(pos<0) {
      pos = StringFind(_exp, " HOUR", 0);
      sl = 5;
   }   
   if(pos>=0) {
      hh = StrToInteger(StringSubstr(_exp, 0, pos));
      pos_end = pos+sl;      
   }
   
   pos = StringFind(_exp, "m", pos_end);
   sl = 1;
   if(pos<0) {
      pos = StringFind(_exp, " MIN", pos_end);
      sl = 4;
   }   
   if(pos>=0) {
      mm = StrToInteger(StringSubstr(_exp, pos_end, pos-pos_end));
      pos_end = pos+sl;      
   }
   
   pos = StringFind(_exp, "s", pos_end);
   sl = 1;
   if(pos<0) {
      pos = StringFind(_exp, " SEC", pos_end);
      sl = 4;
   }   
   if(pos>=0) {
      ss = StrToInteger(StringSubstr(_exp, pos_end, pos-pos_end));
   }
   return hh*3600+mm*60+ss;  
   
}
void CMTKTradePadDialog::RefreshPositions(void) {
   //return;
   int total=OrdersTotal();
   int total_bo = 0;
   double total_invest = 0;
   openning_total = 0;
   string symbol;
   for(int pos=0;pos<total;pos++) {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      symbol = OrderSymbol();
      if(!StringToLower(symbol)) continue;
      if(StringFind(symbol, SYMBOL_POSTFIX) != StringLen(symbol)-StringLen(SYMBOL_POSTFIX)) continue;
      if(OrderType()>OP_SELL) continue;
      InsertOrder(OrderTicket());
      total_bo++;
      total_invest+=OrderLots();
   }
   OutToPosition(total_bo,total_invest);
   if(!showPosition) return;
   openning_scroll.MinPos(1);
   if(total_bo>0) 
      openning_scroll.MaxPos(total_bo);
   else
      openning_scroll.MaxPos(1);
   
   //refresh here
   int cp = openning_scroll.CurrPos();
   if(cp<1) cp=1;
   ShowOrdersFromPosition(cp-1, 4);
}

void CMTKTradePadDialog::InsertOrder(const int ticket) {
   int i;
   for(i=0;i<openning_total;i++) {
      if(ticket==openning[i].ticket) return;
   }
   int pos;
   if(openning_total>=openning_max) {
      if(ArrayResize(openning, openning_max+POSITIONS_STEP)<0) return;
      openning_max+=POSITIONS_STEP;      
   }
   //fill the openning[openning_total]
   if(!OrderSelect(ticket, SELECT_BY_TICKET)) return;
   openning[openning_total].ticket = OrderTicket();
   openning[openning_total].investment = OrderLots();
   openning[openning_total].open_time = OrderOpenTime();
   openning[openning_total].symbol = OrderSymbol();
   openning[openning_total].close_price = OrderClosePrice();
   openning[openning_total].open_price = OrderOpenPrice();
   
   string cmt = OrderComment();

   string arrcfg[];
   if(StringSplit(cmt, SEP_CMT, arrcfg)<3) return;
   if(StringFind(arrcfg[0], "UP") >= 0) {
      openning[openning_total].cmd = CMD_Call;
      openning[openning_total].typeID = S_BUTTON_CALL;
      openning[openning_total].type = UP_DOWN;
   }
   else if(StringFind(arrcfg[0], "DOWN") >= 0) {
      openning[openning_total].cmd = CMD_Put;
      openning[openning_total].typeID = S_BUTTON_PUT;
      openning[openning_total].type = UP_DOWN;
   }
   else if(StringFind(arrcfg[0], "BIG") >= 0) {
      openning[openning_total].cmd = CMD_Big;
      openning[openning_total].typeID = S_BUTTON_BIG;
      openning[openning_total].type = BIG_SMALL;
   }
   else if(StringFind(arrcfg[0], "SMALL") >= 0) {
      openning[openning_total].cmd = CMD_Small;
      openning[openning_total].typeID = S_BUTTON_SMALL;
      openning[openning_total].type = BIG_SMALL;
   }
   else if(StringFind(arrcfg[0], "EVEN") >= 0) {
      openning[openning_total].cmd = CMD_Even;
      openning[openning_total].typeID = S_BUTTON_EVEN;
      openning[openning_total].type = ODD_EVEN;
   }
   else if(StringFind(arrcfg[0], "ODD") >= 0) {
      openning[openning_total].cmd = CMD_Odd;
      openning[openning_total].typeID = S_BUTTON_ODD;
      openning[openning_total].type = ODD_EVEN;
   }
   else if(StringFind(arrcfg[0], "OUT") >= 0) {
      openning[openning_total].cmd = CMD_RangeOut;
      openning[openning_total].typeID = S_BUTTON_RANGE_OUT;
      openning[openning_total].type = RANGE;
   }
   else if(StringFind(arrcfg[0], "IN") >= 0) {
      openning[openning_total].cmd = CMD_RangeIn;
      openning[openning_total].typeID = S_BUTTON_RANGE_IN;
      openning[openning_total].type = RANGE;
   }
   else
      return;
   // printf("cmt= %s ,%d",cmt,openning[openning_total].type);  
   openning[openning_total].payoff = StringToDouble(arrcfg[2]);
   openning[openning_total].expiration = arrcfg[1];
   openning[openning_total].exp_sec = Exp_Str2Sec(arrcfg[1]);
   openning[openning_total].price_mode =   PMODE_MIDDLE;// Dll_GetPriceMode(OrderSymbol(), openning[openning_total].cmd, openning[openning_total].exp_sec);

   openning_total++;   
}
void CMTKTradePadDialog::ShowOrdersFromPosition(const int pos, const int orderCount) {
   if(!showPosition) return;
   int i,j;
   if(pos>openning_total-1) {
      for(i=0;i<4;i++) {
         for(j=0;j<6;j++) edit_openning[i+1][j].Text("");
      }
      return;
   }
   for(i=0;i<orderCount;i++) {
      if(pos+i<=openning_total-1) {
          ShowOrderAsItem(openning[pos+i], i);
      }
      else {
         for(j=0;j<6;j++) edit_openning[i+1][j].Text("");
      }
   }
}
void CMTKTradePadDialog::ShowOrderAsItem(POSITIONS &order,const int atPos){
   int dOrder = StringToInteger(edit_openning[atPos][0].Text());
   int showReturnType = 1;
   int showProcessType = 1;
   if(dOrder!=order.ticket) {
      //rewrite all
      edit_openning[atPos+1][0].Text(IntegerToString(order.ticket));
      edit_openning[atPos+1][1].Text(order.symbol);
      edit_openning[atPos+1][2].Text(DoubleToString(order.investment, 0));
      edit_openning[atPos+1][3].Text(DISPLAY_LANG[language_idx][order.type+10]);//offset
      if(showReturnType==1) { // version 1 ==> return/payoff fixed when openning
         edit_openning[atPos+1][4].Text(DoubleToString(order.investment*order.payoff, 2)+"/"+DoubleToString(order.payoff*100, 1)+"%");
      }
      else { // version 1 beta, dynamic return
         if(order.type == UP_DOWN) {
            double quote=0;
            if(order.price_mode == PMODE_ASK)
               quote = SymbolInfoDouble(order.symbol,SYMBOL_ASK);
            else if (order.price_mode == PMODE_BID)
               quote = SymbolInfoDouble(order.symbol,SYMBOL_BID);
            else
               quote = (SymbolInfoDouble(order.symbol,SYMBOL_ASK)+SymbolInfoDouble(order.symbol,SYMBOL_BID))/2;
         
            if(order.cmd == CMD_Call) {
               if(quote > order.open_price) 
                  edit_openning[atPos+1][4].Text(DoubleToString(order.investment*order.payoff, 2)+"/"+DoubleToString(order.payoff*100, 1)+"%");
               else
                  edit_openning[atPos+1][4].Text(DoubleToString(-order.investment, 2)+"/"+DoubleToString(0, 1)+"%");
            }
            else {
               if(quote < order.open_price)
                  edit_openning[atPos+1][4].Text(DoubleToString(order.investment*order.payoff, 2)+"/"+DoubleToString(order.payoff*100, 1)+"%");
               else
                  edit_openning[atPos+1][4].Text(DoubleToString(-order.investment, 2)+"/"+DoubleToString(0, 1)+"%");
            }
         }
      }
      if(1==2) { //show color
         if(order.close_price>order.open_price)
            edit_openning[atPos+1][4].Color(BUTTON_UP_COLOR);
         else
            edit_openning[atPos+1][4].Color(BUTTON_DOWN_COLOR);
      } 
   }
   //processing info
   int tdiff = TimeCurrent()-order.open_time;
   if(tdiff<0)
      edit_openning[atPos+1][5].Text(order.expiration+" / "+order.expiration);
   else
      edit_openning[atPos+1][5].Text(Exp_Sec2Str(tdiff-order.exp_sec)+" / "+order.expiration);
      
     /*// printf(" StringToInteger(order.exp_sec-tdiff) %d",StringToInteger(order.exp_sec-tdiff));
     //printf(" StringToInteger(tdiff) %d",StringToInteger(tdiff));      
     //printf(" StringToInteger(order.exp_sec) %d",StringToInteger(order.exp_sec));    
      if(StringToInteger(tdiff)> StringToInteger(order.expiration)){
         if(order.cmd==CMD_Call)//up
          OrderClose(order.ticket,order.investment,Bid,5,Red); 
         else  if(order.cmd==CMD_Put)
         OrderClose(order.ticket,order.investment,Ask,5,Red); //down         
                   
          }*/

        //   
   /*if(tdiff<0)
      edit_openning[atPos+1][5].Text("0.0% / "+order.expiration);
   else
      edit_openning[atPos+1][5].Text(DoubleToString((double)tdiff/order.exp_sec*100, 1)+"% / "+order.expiration);
   */
   //edit_openning[atPos+1][5].Text(Exp_Sec2Str(TimeCurrent()-order.open_time)+" / "+order.expiration);
      
}
void CMTKTradePadDialog::OnPosScrollUp(void) {
    int cp = openning_scroll.CurrPos();
    //printf("down "+cp);
    if(cp<1) cp=1;
    ShowOrdersFromPosition(cp-1, 4);
}
void CMTKTradePadDialog::OnPosScrollDown(void) {
    int cp = openning_scroll.CurrPos();
    //printf("down "+cp);
    if(cp<1) cp=1;
    ShowOrdersFromPosition(cp-1, 4);
}

string CMTKTradePadDialog::BytesNumber(const int _byte) {
   if(_byte<1024) return IntegerToString(_byte)+" bytes";
   if(_byte<1024*1024) return DoubleToString((double)_byte/1024, 2)+ " KB";
   if(_byte<1024*1024*1024) return DoubleToString((double)_byte/1024/1024, 2)+ " MB";
   return DoubleToString((double)_byte/1024/1024/1024, 2)+ " GB";
}



//+----------------------------------h--------------------------------+
//+------------------------------------------------------------------+
//| Comment Table                                                    |
//+------------------------------------------------------------------+
