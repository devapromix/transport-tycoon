unit TransportTycoon.Construct;

interface

type
  TConstructEnum = (ceClearLand, ceLoweringLand, ceBuildCanal, ceBuildAqueduct,
    ceBuildRoad, ceBuildRoadTunnel, ceBuildRoadBridge);

type
  TInfrastructureCategory = (icNone, icLandscaping, icWaterways, icRoadways,
    icRailways);

const
  InfrastructureCategoryName: array [TInfrastructureCategory] of string = ('',
    'Landscaping', 'Waterways', 'Roadways', 'Railways');

type

  { TConstruct }

  TConstruct = class(TObject)
  private
    FConstruct: array [TConstructEnum] of Boolean;
  public
    constructor Create;
    procedure Clear;
    function IsConstruct: Boolean;
    function IsBuild(const AConstructEnum: TConstructEnum): Boolean;
    procedure Build(const AConstructEnum: TConstructEnum);
    function GetConstructStr: string;
  end;

implementation

{ TConstruct }

uses
  TransportTycoon.Map;

procedure TConstruct.Build(const AConstructEnum: TConstructEnum);
begin
  Clear;
  FConstruct[AConstructEnum] := True;
end;

procedure TConstruct.Clear;
var
  LConstructEnum: TConstructEnum;
begin
  for LConstructEnum := Low(TConstructEnum) to High(TConstructEnum) do
    FConstruct[LConstructEnum] := False;
end;

constructor TConstruct.Create;
begin
  Clear;
end;

function TConstruct.GetConstructStr: string;
var
  LConstructEnum: TConstructEnum;
begin
  Result := '';
  for LConstructEnum := Low(TConstructEnum) to High(TConstructEnum) do
    if FConstruct[LConstructEnum] then
      Exit(Construct[LConstructEnum].Name);
end;

function TConstruct.IsBuild(const AConstructEnum: TConstructEnum): Boolean;
begin
  Result := FConstruct[AConstructEnum];
end;

function TConstruct.IsConstruct: Boolean;
var
  LConstructEnum: TConstructEnum;
begin
  Result := False;
  for LConstructEnum := Low(TConstructEnum) to High(TConstructEnum) do
    if FConstruct[LConstructEnum] then
      Exit(True);
end;

end.
