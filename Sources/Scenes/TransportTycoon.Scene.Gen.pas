unit TransportTycoon.Scene.Gen;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneGen = class(TScene)
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
  TransportTycoon.Map;

procedure TSceneGen.Render;
begin
  DrawFrame(10, 5, 60, 15);
  DrawTitle('WORLD GENERATION');

  DrawText(12, 9, 'Map size: ' + MapSizeStr[Game.Map.Size]);
  DrawText(42, 9, 'No. of towns: ' + MapNoOfTownsStr[Game.Map.NoOfTowns]);

  // DrawText(12, 10, "[[C]] Rivers: " + gen_rivers_str());
  // DrawText(42, 10, "[[D]] No. of ind.: " + gen_indust_str());

  // DrawText(12, 11, "[[E]] Sea level: " + gen_sea_level_str());
  DrawText(42, 11, Format('Date: %s %d, %d', [MonStr[Game.Month], Game.Day,
    Game.Year]));

  DrawButton(23, 17, 'ENTER', 'GENERATE');
  DrawText(40, 17, '|');
  DrawButton(42, 17, 'ESC', 'BACK');
end;

procedure TSceneGen.Update(var Key: word);
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (MX >= 23) and (MX < 39) then
      case MY of
        17:
          Key := TK_ENTER;
      end;
    if (MX >= 42) and (MX < 52) then
      case MY of
        17:
          Key := TK_ESCAPE;
      end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scMenu);
    TK_ENTER:
      begin
        Game.Clear;
        Game.Map.Gen;
        Game.IsPause := False;
        Scenes.SetScene(scWorld);
      end;
  end;
end;

end.
