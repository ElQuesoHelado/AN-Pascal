unit clGrange;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,custParse;

type
  TArrSimp = array of real;
  TArr2D = array of TArrSimp;
  TClGrange=class
    private
      xn:Real;
    public
      data:TArr2D;
      polin:string;
      resultado:Real;
      Grapar:TCustParse;

      procedure getxn(X:Real);
      procedure execute();
      constructor Create;
      destructor Destroy; override;

  end;

implementation

constructor TClGrange.Create;
begin
  Grapar:=TCustParse.create;
end;

destructor TClGrange.Destroy;
begin

end;


procedure TClGrange.getxn(X:Real);
begin
  xn:=X;
end;

procedure TClGrange.execute();
var i,j:Integer;
  nume:string;
  denom:Real;
  temporal:string;
begin
  //Hallar polinomio

  Grapar.addVariable('x', xn);
  polin:='';
  temporal:='';
  nume:='';
  denom:=1;
  for i:=0 to length(data)-1 do
  begin
        denom:=1;
        nume:='';
        for j:=0 to length(data)-1 do//Solo trabaja x's
        begin
        if(j=i)then
        continue;

        denom:=denom*(data[i][0]-data[j][0]);
                        {
        if(j=length(data)-1)then
        continue;
                         }
        nume:=nume+'(x-'+floatToStr(data[j][0])+')*';

        end;
        //nume:=nume+'(x-'+floatToStr(data[j][0])+')';
        setLength(nume,length(nume)-1);
        temporal:='(('+floatToStr(data[i][1])+')*'+nume+'/('+floatToStr(denom)+'))+';
        polin:=polin+temporal;
  end;
  setLength(polin,length(polin)-1);
  Grapar.addExpression(polin);
  //resultado:=Grapar.evaluate();



end;



end.

