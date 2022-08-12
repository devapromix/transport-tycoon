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
    procedure Update(var Key: Word); override;
  end;

implementation

uses
  BearLibTerminal,
  SysUtils,
  TransportTycoon.Game;

{ TSceneRoadVehicles }

procedure TSceneRoadVehicles.Render;
var
  I: Integer;
begin
  inherited Render;
  DrawTitle(Game.Company.Name + ' Road Vehicles');
  for I := 0 to Game.Vehicles.RoadVehicleCount - 1 do
    DrawButton(12, I + 11, Chr(Ord('A') + I),
      Game.Vehicles.RoadVehicle[I].Name);
end;

procedure TSceneRoadVehicles.Update(var Key: Word);
var
  I: Integer;
begin
  inherited Update(Key);
  case Key of
    TK_A .. TK_G:
      begin
        I := Key - TK_A;
        if I > Game.Vehicles.RoadVehicleCount - 1 then
          Exit;
        Game.Vehicles.CurrentVehicle := I;
        with Game.Vehicles.RoadVehicle[I] do
          ScrollTo(X, Y);
        Scenes.SetScene(scRoadVehicle, scRoadVehicles);
      end;
  end;
end;

end.
