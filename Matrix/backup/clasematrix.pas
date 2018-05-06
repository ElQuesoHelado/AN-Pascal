unit clasematrix;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type //rows | cols
  multi= array of array of Real;
  TArrSimp = array of Real;
  TArr2D = array of TArrSimp;
  clMatr=class
    private
      //matriz:Array of integer;
    public
      matriz:multi;
      //matriz:TArr2D;
      elem:TStringList;
      procedure multEscal(M1:TArr2D; x:Integer);
      function Traza(M1:TArr2D):Real;
      procedure sumaMatrices(M1:TArr2D; M2:TArr2D);
      function multMatrices(M1:TArr2D; M2:TArr2D):TArr2D;
      function prodPunto(M1:TArr2D; M2:TArr2D):Real;
      function trasposicion(M1:TArr2D):TArr2D;
      procedure printArr(M1:TArr2D);
      constructor Create;
      destructor Destroy;override;
  end;


implementation


constructor clMatr.Create;
begin
  elem:=TStringList.Create;

end;

destructor clMatr.Destroy;
begin
  elem.free;
end;



procedure clMatr.multEscal(M1:TArr2D;x:Integer);
var i,j:Integer;
begin
  setLength(matriz,length(M1),length(M1[0]));
  for i:=0 to length(M1)-1 do
      for j:=0 to length(M1[0])-1 do
          matriz[i][j]:=M1[i][j]*x;
end;

function clMatr.Traza(M1:TArr2D):Real;
var i:integer;
begin
  Result:=0;
  if(length(M1)<>length(M1[0])) then
  exit;
  for i:=0 to length(M1)-1 do
      Result+=M1[i][i];
end;

procedure clMatr.sumaMatrices(M1:TArr2D; M2:TArr2D);
var i,j:Integer;
begin
  //Mismo tamanio, sino error
  if(length(M1)<>length(M2)) then
  exit;
  //se setea tamanio de la matriz resultado
  setLength(matriz,length(M1),length(M1[0]));
  for i:=0 to Length(M1)-1 do
      for j:=0 to Length(M1[0])-1 do
          matriz[i][j]:=M1[i][j]+M2[i][j];
end;

function clMatr.multMatrices(M1:TArr2D; M2:TArr2D):TArr2D;
var i,j,k:Integer;
begin//MxN X NxB  = MxB
  if(length(M1[0])<>length(M2))then
  exit;
  setLength(Result,length(M1),length(M2[0]));
  for i:=0 to length(M1)-1 do//rows de M1
  begin
      for j:=0 to length(M2[0])-1 do//cols de M2
      begin
          for k:=0 to length(M1[0])-1 do//cols de M1
              Result[i][j]+=M1[i][k]*M2[k][j];
      end;
  end;
end;

function clMatr.prodPunto(M1:TArr2D; M2:TArr2D):Real;
var i,j:Integer;
  Temp:TArr2D;
begin
  if(length(M1)<>length(M2)) or (length(M1[0])<>length(M2[0])) then
  exit;
  Result:=Traza(multMatrices(trasposicion(M1),M2));
end;

function clMatr.trasposicion(M1:TArr2D):TArr2D;
var i,j:integer;
begin
  setLength(Result,length(M1[0]),length(M1));
  for i:=0 to length(M1)-1 do
      for j:=0 to length(M1[0])-1 do
          Result[j][i]:=M1[i][j];
end;

procedure clMatr.printArr(M1:TArr2D);
var i,j:integer;
  temp:string;
begin
  for i:=0 to length(M1)-1 do
  begin
      temp:='';//Reinicia el string:temp a vacio
      for j:=0 to length(M1[0])-1 do
          temp:=temp+IntToStr(M1[i][j])+' ';
      elem.add(temp);
  end;
  setLength(matriz,0,0);//Libera el array resultado
end;

end.

