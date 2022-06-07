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

  DrawFrame(10, 7, 60, 15);

  C := Game.Map.City[Game.Map.CurrentCity];

  DrawTitle(C.Name + ' Airport Hangar');

  for I := 0 to Length(AircraftBase) - 1 do
    DrawButton(12, I + 11, Chr(Ord('A') + I), AircraftBase[I].Name);

  I := Math.EnsureRange(Game.Vehicles.CurrentVehicle, 0,
    Length(AircraftBase) - 1);
  DrawText(42, 11, AircraftBase[I].Name);

  AddButton(19, 'Enter', 'Buy Aircraft');
  AddButton(19, 'Esc', 'Close');

  DrawBar;
end;

procedure TSceneHangar.Update(var Key: Word);
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (MX >= 12) and (MX <= 38) then
      case MY of
        11 .. 17:
          Key := TK_A + (MY - 11);
      end;
    if (MX >= 23) and (MX <= 42) then
      case MY of
        19:
          Key := TK_ENTER;
      end;
    if (MX >= 46) and (MX <= 56) then
      case MY of
        19:
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
