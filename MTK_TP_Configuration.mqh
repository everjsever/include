//+------------------------------------------------------------------+
//|                                         MTK_TP_Configuration.mqh |
//|                       Copyright 2014, MTK Beijing Tech. Co., Ltd |
//|                                        https://www.mt4xitong.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MTK Beijing Tech. Co., Ltd"
#property link      "https://www.mt4xitong.com"
#property strict

#import "mtkbo.dll"
string fetchMailMsg(int, string, int);
string RequestBOCfg(string, string, string, string, int);
string HttpRequest(string, int, string, string, string, string, int);
#import

//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
#define TTEXT_OFFSET 8
#define CONFIG_MAX   1024
#define STR_BUFFER   8192
enum CFG_ARRAY_INDEX {
   CFG_SYMBOL=0,
   CFG_PLAYCMD,
   CFG_PERIOD,
   CFG_PRICE_MODE,
   CFG_PRICE_OFFSET,
   CFG_PAYOFF,
   CFG_MAX_VOLUME
};

enum BO_TYPE {
   UP_DOWN=1,
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

enum PMODE {
   PMODE_BID=1,
   PMODE_ASK,
   PMODE_MIDDLE
};

class MTK_TP_Configuration 
{
private:
   string      config_string;
   bool        config_ok;
   int         product_total;
   string      config_line[];
   int         config_total;

   string      symbols[CONFIG_MAX];
   int         playmodes[CONFIG_MAX];
   int         expirations[CONFIG_MAX];
   double      payoff[CONFIG_MAX][2];
   int         price_mode[CONFIG_MAX][2];
   int         price_offset[CONFIG_MAX][2];
   int         maxvolume[CONFIG_MAX][2];
   
public:
   string      pSymbol[CONFIG_MAX];
   int         pSymbol_Size;
   int         pType[CONFIG_MAX];
   int         pType_Size;
   int         pPeriod_Size;
   int         pPeriod[CONFIG_MAX];
   int         pInvest[CONFIG_MAX][2];
   int         pPriceMode[CONFIG_MAX][2];
   int         pPriceOffset[CONFIG_MAX][2];
   double      pPayoff[CONFIG_MAX][2];
   
   string      pSymbolSelected;
   int         pTypeSelected;
   int         pPeriodSelected;
   int         pPeriodIdx;

   string      trans_sn;  
   int         magic_number;       
private:
   bool        splitConfig();
   bool        insertSymbol(string _symbol);
   bool        insertType(int _type);
   
   bool        initType();
   bool        initPeriod();
   
   int         searchCfg(string symbol, int playmode, int expiration);
   
public:
               MTK_TP_Configuration(void);
               ~MTK_TP_Configuration(void);
   bool        setSymbol(string _symbol);
   bool        setType(const int SelectedIdx);
   bool        setExp(const int SelectedIdx) ;
   
   bool        configReady() {return config_ok; }
   int         TotalConfig() { return config_total; }
   
   int         getConfig();
   
   //---
   double      currentPayoff(const int offset=0);
   int         currentPriceMode(const int offset=0);
   int         currentPriceOffset(const int offset=0);
   int         currentMaxVol(const int offset=0);
   
};
//config string
// EURUSD|1|60|75
// EURUSD|1|90|70.5
// ....

MTK_TP_Configuration::MTK_TP_Configuration(void){
   config_string = "";
   product_total  = 0;
   config_total = 0;
   config_ok = false;   
   magic_number = 888888;
}

MTK_TP_Configuration::~MTK_TP_Configuration(void){
}
int MTK_TP_Configuration::searchCfg(string symbol,int playmode,int expiration) {
   if(config_total<=0) return -1;
   int i;
   for(i=0;i<config_total;i++) {
      if(StringCompare(symbols[i], symbol)!=0) continue;
      if(playmodes[i]!=playmode) continue;
      if(expirations[i]!=expiration) continue;
      return i;
   }
   return -1;
}
//------------------------------
int MTK_TP_Configuration::getConfig(void){
   printf("debug ==> get config with sn=%s and login=%d", trans_sn, AccountNumber());
   string body;
   StringInit(body, STR_BUFFER);
   body="";
   /*
   int max_try = 10;
   int i;
   bool found = false;
   printf("Try to get settings from Main Server...");
   for(i=0;i<max_try;i++) {
      StringInit(body, STR_BUFFER);
      body = fetchMailMsg(i, body, 2);
      if(StringCompare(body, "Alpha-Growth BO Configuration")==0) {
         StringInit(body, STR_BUFFER);
         body = fetchMailMsg(i, body, 3);
         found = true;
         break;
      }      
   }
   
   if(!found || StringCompare(body, "")==0) {
      printf("Try to get settings from Data Server...");
      StringInit(body, STR_BUFFER);
      body = "";
      body = RequestBOCfg("boconfig.agmdataservice.com", "http://boconfig.agmdataservice.com/GetBoConfig.php", StringConcatenate("type=snapshot&mt4login=", IntegerToString(AccountNumber()), "&sn=", trans_sn), body, STR_BUFFER); 
      if(StringCompare(body, "")==0) return ERR_RESOURCE_NOT_FOUND;
   }
   
   if(StringCompare(body, config_string)==0) return ERR_RESOURCE_DUPLICATED; 
   
   */
   body = "USDJPY.bx|1|60|3|10|0.750|10000`USDJPY.bx|2|60|3|10|0.70|10000`GBPCHF|1|60|3|10|0.750|10000`GBPCHF|2|60|3|10|0.70|10000";
   if(StringCompare(body, config_string)==0) return ERR_RESOURCE_DUPLICATED;
   //config_string = body;
   
   config_string="USDJPY.bx|1|60|3|10|0.750|10000`USDJPY.bx|2|60|3|10|0.70|10000`GBPCHF|1|60|3|10|0.750|10000`GBPCHF|2|60|3|10|0.70|10000";
   
   if(splitConfig())
      return ERR_NO_ERROR;
   else {
      printf("Config parser failed");
      return ERR_ARRAY_INVALID;
   }
}

bool MTK_TP_Configuration::splitConfig(void){
   string sep="`";
   ushort u_sep;
   u_sep=StringGetCharacter(sep,0);
   ArrayFree(config_line);
   
   pSymbol_Size = 0;   
   pType_Size = 0;
   pPeriod_Size = 0;
   
   config_total = StringSplit(config_string,u_sep,config_line);
   //PrintFormat("Strings obtained: %d lines", config_total);
   if(config_total>CONFIG_MAX) config_total = CONFIG_MAX;
   if(config_total>0) {
      sep="|";
      u_sep=StringGetCharacter(sep,0);
      string result[];
      int k;
      product_total  = 0;
      config_ok = true;
      int pos = 0;
      int play_cmd;
      int play_mode;
      int expi;
      int arroffset;
      for(int i=0;i<config_total;i++) {
         k = StringSplit(config_line[i], u_sep, result);
         if(k<7) continue;
         //printf("line : %s ==> %d", config_line[i], k);
         play_cmd = StrToInteger(result[CFG_PLAYCMD]);
         expi = StrToInteger(result[CFG_PERIOD]);
   
         if(play_cmd==CMD_Put) { 
            play_mode = UP_DOWN;
            arroffset = 1;
         }           
         else if(play_cmd==CMD_Call) {
            play_mode = UP_DOWN;
            arroffset = 0;
         }
         else if(play_cmd==CMD_Small) {
            play_mode = BIG_SMALL;
            arroffset = 1;
         }
         else if(play_cmd==CMD_Big) {
            play_mode = BIG_SMALL;
            arroffset = 0;
         }
         else if(play_cmd==CMD_Odd) {
            play_mode = ODD_EVEN;
            arroffset = 0;
         }
         else if(play_cmd==CMD_Even) {
            play_mode = ODD_EVEN;
            arroffset = 1;
         }
         else if(play_cmd==CMD_RangeIn) {
            play_mode = RANGE;
            arroffset = 0;
         }
         else { //if(play_cmd==CMD_RangeOut) {
            play_mode = RANGE;
            arroffset = 1;
         }
         pos = searchCfg(result[CFG_SYMBOL], play_mode, expi);
         if(pos<0) {
            symbols[product_total] = result[CFG_SYMBOL];
            playmodes[product_total] = play_mode; 
            expirations[product_total] = expi;
            pos = product_total;
         }   
         payoff[pos][arroffset] = StrToDouble(result[CFG_PAYOFF]);
         price_mode[pos][arroffset] = StrToInteger(result[CFG_PRICE_MODE]);
         price_offset[pos][arroffset] = StrToInteger(result[CFG_PRICE_OFFSET]);
         maxvolume[pos][arroffset] = StrToInteger(result[CFG_MAX_VOLUME]);
         if(StringCompare(result[CFG_SYMBOL], "")==0) continue;
         if(playmodes[product_total]<UP_DOWN || playmodes[product_total]>RANGE) continue;
         if(expirations[product_total]<=0) continue;
         insertSymbol(result[CFG_SYMBOL]);
         product_total++;
      }
      if(product_total==0) config_ok = false;
      printf("Total Symbols : %d", product_total);
      return config_ok;
   }
   return false;
}

bool MTK_TP_Configuration::insertSymbol(string _symbol) {
   int i;
   for (i=0;i<pSymbol_Size;i++) {
      if(StringCompare(_symbol, pSymbol[i])==0) return true;
   }
   pSymbol[pSymbol_Size] = _symbol;
   pSymbol_Size++;
   return true;
}

bool MTK_TP_Configuration::insertType(int _type) {
   int i;
   for (i=0;i<pType_Size;i++) {
      if(pType[i]==_type) return true;
   }
   pType[pType_Size] = _type;
   pType_Size++;
   return true;
}

bool MTK_TP_Configuration::setSymbol(string _symbol) {
   int i;
   //printf("Config : select %s", _symbol);
   for(i=0;i<pSymbol_Size;i++) {
      if(StringCompare(pSymbol[i], _symbol)==0) {
         pSymbolSelected = _symbol;
         return initType();
      }
   }
   return false;
}

bool MTK_TP_Configuration::initType(void) {
   int i;
   for(i=0;i<product_total;i++) {
      if(StringCompare(symbols[i], pSymbolSelected) == 0) insertType(playmodes[i]);
   }
   return true;
}

bool MTK_TP_Configuration::setType(const int SelectedIdx) {
   if(SelectedIdx<0 || SelectedIdx > pType_Size) return false;
   pTypeSelected = pType[SelectedIdx];
   return initPeriod();
}

bool MTK_TP_Configuration::setExp(const int SelectedIdx){
   if(SelectedIdx<0 || SelectedIdx > pPeriod_Size) return false;
   pPeriodSelected = pPeriod[SelectedIdx];
   pPeriodIdx = SelectedIdx;
   return true;
}

bool MTK_TP_Configuration::initPeriod(void){
   int i,j;
   pPeriod_Size = 0;
   for(i=0;i<product_total;i++) {
      if(StringCompare(symbols[i], pSymbolSelected)!=0) continue;
      if(playmodes[i]!=pTypeSelected) continue;
      pPeriod[pPeriod_Size]=expirations[i];
      for(j=0;j<2;j++) {
         pInvest[pPeriod_Size][j]=maxvolume[i][j];
         pPriceMode[pPeriod_Size][j]=price_mode[i][j];
         pPriceOffset[pPeriod_Size][j]=price_offset[i][j];
         pPayoff[pPeriod_Size][j]=payoff[i][j];
      }
      pPeriod_Size++;   
   }
   //printf("%d expirations available for %s[%d]", pPeriod_Size, pSymbolSelected, pTypeSelected); 
   return (pPeriod_Size>0);
}

double MTK_TP_Configuration::currentPayoff(const int offset){
   if(pPeriodIdx<0 || pPeriodIdx>pPeriod_Size-1) return -1;
   return pPayoff[pPeriodIdx][offset];
}

int MTK_TP_Configuration::currentPriceMode(const int offset){
   if(pPeriodIdx<0 || pPeriodIdx>pPeriod_Size-1) return -1;
   return pPriceMode[pPeriodIdx][offset];
}

int MTK_TP_Configuration::currentPriceOffset(const int offset){
   if(pPeriodIdx<0 || pPeriodIdx>pPeriod_Size-1) return -1;
   return pPriceOffset[pPeriodIdx][offset];
}

int MTK_TP_Configuration::currentMaxVol(const int offset){
   if(pPeriodIdx<0 || pPeriodIdx>pPeriod_Size-1) return -1;
   return pInvest[pPeriodIdx][offset];
}