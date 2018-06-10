unit claseinter;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,custParse, fpexprpars,math;

type
  TIntegral=class
    private
      a,b,h:Real;
      metodo:Integer;
      area:boolean;
      expre:string;

    public
      parse:TCustParse;
      procedure getInterv(izq:Real;dere:Real);
      procedure getFunc(x:String);
      procedure esArea();
      procedure setMetod(x:Integer);
      procedure seth(x:real);
      function solve(x: real): real;
      function trapezio():Real;
      function simp13():Real;
      function simp38():Real;
      function execute():Real;
      constructor Create;
      destructor Destroy; override;
  end;





implementation


constructor TIntegral.Create;
begin
  parse:=TCustParse.Create;
  area:=false;
  metodo:=1;
  h:=0.0001;
end;

destructor TIntegral.Destroy;
begin
  parse.Destroy

end;


procedure TIntegral.getInterv(izq:Real;dere:Real);
begin
  a:=izq;
  b:=dere;
end;

procedure TIntegral.getFunc(x:String);
begin
  expre:=x;
end;

procedure TIntegral.esArea();
begin
  area:=true;
end;


procedure TIntegral.seth(x:real);
begin
  h:=x;
end;

procedure TIntegral.setMetod(x:Integer);
begin
  metodo:=x;
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


function TIntegral.trapezio():Real;
var
  i:Integer;
  xnact,remh,suma:Real;
begin
  xnact:=a;
  if(area)then begin
    //Result:=abs(parse.evaluate);//f(a)
    Result:=abs(solve(a));
    //parse.identVar[0].AsFloat :=b;
    Result:=(Result+abs(solve(b)))/2;//(f(a)+f(b))/2
  end else begin
    //Result:=parse.evaluate;//f(a)
    Result:=solve(a);
    //parse.identVar[0].AsFloat :=b;
    Result:=(Result+solve(b))/2;//(f(a)+f(b))/2
  end;
  suma:=0;
  i:=1;
  //se halla la suma
  repeat//se suma la funcion de var(a+h)....
    xnact:=xnact+h;
    //parse.identVar[0].AsFloat :=xnact;
    if(area)then
    suma:=suma+abs(solve(xnact))
    else
    suma:=suma+solve(xnact);
    i+=1;
  until (xnact >= b - h);

  Result:=h*(Result+suma);

end;



function TIntegral.simp13():Real;
var
  sum,xnact,sumpar,sumimp,act:Real;
  i:Integer;
begin
  xnact:=a;
  sum:=solve(a);
  //parse.identVar[0].AsFloat:=b;
  sum:=sum+solve(b);

  sumpar:=0;
  sumimp:=0;
  i:=1;
  repeat
    xnact:=xnact+h;
    //par suma a sumpar
    if(i mod 2 = 0)then
    sumpar:=sumpar+solve(xnact)
    else
    sumimp:=sumimp+solve(xnact);
    i+=1;
  until (xnact >= b - h);
  sum:=(h/3)*(sum+ 2*sumpar+4*sumimp);
  Result:=sum;
end;

//integral(0.2+25*x-200*power(x,2)+675*power(x,3)-900*power(x,4)+400*power(x,5),0,0.8)

function TIntegral.simp38():Real;
var
  i,i2,i3:Integer;
  xnact,sum,sum14,sum25,sum36:Real;
begin
  //sum:=parse.evaluate;
  //parse.identVar[0].AsFloat:=b;
  //sum:=sum+(parse.evaluate);  //a+b

  xnact:=a;
  sum:=solve(a);
  sum:=sum+solve(b);


  sum14:=0;
  sum25:=0;
  sum36:=0;
  i:=1;
  i2:=2;
  i3:=3;
  repeat
    xnact:=xnact+h;
    sum14:=sum14+(3*solve(xnact));
    sum25:=sum25+(3*solve(xnact));
    sum36:=sum36+(2*solve(xnact));
    i+=3;
    i2+=3;
    i3+=3;
  until (xnact>=b-h);
  //until ((i>n) or (i2>n) or (i3>n));

  sum:=(3*(h/8))*(sum+sum14+sum25+sum36);
  Result:=sum;
end;




function TIntegral.execute():Real;
var
  i:Integer;
  suma:Real;
begin
  //set de ecuacion
  //parse.addVariable('x',a);
  //parse.addExpression(expre);

  //Metodos
  case metodo of
  0:Result:=trapezio();
  1:Result:=simp13();
  2:Result:=simp38();
  end;

end;

end.

