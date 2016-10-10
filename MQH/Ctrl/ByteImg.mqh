//+------------------------------------------------------------------+
//|                                                           Buffer |
//|                    Copyright © 2006-2014, FINEXWARE Technologies |
//|                                                www.FINEXWARE.com |
//|         programming & support - Alexey Sergeev, Boris Gerschanov |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006-2014, FINEXWARE Technologies"
#property link      "www.FINEXWARE.com"
#property version		"1.00"
#property library

#include "FastFile.mqh"
//+------------------------------------------------------------------+
//| CBuffer class                                                    |
//+------------------------------------------------------------------+
class CByteImg
  {
public:
   void Clear() { ArrayResize(m_data,0); };
   bool Copy(const CByteImg &a) { ArrayCopy(m_data,a.m_data); return(true); };

public:
   //--- byte array
   uchar             m_data[];
   //--- specific data
   __8               __b8;
   __4               __b4;
   __2               __b2;
   __1               __b1;
   uchar             __b[];

public:
                     CByteImg() { Clear(); };
                     CByteImg(uchar &data[]) { Clear(); AssignArray(data); };
                    ~CByteImg() { Clear(); };

public:
   int Len() { return(ArraySize(m_data)); }
   int Size() { return(Len()); }

public:
   void Append(uchar byte) { int sz=ArraySize(m_data); ArrayResize(m_data,sz+1); m_data[sz]=byte; }
   //--- File write functions
   uint AssignArray(uchar &src[],uint src_start=0,int src_cnt=WHOLE_ARRAY) { int r=ArrayCopy(m_data,src,0,src_start,src_cnt); return(r); }
   uint AssignDouble(double v) { __8 b; __dbl d; d.v=v; b=(__8)d; return(AssignArray(b.v)); }
   uint AssignFloat(float v){ __4 b; __float d; d.v=v; b=(__4)d; return(AssignArray(b.v)); }
   uint AssignInt64(long v){ __8 b; __long d; d.v=v; b=(__8)d; return(AssignArray(b.v)); }
   uint AssignInt(int v){ __4 b; __int d; d.v=v; b=(__4)d; return(AssignArray(b.v)); }
   uint AssignShort(short v){ __2 b; __short d; d.v=v; b=(__2)d; return(AssignArray(b.v)); }
   uint AssignChar(char v){ __1 b; __char d; d.v=v; b=(__1)d; return(AssignArray(b.v)); }
   uint AssignString(string v) { StringToCharArray(v,__b,0,StringLen(v)); return(AssignArray(__b)); }

public:
   //--- File read functions
   uint ViewArray(uchar &dst[],uint dst_start,int cnt) { int r=ArrayCopy(dst,m_data,dst_start,0,cnt); return(r); }
   double ViewDouble() { __dbl d={0}; ViewArray(__b8.v,0,8); d=(__dbl)__b8; return(d.v); }
   float ViewFloat() { __float d={0}; ViewArray(__b4.v,0,4); d=(__float)__b4; return(d.v); }
   long ViewInt64() { __long d={0}; ViewArray(__b8.v,0,8); d=(__long)__b8; return((long)d.v); }
   int ViewInt() { __int d; d.v=0; ViewArray(__b4.v,0,4); d=(__int)__b4; return((int)d.v); }
   short ViewShort() { __short d={0}; ViewArray(__b2.v,0,2); d=(__short)__b2; return((short)d.v); }
   char ViewChar() { __char d={0}; ViewArray(__b1.v,0,1); d=(__char)__b1; return((char)d.v); }
   string ViewString() { ViewArray(__b,0,WHOLE_ARRAY); return(CharArrayToString(__b)); }
  };
//+------------------------------------------------------------------+
