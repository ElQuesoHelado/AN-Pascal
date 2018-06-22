unit clMatrix;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type //rows | cols
  TArrSimp = array of extended;
  TArr2D = array of TArrSimp;

  clMatr = class
  private

    lenMatRows, lenMatCols: integer;
  public
    matOrig, matTempo: TArr2D;
    elem: TStringList;
    //Operaciones en  matOrig
    procedure newMatrix(M1: TArr2D);
    procedure sumar(M1: TArr2D);
    procedure resta(M1: TArr2D);
    procedure restaInv(M1: TArr2D);
    procedure mult(M1: TArr2D);
    procedure inv();
    procedure xEscalar(x: integer);
    //procedure divi(M1: TArr2D);
    function det(): real; overload;
    procedure printArr(M1: TArr2D);

    //Operaciones con 2 Matrices externas

    function trasposicion(M1: TArr2D): TArr2D;
    function det(M1: TArr2D): real; overload;

    constructor Create;
    destructor Destroy; override;
  end;


implementation


constructor clMatr.Create;
begin
  elem := TStringList.Create;
end;

destructor clMatr.Destroy;
begin
  elem.Free;
end;


procedure clMatr.newMatrix(M1: TArr2D);
var
  i: integer;
begin
  //se copia M1  a matOrig
  lenMatRows := length(M1);
  lenMatCols := length(M1[0]);
  setlength(matOrig, lenMatRows, lenMatCols);

  for i := 0 to lenMatRows - 1 do
    matOrig[i] := Copy(M1[i]);
end;



procedure clMatr.xEscalar(x: integer);
var
  i, j: integer;
begin
  for i := 0 to lenMatRows - 1 do
    for j := 0 to lenMatCols - 1 do
      matOrig[i][j] := matOrig[i][j] * x;
end;


procedure clMatr.sumar(M1: TArr2D);
var
  i, j: integer;
begin
  //Mismo tamanio, sino error
  if (lenMatRows <> length(M1)) or (lenMatCols <> length(M1[0])) then
    exit;
  for i := 0 to lenMatRows - 1 do
    for j := 0 to lenMatCols - 1 do
      matOrig[i][j] := matOrig[i][j] + M1[i][j];
end;

procedure clMatr.resta(M1: TArr2D);
var
  i, j: integer;
begin
  //Mismo tamanio, sino error
  if (lenMatRows <> length(M1)) or (lenMatCols <> length(M1[0])) then
    exit;
  for i := 0 to lenMatRows - 1 do
    for j := 0 to lenMatCols - 1 do
      matOrig[i][j] := matOrig[i][j] - M1[i][j];
end;


procedure clMatr.restaInv(M1: TArr2D);
var
  i, j: integer;
begin
  //Mismo tamanio, sino error
  if (lenMatRows <> length(M1)) or (lenMatCols <> length(M1[0])) then
    exit;
  for i := 0 to lenMatRows - 1 do
    for j := 0 to lenMatCols - 1 do
      matOrig[i][j] := M1[i][j] - matOrig[i][j];
end;


procedure clMatr.mult(M1: TArr2D);
var
  i, j, k: integer;
  sum: extended;
  newMat: TArr2D;
begin//MxN X NxB  = MxB
  //if (lenMatCols <> length(M1)) then
  //  exit;
  setLength(newMat, lenMatRows, length(M1[0]));
  for i := 0 to lenMatRows - 1 do//rows de matOrig
    for j := 0 to length(M1[0]) - 1 do//cols de M1
    begin
      sum := 0;
      for k := 0 to lenMatCols - 1 do//cols de matOrig
        sum := sum + (matOrig[i][k] * M1[k][j]);
      newMat[i][j] := sum;
    end;

  lenMatRows := length(newMat);
  lenMatCols := length(newMat[0]);
  setLength(matOrig, lenMatRows, lenMatCols);

  for i := 0 to lenMatRows - 1 do
    matOrig[i] := Copy(newMat[i]);

end;


procedure clMatr.inv();
var
  i, j, k, p, noZero: integer;
  valtemp, multi,mayor: real;
  operar, iden: TArr2D;
begin
  setLength(operar, lenMatRows, lenMatCols);
  setLength(iden, lenMatRows, lenMatCols);

  //Se copia matOrig
  for i := 0 to length(iden) - 1 do
    operar[i] := Copy(matOrig[i]);

  //Se crea una matriz identidad
  for i := 0 to lenMatRows - 1 do
    for j := 0 to lenMatCols - 1 do
      if (i = j) then
        iden[i][j] := 1
      else
        iden[i][j] := 0;

  //Cada vez que se toca un pivot se vuelve 1
  //Si el pivot es 0 se intercambia con el primero que no sea 0

  {

  i->

j,k |  0     -1       6       4  |    1      0      0      0  |
  ! |  2      1       2       1  |    0      1      0      0  |
  v |  1      6       1      -2  |    0      0      1      0  |
    |  4     -6       3       5  |    0      0      0      1  |

  }


  for i := 0 to lenMatRows - 1 do //columna a operar
    //for i := 0 to 0 do //columna a operar
  begin
    //Pivoting buscando el mayor
    noZero:=i;
    for k:=i+1 to lenMatRows -1 do
    if(operar[k][i]>operar[i][i])then
    noZero:=k;

    //el cambio
    if(noZero<>i)then
    begin
    for k := 0 to lenMatRows - 1 do
      begin
        valtemp := operar[i][k];
        operar[i][k] := operar[noZero][k];
        operar[noZero][k] := valtemp;
        //Cambio de la identidad
        valtemp := iden[i][k];
        iden[i][k] := iden[noZero][k];
        iden[noZero][k] := valtemp;

      end;
    end;

    //El pivot se iguala a 1
    valtemp := operar[i][i];
    for p := 0 to lenMatRows - 1 do//dividir toda la fila entre el pivot
    begin
      operar[i][p] := operar[i][p] / valtemp;
      iden[i][p] := iden[i][p] / valtemp;
    end;

    //columna i :=0
    //Los de abajo del pivot
    for j := i + 1 to lenMatRows - 1 do//filas
    begin
      multi := operar[j][i];
      for p := 0 to lenMatRows - 1 do//columnas
      begin
        operar[j][p] := operar[j][p] - operar[i][p] * multi;
        iden[j][p] := iden[j][p] - iden[i][p] * multi;
      end;
    end;

    //Los de arriba del pivot
    for j := 0 to i - 1 do//filas
    begin
      multi := operar[j][i];
      for p := 0 to lenMatRows - 1 do//columnas
      begin
        operar[j][p] := operar[j][p] - operar[i][p] * multi;
        iden[j][p] := iden[j][p] - iden[i][p] * multi;
      end;
    end;

  end;

  for i := 0 to length(iden) - 1 do
    matOrig[i] := Copy(iden[i]);
  //matOrig[i] := Copy(operar[i]);

end;




function clMatr.trasposicion(M1: TArr2D): TArr2D;
var
  i, j: integer;
begin
  setLength(Result, length(M1[0]), length(M1));
  for i := 0 to length(M1) - 1 do
    for j := 0 to length(M1[0]) - 1 do
      Result[j][i] := M1[i][j];
end;

function clMatr.det(M1: TArr2D): real;
var
  i, j, k, lenRow: integer;
  multi: real;
  MUpper: TArr2D;
begin
  //Evalua que sea una matriz cuadrada
  if (length(M1) <> length(M1[0])) then
    exit;
  lenRow := length(M1);

  for i := 0 to lenRow - 1 do
    MUpper[i] := Copy(M1[i]);

  //halla triang Upper
  for j := 0 to lenRow - 2 do
    for i := j + 1 to lenRow - 1 do
    begin
      multi := MUpper[i][j] / MUpper[j][j];
      for k := j to lenRow - 1 do//columnas de la i-th fila
        MUpper[i][k] := MUpper[i][k] - (multi * MUpper[j][k]);
    end;

  Result := 1;
  for i := 0 to length(MUpper) - 1 do
    Result := Result * MUpper[i][i];
end;


function clMatr.det(): real;
var
  i, j, k: integer;
  multi: real;
  MUpper: TArr2D;
begin
  //Evalua que sea una matriz cuadrada
  if (lenMatRows <> lenMatCols) then
    exit;

  for i := 0 to lenMatRows - 1 do
    MUpper[i] := Copy(matOrig[i]);


  //halla triang Upper
  for j := 0 to lenMatRows - 2 do
    for i := j + 1 to lenMatRows - 1 do
    begin
      multi := MUpper[i][j] / MUpper[j][j];
      for k := j to lenMatRows - 1 do//columnas de la i-th fila
        MUpper[i][k] := MUpper[i][k] - (multi * MUpper[j][k]);
    end;

  Result := 1;
  for i := 0 to length(MUpper) - 1 do
    Result := Result * MUpper[i][i];
end;


procedure clMatr.printArr(M1: TArr2D);
var
  i, j: integer;
  temp: string;
begin
  for i := 0 to length(M1) - 1 do
  begin
    temp := '';//Reinicia el string:temp a vacio
    for j := 0 to length(M1[0]) - 1 do
      temp := temp + FloatToStr(M1[i][j]) + ', ';
    elem.add(temp);
  end;
  setLength(matOrig, 0, 0);//Libera el array resultado
end;

end.

