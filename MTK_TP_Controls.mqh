//+------------------------------------------------------------------+
//|                                              MTK_TP_Controls.mqh |
//|                       Copyright 2014, MTK Beijing Tech. Co., Ltd |
//|                                        https://www.mt4xitong.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MTK Beijing Tech. Co., Ltd"
#property link      "https://www.mt4xitong.com"
#property strict
#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
#include <Controls\Edit.mqh>
#include <Controls\Label.mqh>
#include <Controls\ListView.mqh>
#include <Controls\MTKComboBox.mqh>
#include <Controls\Picture.mqh>
#include <Controls\VolEdit.mqh>
//#include <Controls\SpinEdit.mqh>
#include <MTK_TP_Language.mqh>

#resource "Controls\\res\\logo2.bmp"                // image file
//+------------------------------------------------------------------+
//| pad parameters                                                     |
//+------------------------------------------------------------------+
//--- 
#define SPACE_LEFT            (10)
#define SPACE_TOP             (10)
#define SPACE_RIGHT           (10)
#define SPACE_BOTTOM          (10)
#define CONTROLS_GAP_X        (5)
#define CONTROLS_GAP_Y        (5)
//--- for buttons
#define BTN_WIDTH             (115)
#define BTN_HEIGHT            (30)
//--- for the indication area
#define LABEL_HEIGHT          (20)
//--- panel coordinate
#define PANEL_X               20
#define PANEL_Y               20
#define PANEL_HEIGHT          360
#define PANEL_WIDTH           270
#define PANEL_SEPERATE        100
#define LOGO_HEIGHT           50
#define LOGO_WIDTH            260

enum ComboID {
   COMBO_SYMBOL=1,
   COMBO_VOLUME,
   COMBO_EXPIRATION,
   COMBO_TRADETYPE
};

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
   
private:

   //---- static info
   CEdit             edit_symbol;
   CEdit             edit_expiration;
   CEdit             edit_volume;
   CEdit             edit_tradeType;
   CEdit             edit_price;
   CEdit             edit_payoff;
   
   
   CPicture          pic_Logo;
   
   //---- dynamic info
   CEdit             edit_symbol_price;
   CEdit             edit_payoffA;
   CEdit             edit_payoffB;
   CEdit             edit_txtpayoffB;
   
   //---- combobox/option
   CComboBox         combo_symbol;
   //CSpinEdit         combo_volume;
   CVolEdit          combo_volume;
   CComboBox         combo_expiration;
   CComboBox         combo_tradeType;
   
   //---- Buttons
   CButton           buttonA;
   CButton           buttonB;
 
   //---- other config parameters
   int               language_idx;
   bool              withHistoryPad;
   
public:
                     CMTKTradePadDialog(void);
                    ~CMTKTradePadDialog(void);
   //--- chart event handler
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   
   bool              InitializeDialog(const long chart, const int subwin, const int lang_id, const int defaultTradeType, const color clName, const color clPrice, const color clBPrice, const color clPayoff, const color clOPayoff, const color clBtnA, const color clBtnB);
   bool              ClearDialog(const int defaultradeType);
   //---- AddItem
   bool              AddComboItem(const ComboID cmbID, int position, const string item);
   //---- default show
   bool              ShowComboItem(const ComboID cmdID, const string item);

   //---- update
   bool              updatePrice(const double value, const int digit);   
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
   
   void              OnClickLogo(void);
 
 private:
 };
//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CMTKTradePadDialog)
   ON_EVENT(ON_CLICK,buttonA,OnClickButtonA)
   ON_EVENT(ON_CLICK,buttonB,OnClickButtonB)
   ON_EVENT(ON_CLICK,pic_Logo,OnClickLogo);
   ON_EVENT(ON_CHANGE,combo_symbol,OnChangeComboSymbol)
   ON_EVENT(ON_CHANGE,combo_volume,OnChangeComboVolume)
   ON_EVENT(ON_CHANGE,combo_expiration,OnChangeComboExpiration)
   ON_EVENT(ON_CHANGE,combo_tradeType,OnChangeComboTradeType)
EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CMTKTradePadDialog::CMTKTradePadDialog(void)
{
}
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CMTKTradePadDialog::~CMTKTradePadDialog(void)
{
}
//---- Init
bool CMTKTradePadDialog::updatePrice(const double value, const int digit) {
   edit_symbol_price.Text(DoubleToString(value, digit));
   return(true);
}
bool CMTKTradePadDialog::InitializeDialog(const long chart,const int subwin,const int lang_id,const int defaultTradeType,const color clName,const color clPrice,const color clBPrice,const color clPayoff,const color clOPayoff,const color clBtnA,const color clBtnB)
{
   language_idx = lang_id;
   
   if (!Create(chart, DISPLAY_LANG[language_idx][S_PANEL_TITLE], subwin, PANEL_X,PANEL_Y,PANEL_X+PANEL_WIDTH,PANEL_Y+PANEL_HEIGHT)) return (false);
   
   int x1,x2,y1,y2,x11,x22;
   
   x1 = (ClientAreaWidth()-LOGO_WIDTH)/2;
   y1 = CONTROLS_SUBWINDOW_GAP;
   x2 = x1+LOGO_WIDTH;
   y2 = y1+LOGO_HEIGHT;
   if(!pic_Logo.Create(m_chart_id, "piclogo", m_subwin, x1, y1, x2, y2)) return (false);
   pic_Logo.BmpName("::Controls\\res\\logo2.bmp");
  
   if(!Add(pic_Logo)) return (false);
   
   
   x1 = SPACE_LEFT;
   x2 = PANEL_SEPERATE;
   y1 = y2+CONTROLS_GAP_Y;
   y2 = y1+LABEL_HEIGHT;
   x11 = PANEL_SEPERATE+CONTROLS_GAP_X;
   x22 = ClientAreaWidth() - SPACE_RIGHT;
   
   //--- TradeType
   if(!edit_tradeType.Create(m_chart_id, "txttradetype", m_subwin, x1, y1, x2, y2)) return (false);
   if(!Add(edit_tradeType)) return (false);
   edit_tradeType.Text(DISPLAY_LANG[language_idx][S_TRADETYPE]);
   edit_tradeType.TextAlign(ALIGN_RIGHT);
   edit_tradeType.Font(DISPLAY_LANG[language_idx][0]);
   edit_tradeType.ColorBackground(clName);
   edit_tradeType.ColorBorder(clName);
   edit_tradeType.ReadOnly(true);
   
   if(!combo_tradeType.Create(m_chart_id, "cmbtradetype", m_subwin, x11, y1, x22, y2)) return (false);
   if(!Add(combo_tradeType)) return (false);
   combo_tradeType.SetReadOnly(true);
   if(!combo_tradeType.ItemAdd(DISPLAY_LANG[language_idx][S_TYPE_UP_DOWN])) return(false);
   combo_tradeType.Select(0);
    
   
   //------------------
   
   y1 = y2+CONTROLS_GAP_Y;
   y2 = y1+LABEL_HEIGHT;
   //--- symbol
   if(!edit_symbol.Create(m_chart_id, "txtsymbol", m_subwin, x1, y1, x2, y2)) return (false);
   if(!Add(edit_symbol)) return (false);
   edit_symbol.Text(DISPLAY_LANG[language_idx][S_SYMBOL]);
   edit_symbol.Font(DISPLAY_LANG[language_idx][0]);
   edit_symbol.TextAlign(ALIGN_RIGHT);
   edit_symbol.ColorBackground(clName);
   edit_symbol.ColorBorder(clName);
   edit_symbol.ReadOnly(true);
 
   
   if(!combo_symbol.Create(m_chart_id, "cmbsymbol", m_subwin, x11, y1, x22, y2)) return (false);
   if(!Add(combo_symbol)) return (false);
   combo_symbol.SetReadOnly(true);
   //test
   if(!combo_symbol.ItemAdd(DISPLAY_LANG[language_idx][S_CHOOSE_SYMBOL])) return(false);
    if(!combo_symbol.ItemAdd("EURUSD")) return(false);
    if(!combo_symbol.ItemAdd("USDJPY")) return(false);
    if(!combo_symbol.ItemAdd("GBPUSD")) return(false);
    
   combo_symbol.Select(0);
     
   y1 = y2+CONTROLS_GAP_Y;
   y2 = y1+LABEL_HEIGHT;
   //--- expiration
   if(!edit_expiration.Create(m_chart_id, "txtexpiration", m_subwin, x1, y1, x2, y2)) return (false);
   if(!Add(edit_expiration)) return (false);
   edit_expiration.Font(DISPLAY_LANG[language_idx][0]);
   edit_expiration.Text(DISPLAY_LANG[language_idx][S_EXPIRATION]);
   edit_expiration.TextAlign(ALIGN_RIGHT);
   edit_expiration.ColorBackground(clName);
   edit_expiration.ColorBorder(clName);
   edit_expiration.ReadOnly(true);
   
   if(!combo_expiration.Create(m_chart_id, "cmbexpiration", m_subwin, x11, y1, x22, y2)) return (false);
   if(!Add(combo_expiration)) return (false);
   combo_expiration.SetReadOnly(true);
   
   
   y1 = y2+CONTROLS_GAP_Y;
   y2 = y1+LABEL_HEIGHT;
   //--- volume
   if(!edit_volume.Create(m_chart_id, "txtvolume", m_subwin, x1, y1, x2, y2)) return (false);
   if(!Add(edit_volume)) return (false);
   edit_volume.Font(DISPLAY_LANG[language_idx][0]);
   edit_volume.Text(DISPLAY_LANG[language_idx][S_VOLUME]);
   edit_volume.TextAlign(ALIGN_RIGHT);
   edit_volume.ColorBackground(clName);
   edit_volume.ColorBorder(clName);
   edit_volume.ReadOnly(true);
   
   if(!combo_volume.Create(m_chart_id, "cmbvolume", m_subwin, x11, y1, x22, y2)) return (false);
   if(!Add(combo_volume)) return (false);
   combo_volume.MaxValue(100);
   combo_volume.MinValue(1);
   combo_volume.Decimals(0);
   combo_volume.Step(5);
   combo_volume.Value(5);
   //combo_volume.SetReadOnly(false);
   
   
   //--- Current Price
   y1 = y2+CONTROLS_GAP_Y*2;
   y2 = y1+LABEL_HEIGHT;
   if(!edit_price.Create(m_chart_id, "txtprice", m_subwin, x1, y1, x1+BTN_WIDTH, y2)) return (false);
   if(!Add(edit_price)) return (false);
   edit_price.Font(DISPLAY_LANG[language_idx][0]);
   edit_price.Text(DISPLAY_LANG[language_idx][S_PRICE]);
   edit_price.TextAlign(ALIGN_CENTER);
   edit_price.ColorBackground(clPrice);
   edit_price.ColorBorder(clPrice);
   edit_price.ReadOnly(true);
   
   //--- Payoff
   if(!edit_payoff.Create(m_chart_id, "txtpayoff", m_subwin, x22-BTN_WIDTH, y1, x22, y2)) return (false);
   if(!Add(edit_payoff)) return (false);
   edit_payoff.Font(DISPLAY_LANG[language_idx][0]);
   edit_payoff.Text(DISPLAY_LANG[language_idx][S_PAYOFF]);
   edit_payoff.TextAlign(ALIGN_CENTER);
   edit_payoff.ColorBackground(clPayoff);
   edit_payoff.ColorBorder(clPayoff);
   edit_payoff.ReadOnly(true);
   
   //--- realtime quote
   y1 = y2+CONTROLS_GAP_Y;
   y2 = y1+LABEL_HEIGHT*2;
   if(!edit_symbol_price.Create(m_chart_id, "txtsymprice", m_subwin, x1, y1, x1+BTN_WIDTH, y2)) return (false);
   if(!Add(edit_symbol_price)) return (false);
   edit_symbol_price.Font(DISPLAY_LANG[language_idx][0]);
   edit_symbol_price.Text("1234.345");
   edit_symbol_price.FontSize(14);
   edit_symbol_price.TextAlign(ALIGN_CENTER);
   edit_symbol_price.ColorBackground(clrWhite);
   edit_symbol_price.ColorBorder(clBPrice);
   edit_symbol_price.ReadOnly(true);
   
   //--- current payoff
   if(!edit_payoffA.Create(m_chart_id, "txtpayoffA", m_subwin, x22-BTN_WIDTH, y1, x22, y2)) return (false);
   if(!Add(edit_payoffA)) return (false);
   edit_payoffA.Font(DISPLAY_LANG[language_idx][0]);
   edit_payoffA.Text("56.67%");
   edit_payoffA.FontSize(14);
   edit_payoffA.TextAlign(ALIGN_CENTER);
   edit_payoffA.ColorBackground(clPayoff);
   edit_payoffA.ColorBorder(clPayoff);
   edit_payoffA.ReadOnly(true);
   
   //--- other payoff txt
   y1 = y2+CONTROLS_GAP_Y*2;
   y2 = y1+LABEL_HEIGHT;
   if(!edit_txtpayoffB.Create(m_chart_id, "txtpayoffB", m_subwin, x1, y1, x22, y2)) return (false);
   if(!Add(edit_txtpayoffB)) return (false);
   edit_txtpayoffB.Font(DISPLAY_LANG[language_idx][0]);
   edit_txtpayoffB.FontSize(8);
   edit_txtpayoffB.Text(DISPLAY_LANG[language_idx][S_OTHERPAYOFF]);
   edit_txtpayoffB.TextAlign(ALIGN_CENTER);
   edit_txtpayoffB.ColorBackground(clOPayoff);
   edit_txtpayoffB.ColorBorder(clOPayoff);
   edit_txtpayoffB.ReadOnly(true);
   
   //--- other payoff txt
   y1 = y2+CONTROLS_GAP_Y;
   y2 = y1+LABEL_HEIGHT;
   if(!edit_payoffB.Create(m_chart_id, "payoffB", m_subwin, x1, y1, x22, y2)) return (false);
   if(!Add(edit_payoffB)) return (false);
   edit_payoffB.FontSize(8);
   edit_payoffB.Font(DISPLAY_LANG[language_idx][0]);
   edit_payoffB.Text("34.45% / 45.67% / 35.56%");
   edit_payoffB.TextAlign(ALIGN_CENTER);
   edit_payoffB.ColorBackground(clOPayoff);
   edit_payoffB.ColorBorder(clOPayoff);
   edit_payoffB.ReadOnly(true);
   
   //Create Buttons
   y1 = y2+CONTROLS_GAP_Y*2;
   y2 = y1+BTN_HEIGHT;
   //--- button CALL in green
   if(!buttonA.Create(m_chart_id, "btnA", m_subwin, x1, y1, x1+BTN_WIDTH, y1+BTN_HEIGHT)) return (false);
   if(!Add(buttonA)) return (false);
   buttonA.Font(DISPLAY_LANG[language_idx][0]);
   buttonA.Text(DISPLAY_LANG[language_idx][S_BUTTON_CALL]);
   buttonA.ColorBackground(clBtnA);
   buttonA.FontSize(14);
   
   //--- button CALL in green
   if(!buttonB.Create(m_chart_id, "btnB", m_subwin, x22-BTN_WIDTH, y1, x22, y1+BTN_HEIGHT)) return (false);
   if(!Add(buttonB)) return (false);
   buttonB.Font(DISPLAY_LANG[language_idx][0]);
   buttonB.Text(DISPLAY_LANG[language_idx][S_BUTTON_PUT]);
   buttonB.ColorBackground(clBtnB);
   buttonB.FontSize(14);
   buttonB.Locking(false);
   
   
   return (true);
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
   this.Move(20,20);
   return(true);
}
//---- Event handlers
void CMTKTradePadDialog::OnClickButtonA(void)
{}
void CMTKTradePadDialog::OnClickButtonB(void)
{}
void CMTKTradePadDialog::OnChangeComboSymbol(void)
{
   if(combo_symbol.Value()>0)
      symbolSelected = combo_symbol.Select();
   else
      symbolSelected = "";
}
void CMTKTradePadDialog::OnChangeComboVolume(void)
{}
void CMTKTradePadDialog::OnChangeComboExpiration(void)
{}
void CMTKTradePadDialog::OnChangeComboTradeType(void)
{}
void CMTKTradePadDialog::OnClickLogo(void)
{
   MessageBox(DISPLAY_LANG[language_idx][S_ABOUT], DISPLAY_LANG[language_idx][S_CAPTION_ABOUT], MB_ICONINFORMATION);
}
