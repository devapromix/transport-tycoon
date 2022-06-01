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
begin
  Game.Map.Draw(Self.Width, Self.Height - 1);

  DrawFrame(10, 5, 60, 15);

  C := Game.Map.City[Game.Map.CurrentCity];
  DrawTitle(UpperCase(C.Name + ' ' + AirportSizeStr[C.Airport]));

  terminal_color('white');
  DrawText(12, 9, 'Passengers: ' + IntToStr(C.Passengers.Airport));
  DrawText(12, 10, 'Mail: ' + IntToStr(C.Mail.Airport));

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
          begin
            Scenes.SetScene(scCity);
          end;
      end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scCity);
  end;
end;

end.
