unit TransportTycoon.Scene.Aircrafts;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Scene.Vehicles;

type

  { TSceneAircrafts }

  TSceneAircrafts = class(TSceneVehicles)
  private

  public
    procedure Render; override;
    procedure Update(var AKey: Word); override;
  end;

implementation

uses
  BearLibTerminal,
  SysUtils,
  TransportTycoon.Game;

{ TSceneAircrafts }

procedure TSceneAircrafts.Render;
var
  LVehicle: Integer;
begin
  inherited Render;
  DrawTitle(Game.Company.GetName + ' AIRCRAFTS');
  for LVehicle := 0 to Game.Vehicles.AircraftCount - 1 do
    DrawButton(12, LVehicle + 11, Chr(Ord('A') + LVehicle),
      Game.Vehicles.Aircraft[LVehicle].Name);
end;

procedure TSceneAircrafts.Update(var AKey: Word);
var
  LVehicle: Integer;
begin
  inherited Update(AKey);
  case AKey of
    TK_A .. TK_G:
      begin
        LVehicle := AKey - TK_A;
        if LVehicle > Game.Vehicles.AircraftCount - 1 then
          Exit;
        Game.Vehicles.CurrentVehicle := LVehicle;
        with Game.Vehicles.Aircraft[LVehicle] do
          ScrollTo(X, Y);
        Scenes.SetScene(scAircraft, scAircrafts);
      end;
  end;
end;

end.
