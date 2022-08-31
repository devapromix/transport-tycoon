unit TransportTycoon.Construct;

interface

type
  TConstructEnum = (ceClearLand, ceBuildCanal, ceBuildRoad, ceBuildRoadTunnel,
    ceBuildRoadBridge);

type

  { TConstruct }

  TConstruct = class(TObject)
  private
    FConstruct: array [TConstructEnum] of Boolean;
  public
    constructor Create;
    procedure Clear;
    function IsConstruct: Boolean;
    function IsBuild(const ConstructEnum: TConstructEnum): Boolean;
    procedure Build(const ConstructEnum: TConstructEnum);
  end;

implementation

{ TConstruct }

procedure TConstruct.Build(const ConstructEnum: TConstructEnum);
begin
  Clear;
  FConstruct[ConstructEnum] := True;
end;

procedure TConstruct.Clear;
var
  ConstructEnum: TConstructEnum;
begin
  for ConstructEnum := Low(TConstructEnum) to High(TConstructEnum) do
    FConstruct[ConstructEnum] := False;
end;

constructor TConstruct.Create;
begin
  Clear;
end;

function TConstruct.IsBuild(const ConstructEnum: TConstructEnum): Boolean;
begin
  Result := FConstruct[ConstructEnum];
end;

function TConstruct.IsConstruct: Boolean;
var
  ConstructEnum: TConstructEnum;
begin
  Result := False;
  for ConstructEnum := Low(TConstructEnum) to High(TConstructEnum) do
    if FConstruct[ConstructEnum] then
      Exit(True);
end;

end.
