unit clSEDO;

{$mode objfpc}

interface

uses
  Classes, SysUtils;

type
  TSEDO=class
    private

    public
    function RK4(): real;

    constructor Create;
    destructor Destroy; override;

  end;

implementation

constructor TSEDO.Create;
begin

end;

destructor TSEDO.Destroy;
begin

end;


function TSEDO.RK4(): real;
var
  xnact, ynact, m, k1, k2, k3, k4, remh: real;
begin
  xnact := xn;
  ynact := yn;
  repeat
    k1 := solve(xnact, ynact);
    k2 := solve(xnact + h / 2, ynact + (k1 * h / 2));
    k3 := solve(xnact + h / 2, ynact + (k2 * h / 2));
    k4 := solve(xnact + h, ynact + (k3 * h));
    m := (k1 + 2 * k2 + 2 * k3 + k4) / 6;
    xnact := xnact + h;
    ynact := ynact + h * m;
    resx.add(FloatToStr(xnact));
    resy.add(FloatToStr(ynact));
  until (xnact >= xf - h) xor menor;

end;

end.

