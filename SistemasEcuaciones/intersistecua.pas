unit interSistecua;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Grids, clsistem;

type

  { TForm1 }
  TArrSimp = array of extended;
  TArr2D = array of TArrSimp;

  TForm1 = class(TForm)
    Button1: TButton;
    btLess: TButton;
    btMore: TButton;
    ediError: TEdit;
    meEcua: TMemo;
    sgResults: TStringGrid;
    sgVar: TStringGrid;
    procedure btLessClick(Sender: TObject);
    procedure btMoreClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure meEcuaChange(Sender: TObject);

  private
    Sistema: TclSistem;


  public


  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }



procedure TForm1.FormCreate(Sender: TObject);
begin

end;

procedure TForm1.FormDestroy(Sender: TObject);
begin

end;

procedure TForm1.meEcuaChange(Sender: TObject);
begin

end;



procedure TForm1.Button1Click(Sender: TObject);
var
  i, j, sizeEV: integer;
  expresiones: array of string;
begin
  sizeEV := meEcua.Lines.Count;
  //if(sizeEV<>meVar.Lines.Count)then
  //Si no hay igual numero de ecuaciones que variables
  setLength(expresiones, sizeEV);



  Sistema := TclSistem.Create();
  Sistema.setError(StrToFloat(ediError.Text));


  setLength(Sistema.variables, sizeEV);
  Sistema.varname:='';
  for i := 0 to sizeEV - 1 do
  begin
    expresiones[i] := meEcua.Lines[i];
    Sistema.varname += sgVar.Cells[0,i];
    Sistema.variables[i] := StrToFloat(sgVar.Cells[1,i]);
  end;
  Sistema.passVarExp(expresiones);
  Sistema.Execute();




  //Fill TStringGrid
  sgResults.RowCount := Sistema.resultados.Count + 1;
  sgResults.Cells[1, 0] := Sistema.varname;
  for i := 0 to Sistema.resultados.Count - 1 do
  begin
    sgResults.Cells[1, i + 1] := Sistema.resultados.Strings[i];
    sgResults.Cells[2, i + 1] := Sistema.errores.Strings[i];
  end;



  //TStringGrid jacobiano
                           {
  for i := 0 to 2 do
    for j := 0 to 2 do
      StringGrid1.Cells[j, i] := FloatToStr(Sistema.jaco[i][j]);
                            }

  /// for i := 0 to 2 do
   //StringGrid1.Cells[0, i] := FloatToStr(Sistema.fx[i][0]);






  Sistema.Destroy;
end;

procedure TForm1.btLessClick(Sender: TObject);
begin
  sgVar.RowCount:=sgVar.RowCount-1;
end;

procedure TForm1.btMoreClick(Sender: TObject);
begin
  sgVar.rowCount:=sgVar.RowCount+1;
end;

end.





















