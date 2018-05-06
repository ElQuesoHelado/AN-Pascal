unit claseTaylor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;


type
  clTaylor=class
    private
      contIte,
      opera:Integer;
      errPerm,
      xf:Real;
      function seno():Real;
      function coseno():Real;
      function epox():Real;
      function arctan():Real;
      function lnx1():Real;

    public
      ErrList,
      Secuencia:TStringList;
      function execute():Real;
      procedure setError(x:Real);
      procedure setX(b:Real;inde:Integer);
      procedure setOper(x:Integer);
      constructor Create;
      destructor Destroy;override;

  end;



               
const
  maxIte=10000;


implementation

constructor clTaylor.create;
begin
  contIte:=0;
  Secuencia:=TStringList.Create;
  Secuencia.Add('');
  ErrList:=TStringList.Create;
  ErrList.Add('');
end;


destructor clTaylor.Destroy;
begin
  Secuencia.Free;
  ErrList.Free;
end;



function power(a:Real;n:Integer):Real;
var i:Integer;
begin
  Result:=1;
  for i:=1 to n do
  Result:=Result*a;
end;

function factorial(x:Integer):Integer;
begin
  if(x>1)then
    Result:=x*factorial(x-1)
  else if x>=0 then
    Result:=1
  else
    Result:=0;
end;

procedure clTaylor.setError(x:Real);
begin
  errPerm:=x
end;

procedure clTaylor.setX(b:Real;inde:Integer);
begin
  if(inde=1)then
    xf:=b
  else
    xf:=b*pi/180;
end;

procedure clTaylor.setOper(x:Integer);
begin
  opera:=x
end;

function clTaylor.execute():Real;
begin
  case opera of
  0: Result:=seno();
  1: Result:=coseno();
  2: Result:=epox();
  3: Result:=arctan();
  4: Result:=lnx1();
  end;
end;



function clTaylor.coseno():Real;
var n:Integer;
  tempRes,
  tempErr:Real;
begin
  tempRes:=0;
  Result:=0;
  n:=0;
  repeat
    tempRes:=Result;
    Result:=Result + power(-1,n) * power(xf,n)/factorial(2*n);
    tempErr:=abs(tempRes-Result);
    Secuencia.Add(FloatToStr(Result));
    ErrList.Add(FloatToStr(tempErr));
    n:=n+1;
  until (n>maxIte) or (tempErr<errPerm);
end;


function clTaylor.seno():Real;
var n:Integer;
  tempRes,
  tempErr:Real;
begin
  tempRes:=0;
  Result:=0;
  n:=0;
  repeat
    tempRes:=Result;
    Result:=Result + power(-1,n) * power(xf,2*n+1)/factorial(2*n+1);
    tempErr:=abs(tempRes-Result);
    Secuencia.Add(FloatToStr(Result));
    ErrList.Add(FloatToStr(tempErr));
    n:=n+1;
  until (n>maxIte) or (tempErr<errPerm);
end;

function clTaylor.epox():Real;
var n:Integer;
  tempRes,
  tempErr:Real;
begin
  tempRes:=0;
  Result:=0;
  n:=0;
  repeat
    tempRes:=Result;
    Result:=Result + power(xf,n)/factorial(n);
    tempErr:=abs(tempRes-Result);
    Secuencia.Add(FloatToStr(Result));
    ErrList.Add(FloatToStr(tempErr));
    n:=n+1;
  until (n>maxIte) or (tempErr<errPerm);
end;

function clTaylor.arctan():Real;
var n:Integer;
  tempRes,
  tempErr:Real;
begin
  tempRes:=0;
  Result:=0;
  n:=0;
  repeat
    tempRes:=Result;
    Result:=Result + power(-1,n) * power(xf,2*n+1)/(2*n+1);
    tempErr:=abs(tempRes-Result);
    Secuencia.Add(FloatToStr(Result));
    ErrList.Add(FloatToStr(tempErr));
    n:=n+1;
  until (n>maxIte) or (tempErr<errPerm);
end;

function clTaylor.lnx1():Real;
var n:Integer;
  tempRes,
  tempErr:Real;
begin
  tempRes:=0;
  Result:=0;
  n:=1;
  repeat
    tempRes:=Result;
    Result:=Result + power(-1,n+1) * power(xf,n)/n;
    tempErr:=abs(tempRes-Result);
    Secuencia.Add(FloatToStr(Result));
    ErrList.Add(FloatToStr(tempErr));
    n:=n+1;
  until (n>maxIte) or (tempErr<errPerm);
end;

end.

