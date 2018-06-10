unit claseli;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, fpexprpars;

type
  clLinea = class
  private
    resAct, resPast, InteIzq,//Intervalo
    InteDer, errAllo,h: real;
    contIte,//Contador limite de iteraciones,
    Metodo: integer;
    existe: integer;
    ecua: string;

    function bisec(a: real; b: real): real;
    function falPos(a: real; b: real): real;
    function NewRaph(a: real): real;
    function Secante(a: real): real;
    function PuntFij(a: real): real;
    function bolzano(izq: real; dere: real): real;

  public
    ecGraf: real;
    Temporal: real;
    ResLi: TStringList;//Lista de results y errors finales
    errLi: TStringList;
    FParser: TFPExpressionParser;
    FParserSist: TFPExpressionParser;
    //function principal(izq: real; dere: real): real; overload;
    //function principal(xn: real): real; overload;
    function aproximar(izq: real; dere: real): real;
    function finalizar(xn: real): real;

    function execute(): real;
    procedure seth(x: real);
    procedure getInterv(x: real; y: real);
    procedure setMetod(x: string);
    procedure getFunc(x: string);
    function ecuacion(xn: real): real;
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
  ResLi.Add('');
  errLi := TStringList.Create;
  errLi.Add('');
  //Creacion del parser
  //valores iniciales de iteracions y resultados
  contite := 0;
  resAct := 2;
  resPast := 1;
  existe := 1;
  h:=0.0001;

end;

destructor clLinea.Destroy;
begin
  //Se liberan las dos listas
  ResLi.Free;
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

function clLinea.PuntFij(a: real): real;
begin
  Result := ecuacion(a);
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
  //Metodo := x;
end;

procedure clLinea.getFunc(x: string);
begin
  ecua := x;
end;

function clLinea.Execute(): real;
var
  resParcial: real;
begin

  //llama biseccion para aproximar
  resParcial := 0;

  if (ecuacion(InteIzq)*ecuacion(InteDer)>0.0) then//quit si no existe
  begin
  Result := 0;
  existe:=0;
  exit;
  end;
  existe:=1;
  //if existe then aproxima
  resParcial := aproximar(InteIzq, InteDer);

  //llama secante
  Result:=finalizar(resParcial);
  //Result:=resParcial;

end;



function clLinea.aproximar(izq: real; dere: real): real;
var
  iteracion: integer;
  mitad,mitadPast,errAllow,errAct: real;
begin
  iteracion := 0;
  errAllow:=0.01;
  errAct:=0.1;
  mitadPast:=dere;
  resPast := 0;

  //se halla 1 iteracion fuera del bucle
  mitadPast:=bisec(izq,dere);
  if (bolzano(izq, mitadPast) < 0.0) then
  dere:=mitadPast
  else
  izq := mitadPast;

  //comienza bucle
  repeat
    mitad:=bisec(izq,dere);
    errAct:=abs(mitad - mitadPast);
    if (bolzano(izq, mitad) < 0.0) then
    dere:=mitad
    else
    izq := mitad;

    mitadPast:=mitad;
    iteracion+=1;
  until (errAct < errAllow) or (contIte >= maxIte);

  Result:=mitad;
end;



function clLinea.finalizar(xn: real): real;
var
  resa,resp,errAct,DEBUG: real;
begin

  resp:=0;
  resa:=xn;
  errAct:=0;

  DEBUG:=0;

  repeat
    resp:=resa;
    resa:=secante(resa);
    errAct:=abs(resa-resp);
    DEBUG+=1;
  until (errAct <= h) ;
  Result:=resa;
  //Result:=errAct;
  //Result:=resp;
end;

//raiz(2*power(x,3)+2,-1.5,-0.25)


//function clLinea.principal(xn:Real):Real;
//begin
//     contIte:=contIte+1;
//     resPast:=resAct;
//     case Metodo of
//     2:resAct:=NewRaph(xn);
//     3:resAct:=Secante(xn);
//     4:resAct:=PuntFij(xn);
//     end;
//     Resli.Add(FloatToStr(resAct));
//     errLi.Add(FloatToStr(abs(resAct-resPast)));
//     if(abs(resAct-resPast)<errAllo) or (contIte>=maxIte) then
//     begin
//       Result:=resAct;
//       exit
//     end;
//     Result:=principal(resAct);
//end;



//function clLinea.execute():Real;
//begin
//     if (Metodo<=1) then     //Bisec y Falsa pos
//     begin
//        Result:=principal(InteIzq,InteDer);//Mismos argumetos overloading
//        //errLi.Strings[1]('---');
//     end
//     else
//     begin//New/Raph, Secante, Punto fijo
//        resAct:=InteIzq;
//        Resli.Add(FloatToStr(InteIzq));
//        errLi.Add('---');
//        Result:=principal(InteIzq);
//     end;
//end;

//function clLinea.principal(izq: Real; dere:Real):Real;
//begin
//     contIte:=contIte+1;
//     resPast:=resAct;
//     case Metodo of
//     0: resAct:=bisec(izq,dere);
//     1: resAct:=falPos(izq,dere);
//     end;

//     //resAct:=actMetod(izq,dere);
//     Resli.Add(FloatToStr(resAct));
//     errLi.Add(FLoatToStr(abs(resAct-resPast)));
//     if(abs(resAct-resPast)<errAllo) or (contIte>=maxIte) then
//     begin
//       Result:=resAct;
//       exit
//     end;
//     if (bolzano(izq,resAct)<0.0) then
//        Result:=principal(izq,resAct)
//        //Result:=principal(actMetod(izq,resAct))
//     else
//        Result:=principal(resAct,dere);
//        //Result:=principal(actMetod(resAct,dere));
//end;



end.
