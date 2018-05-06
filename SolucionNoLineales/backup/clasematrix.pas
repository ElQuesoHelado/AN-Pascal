unit clasematrix;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type //rows | cols
  TArrSimp = array of Real;
  TArr2D = array of TArrSimp;
  clMatr=class
    private
      matOrig,matTempo:TArr2D;
      lenMatRows,lenMatCols:Integer;
      esCuad:Boolean;
    public
      elem:TStringList;
      procedure newMatrix(M1:TArr2D);
      function xEscalar(x:Integer):TArr2D;
      function traza():Real;overload;
      function traza(M1:TArr2D):Real;overload;
      function sumar(M1:TArr2D):TArr2D;overload;
      function sumar(M1:TArr2D;M2:TArr2D):TArr2D;overload;
      function resta(M1:TArr2D):TArr2D;overload;
      function resta(M1:TArr2D;M2:TArr2D):TArr2D;overload;
      function multMatrices(M1:TArr2D):TArr2D;overload;
      function multMatrices(M1:TArr2D; M2:TArr2D):TArr2D;overload;
      function divMatrices(M1:TArr2D; M2:TArr2D):TArr2D;
      function prodPunto(M1:TArr2D; M2:TArr2D):Real;
      function trasposicion(M1:TArr2D):TArr2D;
      function adj(M1:TArr2D):TArr2D;
      function inv(M1:TArr2D):TArr2D;
      function cofact(M1:TArr2D):TArr2D;
      function det(M1:TArr2D):Real;
      function triUpper():TArr2D;
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


procedure clMatr.newMatrix(M1:TArr2D);
begin
  matOrig:=M1;
  lenMatRows:=length(M1);
  lenMatCols:=length(M1[0]);
  if(lenMatRows=lenMatCols) then
  esCuad:=true
  else
  esCuad:=false;
end;

function clMatr.xEscalar(x:Integer):TArr2D;
var i,j:Integer;
begin
  setLength(Result,lenMatRows,lenMatCols);
  for i:=0 to lenMatRows-1 do
      for j:=0 to lenMatCols-1 do
          Result[i][j]:=matOrig[i][j]*x;
end;

function clMatr.traza():Real;overload;
var i:integer;
begin
  if(not esCuad) then
  exit;
  Result:=0;
  for i:=0 to lenMatRows-1 do
      Result+=matOrig[i][i];
end;

function clMatr.traza(M1:TArr2D):Real;overload;
var i:integer;
begin
  if(length(M1)<>length(M1[0])) then
  exit;
  Result:=0;
  for i:=0 to length(M1)-1 do
      Result+=M1[i][i];
end;

function clMatr.sumar(M1:TArr2D):TArr2D;overload;
var i,j:Integer;
begin
  //Mismo tamanio, sino error
  if(lenMatRows<>length(M1)) or (lenMatCols<>length(M1[0])) then
  exit;
  setLength(Result,lenMatRows,lenMatCols);
  for i:=0 to lenMatRows-1 do
      for j:=0 to lenMatCols-1 do
          Result[i][j]:=matOrig[i][j]+M1[i][j];
end;

function clMatr.sumar(M1:TArr2D;M2:TArr2D):TArr2D;overload;
var i,j:Integer;
begin
  //Mismo tamanio, sino error
  if(length(M1)<>length(M2)) or (length(M1[0])<>length(M2[0])) then
  exit;
  setLength(Result,length(M1),length(M1[0]));
  for i:=0 to length(M1)-1 do
      for j:=0 to length(M1[0])-1 do
          Result[i][j]:=M1[i][j]+M2[i][j];
end;


function clMatr.resta(M1:TArr2D):TArr2D;overload;
var i,j:Integer;
begin
  //Mismo tamanio, sino error
  if(lenMatRows<>length(M1)) or (lenMatCols<>length(M1[0])) then
  exit;
  setLength(Result,lenMatRows,lenMatCols);
  for i:=0 to lenMatRows-1 do
      for j:=0 to lenMatCols-1 do
          Result[i][j]:=matOrig[i][j]-M1[i][j];
end;


function clMatr.resta(M1:TArr2D;M2:TArr2D):TArr2D;overload;
var i,j:Integer;
begin
  //Mismo tamanio, sino error
  if(length(M1)<>length(M2)) or (length(M1[0])<>length(M2[0])) then
  exit;
  setLength(Result,length(M1),length(M1[0]));
  for i:=0 to length(M1)-1 do
      for j:=0 to length(M1[0])-1 do
          Result[i][j]:=M1[i][j]-M2[i][j];
end;


function clMatr.multMatrices(M1:TArr2D):TArr2D;overload;
var i,j,k:Integer;
begin//MxN X NxB  = MxB
  if(lenMatCols<>length(M1))then
  exit;
  setLength(Result,lenMatRows,length(M1[0]));
  for i:=0 to lenMatRows-1 do//rows de matOrig
  begin
      for j:=0 to length(M1[0])-1 do//cols de M1
      begin
          for k:=0 to lenMatCols-1 do//cols de matOrig
              Result[i][j]+=matOrig[i][k]*M1[k][j];
      end;
  end;
end;

function clMatr.multMatrices(M1:TArr2D;M2:TArr2D):TArr2D;overload;
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

function clMatr.divMatrices(M1:TArr2D; M2:TArr2D):TArr2D;
var Temp:TArr2D;
begin
  setLength(Result,length(M1),length(M1[0]));
  Result:=multMatrices(M1,inv(M2));

end;

function clMatr.prodPunto(M1:TArr2D; M2:TArr2D):Real;
var i,j:Integer;
begin
  if(length(M1)<>length(M2)) or (length(M1[0])<>length(M2[0])) then
  exit;
  Result:=Traza(multMatrices(trasposicion(M1),M2));
end;




function clMatr.inv(M1:TArr2D):TArr2D;
var i,j,k,p,o,
  lenRow,lenCol:Integer;
  mult,alpha:Real;
  upper,lower,iden,temp,colInv:TArr2D;
begin

  //Tiene que ser cuadrada
  if(length(M1)<>length(M1[0])) then
  exit;

  //Tamanios
  lenRow:=length(M1);
  lenCol:=length(M1[0]);

  setLength(upper,lenRow,lenCol);
  setLength(lower,lenRow,lenCol);
  setLength(iden,lenRow,lenCol);//Se crea una identidad de mxm
  setLength(Result,lenRow,lenCol);//Result:=Inversa
  setLength(temp,lenRow,1);
  setLength(colInv,lenRow,1);

  //Se inicia temp lleno de 0's,excepto la primera fila
  //temp[0][0]:=1;
  for i:=0 to lenRow-1 do
  temp[i][0]:=0;



  //Se copia M1 a upper
  for i:=0 to lenRow-1 do
  upper[i]:=Copy(M1[i]);


  //Se llena iden y lower como identidades
  for i:=0 to lenRow-1 do
      for j:=0 to lenCol-1 do
          if(i=j)then
          begin
               lower[i][j]:=1;
               iden[i][j]:=1;
          end
          else
          begin
               lower[i][j]:=0;
               iden[i][j]:=0;
          end;



  //Halla la Upper y Lower
  for j:=0 to lenRow-2 do
      for i:=j+1 to lenRow-1 do
      begin
          mult:=upper[i][j]/upper[j][j];
          lower[i][j]:=mult;
          for k:=j to lenRow-1 do//columnas de la i-th fila
            upper[i][k]:=upper[i][k]-(mult*upper[j][k]);
      end;




               ////******/////



               //Hallar Z
 for i:=0 to lenCol-1 do//Columnas de la inversa(Result) e identidad
 begin
   temp[0][0]:=iden[0][i];
   alpha:=0;
   for j:=1 to lenRow-1 do  //Filas de lower
        begin
            alpha:=0;
            for k:=0 to j-1 do//columnas de lower y filas de Z
            alpha:=alpha+lower[j][k]*temp[k][0];
            temp[j][0]:=iden[j][i]-alpha;
        end;


   //Columna inversa

   colInv[lenCol-1][0]:=temp[lenCol-1][0]/upper[lenRow-1][lenCol-1];
   alpha:=0;
   for j:=lenRow-2 downto 0  do  //Filas de lower
        begin
            alpha:=0;
            for k:=lenCol-1 downto j+1 do//columnas de lower y filas de Z
            alpha:=alpha+upper[j][k]*colInv[k][0];
            colInv[j][0]:=(temp[j][0]-alpha)/upper[j][j];
        end;
   //Agregar columna a la inversa

   //Agrega elementos vector a la columna inversa
   for p:=0 to lenRow-1 do
        Result[p][i]:=colInv[p][0];


 end;








         {

               //Hallar Z

 temp[0][0]:=iden[0][0];
 alpha:=0;
 for j:=1 to lenRow-1 do  //Filas de lower
      begin
          alpha:=0;
          for k:=0 to j-1 do//columnas de lower y filas de Z
          alpha:=alpha+lower[j][k]*temp[k][0];
          temp[j][0]:=iden[j][0]-alpha;
      end;


 //Columna inversa

 colInv[lenCol-1][0]:=temp[lenCol-1][0]/upper[lenRow-1][lenCol-1];
 alpha:=0;
 for j:=lenRow-2 downto 0  do  //Filas de lower
      begin
          alpha:=0;
          for k:=lenCol-1 downto j+1 do//columnas de lower y filas de Z
          alpha:=alpha+upper[j][k]*colInv[k][0];
          colInv[j][0]:=(temp[j][0]-alpha)/upper[j][j];
      end;
 //Agregar columna a la inversa
                        }

  //Result:=lower;
  //Result:=upper;
  //Result:=temp;
  Result:=colInv;

end;


function clMatr.adj(M1:TArr2D):TArr2D;
var
  i,j:Integer;
  temp:TArr2D;
begin {
  temp:=trasposicion(M1);
  //Ya se tiene la transpuesta
  setLength(cofact,length(M1)-1,length(M1[0]));
       }

end;


//cofact de 3x3
function clMatr.cofact(M1:TArr2D):TArr2D;
var i,j,sui1,sui2,suj1,suj2:Integer;
begin
  setLength(Result,length(M1),length(M1[0]));
  for i:=0 to length(M1)-1 do
      for j:=0 to length(M1[0])-1 do
      //Caso especial cuando solo 2 valores se salen de index, se halla la matriz
      //cofactor sin tener que multiplicar los alternos por (-1)
      begin
          sui1:=(i+1) mod 3;
          sui2:=(i+2) mod 3;
          suj1:=(j+1) mod 3;
          suj2:=(j+2) mod 3;
          Result[i][j]:=(M1[sui1][suj1]*M1[sui2][suj2])-(M1[sui2][suj1]*M1[sui1][suj2])
      end;
end;

function clMatr.trasposicion(M1:TArr2D):TArr2D;
var i,j:integer;
begin
  setLength(Result,length(M1[0]),length(M1));
  for i:=0 to length(M1)-1 do
      for j:=0 to length(M1[0])-1 do
          Result[j][i]:=M1[i][j];
end;

function clMatr.det(M1:TArr2D):Real;
var i:Integer;
  MUpper:TArr2D;
begin
  //Evalua que sea una matriz cuadrada
  if(length(M1)<>length(M1[0])) then
  exit;
  //Caso de que sea 2x2
  if(length(M1)=2) then
  Result:=M1[0][0]*M1[1][1]-M1[0][1]*M1[1][0];

  MUpper:=triUpper();
  Result:=1;

  for i:=0 to length(MUpper)-1 do
  Result:=Result*MUpper[i][i];

end;

function clMatr.triUpper():TArr2D;
var i,j,k,m:Integer;
  mult:Real;
begin
  setLength(Result,Length(matOrig),Length(matOrig[0]));
  m:=Length(matOrig);
  Result:=matOrig;

  for j:=0 to m-2 do
      for i:=j+1 to m-1 do
      begin
          mult:=matOrig[i][j]/matOrig[j][j];
          for k:=j to m-1 do//columnas de la i-th fila
          Result[i][k]:=matOrig[i][k]-(mult*matOrig[j][k]);
      end;
end;


procedure clMatr.printArr(M1:TArr2D);
var i,j:integer;
  temp:string;
begin
  for i:=0 to length(M1)-1 do
  begin
      temp:='';//Reinicia el string:temp a vacio
      for j:=0 to length(M1[0])-1 do
          temp:=temp+FloatToStr(M1[i][j])+', ';
      elem.add(temp);
  end;
  setLength(matOrig,0,0);//Libera el array resultado
end;

end.

