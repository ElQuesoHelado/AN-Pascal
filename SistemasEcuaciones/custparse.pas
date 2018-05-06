unit custParse;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, fpexprpars;

type
  TCustParse = class
  private
    FParser: TFPExpressionParser;
    expresion: string;
    procedure extraFunctions();


  public
    identVar: array of TFPExprIdentifierDef;
    procedure addExpression(Exp: string);
    procedure addVariable(Name: string; Value: real);
    function evaluate(): real;
    constructor Create;
    destructor Destroy; override;


  end;

implementation


constructor TCustParse.Create;
begin
  FParser := TFPExpressionParser.Create(nil);
  FParser.Builtins := [bcMath];
  extraFunctions();

end;

destructor TCustParse.Destroy;
begin
  FParser.Destroy;
end;


function IsNumber(AValue: TExprFloat): boolean;
begin
  Result := not (IsNaN(AValue) or IsInfinite(AValue) or IsInfinite(-AValue));
end;



procedure ExprFloor(var Result: TFPExpressionResult; const Args: TExprParameterArray);
// maximo entero
var
  x: double;
begin
  x := ArgToFloat(Args[0]);
  if x > 0 then
    Result.ResFloat := trunc(x)

  else
    Result.ResFloat := trunc(x) - 1;

end;

procedure ExprTan(var Result: TFPExpressionResult; const Args: TExprParameterArray);
var
  x: double;
begin
  x := ArgToFloat(Args[0]);
  if IsNumber(x) and ((frac(x - 0.5) / pi) <> 0.0) then
    Result.resFloat := tan(x)

  else
    Result.resFloat := NaN;
end;


procedure ExprSin(var Result: TFPExpressionResult; const Args: TExprParameterArray);
var
  x: double;
begin
  x := ArgToFloat(Args[0]);
  Result.resFloat := sin(x);

end;

procedure ExprCos(var Result: TFPExpressionResult; const Args: TExprParameterArray);
var
  x: double;
begin
  x := ArgToFloat(Args[0]);
  Result.resFloat := cos(x);

end;

procedure ExprLn(var Result: TFPExpressionResult; const Args: TExprParameterArray);
var
  x: double;
begin
  x := ArgToFloat(Args[0]);
  if IsNumber(x) and (x > 0) then
    Result.resFloat := ln(x)

  else
    Result.resFloat := NaN;

end;

procedure ExprLog(var Result: TFPExpressionResult; const Args: TExprParameterArray);
var
  x: double;
begin
  x := ArgToFloat(Args[0]);
  if IsNumber(x) and (x > 0) then
    Result.resFloat := ln(x) / ln(10)

  else
    Result.resFloat := NaN;

end;

procedure ExprSQRT(var Result: TFPExpressionResult; const Args: TExprParameterArray);
var
  x: double;
begin
  x := ArgToFloat(Args[0]);
  if IsNumber(x) and (x > 0) then
    Result.resFloat := sqrt(x)

  else
    Result.resFloat := NaN;

end;

procedure ExprPower(var Result: TFPExpressionResult; const Args: TExprParameterArray);
var
  x, y: double;
begin
  x := ArgToFloat(Args[0]);
  y := ArgToFloat(Args[1]);


  Result.resFloat := power(x, y);

end;

procedure TCustParse.extraFunctions();
begin
  with FParser.Identifiers do
  begin
    AddFunction('tan', 'F', 'F', @ExprTan);
    AddFunction('sin', 'F', 'F', @ExprSin);
    AddFunction('sen', 'F', 'F', @ExprSin);
    AddFunction('cos', 'F', 'F', @ExprCos);
    AddFunction('ln', 'F', 'F', @ExprLn);
    AddFunction('log', 'F', 'F', @ExprLog);
    AddFunction('sqrt', 'F', 'F', @ExprSQRT);
    AddFunction('floor', 'F', 'F', @ExprFloor);
    AddFunction('power', 'F', 'FF', @ExprPower);

  end;

end;


procedure TCustParse.addExpression(Exp: string);
begin
  FParser.Expression := Exp;
end;

procedure TCustParse.addVariable(Name: string; Value: real);
var
  len: integer;
begin
  len := length(identVar) + 1;
  setLength(identVar, len);
  identVar[len - 1] := FParser.Identifiers.AddFloatVariable(Name, Value);
  //FParser.Identifiers.AddFloatVariable(Name, Value);

end;



function TCustParse.evaluate(): real;
begin
  Result := ArgToFloat(FParser.Evaluate);
end;

end.
