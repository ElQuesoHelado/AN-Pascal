unit claseinter;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,custParse;

type
  TIntegral=class
    private
      a,b,h:Real;
      n:Integer;
      expre:string;



    public
      parse:TCustParse;
      procedure getInterv(izq:Real;dere:Real;inte:integer);
      procedure getFunc(x:String);
      function execute():Real;
      constructor Create;
      destructor Destroy; override;


  end;





implementation


constructor TIntegral.Create;
begin
  parse:=TCustParse.Create;

end;

destructor TIntegral.Destroy;
begin
  parse.Destroy

end;


procedure TIntegral.getInterv(izq:Real;dere:Real;inte:Integer);
begin
  a:=izq;
  b:=dere;
  n:=inte;
  h:=(b-a)/n;
end;

procedure TIntegral.getFunc(x:String);
begin
  expre:=x;
end;


function TIntegral.execute():Real;
var
  i:Integer;
  suma:Real;
begin
  //set de ecuacion
  parse.addVariable('x',a);
  parse.addExpression(expre);
  Result:=parse.evaluate;//f(a)
  parse.identVar[0].AsFloat :=b;
  Result:=(Result+parse.evaluate)/2;//(f(a)+f(b))/2

  suma:=0;
  i:=1;
  //se halla la suma
  repeat//se suma la funcion de var(a+h)....
    parse.identVar[0].AsFloat :=a +i*h;
    suma:=suma+parse.evaluate;
    i+=1;
  until (i=n);

  Result:=(Result+suma);




end;

end.

