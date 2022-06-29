unit TransportTycoon.Scene.ShipOrders;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneShipOrders = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

implementation

uses
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Game;

procedure TSceneShipOrders.Render;
var
  TownID: Integer;
  F: Boolean;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(20, 5, 40, 19);
  with Game.Vehicles do
  begin
    DrawTitle(7, Ship[CurrentVehicle].Name + ' Orders');

    for TownID := 0 to Length(Game.Map.Town) - 1 do
    begin
      F := not(Ship[CurrentVehicle].IsOrder(TownID) or
        (Game.Map.Town[TownID].Dock.Level = 0));
      DrawButton(22, TownID + 9, F, Chr(Ord('A') + TownID),
        'Go to ' + Game.Map.Town[TownID].Name + ' Dock');
    end;
  end;

  AddButton(21, 'Esc', 'Close');

  DrawBar;
end;

procedure TSceneShipOrders.Update(var Key: Word);
var
  TownID: Integer;
  F: Boolean;
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (MX >= 22) and (MX <= 56) then
      case MY of
        9 .. 19:
          Key := TK_A + (MY - 9);
      end;
    if (GetButtonsY = MY) then
    begin
      if (MX >= 35) and (MX <= 45) then
        Key := TK_ESCAPE;
    end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scShip);
    TK_A .. TK_K:
      with Game.Vehicles do
      begin
        TownID := Key - TK_A;
        F := not(Ship[CurrentVehicle].IsOrder(TownID) or
          (Game.Map.Town[TownID].Dock.Level = 0));
        if F then
          with Game.Vehicles do
          begin
            Ship[CurrentVehicle].AddOrder(TownID);
            Scenes.SetScene(scShip);
          end;
      end;
  end;
end;

end.
