unit TransportTycoon.Scene.Ships;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Scene.Vehicles;

type

  { TSceneShips }

  TSceneShips = class(TSceneVehicles)
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

{ TSceneShips }

procedure TSceneShips.Render;
var
  I: Integer;
begin
  inherited Render;
  DrawTitle(Game.Company.Name + ' SHIPS');
  for I := 0 to Game.Vehicles.ShipCount - 1 do
    DrawButton(12, I + 11, Chr(Ord('A') + I), Game.Vehicles.Ship[I].Name);
end;

procedure TSceneShips.Update(var AKey: Word);
var
  I: Integer;
begin
  inherited Update(AKey);
  case AKey of
    TK_A .. TK_G:
      begin
        I := AKey - TK_A;
        if I > Game.Vehicles.ShipCount - 1 then
          Exit;
        Game.Vehicles.CurrentVehicle := I;
        with Game.Vehicles.Ship[I] do
          ScrollTo(X, Y);
        Scenes.SetScene(scShip, scShips);
      end;
  end;
end;

end.
