unit TransportTycoon.Scene.AircraftOrders;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneAircraftOrders = class(TScene)
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

procedure TSceneAircraftOrders.Render;
var
  TownID: Integer;
  F: Boolean;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(20, 5, 40, 19);
  with Game.Vehicles do
  begin
    DrawTitle(7, Aircraft[CurrentVehicle].Name + ' Orders');

    for TownID := 0 to Length(Game.Map.Town) - 1 do
    begin
      F := not(Aircraft[CurrentVehicle].IsOrder(TownID) or
        (Game.Map.Town[TownID].Airport.Level = 0));
      DrawButton(22, TownID + 9, F, Chr(Ord('A') + TownID),
        'Go to ' + Game.Map.Town[TownID].Name + ' Airport');
    end;
  end;

  AddButton(21, 'Esc', 'Close');

  DrawBar;
end;

procedure TSceneAircraftOrders.Update(var Key: Word);
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
      Scenes.SetScene(scAircraft);
    TK_A .. TK_K:
      with Game.Vehicles do
      begin
        TownID := Key - TK_A;
        F := not(Aircraft[CurrentVehicle].IsOrder(TownID) or
          (Game.Map.Town[TownID].Airport.Level = 0));
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
