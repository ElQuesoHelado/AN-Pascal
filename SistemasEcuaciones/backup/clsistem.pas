unit clSistem;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, custParse, clMatrix, Math;

type
  TArrSimp = array of extended;
  TArr2D = array of TArrSimp;

  TclSistem = class

  private
    errAll, h: real;



  public
    resultados, errores: TStringList;
    variables: TArrSimp;
    varname: string;

    matriz: clMatr;
    jacobian, jaco, fx: TArr2D;
    arrParse: array of TCustParse;
    procedure passVarExp(exp: array of string);
    procedure setError(x: real);
    procedure Execute();

    constructor Create;
    destructor Destroy; override;


  end;

const
  maxite = 10000;




implementation
//Pasar variables y expresion cons string array

constructor TclSistem.Create;
begin
  resultados := TStringList.Create;
  errores := TStringList.Create;
  varname:='';
end;

destructor TclSistem.Destroy;
begin
  resultados.Free;
  errores.Free;

end;


procedure TclSistem.passVarExp(exp: array of string);
var
  i, j, dim: integer;
  tempo: string;
begin
  dim := length(exp);
  setLength(arrParse, dim);
  //agrega valores variables a un array y su nombre
  //varname := '(';
  //tempo := '';

  for i := 0 to dim - 1 do
  begin
    arrParse[i] := TCustParse.Create();//se inicializan
    for j := 0 to dim - 1 do//agregar variables a parser
    begin
      //arrParse[i].addVariable(vari[j][1], StrToFloat(vari[j][3]));
      arrParse[i].addVariable(varname[j+1], variables[j]);
    end;
    arrParse[i].addExpression(exp[i]);//se agrega la expresion
  end;

end;




procedure TclSistem.setError(x: real);
begin
  errAll := x;
  h := errAll / 10;
end;




//*****



function ArrSimp(const arr: array of extended): TArrSimp;
var
  i: integer;
begin
  setLength(Result, length(arr));
  for i := 0 to High(Result) do
    Result[i] := arr[i];
end;

function Arr2D(const arr: array of TArrSimp): TArr2D;
var
  i: integer;
begin
  setLength(Result, length(arr));
  for i := 0 to High(Result) do
    Result[i] := arr[i];
end;
//******



procedure TclSistem.Execute();
var
  i, j, n, dim: integer;
  inVar: TArr2D;
  strTemp: string;
  errAct,sumerr: extended;

begin
  //set de tamanios
  dim := length(variables);
  setLength(fx, dim, 1);
  setLength(jaco, dim, dim);
  setLength(inVar, dim, 1);
  //variables iniciales
  for i := 0 to dim - 1 do
    inVar[i][0] := variables[i];

  matriz := clMatr.Create();

  n := 0;

  //****
  setLength(jacobian, dim, dim);

  repeat

    //Hallar vector f(xn)
    for i := 0 to dim - 1 do
      fx[i][0] := arrParse[i].evaluate();

    //Halla jacobiano



    for i := 0 to dim - 1 do
      for j := 0 to dim - 1 do
      begin
        arrParse[i].identVar[j].AsFloat := arrParse[i].identVar[j].AsFloat + h;
        jaco[i][j] := arrParse[i].evaluate();

        //jacobian[i][j] := arrParse[i].evaluate();

        arrParse[i].identVar[j].AsFloat := arrParse[i].identVar[j].AsFloat - h;
        jaco[i][j] := (jaco[i][j] - arrParse[i].evaluate()) / h;

        //jacobian[i][j] := (jaco[i][j] - arrParse[i].evaluate()) / h;
      end;

    //Xn-(J(f(Xn))^-1)*f(Xn)


    //jacobian := Arr2D([ArrSimp([5, 2, 6, 2]), ArrSimp([2, 3, 8, 5]),
    //  ArrSimp([3, 1, 2, 4]), ArrSimp([9, 12, 3, 1])]);
    matriz.newMatrix(jaco);
    matriz.inv();

    //Mult manual
    //*****


    //******



    matriz.mult(fx);
    matriz.restainv(inVar);

    //Fill results
    strTemp := '(';
    for i := 0 to length(matriz.matOrig) - 2 do
      strTemp := strTemp + FloatToStr(matriz.matOrig[i][0]) + ',';

    strTemp := strTemp + FloatToStr(matriz.matOrig[length(matriz.matOrig) - 1][0]) + ')';
    resultados.Add(strTemp);

    //Errores
    sumerr:=0;
    for i:=0 to dim-1 do
      sumerr:= sumerr+power(matriz.matOrig[i][0] - inVar[i][0], 2);
    errAct := sqrt(sumerr);


    errores.Add(FloatToStr(errAct));
    n := n + 1;

    //Cambia vector variables a el resultado

    for i := 0 to dim - 1 do
      inVar[i][0] := matriz.matOrig[i][0];

    //Reasigna variables array parsers
    for i := 0 to dim - 1 do
      for j := 0 to dim - 1 do
      begin
        arrParse[i].identVar[j].AsFloat := matriz.matOrig[j][0];
      end;

  until (n > maxIte) or (errAct < errAll);




  matriz.Destroy;

end;

// 2.7182818284590452353602
//cos(x)+exp(y)-x
//sen(5*x)+x*y-y

//x=0.5
//y=1


//power(x,2)+3*power(y,2)+

//problema pizzar
                       {
 power(x,2)+3*power(y,2)+exp(z)+w
 3*sen(x+y)+ln(abs(y-w))
 power(w,2)+arctan(x)-pi/4
 5*y+3*w+ln(abs(z+x+y))


 x=1
 y=-1
 z=1
 w=-2
                        }

//Problema ejemplo
{
power(x,2)+power(y,2)-5
power(x,2)-power(y,2)-1

x=2
y=1




 }



end.





