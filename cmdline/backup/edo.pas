unit edo;

{$mode objfpc}

interface

uses
  Classes, SysUtils, custParse, fpexprpars,math;

type
  TEdo = class
  private
    expre: string;
    metodo: integer;
    menor: boolean;
    xn, xf, yn, h: real;
  public
    resx,resy:TStringList;
    //get|set
    procedure seth(x: real);
    procedure getFront(x: real; y: real);
    procedure setMetod(x: integer);
    procedure setyf(y: real);
    procedure getFunc(x: string);
    //metodos
    function solve(x: real; y: real): real;
    function euler(): real;
    function heun(): real;
    function RK4(): real;
    function DOPRI(): real;
    function adaptRK45():Real;
    procedure RK45(x:Real;y:Real;hm:Real;out r4,r5:Real);


    function Execute(): real;
    constructor Create;
    destructor Destroy; override;

  end;


//1
//edo(x-y,0,2,1,0)

//2
//edo(y-power(x,2)+1,0,0.5,2,1)

//3
//edo(-2*x*y,0,1,-2,1)

//4
//edo(-2*power(x,3)+12*power(x,2)-20*x+8.5,0,1,4,0)

//5
//edo(x*exp(3*x)-2*y,0,0,1,0) //a

//edo(1+power(x-y,2),2,1,3,0)  //b

//edo(power(y/x,2)+y/x,1,1,-14,0)  //c
//edo(power(y/x,2)+y/x,1,1,14,0)

//edo(sin(x)+exp(-x),0,0,-10,0)       //d
//edo(sin(x)+exp(-x),0,0,10,0)

//edo(4*exp(0.8*x)-0.5*x,0,2,4,0)      //e



implementation

constructor TEdo.Create;
begin
  xn := 0;
  yn := 0;
  h := 0.0001;
  menor := False;
  metodo:=3;
  resx:=TStringList.create;
  resy:=TStringList.create;
end;

destructor TEdo.Destroy;
begin
  resx.free;
  resy.free;
end;

procedure TEdo.getFront(x: real; y: real);
begin
  xn := x;
  yn := y;
end;

procedure TEdo.setMetod(x: integer);
begin
  metodo := x;
end;

procedure TEdo.getFunc(x: string);
begin
  expre := x;
end;

procedure TEdo.setyf(y: real);
begin
  yf := y;
end;

procedure TEdo.seth(x: real);
begin
  h := x;
end;

function TEdo.solve(x: real; y: real): real;
var
  FParser: TCustParse;
begin
  FParser := TCustParse.Create;
  try
    FParser.AddVariable('y', y);
    FParser.AddVariable('x', x);
    FParser.AddExpression(expre);
    Result := FParser.evaluate;
  finally
    FParser.Free;
  end;
end;



//edo(x*y,1,2,2,0)
function TEdo.euler(): real;
var
  resact, xnact, ynact: real;
begin
  xnact := xn;
  ynact := yn;
  repeat
    resact := ynact + h * solve(xnact, ynact);
    xnact := xnact + h;
    ynact := resact;
    resx.add(FloatToStr(xnact));
    resy.add(FloatToStr(ynact));
  until (xnact >= xf - h) xor menor;

  //resx.add(FloatToStr(xnact+remh));
  //resy.add(FloatToStr(ynact));
  //Hallar xf-xnact
  ynact := ynact + (xf - xnact) * solve(xnact, ynact);
  Result := ynact;
end;


function TEdo.heun(): real;
var
  resact, reseuler, xnact, ynact, remh: real;
begin
  xnact := xn;
  ynact := yn;
  repeat
    reseuler := ynact + h * solve(xnact, ynact);
    resact := ynact + (solve(xnact, ynact) + solve(xnact + h, reseuler)) * h / 2;
    xnact := xnact + h;
    ynact := resact;
    resx.add(FloatToStr(xnact));
    resy.add(FloatToStr(ynact));
  until (xnact >= xf - h) xor menor;

  //Hallar xf-xnact
  remh := xf - xnact;
  reseuler := ynact + remh * solve(xnact, ynact);
  ynact := ynact + (solve(xnact, ynact) + solve(xnact + remh, reseuler)) * remh / 2;
  Result := ynact;
  resx.add(FloatToStr(xnact+remh));
  resy.add(FloatToStr(ynact));
end;


function TEdo.RK4(): real;
var
  xnact, ynact, m, k1, k2, k3, k4, remh: real;
begin
  xnact := xn;
  ynact := yn;
  repeat
    k1 := solve(xnact, ynact);
    k2 := solve(xnact + h / 2, ynact + (k1 * h / 2));
    k3 := solve(xnact + h / 2, ynact + (k2 * h / 2));
    k4 := solve(xnact + h, ynact + (k2 * h));
    m := (k1 + 2 * k2 + 2 * k3 + k4) / 6;
    xnact := xnact + h;
    ynact := ynact + h * m;
    resx.add(FloatToStr(xnact));
    resy.add(FloatToStr(ynact));
  until (xnact >= xf - h) xor menor;

  remh := xf - xnact;
  k1 := solve(xnact, ynact);
  k2 := solve(xnact + remh / 2, ynact + (k1 * remh / 2));
  k3 := solve(xnact + remh / 2, ynact + (k2 * remh / 2));
  k4 := solve(xnact + remh, ynact + (k2 * remh));
  m := (k1 + 2 * k2 + 2 * k3 + k4) / 6;
  ynact := ynact + remh * m;
  Result := ynact;
  resx.add(FloatToStr(remh));
  resy.add(FloatToStr(ynact));
end;


function TEdo.DOPRI(): real;
var
  xnact, ynact,z4,error,s,herror,hmin,hmax, k1, k2, k3, k4, k5, k6, k7, remh: real;
begin
  xnact := xn;
  ynact := yn;
  hmin:=0.00001;
  hmax:=0.01;
  herror:=h;
  repeat
    k1 := h * solve(xnact, ynact);
    k2 := h * solve(xnact + 1 / 5 * h, ynact + 1 / 5 * k1);
    k3 := h * solve(xnact + 3 / 10 * h, ynact + 3 / 40 * k1 + 9/40*k2);
    k4 := h * solve(xnact + 4 / 5 * h, ynact + 44 / 45 * k1 - 56/15*k2 + 32/9*k3);
    k5 := h * solve(xnact + 8 / 9 * h, ynact + 19372 / 6561 * k1 - 25360/2187*k2 + 64448/6561*k3 - 212/729*k4);
    k6 := h * solve(xnact + h, ynact + 9017 / 3168 * k1 - 355/33*k2 + 46732/5247*k3 + 49/176*k4 - 5103/18656*k5);
    k7 := h * solve(xnact + h, ynact + 35 / 384 * k1 + 500/1113*k3 + 125/192*k4 - 2187/6784*k5 + 11/84*k6);
    resx.add(FloatToStr(xnact));
    resy.add(FloatToStr(ynact));

    ynact:= ynact + 35/384*k1 + 500/1113*k3 + 125/192*k4 - 2187/6784*k5 + 11/84*k6;
    z4:=ynact + 5179/57600*k1 + 7571/16695*k3 + 393/640*k4 - 92097/339200*k5 + 187/2100*k6+ 1/40*k7;

    xnact:=xnact+h;
    error:=abs(ynact-z4);
    s:=power((herror*h/(2*error)),1/5);
    h:=s*h;
    if(h<hmin)then h:=hmin
    else if (h<hmax) then h:=hmax;

  until (xnact >= xf - h) xor menor;
  remh := xf - xnact;

  k1 := remh * solve(xnact, ynact);
  k2 := remh * solve(xnact + 1 / 5 * remh, ynact + 1 / 5 * k1);
  k3 := remh * solve(xnact + 3 / 10 * remh, ynact + 3 / 40 * k1 + 9/40*k2);
  k4 := remh * solve(xnact + 4 / 5 * remh, ynact + 44 / 45 * k1 - 56/15*k2 + 32/9*k3);
  k5 := remh * solve(xnact + 8 / 9 * remh, ynact + 19372 / 6561 * k1 - 25360/2187*k2 + 64448/6561*k3 - 212/729*k4);
  k6 := remh * solve(xnact + remh, ynact + 9017 / 3168 * k1 - 355/33*k2 + 46732/5247*k3 + 49/176*k4 - 5103/18656*k5);
  k7 := remh * solve(xnact + remh, ynact + 35 / 384 * k1 + 500/1113*k3 + 125/192*k4 - 2187/6784*k5 + 11/84*k6);

  ynact:= ynact + 35/384*k1 + 500/1113*k3 + 125/192*k4 - 2187/6784*k5 + 11/84*k6;

  resx.add(FloatToStr(xnact+remh));
  resy.add(FloatToStr(ynact));

  Result:=ynact;
end;


function TEdo.adaptRK45():Real;
var
  xnact, ynact,hmin,hmax,hact,emin,emax,eact,resrk4,resrk5: real;
  n,nmax:Integer;
begin
  xnact := xn;
  ynact := yn;
  n:=0;
  hact:=h;
  emin:=0.0001;
  emax:=0.001;
  hmin:=0.000001;
  hmax:=0.01;
  nmax:=10;
  while(n<nmax) or (xnact<xf) do
  begin
    if(hact<hmin) then hact:=hmin
    else if (hact>hmax) then hact:=hmax;
    //RK45
    //***
    RK45(xnact,ynact,hact,resrk4,resrk5);

    //n:=n+1;
    eact:=abs(resrk4-resrk5);
    if(eact>emax) and (hact>hmin) then
    hact:=hact/2
    else begin
      n:=n+1;
      xnact:=xnact+hact;
      ynact:=resrk5;
      if (eact<emin) then h:=2*h;
    end;
  end;
  Result:=ynact;
end;


procedure TEdo.RK45(x:Real;y:Real;hm:Real;out r4,r5:Real);
var
  xnact, ynact, k1, k2, k3, k4,k5,k6,remh,r4temp,r5temp: real;
begin
  xnact := x;
  ynact := y;
  repeat
    k1 := hm*solve(xnact, ynact);
    k2 := hm*solve(xnact + (hm *1 / 4), ynact + (k1 * 1/ 4));
    k3 := hm*solve(xnact + (hm *3 / 8), ynact + (k1 * 3/32) + (k2 * 9/32));
    k4 := hm*solve(xnact + (hm *12 / 13), ynact + (k1 * 1932/2197) - (k2 * 7200/2197) + (k3 * 7296/2197));
    k5 := hm*solve(xnact + hm, ynact + (k1 * 439/216) - (k2 *8) + (k3 * 3680/513) - (k4 * 845/4104));
    k6 := hm*solve(xnact + hm*1/2, ynact - (k1 * 8/27) + (k2 *2) - (k3 * 3544/2565) + (k4 * 1859/4104) - (k5 * 11/40));
    r4temp:=ynact+k1*25/216+k3*1408/2565+k4*2197/4104-k5*1/5;
    r5temp:=ynact+k1*16/135+k3*6656/12825+k4*28561/56430-k5*9/50+k6*2/55;
    ynact :=r5temp;
    xnact := xnact + hm;
  until (xnact >= xf - h) xor menor;

  remh := xf - xnact;
  k1 := remh*solve(xnact, ynact);
  k2 := remh*solve(xnact + (remh *1 / 4), ynact + (k1 * 1/ 4));
  k3 := remh*solve(xnact + (remh *3 / 8), ynact + (k1 * 3/32) + (k2 * 9/32));
  k4 := remh*solve(xnact + (remh *12 / 13), ynact + (k1 * 1932/2197) - (k2 * 7200/2197) + (k3 * 7296/2197));
  k5 := remh*solve(xnact + remh, ynact + (k1 * 439/216) - (k2 *8) + (k3 * 3680/513) - (k4 * 845/4104));
  k6 := remh*solve(xnact + remh*1/2, ynact - (k1 * 8/27) + (k2 *2) - (k3 * 3544/2565) + (k4 * 1859/4104) - (k5 * 11/40));
  r4temp:=ynact+k1*25/216+k3*1408/2565+k4*2197/4104-k5*1/5;
  r5temp:=ynact+k1*16/135+k3*6656/12825+k4*28561/56430-k5*9/50+k6*2/55;
  //2 results
  r4:=r4temp;
  r5:=r5temp;
end;





function TEdo.Execute(): real;
begin
  if (xf < xn) then
  begin
    h := -h;
    menor := True;
  end;
  case metodo of
    0: Result := euler();
    1: Result := heun();
    2: Result := RK4();
    3: Result := DOPRI();
    4: Result := adaptRK45();
  end;
end;




end.
