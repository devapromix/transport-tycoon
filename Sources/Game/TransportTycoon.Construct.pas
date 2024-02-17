unit TransportTycoon.Construct;

interface

type
  TConstructEnum = (ceClearLand, ceBuildCanal, ceBuildAqueduct, ceBuildRoad,
    ceBuildRoadTunnel, ceBuildRoadBridge);

const
  ConstructStr: array [TConstructEnum] of string = ('Clear Land', 'Build Canal',
    'Build Aqueduct', 'Build Road', 'Build Road Tunnel', 'Build Road Bridge');

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
      Exit(ConstructStr[LConstructEnum]);
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
