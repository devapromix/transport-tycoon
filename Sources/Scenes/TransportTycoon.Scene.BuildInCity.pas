unit TransportTycoon.Scene.BuildInCity;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneBuildInCity = class(TScene)
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

{ TSceneBuildInCity }

procedure TSceneBuildInCity.Render;
var
  C: TCity;
  N: Byte;
  S: string;
  F: Boolean;
begin
  Game.Map.Draw(Self.Width, Self.Height - 1);

  DrawFrame(10, 5, 60, 15);

  C := Game.Map.City[Game.Map.CurrentCity];
  DrawTitle('BUILD IN ' + C.Name);

  F := (Game.Money >= C.AirportCost) and (C.Airport < 5);
  N := Math.EnsureRange(C.Airport + 1, 0, 5);
  S := '';
  if C.Airport < 5 then
    S := ' ($' + IntToStr(C.AirportCost) + ')';
  DrawButton(12, 9, F, 'A', 'Build ' + AirportSizeStr[N] + S);

  terminal_color('white');
  DrawButton(17, 'ESC', 'CLOSE');

  TSceneWorld(Scenes.GetScene(scWorld)).DrawBar;
end;

procedure TSceneBuildInCity.Update(var Key: Word);
var
  C: TCity;
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (MX >= 35) and (MX <= 45) then
      case MY of
        17:
          Key := TK_ESCAPE;
      end;
    if (MX >= 12) and (MX <= 46) then
      case MY of
        9:
          Key := TK_A;
      end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scCity);
    TK_A:
      begin
        C := Game.Map.City[Game.Map.CurrentCity];
        if (Game.Money >= C.AirportCost) and (C.Airport < 5) then
        begin
          C.BuildAirport;
          Scenes.SetScene(scAirport);
        end;
      end;

  end;
end;

end.
