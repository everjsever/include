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


  

//+------------------------------------------------------------------+//| Constructor                                                      |
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
   symbolSelected = Symbol(); 
   periodSelected = 1;
   lastSymbol = "";
   lastTickVol = -1;
   lastPeriod = -1;
   chartReady = false;
   PanelLoaded = false;
   quote = 0;
   uid = 0;


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

   CheckTime=0;//1 second 
  
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
bool CMTKTradePadDialog::getInitResult()
{
   return   1;
}
//---- Init
bool CMTKTradePadDialog::updatePrice(const double bid, const double ask, const datetime dt) {;
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
   //combo_symbol.ItemsClear();         
  
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
        
   return true;  

}
bool CMTKTradePadDialog::reloadConfig(double UpPrice,double DownPrice){

   edit_up.Text(DoubleToString(UpPrice));
   edit_down.Text(DoubleToString(DownPrice));   
   return true;
}
void CMTKTradePadDialog::RefreshUI(void){

      int maxVol = MathMax(cur_config.MaxVols[0], cur_config.MaxVols[1]); 
      int minVol = MathMin(cur_config.MinVols[0], cur_config.MinVols[1]);
      int stepVol = MathMax(cur_config.StepVols[0], cur_config.StepVols[1]);      
      string out = DISPLAY_LANG[language_idx][S_VOLUME]+":" + DISPLAY_LANG[language_idx][S_VOL_MIN] + "=" +IntegerToString(minVol) + ";"
         + DISPLAY_LANG[language_idx][S_VOL_MAX] + "=" + IntegerToString(maxVol) + ";" 
         + DISPLAY_LANG[language_idx][S_VOL_STEP] + "=" + IntegerToString(stepVol)+  ";"/*+DISPLAY_LANG[language_idx][41] + "=" + cur_config.login_open_order_num_limit+ ";" + DISPLAY_LANG[language_idx][42] + "=" + cur_config.login_open_investment_limit+ ";"*/ ;      
      edit_detail.Text(out);
      CalculateReturn(0);
      edit_up.Text(DoubleToString(cur_config.Payoff[0]*100, 1)+"%");
      edit_down.Text(DoubleToString(cur_config.Payoff[1]*100, 1)+"%");
}

int CMTKTradePadDialog::SqlInit()
  {
  //--- open database connection
    ResetLastError();
    string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);
    printf(terminal_data_path);
    //char arr[256]={0};
    
    string filename=terminal_data_path+"\\MQL4\\Libraries\\"+"bodll.db";
    uchar arrayChar[512]={0};
    StringToCharArray(filename,arrayChar,0,WHOLE_ARRAY,CP_UTF8);
    filename=CharArrayToString(arrayChar);
    ushort array[512]={0};
    StringToShortArray(filename,array);
    string dbpath=ShortArrayToString(array);
    
    //Dll_GetUTF8String(filename,dbpath);
    //printf(dbpath);
    //printf(ArraySize(arr));
    //for(int i=0;i<ArraySize(arr);i++)
    //{
      //dbpath=dbpath+CharToString(arr[i]);
    //}
    //printf(dbpath);
    //string filename = "E:\娴嬭瘯\MetaTrader Nano 4\MQL4\Libraries\bodll.db";
//   if(sql3.Connect("c:/bo/conf/bodll.db")!=SQLITE_OK){
   if(sql3.Connect(filename)!=SQLITE_OK){
        printf("sql open fail");
      return INIT_FAILED;
  }
   printf("sql open ok!");
   updateTime="";//mtk_bo_data_change ,time field        
   return(INIT_SUCCEEDED);
  } 

 void  CMTKTradePadDialog::Disconnect(){
   tradeDisable();
   sql3.Disconnect();
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
   //printf(" %f, %f",cur_config.MaxVols[_type],cur_config.MinVols[_type]);
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


   string cmt = "[" + stype + "]/" + IntegerToString(Exp_Str2Sec(combo_expiration.Select())) + "s/" + DoubleToString(cur_config.Payoff[0], 3);
  
   int mn = CalcMagicNumber(symbolSelected, IntegerToString(Exp_Str2Sec(combo_expiration.Select())), combo_volume.Value(), OP_BUY, DayOfYear());
  
   OutToStatus(StringConcatenate(STATUS_TEXT[language_idx][S_STATUS_BO_SENDORDER], cmt, ", ", STATUS_TEXT[language_idx][S_STATUS_BO_WAITING]));
   int order = OrderSend(symbolSelected, OP_BUY, combo_volume.Value(), SymbolInfoDouble(symbolSelected, SYMBOL_BID), 1, 0, 0, cmt, mn);
   int _err = GetLastError();
   if(_err == 0) 
      OutToStatus(StringConcatenate(STATUS_TEXT[language_idx][S_STATUS_BO_ORDEROK], IntegerToString(order)));
   else {
        Sleep(1000);
        string rejectStr= OrderReject(login);
        if(rejectStr == NULL)
        {
            OutToStatus(StringConcatenate(STATUS_TEXT[language_idx][S_STATUS_BO_ORDERKO],"Server cant receive the request,try again!"), clrRed);
        }
        else
        {
            OutToStatus(StringConcatenate(STATUS_TEXT[language_idx][S_STATUS_BO_ORDERKO],rejectStr), clrRed);
        }
                
   }

}
int CMTKTradePadDialog::CalcMagicNumber(string _symbol, const int _expi, const int _invest, const int _cmd, const int _dayOfYear) {
	int c0 = StringGetChar(_symbol,0);
   int c1 = StringGetChar(_symbol,1);
   int c2 = StringGetChar(_symbol,2);
   //MqlDateTime reqTime;
   //datetime nowTime = TimeCurrent();
   int ts = TimeCurrent();
	int ret = 0;
	if(login<=0) return ret;
	if(_symbol==NULL) return ret;
	if(StringLen(_symbol)<3)return ret;//
	ret = (c0<<2)+(c1<<1)+c2 + (login % _expi) + (_invest << _cmd) + (ts % 3600);
	//printf("ret= %d",_expi);
	//ret = (((mt4login % _expi) % 1000) * 1000 + _invest + _cmd * 100 + _symbol[0]*10 + _symbol[1]) * 1000 + _dayOfYear;
	//ret = (((login % _expi) % 1000) * 1000 + _invest + _cmd * 100  ) * 1000 + _dayOfYear;
//	printf("ret= %d",ret);
	return ret;
}
void CMTKTradePadDialog::OnClickButtonB(void) {//看跌下单，以down+到期时间+看跌赔率（put）为标准
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
   string cmt = "[" + stype + "]/" + IntegerToString(Exp_Str2Sec(combo_expiration.Select())) + "s/" + DoubleToString(cur_config.Payoff[1], 3);   

//   int mn = CalcMagicNumber(symbolSelected, combo_expiration.Value(), combo_volume.Value(), OP_BUY, DayOfYear());
   int mn = CalcMagicNumber(symbolSelected, IntegerToString(Exp_Str2Sec(combo_expiration.Select())), combo_volume.Value(), OP_BUY, DayOfYear());

   OutToStatus(StringConcatenate(STATUS_TEXT[language_idx][S_STATUS_BO_SENDORDER], cmt, ", ", STATUS_TEXT[language_idx][S_STATUS_BO_WAITING]));
   int order = OrderSend(symbolSelected, OP_SELL, combo_volume.Value(), SymbolInfoDouble(symbolSelected, SYMBOL_ASK), 1, 0, 0, cmt, mn);
   int _err = GetLastError();
   if(_err == 0) 
      OutToStatus(StringConcatenate(STATUS_TEXT[language_idx][S_STATUS_BO_ORDEROK], IntegerToString(order)));
   else {
        Sleep(1000);
        string rejectStr= OrderReject(login);
        if(rejectStr == NULL)
        {
            OutToStatus(StringConcatenate(STATUS_TEXT[language_idx][S_STATUS_BO_ORDERKO],"Server cant receive the request,try again!"), clrRed);
        }
        else
        {
            OutToStatus(StringConcatenate(STATUS_TEXT[language_idx][S_STATUS_BO_ORDERKO],rejectStr), clrRed);
        }
   }

   //Sleep(5);   
}
int CMTKTradePadDialog::Sqlquery(){
   //if(Dll_CfgReady()==0) return 0;//avoid sql unlock,when 1 can operate   
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

  // combo_symbol.ItemsClear();

   string chartSymbol = Symbol();
   special_config.symbol=chartSymbol;
   //printf("% s",chartSymbol);
   int selectID = -1;
   int used = 0;
   string symbol;
   string curSymbol;
   for(int ic=0;ic<recordcs;ic++) {
     if(StringCompare(symbols[ic], chartSymbol)==0) { //(SymbolInfoInteger(symbols[ic], SYMBOL_SELECT)!=1) {
         //printf("Symbol[%s] not available in the Market Watch, ignored", symbols[ic]);
         
         //combo_symbol.AddItem(symbols[ic], 0);
         selectID=0;
      }    

  }    
   if(selectID==-1) return false;//not find the correct symbol
   
   symbolSelected =chartSymbol;
   //combo_symbol.Select(0);
   cur_config.symbol=chartSymbol;
/*
*/
   return reloadType(chartSymbol);
}

bool CMTKTradePadDialog::reloadSymbol(void){
 //  if(Dll_CfgReady()==0) return false;//avoid sql unlock,when 1 can operate   
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
//   if(Dll_CfgReady()==0) return false;//avoid sql unlock,when 1 can operate   
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
 //  if(Dll_CfgReady()==0) return false;//avoid sql unlock,when 1 can operate   
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
            int timeValue = StrToInteger(ExpiList[ic]);
            string timeStr ="";
            int s, m, h;
	         s = timeValue % 60;
	         m = timeValue / 60;
	         h = m / 60;
	         m = m % 60;
	         if(0!=h){
	            timeStr=IntegerToString(h)+"h";
	         }
	         if(0!=m){
	            timeStr=IntegerToString(m)+"m";
	         }
	         if(0!=s){
	            timeStr=IntegerToString(s)+"s";
	         }
            if(!combo_expiration.ItemAdd(timeStr,ic)) continue;

         }
         
         combo_expiration.Select(selectID);
         tradeExpiration = 0;
         special_config.expiration=IntegerToString(Exp_Str2Sec(combo_expiration.Select()));
         cur_config.expiration=IntegerToString(Exp_Str2Sec(combo_expiration.Select()));
         OnChangeComboExpiration();        
      }

        
   return true;
}
void CMTKTradePadDialog::Concentration_limits(){
 //  if(Dll_CfgReady()==0) return;//avoid sql unlock,when 1 can operate   
//select login_open_investment_limit, login_open_order_num_limit  from mtk_bo_concentration_limits where (symbol='Gold.bx' or symbol='*') and (play_mode='*' or  play_mode='up_down' ) and enabled=0 and mt4_group='BOTest' 
    string sqlquery="select login_open_investment_limit, login_open_order_num_limit  from mtk_bo_concentration_limits where (symbol='*' or ";
    sqlquery+="symbol ='"+symbolSelected +"')"; 
    sqlquery+=" and (play_mode ='"+playtype[tradeType] +"' or play_mode='*' ) and enabled=1 ";
    sqlquery+="and mt4_group='"+accountname + "'";

    //printf(" %s ", sqlquery);
    if(sql3.Query(tbl,sqlquery)!=SQLITE_DONE)
     {
      Print(sql3.ErrorMsg());
      return ;
     }     
   int c,cs;
   string temps[20];
   int rs=ArraySize(tbl.m_data);
   for(int r=0; r<rs; r++)
     {
      CSQLite3Row *row=tbl.Row(r);
      cs=ArraySize(row.m_data);
      for( c=0; c<cs; c++){
         temps[c]=row.m_data[c].GetString();
         //printf(" %s    %d",row.m_data[c].GetString(),cs);

      }
     }
    normal_config.login_open_investment_limit=temps[0]; 
    normal_config.login_open_order_num_limit= temps[1];

}
string CMTKTradePadDialog::OrderReject(int _login){
   return "";
}
bool CMTKTradePadDialog::TimeSections(void){
            
      return false;     
      
}
   

void CMTKTradePadDialog::OnChangeComboSymbol(void)
{

}
void CMTKTradePadDialog::OnChangeComboPeriod(void)
{

}
void CMTKTradePadDialog::OnChangeComboVolume(void){
   CalculateReturn(0);
}
void CMTKTradePadDialog::OnChangeComboExpiration(void) {
 //  if(Dll_CfgReady()==0) return;//avoid sql unlock,when 1 can operate   
   if(StringTrimRight(symbolSelected)=="") return;
   
//   if(Dll_CfgReady()==0) return;//avoid sql unlock,when 1 can operate         
   
   int ret;
   string temps[20];   
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
   int c,cs,count;

   count=0;
   int rs=ArraySize(tbl.m_data);
   for(int r=0; r<rs; r++)
     {
      CSQLite3Row *row=tbl.Row(r);
      cs=ArraySize(row.m_data);
      for( c=0; c<cs; c++){
         temps[count]=row.m_data[c].GetString();
         //printf(" %s    %d",temps[c],count);
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
      
      normal_config.Payoff[0] = StringToDouble(temps[0]);
      normal_config.LvPayoff[0]=StringToDouble(temps[1]);
      cur_config.PriceMode[0]=pm1;
      normal_config.PriceMode[0]=pm1;
      cur_config.MaxVols[0]=StringToInteger(temps[3]);
      normal_config.MaxVols[0]=StringToInteger(temps[3]);
      cur_config.MinVols[0]=StringToInteger(temps[4]);
      normal_config.MinVols[0]=StringToInteger(temps[4]);
      cur_config.StepVols[0]=StringToInteger(temps[5]);
      normal_config.StepVols[0]=StringToInteger(temps[5]);
      
      cur_config.Payoff[1] = StringToDouble(temps[6]);
      normal_config.Payoff[1]=StringToDouble(temps[6]);//put赔率
      //printf("  %s, %s",DoubleToString(cur_config.Payoff[0]*100, 1),DoubleToString(cur_config.Payoff[1]*100, 1));      
      cur_config.LvPayoff[1]=StringToDouble(temps[7]);
      normal_config.LvPayoff[1]=StringToDouble(temps[7]);
      cur_config.PriceMode[1]=pm2;
      normal_config.PriceMode[1]=pm2;
      cur_config.MaxVols[1]=StringToInteger(temps[9]);
      normal_config.MaxVols[1]=StringToInteger(temps[9]);
      cur_config.MinVols[1]=StringToInteger(temps[10]);
      normal_config.MinVols[1]=StringToInteger(temps[10]);
      cur_config.StepVols[1]=StringToInteger(temps[11]);
      normal_config.StepVols[1]=StringToInteger(temps[11]);
      
      // printf("temps.temps[1]=%s, %s ",temps[5],temps[11]);    
      //select  *   from mtk_bo_investment_limits where (symbol='Gold.bx' or symbol='*') and (play_mode='*' or  play_mode='up_down' ) and enabled=1 and mt4_group='BOTest'

      //select login_open_investment_limit, login_open_order_num_limit  from mtk_bo_concentration_limits where (symbol='Gold.bx' or symbol='*') and (play_mode='*' or  play_mode='up_down' ) and enabled=0 and mt4_group='BOTest' 
      Concentration_limits();//
      TimeSections();//check the special mode
      
      //--- other info
      double maxVol = MathMax(cur_config.MaxVols[0], cur_config.MaxVols[1]); 
      double minVol = MathMin(cur_config.MinVols[0], cur_config.MinVols[1]);
      double stepVol = MathMax(cur_config.StepVols[0], cur_config.StepVols[1]);
      double val =  combo_volume.Value();
      
      edit_up.Text(DoubleToString(cur_config.Payoff[0]*100, 1)+"%");
      edit_down.Text(DoubleToString(cur_config.Payoff[1]*100, 1)+"%");
      //printf("  %s, %s",DoubleToString(cur_config.Payoff[0]*100, 1),DoubleToString(cur_config.Payoff[1]*100, 1));
      double pfl = normal_config.LvPayoff[0];
      
      
      //string btxt = (show1)?buttonA.Text():buttonB.Text();
      //printf("cur_config.StepVols[1]=%d, %d ",cur_config.StepVols[0],cur_config.StepVols[1]);
      //printf("step=%d, %d ",stepVol,val);
      combo_volume.SetValues(minVol, maxVol, stepVol, val);


      special_config.expiration=IntegerToString(Exp_Str2Sec(combo_expiration.Select()));
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
   edit_return.Text(DoubleToStr(combo_volume.Value()*cur_config.Payoff[0],2));//call
   edit_return_put.Text(DoubleToStr(combo_volume.Value()*cur_config.Payoff[1],2));  //put 
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
      int diff =  TimeCurrent() - OrderOpenTime();//
      int period = 0;
      string comment = OrderComment();
      int pos1 = StringFind(comment,"/",0);
      int pos2 = StringFind(comment,"/",pos1+1);
      string strPeriod = StringSubstr(comment,pos1+1,(pos2-pos1-1));
      string strUnit = StringSubstr(strPeriod,StringLen(strPeriod)-1,1);
      
      if("S"==strUnit||"s"==strUnit)
      {
         period = StrToInteger(strPeriod);
      }
      else if("M"==strUnit||"m"==strUnit)
      {
         period = StrToInteger(strPeriod)*60;
      }
      else
      {
         period = StrToInteger(strPeriod)*60*60;
      }
      if(diff > period)continue;//
      InsertOrder(OrderTicket());
      total_bo++;
      total_invest+=OrderLots();
   }
   OutToPosition(total_bo,total_invest);
   if(!showPosition) return;
   openning_scroll.MinPos(1);
   if(total_bo>4) 
      openning_scroll.MaxPos(total_bo-1);
   else
   {
      openning_scroll.MaxPos(2);
      openning_scroll.CurrPos(0);
   }
   
   //refresh here
   int cp = openning_scroll.CurrPos();
   if(cp<1) cp=1;
   ShowOrdersFromPosition(cp-1, 4);
   int cmd,win_count,lose_count;
   win_count=0;
   lose_count=0;
   int OrderNumBalance=0;
   int i=0;
   if(OrdersHistoryTotal()>5){
    //for(int i=1;i<6;i++){
    do{
      i++;
      if(OrderSelect(OrdersHistoryTotal()-i,SELECT_BY_POS,MODE_HISTORY))
      {
      
          //string symbol = OrderSymbol();
          //if(StringFind(symbol, SYMBOL_POSTFIX) == (StringLen(symbol)-StringLen(SYMBOL_POSTFIX)))
          if(OrderSymbol()=="")
          {
             OrderNumBalance++;
             int profit=OrderProfit();
             //if(cmd==OP_BUY && cmd==OP_SELL )//
             //{
             if(OrderProfit()>0){
                win_count++;	
             }
             else
                 lose_count++;
          
             //}
           }     
                       
       }// if(OrderSelect(OrdersHistoryTotal()-1,SELECT_BY_POS,MODE_HISTORY))
           
      }while(OrderNumBalance<5);
        //最近5次胜率 
       // printf("OrdersHistoryTotal() %d ,%d",win_count,(win_count*100/3)); 
        edit_winratio.Text(DoubleToString((win_count*100/5),2)+"%");
  
      } 


   if(OrdersHistoryTotal()>1){
   
    for(int i=1;i<2;i++){
      if(OrderSelect(OrdersHistoryTotal()-i,SELECT_BY_POS,MODE_HISTORY))
          {
          		double profit=OrderProfit();
             if(profit>0)
						   {
						       edit_win.Text(DoubleToString(profit,2)+"USD");// Print("上一个单子盈利");
						   }else
						   {
						       edit_win.Text(DoubleToString(profit,2)+"USD");// Print("上一个单子盈利");
						   }
						   
						   edit_order.Text(DoubleToString(OrderTicket(),0));//订单号 OrderMagicNumber() 
         
                       
             }// if(OrderSelect(OrdersHistoryTotal()-1,SELECT_BY_POS,MODE_HISTORY))
         }

          
      } 
          
   
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
      if(order.cmd == CMD_Call) {
       edit_openning[atPos+1][3].Text("Buy / "+DoubleToString(order.open_price,5));//offset
      }
      else
      edit_openning[atPos+1][3].Text("Sell / "+DoubleToString(order.open_price,5));//offset
      //edit_openning[atPos+1][3].Text(DISPLAY_LANG[language_idx][order.type+10]);//offset
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
      //if(1==1) 
       //show color
         if(quote>order.open_price)
         {
             edit_openning[atPos+1][0].Color(clrSpringGreen);
         }
         else if(quote < order.open_price)
         {
             edit_openning[atPos+1][0].Color(clrRed);
         }

      }
   //processing info

    int tdiff = TimeCurrent()-order.open_time;
    if(tdiff<0)
      edit_openning[atPos+1][5].Text(order.expiration+" / "+Exp_Sec2Str(order.expiration));//修改间显示方式
    else
      edit_openning[atPos+1][5].Text(Exp_Sec2Str(order.exp_sec-tdiff)+" / "+Exp_Sec2Str(order.expiration)); 
      
     
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

 void ServerFileUpdate()
 {
   int handle = FileOpen("fractals.csv",FILE_WRITE|FILE_CSV);
   if(handle < 1)
   {
       Print("the param file error", GetLastError());
   }

   
 }

bool CMTKTradePadDialog::InitializeDialog(const long chart,const int subwin,const int lang_id,const int defaultTradeType)
{


   language_idx = lang_id;
   int retStart;   
  string _host;
   string _path;
  
   if(!PanelLoaded) { //first call
 
      PanelLoaded = true;
      int wholeHeight = PANEL_HEIGHT+STATUS_HEIGHT-CONTROLS_GAP_Y;
      if(displayPositions) 
      wholeHeight+=PANEL_POSITION_HEIGHT+LABEL_POSITION_HEIGHT+CONTROLS_GAP_Y*2; 
      
      if (!Create(chart, DISPLAY_LANG[language_idx][S_PANEL_TITLE], subwin, PANEL_X,PANEL_Y,PANEL_X+PANEL_WIDTH,PANEL_Y+wholeHeight)) return (false);
   
      int x1,x2,x11,x22;
      int y1,y2,y11,y22;
   
      y1 = CONTROLS_SUBWINDOW_GAP+CONTROLS_GAP_Y;
      y2 = y1+25;
      y11= y2+CONTROLS_GAP_Y;
      y22= y11+160;
   
      //Product Name
      x1 = SPACE_LEFT;
      x2 = SYMBOL_WIDTH;  


      //Chart
      x1 = SPACE_LEFT;
      x2 = x1+CHART_WIDTH;

      ChartBottomY = y22 - UCHART_SPACE_BOTTOM;
      
      //Panel Operation   
      if(!panel_operation.Create(m_chart_id, "paneloperation", m_subwin, 300, 30, 590, 120)) return (false);
      if(!Add(panel_operation)) return (false);
      //printf("x1 =%d x2 =%d", x11-CHART_WIDTH,SPACE_LEFT+CHART_WIDTH+CONTROLS_GAP_X); 
      //Panel Payoff

      if(!panel_payoff.Create(m_chart_id, "panelpayoff", m_subwin, 0, 30, 300, 120)) return (false);
      if(!Add(panel_payoff)) return (false);


      
      //--- TradeType
      //Text

      if(!edit_tradeType.Create(m_chart_id, "txttradetype", m_subwin, 0, 170, 75, 200)) return (false);
      if(!Add(edit_tradeType)) return (false);
      edit_tradeType.TextAlign(ALIGN_CENTER);
      edit_tradeType.ReadOnly(true);
   
   
      if(!combo_tradeType.Create(m_chart_id, "cmbtradetype", m_subwin, 75, 170, 190, 200)) return (false);
      if(!Add(combo_tradeType)) return (false);
      combo_tradeType.SetReadOnly(true);

    
      if(!combo_volume.Create(m_chart_id, "cmbvolume", m_subwin, 200,170, 400,200)) return (false);
      if(!Add(combo_volume)) return (false);
      //test 
      combo_volume.MaxValue(1000);
      combo_volume.MinValue(1);
      combo_volume.Decimals(0);
      combo_volume.Step(0);
      combo_volume.Value(10);
      
      //Expiration

      if(!edit_expiration.Create(m_chart_id, "txtexpiration", m_subwin, 400, 170, 460, 200)) return (false);
      if(!Add(edit_expiration)) return (false);
      edit_expiration.TextAlign(ALIGN_CENTER) ;
      edit_expiration.ReadOnly(true);
      edit_expiration.FontSize(edit_expiration.FontSize()/111);
      

      if(!combo_expiration.Create(m_chart_id, "cmbexpiration", m_subwin, 460, 170, 580, 200)) return (false);
      if(!Add(combo_expiration)) return (false);
      //combo_expiration.AddItem("2222/22/22 23:34:56");
      combo_expiration.SetReadOnly(true);      
      
      //Buttons
      //--- button UP
      if(!buttonA.Create(m_chart_id, "btnA", m_subwin, 400 , 120, 590 , 170)) return (false);
      if(!Add(buttonA)) return (false);
      buttonA.FontSize(DEFAULT_FONTSIZE/111);
      buttonA.Locking(false);
      //buttonA.ColorBorder(Pad_BG_Color);

       //--- realtime quote
      if(!edit_symbol_price.Create(m_chart_id, "txtsymprice", m_subwin, 200, 120, 400, 170)) return (false);
      if(!Add(edit_symbol_price)) return (false);
      edit_symbol_price.Text("------");
      edit_symbol_price.FontSize(DEFAULT_FONTSIZE/111);
      edit_symbol_price.TextAlign(ALIGN_CENTER);
      edit_symbol_price.ReadOnly(true);     
      
      int y31 = y2 + CONTROLS_GAP_Y;
      //--- button down
      y2 = y22 - CONTROLS_GAP_Y;
      y1 = y2 - BTN_HEIGHT;
      CButton tmp;
      if(!buttonB.Create(m_chart_id, "btnB", m_subwin, 0, 120, 200, 170)) return (false);
      if(!Add(buttonB)) return (false);
      buttonB.FontSize(DEFAULT_FONTSIZE/111);
      buttonB.Locking(false);
      //buttonB.ColorBorder(Pad_BG_Color);      
      int y32 = y1 - CONTROLS_GAP_Y;
      
     
      //Payoff value
      if(!edit_up.Create(m_chart_id, "payoffvalue", m_subwin, 300 , 40, 530 ,90)) return (false);
      if(!Add(edit_up)) return (false);
      edit_up.TextAlign(ALIGN_CENTER);
      //edit_up.ReadOnly(true);
      edit_up.FontSize(PAYOFF_FONTSIZE/111);
      edit_up.Text("up----------");

      if(!edit_down.Create(m_chart_id, "payoffvalue_put", m_subwin, 50, 40, 300,90)) return (false);
      if(!Add(edit_down)) return (false);
      edit_down.TextAlign(ALIGN_CENTER);
      //edit_down.ReadOnly(true);
      edit_down.FontSize(PAYOFF_FONTSIZE/111);
      edit_down.Text("down-------");
      //printf("  %d",y1);
      //product info
      y1 = ChartBottomY + UCHART_SPACE_BOTTOM + CONTROLS_GAP_Y;
      y2 = y1+STATUS_HEIGHT;
      x1 = 0;
      x2 = ClientAreaWidth();
      //printf("  %d  %d",y1,y2);
     
      
      //Status Edit
      x1 = 0;
      y1 = ClientAreaHeight()-STATUS_HEIGHT; //ChartBottomY + UCHART_SPACE_BOTTOM + CONTROLS_GAP_Y+3;
      int offsetGap = CONTROLS_GAP_X / 2;
      x2 = x1 + SPACE_LEFT + CHART_WIDTH + CONTROLS_GAP_X+offsetGap;
      y2 = y1 + STATUS_HEIGHT;
      if(!edit_status.Create(m_chart_id, "editstatus", m_subwin, x1, y1, ClientAreaWidth(), y2)) return (false);
      if(!Add(edit_status)) return (false);
      edit_status.TextAlign(ALIGN_LEFT);
      edit_status.ReadOnly(true);
      edit_status.Text(STATUS_TEXT[language_idx][S_STATUS_INIT_PAD]);

      edit_status.Color(clrBlack);
      edit_status.ColorBackground(clrWhite);
      edit_status.ColorBorder(BORDER_COLOR);

         

      //Chart preparation

   }      
   
   edit_tradeType.Text(DISPLAY_LANG[language_idx][S_TRADETYPE]);
   edit_tradeType.Font(DISPLAY_LANG[language_idx][0]);
   edit_tradeType.FontSize(edit_tradeType.FontSize()/111);
   edit_tradeType.ColorBackground(CTLSteelBlue);
   edit_tradeType.ColorBorder(CTLSteelBlue);
   edit_tradeType.Color(TEXT_COLOR);
      
   combo_tradeType.SetFont(DISPLAY_LANG[language_idx][0]);

   panel_operation.ColorBackground(OPERATE_PANEL_BG_COLOR);
   panel_operation.ColorBorder(OPERATE_PANEL_BG_COLOR);
      
   panel_payoff.ColorBackground(PAYOFF_PANEL_BG_COLOR);
   panel_payoff.ColorBorder(PAYOFF_PANEL_BG_COLOR);
      
   edit_expiration.Font(DISPLAY_LANG[language_idx][0]);
   edit_expiration.Text(DISPLAY_LANG[language_idx][S_EXPIRATION]);
   edit_expiration.ColorBackground(CTLSteelBlue);
   edit_expiration.ColorBorder(CTLSteelBlue);
   edit_expiration.Color(TEXT_COLOR);
      
   combo_expiration.SetFont(DISPLAY_LANG[language_idx][0]);
      

      
   combo_volume.SetFont(DISPLAY_LANG[language_idx][0]);
      
   buttonA.Font(DISPLAY_LANG[language_idx][0]);
   buttonA.Text(DISPLAY_LANG[language_idx][S_BUTTON_CALL]);
   buttonA.ColorBackground(BUTTON_UP_COLOR);
  
      
   buttonB.Font(DISPLAY_LANG[language_idx][0]);
   buttonB.Text(DISPLAY_LANG[language_idx][S_BUTTON_PUT]);
   buttonB.ColorBackground(BUTTON_DOWN_COLOR);
      
   edit_symbol_price.Font(DISPLAY_LANG[language_idx][0]);
   edit_symbol_price.Color(PRICE_COLOR);
   edit_symbol_price.ColorBackground(CTLSteelBlue);
   edit_symbol_price.ColorBorder(CTLSteelBlue);
      
 

 
   edit_up.Font(DISPLAY_LANG[language_idx][0]);
   edit_up.ColorBackground(Operation_Panel_BG_Color);
   edit_up.ColorBorder(Operation_Panel_BG_Color);
   edit_up.Color(PAYOFF_COLOR);

   edit_down.Font(DISPLAY_LANG[language_idx][0]);
   edit_down.ColorBackground(PAYOFF_PANEL_BG_COLOR);
   edit_down.ColorBorder(PAYOFF_PANEL_BG_COLOR);
   edit_down.Color(PAYOFF_COLOR);   
  
   

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
  

     
   return true;
}


//+----------------------------------h--------------------------------+
//+------------------------------------------------------------------+
//| Comment Table                                                    |
//+------------------------------------------------------------------+
