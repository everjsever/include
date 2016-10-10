//+------------------------------------------------------------------+
//|                                                         FastFile |
//|                    Copyright © 2006-2012, Finexware Technologies |
//|                                                www.FINEXWARE.com |
//|      programming & development - Alexey Sergeev, Boris Gershanov |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006-2012, Finexware Technologies"
#property link      "www.FINEXWARE.com"
#property version		"1.00"
#property library
//+------------------------------------------------------------------+
//| CFastFile class                                                  |
//+------------------------------------------------------------------+
class CFastFile
  {
   //--- structures, used for conversion to uchar array
   struct __8 { uchar v[8]; };
   struct __4 { uchar v[4]; };
   struct __2 { uchar v[2]; };
   struct __1 { uchar v[1]; };

   struct __dbl { double v; };
   struct __float { float v; };
   struct __long { long v; };
   struct __int { int v; };
   struct __short { short v; };
   struct __char { char v; };

public:
   uchar             m_data[];   // uchar array
   int               m_size;     // size
   int               m_pos;      // current position
   uchar             m_delim;    // delimiter char (data separator for CSV mode)

public:
                     CFastFile() { Clear(); m_delim=';'; };
   //--- constructor with initialization of file data from array
                     CFastFile(uchar &data[]) { Clear(); WriteArray(data); m_pos=0; m_delim=';'; };
                    ~CFastFile() { Clear(); };
   //--- clear file
   virtual void Clear() { m_pos=0; m_size=0; ArrayResize(m_data,0); };

public:
   //--- functions for working with file properties
   //--- set delimiter (data separator) for CSV mode
   void Delim(uchar delim=';') { m_delim=delim; }
   //--- gets file size
   int Size() { m_size=ArraySize(m_data); return(m_size); }
   //--- gets current position
   int Tell() { return(m_pos); }
   //--- seek
   void Seek(int offset,int origin)
     {
      if(origin==SEEK_SET) m_pos=offset;
      if(origin==SEEK_CUR) m_pos+=offset;
      if(origin==SEEK_END) m_pos=m_size-offset;
      m_pos=(m_pos<0)?0:m_pos;
      m_pos=(m_pos>m_size)?m_size:m_pos; // allign
     }
   //--- checking of end of file (EOF)
   bool IsEnding() { return(m_pos>=m_size); }
   //--- checking of end of line
   bool IsLineEnding() { return(m_data[m_pos]=='\r' || m_data[m_pos]=='\n'); }

public:
   //--- functions for writing the data to file
   //--- write uchar array
   uint WriteArray(uchar &src[],uint src_start=0,int src_cnt=WHOLE_ARRAY)
     {
      int r=ArrayCopy(m_data,src,m_pos,src_start,src_cnt);
      if(r>0) { m_pos+=r; m_size=ArraySize(m_data); }
      return(r);
     }
   //--- write data
   uint WriteDouble(double v) { __8 b; __dbl d; d.v=v; b=d; return(WriteArray(b.v)); }
   uint WriteFloat(float v){ __4 b; __float d; d.v=v; b=d; return(WriteArray(b.v)); }
   uint WriteLong(long v){ __8 b; __long d; d.v=v; b=d; return(WriteArray(b.v)); }
   uint WriteInt(int v){ __4 b; __int d; d.v=v; b=d; return(WriteArray(b.v)); }
   uint WriteShort(short v){ __2 b; __short d; d.v=v; b=d; return(WriteArray(b.v)); }
   uint WriteChar(char v){ __1 b; __char d; d.v=v; b=d; return(WriteArray(b.v)); }
   //--- write integer - for compatibility with standard FileWriteInteger
   uint WriteInteger(int v,int sz=INT_VALUE)
     {
      if(sz==CHAR_VALUE) return(WriteChar((char)v));
      if(sz==SHORT_VALUE) return(WriteShort((short)v));
      return(WriteInt(v));
     }
   //--- write string
   uint WriteString(string v)
     {
      uchar b[];
      StringToCharArray(v,b,0,StringLen(v));
      return(WriteArray(b));
     }
   //--- write string cnt=-1 means CSV mode with addition of \r\n
   uint WriteString(string v,int cnt)
     {
      uchar b[];
      StringToCharArray(v,b,0,cnt);
      uint w=WriteArray(b);
      if(cnt<0) { WriteChar('\r'); WriteChar('\n'); }
      return(w+2*(cnt<0));
     }

public:
   //--- functions for reading from file
   //--- read array
   uint ReadArray(uchar &dst[],uint dst_start=0,int cnt=WHOLE_ARRAY)
     {
      int r=ArrayCopy(dst,m_data,dst_start,m_pos,cnt);
      if(r>0) m_pos+=r;
      return(r);
     }
   double ReadDouble() { __8 b; __dbl d; ReadArray(b.v,0,8); d=b; return(d.v); }
   float ReadFloat()   { __4 b; __float d; ReadArray(b.v,0,4); d=b; return(d.v); }
   long ReadLong()     { __8 b; __long d; ReadArray(b.v,0,8); d=b; return(d.v); }
   int ReadInt()       { __4 b; __int d; ReadArray(b.v,0,4); d=b; return(d.v); }
   short ReadShort()   { __2 b; __short d; ReadArray(b.v,0,2); d=b; return(d.v); }
   char ReadChar()     { __1 b; __char d; ReadArray(b.v,0,1); d=b; return(d.v); }
   //--- read integer - for compatibility with standard FileReadInteger
   int ReadInteger(int sz=INT_VALUE)
     {
      if(sz==CHAR_VALUE) return(ReadChar());
      if(sz==SHORT_VALUE) return(ReadShort());
      return(ReadInt());
     }
   double ReadNumber() { return(StringToDouble(ReadString(-1))); } // read number to separator and convert it to double
   //--- read string. cnt=-1 means CSV mode - reading to delimiter (data separator)
   string ReadString(int cnt)
     {
      int i; bool b=false; uchar c=0;
      if(cnt<0)
        {
         for(i=m_pos; i<m_size; i++)
           {
            c=m_data[i];
            if(c==m_delim || c=='\r' || c=='\n') break;
           }
         cnt=i-m_pos; b=true;
        } // find delimiter
      uchar dst[];
      ReadArray(dst,0,cnt);
      if(b) m_pos+=1+(c=='\r');
      m_pos=(m_pos>m_size)?m_size:m_pos;
      return(CharArrayToString(dst));
     }

public:
   //--- functions, used to save data
   //--- save file to uchar array
   uint Save(uchar &v[]) { return((uint)ArrayCopy(v,m_data,0,0)); };
   //--- save file to the real file on disk. h - file handle (the file must be opened)
   uint Save(int h) { return(FileWriteArray(h,m_data)); };
   //--- save file to the real file on disk. file - file name
   uint Save(string file)
     {
      int h=FileOpen(file,FILE_BIN|FILE_ANSI|FILE_WRITE|FILE_SHARE_WRITE);
      if(h<=0) return(0);
      FileSeek(h,0,SEEK_SET);
      uint s=FileWriteArray(h,m_data);
      FileClose(h);
      return(s);
     }

public:
   //--- functions, used for loading of data
   //--- load file from uchar array
   uint Load(uchar &v[])
     {
      m_pos=0;
      ArrayResize(m_data,0);
      uint r=ArrayCopy(m_data,v);
      m_size=ArraySize(m_data);
      return(r);
     };
   //--- load data from real file on disk. h - file handle (the file must be opened)
   uint Load(int h)
     {
      m_pos=0;
      ArrayResize(m_data,0);
      uint r=FileReadArray(h,m_data,0,int(FileSize(h)-FileTell(h)));
      m_size=ArraySize(m_data);
      return(r);
     };
   //--- load data from real file on disk. file - file name
   uint Load(string file)
     {
      int h=FileOpen(file,FILE_BIN|FILE_ANSI|FILE_READ|FILE_SHARE_READ);
      if(h<=0) return(0);
      m_pos=0;
      ArrayResize(m_data,0);
      uint r=FileReadArray(h,m_data,0,int(FileSize(h)));
      m_size=ArraySize(m_data);
      FileClose(h);
      return(r);
     }
  };
//+------------------------------------------------------------------+
