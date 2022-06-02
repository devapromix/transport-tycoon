unit TransportTycoon.Scene.Orders;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneOrders = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

implementation

uses
  BearLibTerminal,
  Math,
  SysUtils,
  TransportTycoon.Game;

procedure TSceneOrders.Render;
var
  TownID: Integer;
  F: Boolean;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(10, 5, 60, 15);
  with Game.Vehicles do
  begin
    DrawTitle(Aircraft[CurrentVehicle].Name + ' Orders');

    for TownID := 0 to Length(Game.Map.City) - 1 do
    begin
      F := not(Aircraft[CurrentVehicle].IsOrder(TownID) or
        (Game.Map.City[TownID].Airport = 0));
      DrawButton(12, TownID + 9, F, Chr(Ord('A') + TownID),
        'Go to ' + Game.Map.City[TownID].Name + ' Airport');
    end;
  end;

  DrawButton(17, 'ESC', 'CLOSE');

  DrawBar;
end;

procedure TSceneOrders.Update(var Key: Word);
var
  TownID: Integer;
  F: Boolean;
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (MX >= 36) and (MX <= 46) then
      case MY of
        17:
          Key := TK_ESCAPE;
      end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scAircraft);
    TK_A .. TK_G:
      with Game.Vehicles do
      begin
        TownID := Key - TK_A;
        F := not(Aircraft[CurrentVehicle].IsOrder(TownID) or
          (Game.Map.City[TownID].Airport = 0));
        if F then
          with Game.Vehicles do
          begin
            Aircraft[CurrentVehicle].AddOrder(TownID);
            Scenes.SetScene(scAircraft);
          end;
      end;
  end;
end;

end.
