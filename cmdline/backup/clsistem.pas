unit clSistem;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, custParse, clMatrix, Math;

type
  TArrSimp = array of extended;
  TArr2D = array of TArrSimp;

  TSENL = class

  private
    errAll, h,xf: real;
    procedure Split(Input: string; const Strings: TStrings);



  public
    resultados, errores: TStringList;
    tempFuncTList: TStringList;
    tempNamValTList: TStringList;
    tempNamesTList: TStringList;
    tempValuesTList: TStringList;

    variables: TArrSimp;
    varname: string;

    DEBUG: string;

    matriz: clMatr;
    jacobian, jaco, fx: TArr2D;
    arrParse: array of TCustParse;
    function getValues(funcs: string; vars: string): boolean;
    procedure passVarExp(exp: array of string);
    procedure seth(x: real);
    function Execute():string;

    constructor Create;
    destructor Destroy; override;


  end;

const
  maxite = 10000;




implementation
//Pasar variables y expresion cons string array

constructor TSENL.Create;
begin
  resultados := TStringList.Create;
  errores := TStringList.Create;
  tempFuncTList:= TStringList.Create;
  tempNamesTList:= TStringList.Create;
  tempValuesTList:=TStringList.Create;
  tempNamValTList:=TStringList.Create;

  varname:='';
  h:=0.001;
end;

destructor TSENL.Destroy;
begin
  resultados.Free;
  errores.Free;
  tempFuncTList.Free;
  tempNamesTList.Free;
  tempValuesTList.Free;
  tempNamValTList.Free;
end;

procedure TSENL.Split(Input: string; const Strings: TStrings);
begin
  Assert(Assigned(Strings));
  Strings.Clear;
  //Strings.StrictDelimiter := True;
  Strings.Delimiter := ' ';
  Strings.QuoteChar := '"';
  Strings.DelimitedText := Input;
end;


procedure TSENL.passVarExp(exp: array of string);
var
  i, j, dim: integer;
  tempo: string;
begin
  dim := length(exp);
  setLength(arrParse, dim);

  //agrega valores variables a un array y su nombre al array de parser
  for i := 0 to dim - 1 do
  begin
    arrParse[i] := TCustParse.Create();//se inicializan
    for j := 0 to dim - 1 do//agregar variables a parser
    begin
      arrParse[i].addVariable(varname[j+1], variables[j]);
    end;
    arrParse[i].addExpression(exp[i]);//se agrega la expresion
  end;

end;

function TSENL.getValues(funcs: string; vars: string): boolean;
var
  i,j,equalindex,dim: integer;
begin
  Result := True;

  //Not valid input
  if (funcs[1] <> '[') or (vars[1] <> '[') or (funcs[length(funcs)] <> ']') or
    (vars[length(vars)] <> ']') then
  begin
    //DEBUG:=vars;
    //DEBUG:=funcs[1];
    DEBUG:='ENTRA ACA';
    Result := False;
    exit;
  end;


  //Creacion de TStringLists para expresiones y variables con nombres

  Delete(funcs, 1, 1);
  setlength(funcs, length(funcs) - 1);
  split(funcs, tempFuncTList);

  Delete(vars, 1, 1);
  setlength(vars, length(vars) - 1);
  split(vars, tempNamValTList);


  //Pasar de tempNamValTList a tempValuesTList y tempNamesTList
  //elementos de tempNamValTList
  for i:=0 to tempNamValTList.count-1 do
  begin
    equalindex:=pos('=',tempNamValTList[i]);
    tempNamesTList.append(copy(tempNamValTList[i],1,equalindex-1));
    tempValuesTList.append(copy(tempNamValTList[i],equalindex+1,length(tempNamValTList[i])));

  end;

  //DEBUG:='Nombre '+tempNamesTList[2]+' Valor '+tempValuesTList[2];


  //DEBBUGEAR
  DEBUG:='';
  //DEBUG:=IntToStr(tempNamValTList.count);

  for i := 0 to tempFuncTList.count - 1 do
  DEBUG += ' ... ' + tempFuncTList[i];

  if (tempFuncTList.count <> tempNamValTList.count)then
  begin
    //DEBUG:=funcs;
    Result := False;
    exit;
  end;

  //agrega valores variables a un array y su nombre al array de parser

   dim := tempNamValTList.count;
  setLength(arrParse, dim);
  setLength(variables,dim);
//

  for i:=0 to dim-1 do
  variables[i]:=StrToFloat(tempValuesTList[i]);


  for i := 0 to dim - 1 do
  begin
    arrParse[i] := TCustParse.Create();//se inicializan
    for j := 0 to dim - 1 do//agregar variables a parser
    begin
      arrParse[i].addVariable(tempNamesTList[j], variables[j]);
    end;
    arrParse[i].addExpression(tempFuncTList[i]);//se agrega la expresion
  end;

  //senl([cos(x)+exp(y)-x sen(5*x)+x*y-y],[x=0.5 y=1])





  ////DEBUG print
  //DEBUG := '';
  //for i := 0 to tempNamValTList.count - 1 do
  //DEBUG += ' ... ' + arrParse[i].getVariables();
    //DEBUG += '...' + FloatToStr(variables[i]);

  //DEBUG := DEBUG+'...' + tempValuesTList[i];
  //DEBUG += '...' + tempFuncTList[i];
  //DEBUG += tempNamValTList.count;
  //DEBUG:=IntToStr(tempNamValTList.count);
end;


procedure TSENL.seth(x: real);
begin
  errAll := x;
  h := x;
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



function TSENL.Execute():string;
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

  Result:=resultados[resultados.count-1];
  matriz.Destroy;

end;

// 2.7182818284590452353602
//a=cos(x)+exp(y)-x
//b=sen(5*x)+x*y-y

//x=0.5
//y=1


//power(x,2)+3*power(y,2)+

//problema pizzar
                       {
 power(x,2)+3*power(y,2)+exp(z)+w-4.71828183
 3*sen(x+y)+ln(abs(y-w))
 power(w,2)+arctan(x)-pi/4-4
 5*y+3*w+ln(abs(z+x+y))+11


 senl([power(x,2)+3*power(y,2)+exp(z)+w 3*sen(x+y)+ln(abs(y-w)) power(w,2)+arctan(x)-pi/4 5*y+3*w+ln(abs(z+x+y))],[x=1 y=-1 z=1 w=-2])

 senl([a b c d],[x=1 y=-1 z=1 w=-2])




 x=1
 y=-1
 z=1
 w=-2
                        }

//Problema ejemplo
{
a=power(x,2)+power(y,2)-5
b=power(x,2)-power(y,2)-1

x=2
y=1

senl([a b],[x=2 y=1])

senl([power(x,2)+power(y,2)-5 power(x,2)-power(y,2)-1],[x=2 y=1])

senl(["power(x,2)+power(y,2)-5" "power(x,2)-power(y,2)-1"],[x=2 y=1])

}

end.





