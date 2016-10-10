//+------------------------------------------------------------------+
//|                                                     SpinEdit.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "WndContainer.mqh"
#include "Edit.mqh"
#include "BmpButton.mqh"
//+------------------------------------------------------------------+
//| Resources                                                        |
//+------------------------------------------------------------------+
#resource "res\\RightTransp25.bmp"
#resource "res\\LeftTransp25.bmp"
#resource "res\\Right25.bmp"
#resource "res\\Left25.bmp"
#define VOLEDIT_BUTTON_HEIGHT    25 //16
#define VOLEDIT_BUTTON_WIDTH     25 //16
#define VOLEDIT_BUTTON_OFF_X     0 //1
#define VOLEDIT_BUTTON_OFF_Y     0 //1
//+------------------------------------------------------------------+
//| Class CVolEdit                                                  |
//| Usage: class that implements the "Up-Down" control               |
//+------------------------------------------------------------------+
class CVolEdit : public CWndContainer
  {
private:
   //--- dependent controls
   CEdit             m_edit;                // the entry field object
   CBmpButton        m_inc;                 // the "Increment button" object
   CBmpButton        m_dec;                 // the "Decrement button" object
   //--- adjusted parameters
   double               m_min_value;           // minimum value
   double               m_max_value;           // maximum value
   //--- state
   double               m_value;               // current value
   int                  m_digits;              // decimal position
   double               m_step;                // step
   int                  m_height;
   uint                  m_lastClickTime;
public:
                     CVolEdit(void);
                    ~CVolEdit(void);
   //--- create
   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   //--- chart event handler
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- set up
   double            MinValue(void) const { return(m_min_value); }
   void              MinValue(const double value);
   double            MaxValue(void) const { return(m_min_value); }
   void              MaxValue(const double value);
   void              SetValues(const double _min, const double _max, const double _step, const double _value);
   int               Decimals(void) const { return(m_digits); }
   void              Decimals(const int value);
   double            Step(void) const { return (m_step); }
   void              Step(const double value);
   //--- state
   double            Value(void) const { return(m_value); }
   bool              Value(double value);
   //--- methods for working with files
   virtual bool      Save(const int file_handle);
   virtual bool      Load(const int file_handle);
   virtual bool      SetFont(const string fontname);

protected:
   //--- create dependent controls
   virtual bool      CreateEdit(void);
   virtual bool      CreateInc(void);
   virtual bool      CreateDec(void);
   //--- handlers of the dependent controls events
   virtual bool      OnClickInc(void);
   virtual bool      OnClickDec(void);
   //--- internal event handlers
   virtual bool      OnChangeValue(void);
   virtual bool      OnChangeText(void);
   void              SyncValue(void);
   double            DynamicStep(const bool isUp);
  };
//+------------------------------------------------------------------+
//| Common handler of chart events                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CVolEdit)
   ON_EVENT(ON_CLICK,m_inc,OnClickInc)
   ON_EVENT(ON_CLICK,m_dec,OnClickDec)
   ON_EVENT(ON_END_EDIT,m_edit,OnChangeText)
EVENT_MAP_END(CWndContainer)
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CVolEdit::CVolEdit(void) : m_min_value(0),
                             m_max_value(0),
                             m_value(0),
                             m_lastClickTime(0)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CVolEdit::~CVolEdit(void)
  {
  }
double CVolEdit::DynamicStep(const bool isUp){
   if(m_step>0) return m_step;
   
   double div=MathPow(10, MathFloor(MathLog10(m_value)));
   double rest=MathMod(m_value, div);
   
   if(m_value<div*10) {
      if(m_value==div) return (isUp)?div:div/10;
      if(rest == 0) 
         return div;
      else
         return (isUp)?(div-rest):rest;
   }
   return (isUp)?div*10:div;

}
//+------------------------------------------------------------------+
//| Create a control                                                 |
//+------------------------------------------------------------------+
bool CVolEdit::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {
//--- check height
   if(y2-y1<VOLEDIT_BUTTON_HEIGHT)
      return(false);
   if(x2-x1<(VOLEDIT_BUTTON_WIDTH+VOLEDIT_BUTTON_OFF_X)*2)
      return(false);
//--- call method of the parent class
   m_height = y2-y1;
   if(!CWndContainer::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);
//--- create dependent controls
   if(!CreateEdit())
      return(false);
   if(!CreateInc())
      return(false);
   if(!CreateDec())
      return(false);
//--- succeed
   return(true);
  }
bool CVolEdit::SetFont(const string fontname) {
   return m_edit.Font(fontname);
}
//+------------------------------------------------------------------+
//| Set current value                                                |
//+------------------------------------------------------------------+
bool CVolEdit::Value(double value)
  {
//--- check value
   double dVal = value; 
   if(value<m_min_value)
      dVal=m_min_value;
   if(value>m_max_value)
      dVal=m_max_value;
//step verify
   double dstep = 1;
   if(m_step!=0) dstep = m_step;
   double res = MathMod(dVal-m_min_value, dstep);
   if(res!=0) {
      int div = MathFloor((m_max_value-m_min_value)/dstep);
      int div2 = MathFloor((dVal-m_min_value)/dstep);
      if(div2>div) div2 = div;
      dVal = m_min_value + div2*dstep;
   } 
//--- if value was changed
   if(m_value!=dVal)
     {
      m_value=dVal;
      //--- call virtual handler
      return(OnChangeValue());
      //Print(m_value);
     }
//--- value has not been changed
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CVolEdit::Save(const int file_handle)
  {
//--- check
   if(file_handle==INVALID_HANDLE)
      return(false);
//---
   FileWriteDouble(file_handle,m_value);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CVolEdit::Load(const int file_handle)
  {
//--- check
   if(file_handle==INVALID_HANDLE)
      return(false);
//---
   if(!FileIsEnding(file_handle))
      Value(FileReadDouble(file_handle));
//--- succeed
   return(true);
  }
void CVolEdit::SetValues(const double _min,const double _max,const double _step, const double _value) {
   if(m_min_value != _min) m_min_value = _min;
   if(m_max_value != _max) m_max_value = _max;
   if(m_step != _step) Step(_step);
   Value(_value);
}  
//+------------------------------------------------------------------+
//| Set minimum value                                                |
//+------------------------------------------------------------------+
void CVolEdit::MinValue(const double value)
  {
//--- if value was changed
   if(m_min_value!=value)
     {
      m_min_value=value;
      //--- adjust the edit value
      Value(m_value);
     }
  }

void CVolEdit::Decimals(const int value) 
{
   if(value<0 || value > 8) m_digits = 2;
   m_digits = value;
}
void CVolEdit::Step(const double value)
{
   if(value<0 || value>m_max_value) m_step = MathPow(10, -m_digits);
   m_step = value;
}
//+------------------------------------------------------------------+
//| Set maximum value                                                |
//+------------------------------------------------------------------+
void CVolEdit::MaxValue(const double value)
  {
//--- if value was changed
   if(m_max_value!=value)
     {
      m_max_value=value;
      //--- adjust the edit value
      Value(m_value);
     }
  }
//+------------------------------------------------------------------+
//| Create the edit field                                            |
//+------------------------------------------------------------------+
bool CVolEdit::CreateEdit(void)
  {
//--- create
   if(!m_edit.Create(m_chart_id,m_name+"VEdit",m_subwin, VOLEDIT_BUTTON_OFF_X*2+VOLEDIT_BUTTON_WIDTH,0,Width()-VOLEDIT_BUTTON_OFF_X*2-VOLEDIT_BUTTON_WIDTH,Height()))
      return(false);
   if(!m_edit.Text(""))
      return(false);
   m_edit.ReadOnly(false);
   m_edit.TextAlign(ALIGN_CENTER);
   //if(m_edit.ReadOnly(false))
   //   return(false);
   if(!Add(m_edit))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Increment" button                                    |
//+------------------------------------------------------------------+
bool CVolEdit::CreateInc(void)
  {
//--- right align button (try to make equal offsets from top and bottom)
   int x1=Width()-(VOLEDIT_BUTTON_OFF_X+VOLEDIT_BUTTON_WIDTH);
   int y1=(Height() - VOLEDIT_BUTTON_HEIGHT)/2;
   int x2=x1+VOLEDIT_BUTTON_WIDTH;
   int y2=y1+VOLEDIT_BUTTON_HEIGHT;
//--- create
   if(!m_inc.Create(m_chart_id,m_name+"Inc",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_inc.BmpNames("::res\\RightTransp25.bmp","::res\\Right25.bmp"))
      return(false);
   if(!Add(m_inc))
      return(false);
//--- property
   m_inc.PropFlags(WND_PROP_FLAG_CLICKS_BY_PRESS);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Decrement" button                                    |
//+------------------------------------------------------------------+
bool CVolEdit::CreateDec(void)
  {
//--- right align button (try to make equal offsets from top and bottom)
   int x1=VOLEDIT_BUTTON_OFF_X;
   int y1=(Height() - VOLEDIT_BUTTON_HEIGHT)/2;
   int x2=x1+VOLEDIT_BUTTON_WIDTH;
   int y2=y1+VOLEDIT_BUTTON_HEIGHT;
//--- create
   if(!m_dec.Create(m_chart_id,m_name+"Dec",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_dec.BmpNames("::res\\LeftTransp25.bmp","::res\\Left25.bmp"))
      return(false);
   if(!Add(m_dec))
      return(false);
//--- property
   m_dec.PropFlags(WND_PROP_FLAG_CLICKS_BY_PRESS);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Handler of click on the "increment" button                       |
//+------------------------------------------------------------------+
bool CVolEdit::OnClickInc(void)
  {
   printf(GetTickCount());
   if((GetTickCount()- m_lastClickTime)<160)
   {
      return false;
   }
   m_lastClickTime = GetTickCount();
   SyncValue();
//--- try to increment current value
   return(Value(m_value+DynamicStep(true)));
  }
//+------------------------------------------------------------------+
//| Handler of click on the "decrement" button                       |
//+------------------------------------------------------------------+
bool CVolEdit::OnClickDec(void)
  {
   if((GetTickCount()- m_lastClickTime)<160)
   {
      return false;
   }
   m_lastClickTime = GetTickCount();
  SyncValue();
//--- try to decrement current value
   return(Value(m_value-DynamicStep(false)));
  }
//+------------------------------------------------------------------+
//| Handler of changing current state                                |
//+------------------------------------------------------------------+
bool CVolEdit::OnChangeValue(void)
  {
//--- copy text to the edit field edit
   m_edit.Text(DoubleToString(m_value, m_digits));
//--- send notification
   EventChartCustom(INTERNAL_EVENT,ON_CHANGE,m_id,0.0,m_name);
//--- handled
   return(Value(m_value));
  }
 bool CVolEdit::OnChangeText(void) {
   SyncValue();
   return(OnChangeValue());
 }
void CVolEdit::SyncValue(void)
  {
  
//--- copy text to the edit field edit
   double nv = StringToDouble(m_edit.Text());
   if(nv!=m_value) m_value=nv;
  }
 
//+------------------------------------------------------------------+
/*bool CVolEdit::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{
   if(id==CHARTEVENT_KEYDOWN)
   {
      switch(int(lparam))
      {
         case 38:          OnClickInc();           break;
         case 40:          OnClickDec();           break;
      }
   }
   return(true);

}
*/
