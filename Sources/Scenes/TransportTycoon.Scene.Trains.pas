unit TransportTycoon.Scene.Trains;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Scene.Vehicles;

type

  { TSceneTrains }

  TSceneTrains = class(TSceneVehicles)
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

{ TSceneTrains }

procedure TSceneTrains.Render;
var
  LVehicle: Integer;
begin
  inherited Render;
  DrawTitle(Game.Company.GetName + ' Trains');
  for LVehicle := 0 to Game.Vehicles.ShipCount - 1 do
    DrawButton(12, LVehicle + 11, Chr(Ord('A') + LVehicle),
      Game.Vehicles.Ship[LVehicle].Name);
end;

procedure TSceneTrains.Update(var AKey: Word);
var
  LVehicle: Integer;
begin
  inherited Update(AKey);
  case AKey of
    TK_A .. TK_G:
      begin
        LVehicle := AKey - TK_A;
        if LVehicle > Game.Vehicles.ShipCount - 1 then
          Exit;
        Game.Vehicles.CurrentVehicle := LVehicle;
        with Game.Vehicles.Ship[LVehicle] do
          ScrollTo(X, Y);
        Scenes.SetScene(scShip, scTrains);
      end;
  end;
end;

end.
