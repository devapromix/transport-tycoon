unit TransportTycoon.Scene.RoadVehicleOrders;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneRoadVehicleOrders = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

implementation

uses
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Game,
  TransportTycoon.Industries;

procedure TSceneRoadVehicleOrders.Render;
var
  I: Integer;
  F: Boolean;
begin
  DrawMap(Self.ScreenWidth, Self.ScreenHeight - 1);

  DrawFrame(20, 5, 40, 19);
  with Game.Vehicles do
  begin
    DrawTitle(7, RoadVehicle[CurrentVehicle].Name + ' Orders');

    for I := 0 to Length(Game.Map.Industry) - 1 do
    begin
      F := not(RoadVehicle[CurrentVehicle].IsOrder(I) or
        (Game.Map.Industry[I].TruckLoadingBay.Level = 0));
      DrawButton(22, I + 9, F, Chr(Ord('A') + I),
        'Go to ' + Game.Map.Industry[I].Name + ' Truck Loading Bay');
    end;
  end;

  AddButton(21, 'Esc', 'Close');

  DrawBar;
end;

procedure TSceneRoadVehicleOrders.Update(var Key: Word);
var
  I: Integer;
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    case MX of
      22 .. 56:
        case MY of
          9 .. 19:
            Key := TK_A + (MY - 9);
        end;
    end;
    if (GetButtonsY = MY) then
      case MX of
        35 .. 45:
          Key := TK_ESCAPE;
      end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scRoadVehicle);
    TK_A .. TK_K:
      with Game.Vehicles do
      begin
        I := Key - TK_A;
        if not(RoadVehicle[CurrentVehicle].IsOrder(I) or not Game.Map.Industry
          [I].TruckLoadingBay.IsBuilding) then
          with Game.Vehicles do
          begin
            if Game.Map.Industry[I].TruckLoadingBay.IsBuilding then
              RoadVehicle[CurrentVehicle].AddOrder(I);
            Scenes.SetScene(scRoadVehicle);
          end;
      end;
  end;
end;

end.
