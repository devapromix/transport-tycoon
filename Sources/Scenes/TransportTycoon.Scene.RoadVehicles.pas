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
  LVehicleIndex: Integer;
begin
  inherited Render;
  DrawTitle(Game.Company.Name + ' Road Vehicles');
  for LVehicleIndex := 0 to Game.Vehicles.RoadVehicleCount - 1 do
    DrawButton(12, LVehicleIndex + 11, Chr(Ord('A') + LVehicleIndex),
      Game.Vehicles.RoadVehicle[LVehicleIndex].Name);
end;

procedure TSceneRoadVehicles.Update(var AKey: Word);
var
  LVehicleIndex: Integer;
begin
  inherited Update(AKey);
  case AKey of
    TK_A .. TK_G:
      begin
        LVehicleIndex := AKey - TK_A;
        if LVehicleIndex > Game.Vehicles.RoadVehicleCount - 1 then
          Exit;
        Game.Vehicles.CurrentVehicle := LVehicleIndex;
        with Game.Vehicles.RoadVehicle[LVehicleIndex] do
          ScrollTo(X, Y);
        Scenes.SetScene(scRoadVehicle, scRoadVehicles);
      end;
  end;
end;

end.
