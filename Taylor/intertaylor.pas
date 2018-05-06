unit interTaylor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Grids, ExtCtrls, claseTaylor;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnEje: TButton;
    cbOper: TComboBox;
    ediAng: TEdit;
    ediErr: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    rgAng: TRadioGroup;
    tmRes: TMemo;
    TDatos: TStringGrid;
    procedure btnEjeClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    Taylor:clTaylor;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

//ediAng.Text(laclase.execute);

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  Taylor.destroy
end;

procedure TForm1.btnEjeClick(Sender: TObject);
var i:Integer;
begin
  Taylor:=clTaylor.create;
  Taylor.setX(StrToFloat(ediAng.Text),rgAng.ItemIndex);
  Taylor.setError(StrToFloat(ediErr.Text));
  Taylor.setOper(cbOper.ItemIndex);
  tmRes.Lines.Add(FloatToStr(Taylor.execute()));
  TDatos.RowCount:=Taylor.Secuencia.Count;
  for i:=0 to Taylor.Secuencia.Count-1 do
  begin
    TDatos.Cells[0,i]:=IntToStr(i);
    TDatos.Cells[1,i]:=Taylor.Secuencia.Strings[i];
    TDatos.Cells[2,i]:=Taylor.ErrList.Strings[i];
  end;




end;

end.

