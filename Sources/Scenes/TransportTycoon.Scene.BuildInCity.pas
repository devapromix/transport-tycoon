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
begin
  Game.Map.Draw(Self.Width, Self.Height - 1);

  DrawFrame(10, 5, 60, 15);

  C := Game.Map.City[Game.Map.CurrentCity];
  DrawTitle('BUILD IN ' + C.Name);

  if (Game.Money >= C.AirportCost) and (C.Airport < 5) then
    terminal_color('white')
  else
    terminal_color('gray');
  N := Math.EnsureRange(C.Airport + 1, 0, 5);
  S := '';
  if C.Airport < 5 then
    S := ' ($' + IntToStr(C.AirportCost) + ')';
  DrawText(12, 9, '[[A]] Build ' + AirportSizeStr[N] + S);

  terminal_color('white');
  DrawText(36, 17, '[[ESC]] CLOSE');

  TSceneWorld(Scenes.GetScene(scWorld)).DrawBar;
end;

procedure TSceneBuildInCity.Update(var Key: Word);
var
  C: TCity;
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
    if (MX >= 12) and (MX <= 46) then
      case MY of
        9:
          begin
            Key := TK_A;
          end;
      end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scCity);
    TK_A:
      begin
        C := Game.Map.City[Game.Map.CurrentCity];
        if Game.Money >= C.AirportCost then
          C.BuildAirport;
      end;

  end;
end;

end.
