unit linealinter;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, TASeries, TAFuncSeries, Forms, Controls,
  Graphics, Dialogs, StdCtrls, Grids, ExtCtrls, ComCtrls,fpexprpars, claseli,clasematrix;

type

  { TForm1 }
  TArrSimp = array of Real;
  TArr2D = array of TArrSimp;
  TForm1 = class(TForm)
    btEjecuta: TButton;
    btAxis: TButton;
    btTraces: TButton;
    cbPropo: TCheckBox;
    ediEcua: TEdit;
    Grafica: TChart;
    GraficaConstantLine1: TConstantLine;
    GraficaConstantLine2: TConstantLine;
    ediError: TEdit;
    ediIntIzq: TEdit;
    ediIntDer: TEdit;
    GraficaLineSeries1: TLineSeries;
    Memo1: TMemo;
    Ecua: TStringGrid;
    Traces: TLineSeries;
    GraficaPoints: TLineSeries;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    meResu: TMemo;
    rdMetod: TRadioGroup;
    Secuencia:TStringList;
    TDatos: TStringGrid;
    tbZoom: TTrackBar;
    procedure btAxisClick(Sender: TObject);
    procedure btEjecutaClick(Sender: TObject);
    procedure btTracesClick(Sender: TObject);
    procedure cbPropoChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
    procedure tbZoomChange(Sender: TObject);
  private
    lineal : clLinea;
    matrix : clMatr;
    procedure findTraces();
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

//Funciones para arrays 2D hardcoded
function ArrSimp(const arr: array of Real):TArrSimp;
var i:Integer;
begin
  SetLength(Result,Length(arr));
  for i:=0 to high(arr) do
      Result[i]:=arr[i];
end;

function Arr2D(const arr: array of TArrSimp):TArr2D;
var i: Integer;
begin
  SetLength(Result,length(arr));
  for i:=0 to high(Result) do
      Result[i]:=arr[i];
end;



procedure TForm1.btEjecutaClick(Sender: TObject);
const
  N=4000;
  MIN=-10;
  MAX=10;
var i  ,k,p: Integer;
  j,
  xn,res : Real;
  M1,M2,M3,M4,M5:TArr2D;
  variables:TArrSimp;
  expresions:array of string;
  //El tipo de todas las matrices tiene que ser TArr2D
begin
  lineal:=clLinea.create;
  lineal.setError(StrToFloat(ediError.Text));
  lineal.setInterv(StrToFloat(ediIntIzq.Text),StrToFloat(ediIntDer.Text));
  lineal.setMetod(rdMetod.ItemIndex);
  lineal.setEcua(ediEcua.Text);
  meResu.Lines.Clear;
  meResu.Lines.Add(FloatToStr(lineal.execute()));
  TDatos.RowCount:=lineal.Resli.Count;



  //Limpieza de graf de funcion y punto intersec
  GraficaLineSeries1.clear;
  GraficaPoints.clear;
  j:=-3;
  while (j<N-1) do
  begin
  xn:=MIN+(MAX-MIN)*j/(N-1);
  GraficaLineSeries1.AddXY(xn,lineal.ecuacion(xn));
  //GraficaLineSeries1.AddXY(xn,StrToFloat(ediEcua.Text));
  j+=1;
  end;
  GraficaPoints.AddXY(StrToFloat(meResu.Text),lineal.ecuacion(StrToFloat(meResu.Text)));
  //Halla los traces cada ejecucion
  findTraces();

  for  i:=0 to lineal.Resli.Count-1 do
      begin
      TDatos.Cells[0,i]:=IntToStr(i);
      TDatos.Cells[1,i]:=lineal.Resli.Strings[i];
      TDatos.Cells[2,i]:=lineal.errLi.Strings[i];
      end;

  matrix.destroy;
end;


procedure TForm1.findTraces();
var i:Integer;
begin
  Traces.clear;
  Traces.AddXY(StrToFloat(lineal.Resli.Strings[1]),lineal.ecuacion(StrToFloat(lineal.Resli.Strings[1])));
  Traces.AddXY(StrToFloat(lineal.Resli.Strings[1]),0);
  for i:=1 to lineal.Resli.Count-2 do
  begin
      Traces.AddXY(StrToFloat(lineal.Resli.Strings[i]),lineal.ecuacion(StrToFloat(lineal.Resli.Strings[i])));
      Traces.AddXY(StrToFloat(lineal.Resli.Strings[i+1]),0);
  end;
end;

procedure TForm1.btTracesClick(Sender: TObject);
begin
  Traces.Active:=not Traces.Active;
end;



procedure TForm1.btAxisClick(Sender: TObject);
begin
  Grafica.Extent.YMin:=-10;
  Grafica.Extent.YMax:=10;

  Grafica.Extent.XMin:=-10;
  Grafica.Extent.XMax:=10;
  tbZoom.Position:=10;
end;

procedure TForm1.cbPropoChange(Sender: TObject);
begin
  Grafica.Proportional:=not Grafica.Proportional;
end;



procedure TForm1.FormCreate(Sender: TObject);
begin
  Grafica.Extent.UseYMax:=true;
  Grafica.Extent.UseYMin:=true;
  Grafica.Extent.UseXMax:=true;
  Grafica.Extent.UseXMin:=true
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  lineal.Destroy
end;

procedure TForm1.Memo1Change(Sender: TObject);
begin

end;

procedure TForm1.tbZoomChange(Sender: TObject);
begin

  Grafica.Extent.YMin:=tbZoom.Position;
  Grafica.Extent.YMax:=-tbZoom.Position;

  Grafica.Extent.XMin:=tbZoom.Position;
  Grafica.Extent.XMax:=-tbZoom.Position;

end;



end.

