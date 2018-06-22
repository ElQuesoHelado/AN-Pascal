unit clGrange;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, custParse;

type
  TArrSimp = array of real;
  TArr2D = array of TArrSimp;

  TGrange = class
  private
    xn: real;
  public
    Datax: TArrSimp;
    Datay: TArrSimp;
    tempxTList: TStringList;
    tempyTList: TStringList;

    DEBUG: string;

    polin: string;
    resultado: real;
    Grapar: TCustParse;

    procedure getxn(X: real);
    function Execute():string;
    procedure Split(Input: string; const Strings: TStrings);
    function getValues(xs: string; ys: string): boolean;
    //procedure getValues(xs: TArrSimp;ys:TArrSimp);overload;
    constructor Create;
    destructor Destroy; override;

  end;

implementation

constructor TGrange.Create;
begin
  Grapar := TCustParse.Create;
  tempxTList := TStringList.Create;
  tempyTList := TStringList.Create;
  setlength(Datax, 0);
  setlength(Datay, 0);
end;

destructor TGrange.Destroy;
begin

end;


procedure TGrange.getxn(X: real);
begin
  xn := X;
end;

procedure TGrange.Split(Input: string; const Strings: TStrings);
begin
  Assert(Assigned(Strings));
  Strings.Clear;
  Strings.QuoteChar := '"';
  Strings.DelimitedText := Input;
end;

function TGrange.getValues(xs: string; ys: string): boolean;
var
  i: integer;
begin
  Result := True;

  //Not valid input
  if (xs[1] <> '[') or (ys[1] <> '[') or (xs[length(xs)] <> ']') or
    (ys[length(ys)] <> ']') then
  begin
    //DEBUG:='CONDICION INICIAL';
    DEBUG:=xs;
    Result := False;
    exit;
  end;

  Delete(xs, 1, 1);
  setlength(xs, length(xs) - 1);
  split(xs, tempxTList);

  Delete(ys, 1, 1);
  setlength(ys, length(ys) - 1);
  split(ys, tempyTList);

  if (tempxTList.count <> tempyTList.count)then
  begin
    //DEBUG:=xs;
    Result := False;
    exit;
  end;


  //pasar valores TStringList a TArrSimp
  setLength(Datax, tempxTList.Count);
  setLength(Datay, tempyTList.Count);

  for i := 0 to tempxTList.Count - 1 do
    if (not (TryStrToFloat(tempxTList[i], Datax[i]))) or
      (not (TryStrToFloat(tempyTList[i], Datay[i]))) then
    begin
      Result := False;
      setLength(Datax, 0);
      setLength(Datay, 0);
      break;
    end;

  ////imprimir valores array
  DEBUG := '';
  for i := 0 to length(Datay) - 1 do
    DEBUG += 'ttt' + FloatToStr(Datay[i]);

end;

//procedure TGrange.getValues(xs: TArrSimp;ys:TArrSimp);overload;
//begin
//  Data[0]:=xs;
//  Data[1]:=ys;
//end;


function TGrange.Execute():string;
var
  i, j: integer;
  nume: string;
  denom: real;
  temporal: string;
begin
  //Hallar polinomio

  Grapar.addVariable('x', xn);
  polin := '';
  temporal := '';
  nume := '';
  denom := 1;
  for i := 0 to length(Datax) - 1 do
  begin
    denom := 1;
    nume := '';
    for j := 0 to length(Datay) - 1 do//Solo trabaja x's
    begin
      if (j = i) then
        continue;

      denom := denom * (Datax[i] - Datax[j]);
                        {
        if(j=length(data)-1)then
        continue;
                         }
      nume := nume + '(x-' + floatToStr(Datax[j]) + ')*';

    end;
    //nume:=nume+'(x-'+floatToStr(data[j][0])+')';
    setLength(nume, length(nume) - 1);
    temporal := '((' + floatToStr(Datay[i]) + ')*' + nume + '/(' +
      floatToStr(denom) + '))+';

    polin := polin + temporal;
  end;
  setLength(polin, length(polin) - 1);
  DEBUG:=polin;
  Result:=polin;
  //Grapar.addExpression(polin);
  //resultado := Grapar.evaluate();
end;

end.
