unit StorVar;

{$mode objfpc}

interface

uses
  Classes, SysUtils;

type
  TArrSimp = array of real;
  TArr2D = array of TArrSimp;

  clVar = class
  private


  public

    prueba: TStringList;

    varname: string;
    varstr: string;
    arrayReal: TArrSimp;
    arrayValores: TStringList;
    varFloat: double;
    esFloat: boolean;
    esArray: boolean;
    //boolean in case of failure
    function getName(): string;
    procedure Split(Input: string; const Strings: TStrings);
    procedure SplitArray(Input: string; const Strings: TStrings);
    function passValue(Name: string; Value: string): boolean;
    constructor Create;
    destructor Destroy; override;

  end;


implementation

constructor clVar.Create;
begin
  varstr := '';
  varfloat := 0;
  setlength(arrayReal, 0);

  arrayValores := TStringList.Create;
  prueba := TStringList.Create;

end;

destructor clVar.Destroy;
begin
  prueba.Destroy;
  arrayValores.Destroy;
end;

function clVar.getName(): string;
begin
  Result := varname;
end;

procedure clVar.Split(Input: string; const Strings: TStrings);
begin
  Assert(Assigned(Strings));
  Strings.Clear;
  //Strings.StrictDelimiter := True;
  //Strings.Delimiter := ' ';
  Strings.QuoteChar := '"';
  Strings.DelimitedText := Input;
end;

procedure clVar.SplitArray(Input: string; const Strings: TStrings);
begin
  Assert(Assigned(Strings));
  Strings.Clear;
  Strings.QuoteChar := '"';
  Strings.DelimitedText := Input;
end;

function clVar.passValue(Name: string; Value: string): boolean;
var
  valuetemp, nametemp: string;
  floattemp: double;
  i: integer;
begin
  valuetemp := trim(Value);
  nametemp := trim(Name);


  //valuetemp := Value;
  //nametemp:=Name;

  //Result := True;
  esFloat := True;

  //if they are empty
  if (valuetemp = '') or (nametemp = '') or (TryStrToFloat(nameTemp, floattemp)) then
  begin
    Result := False;
    exit;
  end;

  varname := nametemp;


  //*****
  esArray := False;
  //value
  //if it's a float
  if (TryStrToFloat(valuetemp, floattemp)) then
    varstr:=valuetemp
  else if (valuetemp[1] = '[') or (valuetemp[length(valuetemp)] = ']') then
  begin
    //trim '[' ']' de valuetemp
    Delete(valuetemp, 1, 1);
    setlength(valuetemp, length(valuetemp) - 1);
    //split to arrayValores(TStringList)
    SplitArray(valuetemp,arrayValores);
    esArray := True
  end
  else //failure = is a non empty string
    varstr := valuetemp;
  esFloat := False;
end;

end.
