unit TransportTycoon.Vehicles;

interface

uses
  TransportTycoon.Aircraft;

type
  TVehicles = class
  private

  public const
    MaxAircrafts = 7;
  public
    CurrentVehicle: Integer;
    Aircraft: array of TAircraft;
    constructor Create;
    destructor Destroy; override;
    procedure Draw;
    procedure Step;
    procedure AddAircraft(const AName: string;
      const ACityIndex, AircraftID: Integer);
    procedure RunningCosts;
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
  if ((Game.Map.City[ACityIndex].Airport > 0) and
    (Game.Money >= AircraftBase[AircraftID].Cost)) then
    with Game.Vehicles do
    begin
      SetLength(Aircraft, Length(Aircraft) + 1);

      Aircraft[High(Aircraft)] := TAircraft.Create(AName,
        Game.Map.City[ACityIndex].X, Game.Map.City[ACityIndex].Y, AircraftID);

      with Aircraft[High(Aircraft)] do
      begin
        AddOrder(ACityIndex, Game.Map.City[ACityIndex].Name,
          Game.Map.City[ACityIndex].X, Game.Map.City[ACityIndex].Y);
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

procedure TVehicles.Step;
var
  I: Integer;
begin
  for I := 0 to Length(Aircraft) - 1 do
    Aircraft[I].Step;
end;

end.
