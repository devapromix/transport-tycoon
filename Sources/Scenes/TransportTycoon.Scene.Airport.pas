unit TransportTycoon.Scene.Airport;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneAirport = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var Key: word); override;
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
  Game.Map.Draw(Self.Width, Self.Height - 1);

  DrawFrame(10, 5, 60, 15);

  C := Game.Map.City[Game.Map.CurrentCity];
  DrawTitle(UpperCase(C.Name + ' AIRPORT'));

  terminal_color('white');
  DrawText(12, 9, 'SIZE: ' + UpperCase(AirportSizeStr[C.Airport]));
  DrawText(12, 10, 'PASSENGERS: ' + IntToStr(C.Passengers.Airport));
  DrawText(12, 11, 'BAGS OF MAIL: ' + IntToStr(C.Mail.Airport));

  for I := 0 to Length(Game.Aircraft) - 1 do
    DrawButton(42, I + 9, (Game.Aircraft[I].X = C.X) and
      (Game.Aircraft[I].Y = C.Y), Chr(Ord('A') + I), Game.Aircraft[I].Name);

  DrawButton(17, 'ESC', 'CLOSE');

  TSceneWorld(Scenes.GetScene(scWorld)).DrawBar;
end;

procedure TSceneAirport.Update(var Key: word);
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
      Scenes.SetScene(scCity);
    TK_H:
      Scenes.SetScene(scHangar);
    TK_V: // Test
      if Length(Game.Aircraft) < 7 then
        Game.Aircrafts.AddAircraft('Aircraft #' + IntToStr(Length(Game.Aircraft)
          + 1), Game.Map.CurrentCity, 25);

  end;
end;

end.
