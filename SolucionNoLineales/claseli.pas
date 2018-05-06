unit claseli;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,math,fpexprpars;

type
  //TMetodo = function(x:Real; y:Real):Real;
  TArrSimp = array of Real;
  TArr2D = array of TArrSimp;
  clLinea=class
    private
      resAct,
      resPast,
      InteIzq,//Intervalo
      InteDer,
      errAllo:Real;
      contIte,//Contador limite de iteraciones,
      Metodo:Integer;
      ecua:String;

      function bisec(a:Real;b:Real):Real;
      function falPos(a:Real;b:Real):Real;
      function NewRaph(a:Real):Real;
      function Secante(a:Real):Real;
      function PuntFij(a:Real):Real;
      function bolzano(izq: Real; dere:Real):Real;

    public
      ecGraf:Real;
      Temporal:Real;
      ResLi: TStringList;//Lista de results y errors finales
      errLi:TStringList;
      FParser:TFPExpressionParser;
      FParserSist:TFPExpressionParser;
      function principal(izq: Real; dere:Real):Real;overload;
      function principal(xn:Real):Real;overload;
      function execute():Real;
      procedure setError(x:Real);
      procedure setInterv(x:real;y:Real);
      procedure setMetod(x:Integer);

      function sistvar(ecuacion:String;varName:array of String;valor:TArrSimp):Real;

      procedure setEcua(x:string);
      function ecuacion(xn:Real):Real;
      constructor Create;
      destructor Destroy;override;
    end;
{var
  FParser:TFPExpressionParser;  //Instancia parser
 }
implementation

const
  maxIte=10000;
//var
  //FParser:TFPExpressionParser;  //Instancia parser


constructor clLinea.Create;
begin
     //Se crean las listas de resultados y errores
     //Se agrega un elemento 0
     //FParser:=TFpExpressionParser.Create(nil);
     ResLi:=TStringList.Create;
     ResLi.Add('');
     errLi:=TStringList.Create;
     errLi.Add('');
     //Creacion del parser
     //valores iniciales de iteracions y resultados
     contite:=0;
     resAct:=2;
     resPast:=1;
end;

destructor clLinea.Destroy;
begin
     //Se liberan las dos listas
     ResLi.Free;
     errLi.Free;

end;        {

function power(b:Real;e:Integer):Real;
var i:Integer;
begin
     Result:=1;
     for i:=1 to e do
         Result:=Result*b
end;         }
procedure elevado(var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  x,n:Double;
begin
     x:=ArgToFloat(Args[0]);
     n:=ArgToFloat(Args[1]);
     Result.resFloat:=power(x,n);
end;

function clLinea.ecuacion(xn:Real):Real;
begin     //El parser resuelve la ecuacion
     FParser:=TFpExpressionParser.Create(nil);
     try
       FParser.BuiltIns:=[bcMath,bcConversion];//reemplaza el (x^n) por power(x,n) para la grafica
       FParser.Identifiers.AddFunction('power','F','FF',@elevado);
       FParser.Identifiers.AddFloatVariable('x', xn);//se usa la variable seteada
       FParser.Expression:=ecua;//la funcion se obtiene por interfaz
       //ecGraf:=StrToFloat(FParser.Expression);
       Result:=FParser.Evaluate.ResFloat;
       ecGraf:=Result;
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


function clLinea.sistvar(ecuacion:String;varName:array of String;valor:TArrSimp):Real;
begin     //El parser resuelve la ecuacion
     FParserSist:=TFpExpressionParser.Create(nil);
     try
       FParserSist.BuiltIns:=[bcMath,bcConversion];
       FParserSist.Identifiers.AddFunction('power','F','FF',@elevado);

       FParserSist.Expression:=ecuacion;//del StringGrid
       Result:=FParser.Evaluate.ResFloat;
       ecGraf:=Result;
     finally
       FParser.Free;
     end;

end;

//Los metodos
function clLinea.bisec(a:Real;b:Real):Real;
begin
     Result:=(a+b)/2
end;

function clLinea.falPos(a:Real;b:Real):Real;
begin
     Result:=a-(ecuacion(a)*((b-a)/(ecuacion(b)-ecuacion(a))))

end;

function clLinea.NewRaph(a:Real):Real;  //*******************
var h:double;
begin
     h:=0.000000000001;
     //hallar derivada por definicion
     //Result:=a-ecuacion(a)/(6*power(a,2))
     //Result:=a-ecuacion(a)/(sin(power(a,3))+(3*power(a,3)*cos(power(a,3))))
     //Result:=a-ecuacion(a)/(-1/power(a,2))
     //Result:=a-ecuacion(a)/(6*power(a,2)-4*a)//sin lim

     //Por definicion de derivada
     Result:=a-ecuacion(a)/((ecuacion(a+h)-ecuacion(a))/h)
end;

function clLinea.Secante(a:Real):Real;
begin  //h=error/10
     Result:=a-(2*(errAllo/10)*ecuacion(a))/(ecuacion(a+(errAllo/10))-ecuacion(a-(errAllo/10)))
end;

function clLinea.PuntFij(a:Real):Real;
begin
     Result:=ecuacion(a);
end;

//Evalua bolzano
function clLinea.bolzano(izq: Real; dere:Real):Real;
begin
     Result:=ecuacion(izq)*ecuacion(dere)
end;


//Sets de error, intervalos y metodo a usar
procedure clLinea.setError(x:Real);
begin
     errAllo:=x;
end;

procedure clLinea.setInterv(x:real;y:Real);
begin
     InteIzq:=x;
     InteDer:=y
end;

procedure clLinea.setMetod(x:Integer);
begin
     Metodo:=x
end;

procedure clLinea.setEcua(x:string);
begin
     ecua:=x;
end;

function clLinea.execute():Real;
//var ptr: Pointer;
begin
     //ptr:=@bisec();
     //WriteLn(TMetodo(ptr));
     if (Metodo<=1) then     //Bisec y Falsa pos
     begin
        Result:=principal(InteIzq,InteDer);//Mismos argumetos overloading
        //errLi.Strings[1]('---');
     end
     else
     begin//New/Raph, Secante, Punto fijo
        resAct:=InteIzq;
        Resli.Add(FloatToStr(InteIzq));
        errLi.Add('---');
        Result:=principal(InteIzq);
     end;
end;

function clLinea.principal(izq: Real; dere:Real):Real;
//function clLinea.principal(actMetod : TMetodo):Real;
begin
     contIte:=contIte+1;
     resPast:=resAct;
     case Metodo of
     0: resAct:=bisec(izq,dere);
     1: resAct:=falPos(izq,dere);
     end;

     //resAct:=actMetod(izq,dere);
     Resli.Add(FloatToStr(resAct));
     errLi.Add(FLoatToStr(abs(resAct-resPast)));
     if(abs(resAct-resPast)<errAllo) or (contIte>=maxIte) then
     begin
       Result:=resAct;
       exit
     end;
     if (bolzano(izq,resAct)<0.0) then
        Result:=principal(izq,resAct)
        //Result:=principal(actMetod(izq,resAct))
     else
        Result:=principal(resAct,dere);
        //Result:=principal(actMetod(resAct,dere));
end;

function clLinea.principal(xn:Real):Real;
begin
     contIte:=contIte+1;
     resPast:=resAct;
     case Metodo of
     2:resAct:=NewRaph(xn);
     3:resAct:=Secante(xn);
     4:resAct:=PuntFij(xn);
     end;
     Resli.Add(FloatToStr(resAct));
     errLi.Add(FloatToStr(abs(resAct-resPast)));
     if(abs(resAct-resPast)<errAllo) or (contIte>=maxIte) then
     begin
       Result:=resAct;
       exit
     end;
     Result:=principal(resAct);



end;
end.


