unit clSEDO;

{$mode objfpc}

interface

uses
  Classes, SysUtils,custParse;

type
  TArrSimp = array of extended;
  TArr2D = array of TArrSimp;

  TSEDO=class
    private
    tempFuncTList: TStringList;
    tempNamValTList: TStringList;
    tempNamesTList: TStringList;
    tempValuesTList: TStringList;



    h,errAll,xf:Real;
    variables: TArrSimp;
    arrParse: array of TCustParse;
    procedure Split(Input: string; const Strings: TStrings);

    public
    resx, resy,resz: TStringList;
    function execute():string;
    function solve1(x,y,z: real): real;
    function solve2(x,y,z: real): real;
    function RK4(): real;
    function getValues(funcs: string; vars: string): boolean;
    function getFinal(x:string):boolean;
    procedure seth(x: real);

    constructor Create;
    destructor Destroy; override;

  end;

implementation

constructor TSEDO.Create;
begin
  h:=0.001;
  tempFuncTList:= TStringList.Create;
  tempNamesTList:= TStringList.Create;
  tempValuesTList:=TStringList.Create;
  tempNamValTList:=TStringList.Create;
  resx:= TStringList.Create;
  resy:=TStringList.Create;
  resz:=TStringList.Create;
end;

destructor TSEDO.Destroy;
begin
  tempFuncTList.free;
  tempNamesTList.free;
  tempValuesTList.free;
  tempNamValTList.free;
  resx.free;
  resy.free;
  resz.free;
end;

procedure TSEDO.seth(x: real);
begin
  errAll := x;
  h := x;
end;


procedure TSEDO.Split(Input: string; const Strings: TStrings);
begin
  Assert(Assigned(Strings));
  Strings.Clear;
  //Strings.StrictDelimiter := True;
  Strings.Delimiter := ' ';
  Strings.QuoteChar := '"';
  Strings.DelimitedText := Input;
end;

function TSEDO.getFinal(x:string):boolean;
begin
  Result:=TryStrToFloat(x,xf);
end;

function TSEDO.getValues(funcs: string; vars: string): boolean;
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
    //DEBUG:='ENTRA ACA';
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
  //DEBUG:='';
  //DEBUG:=IntToStr(tempNamValTList.count);

  //for i := 0 to tempFuncTList.count - 1 do
  //DEBUG += ' ... ' + tempFuncTList[i];

  if (tempFuncTList.count <> tempNamValTList.count-1)then
  begin
    //DEBUG:=funcs;
    Result := False;
    exit;
  end;

  //agrega valores variables a un array y su nombre al array de parser

   dim := tempNamValTList.count;
  //setLength(arrParse, dim);
  setLength(variables,dim);
//

  for i:=0 to dim-1 do
  variables[i]:=StrToFloat(tempValuesTList[i]);

//
//  for i := 0 to dim - 1 do
//  begin
//    arrParse[i] := TCustParse.Create();//se inicializan
//    for j := 0 to dim - 1 do//agregar variables a parser
//    begin
//      arrParse[i].addVariable(tempNamesTList[j], variables[j]);
//    end;
//    arrParse[i].addExpression(tempFuncTList[i]);//se agrega la expresion
//  end;

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

function TSEDO.solve1(x,y,z: real): real;
var
  FParser: TCustParse;
begin
  FParser := TCustParse.Create;
  try
    FParser.AddVariable('y', y);
    FParser.AddVariable('x', x);
    FParser.AddVariable('z', z);
    FParser.AddExpression(tempFuncTList[0]);
    Result := FParser.evaluate;
  finally
    FParser.Free;
  end;
end;

function TSEDO.solve2(x,y,z: real): real;
var
  FParser: TCustParse;
begin
  FParser := TCustParse.Create;
  try
    FParser.AddVariable('y', y);
    FParser.AddVariable('x', x);
    FParser.AddVariable('z', z);
    FParser.AddExpression(tempFuncTList[1]);
    Result := FParser.evaluate;
  finally
    FParser.Free;
  end;
end;



function TSEDO.RK4(): real;
var
  xnact, ynact,znact, k1, k2, k3, k4,k,l,l1,l2,l3,l4: real;
  i,j:Integer;
begin
  xnact:=variables[0];
  ynact:=variables[1];
  znact:=variables[2];

  repeat
    //hallar m para cada funcion


    k1 := h*solve1(xnact,ynact,znact);
    l1 := h*solve2(xnact,ynact,znact);



    k2 := h*solve1(xnact + h / 2, ynact + (k1 / 2),znact+l1/2);
    l2 := h*solve2(xnact + h / 2, ynact + (k1 / 2),znact+l1/2);


    k3 := h*solve1(xnact + h / 2, ynact + (k2 / 2),znact+l2/2);
    l3 := h*solve2(xnact + h / 2, ynact + (k2 / 2),znact+l2/2);

    k4 := h*solve1(xnact + h, ynact + k3,znact+l3 );
    l4 := h*solve2(xnact + h, ynact + k3,znact+l3 );

    k := (k1 + 2 * k2 + 2 * k3 + k4) / 6;
    l := (l1 + 2 * l2 + 2 * l3 + l4) / 6;


    resx.add(FloatToStr(xnact));
    resy.add(FloatToStr(ynact));
    resz.add(FloatToStr(znact));

    xnact := xnact + h;
    ynact := ynact + k;
    znact := ynact + l;

    //iteracion de RK
  until (xnact >= xf - h);

end;


function TSEDO.execute():string;
var
  lenRes:Integer;
begin
  RK4();
  lenRes:=resx.Count;
  Result:='xf: '+resx[lenRes-1]+' y: '+resy[lenRes-1]+' z: '+resz[lenRes-1];
end;

end.

