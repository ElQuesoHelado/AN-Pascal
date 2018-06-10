{ Copyright (C) 2007 Julian Schutsch

  This source is free software; you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 3 of the License, or (at your option)
  any later version.

  This code is distributed in the hope that it will be useful, but WITHOUT ANY
  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
  details.

  A copy of the GNU General Public License is available on the World Wide Web
  at <http://www.gnu.org/copyleft/gpl.html>. You can also obtain it by writing
  to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
  MA 02111-1307, USA.
  
  This Software is GPL, not LGPL as the libary it uses !
  
  Changelog
    10.8.2007 : Added "Buttons" Unit to avoid "TButton" missing error on 0.9.22 (Linux)

}
unit wnmainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Graphics, Dialogs, ExtCtrls, LCLType,
  ucmdbox, StdCtrls, Controls, Buttons, Menus, ComCtrls, claseli, claseinter,
  edo, custParse, TAGraph, TASeries;

type

  { TWMainForm }

  TWMainForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    cbWordWrap: TCheckBox;
    Chart1: TChart;
    Chart1AreaSeries1: TAreaSeries;
    Chart1ConstantLine1: TConstantLine;
    Chart1ConstantLine2: TConstantLine;
    Chart1LineSeries1: TLineSeries;
    Chart1LineSeries2: TLineSeries;
    CmdBox: TCmdBox;
    CbSetCaret: TComboBox;
    FontDialog: TFontDialog;
    Label1: TLabel;
    HistoryList: TListBox;
    MenuItem1: TMenuItem;
    PopupMenu1: TPopupMenu;
    RightPanel: TPanel;
    Splitter1: TSplitter;
    ReaderTimer: TTimer;
    ProcessTimer: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Split(Input: string; const Strings: TStrings);
    procedure puntosEdo(listax, listay: TStringList);
    function solve(x: real; expre: string): real;
    procedure Graficar(Xminimo: real; Xmaximo: real; expresion: string; esarea: boolean);
    procedure cbWordWrapChange(Sender: TObject);
    procedure CmdBoxInput(ACmdBox: TCmdBox; Input: string);
    procedure CbSetCaretChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ProcessTimerTimer(Sender: TObject);
    procedure ReaderTimerTimer(Sender: TObject);
  private
    hglobal: real;
    TextPosition: integer;
    DText: TStringList;
    Rdpw: boolean;
    FProcess: integer;
    lineal: clLinea;
    integral: TIntegral;
    diferen: TEdo;
  end;

var
  WMainForm: TWMainForm;


implementation

var
  Dir: string;

{ TWMainForm }

procedure TWMainForm.ReaderTimerTimer(Sender: TObject);
var
  i: integer;
  s: string;
begin
  for i := 0 to 0 do
  begin
    s := '';
    s := DText[TextPosition];{+#13#10;}
    Inc(TextPosition);
    CmdBox.TextColors(clAqua, clNavy);
    CmdBox.Writeln(s);
    if (TextPosition >= DText.Count) then
    begin
      CmdBox.ClearLine;
      CmdBox.TextColor(clYellow);
      CmdBox.Writeln(#27#10#196);
      TextPosition := 0;
      ReaderTimer.Enabled := False;
    end;
  end;
end;


procedure TWMainForm.FormCreate(Sender: TObject);
begin
  DoubleBuffered := True;
  hglobal := 0.0001;
  DText := TStringList.Create;
  if FileExists(Dir + '/demotext.txt') then
    DText.LoadFromFile(Dir + '/demotext.txt');
  CmdBox.StartRead(clSilver, clNavy, '/example/prompt/>', clYellow, clNavy);
  CmdBox.TextColors(clWhite, clNavy);
  CmdBox.Writeln(#27#218#27#10#191);
  CmdBox.Writeln(#27#179'Type "help" to see a short list of available commands.'#27#10#179);
  CmdBox.Writeln(#27#217#27#10#217);
end;

//*******

function TWMainForm.solve(x: real; expre: string): real;
var
  FParser: TCustParse;
begin
  FParser := TCustParse.Create;
  try
    FParser.AddVariable('x', x);
    FParser.AddExpression(expre);
    Result := FParser.evaluate;
  finally
    FParser.Free;
  end;
end;


procedure TWMainForm.puntosEdo(listax, listay: TStringList);
var
  i: integer;
begin
  //Chart1LineSeries1.clear;
  for i := 0 to listax.Count - 1 do
  begin
    Chart1LineSeries1.AddXY(StrToFloat(listax[i]), StrToFloat(listay[i]));
  end;
end;


procedure TWMainForm.Split(Input: string; const Strings: TStrings);
begin
  Assert(Assigned(Strings));
  Strings.Clear;
  Strings.Delimiter := ',';
  Strings.QuoteChar := '"';
  Strings.DelimitedText := Input;
end;



procedure TWMainForm.Graficar(Xminimo: real; Xmaximo: real; expresion: string;
  esarea: boolean);
const
  N = 4000;
  MIN = -50;
  MAX = 50;
var
  j, xn: real;
begin

  Chart1AreaSeries1.Clear;
  Chart1LineSeries2.Clear;

  //graph function
  j := -3;
  while (j < N - 1) do
  begin
    xn := MIN + (MAX - MIN) * j / (N - 1);
    Chart1LineSeries2.AddXY(xn, solve(xn, expresion));
    j += 1;
  end;

  //graph area
  if (esarea) then
  begin
    //Chart1AreaSeries1.AddXY(Xminimo, 0);
    j := -3;
    while (j < N - 1) do
    begin
      xn := Xminimo + (Xmaximo - Xminimo) * j / (N - 1);
      Chart1AreaSeries1.AddXY(xn, solve(xn, expresion));
      j += 1;
    end;
    Chart1AreaSeries1.AddXY(Xmaximo, 0);
  end;
end;




procedure TWMainForm.CmdBoxInput(ACmdBox: TCmdBox; Input: string);
var
  i, j: integer;
  metodo, funvar, res: string;
  valParse: TStringList;
  flgArea, pascom: boolean;
begin
  if rdpw then
  begin
    CmdBox.TextColors(clLime, clBlue);
    CmdBox.Writeln('Your Secret Password : ' + Input);
    CmdBox.TextColors(clSilver, clNavy);
    rdpw := False;
  end
  else
  begin
    rdpw := False;
    valParse := TStringList.Create;
    lineal := clLinea.Create;
    integral := TIntegral.Create;
    diferen := TEdo.Create;
    flgArea := False;
    pascom := True;
    metodo := '';
    Input := LowerCase(Input);
    if Input = 'help' then
    begin
      CmdBox.TextColors(clLime, clNavy);
      CmdBox.Writeln(#27#218#27#197#128#0#27#194#27#10#191);
      CmdBox.Writeln(#27#179' Command'#27#33#128#0#27#179' Explanation'#27#10#179);
      CmdBox.Writeln(#27#195#27#197#128#0#27#198#27#10#180);
      CmdBox.Writeln(#27#179' help'#27#33#128#0#27#179' Gives this list of Commands'#27#10#179);
      CmdBox.Writeln(#27#179' clear'#27#33#128#0#27#179' Clears the Content of CmdBox'#27#10#179);
      CmdBox.Writeln(#27#179' start'#27#33#128#0#27#179' Outputs the Content of Demotext.txt from the beginning'#27#10#179);
      CmdBox.Writeln(#27#179' stop'#27#33#128#0#27#179' Stops output and resets to Start'#27#10#179);
      CmdBox.Writeln(#27#179' pause'#27#33#128#0#27#179' Interrupts output'#27#10#179);
      CmdBox.Writeln(#27#179' resume'#27#33#128#0#27#179' Resumes output from the last position'#27#10#179);
      CmdBox.Writeln(#27#179' clearhistory'#27#33#128#0#27#179' Clears all history entries'#27#10#179);
      CmdBox.Writeln(#27#179' readpwd'#27#33#128#0#27#179' Read a Password (just as a test)'#27#10#179);
      CmdBox.Writeln(#27#179' exit'#27#33#128#0#27#179' Exit program'#27#10#179);
      CmdBox.Writeln(#27#217#27#197#128#0#27#193#27#10#217);
      CmdBox.TextColor(clSilver);
    end
    else
    if Input = 'readpwd' then
    begin
      rdpw := True;
    end
    else
    if Input = 'clearhistory' then
    begin
      CmdBox.TextColor(clYellow);
      CmdBox.Writeln('Clear History...');
      CmdBox.TextColor(clSilver);
      CmdBox.ClearHistory;
    end
    else
    if Input = 'start' then
    begin
      TextPosition := 0;
      ReaderTimer.Enabled := True;
      CmdBox.TextColors(clLime, clBlue);
      CmdBox.Writeln('Start...');
    end
    else if Input = 'stop' then
    begin
      TextPosition := 0;
      ReaderTimer.Enabled := False;
      CmdBox.TextColors(clRed, clBlue);
      CmdBox.Writeln('Stop...');
    end
    else if Input = 'pause' then
    begin
      ReaderTimer.Enabled := False;
      CmdBox.TextColors(clPurple, clBlue);
      CmdBox.Writeln('Pause...');
    end
    else if Input = 'resume' then
    begin
      ReaderTimer.Enabled := True;
      CmdBox.TextColors(clGreen, clBlue);
      CmdBox.Writeln('Continue...');
    end
    else if Input = 'clear' then
    begin
      CmdBox.Clear;
    end
    else if Input = 'cleargraph' then
    begin
      Chart1LineSeries1.Clear;
      Chart1AreaSeries1.Clear;
      Chart1LineSeries2.Clear;
    end
    else if Input = 'hvalue' then
    begin
      CmdBox.Writeln(FloatToStr(hglobal));
    end
    else if Input = 'exit' then
      Close
    else
    begin
      try
        //Parse metodo
        i := 1;
        while (i <> length(Input)) and (Input[i] <> '(') do
        begin
          metodo += Input[i];
          i += 1;
        end;

        //argumentos metodo
        Split(copy(Input, i + 1, length(Input) - i - 1), valParse);

        //Metodos validos
        if (metodo = 'newh') then
        begin
          hglobal := StrToFloat(valParse[0]);
        end
        else if (metodo = 'raiz') then
        begin
          //raiz("2*power(x,3)+2",-1.5,-0.25)
          //raiz(expre,a,b,metod)
          if (valParse.Count = 4) then
            lineal.setMetod(valParse[3]);

          lineal.seth(hglobal);
          lineal.getFunc(valParse[0]);
          lineal.getInterv(StrToFloat(valParse[1]), StrToFloat(valParse[2]));
          graficar(0, 0, valParse[0], False);
          res := floattostr(lineal.Execute());
        end
        else if (metodo = 'integral') then
        begin
          //integral(expre,a,b,metod)
          //integral("2*power(x+1,3)-1",-1,0)

          if (valParse.Count = 4) then
            integral.setMetod(StrToInt(valParse[3]));

          if (valParse.Count = 5) then begin
            integral.setMetod(StrToInt(valParse[3]));
            integral.esArea();
            flgArea:=True;
          end;

          integral.seth(hglobal);
          integral.getInterv(StrToFloat(valParse[1]),
            StrToFloat(valParse[2]));
          integral.getFunc(valParse[0]);
          graficar(StrToFloat(valParse[1]), StrToFloat(valParse[2]), valParse[0], flgArea);
          res := FloatToStr(integral.Execute());
        end
        else if (metodo = 'edo') then
        begin
          //edo("x*y",1,2,2)
          //edo(expre,xo,yo,xf,metodo)
          if (valParse.Count = 5) then
            diferen.setMetod(StrToInt(valParse[4]));

          diferen.seth(hglobal);
          diferen.setxf(StrToFloat(valParse[3]));
          diferen.getFunc(valParse[0]);
          diferen.getFront(StrToFloat(valParse[1]),
            StrToFloat(valParse[2]));
          res := FloatToStr(diferen.Execute());
          puntosEdo(diferen.resx, diferen.resy);
        end
        else
        begin
          CmdBox.TextColors(clYellow, ClRed);
          CmdBox.Writeln('Invalid Command!');
          res := '';
        end;

        CmdBox.TextColors(clLime, clNavy);
        if (res <> '') then
        begin
          CmdBox.Writeln(res);
        end;
      except
        CmdBox.TextColors(clYellow, ClRed);
        CmdBox.Writeln('Invalid Command!');
      end;
    end;
  end;
  valParse.Free;
  lineal.Destroy;
  integral.Destroy;
  diferen.Destroy;
  if rdpw then
    CmdBox.StartReadPassWord(clYellow, clNavy, 'Pwd:', clLime, clNavy)
  else
    CmdBox.StartRead(clSilver, clNavy, '/example/prompt/>', clYellow, clNavy);
  HistoryList.Clear;
  for i := 0 to CmdBox.HistoryCount - 1 do
    HistoryList.Items.Add(CmdBox.History[i]);
end;

procedure TWMainForm.CbSetCaretChange(Sender: TObject);
begin
  case cbSetCaret.ItemIndex of
    0: CmdBox.CaretType := cartLine;
    1: CmdBox.CaretType := cartSubBar;
    2: CmdBox.CaretType := cartBigBar;
  end;
  CmdBox.SetFocus;
end;

procedure TWMainForm.Button2Click(Sender: TObject);
begin
  CmdBox.ClearHistory;
  HistoryList.Clear;
end;

procedure TWMainForm.Button3Click(Sender: TObject);
begin
  FProcess := 0;
  ProcessTimer.Enabled := True;
end;

procedure TWMainForm.Button4Click(Sender: TObject);
begin
  FontDialog.Font := CmdBox.Font;
  if FontDialog.Execute then
  begin
    CmdBox.Font := FontDialog.Font;
  end;
end;

procedure TWMainForm.cbWordWrapChange(Sender: TObject);
begin
  if CmdBox.WrapMode = wwmWord then
    CmdBox.WrapMode := wwmChar
  else
    CmdBox.WrapMode := wwmWord;
end;

procedure TWMainForm.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TWMainForm.FormDestroy(Sender: TObject);
begin
  DText.Free;
end;

procedure TWMainForm.ProcessTimerTimer(Sender: TObject);
begin
  if FProcess = 100 then
  begin
    CmdBox.ClearLine;
    ProcessTimer.Enabled := False;
  end
  else
  begin
    CmdBox.TextColors(clRed, clBlue);
    CmdBox.Write('Processing [' + IntToStr(FProcess) + '%]'#13);
  end;
  Inc(FProcess);
end;

initialization
  {$I wnmainform.lrs}
  Dir := ExtractFileDir(ParamStr(0));
end.
