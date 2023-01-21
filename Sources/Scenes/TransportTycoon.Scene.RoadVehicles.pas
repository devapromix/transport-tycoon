unit TransportTycoon.Scene.RoadVehicles;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Scene.Vehicles;

type

  { TSceneRoadVehicles }

  TSceneRoadVehicles = class(TSceneVehicles)
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

{ TSceneRoadVehicles }

procedure TSceneRoadVehicles.Render;
var
  LVehicle: Integer;
begin
  inherited Render;
  DrawTitle(Game.Company.Name + ' Road Vehicles');
  for LVehicle := 0 to Game.Vehicles.RoadVehicleCount - 1 do
    DrawButton(12, LVehicle + 11, Chr(Ord('A') + LVehicle),
      Game.Vehicles.RoadVehicle[LVehicle].Name);
end;

procedure TSceneRoadVehicles.Update(var AKey: Word);
var
  LVehicle: Integer;
begin
  inherited Update(AKey);
  case AKey of
    TK_A .. TK_G:
      begin
        LVehicle := AKey - TK_A;
        if LVehicle > Game.Vehicles.RoadVehicleCount - 1 then
          Exit;
        Game.Vehicles.CurrentVehicle := LVehicle;
        with Game.Vehicles.RoadVehicle[LVehicle] do
          ScrollTo(X, Y);
        Scenes.SetScene(scRoadVehicle, scRoadVehicles);
      end;
  end;
end;

end.
