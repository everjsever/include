
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
#define PANEL_X               0
#define PANEL_Y               20
#define PANEL_HEIGHT          220
#define PANEL_WIDTH           100 //640
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


   
   CPanel            panel_operation;
   

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

   
 

   

   
   //---- Buttons
   CButton           buttonA;
   CButton           buttonB;
   CButton           buttonC;
   CButton           buttonD;
   //---- other config parameters
   int               language_idx;
   bool              withHistoryPad;
   
   //---- chart element
   CPanel            Candles[UCHART_CANDLES_NUMBER][3];
public:
                     CMTKTradePadDialog(void);
                    ~CMTKTradePadDialog(void);
   


   //--- chart event handler
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

     
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

   //---- update

protected:
   //--- create
   virtual bool      Create(const long chart,const string name,const int subwin, const int x1,const int y1,const int x2,const int y2);
   
   //--- internal event handlers
   virtual bool      OnResize(void);
   //--- handlers of the dependent controls events
   virtual void      Minimize(void);
   
   void              OnClickButtonA(void);
   void              OnClickButtonB(void);
   void              OnClickButtonC(void);
   void              OnClickButtonD(void);   
      

   

 private:
   void              ReDrawChart();


   
 };
//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CMTKTradePadDialog)
   ON_EVENT(ON_CLICK,buttonA,OnClickButtonA)
   ON_EVENT(ON_CLICK,buttonB,OnClickButtonB)
   ON_EVENT(ON_CLICK,buttonC,OnClickButtonC)
   ON_EVENT(ON_CLICK,buttonD,OnClickButtonD)

EVENT_MAP_END(CAppDialog)
