unit claseli;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, fpexprpars;

type
  clLinea = class
  private
    resAct, resPast, InteIzq,//Intervalo
    InteDer, errAllo, h: real;
    contIte,//Contador limite de iteraciones,
    Metodo: integer;

    ecua, ecuainter: string;

    function bisec(a: real; b: real): real;
    function falPos(a: real; b: real): real;
    function NewRaph(a: real): real;
    function Secante(a: real): real;
    function bolzano(izq: real; dere: real): real;

  public
    ecGraf, resultado: real;
    Temporal, errAllow: real;
    ResLi, Resliy: TStringList;//Lista de results y errors finales
    errLi: TStringList;
    FParser: TFPExpressionParser;
    FParserSist: TFPExpressionParser;
    //function principal(izq: real; dere: real): real; overload;
    //function principal(xn: real): real; overload;
    function aproximar(izq: real; dere: real): real;
    function finalizar(xn: real): real;

    function Execute(): boolean;
    procedure seth(x: real);
    procedure getInterv(x: real; y: real);
    procedure setMetod(x: string);
    procedure getFunc(x: string);
    procedure getFuncInter(x: string);
    function ecuacion(xn: real): real;
    function ecuacionInter(xn: real): real;
    constructor Create;
    destructor Destroy; override;
  end;


implementation

const
  maxIte = 10000;


constructor clLinea.Create;
begin
  //Se crean las listas de resultados y errores
  //Se agrega un elemento 0
  //FParser:=TFpExpressionParser.Create(nil);
  ResLi := TStringList.Create;
  ResLiy := TStringList.Create;
  errLi := TStringList.Create;
  errLi.Add('');
  //Creacion del parser
  //valores iniciales de iteracions y resultados
  contite := 0;
  resAct := 2;
  resPast := 1;
  h := 0.001;
  metodo := 0;

end;

destructor clLinea.Destroy;
begin
  //Se liberan las dos listas
  ResLi.Free;
  ResLiy.Free;
  errLi.Free;

end;

procedure elevado(var Result: TFPExpressionResult; const Args: TExprParameterArray);
var
  x, n: double;
begin
  x := ArgToFloat(Args[0]);
  n := ArgToFloat(Args[1]);
  Result.resFloat := power(x, n);
end;

function clLinea.ecuacion(xn: real): real;
begin     //El parser resuelve la ecuacion
  FParser := TFpExpressionParser.Create(nil);
  try
    FParser.BuiltIns := [bcMath, bcConversion];
    //reemplaza el (x^n) por power(x,n) para la grafica
    FParser.Identifiers.AddFunction('power', 'F', 'FF', @elevado);
    FParser.Identifiers.AddFloatVariable('x', xn);//se usa la variable seteada
    FParser.Expression := ecua;//la funcion se obtiene por interfaz
    //ecGraf:=StrToFloat(FParser.Expression);
    Result := FParser.Evaluate.ResFloat;
    ecGraf := Result;
  finally
    FParser.Free;
  end;

  //Result:=2*power(xn,3)+2 //Default
  //Result:=power(x,2)
  //Result:=power(x,3)-power(x,2)-2*x-4; //Intersec
  //Result:=power(x,3)-3*x    //la 4ta
  //Result:=power(x,2)+power(3,1/4)-6;
  //Result:=power(x+1,4)-3;


  //x*sin(power(x,3))
  //2*power(x,3)-2*power(x,2)
end;

function clLinea.ecuacionInter(xn: real): real;
begin     //El parser resuelve la ecuacion
  FParser := TFpExpressionParser.Create(nil);
  try
    FParser.BuiltIns := [bcMath, bcConversion];
    FParser.Identifiers.AddFunction('power', 'F', 'FF', @elevado);
    FParser.Identifiers.AddFloatVariable('x', xn);//se usa la variable seteada
    FParser.Expression := ecuainter;//la funcion se obtiene por interfaz
    Result := FParser.Evaluate.ResFloat;
    ecGraf := Result;
  finally
    FParser.Free;
  end;
end;


//Los metodos
function clLinea.bisec(a: real; b: real): real;
begin
  Result := (a + b) / 2;
end;

function clLinea.falPos(a: real; b: real): real;
begin
  Result := a - (ecuacion(a) * ((b - a) / (ecuacion(b) - ecuacion(a))));

end;

function clLinea.NewRaph(a: real): real;  //*******************
begin
  //Por definicion de derivada
  Result := a - ecuacion(a) / ((ecuacion(a + h) - ecuacion(a)) / h);
end;

function clLinea.Secante(a: real): real;
begin  //h=error/10
  Result := a - (2 * (h / 10) * ecuacion(a)) /
    (ecuacion(a + (h / 10)) - ecuacion(a - (h / 10)));
end;

//Evalua bolzano
function clLinea.bolzano(izq: real; dere: real): real;
begin
  Result := ecuacion(izq) * ecuacion(dere);
end;


//Sets de error, intervalos y metodo a usar
procedure clLinea.seth(x: real);
begin
  h := x;
end;

procedure clLinea.getInterv(x: real; y: real);
begin
  InteIzq := x;
  InteDer := y;
end;

procedure clLinea.setMetod(x: string);
begin
  Metodo := StrToInt(x);
end;

procedure clLinea.getFunc(x: string);
begin
  ecua := x;
  ecuaInter := x;
end;

procedure clLinea.getFuncInter(x: string);
begin
  ecuaInter := x;
end;


function clLinea.Execute(): boolean;
var
  resParcial, hpaso,i, a, b: real;
  n: integer;
begin

  //Result := True;
  //if (ecuacion(InteIzq) * ecuacion(InteDer) > 0.0) then//si no existe hay raiz
  //begin
  //  Result := False;
  //  exit;
  //end;



  //raiz("power(x,4)-3*power(x,2)+x",-2,2)

  i:=InteIzq;
  Result := False;
  //Determinar si hay raiz en el intervalo
  while (i<InteDer) do
  begin
    if (ecuacion(i) * ecuacion(i+h) < 0.0) then//si no existe hay raiz
    begin
      Result := True;
      break;
    end;
    i:=i+h;
  end;

  if (Result=False) then
  exit;

  i := 0;
  resParcial := 0;
  a := InteIzq;
  b := InteIzq + h;
  hpaso := 0.001;
  if (metodo = 0) then
  begin

    repeat

      if (ecuacion(a) * ecuacion(b) > 0.0) then
      begin
        a += hpaso;
        b += hpaso;
        continue;
      end;

      //llama biseccion para aproximar
      errAllow := 0.01;
      resParcial := aproximar(a, b);

      //llama secante y termina de aproximar
      errAllow := h;
      resultado := finalizar(resParcial);
      resli.Add(FloatToStr(resultado));
      a += hpaso;
      b += hpaso;

    until (b >= InteDer) or (a >= InteDer);

  end
  else if (metodo = 1) then //biseccion
  begin
    errAllow := h;
    repeat

      if (ecuacion(a) * ecuacion(b) > 0.0) then
      begin
        a += hpaso;
        b += hpaso;
        continue;
      end;

      //llama biseccion para aproximar
      resultado := aproximar(a, b);
      resli.Add(FloatToStr(resultado));
      Resliy.add(FloatToStr(ecuacionInter(resultado)));
      a += hpaso;
      b += hpaso;
    until (b >= InteDer) or (a >= InteDer);
  end
  else if (metodo = 2) then //newton
  begin
    Result := False;
    exit;
  end
  else if (metodo = 3) then //secante
  begin
    errAllow := h;
    repeat

      if (ecuacion(a) * ecuacion(b) > 0.0) then
      begin
        a += hpaso;
        b += hpaso;
        continue;
      end;


      //llama secante y termina de aproximar
      resultado := finalizar(a);
      resli.Add(FloatToStr(resultado));
      a += hpaso;
      b += hpaso;

    until (b >= InteDer) or (a >= InteDer);
  end;
end;


function clLinea.aproximar(izq: real; dere: real): real;
var
  iteracion: integer;
  mitad, mitadPast, errAct: real;
begin
  iteracion := 0;
  errAct := 0.1;
  mitadPast := dere;
  resPast := 0;

  //se halla 1 iteracion fuera del bucle
  mitadPast := bisec(izq, dere);
  if (bolzano(izq, mitadPast) < 0.0) then
    dere := mitadPast
  else
    izq := mitadPast;

  //comienza bucle
  repeat
    mitad := bisec(izq, dere);
    errAct := abs(mitad - mitadPast);
    if (bolzano(izq, mitad) < 0.0) then
      dere := mitad
    else
      izq := mitad;

    mitadPast := mitad;
    iteracion += 1;
  until (errAct < errAllow) or (contIte >= maxIte);

  Result := mitad;
end;


function clLinea.finalizar(xn: real): real;
var
  resa, resp, errAct: real;
begin

  resp := 0;
  resa := xn;
  errAct := 0;

  repeat
    resp := resa;
    resa := secante(resa);
    errAct := abs(resa - resp);
  until (errAct <= h);
  Result := resa;
end;

end.
