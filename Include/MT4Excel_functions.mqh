//+------------------------------------------------------------------+
//|                                           MT4Excel_functions.mqh |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property show_inputs
#include <WinUser32.mqh>

#import "mt4excel.dll"

bool  ExcelOpen();//Îòêðûâàåò Excel è ñîçäàåò ÷èñòóþ ñòðàíèöó  
bool  ExcelClose();//Çàêðûâàåò Excel
bool  ExcelOpenPattern(int NumPatt);//Îòêðûâàåò Excel ïî øàáëîíó
bool  ExcelOpenFile(string FileName);//Îòêðûâàåò ôàéë Excel
bool  ExcelSave();//Ñîõðàíÿåì ôàéë
bool  ExcelSaveAs(string FileName);//Ñîõðàíÿåì ôàéë â FileName
bool  ExcelAddSheet(string Name);//Äîáàèòü ëèñò è ñäåëàòü åãî àêòèâíûì    
bool  ExcelSetFormulaCell(int X,int Y,string Value);//Çàïèñàòü ôîðìóëó â ÿ÷åéêó
double  ExcelGetValueCell(int X,int Y);//Ñ÷èòàòü ÷èñëî èç ÿ÷åéêè
string  ExcelGetTextCell(int X,int Y);//Ñ÷èòàòü òåêñò èç ÿ÷åéêè
string  ExcelGetFormulaCell(int X,int Y);//Ñ÷èòàòü ôîðìóëó èç ÿ÷åéêè
/*TypeD - òèï äèàãðàììû:
xl3DArea -4098        xl3DAreaStacked 78      xl3DAreaStacked100 79   xl3DBarClustered 60     xl3DBarStacked 61    xl3DBarStacked100 62 
xl3DColumn -4100      xl3DColumnClustered 54  xl3DColumnStacked 55    xl3DColumnStacked100 56 xl3DLine -4101       xl3DPie -4102 
xl3DPieExploded 70    xlArea 1                xlAreaStacked 76        xlAreaStacked100 77     xlBarClustered 57    xlBarOfPie 71 
xlBarStacked 58       xlBarStacked100 59      xlBubble 15             xlBubble3DEffect 87     xlColumnClustered 51 xlColumnStacked 52 
xlColumnStacked100 53 xlConeBarClustered 102  xlConeBarStacked 103    xlConeBarStacked100 104 xlConeCol 105        xlConeColClustered 99 
xlConeColStacked 100  xlConeColStacked100 101 xlCylinderBarClustered 95 xlCylinderBarStacked 96 xlCylinderBarStacked100 97 xlCylinderCol 98 
xlCylinderColClustered 92 xlCylinderColStacked 93 xlCylinderColStacked100 94 xlDoughnut -4120 xlDoughnutExploded 80 xlLine 4 xlLineMarkers 65 
xlLineMarkersStacked 66 xlLineMarkersStacked100 67 xlLineStacked 63 xlLineStacked100 64 xlPie 5 xlPieExploded 69 xlPieOfPie 68 xlPyramidBarClustered 109 
xlPyramidBarStacked 110 xlPyramidBarStacked100 111 xlPyramidCol 112 xlPyramidColClustered 106 xlPyramidColStacked 107 xlPyramidColStacked100 108 
xlRadar -4151 xlRadarFilled 82 xlRadarMarkers 81 xlStockHLC 88 xlStockOHLC 89 xlStockVHLC 90 xlStockVOHLC 91 xlSurface 83 
xlSurfaceTopView 85 xlSurfaceTopViewWireframe 86 xlSurfaceWireframe 84 xlXYScatter -4169 xlXYScatterLines 74 xlXYScatterLinesNoMarkers 75 
xlXYScatterSmooth 72 xlXYScatterSmoothNoMarkers 73 */  
bool ExcelSetDiagramma(int TypeD,string Title,string XRange,string YRange,int Left,int Top,int Riht,int Bottom);//Äîáàâëÿåò äèàãðàìó
bool ExcelDiagrammaAddRange();//Äîáàâèòü äàííûõ â äèàãðàììó. Ïåðâàÿ ñòðîêà - çàãîëîâîê
bool  ExcelSetValueCell(int X,int Y,double Value);//Çàïèñàòü ÷èñëî â ÿ÷åéêó
bool  ExcelSetTextCell(int X,int Y,string Value);//Çàïèñàòü òåêñò â ÿ÷åéêó
bool ExcelSetRange(string Range);//Çàïîìíèòü äèàïàçîí
string ExcelGetFormat();//Âîçâðàùàåò ôîðìàò äèàïàçîíà
bool ExcelSetFormat(string Format);//Çàäàòü ôîðìàò äëÿ äèàïîçàíà
bool ExcelSetFormula(string Formula);//Çàïèñàòü ôîðìóëó â äèàïàçîí
bool ExcelIsFormula();//true åñëè â äèàïàçîíå ôîðìóëà
int ExcelRangeCount();//Êîë-âî ÿ÷ååê â äèàïàçîíå
string ExcelRangeAdress();//Àäðåññ äèàïàçîíà
bool ExcelRangeColumnWidth(int Width);//Øèðèíà äèàïàçîíà
bool ExcelRangeRowHeight(int Height);//Âûñîòà äèàïàçîíà
bool ExcelRangeInteriorColor(int Color);//Öâåò ôîíà äèàïàçîíà
bool ExcelRangeFontColor(int Color);//Öâåò øðèôòà äèàïàçîíà
int ExcelGetLastErrorCode();//Êîä ïîñëåäíåé îøèáêè Excel
string ExcelGetLastErrorText();//Òåêñò ïîñëåäíåé îøèáêè Excel
#import

int CountRows_ReportErrors;

void Open_ReportErrors(){
   if (ExcelOpen()){
      Print("Open_ReportErrors Success!");
      //Add Header 
      CountRows_ReportErrors=1;
      ExcelSetTextCell(CountRows_ReportErrors,1,"Simbolo");
      ExcelSetTextCell(CountRows_ReportErrors,2,"Tiempo");
      ExcelSetTextCell(CountRows_ReportErrors,3,"Tipo");//Buy or Sell
      ExcelSetTextCell(CountRows_ReportErrors,4,"Volumen");
      ExcelSetTextCell(CountRows_ReportErrors,5,"Precio");
      ExcelSetTextCell(CountRows_ReportErrors,6,"Stop Loss");
      ExcelSetTextCell(CountRows_ReportErrors,7,"Take Profit");
      ExcelSetTextCell(CountRows_ReportErrors,8,"Beneficios");
      ExcelSetTextCell(CountRows_ReportErrors,9,"Balance");
      
   }else{
      Print("Open_ReportErrors Error:",ExcelGetLastErrorText());//Error mt4excel.dll
   }
}

void AddRow_ReportErrors(string Simbolo,datetime Tiempo,string Tipo,double Volumen,double Precio,double StopLoss,double TakeProfit,double Beneficio,double Balance){
   CountRows_ReportErrors++;
   ExcelSetValueCell(CountRows_ReportErrors,1,Simbolo);         
   ExcelSetValueCell(CountRows_ReportErrors,2,Fecha);         
}

void Close_ReportErrors(string filename){//filename.xls
   string dirpath=TerminalPath()+"\\MQL4\\Experts\\Projects\\MaxProfit_EA_MT4\\Reports\\";
   string filepath=dirpath+filename;
   ExcelSaveAs(filepath);
   ExcelClose();
}