unit TransportTycoon.Vehicles;

interface

uses
  TransportTycoon.Vehicle,
  TransportTycoon.Aircraft;

type
  TVehicles = class(TVehicle)
  private

  public
    CurrentVehicle: Integer;
    Aircraft: array of TAircraft;
    constructor Create;
    destructor Destroy; override;
    procedure Draw; override;
    procedure Step; override;
    procedure AddAircraft(const AName: string;
      const ACityIndex, AMaxPassengers: Integer);
  end;

implementation

uses
  BearLibTerminal,
  TransportTycoon.Game,
  TransportTycoon.Finances;

procedure TVehicles.AddAircraft(const AName: string;
  const ACityIndex, AMaxPassengers: Integer);
begin
  if ((Game.Map.City[ACityIndex].Airport > 0) and (Game.Money >= 1000)) then
    with Game.Vehicles do
    begin
      SetLength(Aircraft, Length(Aircraft) + 1);

      Aircraft[High(Aircraft)] := TAircraft.Create(AName,
        Game.Map.City[ACityIndex].X, Game.Map.City[ACityIndex].Y,
        AMaxPassengers);

      Aircraft[High(Aircraft)].AddOrder(ACityIndex,
        Game.Map.City[ACityIndex].Name, Game.Map.City[ACityIndex].X,
        Game.Map.City[ACityIndex].Y);
      Game.ModifyMoney(ttNewVehicles, -1000);
    end;
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
