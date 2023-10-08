//+------------------------------------------------------------------+
//|                                                      shablon.mq4 |
//|                                             Viatcheslav Suvorov  |
//+------------------------------------------------------------------+
#property copyright "Viatcheslav Suvorov"
#property show_inputs
#include <WinUser32.mqh>

#import "mt4excel.dll"

bool  ExcelOpen();//��������� Excel � ������� ������ ��������  
bool  ExcelClose();//��������� Excel
bool  ExcelOpenPattern(int NumPatt);//��������� Excel �� �������
bool  ExcelOpenFile(string FileName);//��������� ���� Excel
bool  ExcelSave();//��������� ����
bool  ExcelSaveAs(string FileName);//��������� ���� � FileName
bool  ExcelAddSheet(string Name);//������� ���� � ������� ��� ��������    
bool  ExcelSetFormulaCell(int X,int Y,string Value);//�������� ������� � ������
double  ExcelGetValueCell(int X,int Y);//������� ����� �� ������
string  ExcelGetTextCell(int X,int Y);//������� ����� �� ������
string  ExcelGetFormulaCell(int X,int Y);//������� ������� �� ������
/*TypeD - ��� ���������:
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
bool ExcelSetDiagramma(int TypeD,string Title,string XRange,string YRange,int Left,int Top,int Riht,int Bottom);//��������� ��������
bool ExcelDiagrammaAddRange();//�������� ������ � ���������. ������ ������ - ���������
bool  ExcelSetValueCell(int X,int Y,double Value);//�������� ����� � ������
bool  ExcelSetTextCell(int X,int Y,string Value);//�������� ����� � ������
bool ExcelSetRange(string Range);//��������� ��������
string ExcelGetFormat();//���������� ������ ���������
bool ExcelSetFormat(string Format);//������ ������ ��� ���������
bool ExcelSetFormula(string Formula);//�������� ������� � ��������
bool ExcelIsFormula();//true ���� � ��������� �������
int ExcelRangeCount();//���-�� ����� � ���������
string ExcelRangeAdress();//������ ���������
bool ExcelRangeColumnWidth(int Width);//������ ���������
bool ExcelRangeRowHeight(int Height);//������ ���������
bool ExcelRangeInteriorColor(int Color);//���� ���� ���������
bool ExcelRangeFontColor(int Color);//���� ������ ���������
int ExcelGetLastErrorCode();//��� ��������� ������ Excel
string ExcelGetLastErrorText();//����� ��������� ������ Excel
#import

int start()
  { 
  
        if (ExcelOpen()) Print("�c����� ������� Excel"); else Print("�� ����������� Excel:",ExcelGetLastErrorText());//��������� Excel        
        ExcelSetTextCell(1,1,"����������");
        ExcelSetTextCell(2,1,"EURUSD");        
        ExcelSetTextCell(3,1,"GBPUSD");        
        ExcelSetTextCell(4,1,"USDCHF");        
        
        ExcelSetTextCell(1,2,"��������(0:0 GMT)");
        ExcelSetValueCell(2,2,iOpen("EURUSD",PERIOD_D1,0));        
        ExcelSetValueCell(3,2,iOpen("GBPUSD",PERIOD_D1,0));                
        ExcelSetValueCell(4,2,iOpen("USDCHF",PERIOD_D1,0));        
                
        ExcelSetTextCell(1,3,"��������� Bid");       
        ExcelSetValueCell(2,3,MarketInfo("EURUSD",MODE_BID));        
        ExcelSetValueCell(3,3,MarketInfo("GBPUSD",MODE_BID));                
        ExcelSetValueCell(4,3,MarketInfo("USDCHF",MODE_BID));        
        
        ExcelSetTextCell(1,4,"��������� �� ����");        
        ExcelSetRange("D2:D4");        
        ExcelSetFormula("=C2-B2");                
           
        ExcelSetRange("A1");
        ExcelRangeColumnWidth(15);
        ExcelSetRange("B1");
        ExcelRangeColumnWidth(20);
        ExcelSetRange("C1");
        ExcelRangeColumnWidth(20);
        ExcelSetRange("D1");
        ExcelRangeColumnWidth(20);
        ExcelSetRange("A1:D1");
        ExcelRangeInteriorColor(0x000000);   
        ExcelRangeFontColor(0xFFFFFF);                      
        
        ExcelSetDiagramma(103,"��������� �� ����","A2:A4","D1:D4",1,50,400,200);                  
        bool NeedLoop=true;  
        double lastEURUSD,lastGBPUSD,lastUSDCHF;
        double curEURUSD,curGBPUSD,curUSDCHF;
        while(NeedLoop){           
          curEURUSD=MarketInfo("EURUSD",MODE_BID);
          curGBPUSD=MarketInfo("GBPUSD",MODE_BID);
          curUSDCHF=MarketInfo("USDCHF",MODE_BID);
          if  (lastEURUSD!=curEURUSD){
            lastEURUSD=curEURUSD;
            ExcelSetValueCell(2,3,MarketInfo("EURUSD",MODE_BID));                    
          }
          if  (lastGBPUSD!=curGBPUSD){
            lastGBPUSD=curGBPUSD;
            ExcelSetValueCell(3,3,MarketInfo("GBPUSD",MODE_BID));                    
          }          
          if  (lastUSDCHF!=curUSDCHF){
            lastUSDCHF=curUSDCHF;
            ExcelSetValueCell(4,3,MarketInfo("USDCHF",MODE_BID));                    
          }                              
          Sleep(1000);
        }//while     
        
   return(0);
  }

void deinit()
  {
   ExcelSaveAs("C:\proba.xls");
   ExcelClose();
  }

