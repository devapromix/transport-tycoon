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
  LCurrentAircraft: Integer;
begin
  inherited Render;
  DrawTitle(Game.Company.Name + ' AIRCRAFTS');
  for LCurrentAircraft := 0 to Game.Vehicles.AircraftCount - 1 do
    DrawButton(12, LCurrentAircraft + 11, Chr(Ord('A') + LCurrentAircraft),
      Game.Vehicles.Aircraft[LCurrentAircraft].Name);
end;

procedure TSceneAircrafts.Update(var AKey: Word);
var
  LCurrentAircraft: Integer;
begin
  inherited Update(AKey);
  case AKey of
    TK_A .. TK_G:
      begin
        LCurrentAircraft := AKey - TK_A;
        if LCurrentAircraft > Game.Vehicles.AircraftCount - 1 then
          Exit;
        Game.Vehicles.CurrentVehicle := LCurrentAircraft;
        with Game.Vehicles.Aircraft[LCurrentAircraft] do
          ScrollTo(X, Y);
        Scenes.SetScene(scAircraft, scAircrafts);
      end;
  end;
end;

end.
