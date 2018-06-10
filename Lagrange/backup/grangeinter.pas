unit grangeInter;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, TASeries, TAFuncSeries, Forms, Controls,
  Graphics, Dialogs, StdCtrls, Grids, custParse, clGrange, claseli;

type

  { TForm1 }
  TArrSimp = array of real;
  TArr2D = array of TArrSimp;

  TForm1 = class(TForm)
    btExecute: TButton;
    Chart1: TChart;
    Chart1ConstantLine1: TConstantLine;
    Chart1ConstantLine2: TConstantLine;
    PtsInter: TLineSeries;
    poli1Puntos: TLineSeries;
    poli2Puntos: TLineSeries;
    poli2: TLineSeries;
    poli1: TLineSeries;
    ediInput: TEdit;
    meResult: TMemo;
    sgData: TStringGrid;
    sgData1: TStringGrid;
    procedure btExecuteClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);


  private
    lagrange: TClGrange;
    lagrange2: TClGrange;
    intersec: clLinea;

  public


  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.btExecuteClick(Sender: TObject);
const
  N = 4000;
  MIN = -10;
  MAX = 10;
var
  i, j: integer;
  xn, menor, mayor: real;
  puntos: TArr2D;

begin
  lagrange := TClGrange.Create;
  //lagrange2 := TClGrange.Create;
  intersec := clLinea.Create;

  setLength(lagrange.Data, sgData.RowCount - 1, 2);
  //setLength(lagrange2.Data, sgData.RowCount - 1, 2);
  for i := 0 to sgData.RowCount - 2 do
  begin
    lagrange.Data[i][0] := StrToFloat(sgData.cells[0, i + 1]);
    lagrange.Data[i][1] := StrToFloat(sgData.cells[1, i + 1]);
    //lagrange2.Data[i][0] := StrToFloat(sgData1.cells[0, i + 1]);
    //lagrange2.Data[i][1] := StrToFloat(sgData1.cells[1, i + 1]);
  end;

  lagrange.getxn(StrToFloat(ediInput.Text));
  lagrange.Execute();
  //lagrange2.getxn(StrToFloat(ediInput.Text));
  //lagrange2.Execute();

  j := -3;
  while (j < N - 1) do
  begin
    xn := MIN + (MAX - MIN) * j / (N - 1);
    poli1.AddXY(xn, lagrange.Grapar.calPuntos(xn, lagrange.polin));
    //poli2.AddXY(xn, lagrange2.Grapar.calPuntos(xn, lagrange2.polin));
    j += 1;
  end;


  poli1Puntos.showLines := False;
  //poli2Puntos.showLines := False;

  for i := 0 to length(lagrange.Data) - 1 do
  begin
    poli1Puntos.AddXY(lagrange.Data[i][0], lagrange.Grapar.calPuntos(
      lagrange.Data[i][0], lagrange.polin));
    //poli2Puntos.AddXY(lagrange2.Data[i][0], lagrange2.Grapar.calPuntos(
      //lagrange2.Data[i][0], lagrange2.polin));
  end;


  //intersec.setEcua('(' + lagrange.polin + ')-(' + lagrange2.polin + ')');
  //intersec.setMetod(1);
  //intersec.setError(0.0001);
{

  //[-3,-1]
  intersec.setInterv(-3, -1);
  intersec.Execute();
  PtsInter.showLines := False;//(X ,Y)
  PtsInter.AddXY(intersec.Execute(), lagrange.Grapar.calPuntos(
    intersec.Execute(), lagrange.polin));

  //[0,1]
  intersec.setInterv(0, 1);
  intersec.Execute();
  PtsInter.AddXY(intersec.Execute(), lagrange.Grapar.calPuntos(
    intersec.Execute(), lagrange.polin));
  //[2,3]
  intersec.setInterv(2, 3);
  intersec.Execute();
  PtsInter.AddXY(intersec.Execute(), lagrange.Grapar.calPuntos(
    intersec.Execute(), lagrange.polin));

  //[4,5]
  intersec.setInterv(4, 5);
  intersec.Execute();
  PtsInter.AddXY(intersec.Execute(), lagrange.Grapar.calPuntos(
    intersec.Execute(), lagrange.polin));

  meResult.Lines.Add(lagrange.polin);
  meResult.Lines.Add(lagrange2.polin);
  meResult.Lines.Add(FloatToStr(lagrange.resultado));
 }



end;


procedure TForm1.FormCreate(Sender: TObject);
begin

end;

procedure TForm1.FormDestroy(Sender: TObject);
begin

end;

end.
