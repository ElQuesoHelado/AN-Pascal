unit MatrInter;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  clMatrix;

type

  { TForm1 }
  //arrDi = array of array of Integer;
  TArrSimp = array of Real;
  TArr2D = array of TArrSimp;

  TForm1 = class(TForm)
    Button1: TButton;
    meInput: TMemo;
    //instancias:TObjectList<clMatr>;
    procedure Button1Click(Sender: TObject);
    procedure setInstances();
    //procedure FormCreate(Sender: TObject);
    //procedure FormDestroy(Sender: TObject);
  private
    matrix:clMatr;

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

function ArrSimp(const arr: array of Real):TArrSimp;
var i:Integer;
begin
  SetLength(Result,Length(arr));
  for i:=0 to high(arr) do
      Result[i]:=arr[i];
end;

function Arr2D(const arr: array of TArrSimp):TArr2D;
var i: Integer;
begin
  SetLength(Result,length(arr));
  for i:=0 to high(Result) do
      Result[i]:=arr[i];
end;


procedure TForm1.Button1Click(Sender: TObject);
var
  i,j:Integer;
  M1,M2,M3:TArr2D;
  strtemp:string;
  deter:Real;
begin
    M1:=Arr2D([
    ArrSimp([0,-1,4]),
    ArrSimp([2,1,1]),
    ArrSimp([1,1,-2])
    ]);

    M2:=Arr2D([
    ArrSimp([0,-1,6,4]),
    ArrSimp([2,1,2,1]),
    ArrSimp([1,6,1,-2]),
    ArrSimp([4,-6,3,5])
    ]);

    M3:=Arr2D([
    ArrSimp([1,0,0,1]),
    ArrSimp([0,2,1,2]),
    ArrSimp([2,1,0,1]),
    ArrSimp([2,0,1,4])
    ]);
     matrix:=clMatr.Create;
     matrix.newMatrix(M3);
     //matrix.invGauss();
     matrix.maupper();


     for i:=0 to length(M2)-1 do
     begin
         strtemp:='';
         for j:=0 to length(M2)-1 do
         strtemp:=strtemp+FloatToStr(matrix.matOrig[i][j])+' ';

         meInput.Lines.Add(strtemp+'      ');
     end;



end;



procedure TForm1.setInstances();
//var i,j,k,nInstan:Integer,actRow,colAnt,colSig;
begin {
  nInstan=0;
  actRow=0;
  colAnt=0;
  colSig=0;
  instancias:=TObjectList<clMatr>.Create;
  instancias.OwnsObjects:=true;

  for i:=0 to meInput.Lines.Count-1 do //Pasa por cada linea del memo input
  begin             //[# de linea][caracter de la linea]
      if(meInput.Lines[i][1]!='[') then
      Continue; //Si no comienza con '[' ignora la linea
      //Si comienza con '[' se crea una instancia
      instancias.Add(clMatr.Create);

      //Contar las columnas


      for j:=2 to length(meInput.Lines[i]) do//revisa cada char del string
      begin
          //instancias[i].
          {
          if(meInut.Lines[i][j]=';')then
          //Add row, change row  }
          try
          //Add to actual row
          except

            end;
      end;

  end;

    }
end;
       {
procedure FormCreate(Sender: TObject);
begin
end;

procedure FormDestroy(Sender: TObject);
begin
end;
          }
end.

