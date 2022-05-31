unit TransportTycoon.Scene.City;

interface

uses
  TransportTycoon.Scenes;

type

  TSceneCity = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var Key: word); override;
  end;

implementation

uses
  BearLibTerminal,
  SysUtils,
  TransportTycoon.Game,
  TransportTycoon.Scene.World, TransportTycoon.City;

procedure TSceneCity.Render;
var
  C: TCity;
begin
  Game.Map.Draw(Self.Width, Self.Height - 1);

  DrawFrame(10, 5, 60, 15);

  C := Game.Map.City[Game.Map.CurrentCity];
  DrawTitle(C.Name);
  terminal_color('white');
  DrawText(12, 9, 'Population: ' + IntToStr(C.Population));
  if C.Airport = 0 then
    terminal_color('dark gray');
  DrawText(34, 9, '[[A]] Airport: ' + AirportSizeStr[C.Airport]);
  terminal_color('white');
  DrawText(30, 17, '[[B]] BUILD | [[ESC]] CLOSE');

  TSceneWorld(Scenes.GetScene(scWorld)).DrawBar;

end;

procedure TSceneCity.Update(var Key: word);
begin
  if (Key = TK_MOUSE_LEFT) and (MX >= 30) and (MX <= 38) then
    case MY of
      17:
        begin
          Scenes.SetScene(scBuildInCity);
        end;
    end;
  if (Key = TK_MOUSE_LEFT) and (MX >= 42) and (MX <= 52) then
    case MY of
      17:
        begin
          Scenes.SetScene(scWorld);
        end;
    end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scWorld);
  end;
end;

end.
