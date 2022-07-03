unit TransportTycoon.Scene.BuildNearIndustry;

interface

uses
  TransportTycoon.Scenes;

type

  { TSceneBuildNearIndustry }

  TSceneBuildNearIndustry = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

implementation

uses
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Game,
  TransportTycoon.Industries;

{ TSceneBuildNearIndustry }

var
  Industry: TIndustry;

procedure TSceneBuildNearIndustry.Render;
var
  S: string;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(15, 7, 50, 15);

  Industry := Game.Map.Industry[Game.Map.CurrentIndustry];
  DrawTitle('BUILD IN ' + Industry.Name);

  S := '';
  if Industry.Dock.Level = 0 then
    S := ' ($' + IntToStr(Industry.Dock.Cost) + ')';
  DrawButton(17, 11, Industry.Dock.CanBuild(Industry.X, Industry.Y), 'D',
    'Build Dock' + S);

  AddButton(19, 'Esc', 'Close');

  DrawBar;
end;

procedure TSceneBuildNearIndustry.Update(var Key: Word);
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (MX >= 35) and (MX <= 45) then
      case MY of
        19:
          Key := TK_ESCAPE;
      end;
    if (MX >= 17) and (MX <= 62) then
      case MY of
        11:
          Key := TK_D;
      end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scIndustry);
    TK_D:
      begin
        if Industry.Dock.CanBuild(Industry.X, Industry.Y) then
        begin
          Industry.Dock.Build;
          Scenes.SetScene(scDock, scIndustry);
        end;
      end;
  end;
end;

end.
