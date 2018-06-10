unit intIntegral;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, TASeries, uCmdBox, Forms, Controls,
  Graphics, Dialogs, StdCtrls, claseinter;

type

  { TForm1 }

  TForm1 = class(TForm)
    btExecute: TButton;
    Chart1: TChart;
    Chart1ConstantLine1: TConstantLine;
    Chart1ConstantLine2: TConstantLine;
    Chart1LineSeries1: TLineSeries;
    ediIntera: TEdit;
    ediInterb: TEdit;
    ediFunc: TEdit;
    edinIn: TEdit;
    meResu: TMemo;
    procedure btExecuteClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    integral:TIntegral;

  public

  end;

var
  Form1: TForm1;

implementation

procedure TForm1.FormCreate(Sender: TObject);
begin

end;

procedure TForm1.btExecuteClick(Sender: TObject);
begin
  integral:=TIntegral.Create;
  //set de var y func
  integral.getInterv(StrToFloat(ediIntera.text),StrToFloat(ediInterb.text)
  ,StrToInt(edinIn.Text));
  integral.getFunc(ediFunc.text);
  //graf de func


  meResu.Lines.Add(FloatToStr(integral.execute()));

end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  integral.Destroy;

end;




{$R *.lfm}

end.

