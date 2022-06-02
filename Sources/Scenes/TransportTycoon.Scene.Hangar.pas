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
  TransportTycoon.City;

procedure TSceneHangar.Render;
var
  C: TCity;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(10, 5, 60, 15);

  C := Game.Map.City[Game.Map.CurrentCity];
  DrawTitle(UpperCase('HANGAR'));

  // terminal_color('white');
  // DrawText(12, 9, 'SIZE: ' + UpperCase(AirportSizeStr[C.Airport]));

  DrawButton(17, 'ESC', 'CLOSE');

  DrawBar;
end;

procedure TSceneHangar.Update(var Key: Word);
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
      Scenes.SetScene(scAirport);
  end;
end;

end.
