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
  TransportTycoon.Game,
  TransportTycoon.Industries;

procedure TSceneAircraftOrders.Render;
var
  I: Integer;
  F: Boolean;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(20, 5, 40, 19);
  with Game.Vehicles do
  begin
    DrawTitle(7, Aircraft[CurrentVehicle].Name + ' Orders');

    for I := 0 to Length(Game.Map.Industry) - 1 do
      if (Game.Map.Industry[I].IndustryType = inTown) then
      begin
        F := not(Aircraft[CurrentVehicle].IsOrder(I) or
          (TTownIndustry(Game.Map.Industry[I]).Airport.Level = 0));
        DrawButton(22, I + 9, F, Chr(Ord('A') + I),
          'Go to ' + Game.Map.Industry[I].Name + ' Airport');
      end;
  end;

  AddButton(21, 'Esc', 'Close');

  DrawBar;
end;

procedure TSceneAircraftOrders.Update(var Key: Word);
var
  I: Integer;
  F: Boolean;
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
      Scenes.SetScene(scAircraft);
    TK_A .. TK_K:
      with Game.Vehicles do
      begin
        I := Key - TK_A;
        F := not(Aircraft[CurrentVehicle].IsOrder(I) or
          (TTownIndustry(Game.Map.Industry[I]).Airport.Level = 0));
        if F then
          with Game.Vehicles do
          begin
            if TTownIndustry(Game.Map.Industry[I]).Airport.IsBuilding then
              Aircraft[CurrentVehicle].AddOrder(I);
            Scenes.SetScene(scAircraft);
          end;
      end;
  end;
end;

end.
