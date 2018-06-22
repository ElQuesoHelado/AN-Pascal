unit claseinter;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, custParse, fpexprpars;

type
  TIntegral = class
  private
    a, b, h: real;
    metodo: integer;
    area: boolean;
    expre: string;

  public
    parse: TCustParse;
    procedure getInterv(izq: real; dere: real);
    procedure getFunc(x: string);
    procedure esArea();
    procedure setMetod(x: integer);
    procedure seth(x: real);
    function solve(x: real): real;
    function trapezio(): real;
    function simp13(): real;
    function simp38(): real;
    function Execute(): real;
    constructor Create;
    destructor Destroy; override;
  end;


implementation

constructor TIntegral.Create;
begin
  parse := TCustParse.Create;
  area := False;
  metodo := 1;
  h := 0.001;
end;


destructor TIntegral.Destroy;
begin
  parse.Destroy;

end;


procedure TIntegral.getInterv(izq: real; dere: real);
begin
  a := izq;
  b := dere;
end;


procedure TIntegral.getFunc(x: string);
begin
  expre := x;
end;


procedure TIntegral.esArea();
begin
  area := True;
end;


procedure TIntegral.seth(x: real);
begin
  h := x;
end;

procedure TIntegral.setMetod(x: integer);
begin
  metodo := x;
end;


function TIntegral.solve(x: real): real;
var
  FParser: TCustParse;
begin
  FParser := TCustParse.Create;
  try
    //FParser.extraFunctions();
    FParser.AddVariable('x', x);
    FParser.AddExpression(expre);
    Result := FParser.evaluate;
  finally
    FParser.Free;
  end;
end;


function TIntegral.trapezio(): real;
var
  i: integer;
  xnact, remh, suma: real;
begin
  xnact := a;
  if (area) then
  begin
    Result := abs(solve(a));
    Result := (Result + abs(solve(b))) / 2;//(f(a)+f(b))/2
  end
  else
  begin
    Result := solve(a);
    Result := (Result + solve(b)) / 2;//(f(a)+f(b))/2
  end;

  suma := 0;
  i := 1;
  //se halla la suma
  repeat//se suma la funcion de var(a+h)....
    xnact := xnact + h;
    if (area) then
      suma := suma + abs(solve(xnact))
    else
      suma := suma + solve(xnact);
    i += 1;
  until (xnact >= b - h);

  Result := h * (Result + suma);
end;

//integral("2+(1/sqrt(x)+(1/(4*x)))",2,5)

function TIntegral.simp13(): real;
var
  n, res: real;
  i: integer;
begin
  n := (b - a) / (2 * h);
  res := 0;

  i := 0;
  while (i <= n - 1) do
  begin
    if (area) then
      res += 4 * abs(solve(a + (2 * i + 1) * h))
    else
      res += 4 * solve(a + (2 * i + 1) * h);

    i += 1;
  end;

  i := 1;
  while (i <= n - 1) do
  begin
    if (area) then
      res += 2 * abs(solve(a + (2 * i) * h))
    else
      res += 2 * solve(a + (2 * i) * h);

    i += 1;
  end;

  if (area) then
    Result := (h / 3) * (abs(solve(a)) + res + abs(solve(b)))
  else
    Result := (h / 3) * (solve(a) + res + solve(b));

end;


//integral("0.2+25*x-200*power(x,2)+675*power(x,3)-900*power(x,4)+400*power(x,5)",0,0.8)
function TIntegral.simp38(): real;
var
  i: integer;
  n, res: real;
begin
  n := (b - a) / (3 * h);
  res := 0;

  i := 1;
  while (i <= n+2) do
  begin
    if (area) then
      res += abs(solve(a + (3 * i - 3) * h)) + 3 * abs(solve(a + (3 * i - 2) * h)) +
        3 * abs(solve(a + (3 * i - 1) * h)) + abs(solve(a + (3 * i) * h))
    else
      res += solve(a + (3 * i - 3) * h) + 3 * solve(a + (3 * i - 2) * h) +
        3 * solve(a + (3 * i - 1) * h) + solve(a + (3 * i) * h);
    i += 1;
  end;

  Result := (3 * h / 8) * res;
end;


function TIntegral.Execute(): real;
var
  i: integer;
  suma: real;
begin
  //Metodos
  case metodo of
    0: Result := trapezio();
    1: Result := simp13();
    2: Result := simp38();
  end;
end;

end.
