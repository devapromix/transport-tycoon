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
  TransportTycoon.Scene.World,
  TransportTycoon.City;

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
  DrawText(12, 10, 'Houses: ' + IntToStr(C.Houses));
  DrawButton(34, 9, C.Airport > 0, 'A', 'Airport: ' + AirportSizeStr[C.Airport]);
  terminal_color('white');

  DrawButton(30, 17, 'B', 'BUILD');
  DrawText(40, 17, '|');
  DrawButton(42, 17, 'ESC', 'CLOSE');

  TSceneWorld(Scenes.GetScene(scWorld)).DrawBar;
end;

procedure TSceneCity.Update(var Key: word);
var
  C: TCity;
begin
  C := Game.Map.City[Game.Map.CurrentCity];
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (MX >= 30) and (MX <= 38) then
      case MY of
        17:
          begin
            Scenes.SetScene(scBuildInCity);
          end;
      end;
    if (MX >= 42) and (MX <= 52) then
      case MY of
        17:
          begin
            Scenes.SetScene(scWorld);
          end;
      end;
    if (MX >= 34) and (MX <= 69) then
      case MY of
        9:
          begin
            Key := TK_A;
          end;
      end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scWorld);
    TK_A:
      if (C.Airport > 0) then
        Scenes.SetScene(scAirport);
    TK_B:
      Scenes.SetScene(scBuildInCity);
  end;
end;

end.
