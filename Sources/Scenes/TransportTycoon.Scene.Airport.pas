unit TransportTycoon.Scene.Airport;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneAirport = class(TScene)
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
  TransportTycoon.Scene.World,
  TransportTycoon.City;

procedure TSceneAirport.Render;
var
  C: TCity;
  I: Integer;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(10, 5, 60, 15);

  C := Game.Map.City[Game.Map.CurrentCity];
  DrawTitle(C.Name + ' AIRPORT');

  terminal_color('white');
  DrawText(12, 9, 'SIZE: ' + UpperCase(AirportSizeStr[C.Airport]));
  DrawText(12, 10, 'PASSENGERS: ' + IntToStr(C.Passengers.Airport));
  DrawText(12, 11, 'BAGS OF MAIL: ' + IntToStr(C.Mail.Airport));

  for I := 0 to Length(Game.Vehicles.Aircraft) - 1 do
    DrawButton(42, I + 9, (Game.Vehicles.Aircraft[I].X = C.X) and
      (Game.Vehicles.Aircraft[I].Y = C.Y), Chr(Ord('A') + I),
      Game.Vehicles.Aircraft[I].Name);

  DrawButton(28, 17, 'H', 'HANGAR');
  DrawText(39, 17, '|');
  DrawButton(41, 17, 'ESC', 'CLOSE');

  DrawBar;
end;

procedure TSceneAirport.Update(var Key: Word);
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (MX >= 28) and (MX <= 37) then
      case MY of
        17:
          Key := TK_H;
      end;
    if (MX >= 41) and (MX <= 51) then
      case MY of
        17:
          Key := TK_ESCAPE;
      end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scCity);
    TK_A .. TK_G:
      begin
        Game.Vehicles.CurrentVehicle := Key - TK_A;
        Scenes.SetScene(scAircraft);
      end;
    TK_H:
      Scenes.SetScene(scHangar);
  end;
end;

end.
