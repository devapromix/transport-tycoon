unit TransportTycoon.Vehicles;

interface

uses
  TransportTycoon.Aircraft;

type
  TVehicles = class
  private
    FCurrentVehicle: Integer;
  public const
    MaxAircrafts = 7;
  public
    Aircraft: array of TAircraft;
    constructor Create;
    destructor Destroy; override;
    property CurrentVehicle: Integer read FCurrentVehicle write FCurrentVehicle;
    procedure Draw;
    procedure Step;
    procedure AddAircraft(const AName: string;
      const ACityIndex, AircraftID: Integer);
    procedure RunningCosts;
    function GetCurrentAircraft(const AX, AY: Integer): Integer;
    procedure Clear;
  end;

implementation

uses
  BearLibTerminal,
  TransportTycoon.Game,
  TransportTycoon.Finances;

procedure TVehicles.AddAircraft(const AName: string;
  const ACityIndex, AircraftID: Integer);
begin
  if ((Game.Map.Town[ACityIndex].Airport.Level > 0) and
    (Game.Money >= AircraftBase[AircraftID].Cost)) then
    with Game.Vehicles do
    begin
      SetLength(Aircraft, Length(Aircraft) + 1);

      Aircraft[High(Aircraft)] := TAircraft.Create(AName,
        Game.Map.Town[ACityIndex].X, Game.Map.Town[ACityIndex].Y, AircraftID);

      with Aircraft[High(Aircraft)] do
      begin
        AddOrder(ACityIndex, Game.Map.Town[ACityIndex].Name,
          Game.Map.Town[ACityIndex].X, Game.Map.Town[ACityIndex].Y);
        Game.ModifyMoney(ttNewVehicles, -AircraftBase[AircraftID].Cost);
        VehicleID := AircraftID;
      end;
    end;
end;

procedure TVehicles.RunningCosts;
var
  I, J, M: Integer;
begin
  for I := 0 to Length(Aircraft) - 1 do
  begin
    J := Self.Aircraft[I].VehicleID;
    M := AircraftBase[J].RunningCost div 12;
    Game.ModifyMoney(ttAircraftRunningCosts, -M);
  end;
end;

procedure TVehicles.Clear;
var
  I: Integer;
begin
  for I := 0 to Length(Aircraft) - 1 do
    Aircraft[I].Free;
  SetLength(Aircraft, 0);
end;

constructor TVehicles.Create;
begin
  CurrentVehicle := 0;
end;

destructor TVehicles.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Aircraft) - 1 do
    Aircraft[I].Free;
  inherited;
end;

procedure TVehicles.Draw;
var
  I: Integer;
begin
  terminal_color('lightest blue');
  for I := 0 to Length(Aircraft) - 1 do
    Aircraft[I].Draw;

  terminal_color('white');
end;

function TVehicles.GetCurrentAircraft(const AX, AY: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Length(Aircraft) - 1 do
    if ((Aircraft[I].X = AX) and (Aircraft[I].Y = AY)) then
      Exit(I);
end;

procedure TVehicles.Step;
var
  I: Integer;
begin
  for I := 0 to Length(Aircraft) - 1 do
    Aircraft[I].Step;
end;

end.
