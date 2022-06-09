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
  TransportTycoon.City;

procedure TSceneCity.Render;
var
  C: TCity;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(10, 8, 60, 13);

  C := Game.Map.City[Game.Map.CurrentCity];
  DrawTitle(10, C.Name);
  terminal_color('white');
  DrawText(12, 12, 'Population: ' + IntToStr(C.Population));
  DrawText(12, 13, 'Houses: ' + IntToStr(C.Houses));
  DrawButton(34, 12, C.Airport > 0, 'A', 'Airport: ' + AirportSizeStr
    [C.Airport]);
  terminal_color('white');

  AddButton(18, 'B', 'Build');
  AddButton(18, 'ESC', 'Close');

  DrawBar;
end;

procedure TSceneCity.Update(var Key: word);
var
  C: TCity;
begin
  C := Game.Map.City[Game.Map.CurrentCity];
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (MX >= 29) and (MX <= 37) then
      case MY of
        18:
          Key := TK_B;
      end;
    if (MX >= 41) and (MX <= 51) then
      case MY of
        18:
          Key := TK_ESCAPE;
      end;
    if (MX >= 34) and (MX <= 69) then
      case MY of
        12:
          Key := TK_A;
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
