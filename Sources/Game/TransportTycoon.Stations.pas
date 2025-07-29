unit TransportTycoon.Stations;

interface

type

  { TStation }

  TStation = class(TObject)
  private
    FCost: Integer;
    FLevel: Integer;
    FMaxLevel: Integer;
  public
    constructor Create(const ACost: Integer; const AMaxLevel: Integer = 1);
    property Level: Integer read FLevel write FLevel;
    property MaxLevel: Integer read FMaxLevel write FMaxLevel;
    function Cost: Integer;
    procedure Build;
    function CanBuild: Boolean;
    function IsBuilding: Boolean;
  end;

type

  { TAirport }

  TAirport = class(TStation);

type

  { TDock }

  TDock = class(TStation)
  private
    function IsNearWaterTile(const AX, AY: Integer): Boolean;
  public
    function CanBuild(const AX, AY: Integer): Boolean;
  end;

type

  { TTrainStation }

  TTrainStation = class(TStation);

implementation

{ TStation }

uses
  TransportTycoon.Game,
  TransportTycoon.Finances,
  TransportTycoon.Map;

procedure TStation.Build;
begin
  if CanBuild then
  begin
    Game.ModifyMoney(ttConstruction, -Cost);
    Inc(FLevel);
  end;
end;

function TStation.CanBuild: Boolean;
begin
  Result := (FLevel < FMaxLevel) and (Game.Money >= Cost);
end;

function TStation.Cost: Integer;
begin
  Result := 0;
  if (FLevel < FMaxLevel) then
    Result := (FLevel + 1) * FCost;
end;

constructor TStation.Create(const ACost: Integer; const AMaxLevel: Integer = 1);
begin
  FLevel := 0;
  FCost := ACost;
  FMaxLevel := AMaxLevel;
end;

function TStation.IsBuilding: Boolean;
begin
  Result := FLevel > 0;
end;

{ TDock }

function TDock.IsNearWaterTile(const AX, AY: Integer): Boolean;
var
  LTile: TTileEnum;
begin
  Result := False;
  for LTile := tlWater to tlDeepWater do
    if Game.Map.IsNearTile(AX, AY, LTile) then
      Exit(True);
end;

function TDock.CanBuild(const AX, AY: Integer): Boolean;
begin
  Result := (FLevel < FMaxLevel) and (Game.Money >= Cost) and
    IsNearWaterTile(AX, AY);
end;

end.
