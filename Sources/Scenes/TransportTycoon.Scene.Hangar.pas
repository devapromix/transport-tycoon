unit TransportTycoon.Scene.Hangar;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneHangar = class(TScene)
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
  TransportTycoon.Game,
  TransportTycoon.City,
  TransportTycoon.Aircraft;

procedure TSceneHangar.Render;
var
  C: TCity;
  I: Integer;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(10, 5, 60, 15);

  C := Game.Map.City[Game.Map.CurrentCity];

  DrawTitle(C.Name + ' Airport Hangar');

  for I := 0 to Length(AircraftBase) - 1 do
    DrawButton(12, I + 9, Chr(Ord('A') + I), AircraftBase[I].Name);

  I := Math.EnsureRange(Game.Vehicles.CurrentVehicle, 0,
    Length(AircraftBase) - 1);
  DrawText(42, 9, AircraftBase[I].Name);

  DrawButton(22, 17, 'ENTER', 'BUY AIRCRAFT');
  DrawText(43, 17, '|');
  DrawButton(45, 17, 'ESC', 'CLOSE');

  DrawBar;
end;

procedure TSceneHangar.Update(var Key: Word);
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (MX >= 12) and (MX <= 38) then
      case MY of
        9 .. 15:
          Key := TK_A + (MY - 9);
      end;
    if (MX >= 22) and (MX <= 41) then
      case MY of
        17:
          Key := TK_ENTER;
      end;
    if (MX >= 45) and (MX <= 55) then
      case MY of
        17:
          Key := TK_ESCAPE;
      end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scAirport);
    TK_A .. TK_G:
      begin
        if Key - TK_A > Length(AircraftBase) - 1 then
          Exit;
        Game.Vehicles.CurrentVehicle := Key - TK_A;
        Scenes.Render;
      end;
    TK_ENTER:
      begin
        if Length(Game.Vehicles.Aircraft) < 7 then
        begin
          Game.Vehicles.AddAircraft('Aircraft #' +
            IntToStr(Length(Game.Vehicles.Aircraft) + 1),
            Game.Map.CurrentCity, 25);
          Scenes.SetScene(scAirport);
        end;
      end;
  end;

end;

end.
