unit clasematrix;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  clMatr=class
    private
      matriz:Array of integer;
      dimx,dimy:Integer;
      //procedure createMat();
    public
      elem:TStringList;
      procedure getDim(x:Integer;y:Integer);
      procedure getArr(A:array of integer);
      procedure printArr();
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


procedure clMatr.getDim(x:Integer;y:Integer);
begin
  dimx:=x;
  dimy:=y
end;

procedure clMatr.getArr(A:array of integer);
begin
  matriz:=A;
end;

procedure clMatr.printArr();
var i:integer;
begin
  for i:=0 to 4 do
      elem.add(IntToStr(matriz[i]));
end;

end.

