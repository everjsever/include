
#define SEP_LINE     96 //  
#define SEP_CONFIG   124 // |
#define SEP_CMT      47  // /
#define TTEXT_OFFSET 9
#define _VERSION     112
//+------------------------------------------------------------------+
//| pad parameters                                                     |
//+------------------------------------------------------------------+
//--- 
#define SPACE_LEFT            (5)
#define SPACE_TOP             (5)
#define SPACE_RIGHT           (5)
#define SPACE_BOTTOM          (5)
#define CONTROLS_GAP_X        (4)
#define CONTROLS_GAP_Y        (4)
//--- for buttons
#define BTN_WIDTH             (90) 
#define BTN_HEIGHT            (30)
//--- for the indication area
#define LABEL_HEIGHT          (25)
#define STATUS_HEIGHT         18
//--- panel coordinate
#define PANEL_X               20
#define PANEL_Y               20
#define PANEL_HEIGHT          250
#define PANEL_WIDTH           600 //640
#define PAYOFF_FONTSIZE       32
#define DEFAULT_FONTSIZE      14
//#define PANEL_SEPERATE      100
#define SYMBOL_WIDTH          160
#define PERIOD_WIDTH          65
#define CHART_HEIGHT          160
#define CHART_WIDTH           300
#define EXP_TXT_WIDTH         50
//----- panel positions
#define LABEL_POSITION_HEIGHT 20
#define PANEL_POSITION_HEIGHT 80
#define PANEL_POS_TICKET_W    80
#define PANEL_POS_SYMBOL_W    80
#define PANEL_POS_INVEST_W    75
#define POSITION_LINE_H       20

#define PANEL_POSITION_SCROLL 20

#define POSITIONS_STEP        32
//----- chart
#define UCHART_SPACE_LEFT     5
#define UCHART_SPACE_TOP      5
#define UCHART_SPACE_BOTTOM   5
#define UCHART_SPACE_RIGHT    60
#define UCHART_CANDLES_NUMBER 30
#define UCHART_CANDLES_OFFSET 1
#define UCHART_CANDLES_GAP    2
#define UCHART_CANDLES_WIDTH  6
#define UCHART_CANDLES_LINEW  2
#define UCHART_CANDLES_LINEO  2
#define UCHART_RECT_WIDTH     240
#define UCHART_RECT_HEIGHT    150
#define SYMBOL_POSTFIX        "bx"

enum ComboID {
   COMBO_SYMBOL=1,
   COMBO_VOLUME,
   COMBO_EXPIRATION,
   COMBO_TRADETYPE
};
enum PMODE {
   PMODE_BID=1,
   PMODE_ASK,
   PMODE_MIDDLE
};


enum BO_TYPE {
   UP_DOWN=0,
   BIG_SMALL,
   ODD_EVEN,
   RANGE
};

enum BO_CMD {
   CMD_Put=1,
   CMD_Call=2,
   CMD_Small=3,
   CMD_Big=4,
   CMD_Odd=5,
   CMD_Even=6,
   CMD_RangeIn=7,
   CMD_RangeOut=8
};


struct POSITIONS {
   int      ticket;
   string   expiration;
   int      type;
   int      cmd;
   int      exp_sec;
   int      price_mode;
   int      typeID;
   string   symbol;
   double   investment;
   double   payoff;
   datetime open_time;
   double   open_price;
   double   close_price;
};
struct BOCONFIG {
   int      ticket;
   string   expiration;
   string   play_mode;
   int      prohibited;
   string   time_section_mode;
   string   symbol;
   double   investment;
   double   pay_off;
   double   payoff_lv;   

   datetime open_time;
   double   open_price;
   double   close_price;
   int      single_order_limit;
   int      group_open_investment_limit;
   int      group_open_order_num_limit;
   int      login_open_investment_limit;
   int      login_open_order_num_limit ;
    
   int               PriceMode[2];
   double            PriceOffset[2];
   int               MaxVols[2];
   int               MinVols[2];
   int               StepVols[2];
   double            Payoff[2];
   double            LvPayoff[2];    
};
struct BOTimeSectionCfg {
	int id;
	char whiteLabelID[24];
	char symbol[24];
	int period;
	//BO_PlayMode playMode;
	//TimeSectionMode tSectionMode;
	char timeBegin[32];
	char timeEnd[32];
	bool enabled;
	bool prohibited;
	double payoffRatio;
	double lvPayoffRatio;
	int singleOrderlimit;
	int groupInvestLimit;
	int groupOrderNumLimit;
	int loginInvestLimit;
	int loginOrderNumLimit;


} ;
enum BO_PlayMode{
	AnyPlayMode=0,
	UpDown=1,
	SmallBig=2,
	OddEven=3,
	Range=4,
	AllPlayMode=100
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
   void              tradeDisable();      
   void              tradeEnable();    
private:

   bool              PanelLoaded;
   bool              firstEAThread;
   bool              showPosition;
   int               PriceDigits;
   int               CheckTime;   
   bool              hasExpiVal;

   
   bool              tradeCheck(const int _type);


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
   
   CEdit             edit_news;
   CEdit             edit_order;
   CEdit             edit_win;
   CEdit             edit_ordertxt;
   CEdit             edit_wintxt;
   CEdit             edit_winratiotxt;
   CEdit             edit_winratio;
   
   
   CPanel            panel_operation;
   CPanel            panel_payoff;
   CPanel            panel_trade;   

   
   //---- dynamic info
   CEdit             edit_symbol_price;
   CEdit             edit_up;
   CEdit             edit_down;
   CEdit             edit_payoffl;
   CEdit             edit_return;
   CEdit             edit_txtpayoff;
   CEdit             edit_return_put;
   CEdit             edit_txtpayoff_put;   
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
   bool              reloadConfig(double UpPrice,double DownPrice);
   bool              reloadSymbol();
   bool              reloadType(string symbol);
   bool              reloadExp();
   
   void              OutToStatus(string txt, color fcolor = clrBlack);
   void              OutToPosition(const int orders, const double invest);

   void              RefreshPositions();
   void              RefreshUI();      
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
   bool              getInitResult();  
protected:
   //--- create
   virtual bool      Create(const long chart,const string name,const int subwin, const int x1,const int y1,const int x2,const int y2);
   
   //--- internal event handlers
   virtual bool      OnResize(void);
   //--- handlers of the dependent controls events
   virtual void      Minimize(void);
   
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
   void              Concentration_limits();
   bool              TimeSectionsEnabled();
   void              CalculateReturn(int which);
   string            Exp_Sec2Str(const int _exp, const bool isShort=true);
   int               Exp_Str2Sec(string _exp);
   void              InsertOrder(const int ticket);
   void              ShowOrdersFromPosition(const int pos, const int orderCount);
   void              ShowOrderAsItem(POSITIONS &order, const int atPos);
   string            BytesNumber(const int _byte);
   string            OrderReject(int _login);  
   
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
