unit TransportTycoon.Construct;

interface

type
  TConstructEnum = (ceClearLand, ceBuildCanal);

type

  { TConstruct }

  TConstruct = class(TObject)
  private
    FConstruct: array [TConstructEnum] of Boolean;
  public
    constructor Create;
    procedure Clear;
    function IsConstruct: Boolean;
    function IsBuild(const C: TConstructEnum): Boolean;
    procedure Build(const C: TConstructEnum);
  end;

implementation

{ TConstruct }

procedure TConstruct.Build(const C: TConstructEnum);
begin
  Clear;
  FConstruct[C] := True;
end;

procedure TConstruct.Clear;
var
  C: TConstructEnum;
begin
  for C := Low(TConstructEnum) to High(TConstructEnum) do
    FConstruct[C] := False;
end;

constructor TConstruct.Create;
begin
  Clear;
end;

function TConstruct.IsBuild(const C: TConstructEnum): Boolean;
begin
  Result := FConstruct[C];
end;

function TConstruct.IsConstruct: Boolean;
var
  C: TConstructEnum;
begin
  Result := False;
  for C := Low(TConstructEnum) to High(TConstructEnum) do
    if FConstruct[C] then
      Exit(True);
end;

end.
